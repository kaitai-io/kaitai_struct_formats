meta:
  id: legacy_option_rom_header
  title: Legacy Option ROM header
  application: x86 architecture
  endian: le
  license: Unlicense
doc: >
  Spec:
    Plug and Play BIOS Specification Version 1.0A May 5, 1994, 3.1 Option ROM Header
    BIOS Boot Specification Version 1.01 January 11, 1996, Appendix A: Data Structures, A.2 PnP Option ROM Header
doc-ref:
  - http://download.intel.com/support/motherboards/desktop/sb/pnpbiosspecificationv10a.pdf
  - http://www.scs.stanford.edu/05au-cs240c/lab/specsbbs101.pdf
seq:
  - id: optrom_len
    type: u1
    doc: "The length of the option ROM in 512 byte increments. The size includes this header."
  - id: init_vec
    type: u4
    doc: "The system BIOS will execute a FAR CALL to this location to initialize the Option ROM. A Plug and Play System BIOS will identify itself to a Plug and Play Option ROM by passing a pointer to a Plug and Play Identification structure when it calls the Option ROM's initialization vector. If the Option ROM determines that the System BIOS is a Plug and Play BIOS, the Option ROM should not hook the input, display, or IPL device vectors (INT 9h, 10h, or 13h) at this time. Instead, the device should wait until the System BIOS calls the Boot Connection vector before it hooks any of these vectors. Note: A Plug and Play device should never hook INT 19h or INT 18h until its Boot Connection Vector, offset 16h of the Expansion Header Structure (section 3.2), has been called by the Plug and Play system BIOS. If the Option ROM determines that it is executing under a Plug and Play system BIOS, it should return some device status parameters upon return from the initialization call. See the section on Option ROM Initialization for further details. The field is four bytes wide even though most implementations may adhere to the custom of defining a simple three byte NEAR JMP. The definition of the fourth byte may be OEM specific."
  - id: reserved
    size: 17
    doc: "This area is used by various vendors and contains OEM specific data and copyright strings"
