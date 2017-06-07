# ID3v2.3.0 Specifications
# http://id3.org/id3v2.3.0

meta:
  id: id3v2_3
  license: CC0-1.0
  endian: be
  file-extension:
    - mp3

seq:
  - id: tag
    type: tag

types:
  # Section 3. ID3v2 overview
  tag:
    seq:
      - id: header
        type: header
      - id: header_ex
        type: header_ex
        if: header.flags.flag_headerex
      - id: frames  
        type: frame
        repeat: until
        repeat-until: _io.pos + _.size > header.size.value or _.is_invalid
      - id: padding
        if: header.flags.flag_headerex
        size: header_ex.padding_size - _io.pos

  # Section 3.1. ID3v2 header
  header:
    doc: ID3v2 fixed header
    doc-ref: Section 3.1. ID3v2 header
    seq:
      - id: magic
        contents: 'ID3'
      - id: version_major
        type: u1
      - id: version_revision
        type: u1
      - id: flags
        type: flags
      - id: size
        type: u4be_synchsafe
    types:
      flags:
        seq:
          - id: flag_unsynchronization
            type: b1
          - id: flag_headerex
            type: b1
          - id: flag_experimental
            type: b1
          - id: reserved
            type: b5

  header_ex:
    doc: ID3v2 extended header
    doc-ref: Section 3.2. ID3v2 extended header
    seq:
      - id: size
        type: u4
      - id: flags_ex
        type: flags_ex
      - id: padding_size
        type: u4
      - id: crc
        type: u4
        if: flags_ex.flag_crc
    types:
      flags_ex:
        seq:
          - id: flag_crc
            type: b1
          - id: reserved
            type: b15

  # Section 3.3. ID3v2 frame overview
  frame:
    seq:
      - id: id
        type: str
        size: 4
        encoding: ASCII
      - id: size
        type: u4
      - id: flags
        type: flags
      - id: data
        size: size
    types:
      flags:
        seq:
          - id: flag_discard_alter_tag
            type: b1
          - id: flag_discard_alter_file
            type: b1
          - id: flag_read_only
            type: b1
          - id: reserved1
            type: b5
          - id: flag_compressed
            type: b1
          - id: flag_encrypted
            type: b1
          - id: flag_grouping
            type: b1
          - id: reserved2
            type: b5
    instances:
      is_invalid:
        value: "id == '\x00\x00\x00\x00'"

  # Section 6.2. Synchsafe integers
  u1be_synchsafe:
    seq:
      - id: padding
        type: b1
      - id: value
        type: b7
  u2be_synchsafe:
    seq:
      - id: byte0
        type: u1be_synchsafe
      - id: byte1
        type: u1be_synchsafe
    instances:
      value:
        value: (byte0.value << 7) | byte1.value
  u4be_synchsafe:
    seq:
      - id: short0
        type: u2be_synchsafe
      - id: short1
        type: u2be_synchsafe
    instances:
      value:
        value: (short0.value << 14) | short1.value
