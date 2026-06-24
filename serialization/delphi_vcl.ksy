meta:
  id: delphi_vcl
  title: Delphi VCL TComponent serialization
  file-extension: dfm
  tags:
    - serialization
  license: CC0-1.0
  endian: le
doc: |
  Format used by Delphi (Visual Component Library) to serialize/deserialize
  TComponent's. One of its notable uses is for storage of GUI forms as
  resources.
doc-ref:
  - https://web.archive.org/web/20151028201608/http://geos.icc.ru:8080/scripts/WWWBinV.dll/ShowR?DFM.rfh
  - https://gitlab.com/freepascal.org/fpc/source/-/blob/main/rtl/objpas/classes/classes.inc
seq:
  - id: header
    type: header
  - id: root_object
    type: object_rec
types:
  header:
    seq:
      - id: magic1
        contents: [0xFF]
      - id: magic2
        contents: [0x0a, 0x00]
      - id: resource_name
        type: strz
        encoding: ASCII
      - id: magic3
        contents: [0x30, 0x10]
      - id: image_size
        type: u4
        valid:
          expr: "_ < _io.size"
      - id: filer_signature
        contents: TPF0
  string:
    seq:
      - id: len_value
        type: u1
      - id: value
        size: len_value
  value:
    seq:
      - id: value_type
        type: u1
        enum: value_type
      - id: value
        type:
          switch-on: value_type
          cases:
            #value_type::null
            value_type::list: list_value
            value_type::int8: u1
            value_type::int16: u2
            value_type::int32: u4
            value_type::extended: extended_value
            value_type::string: string
            value_type::ident: string
            value_type::false: false_value
            value_type::true: true_value
            value_type::binary: binary_value
            value_type::set: set_value
            value_type::lstring: lstring_value
            #value_type::nil
            value_type::collection: collection_value
            value_type::single: single_value
            value_type::currency: currency_value
            value_type::date: date_value
            value_type::wstring: wstring_value
            value_type::int64: u8
            value_type::utf8string: utf8string_value
  list_value:
    seq:
      - id: item
        type: value
        repeat: until
        repeat-until: _.value_type != value_type::null
  extended_value:
    seq:
      - id: value
        size: 10
  lstring_value:
    seq:
      - id: len_value
        type: u4
      - id: value
        size: len_value
  false_value:
    doc: This type is intentionally left blank.
  true_value:
    doc: This type is intentionally left blank.
  binary_value:
    seq:
      - id: len_value
        type: u4
      - id: value
        size: len_value
  set_value:
    seq:
      - id: item
        type: string
        repeat: until
        repeat-until: _.len_value == 0x00
  wstring_value:
    seq:
      - id: len_value
        type: u4
      - id: value
        size: 2 * len_value
  utf8string_value:
    seq:
      - id: len_value
        type: u1
      - id: value
        size: len_value
  collection_rec:
    seq:
      - id: value_type1
        type: u1
        enum: value_type
        valid:
          expr: |
            (_ == value_type::null) or (_ == value_type::list)
            or (_ == value_type::int8) or (_ == value_type::int16)
            or (_ == value_type::int32)
      - id: int_val
        type:
          switch-on: value_type1
          cases:
            value_type::int8: u1
            value_type::int16: u2
            value_type::int32: u4
        if: (value_type1 != value_type::null) and (value_type1 != value_type::list)
      - id: value_type2
        type: u1
        enum: value_type
        valid:
          expr: _ == value_type::list
        if: (value_type1 != value_type::null) and (value_type1 != value_type::list)
      - id: prop_list
        type: prop_list
        if: (value_type1 != value_type::null)
  collection_value:
    seq:
      - id: item
        type: collection_rec
        repeat: until
        repeat-until: _.value_type1 == value_type::null
  single_value:
    seq:
      - id: value
        size: 4
  currency_value:
    seq:
      - id: value
        size: 8
  date_value:
    seq:
      - id: value
        size: 8
  prop_rec:
    seq:
      - id: name
        type: string
      - id: value
        type: value
        if: name.len_value != 0
  prop_list:
    seq:
      - id: item
        type: prop_rec
        repeat: until
        repeat-until: _.name.len_value == 0x00
  obj_list:
    seq:
      - id: item
        type: object_rec
        repeat: until
        repeat-until: _.class_name.len_value == 0x00
  object_rec:
    doc: |
      XXX Filer flags are not implemented
    seq:
      - id: class_name
        type: string
      - id: object_name
        type: string
        if: class_name.len_value != 0x00
      - id: prop_list
        type: prop_list
        if: class_name.len_value != 0x00
      - id: obj_list
        type: obj_list
        if: class_name.len_value != 0x00
enums:
  value_type:
    0: "null"
    1: "list"
    2: "int8"
    3: "int16"
    4: "int32"
    5: "extended"
    6: "string"
    7: "ident"
    8: "false"
    9: "true"
    10: "binary"
    11: "set"
    12: "lstring"
    13: "nil"
    14: "collection"
    15: "single"
    16: "currency"
    17: "date"
    18: "wstring"
    19: "int64"
    20: "utf8string"
