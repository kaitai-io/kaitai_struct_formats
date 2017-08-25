meta:
  id: icmp_packet
  endian: be
  # https://tools.ietf.org/html/rfc792
seq:
  - id: icmp_type
    type: u1
    enum: icmp_type_enum
  - id: destination_unreachable
    type: destination_unreachable_msg
    if: icmp_type == icmp_type_enum::destination_unreachable
  - id: time_exceeded
    type: time_exceeded_msg
    if: icmp_type == icmp_type_enum::time_exceeded
  - id: echo
    type: echo_msg
    if: icmp_type == icmp_type_enum::echo or icmp_type == icmp_type_enum::echo_reply
enums:
  icmp_type_enum:
    0: echo_reply
    3: destination_unreachable
    4: source_quench
    5: redirect
    8: echo
    11: time_exceeded
types:
  destination_unreachable_msg:
    seq:
      - id: code
        type: u1
        enum: destination_unreachable_code
      - id: checksum
        type: u2
    enums:
      destination_unreachable_code:
        0: net_unreachable
        1: host_unreachable
        2: protocol_unreachable
        3: port_unreachable
        4: fragmentation_needed_and_df_set
        5: source_route_failed
  time_exceeded_msg:
    seq:
      - id: code
        type: u1
        enum: time_exceeded_code
      - id: checksum
        type: u2
    enums:
      time_exceeded_code:
        0: time_to_live_exceeded_in_transit
        1: fragment_reassembly_time_exceeded
  echo_msg:
    seq:
      - id: code
        contents: [0]
      - id: checksum
        type: u2
      - id: identifier
        type: u2
      - id: seq_num
        type: u2
