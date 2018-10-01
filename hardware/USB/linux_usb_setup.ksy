meta:
  id: linux_usb_setup
  license: GPL-2.0
  endian: le
seq:
  - id: s
    size: 8
    type:
      switch-on: 0
      cases:
        1: iso_rec
        0: setup[SETUP_LEN] # Only for Control S-type
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
  
  iso_rec:
    seq:
      - id: error_count
        type: s4
      - id: numdesc
        type: s4

