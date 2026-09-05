meta:
  id: delorme_track_gpl
  title: DeLorme TripMate file format
  application:
    - DeLorme TripMate
    - DeLorme Map'n'Go 3.0
    - Deorme Street Atlas 4.0
  file-extension: gpl
  license: GPL-2.0-or-later
  endian: le
  tags:
    - geospatial

doc: |
  Native DeLorme TripMate file format (the version used in GPSBabel).
  Sample files are available in
    * https://www.frontiernet.net/~werner/gps/readgpl-06-Sep-2002.zip
    * https://www.frontiernet.net/~werner/gps/gplfiles.zip

doc-ref:
  - https://www.frontiernet.net/~werner/gps/
  - https://github.com/gpsbabel/gpsbabel/blob/e1e195beca8e0f24ca0e41c02d1986af13865cd0/delgpl.cc

seq:
  - id: points
    type: point
    repeat: eos

types:
  point:
    seq:
      - id: fix
        type: u4
        enum: fix
      - id: reserved1
        type: u4
        doc: Zero in all observed files
      - id: lat
        type: f8
        -unit: °
      - id: lon
        type: f8
        -unit: °
      - id: alt
        type: f8
        -unit: feet
      - id: heading
        type: f8
        -unit: °
      - id: speed
        type: f8
        -unit: mi/h
      - id: unix_timestamp
        type: u4
      - id: reserved1
        type: u4
        doc: Zero in all observed files

enums:
  fix:
    0:
      id: dupe
      doc: duplicate of the previous record
    1: none
    2: two_d
    3: three_d
    5: dgps
