meta:
  id: bluetooth_att
  title: Bluetooth ATT (IEEE 802.15.1)
  xref:
    ieee: 802.15.1
  license: CC0-1.0
  ks-version: 0.8
  endian: le
doc: |
  Bluetooth ATT is a part of the Bluetooth specification.
  Attribute Profile, page 2288
doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080

seq:
  - id: opcode
    type: u1
    enum: att_opcode
    doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080 page 2330
  - id: parameters
    type:
      switch-on: opcode
      cases:
        'att_opcode::error_response': error_response
        'att_opcode::find_information_request': read_by_type_request
        'att_opcode::find_information_response': find_information_response
        'att_opcode::read_by_type_request': read_by_type_request
        'att_opcode::read_by_type_response': read_by_type_response
        'att_opcode::read_by_group_type_request': read_by_type_request
        'att_opcode::read_by_group_type_response': read_by_type_response
        'att_opcode::write_request': write_request
        'att_opcode::handle_value_notification': write_request

enums:
  # 3.4.8 Attribute Opcode summary, page 2330
  att_opcode:
    # 0x00 illegal
    0x01: error_response
    0x02: exchange_mtu_request
    0x03: exchange_mtu_response
    0x04: find_information_request
    0x05: find_information_response
    0x06: find_by_type_value_request
    0x07: find_by_type_value_response
    0x08: read_by_type_request
    0x09: read_by_type_response
    0x0a: read_request
    0x0b: read_response
    0x0c: read_blob_request
    0x0d: read_blob_response
    0x0e: read_multiple_request
    0x0f: read_multiple_response
    0x10: read_by_group_type_request
    0x11: read_by_group_type_response
    0x12: write_request
    0x13: write_response
    0x52: write_command
    0x16: prepare_write_request
    0x17: prepare_write_response
    0x18: execute_write_request
    0x19: execute_write_response
    0x1b: handle_value_notification
    0x1d: handle_value_indication
    0x1e: handle_value_confirmation
    0xd2: signed_write_command

types:
  error_response:
    doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080 page 2301
    seq:
      - id: request_opcode_in_error
        type: u1
      - id: attribute_handle_in_error
        type: u2
      - id: error_code
        type: u1
  find_information_response:
    doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080 page 2306
    seq:
      - id: format
        type: u1
      - id: information_data
        size-eos: true
  read_by_type_request:
    # also for
    #   find_information_request
    #   read_by_group_type_request
    doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080 page 2310
    seq:
      - id: starting_handle
        type: u2
      - id: ending_handle
        type: u2
      - id: attribute_type_bytes
        size-eos: true
  read_by_type_response:
    # also for
    #  read_by_group_type_response
    doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080 page 2312
    seq:
      - id: length
        type: u1
      - id: attribute_data_list_bytes
        size-eos: true
  write_request:
    # also for
    #  handle_value_notification
    doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080 page 2320
    seq:
      - id: attribute_handle
        type: u2
      - id: attribute_value_bytes
        size-eos: true
