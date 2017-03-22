meta:
  id: smbios32
  title: SMBIOS32
  application: x86 architecture
  endian: le
  license: Unlicense
doc-ref: "https://www.dmtf.org/sites/default/files/standards/documents/DSP0134_3.1.1.pdf"
seq:
- id: checksum
  type: u1
  doc: "Checksum of the Entry Point Structure (EPS). This value, when added to all other bytes in the EPS, results in the value 00h (using 8-bit addition calculations). Values in the EPS are summed starting at offset 00h, for Entry Point Length bytes."
- id: length
  type: u1
  doc: "Length of the Entry Point Structure, starting with the Anchor String field, in bytes, currently 1Fh. NOTE: This value was incorrectly stated in version 2.1 of this specification as 1Eh. Because of this, there might be version 2.1 implementations that use either the 1Eh or the 1Fh value, but version 2.2 or later implementations must use the 1Fh value."
- id: major_version
  type: u1
  doc: "Major version of this specification implemented in the table structures (for example, the value is 0Ah for revision 10.22 and 02h for revision 2.1)"
- id: minor_version
  type: u1
  doc: "Minor version of this specification implemented in the table structures (for example, the value is 16h for revision 10.22 and 01h for revision 2.1)"
- id: max_structure_size
  type: u2
  doc: "Size of the largest SMBIOS structure, in bytes, and encompasses the structure’s formatted area and text strings"
- id: entry_point_revision
  type: u1
  enum: eps_revision
- id: formatted_area
  size: 5
  doc: "Value present in the Entry Point Revision field defines the interpretation to be placed upon these 5 bytes"
- id: ieps
  type: ieps
types:
  smbios_table:
    seq:
    - id: entries
      type: smbios_structure
      repeat: expr
      repeat-expr: ieps.number_of_structures
    types:
      smbios_structure:
        seq:
        - id: type
          type: u1
          doc: "Specifies the type of structure. Types 0 through 127 (7Fh) are reserved for and defined by this specification. Types 128 through 256 (80h to FFh) are available for system- and OEM-specific information."
        - id: len
          type: u1
          doc: "Specifies the length of the formatted area of the structure, starting at the Type field. The length of the structure’s string-set is not included."
        - id: handle
          type: u2
          doc: "Specifies the structure’s handle, a unique 16-bit number in the range 0 to 0FFFEh (for version 2.0) or 0 to 0FEFFh (for version 2.1 and later). The handle can be used with the Get SMBIOS Structure function to retrieve a specific structure; the handle numbers are not required to be contiguous. For version 2.1 and later, handle values in the range 0FF00h to 0FFFFh are reserved for use by this specification. If the system configuration changes, a previously assigned handle might no longer exist. However, after a handle has been assigned by the BIOS, the BIOS cannot re-assign that handle number to another structure."
        - id: data
          doc: "Without strings"
          size: len - 4
        - id: strings
          type: strz
          encoding: ASCII
          repeat: until
          repeat-until: _ == ""
  ieps:
    seq:
    - id: signature
      type: str
      size: 5
      encoding: ASCII
      contents: "_DMI_"
    - id: checksum
      type: u1
      doc: "Checksum of Intermediate Entry Point Structure (IEPS). This value, when added to all other bytes in the IEPS, results in the value 00h (using 8-bit addition calculations). Values in the IEPS are summed starting at offset 10h, for 0Fh bytes."
    - id: structure_table_length
      type: u2
      doc: "Total length of SMBIOS Structure Table, pointed to by the Structure Table Address, in bytes"
    - id: structure_table_address
      type: u4
      doc: "32-bit physical starting address of the read-only SMBIOS Structure Table, which can start at any 32-bit address This area contains all of the SMBIOS structures fully packed together. These structures can then be parsed to produce exactly the same format as that returned from a Get SMBIOS Structure function call."
    - id: number_of_structures
      type: u2
      doc: "Total number of structures present in the SMBIOS Structure Table. This is the value returned as NumStructures from the Get SMBIOS Information function."
    - id: bcd_revision
      type: u1
      doc: "Indicates compliance with a revision of this specification It is a BCD value where the upper nibble indicates the major version and the lower nibble the minor version. For revision 2.1, the returned value is 21h. If the value is 00h, only the Major and Minor Versions in offsets 6 and 7 of the Entry Point Structure provide the version information."
instances:
  table:
    type: smbios_table
    size: ieps.structure_table_length
enums:
  eps_revision:
    0x00: SMBIOS_21 #Entry Point is based on SMBIOS 2.1 definition; formatted area is reserved and set to all 00h.

