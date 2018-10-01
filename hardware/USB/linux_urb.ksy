meta:
  id: linux_urb
  license: GPL-2.0
  endian: le
seq:
  - id: usb_device
    type: ptr
    doc: pointer to associated USB device
  - id: pipe
    type: u4
    doc: endpoint information
  - id: transfer_flags
    type: u4
    doc: URB_ISO_ASAP, URB_SHORT_NOT_OK, etc.
  - id: context
    type: ptr
    doc: pointer to context for completion routine
  - id: complete
    type: ptr
    doc: pointer to completion routine
  - id: status
    type: u4
    doc: returned status
  - id: transfer_buffer
    type: ptr
    doc: associated data buffer
  - id: transfer_buffer_length
    type: u4
    doc: data buffer length
  - id: number_of_packets
    type: s4
    doc: size of iso_frame_desc
  - id: actual_length
    type: u4
    doc: |
      actual data buffer length
      sometimes only part of CTRL/BULK/INTR transfer_buffer is used
  - id: setup_packet
    type: ptr
    doc: setup packet (control only)
  - id: start_frame
    type: s4
    doc: start frame
  - id: interval
    type: s4
    doc: polling interval
  - id: error_count
    type: s4
    doc: number of errors
  - id: iso_frame_desc
    type: usb_iso_packet_descriptor
types:
  ptr:
    seq:
      - id: ptr
        type: u8