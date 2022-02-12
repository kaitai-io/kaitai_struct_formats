meta:
  id: dcmp_1
  title: Compressed Macintosh resource data, Apple `'dcmp' (1)` format
  application: Mac OS
  license: MIT
  ks-version: "0.8"
  imports:
    - dcmp_variable_length_integer
  endian: be
doc: |
  Compressed resource data in `'dcmp' (1)` format,
  as stored in compressed resources with header type `8` and decompressor ID `1`.

  The `'dcmp' (1)` decompressor resource is included in the System file of System 7.0 and later.
  This compression format is used for a few compressed resources in System 7.0's files
  (such as the Finder Help file).
  This decompressor is also included with and used by some other Apple applications,
  such as ResEdit.
  (Note: ResEdit includes the `'dcmp' (1)` resource,
  but none of its resources actually use this decompressor.)

  This compression format supports some basic general-purpose compression schemes,
  including backreferences to previous data and run-length encoding.
  It also includes some types of compression tailored specifically to Mac OS resources,
  including a set of single-byte codes that correspond to entries in a hard-coded lookup table.

  The `'dcmp' (0)` compression format (see dcmp_0.ksy) is very similar to this format,
  with the main difference that it operates mostly on units of 2 or 4 bytes.
  This makes the ``dcmp' (0)` format more suitable for word-aligned data,
  such as executable code, bitmaps, sounds, etc.
  The `'dcmp' (0)` format also appears to be generally preferred over `'dcmp' (1)`,
  with the latter only being used in resource files that contain mostly unaligned data,
  such as text.
doc-ref: 'https://github.com/dgelessus/python-rsrcfork/blob/f891a6e/src/rsrcfork/compress/dcmp1.py'
seq:
  - id: chunks
    type: chunk
    repeat: until
    repeat-until: _.tag == 0xff
    doc: |
      The sequence of chunks that make up the compressed data.
types:
  chunk:
    doc: |
      A single chunk of compressed data.
      Each chunk in the compressed data expands to a sequence of bytes in the uncompressed data,
      except when `tag == 0xff`,
      which marks the end of the data and does not correspond to any bytes in the uncompressed data.

      Most chunks are stateless and always expand to the same data,
      regardless of where the chunk appears in the sequence.
      However,
      some chunks affect the behavior of future chunks,
      or expand to different data depending on which chunks came before them.
    seq:
      - id: tag
        type: u1
        doc: |
          The chunk's tag byte.
          This controls the structure of the body and the meaning of the chunk.
      - id: body
        type:
          switch-on: |
            tag >= 0x00 and tag <= 0x1f ? tag_kind::literal
            : tag >= 0x20 and tag <= 0xcf ? tag_kind::backreference
            : tag >= 0xd0 and tag <= 0xd1 ? tag_kind::literal
            : tag == 0xd2 ? tag_kind::backreference
            : tag >= 0xd5 and tag <= 0xfd ? tag_kind::table_lookup
            : tag == 0xfe ? tag_kind::extended
            : tag == 0xff ? tag_kind::end
            : tag_kind::invalid
          cases:
            'tag_kind::literal': literal_body(tag)
            'tag_kind::backreference': backreference_body(tag)
            'tag_kind::table_lookup': table_lookup_body(tag)
            'tag_kind::extended': extended_body
            'tag_kind::end': end_body
        doc: |
          The chunk's body.

          Certain chunks do not have any data following the tag byte.
          In this case,
          the body is a zero-length structure.
    enums:
      # Internal enum, only for use in the type switch above.
      # This is a workaround for kaitai-io/kaitai_struct#489.
      tag_kind:
        -1: invalid
        0: literal
        1: backreference
        2: table_lookup
        3: extended
        4: end
    types:
      literal_body:
        doc: |
          The body of a literal data chunk.

          The data that this chunk expands to is stored literally in the body (`literal`).
          Optionally,
          the literal data may also be stored for use by future backreference chunks (`do_store`).
        params:
          - id: tag
            type: u1
            doc: |
              The tag byte preceding this chunk body.
        seq:
          - id: len_literal_separate
            type: u1
            if: is_len_literal_separate
            doc: |
              The length of the literal data,
              in bytes.

              This field is only present if the tag byte is 0xd0 or 0xd1.
              In practice,
              this only happens if the length is 0x11 or greater,
              because smaller lengths can be encoded into the tag byte.
          - id: literal
            size: len_literal
            doc: |
              The literal data.
        instances:
          do_store:
            value: |
              is_len_literal_separate ? tag == 0xd1 : (tag & 0x10) != 0
            doc: |
              Whether this literal should be stored for use by future backreference chunks.

              See the documentation of the `backreference_body` type for details about backreference chunks.
          len_literal_m1_in_tag:
            value: tag & 0x0f
            if: not is_len_literal_separate
            doc: |
              The part of the tag byte that indicates the length of the literal data,
              in bytes,
              minus one.

              If the tag byte is 0xd0 or 0xd1,
              the length is stored in a separate byte after the tag byte and before the literal data.
          is_len_literal_separate:
            value: tag >= 0xd0
            doc: |
              Whether the length of the literal is stored separately from the tag.
          len_literal:
            value: |
              is_len_literal_separate
              ? len_literal_separate
              : len_literal_m1_in_tag + 1
            doc: |
              The length of the literal data,
              in bytes.

              In practice,
              this value is always greater than zero,
              as there is no use in storing a zero-length literal.
      backreference_body:
        doc: |
          The body of a backreference chunk.

          This chunk expands to the data stored in a preceding literal chunk,
          indicated by an index number (`index`).
        params:
          - id: tag
            type: u1
            doc: |
              The tag byte preceding this chunk body.
        seq:
          - id: index_separate_minus
            type: u1
            if: is_index_separate
            doc: |
              The index of the referenced literal chunk,
              stored separately from the tag.
              The value in this field is stored minus 0xb0.

              This field is only present if the tag byte is 0xd2.
              For other tag bytes,
              the index is encoded in the tag byte.
              Values smaller than 0xb0 cannot be stored in this field,
              they must always be encoded in the tag byte.
        instances:
          is_index_separate:
            value: tag == 0xd2
            doc: |
              Whether the index is stored separately from the tag.
          index_in_tag:
            value: tag - 0x20
            doc: |
              The index of the referenced literal chunk,
              as stored in the tag byte.
          index_separate:
            value: |
              index_separate_minus + 0xb0
            if: is_index_separate
            doc: |
              The index of the referenced literal chunk,
              as stored separately from the tag byte,
              with the implicit offset corrected for.
          index:
            value: |
              is_index_separate ? index_separate : index_in_tag
            doc: |
              The index of the referenced literal chunk.

              Stored literals are assigned index numbers in the order in which they appear in the compressed data,
              starting at 0.
              Non-stored literals are not counted in the numbering and cannot be referenced using backreferences.
              Once an index is assigned to a stored literal,
              it is never changed or unassigned for the entire length of the compressed data.

              As the name indicates,
              a backreference can only reference stored literal chunks found *before* the backreference,
              not ones that come after it.
      table_lookup_body:
        doc: |
          The body of a table lookup chunk.
          This body is always empty.

          This chunk always expands to two bytes (`value`),
          determined from the tag byte using a fixed lookup table (`lookup_table`).
          This lookup table is hardcoded in the decompressor and always the same for all compressed data.
        params:
          - id: tag
            type: u1
            doc: |
              The tag byte preceding this chunk body.
        seq: []
        instances:
          lookup_table:
            value: |
              [
                [0x00, 0x00], [0x00, 0x01], [0x00, 0x02],
                [0x00, 0x03], [0x2e, 0x01], [0x3e, 0x01], [0x01, 0x01],
                [0x1e, 0x01], [0xff, 0xff], [0x0e, 0x01], [0x31, 0x00],
                [0x11, 0x12], [0x01, 0x07], [0x33, 0x32], [0x12, 0x39],
                [0xed, 0x10], [0x01, 0x27], [0x23, 0x22], [0x01, 0x37],
                [0x07, 0x06], [0x01, 0x17], [0x01, 0x23], [0x00, 0xff],
                [0x00, 0x2f], [0x07, 0x0e], [0xfd, 0x3c], [0x01, 0x35],
                [0x01, 0x15], [0x01, 0x02], [0x00, 0x07], [0x00, 0x3e],
                [0x05, 0xd5], [0x02, 0x01], [0x06, 0x07], [0x07, 0x08],
                [0x30, 0x01], [0x01, 0x33], [0x00, 0x10], [0x17, 0x16],
                [0x37, 0x3e], [0x36, 0x37],
              ]
            doc: |
              Fixed lookup table that maps tag byte numbers to two bytes each.

              The entries in the lookup table are offset -
              index 0 stands for tag 0xd5, 1 for 0xd6, etc.
          value:
            value: lookup_table[tag - 0xd5]
            doc: |
              The two bytes that the tag byte expands to,
              based on the fixed lookup table.
      extended_body:
        doc: |
          The body of an extended chunk.
          The meaning of this chunk depends on the extended tag byte stored in the chunk data.
        seq:
          - id: tag
            type: u1
            doc: |
              The chunk's extended tag byte.
              This controls the structure of the body and the meaning of the chunk.
          - id: body
            type:
              switch-on: tag
              cases:
                0x02: repeat_body
            doc: |
              The chunk's body.
        types:
          repeat_body:
            doc: |
              The body of a repeat chunk.

              This chunk expands to the same byte repeated a number of times,
              i. e. it implements a form of run-length encoding.
            seq:
              - id: to_repeat_raw
                type: dcmp_variable_length_integer
                doc: |
                  Raw variable-length integer representation of `to_repeat`.
              - id: repeat_count_m1_raw
                type: dcmp_variable_length_integer
                doc: |
                  Raw variable-length integer representation of `repeat_count_m1`.
            instances:
              to_repeat:
                value: to_repeat_raw.value
                doc: |
                  The value to repeat.

                  Although it is stored as a variable-length integer,
                  this value must fit into an unsigned 8-bit integer.
              repeat_count_m1:
                value: repeat_count_m1_raw.value
                doc: |
                  The number of times to repeat the value,
                  minus one.

                  This value must not be negative.
              repeat_count:
                value: repeat_count_m1 + 1
                doc: |
                  The number of times to repeat the value.

                  This value must be positive.
      end_body:
        doc: |
          The body of an end chunk.
          This body is always empty.

          The last chunk in the compressed data must always be an end chunk.
          An end chunk cannot appear elsewhere in the compressed data.
        seq: []
