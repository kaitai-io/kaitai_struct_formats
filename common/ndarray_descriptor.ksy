meta:
  id: ndarray_descriptor
  title: A descriptor for an ndarray describing its dimensions and type
  application:
    - numpy
    - safetensors
  license: Unlicense
  endian: le
  encoding: utf-8

doc: |
  This is a part of an abstraction layer for multidimensional arrays and tensors, as used in, for example, `numpy`.
  Using this structure one can specify the shape and item type of an array.

params:
  - id: item_type
    type: u1
    enum: item_type
  - id: shape
    type: u8[]

types:
  encode_type:
    doc: used to encode endianness, type and size of a scalar into a value of `item_type`. Then this value can be used in `switch-on.cases`.
    params:
      - id: endianness
        type: u1
        enum: endianness
      - id: category
        type: u1
        enum: category
      - id: log2size_or_special
        type: u1
    instances:
      value:
        value: ((log2size_or_special==0 and category.to_i < 3)?0:endianness.to_i) << 6 | category.to_i << 3 | log2size_or_special
        enum: item_type

  decode_type:
    doc: used to decode endianness, type and size of a scalar from a value of `item_type`. The decoded values can be used to configure native implementations.
    params:
      - id: value
        type: u1
        enum: item_type
    instances:
      endianness:
        value: (value.to_i >> 6)
        enum: endianness
      category:
        value: (value.to_i >> 3) & 0b111
        enum: category
      log2size_or_special:
        value: value.to_i & 0b111

      size:
        value: "(log2size_or_special == 6? 10: (log2size_or_special == 7? 12: (1 << log2size_or_special)))"
        if: category.to_i < 3

      special:
        value: log2size_or_special
        if: category.to_i >= 3


enums:
  endianness:
    0: machine
    1: le
    2: be
  category:
    0: uint
    1: sint
    2: ieee754
    3: string

  item_type:
    0000: u1
    0010: s1
    0020: f1

    0031: uc1 # unsigned char
    0032: ustr # unsigned char string

    0131: sc1 # signed char
    0132: sstr # signed char string

    # Machine endianness
    0001: u2me
    0002: u4me
    0003: u8me
    0011: s2me
    0012: s4me
    0013: s8me
    0021: f2me
    0022: f4me
    0023: f8me
    0026: f10me
    0027: f12me
    0024: f16me
    0025: f32me

    # le

    0101: u2le
    0102: u4le
    0103: u8le
    0111: s2le
    0112: s4le
    0113: s8le
    0121: f2le
    0122: f4le
    0123: f8le
    0126: f10le
    0127: f12le
    0124: f16le
    0125: f32le

    # be

    0201: u2be
    0202: u4be
    0203: u8be
    0211: s2be
    0212: s4be
    0213: s8be
    0221: f2be
    0222: f4be
    0223: f8be
    0226: f10be
    0227: f12be
    0224: f16be
    0225: f32be

