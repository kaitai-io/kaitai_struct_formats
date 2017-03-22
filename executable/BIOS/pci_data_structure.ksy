meta:
  id: pci_data_structure
  title: PCIR data structure
  application: x86 architecture
  endian: le
  license: Unlicense
  imports:
    - ./device_class_code
doc: >
  Spec: BIOS Boot Specification Version 1.01 January 11, 1996, Appendix A: Data Structures, A.4 PCI Data Structure
doc-ref: http://www.scs.stanford.edu/05au-cs240c/lab/specsbbs101.pdf
seq:
  - id: signature
    contents: "PCIR"
  - id: vid
    type: u2
    doc: "Vendor Identification."
  - id: pid
    type: u2
    doc: "Device Identification."
  - id: vital_product_data_ptr
    type: u2
    doc: "Pointer to Vital Product Data."
  - id: len
    type: u2
    doc: "PCI Data Structure Length."
  - id: rev
    type: u1
    doc: "PCI Data Structure revision."
  - id: class_code
    type: device_class_code
    doc: "Class Code."
  - id: image_len
    type: u2
    doc: "Image Length."
  - id: rev_level
    type: u2
    doc: "Revision Level of Code/Data."
  - id: code_type
    type: u1
    enum: code_type
  - id: indicator
    type: u1
    doc: "indicator"
  - id: maximum_runtime_image_length
    doc: "represents the maximum length of the image after the initialization code has been executed. Its value is in units of 512 bytes. This field will be used to determine if the run-time image size is small enough to fit in the memory remaining in the system."
    type: u2
    if: rev > 30
  - id: configuration_utility_code_header_ptr
    doc: "This pointer is a two-byte pointer in little-endian format that points to the Expansion ROM’s Configuration Utility Code Header table at the beginning of the configuration code block. The beginning reference point (“offset zero”) for this pointer is the beginning of the Expansion ROM image. A value of 0000 will be present in this field if the Expansion ROM does not support a Configuration Utility Code Header."
    type: u2
    if: rev > 30
  - id: dmtf_clp_entry_point_ptr
    doc: "This pointer is a two-byte pointer in little-endian format that points to the execution entry point for the DMTP CLP code supported by this ROM. The beginning reference point (“offset zero”) for this pointer is the beginning of the Expansion ROM image. A value of 0000 will be present in this field if the Expansion ROM does not support a DMTF CLP code entry point."
    type: u2
    if: rev > 30
types:
  pci_data_struct_ptr:
    seq:
      - id: ptr
        type: u2
        doc: "Offset to PCIR data structure."
    instances:
      pci_data_struct:
        pos: ptr
        type: pci_data_structure
        if: ptr != 0
enums:
  code_type:
    0: x86
    1: open_firmware
    2: hewlett_packard
    3: efi
