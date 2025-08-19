meta:
  id: usbmon
  title: usbmon capture header
  application:
    - usbmon (Linux Kernel)
    - Wireshark
  license: BSD-3-Clause
  endian: le
  imports:
    - /hardware/USB/pcap/usb_pcap_endpoint_number
doc: |
  A native pcap header of [usbmon](https://www.kernel.org/doc/Documentation/usb/usbmon.txt) part of libpcap and Linux kernel.
doc-ref:
  - https://github.com/the-tcpdump-group/libpcap/blob/ba0ef0353ed9f9f49a1edcfb49fefaf12dec54de/pcap/usb.h#L94
  - https://www.kernel.org/doc/Documentation/usb/usbmon.txt
  - https://www.kernel.org/doc/html/latest/driver-api/usb/URB.html
  - https://wiki.wireshark.org/USB

params:
  - id: header_size
    type: u1
seq:
  - id: header
    size: header_size
    type: header
  - id: data
    size: header.data_size
types:
  timestamp:
    seq:
      - id: seconds
        -orig-id: ts_sec
        type: s8
      - id: microseconds
        -orig-id: ts_usec
        type: s4
  header:
    seq:
      - id: urb_id
        -orig-id: id
        type: u8
      - id: event_type
        -orig-id: type
        type: u1
        enum: event_type
      - id: transfer_type
        -orig-id: xfer_type
        type: u1
        enum: transfer_type
      - id: endpoint_number
        -orig-id: epnum
        type: usb_pcap_endpoint_number
      - id: device_address
        -orig-id: devnum
        type: u1
      - id: bus_id
        -orig-id: busnum
        type: u2
      - id: setup_flag
        type: u1
        enum: setup_flag
      - id: data_flag
        enum: data_flag
        type: u1
      - id: timestamp
        type: timestamp
      - id: status
        type: s4
        doc: error code
      - id: urb_size
        -orig-id: |
          urb_len (Wireshark wiki, libpcap)
          length (kernel.org)
        type: s4
      - id: data_size
        -orig-id: |
          data_len (Wireshark Wiki, libpcap)
          len_cap (kernel.org)
        type: s4
      - id: setup
        type: setup
        if: setup_flag == setup_flag::relevant
    enums:
      event_type:
        0x53: submit # 'S'
        0x43: completion # 'C'
        0x45: error # 'E'
      transfer_type:
        0: isochronous
        1: interrupt
        2: control
        3: bulk
      setup_flag:
        0x00: relevant
        0x2d: irrelevant # -
      data_flag:
        0x00:
          id: urb
          -orig-id: present
        0x45: error # E
        0x3c: incoming # <
        0x3e: outgoing # >
    types:
      setup:
        doc-ref:
          - https://github.com/the-tcpdump-group/libpcap/blob/ba0ef0353ed9f9f49a1edcfb49fefaf12dec54de/pcap/usb.h#L118

        seq:
          - id: s
            size: 8
            type:
              switch-on: _parent.transfer_type == transfer_type::isochronous
              cases:
                true: iso_rec
                false: pcap_usb_setup # Only for Control S-type
          - id: interval
            type: s4
          - id: start_frame
            type: s4
          - id: copy_of_urb_transfer_flags
            -orig-id: xfer_flags
            type: s4

          - id: iso_descriptors_count
            -orig-id: ndesc
            type: s4
            doc: Actual number of ISO descriptors
        types:
          urb_transfer_flags:
            seq:
              - id: short_not_ok
                type: b1
              - id: iso_asap
                type: b1
              - id: no_transfer_dma_map
                type: b1
              - id: reserved0
                type: b2
              - id: no_fsbr
                type: b1
              - id: zero_packet
                type: b1
              - id: no_interrupt
                type: b1
              - id: free_buffer
                type: b1
              - id: dir_in
                type: b1
              - id: reserved1
                type: b6
              - id: dma_map_single
                type: b1
              - id: dma_map_page
                type: b1
              - id: dma_map_sg
                type: b1
              - id: map_local
                type: b1
              - id: setup_map_single
                type: b1
              - id: setup_map_local
                type: b1
              - id: dma_sg_combined
                type: b1
              - id: aligned_temp_buffer
                type: b1
              - id: reserved2
                type: u1

          pcap_usb_setup:
            doc: |
              USB setup header as defined in USB specification.
              Appears at the front of each Control S-type packet in DLT_USB captures.
            seq:
              - id: request_type
                -orig-id: bmRequestType
                type: u1
              - id: request
                -orig-id: bRequest
                type: u1
              - id: value
                -orig-id: wValue
                type: u2
              - id: index
                -orig-id: wIndex
                type: u2
              - id: length
                -orig-id: wLength
                type: u2

          iso_rec:
            doc: Information from the URB for Isochronous transfers
            doc-ref: https://github.com/the-tcpdump-group/libpcap/blob/ba0ef0353ed9f9f49a1edcfb49fefaf12dec54de/pcap/usb.h#L70
            seq:
              - id: error_count
                type: s4
              - id: descriptors_count
                -orig-id: numdesc
                type: s4
