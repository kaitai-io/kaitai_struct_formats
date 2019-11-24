meta:
  id: parent_chunk_data
  encoding: ASCII
  endian: le
params:
  - id: expected_form_type
    type: str
seq:
  - id: form_type_assert
    type: str
    size: 4
    valid: expected_form_type
  - id: subchunks_slot
    type: slot
    size-eos: true
types:
  slot: {} # Keeps _io for later use of same substream
