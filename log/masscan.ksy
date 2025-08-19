meta:
  id: masscan
  title: masscan binary report
  endian: be
  encoding: ascii
  imports:
    - /common/vlq_base128_le
    - /network/protocol_body

doc: |
    Results of scanning with masscan tool

doc-ref:
  - https://github.com/robertdavidgraham/masscan/blob/2895fa0acfe45983a3e9b2bbfadf25934c8d2c65/src/out-binary.c
  - https://github.com/robertdavidgraham/masscan/blob/2895fa0acfe45983a3e9b2bbfadf25934c8d2c65/src/in-binary.c

seq:
  - id: header
    type: header
    size: 99
  - id: records
    type: record
    repeat: until
    repeat-until: _io.size - _io.pos <= header_size
  - id: footer
    type: footer

instances:
  header_size:
    value: 99


types:
  header:
    seq:
      - id: signature
        type: strz
        terminator: 0x2f
        valid: "'masscan'"
      - id: version_str
        type: strz
        terminator: 0x0a
      - id: metadata_str
        type: strz
        size-eos: true
  footer:
    seq:
      - id: signature
        type: strz
        terminator: 0x2f
        valid: _parent.header.signature
      - id: version_str
        type: strz
        valid: _parent.header.version_str
      - id: metadata_str
        type: strz
        size-eos: true
  record:
    seq:
      - id: type_raw
        type: vlq_base128_le
      - id: length
        type: vlq_base128_le
      - id: payload
        size: length.value
        type:
          switch-on: type
          cases:
            type::status_open: masscan_record(true, false, true, false, true, true)
            type::status_closed: masscan_record(false, false, true, false, true, true)
            type::status2_open: masscan_record(true, true, true, false, true, true)
            type::status2_closed: masscan_record(false, true, true, false, true, true)
            type::status6_open: masscan_record(true, false, true, false, true, true)
            type::status6_closed: masscan_record(false, false, true, false, true, true)
            type::banner6: masscan_record(true, false, false, true, true, true)
            type::banner4: masscan_record(true, true, false, true, false, true)
            type::banner9: masscan_record(true, true, false, true, true, true)
            type::banner3: masscan_record(true, true, false, true, false, false)

    instances:
      type:
        value: type_raw.value
        enum: type
    enums:
      type:
        1:
          id: status_open
        2:
          id: status_closed
        3:
          id: banner3 #
        4:
          id: banner4 #
        5:
          id: banner_4_1
        6:
          id: status2_open #
        7:
          id: status2_closed #
        9:
          id: banner9 #
        10:
          id: status6_open #
        11:
          id: status6_closed #
        13:
          id: banner6 #
        109: m #'m' FILEHEADER
    types:
      masscan_record:
        params:
          - id: is_open
            type: b1
          - id: old
            type: b1
          - id: has_reason
            type: b1
          - id: app_proto_present
            type: b1
          - id: has_ttl
            type: b1
          - id: has_ip_proto
            type: b1
        meta:
          endian:
            switch-on: old
            cases:
              true: le
              false: be
        seq:
          - id: timestamp
            type: u4
          - id: ipv4
            size: 4
            if: old

          - id: ip_proto
            type: u1
            if: has_ip_proto
            enum: protocol_body::protocol_enum
            #--affected-by:

          - id: port
            type: u2
          - id: app_proto
            type: u2
            enum: app_proto
            if: app_proto_present

          - id: reason
            type: u1
            if: has_reason
          - id: ttl
            type: u1
            if: has_ttl

          - id: ip_with_version
            type: switcheable_ip_version
            if: not old
        instances:
          ip_addr:
            value: "(old?ipv4:ip_with_version.addr)"

      switcheable_ip_version:
        seq:
          - id: version
            type: u1
            valid: 6
          - id: addr
            size: 16

enums:
  app_proto:  # https://github.com/robertdavidgraham/masscan/blob/0300ff031cff6fafa078b25b31106bea237d3879/src/masscan-app.c
    0:
      id: none
      -orig-id: PROTO_NONE
    1:
      id: heur
      -orig-id: PROTO_HEUR
    2:
      id: ssh1
      -orig-id: PROTO_SSH1
    3:
      id: ssh2
      -orig-id: PROTO_SSH2
    4:
      id: http
      -orig-id: PROTO_HTTP
    5:
      id: ftp
      -orig-id: PROTO_FTP
    6:
      id: dns_version_bind
      -orig-id: PROTO_DNS_VERSIONBIND
    7:
      id: snmp
      -orig-id: PROTO_SNMP
    8:
      id: nbt_stat
      -orig-id: PROTO_NBTSTAT
    9:
      id: ssl3
      -orig-id: PROTO_SSL3
    10:
      id: smb
      -orig-id: PROTO_SMB
    11:
      id: smtp
      -orig-id: PROTO_SMTP
    12:
      id: pop3
      -orig-id: PROTO_POP3
    13:
      id: imap4
      -orig-id: PROTO_IMAP4
    14:
      id: udp_zero_access
      -orig-id: PROTO_UDP_ZEROACCESS
    15:
      id: x509_cert
      -orig-id: PROTO_X509_CERT
    16:
      id: html_title
      -orig-id: PROTO_HTML_TITLE
    17:
      id: html_full
      -orig-id: PROTO_HTML_FULL
    18:
      id: ntp
      -orig-id: PROTO_NTP
    19:
      id: vuln
      -orig-id: PROTO_VULN
    20:
      id: heartbleed
      -orig-id: PROTO_HEARTBLEED
    21:
      id: ticketbleed
      -orig-id: PROTO_TICKETBLEED
    22:
      id: vnc_rfb
      -orig-id: PROTO_VNC_RFB
    23:
      id: safe
      -orig-id: PROTO_SAFE
    24:
      id: memcached
      -orig-id: PROTO_MEMCACHED
    25:
      id: scripting
      -orig-id: PROTO_SCRIPTING
    26:
      id: versioning
      -orig-id: PROTO_VERSIONING
    27:
      id: coap
      -orig-id: PROTO_COAP
    28:
      id: telnet
      -orig-id: PROTO_TELNET
    29:
      id: rdp
      -orig-id: PROTO_RDP
    30:
      id: http_server
      -orig-id: PROTO_HTTP_SERVER
    31:
      id: end_of_list
      -orig-id: PROTO_end_of_list
