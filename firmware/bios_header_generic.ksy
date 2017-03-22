meta:
  id: header_generic
  title: Expansion header
  application: x86 architecture
  endian: le
  license: Unlicense
  imports:
    - ./pirt
    - ./smbios32
    - /executable/BIOS/pnp_hdr
    - /executable/BIOS/pmm_str
    - /executable/BIOS/bios32
doc: "Selects the right header body type based on signature"
seq:
  - id: signature
    type: str
    encoding: ASCII
    size: 4
    doc: "All Expansion Headers will contain a unique expansion header identifier. Each different Expansion Header will have its own unique signature. Software that wishes to make use of any given Expansion Header simply traverses the linked list of Generic Expansion Headers until the Expansion Header with the desired signature is found, or the end of the list is encountered. Example: The Plug and Play expansion header's identifier is the ASCII string \"$PnP\" or hex 24 50 6E 50h."
  - id: data
    type:
      switch-on: signature
      cases:
        '"$PnP"': pnp_hdr
        '"$PMM"': pmm_str
        '"_32_"': bios32
        '"$PIR"': pirt
        '"_SM_"': smbios32
types:
  header_ptr:
    seq:
      - id: next_header
        type: u2
        doc: "This location contains a link to the next expansion ROM header in this Option ROM. If there are no other expansion ROM headers, then this field will have a value of 0h. The offset specified in this field is the offset from the start of the option ROM header."
    instances:
      next_hdr:
        pos: next_header
        type: header_generic
        if: next_header != 0