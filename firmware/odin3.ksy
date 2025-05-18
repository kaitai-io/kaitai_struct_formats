meta:
  id: odin3
  title: ODIN3
  license: MIT
  endian: le
  application:
    - Samsung ODIN3
    - Samsung LOKE
    - Heimdall
    - wuotan
    - Thor
  xref:
    wikidata: Q19599499
doc: |
  [Samsung Odin](https://en.wikipedia.org/wiki/Odin_(firmware_flashing_software)) is a proprietary piece of software developed by Samsung and used to flash firmware into Samsung devices. Odin utility has a Loke counterpart in the device bootloader. This ksy documents the message format of the protocol they talk to each other.
  The protocol was reverse engineered by Benjamin Dobell who have created a MIT-licensed utility Heimdall, on which source code this ksy is based.
  If you wanna test and augment this spec keep in mind that a lot of websites spreading leaked versions of Odin utility were created with the sole purpose of spreading malware glued with the tool. The most trustworthy website I know is the one belonging to chainfire, a well-known dev on Android scene.

  Examples of the packets can be downloaded by the links:
    * https://github.com/Benjamin-Dobell/Heimdall/files/1414758/ODIN_flash_capture.zip
    * https://lindi.iki.fi/lindi/I9195IXXU1AOB1/KTU84P.I9195IXXU1AOB1_upgrade_Kies3.2.15072_2_Windows7_x64.pcap
    * https://lindi.iki.fi/lindi/I9195IXXU1AOB1/AP_flash_odin3.10_Windows7_x64.pcap
    * https://lindi.iki.fi/lindi/I9195IXXU1AOB1/recovery_flash_heimdall_d0526a3b_Debian_x64.pcap
    * https://lindi.iki.fi/lindi/I9195IXXU1AOB1/recovery_flash_heimdall_d0526a3b_Debian_x64.try2.pcap
    * https://lindi.iki.fi/lindi/I9195IXXU1AOB1/recovery_flash_valgrind_heimdall_d0526a3b_Debian_x64.pcap

doc-ref:
  - https://github.com/Benjamin-Dobell/Heimdall/tree/master/heimdall/source
  - https://github.com/Samsung-Loki/Thor
  - https://github.com/nickelc/wuotan

enums:
  reboot_values:
    0x00:
      id: none
      -orig-id: REBOOT_MODE_NONE
      doc: Model's Name
    0x01:
      id: download
      -orig-id: REBOOT_MODE_DOWNLOAD
      doc: Serial Code
    0x02:
      id: upload
      -orig-id: REBOOT_MODE_UPLOAD
      doc: Used, purpose unknown
    0x03:
      id: charging_03
      -orig-id: REBOOT_MODE_CHARGING
      doc: Unused?
    0x04:
      id: fota
      -orig-id: REBOOT_MODE_FOTA
      doc: FOTA Updating Process
    0x05:
      id: fota_bl
      -orig-id: REBOOT_MODE_FOTA_BL
      doc: BOTA Update
    0x06:
      id: secure
      -orig-id: REBOOT_MODE_SECURE
      doc: Modem Secure Error
    0x07:
      id: normal
      -orig-id: REBOOT_MODE_NORMAL
      doc: Default Reboot Mode
    0x08:
      id: firmware_update
      -orig-id: REBOOT_MODE_FWUP
      doc: Emergency Firmware Update
    0x09:
      id: em_fuse
      -orig-id: REBOOT_MODE_EM_FUSE
      doc: Unused?
    #0xXA:
    #  id: factory_md
    #  -orig-id: REBOOT_MODE_FACTORY_MD
    #  doc: Unused?
    0x0B:
      id: fota_setup
      -orig-id: REBOOT_MODE_FOTA_UP
      doc: FOTA Setting Up
    #0xXC:
    #  id: bootloader
    #  -orig-id: REBOOT_MODE_BOOTLOADER
    #  doc: Download (Odin) Mode
    #0xXD:
    #  id: wirelessd_bl
    #  -orig-id: REBOOT_MODE_WIRELESSD_BL
    #  doc: Unused?
    0x0E:
      id: recovery_wd
      -orig-id: REBOOT_MODE_RECOVERY_WD
      doc: Skip AVB Main
    0x0F:
      id: factory
      -orig-id: REBOOT_MODE_FACTORY
      doc: Samsung Factory Mode
    0xFD:
      id: power_off_watch
      -orig-id: REBOOT_MODE_POWEROFF_WATCH
      doc: Unused?
    0x10:
      id: watch_reboot_mode
      -orig-id: REBOOT_MODE_WATCH_REBOOT_MODE
      doc: Unused?
    0x11:
      id: charging_11
      -orig-id: REBOOT_MODE_CHARGING
      doc: Unused?
    0x12:
      id: power_off_by_key
      -orig-id: REBOOT_MODE_POWEROFF_BYKEY
      doc: Unused?

  chip_type:
    0:
      id: ram
      -orig-id: kChipTypeRam
    1:
      id: nand
      -orig-id: kChipTypeNand
  tr_request:
    # XmitShared in Thor
    0:
      id: flash
      -orig-id:
        - kRequestFlash
        - RequestFlash
        - FILE_REQUEST_TYPE_FLASH
    1:
      id: dump
      -orig-id:
        - kRequestDump
        - RequestDump
        - PIT_REQUEST_TYPE_DUMP
    2:
      id: part
      -orig-id:
        - kRequestPart
        - Begin
        - [FILE_REQUEST_TYPE_PART, PIT_REQUEST_TYPE_PART]
    3:
      id: end
      -orig-id:
        - [kRequestEnd, kRequestEndTransfer]
        - End
        - [FILE_REQUEST_TYPE_END_TRANSFER, PIT_REQUEST_TYPE_END_TRANSFER]
    0x2000: unknown2000
  destination:
    # BinaryType in Thor
    0:
      id: phone
      -orig-id:
        - kDestinationPhone
        - AP
        - FILE_END_TRANSFER_DEST_PHONE
    1:
      id: modem
      -orig-id:
        - kDestinationModem
        - CP
        - FILE_END_TRANSFER_DEST_MODEM
  packet_type:
    # PacketType in Thor
    0x00000000:
      id: send_file_part
      -orig-id:
        - kResponseTypeSendFilePart
        -
        - RESPONSE_TYPE_SEND_FILE_PART
    0x00000064:
      id: session
      -orig-id:
        - [kControlTypeSession, kResponseTypeSessionSetup]
        - SessionStart
        - [CONTROL_TYPE_SESSION, RESPONSE_TYPE_SETUP_SESSION]
    0x00000065:
      id: pit_file
      -orig-id:
        - kControlTypePitFile, kResponseTypePitFile
        - PitXmit
        - [CONTROL_TYPE_PIT_FILE, RESPONSE_TYPE_PIT_FILE]
    0x00000066:
      id: file_transfer
      -orig-id:
        - [kControlTypeFileTransfer, kResponseTypeFileTransfer]
        - FileXmit
        - [CONTROL_TYPE_FILE_TRANSFER, RESPONSE_TYPE_FILE_TRANSFER]
    0x00000067:
      id: end_session
      -orig-id:
        - [kControlTypeEndSession, kResponseTypeEndSession]
        - SessionEnd
        - [CONTROL_TYPE_END_SESSION, RESPONSE_TYPE_END_SESSION]
    0x00000069:
      id: device_information
      -orig-id:
        -
        - DeviceInfo
        -

instances:
  odin_handshake_message:
    contents: [ODIN, 0x00]
  loke_handshake_message:
    contents: [LOKE]

params:
  - id: is_loki_to_odin
    type: bool
    doc: |
      direction of the request, set into `true` if incoming to PC
      `packet.meta.endpoint_number.is_input`
  - id: was_previous_item_session_initiation
    type: bool
    doc: |
      the previous item was sessio initiation, so we get a response in the format that is different
      `not packet.meta.endpoint_number.is_input and o.type == odin3.Odin3.PacketType.session and o.content.regular_session.request == odin3.Odin3.Session.Request.begin_session`
      of the previous packet
seq:
  - id: type
    type: u4
    enum: packet_type
  - id: content
    size-eos: true
    type:
      switch-on: type
      cases:
        packet_type::session: session
        packet_type::pit_file: pit_file
        packet_type::file_transfer: file_transfer
        packet_type::end_session: end_session
        packet_type::device_information: device_information

types:
  end_session:
    seq:
      - id: request
        type: u4
        enum: request
    enums:
      request:
        0:
          id: end_session
          -orig-id:
            - kRequestEndSession
            - EndSession
            - END_SESSION_REQUEST_TYPE_END_SESSION
        1:
          id: reboot_os
          -orig-id:
            - kRequestRebootDevice
            - Reboot
            - END_SESSION_REQUEST_TYPE_REBOOT
        2:
          id: reboot_bootloader
          -orig-id:
            -
            - OdinReboot
            -
        3:
          id: power_off
          -orig-id:
            -
            - Shutdown
            -
  file_transfer:
    seq:
      - id: request
        type: u4
        enum: tr_request
      - id: content
        type:
          switch-on: request
          cases:
            #tr_request::flash:
            tr_request::dump: dump
            tr_request::part: part
            tr_request::end: end
    types:
      flash_part:
        seq:
          - id: sequence_byte_count
            type: u4
      part:
        seq:
          - id: sequence_byte_count
            type: u4
           # or (recheck this!)
          - id: part_index
            type: u4
      dump:
        seq:
          - id: chip_type
            type: u4
            enum: chip_type
          - id: chip_id
            type: u4
      end:
        seq:
          - id: destination
            type: u4
            enum: destination
          - id: sequence_byte_count
            type: u4
          - id: unknown1 # efs?
            type: u4
          - id: device_type
            type: u4
          - id: content
            type:
              switch-on: destination
              cases:
                destination::phone: phone
                #destination::modem: modem # empty
          - id: end_of_file
            type: u4
        types:
          phone:
            seq:
              - id: file_identifier
                type: u4
                enum: file
            enums:
              file:
                0x00:
                  id: primary_bootloader
                  -orig-id: kFilePrimaryBootloader
                0x01:
                  id: pit
                  -orig-id: kFilePit
                  doc: don't flash the pit this way!
                0x03:
                  id: secondary_bootloader
                  -orig-id: kFileSecondaryBootloader
                0x04:
                  id: secondary_bootloader_backup
                  -orig-id: kFileSecondaryBootloaderBackup
                0x06:
                  id: kernel
                  -orig-id: kFileKernel
                0x07:
                  id: recovery
                  -orig-id: kFileRecovery
                0x08:
                  id: tablet_modem
                  -orig-id: kFileTabletModem

                0x12: unknown12
                0x14:
                  id: efs
                  -orig-id: kFileEfs
                0x15:
                  id: param_lfs
                  -orig-id: kFileParamLfs
                0x16:
                  id: factory_file_system
                  -orig-id: kFileFactoryFilesystem
                0x17:
                  id: database_data
                  -orig-id: kFileDatabaseData
                0x18:
                  id: cache
                  -orig-id: kFileCache
                0x0b:
                  id: modem
                  -orig-id: kFileModem
                  doc: kies flashes the modem this way

  pit_file:
    seq:
      - id: request
        type: u4
        enum: tr_request
      - id: content
        type:
          switch-on: request
          cases:
            #tr_request::flash:
            tr_request::part: part
            tr_request::end: end
    types:
      flash_part:
        seq:
          - id: part_size
            type: u4
      part:
        seq:
          - id: part_index
            type: u4
      end:
        seq:
          - id: file_size
            type: u4

  session:
    doc-ref:
      - https://github.com/Samsung-Loki/samsung-docs/blob/main/docs/Odin/Session.md # in addition

    instances:
      is_quirky_session_response:
        value: _root.is_loki_to_odin and _root.was_previous_item_session_initiation
      session:
        value: "(is_quirky_session_response?quirky_session:regular_session)"
        doc: Who have designed this shit?

    enums:
      request:
        0:
          id: begin_session
          -orig-id:
            - kBeginSession
            - BeginSession
            - SESSION_REQUEST_TYPE_BEGIN_SESSION
        1:
          id: device_type
          -orig-id:
            - [kDeviceType, kDeviceInfo]
            - DeviceType
            - SESSION_REQUEST_TYPE_DEVICE_TYPE
          doc: obsolete (why?)
        2:
          id: total_bytes
          -orig-id:
            - kTotalBytes
            - TotalBytes
            - SESSION_REQUEST_TYPE_TOTAL_BYTES
        3:
          id: set_oem_state
          -orig-id:
            - kEnableSomeSortOfFlag
            - OemState
            -
        4:
          id: no_oem_check
          -orig-id:
            -
            - NoOemCheck
            -
        5:
          id: file_part_size
          -orig-id:
            - kFilePartSize
            - FilePartSize
            - SESSION_REQUEST_TYPE_FILE_PART_SIZE
        7:
          id: erase_user_data
          -orig-id:
            -
            - EraseUserdata
            -
        8:
          id: enable_tflash
          -orig-id:
            - kEnableTFlash
            - EnableTFlash
            - SESSION_REQUEST_TYPE_ENABLE_TFLASH
        9:
          id: set_region
          -orig-id:
            -
            - SetRegionCode
            -
        10:
          id: enable_rtn
          -orig-id:
            -
            - EnableRtn
            -
          doc: make device refurbished?

    seq:
      - id: quirky_session
        type: quirky_session
      - id: regular_session
        type: regular_session

    types:
      quirky_session:
        seq:
          - id: content
            type: session::begin_session
        instances:
          request:
            value: session::request::begin_session

      regular_session:
        seq:
          - id: request
            type: u4
            enum: request
          #- id: unknown_parameter
          #  type: u4
          - id: content
            type:
              switch-on: request
              cases:
                "request::begin_session": begin_session
                #"request::device_type": device_type
                request::total_bytes: total_bytes
                #"request::enable_some_sort_of_flag": enable_some_sort_of_flag
                request::file_part_size: file_part_size
                #"request::enable_tflash": enable_tflash
                request::set_region: set_region
      begin_session:
        doc-ref: https://github.com/Samsung-Loki/samsung-docs/blob/bc1e3a75dabf0c548bf50e2bf612d983c6f0bd8b/docs/Odin/Session.md
        seq:
          - id: protocol_version
            type: u4
      file_part_size:
        seq:
          - id: file_part_size
            type: u4
      total_bytes:
        seq:
          - id: total_bytes
            type: u4
      set_region:
        seq:
          - id: region
            type: str
            size: 3
            encoding: ascii
  device_information:
    doc-ref: https://github.com/Samsung-Loki/Thor/blob/18d655064b0a767c3b94d249385b77b536e2a582/TheAirBlow.Thor.Enigma/DeviceInfo.cs
    seq:
      - id: signature
        -orig-id: magic
        type: u4
        valid: 0x12345678
      - id: count
        type: u4
      - id: locations
        type: location
        repeat: expr
        repeat-expr: count
      - id: info
        type: item
        repeat: expr
        repeat-expr: count
    enums:
      type:
        0: model
        1: serial
        2: region
        3: carrier
    types:
      location:
        seq:
          - id: type
            type: u4
            enum: type
          - id: offset
            type: u4
          - id: size
            type: u4
      item:
        seq:
          - id: type
            type: u4
            enum: type
          - id: size
            type: u4
          - id: value
            -orig-id: str
            type: str
            encoding: utf-8
            size: size
