meta:
  id: device_class_code
  title: Device class codes
  application: x86 architecture
  endian: le
  license: Unlicense
doc: >
  Spec:
    Plug and Play BIOS Specification Version 1.0A May 5, 1994, 3.2 Expansion Header for Plug and Play
doc-ref:
  - http://download.intel.com/support/motherboards/desktop/sb/pnpbiosspecificationv10a.pdf
seq:
  - id: base_type
    doc: "Indicates the general device type"
    type: u1
    enum: base 
  - id: sub_type
    doc: "Device Sub-Type, its definition is dependent upon the Base-Type code."
    type: u1
    # enum:
      # switch-on: base_type
      # cases:
        # 'base::legacy': sub_legacy
        # 'base::mass_storage': sub_storage
        # 'base::network': sub_network
        # 'base::display': sub_display
        # 'base::multimedia': sub_multimedia
        # 'base::memory': sub_memory
        # 'base::bridge': sub_bridge
        # 'base::simple_communication': sub_simple_communication
        # 'base::base_system_peripherals': sub_base_system_peripherals
        # 'base::input_devices': sub_input_devices
        # 'base::docking_stations': sub_docking_stations
        # 'base::processors': sub_processors
        # 'base::serial_bus': sub_serial_bus
        # 'base::wireless': sub_wireless
        # 'base::intelligent_io': sub_intelligent_io
        # 'base::satellite_communication': sub_satellite_communication
        # 'base::crypto': sub_crypto
        # 'base::data_acquisition_and_signal_processing': sub_data_acquisition_and_signal_processing
        # 'base::processing_accelerators': sub_processing_accelerators
  - id: if_type
    doc: "the specific device programming interface"
    type: u1
enums:
  base:
    0x00: legacy
    0x01: mass_storage
    0x02: network
    0x03: display
    0x04: multimedia
    0x05: memory
    0x06: bridge
    0x07: simple_communication
    0x08: base_system_peripherals
    0x09: input_devices
    0x0a: docking_stations
    0x0b: processors
    0x0c: serial_bus
    0x0d: wireless
    0x0e: intelligent_io
    0x0f: satellite_communication
    0x10: crypto
    0x11: data_acquisition_and_signal_processing
    0x12: processing_accelerators
    0x13: non_essential_instrumentation
    0x40: coprocessor
    0xff: unknown
  sub_legacy:
    0x00: non_vga
    0x01: vga
  sub_storage:
    0x00: scsi_storage_controller
    0x01: ide
    0x02: floppy
    0x03: ipi_bus
    0x04: raid_bus
    0x05: ata
    0x06: sata
    0x07: serial_attached_scsi
    0x08: non_volatile
    0x80: other
  sub_network:
    0x00: ethernet
    0x01: token_ring
    0x02: fddi
    0x03: atm
    0x04: isdn
    0x05: worldfip
    0x06: picmg
    0x07: infiniband
    0x08: fabric
    0x80: other
  sub_display:
    0x00: vga
    0x01: xga
    0x02: three_dimensional
    0x80: other
  sub_multimedia:
    0x00: video_controller
    0x01: audio_controller
    0x02: telephony_device
    0x03: audio_device
    0x80: other
  sub_memory:
    0x00: ram
    0x01: flash
    0x80: other
  sub_bridge:
    0x00: host
    0x01: isa
    0x02: eisa
    0x03: microchannel
    0x04: pci
    0x05: pcmcia
    0x06: nubus
    0x07: cardbus
    0x08: raceway
    0x09: semitransparent_pci2pci
    0x0a: infiniband2pci_host
    0x80: other
  sub_simple_communication:
    0x00: serial
    0x01: parallel
    0x02: multiport_serial
    0x03: modem
    0x04: gpib
    0x05: smard_card
    0x80: other
  sub_base_system_peripherals:
    0x00: pic
    0x01: dma
    0x02: timer
    0x03: rtc
    0x04: pci_hotplug
    0x05: sd_host
    0x06: iommu
    0x80: other
  sub_input_devices:
    0x00: keyboard
    0x01: digitizer_pen
    0x02: mouse
    0x03: scanner
    0x04: gameport
    0x80: other
  sub_docking_stations:
    0x00: generic_docking_station
    0x80: other
  sub_processors:
    0x00: i386
    0x01: i486
    0x02: pentium
    0x10: alpha
    0x20: power_pc
    0x30: mips
    0x40: coprocessor
  sub_serial_bus:
    0x00: firewire
    0x01: access_bus
    0x02: ssa
    0x03: usb
    0x04: fibre_channel
    0x05: smbus
    0x06: infiniband
    0x07: ipmi_smic
    0x08: sercos
    0x09: canbus
  sub_wireless:
    0x00: irda
    0x01: consumer_ir
    0x10: rf
    0x11: bluetooth
    0x12: broadband
    0x20: IEEE802_1a
    0x21: IEEE802_1b
    0x80: other
  sub_intelligent_io:
    0x00: i2o
  sub_satellite_communication:
    0x01: sat_tv
    0x02: sat_audio_communication
    0x03: sat_voice_communication
    0x04: sat_data_communication
  sub_crypto:
    0x00: network_and_computing
    0x10: entertainment
    0x80: other
  sub_data_acquisition_and_signal_processing:
    0x00: dpio_module
    0x01: performance_counters
    0x10: communication_synchronizer
    0x20: signal_processing_management
    0x80: other
  sub_processing_accelerators:
    0x00: processing_accelerators
  sub_unknown:
    0x00: unknown0

