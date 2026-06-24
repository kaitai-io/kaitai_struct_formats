meta:
  id: windows_suite_mask
  title: Windows suite mask bit flags
  license: Unlicense
  endian: le
  bit-endian: le
doc: |
  A structure describing Windows feature suite. By default parses 4 bytes. Set `size: 2` to parse the basic version only.
doc-ref:
  - https://github.com/mirror/mingw-w64/blob/adfc6f4f73cc9de26007e7879422d5d3d9ffbfa4/mingw-w64-headers/include/ntdef.h#L799-L817
  - https://github.com/reactos/reactos/blob/2204695f0a87741b9b6224625a4707e59b9c9995/sdk/include/xdk/ntbasedef.h#L810-L827
  - https://github.com/DynamoRIO/drmemory/blob/d4b9a40c6f75ad0e7a03dccebb492876d866acb1/drstrace/drstrace_named_consts.c#L107-L127
  - https://github.com/hfiref0x/WinObjEx64/blob/71d340be5effe2b99d95b686105349972764f061/Source/WinObjEx64/extras/extrasUSD.c#L95-L115
  - https://learn.microsoft.com/en-us/windows/win32/sysinfo/rtlgetsuitemask
  - https://learn.microsoft.com/en-us/windows/win32/api/minidumpapiset/ns-minidumpapiset-minidump_system_info
  - https://learn.microsoft.com/en-us/windows-hardware/drivers/install/inf-manufacturer-section

-orig-id:
  - wSuiteMask
  - SuiteMask

seq:
  - id: basic
    type: basic
  - id: extended
    type: extended
    if: _io.size > sizeof<basic>

types:
  basic:
    meta:
      bit-endian: le
    doc: first 2 bytes (lower half of u4le)
    seq:
      - id: small_business # 01
        -orig-id: VER_SUITE_SMALLBUSINESS
        type: b1
      - id: enterprise # 02
        -orig-id: VER_SUITE_ENTERPRISE
        type: b1
      - id: back_office # 04
        -orig-id: VER_SUITE_BACKOFFICE
        type: b1
      - id: communications # 08
        -orig-id: VER_SUITE_COMMUNICATIONS
        type: b1

      - id: terminal # 10
        -orig-id: VER_SUITE_TERMINAL
        type: b1

      - id: small_business_restricted # 20
        -orig-id: VER_SUITE_SMALLBUSINESS_RESTRICTED
        type: b1
      - id: embedded_nt # 40
        -orig-id: VER_SUITE_EMBEDDEDNT
        type: b1
      - id: data_center # 80
        -orig-id: VER_SUITE_DATACENTER
        type: b1

      - id: single_user_ts # 100
        -orig-id: VER_SUITE_SINGLEUSERTS
        type: b1

      - id: personal # 200
        -orig-id: VER_SUITE_PERSONAL
        type: b1
      - id: blade # 400
        -orig-id:
          - VER_SUITE_BLADE
          - VER_SUITE_SERVERAPPLIANCE
        type: b1

      - id: embedded_restricted # 800
        -orig-id: VER_SUITE_EMBEDDED_RESTRICTED
        type: b1

      - id: security_appliance # 1000
        -orig-id: VER_SUITE_SECURITY_APPLIANCE
        type: b1

      - id: storage_server # 2000
        -orig-id: VER_SUITE_STORAGE_SERVER
        type: b1
      - id: compute_server # 4000
        -orig-id: VER_SUITE_COMPUTE_SERVER
        type: b1
      - id: home_server # 8000
        -orig-id: VER_SUITE_WH_SERVER
        type: b1

  extended:
    meta:
      bit-endian: le
    doc: last 2 bytes (upper half of u4le)
    seq:
      - id: unkn0 # 0001_0000
        type: b1
      - id: multi_user_ts # 0002_0000
        -orig-id: VER_SUITE_MULTIUSERTS
        type: b1
      - id: unkn1
        type: b6

      - id: unkn2
        type: b6
      - id: workstation_nt # 0x4000_0000
        -orig-id: VER_WORKSTATION_NT
        type: b1
      - id: server_nt # 0x8000_0000
        -orig-id: VER_SERVER_NT
        type: b1
