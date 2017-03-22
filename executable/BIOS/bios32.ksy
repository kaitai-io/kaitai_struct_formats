meta:
  id: bios32
  title: legacy BIOS
  application: x86 architecture
  endian: le
  license: Unlicense
doc-ref: http://bos.asmhackers.net/docs/pci/docs/bios32.pdf
seq:
  - id: entry_point
    type: u4
    doc: "The entry point for the BIOS32 Service Directory Calling Interface.  This is a 32-bit linear physical address."
  - id: rev
    type: u1
    doc: "The revision level of the BIOS32 Service Directory Header and Calling Interface."
  - id: len
    type: u1
    doc: "The length of the BIOS32 Service Directory Header.  This is measured in units of paragraphs (16 bytes)."
  - id: checksum
    type: u1
    doc: "The BIOS32 Service Directory Header checksum which makes the cumulative ADD value of all bytes in the Header equal to 0h."
  - id: reserved
    size: 5
