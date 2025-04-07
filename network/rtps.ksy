meta:
    id: rtps
    title: RTPS
    endian: le
    tags: 2.3
doc: |
  The RTPS protocol provides DDS interroperability wire protocol.
seq:
  - id: header
    type: rtps_header
  - id: submessage
    type: rtps_submessage
    repeat: eos

types:
  protocol_version:
    seq:
      - id: major
        type: u1
      - id: minor
        type: u1
  vendor_id:
    seq:
      - id: value
        size: 2
  app_id:
    seq:
      - id: instance_id
        size: 3
      - id: app_kind
        size: 1
  guid_prefix:
    seq:
      - id: host_id
        size: 4
      - id: app_id
        size: 4
      - id: instance_id
        size: 4
  timestamp:
    seq:
      - id: seconds
        type: u4
        doc: Time in seconds
      - id: fraction
        type: u4
        doc: Time in sec/2^32
  entity_id:
    seq:
      - id: key
        size: 3
      - id: kind
        size: 1
  sequence_number:
    seq:
      - id: high
        size: 4
      - id: low
        size: 4
  bitmap_t:
    seq:
      - id: value
        type: s4
  sequence_number_set:
    seq:
      - id: bitmap_base
        type: sequence_number
      - id: numbits
        type: u4
      - id: bitmap
        type: bitmap_t
        repeat: expr
        repeat-expr: ((numbits+31)/32)
  count:
    seq:
      - id: value
        type: s4
  parameter_id:
    seq:
      - id: id
        type: s2
  parameter_list:
    seq:
      - id: parameter_id
        type: parameter_id
      - id: length
        type: s2
      - id: value
        size: length
  serialized_payload_header:
    seq:
      - id: representation_identifier
        type: s2
      - id: representation_options
        type: s2
  serialized_payload:
    seq:
      - id: header
        type: serialized_payload_header
      - id: payload
        size: _parent._parent.header.octets_to_next_header - 28
  locator:
    seq:
      - id: kind
        type: s4
      - id: port
        type: u4
      - id: address
        size: 16
  locator_list:
    seq:
      - id: value
        type: locator
  fragment_number:
    seq:
      - id: value
        type: u4
  fragment_number_set:
    seq:
      - id: bitmap_base
        type: fragment_number
      - id: numbits
        type: u4
      - id: bitmap
        type: fragment_number
        size: numbits
  info_source:
    seq:
      - id: unused
        type: u4
      - id: protocol_version
        type: protocol_version
      - id: vendor_id
        type: vendor_id
  info_timestamp:
    seq:
      - id: timestamp
        type: timestamp
  acknack:
    seq:
      - id: reader_id
        type: entity_id
      - id: writer_id
        type: entity_id
      - id: reader_sn_state
        type: sequence_number_set
      - id: count
        type: count
  data:
    meta:
      endian:
        switch-on: _parent.header.flags & 0x01
        cases:
          'false': be
          'true': le
    seq:
      - id: extra_flags
        type: s2
        doc: see 9.4.5.3.2. This protocol version should set all to zero.
      - id: octets_to_inline_qos
        type: u2
        doc: 9.4.5.3.2
      - id: reader_id
        type: entity_id
      - id: writer_id
        type: entity_id
      - id: writer_sn
        type: sequence_number
      - id: inline_qos
        type: parameter_list
        if: ((_parent.header.flags & 0x02) == 0)
        doc: only if Q == 1 means only if QosFlag is set
      - id: serialized_payload
        type: serialized_payload
        if: (((_parent.header.flags & 0x04) == 0) or ((_parent.header.flags & 0x08) == 0))
        doc: only if D==1 or K==1 means only if DataFlag or KeyFlag is set. see 9.4.5.3.1
  gap:
    seq:
      - id: reader_id
        type: entity_id
      - id: writer_id
        type: entity_id
      - id: gap_start
        type: sequence_number
      - id: gap_list
        type: sequence_number_set
  heartbeat:
    seq:
      - id: reader_id
        type: entity_id
      - id: writer_id
        type: entity_id
      - id: first_sn
        type: sequence_number
      - id: last_sn
        type: sequence_number
      - id: count
        type: count
  info_destination:
    seq:
      - id: guid_prefix
        type: guid_prefix
  info_reply:
    seq:
      - id: unicast_locator_list
        type: locator_list
      - id: multicast_locator_list
        type: locator_list
        if: _parent.header.flags & 0x02 == 1
  pad:
    doc: Pad is leaved blank, as specified by 9.4.5.12
  nack_frag:
    seq:
      - id: reader_id
        type: entity_id
      - id: writer_id
        type: entity_id
      - id: writer_sn
        type: sequence_number
      - id: fragment_number_set
        type: fragment_number_set
      - id: count
        type: count
  submessage_header:
    seq:
      - id: submessage_id
        type: s1
        enum: submessage_id
      - id: flags
        type: u1
      - id: octets_to_next_header
        type: u2
  rtps_header:
    seq:
      - id: magic
        contents: RTPS
      - id: protocol_version
        type: protocol_version
      - id: vendor_id
        type: vendor_id
      - id: guid_prefix
        type: guid_prefix
  rtps_submessage:
    seq:
      - id: header
        type: submessage_header
      - id: payload
        type:
          switch-on: header.submessage_id
          cases:
            'submessage_id::info_src': info_source
            'submessage_id::info_ts': info_timestamp
            'submessage_id::data': data
            'submessage_id::gap': gap
            'submessage_id::heartbeat': heartbeat
            'submessage_id::info_dst': info_destination
            'submessage_id::info_reply': info_reply
            'submessage_id::pad': pad
            'submessage_id::acknack': acknack

enums:
  submessage_id:
    0x1: pad
    0x6: acknack
    0x7: heartbeat
    0x8: gap
    0x9: info_ts
    0xc: info_src
    0xd: info_reply_ip4
    0xe: info_dst
    0xf: info_reply
    0x12: nack_frag
    0x13: heartbeat_frag
    0x15: data
    0x16: data_frag
