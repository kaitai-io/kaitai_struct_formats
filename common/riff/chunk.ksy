meta:
  id: chunk
  encoding: ASCII
  endian: le
seq:
  - id: id
    type: str
    size: 4
  - id: len
    type: u4
  - id: data_slot
    type: slot
    size: len
  - id: pad_byte
    size: len % 2 # if size is odd, there is 1 padding byte
types:
  slot: {} # Keeps _io for later use of same substream
