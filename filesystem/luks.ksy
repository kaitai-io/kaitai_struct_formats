meta:
  id: luks
  title: Linux Unified Key Setup
  license: CC0-1.0
  endian: be
  encoding: ASCII
doc: |
  Linux Unified Key Setup (LUKS) is a format specification for storing disk
  encryption parameters and up to 8 user keys (which can unlock the master key).
doc-ref: https://gitlab.com/cryptsetup/cryptsetup/wikis/LUKS-standard/on-disk-format.pdf
seq:
  - id: partition_header
    type: partition_header
types:
  partition_header:
    seq:
      - id: magic
        contents: [0x4C, 0x55, 0x4B, 0x53, 0xBA, 0xBE]
      - id: version
        contents: [0x00, 0x01]
      - id: cipher_name_specification
        type: str
        size: 32
      - id: cipher_mode_specification
        type: str
        size: 32
      - id: hash_specification
        type: str
        size: 32
      - id: payload_offset
        type: u4
      - id: number_of_key_bytes
        type: u4
      - id: master_key_checksum
        size: 20
      - id: master_key_salt_parameter
        size: 32
      - id: master_key_iterations_parameter
        type: u4
      - id: uuid
        type: str
        size: 40
      - id: key_slots
        type: key_slot
        repeat: expr
        repeat-expr: 8
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
instances:
  payload:
    pos: partition_header.payload_offset * 512
    size-eos: true
