meta:
  id: parent_chunk_data
  endian: le
seq:
  - id: form_type
    type: u4
  - id: subchunks_slot
    type: slot
    size-eos: true
types:
  slot: {} # Keeps _io for later use of same substream
