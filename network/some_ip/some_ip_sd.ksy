meta:
  id: some_ip_sd
  title: AUTOSAR SOME/IP Service Discovery
  license: CC0-1.0
  ks-version: 0.9
  endian: be
  imports:
    - /network/some_ip/some_ip_sd_entries
    - /network/some_ip/some_ip_sd_options

doc: |
  The main tasks of the Service Discovery Protocol are communicating the
  availability of functional entities called services in the in-vehicle
  communication as well as controlling the send behavior of event messages.
  This allows sending only event messages to receivers requiring them (Publish/Subscribe).
  The solution described here is also known as SOME/IP-SD
  (Scalable service-Oriented MiddlewarE over IP - Service Discovery).
doc-ref: https://www.autosar.org/fileadmin/user_upload/standards/foundation/19-11/AUTOSAR_PRS_SOMEIPServiceDiscoveryProtocol.pdf

seq:
  - id: flags
    type: sd_flags
    doc: The SOME/IP-SD Header shall start with an 8 Bit field called flags.
  - id: reserved
    size: 3
  - id: len_entries
    type: u4
  - id: entries
    type: some_ip_sd_entries
    size: len_entries
  - id: len_options
    type: u4
  - id: options
    type: some_ip_sd_options
    size: len_options

types:
  sd_flags:
    seq:
      - id: reboot
        type: b1
      - id: unicast
        type: b1
      - id: initial_data
        type: b1
      - id: reserved
        type: b5
    doc-ref: AUTOSAR_PRS_SOMEIPServiceDiscoveryProtocol.pdf - Figure 4.3
