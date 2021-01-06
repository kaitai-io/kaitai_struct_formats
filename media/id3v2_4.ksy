meta:
  id: id3v2_4
  title: ID3v2.4 tag for .mp3 files
  file-extension: mp3
  xref:
    forensicswiki: ID3
    justsolve: ID3
    loc: fdd000108 # ID3v2
    wikidata: Q1054220
  license: CC0-1.0
  endian: be

doc-ref:
  - http://id3.org/id3v2.4.0-structure
  - http://id3.org/id3v2.4.0-frames

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
        repeat-until: _io.pos + _.size.value > header.size.value or _.is_invalid
      - id: padding
        type: padding
        if: not header.flags.flag_footer
      - id: footer
        type: footer
        if: header.flags.flag_footer

  # Section 3.1. ID3v2 header
  header:
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
          - id: flag_footer
            type: b1
          - id: reserved
            type: b4

  # Section 3.2. ID3v2 extended header
  header_ex:
    seq:
      - id: size
        type: u4be_synchsafe
      - id: flags_ex
        type: flags_ex
      - id: data
        size: size.value - 5
    types:
      flags_ex:
        seq:
          - id: reserved1
            type: b1
          - id: flag_update
            type: b1
          - id: flag_crc
            type: b1
          - id: flag_restrictions
            type: b1
          - id: reserved2
            type: b4

  # Section 3.3. Padding
  padding:
    seq:
      - id: padding
        size: _root.tag.header.size.value - _io.pos

  # Section 3.4. ID3v2 footer
  footer:
    seq:
      - id: magic
        contents: '3DI'
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
          - id: flag_footer
            type: b1
          - id: reserved
            type: b4

  # Section 4. ID3v2 frames overview
  frame:
    seq:
      - id: id
        type: str
        size: 4
        encoding: ASCII
      - id: size
        type: u4be_synchsafe
      - id: flags_status
        type: flags_status
      - id: flags_format
        type: flags_format
      - id: data
        size: size.value
    types:
      flags_status:
        seq:
          - id: reserved1
            type: b1
          - id: flag_discard_alter_tag
            type: b1
          - id: flag_discard_alter_file
            type: b1
          - id: flag_read_only
            type: b1
          - id: reserved2
            type: b4
      flags_format:
        seq:
          - id: reserved1
            type: b1
          - id: flag_grouping
            type: b1
          - id: reserved2
            type: b2
          - id: flag_compressed
            type: b1
          - id: flag_encrypted
            type: b1
          - id: flag_unsynchronisated
            type: b1
          - id: flag_indicator
            type: b1
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
