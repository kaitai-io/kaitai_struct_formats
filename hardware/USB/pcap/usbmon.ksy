meta:
  id: usbmon
  title: usbmon capture header
  application:
    - usbmon (Linux Kernel)
    - Wireshark
  license: Unlicense
  endian: le
  imports:
    - /hardware/USB/pcap/endpoint_number
    - /hardware/USB/linux_usb_setup
doc: |
  A native pcap header of [usbmon](https://www.kernel.org/doc/Documentation/usb/usbmon.txt) part of Linux kernel.
doc-ref: |
  https://www.kernel.org/doc/Documentation/usb/usbmon.txt
  https://www.kernel.org/doc/html/latest/driver-api/usb/URB.html
  https://wiki.wireshark.org/USB
params:
  - id: header_size
    type: u1
seq:
  - id: header
    size: header_size
    type: header
  - id: data
    size: header.data_size
    doc: |
      For Linux kernel versions less than 2.6.21-rc1 the USB data is provided by means of a 'text' API, which limits the storage for captured data to 32 bytes. This kind of API requires debugfs to be mounted in /sys/kernel/debug in order to be functional. Recently a new 'binary' API as been added to the Linux kernel, removing any restriction on the amount of capturable data for each URB. This new API is available in the Linux kernel starting from version 2.6.21-rc1.
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
    doc: |
      The header, except for the 'setup' field, is in host byte order.
    seq:
      - id: urb_id
        -orig-id: id
        type: u8
        doc: used to link a 'submit' event with its coupled 'completion' or 'error' event. 
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
        type: endpoint_number
      - id: device_address
        -orig-id: devnum
        type: u1
      - id: bus_id
        -orig-id: busnum
        type: u2
      - id: setup_flag
        -orig-id: flag_setup
        type: u1
        enum: setup_flag
        doc: "If the 'setup_flag' is 0, than the setup data is valid. If the 'data_flag' is 0, then this header is followed by the data with the associated URB. In an error event, the 'status' field specifies the error code."
      - id: data_flag
        -orig-id: flag_data
        enum: data_flag
        type: u1
      - id: timestamp
        type: timestamp
      - id: status
        type: s4
      - id: urb_size
        -orig-id: |
          urb_len (Wireshark wiki)
          length (kernel.org)
        type: s4
      - id: data_size
        -orig-id: |
          data_len (Wireshark Wiki)
          len_cap (kernel.org)
        type: s4
      - id: setup
        type: linux_usb_setup
        doc: |
          The setup structure follows the USB specification for the setup header and thus is in little endian byte order. The USB data is present only in one of two events associated with an URB. If the transfer direction is from the host to the device, the data is present in the 'submit' event, otherwise the data is present in the 'completion' event. The amount of data effectively present into the event can be less than the amount of data effectively exchanged.
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
        0x00: present
        0x45: error # E
        0x3c: incoming # <
        0x3e: outgoing # >
