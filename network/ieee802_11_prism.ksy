meta:
  id: ieee802_11_prism
  title: prism II headers for 802.11 capture
  license: Unlicense
  endian: le
  encoding: ascii
  xref:
    ieee: 802.11
    wikidata: Q7245672
doc: |
  Prism II headers are usually used by wlan cards based on Intersil/Conexant/Broadcom [Prism II](https://en.wikipedia.org/wiki/Prism_(chipset)) and Proxim Wireless/Lucent ORiNOCO.
  Disclaimer: AFAIK there is no official spec publicly available, most of the specs publicly available are reverse-engineered and incorporate their authors beleifs.

doc-ref:
  - https://www.tcpdump.org/linktypes/LINKTYPE_IEEE802_11_PRISM.html
  - http://www.martin.cc/linux/prism
  - https://github.com/NetBSD/src/blob/254d96fc6f162e5bf73da95029e7c6f3c9c6fd2c/sys/dev/ic/wi.c
  - https://github.com/freebsd/freebsd/tree/c71e73b0fbd8b142ebb4a933bb0e93ec2b0d830e/sys/dev/wi
  - https://github.com/wireshark/wireshark/blob/3a514caaf1e3b36eb284c3a566d489aba6df5392/epan/dissectors/packet-ieee80211-prism.c

seq:
  - id: message_code
    type: u4
  - id: size
    type: u4
  - id: device_name
    type: strz
    size: 16
  - id: fields
    type: fields
    size: fields_size
  - id: body
    size-eos: true
instances:
  rssi_offset:
    value: 100
    doc: "+100 for PRISM II, +149 for Lucent cards"
  header_size:
    value: 4 + 4 + 16
  fields_size:
    value: size - header_size
types:
  fields:
    seq:
      - id: fields
        type: field
        repeat: eos
    types:
      field:
        seq:
          - id: header
            type: header
          - id: is_not_supplied
            type: u2
          - id: size
            type: u2
          - id: value
            size: size
            type:
              switch-on: header.type
              cases:
                'type::host_time': u4 # in 10ms units, according to Cris Martin
                'type::mac_time': u4 # In micro-seconds, according to Cris Martin
                'type::channel': u4
                'type::rssi': rssi
                'type::signal_quality': u4
                'type::noise': s4
                'type::data_rate': u4 # in units/multiples of 500Khz, according to Cris Martin
                'type::direction': direction
                'type::frame_length': u4
        instances:
          is_supplied:
            value: is_not_supplied == 0
        types:
          rssi:
            seq:
              - id: offsetted
                type: u4
            instances:
              value:
                doc-ref: https://github.com/freebsd/freebsd/blob/c71e73b0fbd8b142ebb4a933bb0e93ec2b0d830e/sys/dev/wi/if_wivar.h#L173
                value: "offsetted - _root.rssi_offset"
                -affected-by: 88
          direction:
            seq:
              - id: value
                type: u4
                enum: direction
                -affected-by: 88
            enums:
              direction:
                0:
                  id: receive
                1:
                  id: transmit
          header:
            # all of these are wild guesses
            seq:
              - id: header_size
                type: b4
              - id: mandatory_part_offset
                type: b4
              - id: placeholder
                type: placeholder
                size: header_size - 1
            instances:
              mandatory_part_offset_from_first_byte:
                value: mandatory_part_offset - 1
              mandatory_part:
                pos: mandatory_part_offset_from_first_byte / 2
                type: mandatory_part(mandatory_part_skip_nibble)
                io: placeholder._io
              mandatory_part_skip_nibble:
                value: mandatory_part_offset_from_first_byte % 2 == 1
              type:
                value: mandatory_part.type
            types:
              placeholder:
                seq: []
              mandatory_part:
                params:
                  - id: skip_nibble
                    type: b1
                seq:
                  - id: unneeded_nibble
                    type: b4
                    if: skip_nibble
                  - id: type
                    type: b4
                    enum: type
                  - id: unkn
                    type: b8
enums:
  type:
    0x1: host_time
    0x2: mac_time
    0x3: channel
    0x4: rssi
    0x5: signal_quality
    0x6: signal
    0x7: noise
    0x8: data_rate
    0x9:
      id: direction
      -orig-id: is_tx
    0xa: frame_length
