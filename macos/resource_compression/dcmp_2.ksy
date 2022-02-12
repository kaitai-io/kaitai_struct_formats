meta:
  id: dcmp_2
  title: Compressed Macintosh resource data, Apple `'dcmp' (2)` format
  application: Mac OS
  license: MIT
  ks-version: "0.8"
  imports:
    - /common/bytes_with_io
  endian: be
doc: |
  Compressed resource data in `'dcmp' (2)` format,
  as stored in compressed resources with header type `9` and decompressor ID `2`.

  The `'dcmp' (2)` decompressor resource is included in the System file of System 7.0 and later.
  This compression format is used for a few compressed resources in System 7.0's files
  (such as the System file).
  This decompressor is also included with and used by some other Apple applications,
  such as ResEdit.
  (Note: ResEdit includes the `'dcmp' (2)` resource,
  but none of its resources actually use this decompressor.)

  This compression format is based on simple dictionary coding,
  where each byte in the compressed data expands to two bytes,
  based on a lookup table
  (either included in the compressed data or provided by the decompressor).
  An alternative "tagged" compression format is also supported,
  which allows using two-byte literals in addition to single-byte table references,
  at the cost of requiring an extra "tag" byte every 16 output bytes,
  to differentiate literals and table references.
doc-ref: 'https://github.com/dgelessus/python-rsrcfork/blob/f891a6e/src/rsrcfork/compress/dcmp2.py'
params:
  - id: len_decompressed
    type: u4
    doc: |
      The length of the decompressed data in bytes,
      from the compressed resource header.
  - id: header_parameters_with_io
    type: bytes_with_io
    doc: |
      The unparsed decompressor-specific parameters,
      from the compressed resource header.
seq:
  - id: custom_lookup_table
    size: 2
    repeat: expr
    repeat-expr: header_parameters.num_custom_lookup_table_entries
    if: header_parameters.flags.has_custom_lookup_table
    doc: |
      The custom lookup table to be used instead of the default lookup table.
  - id: data
    type:
      switch-on: header_parameters.flags.tagged
      cases:
        true: tagged_data
        # _ is equivalent to false here.
        # This is a workaround for kaitai-io/kaitai_struct#208 to make the compiler understand that the switch only has two cases,
        # so that it doesn't generate a third default case that maps to a byte array type.
        _: untagged_data
    # The data extends to one byte before EOS if the decompressed length is odd,
    # and otherwise extends completely to EOS.
    size: |
      _io.size - _io.pos - (is_len_decompressed_odd ? 1 : 0)
    doc: |
      The compressed data.
      The structure of the data varies depending on whether the "tagged" or "untagged" variant of the compression format is used.
  - id: last_byte
    size: 1
    if: is_len_decompressed_odd
    doc: |
      The last byte of the decompressed data,
      stored literally.
      Only present if the decompressed data has an odd length.

      This special case is necessary because the compressed data is otherwise always stored in two-byte groups,
      either literally or as table references,
      so otherwise there would be no way to compress odd-length resources using this format.
instances:
  header_parameters:
    io: header_parameters_with_io._io
    pos: 0
    type: header_parameters
    doc: |
      The parsed decompressor-specific parameters from the compressed resource header.
  is_len_decompressed_odd:
    value: len_decompressed % 2 != 0
    doc: |
      Whether the length of the decompressed data is odd.
      This affects the meaning of the last byte of the compressed data.
  default_lookup_table:
    value: |
      [
        [0x00, 0x00], [0x00, 0x08], [0x4e, 0xba], [0x20, 0x6e],
        [0x4e, 0x75], [0x00, 0x0c], [0x00, 0x04], [0x70, 0x00],
        [0x00, 0x10], [0x00, 0x02], [0x48, 0x6e], [0xff, 0xfc],
        [0x60, 0x00], [0x00, 0x01], [0x48, 0xe7], [0x2f, 0x2e],
        [0x4e, 0x56], [0x00, 0x06], [0x4e, 0x5e], [0x2f, 0x00],
        [0x61, 0x00], [0xff, 0xf8], [0x2f, 0x0b], [0xff, 0xff],
        [0x00, 0x14], [0x00, 0x0a], [0x00, 0x18], [0x20, 0x5f],
        [0x00, 0x0e], [0x20, 0x50], [0x3f, 0x3c], [0xff, 0xf4],
        [0x4c, 0xee], [0x30, 0x2e], [0x67, 0x00], [0x4c, 0xdf],
        [0x26, 0x6e], [0x00, 0x12], [0x00, 0x1c], [0x42, 0x67],
        [0xff, 0xf0], [0x30, 0x3c], [0x2f, 0x0c], [0x00, 0x03],
        [0x4e, 0xd0], [0x00, 0x20], [0x70, 0x01], [0x00, 0x16],
        [0x2d, 0x40], [0x48, 0xc0], [0x20, 0x78], [0x72, 0x00],
        [0x58, 0x8f], [0x66, 0x00], [0x4f, 0xef], [0x42, 0xa7],
        [0x67, 0x06], [0xff, 0xfa], [0x55, 0x8f], [0x28, 0x6e],
        [0x3f, 0x00], [0xff, 0xfe], [0x2f, 0x3c], [0x67, 0x04],
        [0x59, 0x8f], [0x20, 0x6b], [0x00, 0x24], [0x20, 0x1f],
        [0x41, 0xfa], [0x81, 0xe1], [0x66, 0x04], [0x67, 0x08],
        [0x00, 0x1a], [0x4e, 0xb9], [0x50, 0x8f], [0x20, 0x2e],
        [0x00, 0x07], [0x4e, 0xb0], [0xff, 0xf2], [0x3d, 0x40],
        [0x00, 0x1e], [0x20, 0x68], [0x66, 0x06], [0xff, 0xf6],
        [0x4e, 0xf9], [0x08, 0x00], [0x0c, 0x40], [0x3d, 0x7c],
        [0xff, 0xec], [0x00, 0x05], [0x20, 0x3c], [0xff, 0xe8],
        [0xde, 0xfc], [0x4a, 0x2e], [0x00, 0x30], [0x00, 0x28],
        [0x2f, 0x08], [0x20, 0x0b], [0x60, 0x02], [0x42, 0x6e],
        [0x2d, 0x48], [0x20, 0x53], [0x20, 0x40], [0x18, 0x00],
        [0x60, 0x04], [0x41, 0xee], [0x2f, 0x28], [0x2f, 0x01],
        [0x67, 0x0a], [0x48, 0x40], [0x20, 0x07], [0x66, 0x08],
        [0x01, 0x18], [0x2f, 0x07], [0x30, 0x28], [0x3f, 0x2e],
        [0x30, 0x2b], [0x22, 0x6e], [0x2f, 0x2b], [0x00, 0x2c],
        [0x67, 0x0c], [0x22, 0x5f], [0x60, 0x06], [0x00, 0xff],
        [0x30, 0x07], [0xff, 0xee], [0x53, 0x40], [0x00, 0x40],
        [0xff, 0xe4], [0x4a, 0x40], [0x66, 0x0a], [0x00, 0x0f],
        [0x4e, 0xad], [0x70, 0xff], [0x22, 0xd8], [0x48, 0x6b],
        [0x00, 0x22], [0x20, 0x4b], [0x67, 0x0e], [0x4a, 0xae],
        [0x4e, 0x90], [0xff, 0xe0], [0xff, 0xc0], [0x00, 0x2a],
        [0x27, 0x40], [0x67, 0x02], [0x51, 0xc8], [0x02, 0xb6],
        [0x48, 0x7a], [0x22, 0x78], [0xb0, 0x6e], [0xff, 0xe6],
        [0x00, 0x09], [0x32, 0x2e], [0x3e, 0x00], [0x48, 0x41],
        [0xff, 0xea], [0x43, 0xee], [0x4e, 0x71], [0x74, 0x00],
        [0x2f, 0x2c], [0x20, 0x6c], [0x00, 0x3c], [0x00, 0x26],
        [0x00, 0x50], [0x18, 0x80], [0x30, 0x1f], [0x22, 0x00],
        [0x66, 0x0c], [0xff, 0xda], [0x00, 0x38], [0x66, 0x02],
        [0x30, 0x2c], [0x20, 0x0c], [0x2d, 0x6e], [0x42, 0x40],
        [0xff, 0xe2], [0xa9, 0xf0], [0xff, 0x00], [0x37, 0x7c],
        [0xe5, 0x80], [0xff, 0xdc], [0x48, 0x68], [0x59, 0x4f],
        [0x00, 0x34], [0x3e, 0x1f], [0x60, 0x08], [0x2f, 0x06],
        [0xff, 0xde], [0x60, 0x0a], [0x70, 0x02], [0x00, 0x32],
        [0xff, 0xcc], [0x00, 0x80], [0x22, 0x51], [0x10, 0x1f],
        [0x31, 0x7c], [0xa0, 0x29], [0xff, 0xd8], [0x52, 0x40],
        [0x01, 0x00], [0x67, 0x10], [0xa0, 0x23], [0xff, 0xce],
        [0xff, 0xd4], [0x20, 0x06], [0x48, 0x78], [0x00, 0x2e],
        [0x50, 0x4f], [0x43, 0xfa], [0x67, 0x12], [0x76, 0x00],
        [0x41, 0xe8], [0x4a, 0x6e], [0x20, 0xd9], [0x00, 0x5a],
        [0x7f, 0xff], [0x51, 0xca], [0x00, 0x5c], [0x2e, 0x00],
        [0x02, 0x40], [0x48, 0xc7], [0x67, 0x14], [0x0c, 0x80],
        [0x2e, 0x9f], [0xff, 0xd6], [0x80, 0x00], [0x10, 0x00],
        [0x48, 0x42], [0x4a, 0x6b], [0xff, 0xd2], [0x00, 0x48],
        [0x4a, 0x47], [0x4e, 0xd1], [0x20, 0x6f], [0x00, 0x41],
        [0x60, 0x0c], [0x2a, 0x78], [0x42, 0x2e], [0x32, 0x00],
        [0x65, 0x74], [0x67, 0x16], [0x00, 0x44], [0x48, 0x6d],
        [0x20, 0x08], [0x48, 0x6c], [0x0b, 0x7c], [0x26, 0x40],
        [0x04, 0x00], [0x00, 0x68], [0x20, 0x6d], [0x00, 0x0d],
        [0x2a, 0x40], [0x00, 0x0b], [0x00, 0x3e], [0x02, 0x20],
      ]
    doc: |
      The default lookup table,
      which is used if no custom lookup table is included with the compressed data.
  lookup_table:
    value: |
      header_parameters.flags.has_custom_lookup_table
      ? custom_lookup_table
      : default_lookup_table
    doc: |
      The lookup table to be used for this compressed data.
types:
  header_parameters:
    doc: |
      Decompressor-specific parameters for this compression format,
      as stored in the compressed resource header.
    seq:
      - id: unknown
        type: u2
        doc: |
          The meaning of this field is unknown.
          It does not appear to have any effect on the format of the compressed data or the decompression process.

          The value of this field is usually zero and otherwise a small integer (< 10).
          For `'lpch'` resources,
          the value is always nonzero,
          and sometimes larger than usual.
      - id: num_custom_lookup_table_entries_m1
        type: u1
        doc: |
          The number of entries in the custom lookup table,
          minus one.

          If the default lookup table is used rather than a custom one,
          this value is zero.
      - id: flags
        type: flags
        doc: |
          Various flags that affect the format of the compressed data and the decompression process.
    instances:
      num_custom_lookup_table_entries:
        value: num_custom_lookup_table_entries_m1 + 1
        if: flags.has_custom_lookup_table
        doc: |
          The number of entries in the custom lookup table.
          Only used if a custom lookup table is present.
    types:
      flags:
        doc: |
          Flags for the decompressor,
          as stored in the decompressor-specific parameters.
        seq:
          - id: reserved
            type: b6
            doc: |
              These flags have no known usage or meaning and should always be zero.
          - id: tagged
            type: b1
            doc: |
              Whether the "tagged" variant of this compression format should be used,
              rather than the default "untagged" variant.
          - id: has_custom_lookup_table
            type: b1
            doc: |
              Whether a custom lookup table is included before the compressed data,
              which should be used instead of the default hardcoded lookup table.
        instances:
          as_int:
            pos: 0
            type: u1
            doc: |
              The flags as a packed integer,
              as they are stored in the data.
  untagged_data:
    doc: |
      Compressed data in the "untagged" variant of the format.
    seq:
      - id: table_references
        type: u1
        repeat: eos
        doc: |
          References into the lookup table.
          Each reference is an integer that is expanded to two bytes by looking it up in the table.
  tagged_data:
    doc: |
      Compressed data in the "tagged" variant of the format.
    seq:
      - id: chunks
        type: chunk
        repeat: eos
        doc: |
          The tagged chunks that make up the compressed data.
    types:
      chunk:
        doc: |
          A single tagged chunk of compressed data.

          Each chunk expands to 16 bytes of decompressed data.
          In compressed form,
          the chunks have a variable length
          (between 9 and 17 bytes)
          depending on the value of the tag byte.
        seq:
          - id: tag
            type: b1
            repeat: expr
            repeat-expr: 8
            doc: |
              The bits of the tag byte control the format and meaning of the 8 compressed data units that follow the tag byte.
          - id: units
            type:
              switch-on: tag[_index]
              cases:
                true: u1
                # If false, the type is unset, i. e. a byte array.
            # This size attribute is necessary when the tag bit is false,
            # to set the size of the byte array to 2.
            # When the tag bit is true,
            # the size is implicitly set by the u1 type,
            # so this attribute is redundant.
            # However there is no way to set the size attribute only conditionally,
            # so we need to include a value in all cases,
            # even when the tag bit is true and an explicit size is not normally necessary.
            size: |
              tag[_index] ? 1 : 2
            repeat: until
            repeat-until: _index >= 7 or _io.eof
            doc: |
              The compressed data units in this chunk.

              The format and meaning of each unit is controlled by the bit in the tag byte with the same index.
              If the bit is 0 (false),
              the unit is a pair of bytes,
              which are literally copied to the decompressed data.
              If the bit is 1 (true),
              the unit is a reference into the lookup table,
              an integer which is expanded to two bytes by looking it up in the table.
