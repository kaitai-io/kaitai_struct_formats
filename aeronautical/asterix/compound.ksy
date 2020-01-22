meta:
  id: compound
  license: GPL-3.0-only
  endian: be
  imports:
    - field_spec
    - fixed
    - repetitive
    - explicit
    - extended

  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Compound Standard Field format.

  The compound field format is a variable lenght and content field.
  This uses four parameters:

  item, which is just the item name, as I001/010, or I062/390. It is just
  informative, and is not used during parsing, but permits consult the item name
  in the target language.

  f_fmt, is a string with a list of the formats of the subfields,
  The available formats are:
      F, for Fixed.
      E, for Extended.
      X, for Explicit.
      R, for Repetitive.

  f_pri_sizes, is an array of the parameter sizes for the subfields formats.

  f_sec_sizes, is an array of the second parameter size, which is only used for
  Extended subfields. For all the other formats a 0 should be used, although it is
  not used at all.



params:
  - id: name
    type: str
  - id: f_fmt
    type: str
  - id: f_pri_sizes
  - id: f_sec_sizes

seq:
  - id: flags
    type: field_spec
  - id: data
    type:
      switch-on: fmts[_index]
      cases:
        '"E".as<u1>': explicit("",flags.octects[_index/7].bits[_index % 7]) #E
        '"F".as<u1>': fixed("",flags.octects[_index/7].bits[_index % 7],f_pri_sizes[_index]) #F
        '"R".as<u1>': repetitive("",flags.octects[_index/7].bits[_index % 7],f_pri_sizes[_index]) #R
        '"X".as<u1>': extended("",flags.octects[_index/7].bits[_index % 7],f_pri_sizes[_index],f_sec_sizes[_index]) #X
        _: empty
    repeat: expr
    repeat-expr: total_flags

instances:
  fmts:
    value: f_fmt.as<u1[]>

  total_flags:
    value: 'f_fmt.length'

  type:
    value: '"Compound"'


types:
  empty:
    seq:
    - id: no_val
      size: 0

    instances:
      tot_size:
        value: 0
