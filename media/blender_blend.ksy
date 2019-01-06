meta:
  id: blender_blend
  application: Blender
  endian: le
  file-extension: blend
  license: CC0-1.0
seq:
  - id: hdr
    type: header
  - id: blocks
    type: file_block
    repeat: eos
instances:
  sdna_structs:
    value: 'blocks[blocks.size - 2].body.as<dna1_body>.structs'
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
      - id: len_body
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
        size: len_body
        type:
          switch-on: code
          cases:
            '"DNA1"': dna1_body
    instances:
      sdna_struct:
        value: _root.sdna_structs[sdna_index]
        if: sdna_index != 0
  dna1_body:
    doc-ref: 'https://en.blender.org/index.php/Dev:Source/Architecture/File_Format#Structure_DNA'
    seq:
      - id: id
        contents: SDNA

      - id: name_magic
        contents: NAME
      - id: num_names
        type: u4
      - id: names
        type: strz
        encoding: UTF-8
        repeat: expr
        repeat-expr: num_names

      - id: padding_1
        size: (4 - _io.pos) % 4

      - id: type_magic
        contents: TYPE
        #align: 4 - https://github.com/kaitai-io/kaitai_struct/issues/12
      - id: num_types
        type: u4
      - id: types
        type: strz
        encoding: UTF-8
        repeat: expr
        repeat-expr: num_types

      - id: padding_2
        size: (4 - _io.pos) % 4

      - id: tlen_magic
        contents: TLEN
        #align: 4 - https://github.com/kaitai-io/kaitai_struct/issues/12
      - id: lengths
        type: u2
        repeat: expr
        repeat-expr: num_types

      - id: padding_3
        size: (4 - _io.pos) % 4

      - id: strc_magic
        contents: STRC
      - id: num_structs
        type: u4
      - id: structs
        type: dna_struct
        repeat: expr
        repeat-expr: num_structs
  dna_struct:
    seq:
      - id: idx_type
        type: u2
      - id: num_fields
        type: u2
      - id: fields
        type: dna_field
        repeat: expr
        repeat-expr: num_fields
    instances:
      type:
        value: _parent.types[idx_type]
  dna_field:
    seq:
      - id: idx_type
        type: u2
      - id: idx_name
        type: u2
    instances:
      type:
        value: _parent._parent.types[idx_type]
      name:
        value: _parent._parent.names[idx_name]
enums:
  ptr_size:
    0x5f: bits_32
    0x2d: bits_64
  endian:
    0x56: be
    0x76: le
