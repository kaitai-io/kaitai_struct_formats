meta:
  id: kaydara_fbx
  title: Kaydara FBX (Filmbox) 3D model
  file-extension: fbx
  application: Autodesk/Kaydara Filmbox
  encoding: UTF-8
  endian: le
  license: MIT

doc: |
  A proprietary file format developed by Kaydara and owned by Autodesk
  since 2006. It is used to provide interoperability between digital content
  creation applications. FBX is also part of Autodesk Gameware, a series of
  video game middleware.

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
        type: strz
        valid: '"Kaydara FBX Binary  "'
        size: 21
      - id: more_magic
        valid: '[0x1A, 0x00]'
        size: 2
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
            '"i"': array(pseudo_type::s4)
            '"l"': array(pseudo_type::s8)
            '"f"': array(pseudo_type::f4)
            '"d"': array(pseudo_type::f8)
            '"b"': array(pseudo_type::u1)
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
      - id: pseudo_type
        type: u1
        enum: pseudo_type
        # Works around lack of ability to parameterise the actual type by passing a fake one through.
        -affected-by: 135
    seq:
      - id: element_count
        type: u4
      - id: encoding
        type: u1
      - id: compressed_size
        type: u4
      - id: elements
        # Can't switch for process, so switch for type as a workaround.
        -affected-by: 374
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
        enum: pseudo_type
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
        enum: pseudo_type
      - id: element_count
        type: u4
    seq:
      - id: elements
        type:
          switch-on: pseudo_type
          cases:
            'pseudo_type::sint4': s4
            'pseudo_type::sint8': s8
            'pseudo_type::float4': f4
            'pseudo_type::float8': f8
            'pseudo_type::uint1': u1
        repeat: expr
        repeat-expr: element_count

enums:
  pseudo_type:
    1: s4
    2: s8
    3: f4
    4: f8
    5: u1
