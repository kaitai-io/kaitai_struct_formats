meta:
  id: fbx
  title: FBX 3D model interchange format
  file-extension: fbx
  encoding: UTF-8
  endian: le
  license: MIT

seq:
  - id: header
    type: header
  - id: records
    type: node_record
    repeat: until
    repeat-until: _.end_offset == 0

types:

  header:
    seq:
      - id: magic
        contents: "Kaydara FBX Binary  \0"
        size: 20
      - id: more_magic
        contents: [0x1A, 0x00]
      - id: version
        type: u4

  node_record:
    seq:
      - id: end_offset
        type: u4
      - id: property_count
        type: u4
      - id: property_list_length
        type: u4
      - id: name_length
        type: u1
      - id: name
        type: str
        size: name_length
      - id: properties
        type: property
        repeat: expr
        repeat-expr: property_count
        size: property_list_length
      - id: children
        size: end_offset - _root._io.pos
        type: node_record
        repeat: until
        repeat-until: _.end_offset == 0
        if: not _io.eof

  property:
    seq:
      - id: type_code
        size: 1
        type: str
      - id: data
        type:
          switch-on: type_code
          cases:
            '"I"': s4
            '"L"': s8
            '"F"': f4
            '"D"': f8
            '"Y"': s2
            '"C"': u1 # TODO boolean, should probably have a type for it
            '"i"': array(1)
            '"l"': array(2)
            '"f"': array(3)
            '"d"': array(4)
            '"b"': array(5)
            '"S"': string_data
            '"R"': raw_binary_data

  string_data:
    seq:
      - id: length
        type: u4
      - id: value
        type: str
        size: length
  
  raw_binary_data:
    seq:
      - id: length
        type: u4
      - id: value
        size: length

  array:
    params:
      # Works around lack of ability to parameterise the actual type by passing a fake one through.
      # https://github.com/kaitai-io/kaitai_struct/issues/135
      - id: pseudo_type
        type: u1
    seq:
      - id: element_count
        type: u4
      - id: encoding
        type: u1
      - id: compressed_size
        type: u4
      - id: elements
        # Can't switch for process, so switch for type as a workaround.
        # https://github.com/kaitai-io/kaitai_struct/issues/374
        type:
          switch-on: encoding
          cases:
            0: array_data(pseudo_type, element_count)
            1: array_data_compressed(pseudo_type, element_count)
        size: compressed_size

  array_data_compressed:
    params:
      - id: pseudo_type
        type: u1
      - id: element_count
        type: u4
    seq:
      - id: data
        type: array_data(pseudo_type, element_count)
        process: zlib
        size-eos: true
    instances:
      elements:
        value: data.elements

  array_data:
    params:
      - id: pseudo_type
        type: u1
      - id: element_count
        type: u4
    seq:
      - id: elements
        type:
          switch-on: pseudo_type
          cases:
            1: s4
            2: s8
            3: f4
            4: f8
            5: u1
        repeat: expr
        repeat-expr: element_count

