meta:
  id: edf
  file-extension: edf
  endian: le
  license: MIT

seq:
  - id: header
    type: header

  - id: body
    type: body

types:
  header:
    instances:
      ns:
        value: num_signals.to_i
      ndr:
        value: num_data_records.to_i

    seq:
      - id: "version"
        size: 8
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "patient_id"
        size: 80
        type: str
        encoding: ASCII

      - id: "recording_id"
        size: 80
        type: str
        encoding: ASCII

      - id: "start_date"
        size: 8
        type: str
        encoding: ASCII

      - id: "start_time"
        size: 8
        type: str
        encoding: ASCII

      - id: "header_num_bytes"
        size: 8
        type: str
        encoding: ASCII
        pad-right: 0x20

      - id: "reserved"
        size: 44
        type: str
        encoding: ASCII

      - id: "num_data_records"
        size: 8
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "data_duration"
        size: 8
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "num_signals"
        size: 4
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "labels"
        size: 16
        repeat: expr
        repeat-expr: ns
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "transducers"
        size: 80
        repeat: expr
        repeat-expr: ns
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "phys_dimensions"
        size: 8
        repeat: expr
        repeat-expr: ns
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "phys_mins"
        size: 8
        repeat: expr
        repeat-expr: ns
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "phys_maxes"
        size: 8
        repeat: expr
        repeat-expr: ns
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "dig_mins"
        size: 8
        repeat: expr
        repeat-expr: ns
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "dig_maxes"
        size: 8
        repeat: expr
        repeat-expr: ns
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "prefiltering"
        size: 80
        repeat: expr
        repeat-expr: ns
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "num_samples"
        size: 8
        repeat: expr
        repeat-expr: ns
        type: str
        pad-right: 0x20
        encoding: ASCII

      - id: "signals_reserved"
        size: 32
        repeat: expr
        repeat-expr: ns
        type: str
        pad-right: 0x20
        encoding: ASCII

  body:
    types:
      data_recording:
        seq:
          - id: "data"
            type: u2
            repeat: expr
            repeat-expr: _root.header.num_samples[_parent.signal_index].to_i

      signal:
        params:
          - id: "signal_index"
            type: s4

        seq:
          - id: "recordings"
            repeat: expr
            repeat-expr: _root.header.ndr
            type: data_recording

    seq:
      - id: "signals"
        repeat: expr
        repeat-expr: _root.header.ns
        type: signal(_index)
