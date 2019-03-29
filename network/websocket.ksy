meta:
  id: websocket_dataframe
  title: WebSocket
  xref:
    rfc: 6455
  endian: be
doc: |
  The WebSocket Protocol enables two-way communication between a client
  running untrusted code in a controlled environment to a remote host
  that has opted-in to communications from that code.  The security
  model used for this is the origin-based security model commonly used
  by web browsers.  The protocol consists of an opening handshake
  followed by basic message framing, layered over TCP.  The goal of
  this technology is to provide a mechanism for browser-based
  applications that need two-way communication with servers that does
  not rely on opening multiple HTTP connections (e.g., using
  XMLHttpRequest or <iframe>s and long polling).
seq:
  - id: b1
    type: u1
  - id: b2
    type: u1
  - id: extended_len_1
    type: u2
    if: payload_len == 126
  - id: extended_len_2
    type: u4
    if: payload_len == 127
  - id: mask_key
    type: u4
    if: mask == 1
  - id: payload
    size: len
    
instances:
  fin:
    value: (b1 & 0b10000000) >> 7
  rsv1:
    value: (b1 & 0b01000000) >> 6
  rsv2:
    value: (b1 & 0b00100000) >> 5
  rsv3:
    value: (b1 & 0b00010000) >> 4
  opcode:
    enum: opcode
    value: (b1 & 0b00001111)
    
  mask:
    value: (b2 & 0b10000000) >> 7
  payload_len:
    value: (b2 & 0b01111111)
    
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
    
