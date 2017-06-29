meta:
  id: packet_ppi
  endian: le
  imports:
    - /network/ethernet_frame
  license: CC0-1.0
doc: |
  PPI is a standard for link layer packet encapsulation, proposed as
  generic extensible container to store both captured in-band data and
  out-of-band data. Originally it was developed to provide 802.11n
  radio information, but can be used for other purposes as well.

  Sample capture: https://wiki.wireshark.org/SampleCaptures?action=AttachFile&do=get&target=Http.cap  
doc-ref: https://www.cacetech.com/documents/PPI_Header_format_1.0.1.pdf PPI header format spec, section 3
seq:
  - id: header
    type: packet_ppi_header
  - id: fields
    type: packet_ppi_fields
    size: header.pph_len - 8 # sizeof(packet_ppi_header)
  - id: body
    size-eos: true
    type:
      switch-on: header.pph_dlt
      cases:
        'linktype::ppi': packet_ppi
        'linktype::ethernet': ethernet_frame
types:
  packet_ppi_header:
    doc-ref: https://www.cacetech.com/documents/PPI_Header_format_1.0.1.pdf PPI header format spec, section 3.1
    seq:
      - id: pph_version
        type: u1
      - id: pph_flags
        type: u1
      - id: pph_len
        type: u2
      - id: pph_dlt
        type: u4
        enum: linktype
  packet_ppi_fields:
    seq:
      - id: entries
        type: packet_ppi_field
        repeat: eos
  packet_ppi_field:
    doc-ref: https://www.cacetech.com/documents/PPI_Header_format_1.0.1.pdf PPI header format spec, section 3.1
    seq:
      - id: pfh_type
        type: u2
        enum: pfh_type
      - id: pfh_datalen
        type: u2
      - id: body
        size: pfh_datalen
        type:
          switch-on: pfh_type
          cases:
            'pfh_type::radio_802_11_common': radio_802_11_common_body
            'pfh_type::radio_802_11n_mac_ext': radio_802_11n_mac_ext_body
            'pfh_type::radio_802_11n_mac_phy_ext': radio_802_11n_mac_phy_ext_body
  radio_802_11_common_body:
    doc-ref: https://www.cacetech.com/documents/PPI_Header_format_1.0.1.pdf PPI header format spec, section 4.1.2
    seq:
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
  radio_802_11n_mac_ext_body:
    doc-ref: https://www.cacetech.com/documents/PPI_Header_format_1.0.1.pdf PPI header format spec, section 4.1.3
    seq:
      - id: flags
        type: mac_flags
      - id: a_mpdu_id
        type: u4
      - id: num_delimiters
        type: u1
      - id: reserved
        size: 3
  radio_802_11n_mac_phy_ext_body:
    doc-ref: https://www.cacetech.com/documents/PPI_Header_format_1.0.1.pdf PPI header format spec, section 4.1.4
    seq:
      - id: flags
        type: mac_flags
      - id: a_mpdu_id
        type: u4
      - id: num_delimiters
        type: u1
      - id: mcs
        type: u1
        doc: Modulation Coding Scheme (MCS)
      - id: num_streams
        type: u1
        doc: Number of spatial streams (0 = unknown)
      - id: rssi_combined
        type: u1
        doc: RSSI (Received Signal Strength Indication), combined from all active antennas / channels
      - id: rssi_ant_ctl
        type: u1
        doc: RSSI (Received Signal Strength Indication) for antennas 0-3, control channel
        repeat: expr
        repeat-expr: 4
      - id: rssi_ant_ext
        type: u1
        doc: RSSI (Received Signal Strength Indication) for antennas 0-3, extension channel
        repeat: expr
        repeat-expr: 4
      - id: ext_channel_freq
        type: u2
        doc: Extension channel frequency (MHz)
      - id: ext_channel_flags
        type: channel_flags
        doc: Extension channel flags
      - id: rf_signal_noise
        type: signal_noise
        repeat: expr
        repeat-expr: 4
        doc: Signal + noise values for antennas 0-3
      - id: evm
        type: u4
        repeat: expr
        repeat-expr: 4
        doc: EVM (Error Vector Magnitude) for chains 0-3
    types:
      channel_flags:
        seq:
          # First byte
          - id: spectrum_2ghz
            type: b1
            doc: 2 GHz spectrum
          - id: ofdm
            type: b1
            doc: OFDM (Orthogonal Frequency-Division Multiplexing)
          - id: cck
            type: b1
            doc: CCK (Complementary Code Keying)
          - id: turbo
            type: b1
          # Unused LSB of first byte + MSB of second byte
          - id: unused
            type: b8
          # Second byte
          - id: gfsk
            type: b1
            doc: Gaussian Frequency Shift Keying
          - id: dyn_cck_ofdm
            type: b1
            doc: Dynamic CCK-OFDM
          - id: only_passive_scan
            type: b1
            doc: Only passive scan allowed
          - id: spectrum_5ghz
            type: b1
            doc: 5 GHz spectrum
      signal_noise:
        doc: RF signal + noise pair at a single antenna
        seq:
          - id: signal
            type: s1
            doc: RF signal, dBm
          - id: noise
            type: s1
            doc: RF noise, dBm
  mac_flags:
    seq:
      - id: unused1
        type: b1
      - id: aggregate_delimiter
        type: b1
        doc: Aggregate delimiter CRC error after this frame
      - id: more_aggregates
        type: b1
        doc: More aggregates
      - id: aggregate
        type: b1
        doc: Aggregate
      - id: dup_rx
        type: b1
        doc: Duplicate RX
      - id: rx_short_guard
        type: b1
        doc: RX short guard interval (SGI)
      - id: is_ht_40
        type: b1
        doc: true = HT40, false = HT20
      - id: greenfield
        type: b1
        doc: Greenfield
      - id: unused2
        size: 3
enums:
  pfh_type:
    2: radio_802_11_common
    3: radio_802_11n_mac_ext
    4: radio_802_11n_mac_phy_ext
    5: spectrum_map
    6: process_info
    7: capture_info

  # FIXME: this is copy-paste from pcap.ksy, remove after
  # implementation of enum sharing / parametric types
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
