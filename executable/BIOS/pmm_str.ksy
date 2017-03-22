meta:
  id: pmm_str
  title: POST Memory Manager Services structure
  application: x86 architecture
  endian: le
  license: Unlicense
doc-ref: ftp://ftp.software.ibm.com/eserver/pseries/chrptech/1394ohci/bios2.pdf
seq:
  - id: structure_revision
    type: u1
    doc: "This is an ordinal value that indicates the revision number of this structure only and does not imply a level of compliance with the Plug and Play BIOS version."
  - id: length_16
    type: u1
    doc: "Length of the entire Expansion Header expressed in sixteen byte blocks. The length count starts at the Signature field."
  - id: checksum
    type: u1
    doc: "Each Expansion Header is checksummed individually. This allows the software which wishes to make use of an expansion header (in this case, the system BIOS) the ability to determine if the expansion header is valid. The method for validating the checksum is to add up all byte values in the Expansion Header, including the Checksum field, into an 8-bit value. A resulting sum of zero indicates a valid checksum operation."
  - id: entry_point
    type: u4
    doc: "Segment:offset of PMM Services entry point."
  - id: reserved
    size: 5
instances:
  length:
    value: length_16 * 16
