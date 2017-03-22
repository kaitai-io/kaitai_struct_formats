meta:
  id: pci_expansion_rom_header
  application: x86 architecture
  endian: le
  license: Unlicense
  imports:
    - ./bios_header_generic
    - /executable/BIOS/pci_data_struct
    - /executable/BIOS/legacy_option_rom_header
doc: >
  Spec:
    Plug and Play BIOS Specification Version 1.0A May 5, 1994, 3.1 Option ROM Header
    BIOS Boot Specification Version 1.01 January 11, 1996, Appendix A: Data Structures, A.2 PnP Option ROM Header
doc-ref:
  - http://download.intel.com/support/motherboards/desktop/sb/pnpbiosspecificationv10a.pdf
  - http://www.scs.stanford.edu/05au-cs240c/lab/specsbbs101.pdf
seq:
  - id: signature
    contents : [0x55, 0xAA]
    doc: "All ISA expansion ROMs are currently required to identify themselves with a signature WORD of AA55h at offset 0. This signature is used by the System BIOS as well as other software to identify that an Option ROM is present at a given address"
  - id: impl_defined
    type: legacy_option_rom_header
  - id: data_struct_ptr
    type: pci_data_struct_ptr
  - id: exp_hdr_ptr
    type: header_ptr
    doc: "This location contains a pointer to a linked list of Option ROM expansion headers. Various Expansion Headers (regardless of their type) may be chained together and accessible via this pointer. The offset specified in this field is the offset from the start of the option ROM header."
