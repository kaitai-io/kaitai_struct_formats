meta:
  id: msix
  endian: le
  license: 0BSD

doc: MSI-X PCI capability

doc-ref: |
  PCI LOCAL BUS SPECIFICATION, REV. 3.0
  p238, 6.8.2. MSI-X Capability and Table Structures

# TODO: check PCIe spec

seq:
  - id: message_control
    type: message_control
  - id: table
    type: offset
  - id: pba
    type: offset

types:
  message_control:
    seq:
      # bits 7:0
      - id: table_size_lower
        type: u1
      # bits 15:8
      - id: msix_enable
        type: b1
      - id: function_mask
        type: b1
      - id: reserved
        type: b3
      - id: table_size_upper
        type: b3
    instances:
      table_size:
        value: table_size_lower | (table_size_upper << 8)

  offset:
    seq:
      - id: dword
        type: u4
    instances:
      # QWORD aligned bar offset
      offset:
        value: dword & 0xfffffff8
      # BAR Indicator Register
      bir:
        value: dword & 0x7
      # TODO: plug bar type here
      bar_offset:
        value: bir * 0x4 + 0x10
        # values 6 and 7 are reserved
        if: bir < 6
