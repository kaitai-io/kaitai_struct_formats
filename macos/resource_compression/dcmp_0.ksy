meta:
  id: dcmp_0
  title: Compressed Macintosh resource data, Apple `'dcmp' (0)` format
  application: Mac OS
  license: MIT
  ks-version: "0.8"
  imports:
    - dcmp_variable_length_integer
  endian: be
doc: |
  Compressed resource data in `'dcmp' (0)` format,
  as stored in compressed resources with header type `8` and decompressor ID `0`.

  The `'dcmp' (0)` decompressor resource is included in the System file of System 7.0 and later.
  This compression format is used for most compressed resources in System 7.0's files.
  This decompressor is also included with and used by some other Apple applications,
  such as ResEdit.

  This compression format supports some basic general-purpose compression schemes,
  including backreferences to previous data,
  run-length encoding,
  and delta encoding.
  It also includes some types of compression tailored specifically to Mac OS resources,
  including a set of single-byte codes that correspond to entries in a hard-coded lookup table,
  and a specialized kind of delta encoding for segment loader jump tables.

  Almost all parts of this compression format operate on units of 2 or 4 bytes.
  As a result,
  it is nearly impossible to store data with an odd length in this format.
  To work around this limitation,
  odd-length resources are padded with an extra byte before compressing them with this format.
  This extra byte is ignored after decompression,
  as the real (odd) length of the resource is stored in the compressed resource header.

  The `'dcmp' (1)` compression format (see dcmp_1.ksy) is very similar to this format,
  with the main difference that it operates mostly on single bytes rather than two-byte units.
doc-ref: 'https://github.com/dgelessus/python-rsrcfork/blob/f891a6e/src/rsrcfork/compress/dcmp0.py'
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
            : tag >= 0x20 and tag <= 0x4a ? tag_kind::backreference
            : tag >= 0x4b and tag <= 0xfd ? tag_kind::table_lookup
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

          The length of the literal data is stored as a number of two-byte units.
          This means that the literal data always has an even length in bytes.
        params:
          - id: tag
            type: u1
            doc: |
              The tag byte preceding this chunk body.
        seq:
          - id: len_literal_div2_separate
            type: u1
            if: is_len_literal_div2_separate
            doc: |
              The length of the literal data,
              in two-byte units.

              This field is only present if the tag byte's low nibble is zero.
              In practice,
              this only happens if the length is 0x10 or greater,
              because smaller lengths can be encoded into the tag byte.
          - id: literal
            size: len_literal
            doc: |
              The literal data.
        instances:
          do_store:
            value: (tag & 0x10) != 0
            doc: |
              Whether this literal should be stored for use by future backreference chunks.

              See the documentation of the `backreference_body` type for details about backreference chunks.
          len_literal_div2_in_tag:
            value: tag & 0x0f
            doc: |
              The part of the tag byte that indicates the length of the literal data,
              in two-byte units.
              If this value is 0,
              the length is stored in a separate byte after the tag byte and before the literal data.
          is_len_literal_div2_separate:
            value: len_literal_div2_in_tag == 0
            doc: |
              Whether the length of the literal is stored separately from the tag.
          len_literal_div2:
            value: |
              is_len_literal_div2_separate
              ? len_literal_div2_separate
              : len_literal_div2_in_tag
            doc: |
              The length of the literal data,
              in two-byte units.

              In practice,
              this value is always greater than zero,
              as there is no use in storing a zero-length literal.
          len_literal:
            value: len_literal_div2 * 2
            doc: |
              The length of the literal data,
              in bytes.
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
            type:
              switch-on: tag
              cases:
                0x20: u1
                0x21: u1
                0x22: u2
            if: is_index_separate
            doc: |
              The index of the referenced literal chunk,
              stored separately from the tag.
              The value in this field is stored minus 0x28.
              If the tag byte is 0x21,
              the value is also stored minus 0x100,
              *on top of* the regular offset
              (i. e. minus 0x128 in total).

              In other words,
              for tag bytes 0x20 and 0x21,
              the index is actually 9 bits large,
              with the low 8 bits stored separately and the highest bit stored in the lowest bit of the tag byte.

              This field is only present if the tag byte is 0x20 through 0x22.
              For higher tag bytes,
              the index is encoded in the tag byte.
              Values smaller than 0x28 cannot be stored in this field,
              they must always be encoded in the tag byte.
        instances:
          is_index_separate:
            value: tag >= 0x20 and tag <= 0x22
            doc: |
              Whether the index is stored separately from the tag.
          index_in_tag:
            value: tag - 0x23
            doc: |
              The index of the referenced literal chunk,
              as stored in the tag byte.
          index_separate:
            value: |
              index_separate_minus + 0x28 + (tag == 0x21 ? 0x100 : 0)
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
                [0x00, 0x00],
                [0x4e, 0xba], [0x00, 0x08], [0x4e, 0x75], [0x00, 0x0c],
                [0x4e, 0xad], [0x20, 0x53], [0x2f, 0x0b], [0x61, 0x00],
                [0x00, 0x10], [0x70, 0x00], [0x2f, 0x00], [0x48, 0x6e],
                [0x20, 0x50], [0x20, 0x6e], [0x2f, 0x2e], [0xff, 0xfc],
                [0x48, 0xe7], [0x3f, 0x3c], [0x00, 0x04], [0xff, 0xf8],
                [0x2f, 0x0c], [0x20, 0x06], [0x4e, 0xed], [0x4e, 0x56],
                [0x20, 0x68], [0x4e, 0x5e], [0x00, 0x01], [0x58, 0x8f],
                [0x4f, 0xef], [0x00, 0x02], [0x00, 0x18], [0x60, 0x00],
                [0xff, 0xff], [0x50, 0x8f], [0x4e, 0x90], [0x00, 0x06],
                [0x26, 0x6e], [0x00, 0x14], [0xff, 0xf4], [0x4c, 0xee],
                [0x00, 0x0a], [0x00, 0x0e], [0x41, 0xee], [0x4c, 0xdf],
                [0x48, 0xc0], [0xff, 0xf0], [0x2d, 0x40], [0x00, 0x12],
                [0x30, 0x2e], [0x70, 0x01], [0x2f, 0x28], [0x20, 0x54],
                [0x67, 0x00], [0x00, 0x20], [0x00, 0x1c], [0x20, 0x5f],
                [0x18, 0x00], [0x26, 0x6f], [0x48, 0x78], [0x00, 0x16],
                [0x41, 0xfa], [0x30, 0x3c], [0x28, 0x40], [0x72, 0x00],
                [0x28, 0x6e], [0x20, 0x0c], [0x66, 0x00], [0x20, 0x6b],
                [0x2f, 0x07], [0x55, 0x8f], [0x00, 0x28], [0xff, 0xfe],
                [0xff, 0xec], [0x22, 0xd8], [0x20, 0x0b], [0x00, 0x0f],
                [0x59, 0x8f], [0x2f, 0x3c], [0xff, 0x00], [0x01, 0x18],
                [0x81, 0xe1], [0x4a, 0x00], [0x4e, 0xb0], [0xff, 0xe8],
                [0x48, 0xc7], [0x00, 0x03], [0x00, 0x22], [0x00, 0x07],
                [0x00, 0x1a], [0x67, 0x06], [0x67, 0x08], [0x4e, 0xf9],
                [0x00, 0x24], [0x20, 0x78], [0x08, 0x00], [0x66, 0x04],
                [0x00, 0x2a], [0x4e, 0xd0], [0x30, 0x28], [0x26, 0x5f],
                [0x67, 0x04], [0x00, 0x30], [0x43, 0xee], [0x3f, 0x00],
                [0x20, 0x1f], [0x00, 0x1e], [0xff, 0xf6], [0x20, 0x2e],
                [0x42, 0xa7], [0x20, 0x07], [0xff, 0xfa], [0x60, 0x02],
                [0x3d, 0x40], [0x0c, 0x40], [0x66, 0x06], [0x00, 0x26],
                [0x2d, 0x48], [0x2f, 0x01], [0x70, 0xff], [0x60, 0x04],
                [0x18, 0x80], [0x4a, 0x40], [0x00, 0x40], [0x00, 0x2c],
                [0x2f, 0x08], [0x00, 0x11], [0xff, 0xe4], [0x21, 0x40],
                [0x26, 0x40], [0xff, 0xf2], [0x42, 0x6e], [0x4e, 0xb9],
                [0x3d, 0x7c], [0x00, 0x38], [0x00, 0x0d], [0x60, 0x06],
                [0x42, 0x2e], [0x20, 0x3c], [0x67, 0x0c], [0x2d, 0x68],
                [0x66, 0x08], [0x4a, 0x2e], [0x4a, 0xae], [0x00, 0x2e],
                [0x48, 0x40], [0x22, 0x5f], [0x22, 0x00], [0x67, 0x0a],
                [0x30, 0x07], [0x42, 0x67], [0x00, 0x32], [0x20, 0x28],
                [0x00, 0x09], [0x48, 0x7a], [0x02, 0x00], [0x2f, 0x2b],
                [0x00, 0x05], [0x22, 0x6e], [0x66, 0x02], [0xe5, 0x80],
                [0x67, 0x0e], [0x66, 0x0a], [0x00, 0x50], [0x3e, 0x00],
                [0x66, 0x0c], [0x2e, 0x00], [0xff, 0xee], [0x20, 0x6d],
                [0x20, 0x40], [0xff, 0xe0], [0x53, 0x40], [0x60, 0x08],
                [0x04, 0x80], [0x00, 0x68], [0x0b, 0x7c], [0x44, 0x00],
                [0x41, 0xe8], [0x48, 0x41],
              ]
            doc: |
              Fixed lookup table that maps tag byte numbers to two bytes each.

              The entries in the lookup table are offset -
              index 0 stands for tag 0x4b, 1 for 0x4c, etc.
          value:
            value: lookup_table[tag - 0x4b]
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
                0x00: jump_table_body
                0x02: repeat_body(tag)
                0x03: repeat_body(tag)
                0x04: delta_encoding_16_bit_body
                0x06: delta_encoding_32_bit_body
            doc: |
              The chunk's body.
        types:
          jump_table_body:
            doc: |
              The body of a jump table chunk.

              This chunk generates parts of a segment loader jump table,
              in the format found in `'CODE' (0)` resources.
              It expands to the following data,
              with all non-constant numbers encoded as unsigned 16-bit big-endian integers:

              * `0x3f 0x3c` (push following segment number onto stack)
              * The segment number
              * `0xa9 0xf0` (`_LoadSeg` trap)
              * For each address:
                * The address
                * `0x3f 0x3c` (push following segment number onto stack)
                * The segment number
                * `0xa9 0xf0` (`_LoadSeg` trap)

              Note that this generates one jump table entry without an address before it,
              meaning that this address needs to be generated by the preceding chunk.
              All following jump table entries are generated with the addresses encoded in this chunk.
            seq:
              - id: segment_number_raw
                type: dcmp_variable_length_integer
                doc: |
                  Raw variable-length integer representation of `segment_number`.
              - id: num_addresses_raw
                type: dcmp_variable_length_integer
                doc: |
                  Raw variable-length integer representation of `num_addresses`.
              - id: addresses_raw
                type: dcmp_variable_length_integer
                repeat: expr
                repeat-expr: num_addresses
                doc: |
                  The addresses for each generated jump table entry,
                  stored as variable-length integers.

                  The first address is stored literally and must be in the range `0x0 <= x <= 0xffff`,
                  i. e. an unsigned 16-bit integer.

                  All following addresses are stored as deltas relative to the previous address.
                  Each of these deltas is stored plus 6;
                  this value needs to be subtracted before (or after) adding it to the previous address.

                  Each delta (after subtracting 6) should be positive,
                  and adding it to the previous address should not result in a value larger than `0xffff`,
                  i. e. there should be no 16-bit unsigned integer wraparound.
                  These conditions are always met in all known jump table chunks,
                  so it is not known how the original decompressor behaves otherwise.
            instances:
              segment_number:
                value: segment_number_raw.value
                doc: |
                  The segment number for all of the generated jump table entries.

                  Although it is stored as a variable-length integer,
                  the segment number must be in the range `0x0 <= x <= 0xffff`,
                  i. e. an unsigned 16-bit integer.
              num_addresses:
                value: num_addresses_raw.value
                doc: |
                  The number of addresses stored in this chunk.

                  This number must be greater than 0.
          repeat_body:
            doc: |
              The body of a repeat chunk.

              This chunk expands to a 1-byte or 2-byte value repeated a number of times,
              i. e. it implements a form of run-length encoding.
            params:
              - id: tag
                type: u1
                doc: |
                  The extended tag byte preceding this chunk body.
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
              byte_count:
                value: |
                  tag == 0x02 ? 1
                  : tag == 0x03 ? 2
                  : -1
                doc: |
                  The length in bytes of the value to be repeated.
                  Regardless of the byte count,
                  the value to be repeated is stored as a variable-length integer.
              to_repeat:
                value: to_repeat_raw.value
                doc: |
                  The value to repeat.

                  Although it is stored as a variable-length integer,
                  this value must fit into an unsigned big-endian integer that is as long as `byte_count`,
                  i. e. either 8 or 16 bits.
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
          delta_encoding_16_bit_body:
            doc: |
              The body of a 16-bit delta encoding chunk.

              This chunk expands to a sequence of 16-bit big-endian integer values.
              The first value is stored literally.
              All following values are stored as deltas relative to the previous value.
            seq:
              - id: first_value_raw
                type: dcmp_variable_length_integer
                doc: |
                  Raw variable-length integer representation of `first_value`.
              - id: num_deltas_raw
                type: dcmp_variable_length_integer
                doc: |
                  Raw variable-length integer representation of `num_deltas`.
              - id: deltas
                type: s1
                repeat: expr
                repeat-expr: num_deltas
                doc: |
                  The deltas for each value relative to the previous value.

                  Each of these deltas is a signed 8-bit value.
                  When adding the delta to the previous value,
                  16-bit integer wraparound is performed if necessary,
                  so that the resulting value always fits into a 16-bit signed integer.
            instances:
              first_value:
                value: first_value_raw.value
                doc: |
                  The first value in the sequence.

                  Although it is stored as a variable-length integer,
                  this value must be in the range `-0x8000 <= x <= 0x7fff`,
                  i. e. a signed 16-bit integer.
              num_deltas:
                value: num_deltas_raw.value
                doc: |
                  The number of deltas stored in this chunk.

                  This number must not be negative.
          delta_encoding_32_bit_body:
            doc: |
              The body of a 32-bit delta encoding chunk.

              This chunk expands to a sequence of 32-bit big-endian integer values.
              The first value is stored literally.
              All following values are stored as deltas relative to the previous value.
            seq:
              - id: first_value_raw
                type: dcmp_variable_length_integer
                doc: |
                  Raw variable-length integer representation of `first_value`.
              - id: num_deltas_raw
                type: dcmp_variable_length_integer
                doc: |
                  Raw variable-length integer representation of `num_deltas`.
              - id: deltas_raw
                type: dcmp_variable_length_integer
                repeat: expr
                repeat-expr: num_deltas
                doc: |
                  The deltas for each value relative to the previous value,
                  stored as variable-length integers.

                  Each of these deltas is a signed value.
                  When adding the delta to the previous value,
                  32-bit integer wraparound is performed if necessary,
                  so that the resulting value always fits into a 32-bit signed integer.
            instances:
              first_value:
                value: first_value_raw.value
                doc: |
                  The first value in the sequence.
              num_deltas:
                value: num_deltas_raw.value
                doc: |
                  The number of deltas stored in this chunk.

                  This number must not be negative.
      end_body:
        doc: |
          The body of an end chunk.
          This body is always empty.

          The last chunk in the compressed data must always be an end chunk.
          An end chunk cannot appear elsewhere in the compressed data.
        seq: []
