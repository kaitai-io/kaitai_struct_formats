meta:
  id: pcap
  file-extension:
    - pcap
    - pcapdump
  xref:
    forensicswiki: PCAP
    justsolve: PCAP
  license: CC0-1.0
  ks-version: 0.8
  endian: le
  imports:
    - /network/ethernet_frame
    - /network/packet_ppi
doc: |
  PCAP (named after libpcap / winpcap) is a popular format for saving
  network traffic grabbed by network sniffers. It is typically
  produced by tools like [tcpdump](https://www.tcpdump.org/) or
  [Wireshark](https://www.wireshark.org/).
doc-ref: http://wiki.wireshark.org/Development/LibpcapFileFormat
seq:
  - id: hdr
    type: header
  - id: packets
    type: packet
    repeat: eos
types:
  header:
    doc-ref: 'https://wiki.wireshark.org/Development/LibpcapFileFormat#Global_Header'
    seq:
      - id: magic_number
        contents: [0xd4, 0xc3, 0xb2, 0xa1]
      - id: version_major
        type: u2
      - id: version_minor
        type: u2
      - id: thiszone
        type: s4
        doc: |
          Correction time in seconds between UTC and the local
          timezone of the following packet header timestamps.
      - id: sigfigs
        type: u4
        doc: |
          In theory, the accuracy of time stamps in the capture; in
          practice, all tools set it to 0.
      - id: snaplen
        type: u4
        doc: |
          The "snapshot length" for the capture (typically 65535 or
          even more, but might be limited by the user), see: incl_len
          vs. orig_len.
      - id: network
        type: u4
        enum: linktype
        doc: |
          Link-layer header type, specifying the type of headers at
          the beginning of the packet.
  packet:
    doc-ref: 'https://wiki.wireshark.org/Development/LibpcapFileFormat#Record_.28Packet.29_Header'
    seq:
      - id: ts_sec
        type: u4
      - id: ts_usec
        type: u4
      - id: incl_len
        type: u4
        doc: Number of bytes of packet data actually captured and saved in the file.
      - id: orig_len
        type: u4
        doc: Length of the packet as it appeared on the network when it was captured.
      - id: body
        size: incl_len
        type:
          switch-on: _root.hdr.network
          cases:
            'linktype::ppi': packet_ppi
            'linktype::ethernet': ethernet_frame
        doc-ref: 'https://wiki.wireshark.org/Development/LibpcapFileFormat#Packet_Data'
enums:
  linktype:
    # http://www.tcpdump.org/linktypes.html
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
