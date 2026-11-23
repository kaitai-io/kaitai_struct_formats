meta:
  id: gps_destinator_trk
  title: Destinator track
  application: Destinator
  file-extension:
    - dat
  license: GPL-2.0-or-later
  encoding: utf-16le
  -affected-by: 187
  endian: le
  tags:
    - geospatial

doc: |
  Destinator GPS tracks format for versions 3.0.75_103, 5.1.80 and 6.0.0.24556

doc-ref:
  - https://web.archive.org/web/20160310115940/http://mozoft.com/d3log.html
  - https://web.archive.org/web/20071011022251/http://www.destinatortechnologies.net/uk/products/products/bundles/
  - https://www.gpsbabel.org/htmldoc-development/fmt_destinator_trl.html
  - https://github.com/gpsbabel/gpsbabel/blob/e1e195beca8e0f24ca0e41c02d1986af13865cd0/destinator.cc#L264L326

seq:
  - id: points
    type: point
    repeat: eos

types:
  point:
    seq:
      - id: lon
        type: f8
      - id: lat
        type: f8
      - id: alt
        type: f8
      - id: unknown0
        type: f8
      - id: unknown1
        type: f8
      - id: unknown2
        type: f8
      - id: fix
        type: u4
        enum: fix
      - id: satellites_visible
        type: u4
      - id: satellites_info
        type: u4
        repeat: expr
        repeat-expr: 12
        doc: 0 for unused channels.
      - id: datetime
        type: u4
        doc: DDMMYYHHMMSS in decimal
      - id: milliseconds
        type: f4
        -unit: 0.001 s
        doc: again decimal
      - id: is_connected_to_satellite
        type: u1
        doc: likely bools
        repeat: expr
        repeat-expr: 12
      - id: signal_strength
        type: u2
        -unit: arb. unts
        repeat: expr
        repeat-expr: 12
      - id: signature
        contents: "TXT"
      - id: unknown3
        type: u1
      - id: unknown4
        type: u1
        repeat: expr
        repeat-expr: 12

enums:
  fix:
    2: two_d
    3: three_d
