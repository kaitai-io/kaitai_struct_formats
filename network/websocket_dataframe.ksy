meta:
  id: websocket_dataframe
  title: WebSocket
  xref:
    rfc: 6455
  endian: be
  license: APACHE-2.0
doc: |
  The WebSocket protocol establishes a two-way communication channel via TCP.
  Messages are made up of one or more dataframes, and are delineated by
  frames with the `fin` bit set.
seq:
  - id: fin
    type: b1
  - id: rsv1
    type: b1
  - id: rsv2
    type: b1
  - id: rsv3
    type: b1
  - id: opcode
    enum: opcode
    type: b4
  - id: b1
    type: u1
  - id: extended_len_1
    type: u2
    if: payload_len == 126
  - id: extended_len_2
    type: u4
    if: payload_len == 127
  - id: mask_key
    type: u4
    if: is_masked == 1
  - id: payload
    size: len
    
instances:
  is_masked:
    value: (b1 & 0b10000000) >> 7
  payload_len:
    value: (b1 & 0b01111111)
    
  len:
    value: |
      payload_len <= 125 ? payload_len : (
        payload_len == 126 ? extended_len_1 : extended_len_2
      )
    
enums:
  opcode:
    0: continuation
    1: text
    2: binary
    3: reserved_3
    4: reserved_4
    5: reserved_5
    6: reserved_6
    7: reserved_7
    8: close
    9: ping
    0xA: pong
    0xB: reserved_control_b
    0xC: reserved_control_c
    0xD: reserved_control_d
    0xE: reserved_control_e
    0xF: reserved_control_f
    
