meta:
  id: odin3
  title: ODIN3
  license: MIT
  endian: le
  application:
    - Samsung ODIN3
    - Samsung LOKE
    - Heimdall
  xrefs:
    wikidata: Q19599499
doc: |
  [Samsung Odin](https://en.wikipedia.org/wiki/Odin_(firmware_flashing_software)) is a proprietary piece of software developed by Samsung and used to flash firmware into Samsung devices. Odin utility has a Loke counterpart in the device bootloader. This ksy documents the message format of the protocol they talk to each other.
  The protocol was reverse engineered by Benjamin Dobell who have created a MIT-licensed utility Heimdall, on which source code this ksy is based.
  If you wanna test and augment this spec keep in mind that a lot of websites spreading leaked versions of Odin utility were created with the sole purpose of spreading malware glued with the tool. The most trustworthy website I know is the one belonging to chainfire, a well-known dev on Android scene.
doc-ref: https://github.com/Benjamin-Dobell/Heimdall/tree/master/heimdall/source
enums:
  chip_type:
    0: ram
    1: nand
  tr_request:
    0: flash
    1: dump
    2: part
    3: end
    0x2000: unknown2000
  destination:
    0: phone
    1: modem
  packet_type:
    0x00000000: send_file_part
    0x00000064: session
    0x00000065: pit_file
    0x00000066: file_transfer
    0x00000067: end_session
instances:
  odin_handshake_message:
    contents:   ["ODIN", 0x00]
  loke_handshake_message:
    contents:   ["LOKE"]

seq:
  - id: type
    type: u4
    enum: packet_type
  - id: content
    size-eos: true
    type:
      switch-on: type
      cases:
        "packet_type::session": session
        "packet_type::pit_file": pit_file
        "packet_type::file_transfer": file_transfer
        "packet_type::end_session": end_session

types:
  end_session:
    seq:
      - id: request
        type: u4
        enum: request
    enums:
      request:
        0: end_session
        1: reboot_device

  file_transfer:
    seq:
      - id: request
        type: u4
        enum: tr_request
      - id: content
        type:
          switch-on: request
          cases:
            "tr_request::flash": flash
            "tr_request::dump": dump
            "tr_request::part": part
            "tr_request::end": end
    types:
      flash:
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
                "destination::phone": phone
                #"destination::modem": modem
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
                0x00: primary_bootloader
                0x01: pit # don't flash the pit this way!
                0x03: secondary_bootloader
                0x04: secondary_bootloader_backup
                0x06: kernel
                0x07: recovery
                0x08: tablet_modem
                
                0x12: unknown12
                0x14: efs
                0x15: param_lfs
                0x16: factory_file_system
                0x17: database_data
                0x18: cache

                0x0b: modem # kies flashes the modem this way

  
  
  pit_file:
    seq:
      - id: request
        type: u4
        enum: tr_request
      - id: content
        type:
          switch-on: request
          cases:
            "tr_request::flash": flash
            "tr_request::part": part
            "tr_request::end": end
    types:
      flash:
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
    enums:
      request:
        0: begin_session
        1: device_type
        2: total_bytes
        3: enable_some_sort_of_flag
        5: file_part_size
        8: enable_tflash
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
            #"request::begin_session": begin_session
            #"request::device_type": device_type
            "request::total_bytes": total_bytes
            #"request::enable_some_sort_of_flag": enable_some_sort_of_flag
            "request::file_part_size": file_part_size
            #"request::enable_tflash": enable_tflash
    types:
      file_part_size:
        seq:
          - id: file_part_size
            type: u4
      total_bytes:
        seq:
          - id: total_bytes
            type: u4

    "request::begin_session": begin_session
                #"request::device_type": device_type
                "request::total_bytes": total_bytes
                #"request::enable_some_sort_of_flag": enable_some_sort_of_flag
                "request::file_part_size": file_part_size
                #"request::enable_tflash": enable_tflash
        types:
          file_part_size:
            seq:
              - id: file_part_size
                type: u4
          total_bytes:
            seq:
              - id: total_bytes
                type: u4

