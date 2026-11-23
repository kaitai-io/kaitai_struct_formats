meta:
  id: gps_bunshell_trl
  title: Bunshell GPS Trail
  application: Bunshell receivers
  file-extension: trl
  license: GPL-2.0-or-later
  endian: le

doc: |
  File format used in Bunshell GPS receivers

doc-ref:
  - https://www.gpsbabel.org/htmldoc-development/fmt_bushnell_trl.html
  - https://github.com/gpsbabel/gpsbabel/blob/master/bushnell_trl.cc

seq:
  - id: points
    type: point
    repeat: eos
types:
  point:
    seq:
      - id: lat
        type: fp
      - id: lon
        type: fp
    types:
      fp:
        seq:
          - id: raw
            type: s4
        instances:
          value:
            value: raw / 10000000.
