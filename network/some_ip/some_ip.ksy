meta:
  id: some_ip
  title: AUTOSAR SOME/IP
  license: CC0-1.0
  ks-version: 0.9
  endian: be
  imports:
    - /network/some_ip/some_ip_sd

doc: |
  SOME/IP (Scalable service-Oriented MiddlewarE over IP) is an automotive/embedded
  communication protocol which supports remoteprocedure calls, event notifications
  and the underlying serialization/wire format.

doc-ref: https://www.autosar.org/fileadmin/user_upload/standards/foundation/19-11/AUTOSAR_PRS_SOMEIPProtocol.pdf

seq:
  - id: header
    type: header
  - id: payload
    size: header.length - 8
    type:
      switch-on: header.message_id.value
      cases:
        0xffff8100: some_ip_sd

types:
  header:
    seq:
      - id: message_id
        type: message_id
        size: 4
        doc: |
          The Message ID shall be a 32 Bit identifier that is used to identify
          the RPC call to a method of an application or to identify an event.
      - id: length
        type: u4
        doc: |
          [PRS_SOMEIP_00042] Length field shall contain the length in Byte
          starting from Request ID/Client ID until the end of the SOME/IP message.
      - id: request_id
        type: request_id
        size: 4
        doc: |
          The Request ID allows a provider and subscriber to differentiate
          multiple parallel uses of the same method, event, getter or setter.
      - id: protocol_version
        type: u1
        doc: |
          The Protocol Version identifies the used SOME/IP Header format
          (not including the Payload format).
      - id: interface_version
        type: u1
        doc: |
          Interface Version shall be an 8 Bit field that contains the
          MajorVersion of the Service Interface.
      - id: message_type
        type: u1
        enum: message_type_enum
        doc: |
          The Message Type field is used to differentiate different types of
          messages.
        doc-ref: AUTOSAR_PRS_SOMEIPProtocol.pdf - Table 4.4
      - id: return_code
        type: u1
        enum: return_code_enum
        doc: |
          The Return Code shall be used to signal whether a request was
          successfully processed.
        doc-ref: AUTOSAR_PRS_SOMEIPProtocol.pdf - Table 4.5

    types:
      message_id:
        seq:
          - id: service_id
            type: u2
            doc: Service ID
          - id: sub_id
            type: b1
            doc: Single bit to flag, if there is a Method or a Event ID
          - id: method_id
            type: b15
            if: sub_id == false
            doc: Method ID
            doc-ref: AUTOSAR_PRS_SOMEIPProtocol.pdf - Table 4.1.
          - id: event_id
            type: b15
            if: sub_id == true
            doc: Event ID
            doc-ref: AUTOSAR_PRS_SOMEIPProtocol.pdf - Table 4.6
        doc: |
          [PRS_SOMEIP_00035] The assignment of the Message ID shall be up to
          the user. However, the Message ID shall be unique for the whole
          system (i.e. the vehicle). TheMessage ID is similar to a CAN ID and
          should be handled via a comparable process.
          [PRS_SOMEIP_00038] Message IDs of method calls shall be structured in
          the ID with 2^16 services with 2^15 methods.
        doc-ref: AUTOSAR_PRS_SOMEIPProtocol.pdf 4.1.1.1  Message ID

        instances:
          value:
            pos: 0
            type: u4
            doc: The value provides the undissected Message ID

      request_id:
        seq:
          - id: client_id
            type: u2
          - id: session_id
            type: u2
        doc: |
          The Request ID allows a provider and subscriber to differentiate
          multiple parallel usesof the same method, event, getter or setter.
        doc-ref: AUTOSAR_PRS_SOMEIPProtocol.pdf - section 4.1.1.3  Request ID

        instances:
          value:
            pos: 0
            type: u4
            doc: The value provides the undissected Request ID

    instances:
      is_valid_service_discovery:
        value: message_id.value == 0xffff8100 and protocol_version == 0x01 and interface_version == 0x01 and message_type == message_type_enum::notification and return_code == return_code_enum::ok
        doc: auxillary value
        doc-ref: AUTOSAR_PRS_SOMEIPServiceDiscoveryProtocol.pdf - section 4.1.2.1 General Requirements

    enums:
      message_type_enum:
        0x00 : request
        0x01 : request_no_return
        0x02 : notification
        0x40 : request_ack
        0x41 : request_no_return_ack
        0x42 : notification_ack
        0x80 : response
        0x81 : error
        0xc0 : response_ack
        0xc1 : error_ack

      return_code_enum:
        0x00 : ok
        0x01 : not_ok
        0x02 : unknown_service
        0x03 : unknown_method
        0x04 : not_ready
        0x05 : not_reachable
        0x06 : time_out
        0x07 : wrong_protocol_version
        0x08 : wrong_interface_version
        0x09 : malformed_message
        0x0a : wrong_message_type
