meta:
  id: ata_over_ethernet
  title: ATA over Ethernet
  application:
    - EtherDrive
    - Linux
    - vblade
    - kvblade
  license: Unlicense
  endian: be
  encoding: ascii
  xref:
    wikidata:
      - Q298746
      - Q5403289

doc-ref:
  - https://web.archive.org/web/20151208175927if_/http://brantleycoilecompany.com/AoEr11.pdf
  - https://github.com/OpenAoE/aoe
  - https://github.com/OpenAoE/vblade
  - https://github.com/john-sharratt/kvblade

doc: |
  Body of an Ethernet frame of type ETH_P_AOE (0x88A2).

  As the name implies, this protocol encapsulates ATA commands into Ethernet frames. I see no issue to encapsulate the same payload into packets of 3-7 ISO/OSI levels, if needed (and for working authentication & encryption SSH/dTLS can be used).

  The protocol contains no security (all its "security" relies on the fact that MAC address cannot be spoofed, which is wrong), the messages claiming security are for convenience and not for security. It is said explicitly that AoE should be used on a dedicated interface.

  To generate sample files with queries an `aoetools` package, a loopback interface and wireshark/tcpdump can be used. To generate the files with real ATA transactions and responses, a real impl is needed.

  Here are some samples: https://github.com/kaitai-io/kaitai_struct_formats/files/6343404/aoe.zip

seq:
  - id: header
    type: header
  - id: arguments
    -orig-id: Arg
    size-eos: true
    type:
      switch-on: header.command
      cases:
        command::issue_ata: issue_ata
        command::query_config: query_config
        command::mac_mask_ordered_set: mac_mask_ordered_set
        command::reserve_list: reserve_list

instances:
  sector_size:
    value: 512

types:
  mac:
    seq:
      - id: value
        size: 6
  server_addr:
    doc: |
      A message is considered targeted to the server if for each address component either of the conditions satisfied:
        1. the component is equal to the component of the server address
        2. the component is broadcast.
    seq:
      - id: shelf
        -orig-id:
          - major
          - maj
        type: u2
      - id: slot
        -orig-id:
          - minor
          - min
        type: u1
    instances:
      is_shelf_broadcast:
        value: shelf == 0xffff
      is_slot_broadcast:
        value: slot == 0xff
      is_full_broadcast:
        value: is_shelf_broadcast and is_slot_broadcast
  header:
    -orig-id:
      - aoe_hdr
      - Aoehdr
    seq:
      - id: version_and_flags
        -orig-id: verfl
        type: version_and_flags
      - id: error
        -orig-id: err
        type: u1
        enum: error
        doc: Error code, when `is_error` is set.
      - id: server_addr
        type: server_addr
        doc: |
          Each AoE server has an address and ignores all the messages not targeted to it (see the doc for the type for more info).
          Each response by a server must contain its address.
      - id: command
        -orig-id: cmd
        type: u1
        enum: command
      - id: tag
        type: u4
        doc: |
          Links requests to responses and is copied verbatim into the response from the corresponding request..
          In the impl it is timeval::tv_usec with the MSB overridden to 1 if the software that generated it in userspace and 0 if it is in kernelspace. Can it be exploited?
          Servers should broadcast Query Config Information responses with zero tag when they are ready to process commands.

    instances:
      is_command_vendor_specific:
        value: command.to_i >= 0xf0
        -orig-id: AOECMD_VEND_MIN

    enums:
      error:
        1:
          id: unrecognized_command
          -orig-id:
            - Unrecognized command code
            - BadCmd
            - AOEERR_CMD
        2:
          id: bad_argument
          -orig-id:
            - Bad argument parameter command code
            - BadArg
            - AOEERR_ARG
          doc: '`argument` contains invalid data.'
        3:
          id: device_unavailable
          -orig-id:
            - Device unavailable
            - DevUnavailable
            - AOEERR_DEV
          doc: The server is out of service.
        4:
          id: config_string_present
          -orig-id:
            - Config string present
            - ConfigErr
            - AOEERR_CFG
          doc: Config string was already set.
        5:
          id: unsupported_version
          -orig-id:
            - Unsupported version
            - BadVersion
            - AOEERR_VER
          doc: The server is incompatible to the version of the protocol
        6:
          id: target_is_reserved
          -orig-id:
            - Target is reserved
          doc: The server refuses to execute command because it was reserved to a specific mac address.

    types:
      version_and_flags:
        seq:
          - id: version
            type: b4
            doc: |
              The version of the protocol used.
              The offset and size of this field is guaranteed to be stable across format versions.
            valid:
              max: 1
          - id: is_response
            type: b1
            -orig-id:
              - R
              - AOEFL_RSP
              - Resp
          - id: is_error
            type: b1
            -orig-id:
              - E
              - AOEFL_ERR
              - Error
          - id: reserved
            type: b2
            -orig-id:
              - Z
            valid: 0
  issue_ata:
    doc: |
      The resposes to these commands are generated after commands execution (asynchronous commands are executed immediately), and ATA registers are copied into the corresponding fields.
    seq:
      - id: header
        type: header
      - id: lba
        size: 6
        type:
          switch-on: header.flags.is_lba48_extended
          cases:
            true: lba48
            false: lba24
      - id: reserved
        -orig-id: resvd
        size: 2
      - id: payload
        -orig-id: Data
        size: payload_size
    instances:
      contains_sector_data:
        -affected-by: implement xor
        value: (header.flags.is_write and not _root.header.version_and_flags.is_response) or (not header.flags.is_write and _root.header.version_and_flags.is_response)
      payload_size:
        value: |
          (contains_sector_data?(header.sector_count * _root.sector_size):_io.size - _io.pos)
    types:
      u3le:
        seq:
          - id: lo
            -orig-id: LBA Low, LBA Mid
            type: u2le
          - id: hi
            -orig--id: LBA High
            type: u1
        instances:
          value:
            value: hi << 16 | lo
      lba48:
        seq:
          - id: lba_1
            type: u3le
          - id: lba_0
            type: u3le
        instances:
          device:
            -orig-id: Device register
            value: ((_parent.as<issue_ata>.header.flags.is_lba48_extended.to_i << 6) | (_parent.as<issue_ata>.header.flags.has_device_register.to_i << 4) | 0xA0)
          sector_count_0:
            value: 0
          sector_count_1:
            value: _parent.as<issue_ata>.header.sector_count
      lba24:
        seq:
          - id: basic
            type: u3le
          - id: device
            type: u1
          - id: unkn
            type: u2

      header:
        -orig-id: aoe_atahdr
        seq:
          - id: flags
            -orig-id: aflags
            type: flags
          - id: error_or_feature
            -orig-id:
              - Err/Feature
              - errfeat
            type: u1
          - id: sector_count
            -orig-id:
              - scnt
            type: u1
          - id: command_or_status
            -orig-id:
              - Cmd/Status
              - cmdstat
            type: u1
        types:
          flags:
            -orig-id: AFlags
            seq:
              - id: reserved_80
                -orig-id: Z
                type: b1
                valid: false
              - id: is_lba48_extended
                -orig-id:
                  - E
                  - AOEAFL_EXT
                  - Extend
                type: b1
                doc: this command is LBA48 extended
              - id: reserved_40
                -orig-id: Z
                type: b1
                valid: false
              - id: has_device_register
                -orig-id:
                  - D
                  - AOEAFL_DEV
                  - Device
                type: b1
                doc: as defined in the ATA Device/Head register and is only evaluated when the E bit is set.
              - id: reserved_20
                -orig-id: Z
                type: b1
                valid: false
              - id: reserved_10
                -orig-id: Z
                type: b1
                valid: false
              - id: is_asynchronous
                -orig-id:
                  - A
                  - AOEAFL_ASYNC
                  - Async
                type: b1
                doc: |
                  Asynchronous requests, that can be queued into cache memory and then responded immediately with the same data as in input. Async write requests are not responded at all. In tha case of power loss or failure the cache can be lost.
              - id: is_write
                -orig-id:
                  - W
                  - AOEAFL_WRITE
                  - Write
                type: b1
                doc: The data must be written, not read.

  query_config:
    -orig-id: Conf
    doc: |
      In a command message the fields Buffer Count, , and AoE must be set to zero by the client and ignored by the server. The remaining fields may be used to query and set the server’s config string.
    seq:
      - id: header
        type: header
      - id: config_string
        #type: str
        size: header.config_string_length
        doc: |
          When querying, may be filled with 0xED, which is not ASCII, so I guess it is just a byte array rather than a string.

    types:
      header:
        -orig-id: aoe_cfghdr
        seq:
          - id: buffer_size_in_messages
            -orig-id:
              - Buffer Count
              - bufcnt
            type: u2
            doc: Count of messages that can be buffered. Messages exceeding buffer are dropped.
            valid:
              expr: _ == 0 or _root.header.version_and_flags.is_response
          - id: server_version
            -orig-id:
              - Firmware Version
              - fwver
              - firmware
            type: u2
            doc: Version of server software/firmware.
            valid:
              expr: _ == 0 or _root.header.version_and_flags.is_response
          - id: sectors_per_ata_command
            -orig-id:
              - Sector Count
              - scnt
            type: u1
            doc: Maximum count of sectors the server can handle in a single ATA command request. 0 means 2 due to historical reasons.
          - id: version_and_command
            -orig-id:
              - aoeccmd
              - vercmd
            type: version_and_command
          - id: config_string_length
            -orig-id: cslen
            type: u2
            valid:
              max: 1024
        types:
          version_and_command:
            seq:
              - id: version
                -orig-id:
                  - AoE
                type: b4
                doc: Maximum protocol version the server supports.
                valid:
                  expr: _ == 0 or _root.header.version_and_flags.is_response
              - id: command
                -orig-id:
                  - CCmd
                type: b4
                enum: command
        enums:
          command:
            0:
              id: read_config_string
              -orig-id:
                - AOECCMD_READ
                - Qread
              doc: Just read server config string.
            1:
              id: test_if_config_string_equal
              -orig-id:
                - test config string
                - AOECCMD_TEST
                - Qtest
              doc: One will get a response only if server's config string is equal the one sent.
            2:
              id: test_if_prefix_of_config_string
              -orig-id:
                - ptest
                - AOECCMD_PTEST
                - Qprefix
              doc: One will get a response only if server's config string begins with the one sent.
            3:
              id: initialize_config_string
              -orig-id:
                - set config string
                - set
                - AOECCMD_SET
                - Qset
              doc: If server's config string is not initialized, initializes it and responds OK. If it is already initialized, returns `config_string_present` error.
            4:
              id: override_config_string
              -orig-id:
                - force set config string
                - fset
                - AOECCMD_FSET
                - Qfset
              doc: |
                Overrides the config string with a new one, server responds with the **entire** old config string.


  mac_mask_ordered_set:
    doc: |
      Modifies MAC address masks ordered set. Servers are required to process directives one-by-one in the same order they get them, and if there is an error, rollback and return the response with dir_count equal to the ordinal of the errored directive, and response body must be the same as in the request.
      In the case of success server returns its masks set in the response.

      If MAC adddress masks set is not empty, a server would only accept messages from the MAC addrs in it. Don't rely on it for security, MAC addrs are easily faked.

    seq:
      - id: header
        type: header
      - id: directives
        type: directive
        repeat: expr
        repeat-expr: header.count
    types:
      header:
        seq:
          - id: reserved
            type: u1
          - id: command
            type: u1
            enum: command
          - id: error
            type: u1
            enum: error
          - id: count
            -orig-id: Dir Count
            type: u1
            doc: It was planned that the protocol will never support more than 255 entries in its MAC mask set. Though servers are not required to support 255 addrs and would return mask_list_full in the case of adding more than supported.
      directive:
        seq:
          - id: reserved
            type: u1
          - id: command
            -orig-id: DCmd
            type: u1
            enum: command
          - id: addr
            -orig-id: Ethernet Address
            type: mac
            doc: The Ethernet address to add or delete from the mask list.
        enums:
          command:
            0: no_directive
            1: add_mac
            2: del_mac
    enums:
      command:
        0:
          id: read
        1:
          id: edit
      error:
        0: no_error
        1:
          id: unspecified
        2:
          id: bad_directive_command
        3:
          id: mask_list_full

  reserve_list:
    -orig-id: Reserve/Release
    doc: All the responses contain the current reserve list.
    seq:
      - id: command
        -orig-id: RCmd
        type: u1
        enum: command
      - id: count_of_macs
        -orig-id: NMacs
        type: u1
      - id: macs
        -orig-id: Ethernet Address
        type: mac
        repeat: expr
        repeat-expr: count_of_macs
    enums:
      command:
        0:
          id: read
          -orig-id: Read reserve list
        1:
          id: set_respecting_restrictions
          -orig-id: Set reserve list
          doc: |
            advisory locks the supplied macs, if not locked
        2:
          id: set_ignoring_restrictions
          -orig-id: Force set reserve list
          doc: |
            advisory locks the supplied macs unconditionally. Unlocking is by providing an empty set.

enums:
  command:
    0:
      id: issue_ata
      -orig-id:
        - Issue ATA Command
        - AOECMD_ATA
        - ATAcmd
      doc: |
        All the ATA commandts data must fit into a single message.
    1:
      id: query_config
      -orig-id:
        - Query Config Information
        - AOECMD_CFG
        - Config
      doc: |
        retrieves/sets server config string

    2:
      id: mac_mask_ordered_set
      -orig-id:
        - Mac Mask List
      doc: |
        Use only for convenience. Disallows access from macs not in set.

    3:
      id: reserve_list
      -orig-id:
        - Reserve / Release
      doc: |
        An implementation of advisory locks.
