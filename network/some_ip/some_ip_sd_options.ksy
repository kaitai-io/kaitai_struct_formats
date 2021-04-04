meta:
  id: some_ip_sd_options
  title: AUTOSAR SOME/IP Service Discovery Options
  license: CC0-1.0
  ks-version: 0.9
  endian: be

doc: |
  FormatOptions are used to transport additional information to the entries.
  This includes forinstance the information how a service instance is
  reachable (IP-Address, TransportProtocol, Port Number).
doc-ref: |
  https://www.autosar.org/fileadmin/user_upload/standards/foundation/19-11/AUTOSAR_PRS_SOMEIPServiceDiscoveryProtocol.pdf
  - section 4.1.2.4 Options Format

seq:
  - id: entries
    type: sd_option
    repeat: eos

types:
  sd_option:
    seq:
    - id: header
      type: sd_option_header
    - id: content
      type:
        switch-on: header.type
        cases:
          option_types::configuration_option : sd_configuration_option
          option_types::load_balancing_option : sd_load_balancing_option
          option_types::ipv4_endpoint_option : sd_ipv4_endpoint_option
          option_types::ipv6_endpoint_option : sd_ipv6_endpoint_option
          option_types::ipv4_multicast_option : sd_ipv4_multicast_option
          option_types::ipv6_multicast_option : sd_ipv6_multicast_option
          option_types::ipv4_sd_endpoint_option : sd_ipv4_sd_endpoint_option
          option_types::ipv6_sd_endpoint_option : sd_ipv6_sd_endpoint_option

    types:
      sd_option_header:
        seq:
          - id: length
            type: u2
          - id: type
            type: u1
            enum: option_types

      sd_configuration_option:
        seq:
          - id: reserved
            type: u1
          - id: configurations
            type: sd_config_strings_container
            size: _parent.header.length - 1

      sd_config_strings_container:
        seq:
          - id: config_strings
            type: sd_config_string
            repeat: eos

      sd_config_string:
        seq:
          - id: length
            type: u1
          - id: config
            type: sd_config_kv_pair
            size: length
            if: length != 0

      sd_config_kv_pair:
        seq:
        - id: key
          type: str
          terminator: 0x3D
          encoding: ASCII
        - id: value
          type: str
          size-eos: true
          encoding: ASCII


      sd_load_balancing_option:
        seq:
          - id: reserved
            type: u1
          - id: priority
            type: u2
          - id: weight
            type: u2

      sd_ipv4_endpoint_option:
        seq:
          - id: reserved
            type: u1
          - id: address
            size: 4
          - id: reserved2
            type: u1
          - id: l4_protocol
            type: u1
          - id: port
            type: u2

      sd_ipv6_endpoint_option:
        seq:
          - id: reserved
            type: u1
          - id: address
            size: 16
          - id: reserved2
            type: u1
          - id: l4_protocol
            type: u1
          - id: port
            type: u2

      sd_ipv4_multicast_option:
        seq:
          - id: reserved
            type: u1
          - id: address
            size: 4
          - id: reserved2
            type: u1
          - id: l4_protocol
            type: u1
          - id: port
            type: u2

      sd_ipv6_multicast_option:
        seq:
          - id: reserved
            type: u1
          - id: address
            size: 16
          - id: reserved2
            type: u1
          - id: l4_protocol
            type: u1
          - id: port
            type: u2

      sd_ipv4_sd_endpoint_option:
        seq:
          - id: reserved
            type: u1
          - id: address
            size: 4
          - id: reserved2
            type: u1
          - id: l4_protocol
            type: u1
          - id: port
            type: u2

      sd_ipv6_sd_endpoint_option:
        seq:
          - id: reserved
            type: u1
          - id: address
            size: 16
          - id: reserved2
            type: u1
          - id: l4_protocol
            type: u1
          - id: port
            type: u2

    enums:
      option_types:
        0x01 : configuration_option
        0x02 : load_balancing_option
        0x04 : ipv4_endpoint_option
        0x06 : ipv6_endpoint_option
        0x14 : ipv4_multicast_option
        0x16 : ipv6_multicast_option
        0x24 : ipv4_sd_endpoint_option
        0x26 : ipv6_sd_endpoint_option
