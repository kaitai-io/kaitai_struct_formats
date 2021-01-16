meta:
  id: aamp_v2
  title: AAMP Binary Resource Parameter Archive
  application:
    - Switch Toolbox
    - aamptool
    - aamp
    - Wild Bits
  file-extension:
    - aamp
    - bxml
    - bas
    - baglblm
    - baglccr
    - baglclwd
    - baglcube
    - bagldof
    - baglenv
    - baglenvset
    - baglfila
    - bagllmap
    - bagllref
    - baglmf
    - baglshpp
    - baiprog
    - baslist
    - bassetting
    - batcl
    - batcllist
    - bawareness
    - bawntable
    - bbonectrl
    - bchemical
    - bchmres
    - bdemo
    - bdgnenv
    - bdmgparam
    - bdrop
    - bgapkginfo
    - bgapkglist
    - bgenv
    - bglght
    - bgmsconf
    - bgparamlist
    - bgsdw
    - bksky
    - blifecondition
    - blod
    - bmodellist
    - bmscdef
    - bmscinfo
    - bnetfp
    - bphyscharcon
    - bphyscontact
    - bphysics
    - bphyslayer
    - bphysmaterial
    - bphyssb
    - bphyssubmat
    - bptclconf
    - brecipe
    - brgbw
    - brgcon
    - brgconfig
    - brgconfiglist
    - bsfbt
    - bsft
    - bshop
    - bumii
    - bvege
    - bactcapt
  xref:
    zeldamods: AAMP
  endian: le
seq:
  - id: header
    type: header
    doc-ref: https://zeldamods.org/wiki/AAMP#Header
  - id: parameter_lists
    type: parameter_list
    repeat: expr
    repeat-expr: header.num_lists
    doc-ref: https://zeldamods.org/wiki/AAMP#Parameter_list
  - id: parameter_objects
    type: parameter_object
    repeat: expr
    repeat-expr: header.num_objects
    doc-ref: https://zeldamods.org/wiki/AAMP#Parameter_object
  - id: parameters
    type: parameter
    repeat: expr
    repeat-expr: header.num_parameters
    doc-ref: https://zeldamods.org/wiki/AAMP#Parameter
  - id: data_section
    size: header.data_section_size
    doc-ref: https://zeldamods.org/wiki/AAMP#Section_order
  - id: string_section
    size: header.string_section_size
    doc-ref: https://zeldamods.org/wiki/AAMP#Section_order
  - id: unknown_uint32_section
    type: u1
    repeat: eos
    doc: May be unused.
    doc-ref: https://zeldamods.org/wiki/AAMP#Section_order
types:
  header:
    seq:
    - id: magic
      contents: AAMP
    - id: version
      type: u4
      doc: Should be "2"
    - id: flags
      type: u4
      doc: TODO: Flags (LittleEndian: 1 << 0, UTF8: 1 << 1)
    - id: file_size
      type: u4
    - id: pio_verision
      type: u4
    - id: pio_offset
      type: u4
    - id: num_lists
      type: u4
    - id: num_objects
      type: u4
    - id: num_parameters
      type: u4
    - id: data_section_size
      type: u4
    - id: string_section_size
      type: u4
    - id: unknown
      size: 4
    - id: pio_type
      type: strz
      size: 4
      encoding: utf-8
      doc: typically "xml"
  parameter_list:
    seq:
      - id: name_crc32
        type: u4
      - id: child_lists
        type: u4
      - id: child_objects
        type: u4
    instances:
      child_lists_offset:
        value: child_lists & 16
        doc: Offset to child lists, divided by 4 and relative to parameter list start
      num_child_lists:
        value: child_lists >> 16
        doc: Number of child lists
      child_objects_offset:
        value: child_objects & 16
        doc: Offset to child objects, divided by 4 and relative to parameter list start
      num_child_objects:
        value: child_objects >> 16
        doc: Number of child objects
  parameter_object:
    seq:
      - id: name_crc32
        type: u4
      - id: data
        type: u4
    instances:
      child_offset:
        value: data & 16
      num_child_params:
        value: data >> 16
  parameter:
    seq:
      - id: name_crc32
        type: u4
      - id: data
        type: u4
    instances:
      data_offset:
        value: data & 24
        doc:  Offset to data, divided by 4 and relative to parameter start.
      parameter_type:
        value: data >> 24
        enum: parameter_type
        doc-ref: https://zeldamods.org/wiki/AAMP#ParameterType
enums:
  parameter_type:
    0:  bool
    1:  f32
    2:  int
    3:  vec2
    4:  vec3
    5:  vec4
    6:  color
    7:  string32
    8:  string64
    9:  curve1
    10: curve2
    11: curve3
    12: curve4
    13: buffer_int
    14: buffer_f32
    15: string256
    16: quat
    17: u32
    18: buffer_u32
    19: buffer_binary
    20: string_ref
    21: none_special
