meta:
  id: acpi
  title: ACPI table header
  license: Unlicense
  ks-version: 0.9
  bit-endian: le
  encoding: ascii
  endian: le
  imports:
    - ./windows_platform_binary_table

seq:
  - id: header
    type: header
  - id: payload
    size: header.length - sizeof<header>
    type:
      switch-on: header.signature
      cases:
        '"WPBT"': windows_platform_binary_table

types:
  header:
    seq:
      - id: signature
        size: 4
        type: str
      - id: length
        -orig-id: Length
        type: u4
      - id: revision
        type: u1
      - id: checksum
        -orig-id: 
        type: u1
        doc: Must be so that the entire table sums to 0
      - id: oem_id
        -orig-id: OEMID
        size: 6
      - id: oem_table_id
        -orig-id: OEM Table ID
        size: 8
        doc: Manufacturer model ID.
      - id: oem_revision
        -orig-id: OEM Revision
        type: u4
        doc: OEM revision for supplied OEM table ID.
      - id: creator_id
        -orig-id: Creator ID
        size: 4
        doc: Vendor ID of the utility that created the table.
      - id: creator_revision
        -orig-id: Creator Revision
        type: u4
        doc: Revision of the utility that created the table.
