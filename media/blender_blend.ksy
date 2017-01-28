meta:
  id: blender_blend
  endian: le
  file-extension: blend
seq:
  - id: hdr
    type: header
  - id: blocks
    type: file_block
    repeat: eos
types:
  header:
    seq:
      - id: magic
        contents: BLENDER
      - id: ptr_size_id
        type: u1
        enum: ptr_size
        doc: Size of a pointer; all pointers in the file are stored in this format
      - id: endian
        type: u1
        doc: Type of byte ordering used
        enum: endian
      - id: version
        type: str
        size: 3
        encoding: ASCII
        doc: Blender version used to save this file
    instances:
      psize:
        value: 'ptr_size_id == ptr_size::bits_64 ? 8 : 4'
        doc: Number of bytes that a pointer occupies
  file_block:
    seq:
      - id: code
        type: str
        size: 4
        encoding: ASCII
        doc: Identifier of the file block
      - id: size
        type: u4
        doc: Total length of the data after the header of file block
      - id: mem_addr
        size: _root.hdr.psize
        doc: Memory address the structure was located when written to disk
      - id: sdna_index
        type: u4
        doc: Index of the SDNA structure
      - id: count
        type: u4
        doc: Number of structure located in this file-block
      - id: body
        size: size
enums:
  ptr_size:
    0x5f: bits_32
    0x2d: bits_64
  endian:
    0x56: be
    0x76: le
