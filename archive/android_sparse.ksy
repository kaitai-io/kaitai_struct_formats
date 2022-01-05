meta:
  id: android_sparse
  title: Android sparse image
  file-extension: img
  tags:
    - archive
    - android
  license: CC0-1.0
  ks-version: 0.9
  endian: le
doc: |
    The Android sparse format is a format to more efficiently store files
    for for example firmware updates to save on bandwidth. Files in sparse
    format first have to be converted back to their original format.

    A tool to create images for testing can be found in the Android source code tree:

    <https://android.googlesource.com/platform/system/core/+/e8d02c50d7/libsparse> - `img2simg.c`

    Note: this is not the same as the Android sparse data image format.
doc-ref:
  - https://android.googlesource.com/platform/system/core/+/e8d02c50d7/libsparse/sparse_format.h
  - https://source.android.com/devices/bootloader/images#sparse-image-format
seq:
  - id: header_prefix
    type: file_header_prefix
    doc: internal; access `_root.header` instead
  - id: header
    size: header_prefix.len_header - header_prefix._sizeof
    type: file_header
  - id: chunks
    type: chunk
    repeat: expr
    repeat-expr: header.num_chunks
types:
  file_header_prefix:
    seq:
      - id: magic
        contents: [0x3a, 0xff, 0x26, 0xed]
      - id: version
        type: version
        doc: internal; access `_root.header.version` instead
      - id: len_header
        -orig-id: file_hdr_sz
        type: u2
        doc: internal; access `_root.header.len_header` instead
  file_header:
    seq:
      - id: len_chunk_header
        -orig-id: chunk_hdr_sz
        type: u2
        doc: size of chunk header, should be 12
      - id: block_size
        -orig-id: blk_sz
        type: u4
        valid:
          expr: _ % 4 == 0
        doc: block size in bytes, must be a multiple of 4
      - id: num_blocks
        -orig-id: total_blks
        type: u4
        doc: blocks in the original data
      - id: num_chunks
        -orig-id: total_chunks
        type: u4
      - id: checksum
        -orig-id: image_checksum
        type: u4
        doc: |
          CRC32 checksum of the original data

          In practice always 0; if checksum writing is requested, a CRC32 chunk is written
          at the end of the file instead. The canonical `libsparse` implementation does this
          and other implementations tend to follow it, see
          <https://gitlab.com/ra_kete/android-sparse-rs/-/blob/57c2577/src/write.rs#L112-114>
    instances:
      version:
        value: _root.header_prefix.version
      len_header:
        value: _root.header_prefix.len_header
        doc: size of file header, should be 28
  chunk:
    -webide-representation: '{header}'
    seq:
      - id: header
        size: _root.header.len_chunk_header
        type: chunk_header
      - id: body
        size: header.len_body
        type:
          switch-on: header.chunk_type
          cases:
            chunk_types::crc32: u4
            # byte array for all other chunk types
    types:
      chunk_header:
        -webide-representation: '{chunk_type}: {num_body_blocks:dec} blocks'
        seq:
          - id: chunk_type
            type: u2
            enum: chunk_types
          - id: reserved1
            type: u2
          - id: num_body_blocks
            -orig-id: chunk_sz
            type: u4
            doc: size of the chunk body in blocks in output image
          - id: len_chunk
            -orig-id: total_sz
            type: u4
            valid:
              eq: 'len_body_expected != -1 ? _root.header.len_chunk_header + len_body_expected : len_chunk'
            doc: in bytes of chunk input file including chunk header and data
        instances:
          len_body:
            value: len_chunk - _root.header.len_chunk_header
          len_body_expected:
            value: |
              chunk_type == chunk_types::raw ? _root.header.block_size * num_body_blocks :
              chunk_type == chunk_types::fill ? 4 :
              chunk_type == chunk_types::dont_care ? 0 :
              chunk_type == chunk_types::crc32 ? 4 :
              -1
            doc-ref:
              - https://android.googlesource.com/platform/system/core/+/e8d02c50d7/libsparse/sparse_read.cpp#184  # ::raw
              - https://android.googlesource.com/platform/system/core/+/e8d02c50d7/libsparse/sparse_read.cpp#215  # ::fill
              - https://android.googlesource.com/platform/system/core/+/e8d02c50d7/libsparse/sparse_read.cpp#249  # ::dont_care
              - https://android.googlesource.com/platform/system/core/+/e8d02c50d7/libsparse/sparse_read.cpp#270  # ::crc32
  version:
    seq:
      - id: major
        -orig-id: major_version
        type: u2
        valid: 1
      - id: minor
        -orig-id: minor_version
        type: u2
enums:
  chunk_types:
    0xcac1: raw
    0xcac2: fill
    0xcac3: dont_care
    0xcac4: crc32
