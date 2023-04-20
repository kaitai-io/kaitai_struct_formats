meta:
  id: stone
  title: SerpentOS Stone
  license: Zlib
  endian: be
doc-ref: <https://github.com/serpent-os/libmoss/blob/841a6d67/source/moss/format/binary/archive_header.d>
seq:
  - id: header
    type: header
    size: 32
  - id: payloads
    type: payload
    repeat: expr
    repeat-expr: header.num_payloads
types:
  header:
    seq:
      - id: signature
        contents: [0, 0x6d, 0x6f, 0x73]
      - id: num_payloads
        type: u2
      - id: integrity_check
        contents: [0, 0, 1, 0, 0, 2, 0, 0, 3, 0, 0, 4, 0, 0, 5, 0, 0, 6, 0, 0, 7]
      - id: file_type
        type: u1
        enum: file_types
      - id: version
        type: u4
  payload:
    -webide-representation: "{type}"
    seq:
      - id: len_data
        type: u8
      - id: len_usable_data
        type: u8
        # use len_uncompressed instead?
      - id: xxhash3_64
        size: 8
      - id: num_records
        type: u4
      - id: payload_version
        type: u2
      - id: type
        type: u1
        enum: payload_type
      - id: compression
        type: u1
        enum: compression
      - id: data
        size: len_data
enums:
  file_types:
    0: unknown
    1: binary
    2: delta
    3: repository
    4: build_manifest
  compression:
    0: unknown
    1: no_compression
    2: zstd
  payload_type:
    0: unknown
    1: meta
    2: content
    3: layout
    4: index
    5: attributes
    6: dumb
