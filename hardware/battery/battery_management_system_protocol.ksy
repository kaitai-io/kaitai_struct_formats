meta:
  id: battery_management_system_protocol
  title: Communication protocol of smart battery management systems from LLT power
  license: CC0-1.0
  ks-version: 0.9
  endian: be
  bit-endian: be

doc: |
  Many modern general purpose BMS include a UART/Bluetooth based communication interface.
  After sending read requests they respond with various information's about the battery state in
  a custom binary format.

doc-ref: https://www.lithiumbatterypcb.com/Protocol%20English%20Version.rar

seq:
  - id: magic_start
    contents: [0xdd]
  - id: cmd
    type: u1
    -affected-by: 778

  - size: 0
    if: ofs_body_start < 0 # storing current position
  - id: body
    type:
      switch-on: cmd
      cases:
        commands::read.to_i: read_req
        commands::write.to_i: write_req
        _: response(cmd)
  - size: 0
    if: ofs_body_end < 0 # storing current position

  - id: checksum
    type: u2
    doc: |
      Should be equal to the result from: 0x10000 - sum(body)
      Where sum() is calculated over the value of every byte individually.
      Body includes everything besides magic start/end byte, cmd and checksum,
      so excluding 2 bytes at the beginning and 3 bytes at the end.
  - id: magic_end
    contents: [0x77]

instances:
  ofs_body_start:
    value: _io.pos
  ofs_body_end:
    value: _io.pos
  checksum_input:
    -affected-by: 84
    pos: ofs_body_start
    size: ofs_body_end - ofs_body_start

enums:
  commands:
    0xa5: read
    0x5a: write

types:
  read_req:
    seq:
      - id: req_cmd
        type: u1
        doc: Same value as cmd for response
      - id: data_len
        contents: [0x00]
  write_req:
    seq:
      - id: req_cmd
        type: u1
        doc: Same value as cmd for response
      - id: data_len
        type: u1
      - id: write_data
        size: data_len

  basic_info:
    seq:
      - id: total
        type: voltage
      - id: current
        type: current
      - id: remain_cap
        type: capacity
      - id: typ_cap
        type: capacity
      - id: cycles
        type: u2
        doc: Cycle times
      - id: prod_date
        type: u2
        doc: Production date
      - id: balance_status
        type: balance_list
        doc: List of balance bits
      - id: prot_status
        type: prot_list
        doc: List of protection bits
      - id: software_version
        type: u1
      - id: remain_cap_percent
        type: u1
        doc: Portion of remaining capacity
      - id: fet_status
        type: fet_bits
      - id: cell_count
        type: u1
      - id: ntc_count
        type: u1
      - id: temps
        type: temp
        size: 2
        repeat: expr
        repeat-expr: ntc_count
    types:
      balance_list:
        seq:
          - id: is_balancing
            type: b1
            repeat: expr
            repeat-expr: 32
      prot_list:
        seq:
          - id: reserved
            type: b3
          - id: is_fet_lock
            type: b1
          - id: is_ic_error
            type: b1
          - id: is_ocp_short
            type: b1
          - id: is_ocp_discharge
            type: b1
          - id: is_ocp_charge
            type: b1
          - id: is_utp_discharge
            type: b1
          - id: is_otp_discharge
            type: b1
          - id: is_utp_charge
            type: b1
          - id: is_otp_charge
            type: b1
          - id: is_uvp_pack
            type: b1
          - id: is_ovp_pack
            type: b1
          - id: is_uvp_cell
            type: b1
          - id: is_ovp_cell
            type: b1
      fet_bits:
        seq:
          - id: reserved
            type: b6
          - id: is_discharge_enabled
            type: b1
          - id: is_charge_enabled
            type: b1
      voltage:
        -affected-by: 522
        seq:
          - id: raw
            type: u2
            doc: Pack voltage (raw)
        instances:
          volt:
            value: raw * 0.01
            doc: Pack voltage (V)
      capacity:
        -affected-by: 522
        seq:
          - id: raw
            type: u2
            doc: Capacity (raw)
        instances:
          amp_hour:
            value: raw * 0.01
            doc: Capacity (Ah)
      current:
        -affected-by: 522
        seq:
          - id: raw
            type: s2
            doc: Actual current (raw)
        instances:
          amp:
            value: raw * 0.01
            doc: Actual current (A)
      temp:
        -affected-by: 522
        seq:
          - id: raw
            type: u2
        instances:
          celsius:
            value: raw * 0.1 - 273.1

  cell_voltages:
    seq:
      - id: cells
        type: voltage
        repeat: eos
    types:
      voltage:
        -affected-by: 522
        seq:
          - id: raw
            type: u2
            doc: Cell voltage (raw)
        instances:
          volt:
            value: raw * 0.001
            doc: Cell voltage (V)

  hardware:
    seq:
      - id: version
        type: str
        encoding: ascii
        size-eos: true
        doc: BMS model and version specification

  response:
    params:
      - id: cmd
        type: u1
    enums:
      status:
        0x00: ok
        0x80: fail
    seq:
      - id: status
        type: u1
        enum: status
      - id: data_len
        type: u1
      - id: data
        type:
          switch-on: cmd
          cases:
            0x03: basic_info
            0x04: cell_voltages
            0x05: hardware
        size: data_len
