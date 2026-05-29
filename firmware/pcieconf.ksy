meta:
  id: pcieconf
  endian: le
  license: 0BSD
  imports:
    - pcieconf/bar_list
    - pcieconf/capabilities/pm
    - pcieconf/capabilities/msi
    - pcieconf/capabilities/vendor
    - pcieconf/capabilities/msix
    - pcieconf/capabilities/af

# TODO: EXPANSION ROM
# TODO: header type 0x2 (PC Card Standard)

doc-ref: |
  PCI LOCAL BUS SPECIFICATION, REV. 3.0
  p213, 6. Configuration Space

  PCI-to-PCI Bridge Architecture Specification, Revision 1.1
  p25, 3.2. PCI-to-PCI Bridge Configuration Space Header Format

  PCI EXPRESS BASE SPECIFICATION, REV. 3.0
  p587, 7.5. PCI-Compatible Configuration Registers

  PC Card Standard
  Volume 8, PC Card Host System Specification
  p78, 4.5.1 Bridge Configuration Registers

seq:
  - id: vendor_id
    type: u2
  - id: device_id
    type: u2
  - id: command
    type: command
  - id: status
    type: status
  - id: revision_id
    type: u1
  - id: class_code
    type: class_code
  - id: cacheline_size
    type: u1
  - id: latency_timer
    type: u1
  - id: header_type
    type: header_type
  - id: bist
    type: bist
  - id: layout_specific
    type:
      switch-on: header_type.layout
      cases:
        'layout::endpoint': endpoint_layout
        'layout::pci_pci_bridge': pci_pci_bridge_layout

types:
  command:
    seq:
      # bits 7:0
      - id: reserved0
        type: b1
      - id: parity_error_response
        type: b1
      - id: vga_palette_snoop
        type: b1
      - id: memory_write_and_invalidate_enable
        type: b1
      - id: special_cycles
        type: b1
      - id: bus_master
        type: b1
      - id: memory_space
        type: b1
      - id: io_space
        type: b1
      # bits 15:8
      - id: reserved1
        type: b5
      - id: interrupt_disable
        type: b1
      - id: fast_back_to_back_enable
        type: b1
      - id: serr_enable
        type: b1

  status:
    seq:
      # bits 7:0
      - id: fast_back_to_back_capable
        type: b1
      - id: reserved0
        type: b1
      - id: capable_66mhz
        type: b1
      - id: capabilities_list
        type: b1
      - id: interrupt_status
        type: b1
      - id: reserved1
        type: b3
      # bits 15:8
      - id: detected_parity_error
        type: b1
      - id: signaled_system_error
        type: b1
      - id: received_master_abort
        type: b1
      - id: received_target_abort
        type: b1
      - id: signaled_target_abort
        type: b1
      - id: devsel_timing
        type: b2
        enum: devsel
      - id: master_data_parity_error
        type: b1

  bist:
    seq:
      # bits 7:0
      - id: bist_capable
        type: b1
      - id: start_bist
        type: b1
      - id: reserved0
        type: b2
      - id: completion_code
        type: b4

  class_code:
    seq:
      - id: interface
        type: u1
      - id: sub_class
        type: u1
      - id: base_class
        type: u1

  header_type:
    seq:
      - id: multifunction
        type: b1
      - id: layout
        type: b7
        enum: layout

  endpoint_layout:
    seq:
      - id: bar_list
        type: bar_list
        size: 0x18
      - id: cardbus_cis_pointer
        type: u4
      - id: subsystem_vendor_id
        type: u2
      - id: subsystem_id
        type: u2
      # TODO: PCI LOCAL BUS SPECIFICATION, REV. 3.0 p228
      - id: expansion_rom_base_address
        size: 0x4
      - id: capabilities_pointer
        type: capability_pointer
      - id: reserved0
        size: 7
      - id: interrupt_line
        type: u1
      - id: interrupt_pin
        type: u1
        enum: interrupt_pin
      - id: min_gnt
        type: u1
      - id: max_lat
        type: u1
    instances:
      capabilities_list:
        type: capability
        pos: capabilities_pointer.masked_pointer
        if: _root.status.capabilities_list

  pci_pci_bridge_layout:
    seq:
      - id: bar_list
        type: bar_list
        size: 0x8
      - id: primary_bus_number
        type: u1
      - id: secondary_bus_number
        type: u1
      - id: subordinate_bus_number
        type: u1
      - id: secondary_latency_timer
        type: u1
      - id: io_base
        type: u1
      - id: io_limit
        type: u1
      - id: secondary_status
        type: secondary_status
      - id: memory_base
        type: u2
      - id: memory_limit
        type: u2
      - id: prefetchable_memory_base
        type: u2
      - id: prefetchable_memory_limit
        type: u2
      - id: prefetchable_memory_base_upper
        type: u4
      - id: prefetchable_memory_limit_upper
        type: u4
      - id: io_base_upper
        type: u2
      - id: io_limit_upper
        type: u2
      - id: capabilities_pointer
        type: capability_pointer
      - id: reserved
        size: 3
      # TODO: PCI LOCAL BUS SPECIFICATION, REV. 3.0 p228
      - id: expansion_rom_base_address
        size: 0x4
      - id: interrupt_line
        type: u1
      - id: interrupt_pin
        type: u1
        enum: interrupt_pin
      - id: bridge_control
        size: 2
    instances:
      capabilities_list:
        type: capability
        pos: capabilities_pointer.masked_pointer
        if: _root.status.capabilities_list
      io_base_32_addressing:
        doc-ref: |
          PCI-to-PCI Bridge Architecture Specification, Revision 1.1
          p41, Table 3-7: I/O Adressing Capability
        value:
          io_base & 0x0f == 0x1
      io_limit_32_addressing:
        value:
          io_limit & 0x0f == 0x1
      io_base_addr:
        doc-ref: |
          PCI-to-PCI Bridge Architecture Specification, Revision 1.1
          p41, 3.2.5.6. I/O Base Register and I/O Limit Register
        value: >-
          ((io_base & 0xf0) << 8) |
          ( io_base_32_addressing ? io_base_upper << 16 : 0)
      io_limit_addr:
        value: >-
          ((io_limit & 0xf0) << 8) |
          ( io_limit_32_addressing ? io_limit_upper << 16 : 0) |
          0xfff
      memory_base_addr:
        doc-ref: |
          PCI-to-PCI Bridge Architecture Specification, Revision 1.1
          p45, 3.2.5.8. Memory Base Register and Memory Limit Register
        value:
          (memory_base & 0xfff0) << 16
      memory_limit_addr:
        value:
          (memory_limit & 0xfff0) << 16 | 0xfffff
      prefetchable_memory_base_64_addressing:
        doc-ref: |
          PCI-to-PCI Bridge Architecture Specification, Revision 1.1
          p46, 3.2.5.9.Prefetchable Memory Base Register and Prefetchable
          Memory Limit Register
        value:
          prefetchable_memory_base & 0x0f == 0x1
      prefetchable_memory_limit_64_adressing:
        value:
          prefetchable_memory_limit & 0x0f == 0x1
      prefetchable_memory_base_addr:
        value: >-
          (prefetchable_memory_base & 0xfff0) << 16 |
          (prefetchable_memory_base_64_addressing ?
            prefetchable_memory_base_upper << 32 : 0)
      prefetchable_memory_limit_addr:
        value: >-
          (prefetchable_memory_limit & 0xfff0) << 16 |
          0xfffff |
          (prefetchable_memory_limit_64_adressing ?
            prefetchable_memory_limit_upper << 32 : 0)

  secondary_status:
    seq:
      # bits 7:0
      - id: fast_back_to_back_capable
        type: b1
      - id: reserved0
        type: b1
      - id: capable_66mhz
        type: b1
      - id: reserved1
        type: b5
      # bits 15:8
      - id: detected_parity_error
        type: b1
      - id: received_system_error
        type: b1
      - id: received_master_abort
        type: b1
      - id: received_target_abort
        type: b1
      - id: signaled_target_abort
        type: b1
      - id: devsel_timing
        type: b2
        enum: devsel
      - id: master_data_parity_error
        type: b1

  bridge_control:
    doc-ref: |
      PCI-to-PCI Bridge Architecture Specification, Revision 1.1
      p48, 3.2.5.17. Bridge Control Register
    seq:
      # bits 7:0
      - id: fast_back_to_back_enable
        type: b1
      - id: secondary_bus_reset
        type: b1
      - id: master_abort_mode
        type: b1
      - id: reserved0
        type: b1
      - id: vga_enable
        type: b1
      - id: isa_enable
        type: b1
      - id: serr_enable
        type: b1
      - id: parity_error_response_enable
        type: b1
      # bits 15:8
      - id: reserved1
        type: b4
      - id: discard_timer_serr_enable
        type: b1
      - id: discard_timer_status
        type: b1
      - id: secondary_discard_timer
        type: b1
      - id: primary_discard_timer
        type: b1

  capability:
    doc-ref: |
      PCI LOCAL BUS SPECIFICATION, REV. 3.0
      p230, 6.7. Capabilities List
    seq:
      - id: id
        type: u1
        enum: capability_id
      - id: next_pointer
        type: capability_pointer
      - id: body
        type:
          switch-on: id
          cases:
            'capability_id::pm': pm
            'capability_id::msi': msi
            'capability_id::vendor': vendor
            'capability_id::msix': msix
            'capability_id::af': af
    instances:
      next:
        type: capability
        pos: next_pointer.masked_pointer
        io: _root._io
        if: next_pointer.masked_pointer != 0

  capability_pointer:
    # Capability must be DWORD aligned.
    # Bottom two bits of capability pointer are reserved and must be masked.
    seq:
      - id: raw_pointer
        type: u1
    instances:
      masked_pointer:
        value: raw_pointer & 0xfc

enums:
  layout:
    0: endpoint
    1: pci_pci_bridge
    2: cardbus_bridge

  devsel:
    0: fast
    1: medium
    2: slow
    3: reserved

  capability_id:
    0x01: pm
    0x02: agp
    0x03: vpd
    0x04: slot_numbering
    0x05: msi
    0x06: compact_pci_hotswap
    0x07: pcix
    0x08: hyper_transport
    0x09: vendor
    0x0A: debug
    0x0B: compact_pci
    0x0C: hotplug
    0x0D: bridge_subsystem_vendor_id
    0x0E: agp8x
    0x0F: secure_device
    0x10: pcie
    0x11: msix
    0x12: sta_hba
    0x13: af

  interrupt_pin:
    0: none
    1: inta
    2: intb
    3: intc
    4: intd
