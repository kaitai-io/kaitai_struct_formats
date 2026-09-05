meta:
  id: gps_energympro_workout_measurement
  title: Energympro GPS Workaout
  application: Energympro GPS fitness tracker
  file-extension: cpo
  license: GPL-2.0-or-later
  endian: le
  encoding: ascii
doc: |
  File format used in Energympro GPS fitness tracker

doc-ref:
  - https://www.gpsbabel.org/htmldoc-development/fmt_energympro.html
  - https://github.com/gpsbabel/gpsbabel/blob/master/energympro.cc
  - https://github.com/gpsbabel/gpsbabel/blob/master/energympro.h
  - https://github.com/tboegi/GpsMaster/blob/master/GpsMaster/src/org/gpsmaster/gpsloader/CpoLoader.java
  - https://web.archive.org/web/20181102131518/http://www.energympro.com/product/dsw-gps-sport-watch/
  - https://web.archive.org/web/20200926083518/http://www.gpsmaster.org/download/

seq:
  - id: stuff
    type: stuff
    size: _root._io.size - sizeof<footer>

instances:
  footer:
    pos: _root._io.size - sizeof<footer>
    type: footer

types:
  fp:
    seq:
      - id: raw
        type: s4
    instances:
      value:
        value: raw / 1000000.

  point:
    seq:
      - id: lat
        type: fp
      - id: lon
        type: fp
      - id: alt
        type: u2
      - id: reserved0
        type: u2
      - id: speed
        type: u4
      - id: interval_dist
        type: u2
      - id: reserved1
        type: u2
      - id: interval_time
        type: u4
      - id: status
        type: u1
      - id: heart_rate_value
        type: u1
      - id: heart_rate_status
        type: u1
      - id: reserved2
        type: u1
      - id: speed_value
        type: u4
      - id: speed_status
        type: u1
      - id: reserved3
        size: 3
      - id: cadence_value
        type: u1
      - id: cadence_status
        type: u1
      - id: power_cadence
        type: u2
      - id: power_value
        type: u2
      - id: power_status
        type: u1
      - id: reserved4
        type: u1
      - id: temp
        type: u1
      - id: reserved5
        size: 3

  speed_heart_stats:  # sizeof == 10
    seq:
      - id: speed_max
        type: u4
      - id: speed_avg
        type: u4
      - id: heart_rate_max
        type: u1
      - id: heart_rate_avg
        type: u1

  lap:
    seq:
      - id: split_time
        type: u4
      - id: total_time
        type: u4
      - id: num
        type: u2
      - id: reserved0
        type: u2
      - id: linear_distance
        type: u4
      - id: calorie
        type: u2
      - id: reserved1
        type: u2

      - id: speed_heart_stats
        type: speed_heart_stats

      - id: alt_min
        type: u2
      - id: alt_max
        type: u2
      - id: cad_avg
        type: u1
      - id: cad_max
        type: u1
      - id: power_avg
        type: u2
      - id: power_max
        type: u2
      - id: rec_start
        type: u2
      - id: rec_end
        type: u2


  datetime:
    seq:
      - id: year
        type: u1
      - id: month
        type: u1
      - id: day
        type: u1
      - id: hour
        type: u1
      - id: minute
        type: u1
      - id: second
        type: u1

  footer:
    seq:
      - id: datetime
        type: datetime
      - id: point_count
        type: u2
      - id: duration_raw
        type: u4
        -unit: 0.1 sec
      - id: dist
        type: u4
        -unit: m
      - id: lap_count
        type: u2
      - id: calories
        type: u2
      - id: speed_heart_stats
        type: speed_heart_stats
      - id: unkn0
        size: 14
      - id: product
        type: strz
        size: 15
      - id: version
        type: u2

  stuff:
    seq:
      - id: points
        type: point
        repeat: expr
        repeat-expr: _root.footer.point_count
      - id: laps
        type: lap
        repeat: expr
        repeat-expr: _root.footer.lap_count
