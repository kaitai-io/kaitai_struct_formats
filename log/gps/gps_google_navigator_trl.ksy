meta:
  id: gps_google_navigator_trl
  title: Google Navigator Tracklines
  application: Google Navigator
  file-extension: trl
  endian: le
  license: GPL-2.0-or-later

doc: |
  File format to save logs used in old Google Navigator

doc-ref:
  - https://www.gpsbabel.org/htmldoc-development/fmt_gnav_trl.html
  - https://github.com/gpsbabel/gpsbabel/blob/e1e195beca8e0f24ca0e41c02d1986af13865cd0/gnav_trl.cc

seq:
  - id: points
    type: point
    repeat: eos

types:
  point:
    seq:
      - id: timestamp
        type: s4
      - id: lat
        type: f4
      - id: lon
        type: f4
      - id: alt
        type: f4
        doc: "ToDo: rotated left by eight bits"
