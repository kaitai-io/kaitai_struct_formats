meta:
  id: vendor
  endian: le
  license: 0BSD

doc: Vendor specific PCI capability

doc-ref: |
  PCI LOCAL BUS SPECIFICATION, REV. 3.0
  p330, H. Capability IDs

seq:
  # length of capability structure, starting from capid
  - id: length
    type: u1
  - id: data
    size: length - 3
