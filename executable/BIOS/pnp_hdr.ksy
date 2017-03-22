meta:
  id: pnp_hdr
  title: Generic Option ROM Header
  application: x86 architecture
  endian: le
  license: Unlicense
  imports:
    - /firmware/device_class_code
    - /firmware/bios_header_generic
doc: >
  Specs:
    Plug and Play BIOS Specification Version 1.0A May 5, 1994, 3.2 Expansion Header for Plug and Play
    BIOS Boot Specification Version 1.01 January 11, 1996, Appendix A: Data Structures, A.3 PnP Expansion Header
  A PnP Card is defined by having a PnP Expansion Header in its option ROM. Any IPL device with an option ROM can contain the PnP Expansion Header, including PCI and ISA devices. If a PnP Expansion Header exists, the device will be treated as a PnP Card. If it is a BEV device it will be included in the IPL Priority. If it is a BCV device the BCV will be called. The PnP Expansion Header method of identifying boot devices with option ROMs is expected to become the future standard.
  All IPL devices with option ROMs must contain a valid option ROM header that resides between system memory addresses C0000h and EFFFFh on a 2k boundary and begins with 55AAh. A Device’s booting can only be controlled if it has a PnP Expansion Header. The Expansion Header, whose address resides within the standard option ROM header at offset +1Ah, contains important information used to configure the device. It also contains pointers to code in the device’s option ROM (BCV or BEV) that the BIOS will call to boot from the device. See Appendix A for the structure of the PnP Expansion Header. There are two ways an IPL device with a PnP
  Expansion Header can be booted. It must contain a BCV or a BEV. A BEV device, typically a network card, is booted by the BIOS making a far call directly to its BEV. If the device fails to boot, it executes an INT 18h which returns control back to the BIOS. BEV devices behave much like BAIDs in that they are selectively bootable.
  A BCV device, typically a SCSI controller, is not directly bootable. Rather, it merely adds its drives to the system by hooking into the BIOS’ INT 13h services and appending drive numbers to any existing drives. Since only drive 80h is bootable, a BCV would only be able to boot one of its drives if it installed before any other drives in the system. For this reason, it is necessary to control the order that all drives are installed into the system, including on-board ATA drives and those controlled by Legacy devices such as older SCSI controllers. The only way to control a BCV device’s drives in the boot order is by allowing the user to specify the order of initialization among ATA, BCV, and Legacy option ROMs. This will be discussed in detail in section 5.0.
  Offsets are all based from the beginning of the Header.
doc-ref:
  - http://download.intel.com/support/motherboards/desktop/sb/pnpbiosspecificationv10a.pdf
  - http://www.scs.stanford.edu/05au-cs240c/lab/specsbbs101.pdf
seq:
  - id: structure_revision
    type: u1
    doc: "This is an ordinal value that indicates the revision number of this structure only and does not imply a level of compliance with the Plug and Play BIOS version."
  - id: length_16
    type: u1
    doc: "Length of the entire Expansion Header expressed in sixteen byte blocks. The length count starts at the Signature field."
  - id: next_header
    type: header_ptr
  - id: res1
    type: u1
    doc: "Reserved for Expansion"
  - id: checksum
    type: u1
    doc: "Each Expansion Header is checksummed individually. This allows the software which wishes to make use of an expansion header (in this case, the system BIOS) the ability to determine if the expansion header is valid. The method for validating the checksum is to add up all byte values in the Expansion Header, including the Checksum field, into an 8-bit value. A resulting sum of zero indicates a valid checksum operation."
  - id: dev_id
    type: u4
    doc: "Contains the Plug and Play Device ID."
  - id: manuf_str_ptr
    type: c_str_ptr
    doc: "An offset relative to the base of the Option ROM which points to an ASCIIZ representation of the board manufacturer's name. This field is optional and if the pointer is 0 (Null) then the Manufacturer String is not supported"
  - id: prod_name_ptr
    type: c_str_ptr
    doc: "An offset relative to the base of the Option ROM which points to an ASCIIZ representation of the product name. This field is optional and if the pointer is 0 (Null) then the Product Name String is not supported."
  - id: dev_type
    type: device_class_code
    doc: "General device type information that will assist the System BIOS in prioritizing the boot devices."
  - id: dev_ind
    type: device_indicators 
    doc: "indicator bits that identify the device as being capable of being one of the three identified boot devices: Input, Output, or Initial Program Load (IPL)."
  - id: boot_conn_vec
    type: u2
    doc: "This location contains an offset from the start of the option ROM header to a routine that will cause the Option ROM to hook one or more of the primary input, primary display, or Initial Program Load (IPL) device vectors (INT 9h, INT 10h, or INT 13h), depending upon the parameters passed during the call. When the system BIOS has determined that the device controlled by this Option ROM will be one of the boot devices (the Primary Input, Primary Display, or IPL device), the System ROM will execute a FAR CALL to the location pointed to by the Boot Connection Vector. The system ROM will pass the following parameters to the options ROM's Boot Connection Vector"
  - id: disc_vec
    type: u2
    doc: "This vector is used to perform a cleanup from an unsuccessful boot attempt on an IPL device. The system ROM will execute a FAR CALL to this location on IPL failure."
  - id: bootstr_entr_point
    type: u2
    doc: "This vector is used primarily for RPL (Remote Program Load) support. To RPL (bootstrap), the System ROM will execute a FAR CALL to this location. The System ROM will call the Real/Protected Mode Bootstrap Entry Vector instead of INT 19h if: a) The device indicates that it may function as an IPL device, b) The device indicates that it does not support the INT 13h Block Mode interface, c) The device has a non-null Bootstrap Entry Vector, d) The Real/Protected Mode Boot Connection Vector is null. The method for supporting RPL is beyond the scope of this specification. A separate specification should define the explicit requirements for supporting RPL devices"
  - id: reserved
    type: u2
    doc: "Reserved for Expansion"
  - id: static_res_inf_vec
    type: u2
    doc: "This vector may be used by non Plug and Play devices to report static resource configuration information. Plug and Play devices should not support the Static Resource Information Vector for reporting their configuration information. This vector should be callable both before and/or after the option ROM has been initialized. The call interface for the Static Resource Information Vector is as follows"
instances:
  length:
    value: length_16 * 16
types:
  c_str_ptr:
    seq:
      - id: ptr
        type: u2
    instances:
      str:
        pos: ptr
        type: strz
        encoding: ASCII
        if: ptr != 0
  device_indicators:
    doc: "Indicator bits that identify the device as being capable of being one of the three identified boot devices: Input, Output, or Initial Program Load (IPL)."
    seq:
      - id: supports_ddi_model
        type: b1
        doc: "this ROM supports the Device Driver Initialization Model"
      - id: may_be_shadowed_in_ram
        type: b1
        doc: "this ROM may be Shadowed in RAM"
      - id: read_cacheable
        type: b1
        doc: "this ROM is Read Cacheable"
      - id: boot_device
        type: b1
        doc: "this option ROM is only required if this device is selected as a boot device"
      - id: reserved_0
        type: b1
      - id: ipl_device
        type: b1
        doc: "this device is an Initial Program Load (IPL) device"
      - id: input_device
        type: b1
        doc: "this device is an Input device"
      - id: display_device
        type: b1
        doc: "this device is a Display device"
