meta:
  id: parent_chunk_data_generic
  encoding: ASCII
  endian: le
seq:
  - id: form_type
    type: str
    size: 4
  - id: subchunks_slot
    type: slot
    size-eos: true
types:
  slot: {} # Keeps _io for later use of same substream
