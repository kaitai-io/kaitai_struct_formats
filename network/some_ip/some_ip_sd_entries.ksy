meta:
  id: some_ip_sd_entries
  title: AUTOSAR SOME/IP Service Discovery Entries
  license: CC0-1.0
  ks-version: 0.9
  endian: be

doc: |
  The entries are used to synchronize the state of services instances and the
  Publish/-Subscribe handling.
doc-ref: |
  https://www.autosar.org/fileadmin/user_upload/standards/foundation/19-11/AUTOSAR_PRS_SOMEIPServiceDiscoveryProtocol.pdf
  - section 4.1.2.3  Entry Format

seq:
  - id: entries
    type: sd_entry
    repeat: eos

types:
  sd_entry:
    seq:
    - id: header
      type: sd_entry_header
    - id: content
      type:
        switch-on: header.type
        cases:
          entry_types::find : sd_service_entry
          entry_types::offer : sd_service_entry
          entry_types::subscribe : sd_eventgroup_entry
          entry_types::subscribe_ack : sd_eventgroup_entry

    types:
      sd_entry_header:
        seq:
          - id: type
            type: u1
            enum: entry_types
          - id: index_first_options
            type: u1
          - id: index_second_options
            type: u1
          - id: number_first_options
            type: b4
          - id: number_second_options
            type: b4
          - id: service_id
            type: u2
          - id: instance_id
            type: u2
          - id: major_version
            type: u1
          - id: ttl
            type: b24

      sd_service_entry:
        seq:
          - id: minor_version
            type: u4

      sd_eventgroup_entry:
        seq:
          - id: reserved
            type: u1
          - id: initial_data_requested
            type: b1
          - id: reserved2
            type: b3
          - id: counter
            type: b4
          - id: event_group_id
            type: u2

    enums:
      entry_types:
        0x00 : find
        0x01 : offer
        0x06 : subscribe
        0x07 : subscribe_ack
