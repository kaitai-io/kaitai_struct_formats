meta:
  id: protocol_body
  license: CC0-1.0
  ks-version: 0.8
  imports:
    - /network/tcp_segment
    - /network/icmp_packet
    - /network/udp_datagram
    - /network/ipv4_packet
    - /network/ipv6_packet
doc: |
  Protocol body represents particular payload on transport level (OSI
  layer 4).

  Typically this payload in encapsulated into network level (OSI layer
  3) packet, which includes "protocol number" field that would be used
  to decide what's inside the payload and how to parse it. Thanks to
  IANA's standardization effort, multiple network level use the same
  IDs for these payloads named "protocol numbers".

  This is effectively a "router" type: it expects to get protocol
  number as a parameter, and then invokes relevant type parser based
  on that parameter.
doc-ref: http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
params:
  - id: protocol_num
    type: u1
    doc: Protocol number as an integer.
instances:
  protocol:
    value: protocol_num
    enum: protocol_enum
seq:
  - id: body
    type:
      switch-on: protocol
      cases:
        'protocol_enum::hopopt': option_hop_by_hop
        'protocol_enum::tcp': tcp_segment
        'protocol_enum::icmp': icmp_packet
        'protocol_enum::udp': udp_datagram
        'protocol_enum::ipv4': ipv4_packet
        'protocol_enum::ipv6': ipv6_packet
        'protocol_enum::ipv6_nonxt': no_next_header
types:
  no_next_header:
    doc: Dummy type for IPv6 "no next header" type, which signifies end of headers chain.
  option_hop_by_hop:
    seq:
      - id: next_header_type
        type: u1
      - id: hdr_ext_len
        type: u1
      - id: body
        size: hdr_ext_len - 1
      - id: next_header
        type: protocol_body(next_header_type)
enums:
  protocol_enum:
    0: hopopt
    1: icmp
    2: igmp
    3: ggp
    4: ipv4
    5: st
    6: tcp
    7: cbt
    8: egp
    9: igp
    10: bbn_rcc_mon
    11: nvp_ii
    12: pup
    13: argus
    14: emcon
    15: xnet
    16: chaos
    17: udp
    18: mux
    19: dcn_meas
    20: hmp
    21: prm
    22: xns_idp
    23: trunk_1
    24: trunk_2
    25: leaf_1
    26: leaf_2
    27: rdp
    28: irtp
    29: iso_tp4
    30: netblt
    31: mfe_nsp
    32: merit_inp
    33: dccp
    34: x_3pc
    35: idpr
    36: xtp
    37: ddp
    38: idpr_cmtp
    39: tp_plus_plus
    40: il
    41: ipv6
    42: sdrp
    43: ipv6_route
    44: ipv6_frag
    45: idrp
    46: rsvp
    47: gre
    48: dsr
    49: bna
    50: esp
    51: ah
    52: i_nlsp
    53: swipe
    54: narp
    55: mobile
    56: tlsp
    57: skip
    58: ipv6_icmp
    59: ipv6_nonxt
    60: ipv6_opts
    61: any_host_internal_protocol
    62: cftp
    63: any_local_network
    64: sat_expak
    65: kryptolan
    66: rvd
    67: ippc
    68: any_distributed_file_system
    69: sat_mon
    70: visa
    71: ipcv
    72: cpnx
    73: cphb
    74: wsn
    75: pvp
    76: br_sat_mon
    77: sun_nd
    78: wb_mon
    79: wb_expak
    80: iso_ip
    81: vmtp
    82: secure_vmtp
    83: vines
    84: ttp_or_iptm
    85: nsfnet_igp
    86: dgp
    87: tcf
    88: eigrp
    89: ospfigp
    90: sprite_rpc
    91: larp
    92: mtp
    93: ax_25
    94: ipip
    95: micp
    96: scc_sp
    97: etherip
    98: encap
    99: any_private_encryption_scheme
    100: gmtp
    101: ifmp
    102: pnni
    103: pim
    104: aris
    105: scps
    106: qnx
    107: a_n
    108: ipcomp
    109: snp
    110: compaq_peer
    111: ipx_in_ip
    112: vrrp
    113: pgm
    114: any_0_hop
    115: l2tp
    116: ddx
    117: iatp
    118: stp
    119: srp
    120: uti
    121: smp
    122: sm
    123: ptp
    124: isis_over_ipv4
    125: fire
    126: crtp
    127: crudp
    128: sscopmce
    129: iplt
    130: sps
    131: pipe
    132: sctp
    133: fc
    134: rsvp_e2e_ignore
    135: mobility_header
    136: udplite
    137: mpls_in_ip
    138: manet
    139: hip
    140: shim6
    141: wesp
    142: rohc
    255: reserved_255
