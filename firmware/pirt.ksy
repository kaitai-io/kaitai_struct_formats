meta:
  id: pirt
  title: PCI IRQ Routing Table
  endian: le
  license: Unlicense
doc-ref: "https://web.archive.org/web/20101127024139/http://www.microsoft.com/whdc/archive/pciirq.mspx"
seq:
  - id: ver
    type: u2
    doc: "The version consists of a Minor version byte followed by a Major version byte. Since this specification describes the Version 1.0 table format, byte 4 of the table is a 00h and byte 5 is a 01h. Must be 1.0."
  - id: table_size
    type: u2
    doc: "The size of the PCI IRQ Routing Table in bytes. Must be larger than 32 and must be a multiple of 16. If there were five slot entries in the table, this value would be 32 + (5 * 16) = 112."
  - id: pir_bus
    type: u1
    doc: "The bus number of the PCI Interrupt Router device."
  - id: pir_dev_func
    type: u1
    doc: "The Device and Function number of the PCI Interrupt Router device. The Device is in the upper five bits, the Function in the lower three."
  - id: pci_exclusive_irqs
    type: u2
  - id: compatible_pir
    type: u4
    doc: "Contains the Vendor ID (bytes 10 and 11) and Device ID (byes 12 and 13) of a compatible PCI Interrupt Router, or zero (0) if there is none. A compatible PCI Interrupt Router is one that uses the same method for mapping PIRQn# links to IRQs, and uses the same method for controlling the edge/level triggering of IRQs. This field allows an operating system to load an existing IRQ driver on a new PCI chip set without updating any drivers and without any user interaction."
  - id: miniport_data
    type: u4
    doc: "This is passed directly to the IRQ Miniport's Initialize() function. If an IRQ Miniport does not need any additional information, this field should be set to zero (0)."
  - id: reserved
    size: 11
  - id: checksum
    type: u1
    doc: "This byte should be set such that the sum of all of the bytes in the PCI IRQ Routing Table, including the checksum, and all of the slot entries, modulo 256, is zero."
  - id: entries
    type: pir_slot_entry
    doc: "Each slot entry is 16-bytes long and describes how a slot's PCI interrupt pins are wire OR'd to other slot interrupt pins and to the chip set's IRQ pins."
    repeat: expr
    repeat-expr: (table_size - 32) / 16
types:
  pir_slot_entry:
    seq:
      - id: pci_bus_number
        type: u1
        doc: "The bus number of the slot."
      - id: pci_device_number
        type: u1
        doc: "The device number of the slot."
      - id: parts
        type: pir_slot_entry_part
        repeat: expr
        repeat-expr: 4
      - id: slot_number
        type: u1
        doc: >
          This value is used to communicate whether the table entry is for a system-board device or an add-in slot. For system-board devices, the slot number should be set to zero. For add-in slots, the slot number should be set to a value that corresponds with the physical placement of the slot on the system board. This provides a way to correlate physical slots with PCI device numbers.
          Values (with the exception of zero) are OEM-specific. For end-user ease-of-use, slots in the system should be clearly labeled (such as solder mask, back panel, and so on).
          It should be noted that the slot entries of the PCI IRQ Routing Table are compatible with the PCI IRQ Routing Options Table of the PCI BIOS Specification, Revision 2.1. This makes it possible to support both the PCI IRQ Routing Table and the PCI BIOS specification with only one table in ROM.
      - id: reserved
        type: u1
    types:
      pir_slot_entry_part:
        seq:
          - id: link_value
            type: u1
            doc: >
              A value of zero means this interrupt pin is not connected to any other interrupt pins and is not connected to any of the Interrupt Router's interrupt pins.
              The non-zero link values are specific to a chip set and decided by the chip-set vendor. Here is a suggested implementation:
              A value of 1 through the number of interrupt pins on the Interrupt Router means the pin is connected to that PIRQn# pin of the Interrupt Router.
              A value larger than the number of interrupt pins on the Interrupt Router means the pin is wire OR'd together with other slot interrupt pins, but the group is not connected to any PIRQn# pin on the Interrupt Router.
              Other interpretations of the link values are possible. For instance, the link value may indicate which byte of Configuration Space to access for this link, or which I/O Port to access for the link. The specific interpretation of the link value is decided by the manufacturer of the Interrupt Router and is supported by the driver for that router.
          - id: irq_bitmap
            type: u2
            doc: >
              This value shows which of the standard AT IRQs this PCI's interrupts can be routed to. This provides the routing options for one particular PCI interrupt pin. In this bitmap, bit 0 corresponds to IRQ0, bit 1 to IRQ1, and so on. A 1 bit in this bitmap indicates that routing is possible; a 0 bit indicates that no routing is possible.
              This bitmap must be the same for all pins that have the same link number.