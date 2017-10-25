meta:
  id: usbpcap
  title: usbpcap capture header
  application:
    - usbpcap
  license: Unlicense
  endian: le
  imports:
    - /hardware/USB/windows_urb
    - /hardware/USB/pcap/endpoint_number
    #- /hardware/USB/usbd_status
doc: |
  A native pcap header of [usbpcap](https://github.com/desowin/usbpcap) - an app to capture USB frames in Windows OSes.
doc-ref: http://desowin.org/usbpcap/captureformat.html
seq:
  - id: header
    type: header
  - id: data
    size: header.header_main.data_size
types:
  usbd_status: # a temporary measure
    seq:
      - id: code
        type: u4
  header:
    seq:
      - id: header_size
        -orig-id: headerLen
        type: u2
        doc: describes the total length, in bytes, of the header (including all transfer-specific header data).
      - id: header_main
        size: header_size - 2
        type: header_main
    types:
      header_main:
        seq:
          - id: io_request_packet_id
            -orig-id: irpId
            type: u8
            doc: |
              is merely a pointer to IRP casted to the UINT64. This value can be used to match the request with the response.
          - id: usbd_status_code
            type: usbd_status
            doc: |
              USB status code is valid only on return from host-controller.
          - id: urb_function
            type: u2
            #enum: usb_request_block.urb_function
          - id: io_request_info
            -orig-id: info
            type: info
          - id: bus
            type: u2
            doc: bus (RootHub) number is the root hub identifier used to distingush between multiple root hubs.
          - id: device_address
            -orig-id: device
            type: u2
            doc: |
              is USB device number. This field is, contary to the USB specification, 16-bit because the Windows uses 16-bits value for that matter. Check DeviceAddress field of [USB_NODE_CONNECTION_INFORMATION](http://msdn.microsoft.com/en-us/library/windows/hardware/ff540090(v=vs.85).aspx)
          - id: endpoint_number
            type: endpoint_number
          - id: transfer_type
            -orig-id: transfer
            type: u1
            enum: transfer_type
            doc: transfer type determines the transfer type and thus the header type. See below for details.
          - id: data_size
            -orig-id: dataLength
            type: u4
            doc: specifies the total length of transfer data to follow directly after the header
          - id: additional_header
            size-eos: true
            type:
              switch-on: transfer_type
              cases:
                "transfer_type::isochronous": isoch_header
                "transfer_type::control": control_header
        types:
          info:
            seq:
              - id: reserved
                type: b7
                doc: must be set to 0.
              - id: pdo_to_fdo
                type: b1
                doc: it is 0 when IRP goes from FDO to PDO, 1 the other way round.
          isoch_header:
            seq:
              - id: start_frame
                type: u8
              - id: packet_count
                -orig-id: numberOfPackets
                type: u8
              - id: error_count
                type: u8
              - id: packet
                type: isoch_packet
            types:
              isoch_packet:
                seq:
                  - id: offset
                    type: u8
                  - id: size
                    -orig-id: length
                    type: u8
                  - id: status
                    type: usbd_status
          control_header:
            seq:
              - id: stage
                type: u1
                enum: stage
            enums:
              stage:
                0: setup
                1: data
                2: status
        enums:
          transfer_type:
            0: isochronous
            1: interrupt
            2: control
            3: bulk
