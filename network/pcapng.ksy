meta:
  id: pcapng
  title: PCAP Next Generation Capture File Format
  license: Unlicense
  file-extension: pcapng
  application:
    - Wireshark
    - tcpdump
  endian: le
  encoding: utf-8
  xref:
    mime: application/x-pcapng
    # rfc: # TBD
doc: |
  Pcap-NG is a new format for captures superseding pcap.
doc-ref:
  - https://xml2rfc.tools.ietf.org/cgi-bin/xml2rfc.cgi?url=https://raw.githubusercontent.com/pcapng/pcapng/master/draft-tuexen-opsawg-pcapng.xml&modeAsFormat=html/ascii&type=ascii
  - https://wiki.wireshark.org/Development/PcapNg
seq:
  - id: capture
    type: capture
types:
  capture:
    seq:
      - id: capture
        type: block
        repeat: eos
  version:
    seq:
      - id: major
        -orig-id: Major Version
        type: u2
        doc: backward-incompatible changes. Currently 1.
      - id: minor
        -orig-id: Minor Version
        type: u2
        doc: backward-compatible changes. Currently 0.
  timestamp:
    doc: |
      In units specified by if_tsresol.
    seq:
      - id: high
        -orig-id: Timestamp (High)
        type: u4
      - id: low
        -orig-id: Timestamp (Low)
        type: u4
    instances:
      value:
        value: "high << 32 | low"
  options:
    seq:
      - id: options
        type: option
        repeat: until
        repeat-until: _.type.type != type::opt_endofopt and _.length != 0
    types:
      option:
        seq:
          - id: type
            -orig-id: Option Type
            type: type_descriptor
          - id: length
            -orig-id: Option Length
            type: u2
            doc: length of `value` without padding
          - id: value
            -orig-id: Option Value
            size: length
            type:
              switch-on: type.type
              cases:
                'type::comment': str
        types:
          type_descriptor:
            seq:
              - id: type
                type: u2
                enum: type
            instances:
              is_reserved_for_local_use:
                value: "type.to_i >> 15 == 1"
          custom:
            seq:
              - id: private_enterprise_number
                -orig-id: Private Enterprise Number
                type: u4
                doc-ref: https://www.iana.org/assignments/enterprise-numbers/enterprise-numbers
              - id: value
                -orig-id: Custom Data
                size-eos: true
                doc: padded to 32-bit boundary.
    enums:
      type:
        0:
          id: end_of_options
          -orig-id: opt_endofopt
        1:
          id: comment
          -orig-id: opt_comment
          doc: comment
        0xBAC:
          id: custom_bac
        0xBAD:
          id: custom_bad
        0x4BAC:
          id: custom_4bac
        0x4BAD:
          id: custom_4bad
        0x8000: reserved_for_local_use
  packet_body:
    seq:
      - id: timestamp
        type: timestamp
      - id: captured_packet_size
        -orig-id: Captured Packet Length
        type: u4
      - id: original_packet_size
        -orig-id: Original Packet Length
        type: u4
      - id: data
        -orig-id: Packet Data
        size: captured_packet_size
        #type:
  block:
    seq:
      - id: type
        -orig-id: Block Type
        type: type_descriptor
      - id: total_length
        -orig-id: Block Total Length
        type: u4
      - id: body
        -orig-id: Block Body
        size: total_length
        type:
          switch-on: type.type
          cases:
            'type::section_header': section_header
            'type::interface_description': interface_description
            'type::legacy_packet': legacy_packet
            'type::enhanced_packet': enhanced_packet
            'type::simple_packet': simple_packet
            'type::name_resolution': name_resolution
            'type::interface_statistics': interface_statistics
            'type::systemd_journal_export': strz
            'type::hone_machine_info': hone_machine_info
            'type::hone_connection_event': hone_connection_event
            'type::custom': custom
            #'type::compression': compression
            #'type::encryption': encryption
            #'type::fixed_length': fixed_length
            #'type::directory': directory
            #'type::traffic_statistics_and_monitoring': traffic_statistics_and_monitoring
            #'type::event_security': event_security
        doc: content of the block.
      - id: total_length_dup
        -orig-id: Block Total Length
        type: u4
    types:
      type_descriptor:
        seq:
          - id: type
            type: u4
            enum: type
        instances:
          is_reserved_for_local_use:
            value: "type.to_i >> 31 == 1"

      section_header:
        seq:
          - id: signature
            -orig-id: Byte-Order Magic
            type: u4
          - id: version
            -orig-id: Major Version
            type: version
          - id: size
            -orig-id: Section Length
            type: u8
          - id: options
            -orig-id: Options
            type: options
        enums:
          options:
            2:
              id: hardware
              -orig-id: shb_hardware
            3:
              id: os
              -orig-id: shb_os
            4:
              id: application
              -orig-id: shb_userappl
      interface_description:
        seq:
          - id: link_type
            -orig-id: LinkType
            type: u2
            doc-ref: https://www.tcpdump.org/linktypes.html
          - id: reserved
            -orig-id: Reserved
            type: u2
            doc: zeros
          - id: snap_length
            -orig-id: SnapLen
            type: u4
          - id: options
            -orig-id: Options (variable)
            type: options
        enums:
          options:
            2:
              id: name
              -orig-id: if_name
            3:
              id: description
              -orig-id: if_description
            4:
              id: ipv4_address
              -orig-id: if_IPv4addr
              doc: |
                address first, then mask
            5:
              id: ipv6_address
              -orig-id: if_IPv6addr
              doc: |
                 address first, then prefix length
            6:
              id: mac_address
              -orig-id: if_MACaddr
            7:
              id: eui_address
              -orig-id: if_EUIaddr
            8:
              id: speed
              -orig-id: if_speed
              doc: |
                in bits per second
            9:
              id: timestamp_resolution
              -orig-id: if_tsresol
              doc: |
                negative powers either of 10 or 2, depending on the first bit
            10:
              id: time_zone
              -orig-id: if_tzone
            11:
              id: filter
              -orig-id: if_filter
            12:
              id: os_name
              -orig-id: if_os
            13:
              id: frame_check_sequence_bit_size
              -orig-id: if_fcslen
            14:
              id: ts_offset
              -orig-id: if_tsoffset
      legacy_packet:
        -orig-id: Packet
        seq:
          - id: interface_id
            -orig-id: Interface ID
            type: u2
          - id: drops_count
            -orig-id: Drops Count
            type: u2
          - id: packet_body
            type: packet_body
          - id: options
            -orig-id: Options (variable)
            type: options
        enums:
          options:
            2:
              id: pack_flags
              -orig-id: pack_flags
            3:
              id: pack_hash
              -orig-id: pack_hash
      enhanced_packet:
        seq:
          - id: interface_id
            -orig-id: Interface ID
            type: u4
          - id: packet_body
            type: packet_body
          - id: options
            -orig-id: Options (variable)
            type: options
        enums:
          options:
            2:
              id: epb_flags
              -orig-id: epb_flags
            3:
              id: epb_hash
              -orig-id: epb_hash
            4:
              id: epb_dropcount
              -orig-id: epb_dropcount
        types:
          flags:
            seq:
              - id: link_layer_dependent_errors
                type: link_layer_dependent_errors_le
              - id: second_word
                type: u2
            instances:
              in_out:
                value: ((second_word >> 14)&0b11)
                enum: in_out
              reception_type:
                value: ((second_word >> 11)&0b111)
                enum: reception_type
              fcs_length:
                value: ((second_word >> 7)&0b1111)
              reserved:
                value: (second_word &0b11111111)
            types:
              link_layer_dependent_errors_le:
                seq:
                  - id: symbol
                    type: b1
                  - id: preamble
                    type: b1
                  - id: start_frame_delimiter
                    type: b1
                  - id: unaligned_frame
                    type: b1
                  - id: wrong_inter_frame_gap
                    type: b1
                  - id: packet_too_short
                    type: b1
                  - id: packet_too_long
                    type: b1
                  - id: crc_error
                    type: b1
                  - id: reserved
                    type: b9
            enums:
              in_out:
                0b00: not_available
                0b01: inbound
                0b10: outbound
              reception_type:
                0b000: not_specified
                0b001: unicast
                0b010: multicast
                0b011: broadcast
                0b100: promiscuous
      simple_packet:
        seq:
          - id: packet_data
            -orig-id: Packet Data
            size-eos: true
      name_resolution:
        seq:
          - id: records
            -orig-id: Name Resolution Records
            repeat: eos
            type: record
          - id: options
            -orig-id: Options (variable)
            type: options
        types:
          record:
            doc: contains an association between a network address and a name.
            seq:
              - id: type
                -orig-id: Record Type
                enum: record_type
                type: u2
              - id: size
                -orig-id: Record Value Length
                type: u2
              - id: value
                -orig-id: Record Value
                size: size
            enums:
              record_type:
                0x0000:
                  id: end
                  -orig-id: nrb_record_end
                0x0001:
                  id: ipv4
                  -orig-id: nrb_record_ipv4
                0x0002:
                  id: ipv6
                  -orig-id: nrb_record_ipv6
              options:
                2:
                  id: server_dns_name
                  -orig-id: ns_dnsname
                3:
                  id: server_ipv4_addr
                  -orig-id: ns_dnsIP4addr
                4:
                  id: server_ipv6_addr
                  -orig-id: ns_dnsIP6addr
      interface_statistics:
        seq:
          - id: interface_id
            -orig-id: Interface ID
            type: u4
          - id: timestamp
            type: timestamp
          - id: options
            -orig-id: Options (variable)
            type: options
        enums:
          options:
            2:
              id: start_time
              -orig-id: isb_starttime
            3:
              id: end_time
              -orig-id: isb_endtime
            4:
              id: interface_received
              -orig-id: isb_ifrecv
            5:
              id: interface_dropped
              -orig-id: isb_ifdrop
            6:
              id: filter_accepted
              -orig-id: isb_filteraccept
            7:
              id: os_dropped
              -orig-id: isb_osdrop
            8:
              id: delivered_to_user
              -orig-id: isb_usrdeliv

      decryption_secrets:
        seq:
          - id: type
            -orig-id: Secrets Type
            type: u4
            doc-ref: https://www.winpcap.org/pipermail/pcap-ng-format/
          - id: length
            -orig-id: Secrets Length
            type: u4
          - id: data
            -orig-id: Secrets Data
            size: length
          - id: options
            -orig-id: Options
            type: options
        enums:
          type:
            0x544c534b:
              id: tls_key_log
              doc-ref: https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/Key_Log_Format
            0x57474b4c:
              id: wireguard_key_log
              doc: text string - the output of Handshake extractor
              doc-ref: https://git.zx2c4.com/wireguard-tools/tree/contrib/extract-handshakes
            0x5a4e574b:
              id: zigbee_nwk_key_and_panid
              doc: little endian
              doc-ref:
                - https://zigbeealliance.org/wp-content/uploads/2019/11/docs-05-3474-21-0csg-zigbee-specification.pdf#%5B%7B%22num%22%3A1199%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C70%2C387%2C0%5D

            0x5a415053:
              id: zigbee_application_support_link_key
              doc-ref: https://zigbeealliance.org/wp-content/uploads/2019/11/docs-05-3474-21-0csg-zigbee-specification.pdf#%5B%7B%22num%22%3A1224%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C70%2C651%2C0%5D

      hone_common_block_header:
        seq:
          - id: process_id
            -orig-id: Process ID
            type: u4
          - id: timestamp
            type: timestamp

      hone_machine_info:
        doc-ref: https://raw.githubusercontent.com/google/linux-sensor/master/hone-pcapng.txt
        seq:
          - id: block_header
            type: hone_common_block_header
          - id: options
            -orig-id: Options
            type: options
        enums:
          options_types:
            2: state
            3: executable_path
            4: argv
            5: parent_process_id
            6: user_id
            7: group_id
            8: user_name
            9: group_name

      hone_connection_event:
        doc-ref: https://raw.githubusercontent.com/google/linux-sensor/master/hone-pcapng.txt
        seq:
          - id: block_header
            type: hone_common_block_header
          - id: options
            -orig-id: Options
            type: options
        enums:
          options_types:
            2: event_type
      custom:
        seq:
          - id: private_enterprise_number
            -orig-id: Private Enterprise Number (PEN)
            type: u4
            doc-ref: https://www.iana.org/assignments/enterprise-numbers/enterprise-numbers
          - id: custom_data
            -orig-id: Custom Data
            size-eos: true
      # Experimental Blocks (unfinished in the RFC)
      # compression:
        # seq:
          # - id: type
            # -orig-id: Compr. Type
            # type: u1
            # enum: type
          # - id: data
            # -orig-id: Compressed Data
            # type: capture
            # size-eos: true
        # enums:
          # type:
            # 0: uncompressed
            # 1: lempel_ziv
            # 2: gzip
      # encryption:
        # seq:
          # - id: type
            # -orig-id: Encr. Type
            # type: u1
            # #enum: type
          # - id: data
            # -orig-id: Encrypted Data
            # type: capture
            # size-eos: true
      # fixed_length:
        # seq:
          # - id: cell_size
            # -orig-id: Cell Size
            # type: u2
          # - id: data
            # -orig-id: Fixed Size Data
            # size-eos: true
      # directory:
        # seq:
          # - id: packets_count
            # -orig-id: number of indexed packets
            # type: ?
          # - id: table
            # -orig-id: table with position and length of any indexed packet
            # size-eos: true
      # traffic_statistics_and_monitoring:
        # seq:

      # event_security:
        # seq:
    enums:
      type:
        0x80000000: reserved_for_local_use
        0x00000000: reserved
        0x0A0D0D0A:
          id: section_header
        0x00000001: interface_description
        0x00000006: enhanced_packet
        0x00000003: simple_packet
        0x00000004: name_resolution
        0x00000005: interface_statistics
        0x00000bad: custom00000bad  # allowed to copy
        0x40000bad: custom40000bad # not allowed to copy
        0x00000002:
          id: legacy_packet
          -orig-id: packet
        #alternative_packet
        #compression
        #encryption
        #fixed_length
        #directory
        #traffic_statistics_and_monitoring
        #event_security
        0x00000007: irig_timestamp # Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC)
        0x00000008: afdx_encapsulation_information # Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC)
        0x00000009: systemd_journal_export
        0x0000000A: decryption_secrets
        0x00000101: hone_machine_info
        0x00000102: hone_connection_event

        # sysdig blocks are not yet really implemented even in sysdig itself
        0x00000201: sysdig_machine_info_v0 # todo
        0x00000202: sysdig_process_info_v1 # todo
        0x00000209: sysdig_process_info_block_v3 # todo
        0x00000210: sysdig_process_info_block_v4 # todo
        0x00000211: sysdig_process_info_block_v5 # todo
        0x00000212: sysdig_process_info_block_v6 # todo
        0x00000213: sysdig_process_info_block_v7 # todo
        0x00000203: sysdig_fd_list # todo
        0x00000204: sysdig_event # todo
        0x00000208: sysdig_event_block_with_flags # todo
        0x00000205: sysdig_interface_list # todo
        0x00000206: sysdig_user_list # todo
        0x00000207: sysdig_process_info_v2 # todo
