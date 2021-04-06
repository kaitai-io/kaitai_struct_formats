meta:
  id: microsoft_network_monitor_v2
  application: Microsoft Network Monitor, v2.x
  file-extension: cap
  license: CC0-1.0
  xref:
    pronom: fmt/778
    wikidata: Q47245444
  ks-version: 0.7
  imports:
    - /network/ethernet_frame
    - /windows/windows_systemtime
  endian: le
doc: |
  Microsoft Network Monitor (AKA Netmon) is a proprietary Microsoft's
  network packet sniffing and analysis tool. It can save captured
  traffic as .cap files, which usually contain the packets and may
  contain some additional info - enhanced network info, calculated
  statistics, etc.

  There are at least 2 different versions of the format: v1 and
  v2. Netmon v3 seems to use the same file format as v1.
doc-ref: https://docs.microsoft.com/en-us/windows/win32/netmon2/capturefile-header-values
seq:
  - id: signature
    contents: GMBU
  - id: version_minor
    type: u1
    doc: Format version (minor), BCD
  - id: version_major
    type: u1
    doc: Format version (major), BCD
  - id: mac_type
    type: u2
    enum: linktype
    doc: Network topology type of captured data
  - id: time_capture_start
    type: windows_systemtime
    doc: Timestamp of capture start
  - id: frame_table_ofs
    type: u4
  - id: frame_table_len
    type: u4
  - id: user_data_ofs
    type: u4
  - id: user_data_len
    type: u4
  - id: comment_ofs
    type: u4
  - id: comment_len
    type: u4
  - id: statistics_ofs
    type: u4
  - id: statistics_len
    type: u4
  - id: network_info_ofs
    type: u4
  - id: network_info_len
    type: u4
  - id: conversation_stats_ofs
    type: u4
  - id: conversation_stats_len
    type: u4
instances:
  frame_table:
    pos: frame_table_ofs
    size: frame_table_len
    type: frame_index
    doc: Index that is used to access individual captured frames
types:
  frame_index:
    seq:
      - id: entries
        type: frame_index_entry
        repeat: eos
  frame_index_entry:
    doc: |
      Each index entry is just a pointer to where the frame data is
      stored in the file.
    seq:
      - id: ofs
        doc: Absolute pointer to frame data in the file
        type: u4
    instances:
      body:
        io: _root._io
        pos: ofs
        type: frame
        doc: Frame body itself
  frame:
    doc: |
      A container for actually captured network data. Allow to
      timestamp individual frames and designates how much data from
      the original packet was actually written into the file.
    doc-ref: https://docs.microsoft.com/en-us/windows/win32/netmon2/frame
    seq:
      - id: ts_delta
        type: u8
        doc: Time stamp - usecs since start of capture
      - id: orig_len
        type: u4
        doc: Actual length of packet
      - id: inc_len
        type: u4
        doc: Number of octets captured in file
      - id: body
        size: inc_len
        doc: Actual packet captured from the network
        type:
          switch-on: _root.mac_type
          cases:
            'linktype::ethernet': ethernet_frame
# Duplicate from pcap.ksy - should disappear from here as soon as
# we'll get shared enums working
enums:
  linktype:
    # https://www.tcpdump.org/linktypes.html
    0: null_linktype
    1: ethernet
    3: ax25
    6: ieee802_5
    7: arcnet_bsd
    8: slip
    9: ppp
    10: fddi
    50: ppp_hdlc
    51: ppp_ether
    100: atm_rfc1483
    101: raw
    104: c_hdlc
    105: ieee802_11
    107: frelay
    108: loop
    113: linux_sll
    114: ltalk
    117: pflog
    119: ieee802_11_prism
    122: ip_over_fc
    123: sunatm
    127: ieee802_11_radiotap
    129: arcnet_linux
    138: apple_ip_over_ieee1394
    139: mtp2_with_phdr
    140: mtp2
    141: mtp3
    142: sccp
    143: docsis
    144: linux_irda
    147: user0
    148: user1
    149: user2
    150: user3
    151: user4
    152: user5
    153: user6
    154: user7
    155: user8
    156: user9
    157: user10
    158: user11
    159: user12
    160: user13
    161: user14
    162: user15
    163: ieee802_11_avs
    165: bacnet_ms_tp
    166: ppp_pppd
    169: gprs_llc
    170: gpf_t
    171: gpf_f
    177: linux_lapd
    187: bluetooth_hci_h4
    189: usb_linux
    192: ppi
    195: ieee802_15_4
    196: sita
    197: erf
    201: bluetooth_hci_h4_with_phdr
    202: ax25_kiss
    203: lapd
    204: ppp_with_dir
    205: c_hdlc_with_dir
    206: frelay_with_dir
    209: ipmb_linux
    215: ieee802_15_4_nonask_phy
    220: usb_linux_mmapped
    224: fc_2
    225: fc_2_with_frame_delims
    226: ipnet
    227: can_socketcan
    228: ipv4
    229: ipv6
    230: ieee802_15_4_nofcs
    231: dbus
    235: dvb_ci
    236: mux27010
    237: stanag_5066_d_pdu
    239: nflog
    240: netanalyzer
    241: netanalyzer_transparent
    242: ipoib
    243: mpeg_2_ts
    244: ng40
    245: nfc_llcp
    247: infiniband
    248: sctp
    249: usbpcap
    250: rtac_serial
    251: bluetooth_le_ll
    253: netlink
    254: bluetooth_linux_monitor
    255: bluetooth_bredr_bb
    256: bluetooth_le_ll_with_phdr
    257: profibus_dl
    258: pktap
    259: epon
    260: ipmi_hpm_2
    261: zwave_r1_r2
    262: zwave_r3
    263: wattstopper_dlm
    264: iso_14443
