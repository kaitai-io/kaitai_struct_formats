meta:
  id: smbios
  endian: le
  imports:
    - smbios_bios_info
    - smbios_system_info
    - smbios_processor_info
    - smbios_portable_battery
    - smbios_skipper
    - smbios_strings
  doc: |
    SMBIOS (System Management BIOS) addresses how motherboard and system
    vendors present management information about 340 their products in a
    standard format by extending the BIOS interface on processor
    architecture systems.
seq:
  - id: tables
    type: table
    repeat: eos
types:
  table:
    seq:
      - id: type
        type: u1
        enum: type_enum
      - id: table
        type:
          switch-on: type
          cases:
            # TODO: Add rest of the tables
            'type_enum::table0': smbios_bios_info
            'type_enum::table1': smbios_system_info
            'type_enum::table4': smbios_processor_info
            'type_enum::table22': smbios_portable_battery
            _: smbios_skipper
    enums:
      type_enum:
        0x00: table0
        0x01: table1
        0x04: table4
        0x16: table22

