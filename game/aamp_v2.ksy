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
  endian: le
seq:
  - id: header
    type: header
  - id: parameter_lists
    type: parameter_list
    repeat: expr
    repeat-expr: header.num_lists
  - id: parameter_objects
    type: parameter_object
    repeat: expr
    repeat-expr: header.num_objects
  - id: parameters
    type: parameter
    repeat: expr
    repeat-expr: header.num_parameters
  - id: data_section
    size: header.data_section_size
  - id: string_section
    size: header.string_section_size
  - id: unknown_uint32_section
    type: u1
    repeat: eos
    doc: May be unused.
types:
  header:
    seq:
    - id: magic
      contents: AAMP
    - id: version
      type: u1
      doc: Should be "2"
    - id: flags
      type: u1
      repeat: expr
      repeat-expr: 7
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
      type: str
      size: 4
      encoding: utf-8
      doc: typically "xml"
  parameter_list:
    seq:
      - id: name_crc32
        type: u4
      - id: child_lists
        type: u4
        doc: Number of child lists
      - id: child_objects
        type: u4
    instances:
      child_lists_offset:
        value: child_lists
      num_child_lists:
        value: child_lists >> 16
  parameter_object:
    seq:
      - id: name_crc32
        type: u4
      - id: data
        type: u4
    instances:
      child_offset:
        value: data
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
        value: data
        doc:  Offset to data, divided by 4 and relative to parameter start.
      param_type:
        value: data >> 24
        enum: parameter_type
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
