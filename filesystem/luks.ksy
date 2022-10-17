meta:
  id: luks
  title: Linux Unified Key Setup
  xref:
    forensicswiki: Linux_Unified_Key_Setup_(LUKS)
    wikidata: Q29000504
  tags:
    - filesystem
    - linux
  license: CC0-1.0
  encoding: ASCII
  endian: be
doc: |
  Linux Unified Key Setup (LUKS2) is a format specification for storing disk
  encryption parameters and up to 8 user keys (which can unlock the master key).
doc-ref: https://gitlab.com/cryptsetup/cryptsetup/wikis/LUKS-standard/on-disk-format.pdf
         https://gitlab.com/cryptsetup/cryptsetup/-/blob/main/docs/on-disk-format-luks2.pdf

seq:
  - id: primary_binary_header
    type: binary_header
  - id: primary_json_area
    type: json_area
    if: primary_binary_header.version2 == 0x02
  - id: secondary_binary_header
    type: binary_header
    if: primary_binary_header.version2 == 0x02
  - id: secondary_json_area
    type: json_area
    if: primary_binary_header.version2 == 0x02 
types:
  binary_header:
    seq:
      - id: magic1
        type: str
        size: 4
        valid:
          any-of:
            - '"LUKS"'
            - '"SKUL"'
      - id: magic2
        contents: [0xBA, 0xBE]
      - id: version1
        contents: [0x00]
      - id: version2
        type: u1
        valid:
          min: 0x01
          max: 0x02
      # LUKS1
      - id: cipher_name_specification
        type: str
        size: 32
        if: version2 == 0x01
      - id: cipher_mode_specification
        type: str
        size: 32
        if: version2 == 0x01
      - id: hash_specification
        type: str
        size: 32
        if: version2 == 0x01
      - id: payload_offset
        type: u4
        if: version2 == 0x01
      - id: number_of_key_bytes
        type: u4
        if: version2 == 0x01
      - id: master_key_checksum
        size: 20
        if: version2 == 0x01
      - id: master_key_salt_parameter
        size: 32
        if: version2 == 0x01
      - id: master_key_iterations_parameter
        type: u4
        if: version2 == 0x01
      # LUKS2
      - id: hdr_size
        type: u8
        if: version2 == 0x02
      - id: seqid
        type: u8
        if: version2 == 0x02
      - id: label
        type: str
        size: 48
        if: version2 == 0x02
      - id: csum_alg
        type: str
        size: 32
        if: version2 == 0x02
      - id: salt
        type: u8
        repeat: expr
        repeat-expr: 8
        if: version2 == 0x02
      - id: uuid
        type: str
        size: 40
      # LUKS1
      - id: key_slots
        type: key_slot
        repeat: expr
        repeat-expr: 8
        if: version2 == 0x01
      # LUKS2
      - id: subsystem
        type: str
        size: 48
        if: version2 == 0x02
      - id: hdr_offset
        type: u8
        if: version2 == 0x02
      - id: padding184
        type: str
        size: 184
        if: version2 == 0x02
      - id: csum
        type: u8
        repeat: expr
        repeat-expr: 8
        if: version2 == 0x02
      - id: padding4096
        type: str
        size: 7 * 512
        if: version2 == 0x02
    types:
      key_slot:
        seq:
          - id: state_of_key_slot
            type: u4
            enum: key_slot_states
          - id: iteration_parameter
            type: u4
          - id: salt_parameter
            size: 32
          - id: start_sector_of_key_material
            type: u4
          - id: number_of_anti_forensic_stripes
            type: u4
        instances:
          key_material:
            pos: start_sector_of_key_material * 512
            size: _parent.number_of_key_bytes * number_of_anti_forensic_stripes
        enums:
          key_slot_states:
            0x0000DEAD: disabled_key_slot
            0x00AC71F3: enabled_key_slot
  json_area:
    seq:
      - id: json
        type: str
        size: _root.primary_binary_header.hdr_size - 4096
instances:
  payload:
    pos: primary_binary_header.payload_offset * 512
    size-eos: true
