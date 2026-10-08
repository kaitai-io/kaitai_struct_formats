meta:
  id: blender_blend
  application: Blender
  file-extension: blend
  xref:
    justsolve: BLEND
    mime: application/x-blender
    pronom:
      - fmt/902
      - fmt/903
    wikidata: Q15671948
  license: CC0-1.0
  endian: le
doc: |
  Blender is an open source suite for 3D modelling, sculpting,
  animation, compositing, rendering, preparation of assets for its own
  game engine and exporting to others, etc. `.blend` is its own binary
  format that saves whole state of suite: current scene, animations,
  all software settings, extensions, etc.

  This specification supports the legacy little-endian layout and the
  Blender 5.0+ layout with a 17-byte file header and 64-bit block lengths
  and counts.

  Internally, .blend format is a hybrid semi-self-descriptive
  format. On top level, it contains a simple header and a sequence of
  file blocks, which more or less follow typical [TLV
  pattern](https://en.wikipedia.org/wiki/Type-length-value). Pre-last
  block would be a structure with code `DNA1`, which is a essentially
  a machine-readable schema of all other structures used in this file.
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
    doc-ref: https://github.com/blender/blender/blob/v5.0.0/source/blender/blenloader_core/BLO_core_blend_header.hh
    seq:
      - id: magic
        contents: BLENDER
      - id: first_byte
        type: u1
        doc: Legacy pointer size marker, or the first digit of the modern header size (17)
      - id: modern_header_suffix
        contents: '7-01v'
        if: not is_legacy
        doc: Remainder of the 17-byte header size, 64-bit pointer marker, format version 01 and little-endian marker
      - id: endian_legacy
        type: u1
        doc: Type of byte ordering used
        enum: endian
        if: is_legacy
      - id: version
        type: str
        size: 'is_legacy ? 3 : 4'
        encoding: ASCII
        doc: Blender version used to save this file
    instances:
      is_legacy:
        value: first_byte != 0x31
        doc: Whether this file uses the 12-byte header and small block headers
      file_format_version:
        value: 'is_legacy ? 0 : 1'
        doc: Low-level file format version, independent of the Blender application version
      ptr_size_id:
        value: 'is_legacy ? first_byte : 0x2d'
        enum: ptr_size
        doc: Size of a pointer; modern files always use 64-bit pointers
      endian:
        value: 'is_legacy ? endian_legacy : endian::le'
        doc: Type of byte ordering used; modern files are always little-endian
      psize:
        value: 'ptr_size_id == ptr_size::bits_64 ? 8 : 4'
        doc: Number of bytes that a pointer occupies
  file_block:
    doc-ref: https://github.com/blender/blender/blob/v5.0.0/source/blender/blenloader_core/BLO_core_bhead.hh
    seq:
      - id: code
        type: str
        size: 4
        encoding: ASCII
        doc: Identifier of the file block
      - id: len_body_small
        type: u4
        if: _root.hdr.is_legacy
        doc: Total length of the data after the header of file block
      - id: sdna_index_large
        type: u4
        if: not _root.hdr.is_legacy
        doc: Index of the SDNA structure in a modern block header
      - id: mem_addr
        size: _root.hdr.psize
        doc: Memory address the structure was located when written to disk
      - id: sdna_index_small
        type: u4
        if: _root.hdr.is_legacy
        doc: Index of the SDNA structure
      - id: len_body_large
        type: s8
        if: not _root.hdr.is_legacy
        doc: Total length of the data after a modern block header
      - id: count_small
        type: u4
        if: _root.hdr.is_legacy
        doc: Number of structures in a legacy file block
      - id: count_large
        type: s8
        if: not _root.hdr.is_legacy
        doc: Number of structures in a modern file block
      - id: body
        size: len_body
        type:
          switch-on: code
          cases:
            '"DNA1"': dna1_body
    instances:
      len_body:
        # Cast the legacy branch and the result to preserve 64-bit types in
        # generated Go and Rust code; the outer cast fixes the instance type.
        value: '(_root.hdr.is_legacy ? len_body_small.as<s8> : len_body_large).as<s8>'
        doc: Total length of the data after the header of file block
      sdna_index:
        value: '(_root.hdr.is_legacy ? sdna_index_small : sdna_index_large).as<u4>'
        doc: Index of the SDNA structure
      count:
        # As with len_body, both casts keep the generated value at 64 bits.
        value: '(_root.hdr.is_legacy ? count_small.as<s8> : count_large).as<s8>'
        doc: Number of structures in this file block
      sdna_struct:
        value: _root.sdna_structs[sdna_index]
        if: sdna_index != 0
  dna1_body:
    doc: |
      DNA1, also known as "Structure DNA", is a special block in
      .blend file, which contains machine-readable specifications of
      all other structures used in this .blend file.

      Effectively, this block contains:

      * a sequence of "names" (strings which represent field names)
      * a sequence of "types" (strings which represent type name)
      * a sequence of "type lengths"
      * a sequence of "structs" (which describe contents of every
        structure, referring to types and names by index)
    doc-ref: 'https://archive.blender.org/wiki/index.php/Dev:Source/Architecture/File_Format/#Structure_DNA'
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
    doc: |
      DNA struct contains a `type` (type name), which is specified as
      an index in types table, and sequence of fields.
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
