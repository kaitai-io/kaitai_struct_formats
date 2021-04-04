meta:
  id: rtcp_payload
  title: rtcp network payload (single udp packet)
  xref:
    wikidata: Q749940
  license: CC0-1.0
  ks-version: 0.7
  endian: be

doc: RTCP is the Real-Time Control Protocol

doc-ref: https://tools.ietf.org/html/rfc3550

seq:
  - id: rtcp_packets
    type: rtcp_packet
    repeat: eos

types:
  rtcp_packet:
    seq:
      - id: version
        type: b2
      - id: padding
        type: b1
      - id: subtype
        type: b5
      - id: payload_type
        type: u1
        enum: payload_type
      - id: length
        type: u2
      - id: body
        size: 4 * length
        type:
          switch-on: payload_type
          cases:
            'payload_type::sr': sr_packet
            'payload_type::rr': rr_packet
            'payload_type::sdes': sdes_packet
            'payload_type::psfb': psfb_packet
            'payload_type::rtpfb': rtpfb_packet

  sr_packet:
    seq:
      - id: ssrc
        type: u4
      - id: ntp_msw
        type: u4
      - id: ntp_lsw
        type: u4
      - id: rtp_timestamp
        type: u4
      - id: sender_packet_count
        type: u4
      - id: sender_octet_count
        type: u4
      - id: report_block
        type: report_block
        repeat: expr
        repeat-expr: _parent.subtype
    instances:
      ntp:
        value: (ntp_msw << 32) & ntp_lsw

  rr_packet:
    seq:
      - id: ssrc
        type: u4
      - id: report_block
        type: report_block
        repeat: expr
        repeat-expr: _parent.subtype

  report_block:
    seq:
      - id: ssrc_source
        type: u4
      - id: lost_val
        type: u1
      - id: highest_seq_num_received
        type: u4
      - id: interarrival_jitter
        type: u4
      - id: lsr
        type: u4
      - id: dlsr
        type: u4
    instances:
      fraction_lost:
        value: lost_val >> 24
      cumulative_packets_lost:
        value: lost_val & 0x00ffffff

  sdes_packet:
    seq:
      - id: source_chunk
        type: source_chunk
        repeat: expr
        repeat-expr: source_count
    instances:
      source_count:
        value: _parent.subtype

  source_chunk:
    seq:
      - id: ssrc
        type: u4
      - id: sdes_tlv
        type: sdes_tlv
        repeat: eos

  sdes_tlv:
    seq:
      - id: type
        type: u1
        enum: sdes_subtype
      - id: length
        type: u1
        if: type != sdes_subtype::pad
      - id: value
        size: length
        if: type != sdes_subtype::pad

  rtpfb_packet:
    seq:
      - id: ssrc
        type: u4
      - id: ssrc_media_source
        type: u4
      - id: fci_block
        type:
          switch-on: fmt
          cases:
            'rtpfb_subtype::transport_feedback': rtpfb_transport_feedback_packet
        size-eos: true
    instances:
      fmt:
        value: _parent.subtype
        enum: rtpfb_subtype

  rtpfb_transport_feedback_packet:
    seq:
      - id: base_sequence_number
        type: u2
      - id: packet_status_count
        type: u2
      - id: b4
        type: u4
      - id: remaining
        size-eos: true
    instances:
      reference_time:
        value: b4 >> 8
      fb_pkt_count:
        value: b4 & 0xff
      packet_status:
        size: 0
      recv_delta:
        size: 0

  packet_status_chunk:
    seq:
      - id: t
        type: b1
      - id: s2
        type: b2
        if: t.to_i == 0
      - id: s1
        type: b1
        if: t.to_i == 1
      - id: rle
        type: b13
        if: t.to_i == 0
      - id: symbol_list
        type: b14
        if: t.to_i == 1
    instances:
      s:
        value: '(t.to_i == 0) ? s2 : (s1.to_i == 0 ? 1 : 0)'

  psfb_packet:
    seq:
      - id: ssrc
        type: u4
      - id: ssrc_media_source
        type: u4
      - id: fci_block
        type:
          switch-on: fmt
          cases:
            'psfb_subtype::afb': psfb_afb_packet
        size-eos: true
    instances:
      fmt:
        value: _parent.subtype
        enum: psfb_subtype

  psfb_afb_packet:
    seq:
      - id: uid
        type: u4
      - id: contents
        type:
          switch-on: uid
          cases:
            0x52454d42: psfb_afb_remb_packet
        size-eos: true

  psfb_afb_remb_packet:
    seq:
      - id: num_ssrc
        type: u1
      - id: br_exp
        type: b6
      - id: br_mantissa
        type: b18
      - id: ssrc_list
        type: u4
        repeat: expr
        repeat-expr: num_ssrc
    instances:
      max_total_bitrate:
        value: br_mantissa * (1<<br_exp)



enums:
  payload_type:
    192: fir
    193: nack
    195: ij
    200: sr
    201: rr
    202: sdes
    203: bye
    204: app
    205: rtpfb
    206: psfb
    207: xr
    208: avb
    209: rsi
  sdes_subtype:
    0: pad
    1: cname
    2: name
    3: email
    4: phone
    5: loc
    6: tool
    7: note
    8: priv
  psfb_subtype:
    1: pli
    2: sli
    3: rpsi
    4: fir
    5: tstr
    6: tstn
    7: vbcm
    15: afb
  rtpfb_subtype:
    1: nack
    3: tmmbr
    4: tmmbn
    5: rrr
    15: transport_feedback
