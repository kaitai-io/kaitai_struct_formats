meta:
  id: fastcgi
  title: FastCGI protocol
  xref:
    wikidata: Q1397631
  license: Unlicense
  endian: le

doc: |
  FastCGI is a protocol between a web server process and a process generating responses.

doc-ref:
  - https://fastcgi-archives.github.io/FastCGI_Specification.html
  - https://www.mit.edu/~yandros/doc/specs/fcgi-spec.html

seq:
  - id: records
    type: record
    repeat: eos

types:
  record:
    -orig-id:
      - FCGI_Record
      - FCGI_BeginRequestRecord
      - FCGI_EndRequestRecord
      - FCGI_UnknownTypeRecord
    seq:
      - id: header
        type: header
      - id: content_data
        -orig-id: contentData
        size: header.content_length
        type:
          switch-on: header.type
          cases:
            type::begin_request: begin
            type::end_request: end
            type::unknown: unknown
            #type::stdin: bytes
            #type::data: bytes
            #type::stdout: bytes
            #type::stderr: bytes
            type::get_values: kv_pairs
            type::get_values_result: kv_pairs
            type::params: kv_pairs
      - id: padding_data
        -orig-id: paddingData
        size: header.padding_length

    types:
      header:
        -orig-id: FCGI_Header
        seq:
          - id: version
            type: u1
            valid: 1
          - id: type
            type: u1
            enum: type
          - id: request_id
            -orig-id: requestId
            type: s2
          - id: content_length
            -orig-id: contentLength
            type: u2
          - id: padding_length
            -orig-id: paddingLength
            type: u1
          - id: reserved
            -orig-id: reserved
            type: u1

      unknown:
        -orig-id: FCGI_UnknownTypeBody
        seq:
          - id: type
            type: u1
          - id: reserved
            size: 7
          - id: rest
            size-eos: true

      begin:
        -orig-id: FCGI_BeginRequestBody
        seq:
          - id: role_b1
            -orig-id:
              - roleB1
              - roleB2
            type: u2
            enum: role
          - id: flags
            type: u1
          - id: reserved
            size: 5
        types:
          flags:
            seq:
              - id: reserved
                type: b7
              - id: should_keep_connection
                -orig-id: FCGI_KEEP_CONN
                type: b1
                doc: Should the app close the connection
        enums:
          role:
            1:
              id: responder
              -orig-id: FCGI_RESPONDER
              doc: does access control and generates responses.
            2:
              id: authorizer
              -orig-id: FCGI_AUTHORIZER
              doc: decides if authorized
            3:
              id: filter
              -orig-id: FCGI_FILTER
              doc: generates responses. Access control is implemented in authorizer.

      end:
        -orig-id: FCGI_EndRequestBody
        seq:
          - id: app_status
            -orig-id: appStatus
            type: u4
          - id: protocol_status
            -orig-id: protocolStatus
            type: u1
            enum: protocol_status
          - id: reserved
            size: 3
        enums:
          protocol_status:
            0:
              id: request_complete
              -orig-id: FCGI_REQUEST_COMPLETE
              doc: normal end of request.
            1:
              id: cant_multiplex_connection
              -orig-id: FCGI_CANT_MPX_CONN
              doc: Connection is rejected because multiplexing is not supported by the client
            2:
              id: overloaded
              -orig-id: FCGI_OVERLOADED
              doc: Denial of service
            3:
              id: unknown_role
              -orig-id: FCGI_UNKNOWN_ROLE

      kv_pairs:
        seq:
          - id: pairs
            type: kv_pair
            repeat: eos
        types:
          kv_pair:
            -orig-id:
              - FCGI_NameValuePair11
              - FCGI_NameValuePair14
              - FCGI_NameValuePair41
              - FCGI_NameValuePair44
            seq:
              - id: key_length
                type: vli
                -orig-id: nameLength
              - id: value_length
                type: vli
                -orig-id: valueLength
              - id: key
                -orig-id: nameData
                size: key_length.value
              - id: value
                -orig-id: valueData
                size: value_length.value
            types:
              vli:
                seq:
                  - id: selector
                    type: b1
                  - id: b0
                    type: b7
                    -orig-id:
                      - nameLengthB0
                      - valueLengthB0
                  - id: b1
                    type: u1
                    if: selector
                    -orig-id:
                      - nameLengthB1
                      - valueLengthB1
                  - id: h1
                    type: u2
                    if: selector
                    -orig-id:
                      - nameLengthB2
                      - valueLengthB2
                      - nameLengthB3
                      - valueLengthB3
                instances:
                  value:
                    value: "selector ? ((b0 << 24) | (b1 << 16) | h1) : b0"

    enums:
      type:
        1:
          id: begin_request
          -orig-id: FCGI_BEGIN_REQUEST
        2:
          id: abort_request
          -orig-id: FCGI_ABORT_REQUEST
        3:
          id: end_request
          -orig-id: FCGI_END_REQUEST
        4:
          id: params
          -orig-id: FCGI_PARAMS
        5:
          id: stdin
          -orig-id: FCGI_STDIN
        6:
          id: stdout
          -orig-id: FCGI_STDOUT
        7:
          id: stderr
          -orig-id: FCGI_STDERR
        8:
          id: data
          -orig-id: FCGI_DATA
        9:
          id: get_values
          -orig-id: FCGI_GET_VALUES
        10:
          id: get_values_result
          -orig-id: FCGI_GET_VALUES_RESULT
        11:
          id: unknown_type
          -orig-id: FCGI_UNKNOWN_TYPE
        12:
          id: max_type
          -orig-id: FCGI_MAXTYPE
