meta:
  id: usbpcap
  title: usbpcap capture header
  application:
    - usbpcap
  license: Unlicense
  endian: le
  -affected-by: [651, 703]
  imports:
    #- /hardware/USB/usb_urb_windows
    - /hardware/USB/pcap/usb_pcap_endpoint_number
    - /hardware/USB/usbd_status_windows
doc: |
  A native pcap header of [usbpcap](https://github.com/desowin/usbpcap) - an app to capture USB frames in Windows OSes.
doc-ref: https://desowin.org/usbpcap/captureformat.html
seq:
  - id: header
    type: header
  - id: data
    size: data_size
instances:
  available_size:
    value: _io.size - header.header_size
  is_truncated:
    value: header.header_main.data_size > available_size
  data_size:
    value: is_truncated?available_size:header.header_main.data_size
types:
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
          - id: usbd_status_windows_code
            -orig-id:
              - usbd_status
              - status
            type: usbd_status_windows
            doc: |
              USB status code is valid only on return from host-controller.
          - id: urb_function
            -orig-id: function
            type: u2
            #enum: usb_urb_windows::urb_function
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
              is USB device number. This field is, contary to the USB specification, 16-bit because the Windows uses 16-bits value for that matter. Check DeviceAddress field of [USB_NODE_CONNECTION_INFORMATION](https://msdn.microsoft.com/en-us/library/windows/hardware/ff540090(v=vs.85).aspx)
          - id: endpoint_number
            -orig-id: endpoint
            type: usb_pcap_endpoint_number
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
                transfer_type::isochronous: isoch_header
                transfer_type::control: control_header
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
                    type: usbd_status_windows
          control_header:
            seq:
              - id: stage
                type: u1
                enum: stage
            enums:
              stage:
                0:
                  id: setup
                  -orig-id: USBPCAP_CONTROL_STAGE_SETUP
                1:
                  id: data
                  -orig-id: USBPCAP_CONTROL_STAGE_DATA
                2:
                  id: status
                  -orig-id: USBPCAP_CONTROL_STAGE_STATUS
                3:
                  id: complete
                  -orig-id: USBPCAP_CONTROL_STAGE_COMPLETE
        enums:
          transfer_type:
            0:
              id: isochronous
              -orig-id: USBPCAP_TRANSFER_ISOCHRONOUS
            1:
              id: interrupt
              -orig-id: USBPCAP_TRANSFER_INTERRUPT
            2:
              id: control
              -orig-id: USBPCAP_TRANSFER_CONTROL
            3:
              id: bulk
              -orig-id: USBPCAP_TRANSFER_BULK
            0xFE:
              id: irp_info
              -orig-id: USBPCAP_TRANSFER_IRP_INFO
            0xFF:
              id: unknown
              -orig-id: USBPCAP_TRANSFER_UNKNOWN

