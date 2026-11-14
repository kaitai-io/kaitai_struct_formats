meta:
  id: apple_photos_journal
  title: Apple Photos property list journal
  application: Apple Photos
  file-extension: plj
  license: MIT
  ks-version: '0.11'
  endian: be
  imports:
    - /common/vlq_base128_le
doc: |
  Apple Photos stores these journals in resources/journals inside a Photos
  library. A file is a sequence of records; empty journals also occur.
  Each record has a marker, CRC-16/ARC of the protobuf header, a big-endian
  16-bit header length, the protobuf header, and an optional binary plist.

  This reverse-engineered parser covers the ordered protobuf field encoding
  observed in the linked macOS 15.4.1 fixtures. It does not accept arbitrary
  protobuf field reordering or missing fields in create/update headers.
  Trailing header fields are preserved as bytes. CRCs are exposed but not
  validated. Binary plist payloads are preserved for a separate plist parser.
doc-ref:
  - https://github.com/dgleich/apple-plj-format
  - https://github.com/RhetTbull/apple-plj-parser
seq:
  - id: records
    type: record
    repeat: eos
types:
  record:
    seq:
      - id: marker
        contents: [0x40]
      - id: header_crc
        type: u2
        doc: CRC-16/ARC of the protobuf header bytes, stored big endian
      - id: len_header
        type: u2
        valid:
          min: 1
      - id: header
        type: journal_header
        size: len_header
      - id: payload
        size: 'header.entry_type.value == 2 ? 0 : header.payload_info.len_payload.value'
        doc: Binary plist bytes, absent for observed deletion records
  journal_header:
    seq:
      - id: entry_type_key
        contents: [0x08]
      - id: entry_type
        type: vlq_base128_le
        doc: Observed values are 0 (create), 1 (update), and 2 (delete)
      - id: identifier_key
        type: u1
        valid:
          any-of: [0x12, 0x1a]
        doc: Protobuf field 2 is a UUID; field 3 is a string identifier
      - id: len_identifier
        type: vlq_base128_le
      - id: identifier
        size: len_identifier.value
      - id: payload_info
        type: payload_info
        if: entry_type.value != 2
  payload_info:
    seq:
      - id: payload_version_key
        contents: [0x20]
      - id: payload_version
        type: vlq_base128_le
      - id: len_payload_key
        contents: [0x28]
      - id: len_payload
        type: vlq_base128_le
      - id: payload_crc_key
        contents: [0x30]
      - id: payload_crc
        type: vlq_base128_le
        doc: CRC-32/ISO-HDLC of the payload
      - id: trailing_fields
        size-eos: true
        doc: Additional protobuf fields, e.g. repeated field 7 (nil properties)
