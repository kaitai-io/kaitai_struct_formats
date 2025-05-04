meta:
  id: broadcom_patchram
  title: Broadcom patchram blob
  license: MIT
  endian: le
doc: |
  Patches for Broadcom chips firmware in ROM.
  This spec describes the format of the blobs that are sent to the chip, that encode.
  The blobs are uploded into chip RAM using WRITE_RAM to a special offsets in chip RAM in DOWNLOAD_MINIDRIVER mode, then when the chip is launched using LAUNCH_RAM.
  The hcd files contain raw HCI commands to be sent to chips, the offsets are already there. They should be parsed with another spec, hardware/bluetooth/bluetooth_hcd, the commands should be emulated and this spec should be applied to the result.
doc-ref:
  - https://raw.githubusercontent.com/seemoo-lab/internalblue/master/doc/internalblue_thesis_dennis_mantz.pdf
  - https://github.com/MarkMendelsohn/brcm_patchram/blob/master/brcm_patchram_plus.c#L634
seq:
  - id: patches
    type: patch
    repeat: until
    repeat-until: "_.command == command::end_fe or _.command == command::end_ef"
types:
  patch:
    seq:
      - id: command
        type: u1
        enum: command
      - id: size
        type: u2
      - id: value
        size: size
        type:
          switch-on: command
          cases:
            'command::patch_memory': patch_memory
            'command::patch_dword': patch_dword
            'command::reboot': reboot
    types:
      reboot:
        seq:
          - id: next_tlv_record_addr
            type: u4
            doc: "When the TLV parser in the Download_Minidriver state processes the type 0x02 it initiates a reboot. However, in an early state of the boot process parsing the TLV list is continued at the address specified in the value of the TLV. In case of the bcm4335c5.hcd this is actually just the address of the next TLV object in the list."
          - id: unkn0
            size: 6
            doc: Zero bytes?
      patch_memory:
        seq:
          - id: target
            type: u4
          - id: data
            size-eos: true
      patch_dword:
        doc: |
          Patching procedure (page 28 of the PDF, have I got it right?):
            auto value_table = (uint32_t *)0xD0000;  // ram
            auto addr_table = (uint32_t *)0x310000;  // hw register
            value_table[rec.slot()] = rec.new_value();
            addr_table[rec.slot()] = rec.target();
        seq:
          - id: slot
            type: u1
          - id: target
            -orig-id: target_address
            type: u4
          - id: new_value
            type: u4
          - id: unkn0
            type: u2
            doc: 0x0000
          - id: unkn1
            type: u4
enums:
  command:
    0x02:
      id: reboot
      doc: |
        Issue a reboot and continues processing the list after the reset.
        In the analyzed firmware patch (bcm4335c5.hcd) this typeis used exactly once and relatively early in the list before any of the type 0x08 objects.
    0x08:
      id: patch_dword
      doc: |
        Patch 32-bit word in ROM.
    0x0a:
      id: patch_memory
      doc: Patch  arbitray  length  of  bytes in RAM.

    0x40:
      id: set_mac_addr
      doc: Set default Bluetooth Device Address.

    0x41:
      id: set_local_device_name
      doc: An ASCII string which is set to bethe new local device name.

    0xfe:
      id: end_fe

    0xef:
      id: end_ef

    # todo: 0x03,0x0b,0x1a,0x40,0x68,0x69,0x6f,0x70,0x82,0x86,0x90,0xb1,0xb2,0xb3,0xc0,0xc1,0xd8,0xfd
