meta:
  id: pcap
  file-extension: pcapdump
  endian: le
  ks-version: 0.7
  imports:
    - /network/ethernet_frame
seq:
  - id: hdr
    type: header
  - id: packets
    type: packet
    repeat: eos
-includes:
  - ethernet_frame.ksy
types:
  header:
    seq:
      # https://wiki.wireshark.org/Development/LibpcapFileFormat#Global_Header
      - id: magic_number
        contents: [0xd4, 0xc3, 0xb2, 0xa1]
      - id: version_major
        type: u2
      - id: version_minor
        type: u2
      - id: thiszone
        type: s4
      - id: sigfigs
        type: u4
      - id: snaplen
        type: u4
      - id: network
        type: u4
        enum: linktype
  packet:
    seq:
      # https://wiki.wireshark.org/Development/LibpcapFileFormat#Record_.28Packet.29_Header
      - id: ts_sec
        type: u4
      - id: ts_usec
        type: u4
      - id: incl_len
        type: u4
      - id: orig_len
        type: u4
      # https://wiki.wireshark.org/Development/LibpcapFileFormat#Packet_Data
      - id: body
        size: incl_len
        if: '_root.hdr.network != linktype::ppi and _root.hdr.network != linktype::ethernet'
      - id: ppi_body
        type: packet_ppi
        size: incl_len
        if: '_root.hdr.network == linktype::ppi'
      - id: ethernet_body
        type: ethernet_frame
        size: incl_len
        if: '_root.hdr.network == linktype::ethernet'
  packet_ppi:
    seq:
      # https://www.cacetech.com/documents/PPI_Header_format_1.0.1.pdf - section 3
      - id: header
        type: packet_ppi_header
      - id: fields
        type: packet_ppi_field
        repeat: eos
  packet_ppi_header:
    seq:
      # https://www.cacetech.com/documents/PPI_Header_format_1.0.1.pdf - section 3.1
      - id: pph_version
        type: u1
      - id: pph_flags
        type: u1
      - id: pph_len
        type: u2
      - id: pph_dlt
        type: u4
  packet_ppi_field:
    seq:
      # https://www.cacetech.com/documents/PPI_Header_format_1.0.1.pdf - section 3.1
      - id: pfh_type
        type: u2
#        enum: pfh_type
      - id: pfh_datalen
        type: u2
#      - id: radio_802_11_common_body
#        #size: pfh_datalen
#        type: radio_802_11_common_body
#        if: pfh_type == pfh_type::radio_802_11_common
      - id: body
        size: pfh_datalen
#        if: pfh_type != pfh_type::radio_802_11_common
  radio_802_11_common_body:
    seq:
      # https://www.cacetech.com/documents/PPI_Header_format_1.0.1.pdf - section 4.1.2
      - id: tsf_timer
        type: u8
      - id: flags
        type: u2
      - id: rate
        type: u2
      - id: channel_freq
        type: u2
      - id: channel_flags
        type: u2
      - id: fhss_hopset
        type: u1
      - id: fhss_pattern
        type: u1
      - id: dbm_antsignal
        type: s1
      - id: dbm_antnoise
        type: s1
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
  pfh_type:
    # https://www.cacetech.com/documents/PPI_Header_format_1.0.1.pdf - section 4
    2: radio_802_11_common
    3: radio_802_11n_mac_ext
    4: radio_802_11n_mac_phy_ext
    5: spectrum_map
    6: process_info
    7: capture_info
