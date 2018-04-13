meta:
  id: mrc
  title: MRC/CCP4 2014 file format
  application:
    - Agard
    - Amira
    - Avizo
    - SerialEM
    - Xplore3D
  file-extension:
    - mrc
    - map
    - rec
  xref:
    wikidata:
    - Q6717445
    - Q5009675
  license: Unlicense
  endian: le
  encoding: ascii

doc: |
  A file format for transmission electron microscopy.
  The docs are missing because of copyright (damn it) issues.
  The format will be improved later.
doc-ref:
  - "http://www.ccpem.ac.uk/mrc_format/mrc2014.php"
  - "https://bio3d.colorado.edu/imod/doc/mrc_format.txt"

seq:
  - id: header
    type: header
    size: header_size
  - id: extended_header
    size: header.extended_header_size
    type:
      switch-on: header.extra.type
      cases:
        _: std_ext_header
  - id: data
    type: data
instances:
  header_size:
    value: 1024
  label_length:
    value: 80
  labels_count:
    value: 10
  extra_size:
    value: 100
types:
  data:
    seq:
      - id: flat
        type:
          switch-on: _root.header.mode
          cases:
            "mode::s2": s2
            "mode::s4": s4
            "mode::trans_complex_s2": s2
            "mode::trans_complex_s4": s4
            "mode::u2": u2
            "mode::rgb": rgb
            "mode::b4": b4
        repeat: expr
        repeat-expr: _root.header.dimensions[0]*_root.header.dimensions[1]*_root.header.dimensions[2]
    instances:
      columns:
        type: column(_index)
        repeat: expr
        repeat-expr: _root.header.dimensions[0]
    types:
      column:
        params:
          - id: i
            type: u4
        instances:
          rows:
            type: row(i, _index)
            repeat: expr
            repeat-expr: _root.header.dimensions[1]
        types:
          row:
            params:
              - id: i
                type: u4
              - id: j
                type: u4
            instances:
              sections:
                type: section(i, j, _index)
                repeat: expr
                repeat-expr: _root.header.dimensions[2]
            types:
              section:
                params:
                  - id: i
                    type: u4
                  - id: j
                    type: u4
                  - id: k
                    type: u4
                instances:
                  value:
                    value: "_parent._parent._parent.flat[_root.header.dimensions[0]*i+_root.header.dimensions[1]*j+k]"
  label:
    seq:
      - id: value
        type: str
        size: _root.label_length
  header:
    seq:
      - id: dimensions #0
        -orig-id: NX, NY, NZ
        type: u4
        repeat: expr
        repeat-expr: 3
      - id: mode #12
        type: s4
        enum: mode
      - id: first_item #16
        -orig-id: NXSTART, NYSTART, NZSTART
        type: u4
        repeat: expr
        repeat-expr: 3
      - id: m #28
        -orig-id: MX, MY, MZ
        type: u4
        repeat: expr
        repeat-expr: 3
      - id: cell_dimensions #40
        -orig-id: CELLA
        type: f4
        repeat: expr
        repeat-expr: 3
        doc: in Å
      - id: cell_angles # 52
        -orig-id: CELLB
        type: f4
        repeat: expr
        repeat-expr: 3
        doc: in °
      - id: axis # 64
        -orig-id: MAPC, MAPR, MAPS
        type: u4
        repeat: expr
        repeat-expr: 3
      - id: density_min # 76
        -orig-id: DMIN
        type: f4
      - id: density_max #80
        -orig-id: DMAX
        type: f4
      - id: density_mean #84
        -orig-id: DMEAN
        type: f4
      - id: space_group #88
        -orig-id: ISPG
        type: u4
      - id: extended_header_size #92
        -orig-id: NSYMBT
        type: u4
      - id: extra #96
        size: _root.extra_size
        type: extra
      - id: origin #196
        size: 12
        type:
          switch-on: is_transformed
          cases:
            true: origin_phase
            false: origin_of_subvolume
      - id: signature #208
        -orig-id: MAP
        contents: ['MAP ']
      - id: byte_order_stamp
        -orig-id: MACHST
        type: u4
      - id: rms
        type: u4
      - id: labels_used
        -orig-id: NLABL
        type: u4
      - id: labels
        -orig-id: LABEL
        type: label
        repeat: expr
        repeat-expr: _root.labels_count
    instances:
      is_transformed:
        value: (mode == mode::trans_complex_s2 or mode == mode::trans_complex_s4)
    types:
      extra:
        seq:
          - id: reserved0 #96
            size: 8
          - id: type #104
            -orig-id: EXTTYP
            type: str
            size: 4
          - id: version_number #108
            -orig-id: NVERSION
            type: format_version
      format_version:
        seq:
          - id: num
            type: u4
        instances:
          mask:
            value: 10
          year:
            value: num / mask
          in_year:
            value: num % mask
      origin_phase:
        seq:
          - id: origin_phase #104
            type: u8
      origin_of_subvolume:
        seq:
          - id: origin_of_subvolume #104
            type: u4
            repeat: expr
            repeat-expr: 3
  str16:
    seq:
      - id: str
        type: str
        size: 16
  s3:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b23
    instances:
      value:
        value: (sign?ext_mod-(1<<23):ext_mod)
  rgb:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
  serial_em_float:
    seq:
      - id: mantissa_
        type: s3
      - id: exponent
        type: s1
    instances:
      mantissa:
        value: mantissa_.value
      #value:
      #  value: mantissa * 2**exponent
  std_ext_header:
    seq:
      - id: symmetries
        type: label
        repeat: eos
enums:
  mode:
    1: s2
    2: s4
    3: trans_complex_s2
    4: trans_complex_s4
    6: u2
    16: rgb
    101: b4
