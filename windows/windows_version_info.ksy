meta:
  id: windows_version_info
  title: Windows OSVERSIONINFO(EX)?[AW] structure
  license: Unlicense
  endian: le
  imports:
    - /windows/windows_suite_mask
doc: |
  A structure describing Windows OS edition.
doc-ref:
  - https://github.com/reactos/reactos/blob/01eb9ba8de4bed03cd67049b158acb3faec5dc8b/sdk/include/xdk/rtltypes.h#L236-L296
  - https://learn.microsoft.com/en-us/windows-hardware/drivers/install/combining-platform-extensions-with-operating-system-versions
  - https://learn.microsoft.com/en-us/windows-hardware/drivers/install/inf-manufacturer-section
  - https://learn.microsoft.com/en-us/windows/win32/api/minidumpapiset/ns-minidumpapiset-minidump_system_info
  - https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-osversioninfoa
  - https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-osversioninfow
  - https://learn.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/ns-wdm-_osversioninfoexw
  - https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-verifyversioninfoa

-orig-id:
  - _OSVERSIONINFOA
  - OSVERSIONINFOA
  - _OSVERSIONINFOEXA
  - OSVERSIONINFOEXA
  - _OSVERSIONINFOW
  - OSVERSIONINFOW
  - _OSVERSIONINFOEXW
  - OSVERSIONINFOEXW

instances:
  csd_version_size:
    value: 128
  csd_version_char_size:
    value: csd_version_size
  csd_version_wchar_size:
    value: csd_version_size * 2
  basic_char_size: # 148
    value: size._sizeof + sizeof<internal::basic> + csd_version_char_size
  extended_char_size: # 156
    value: basic_char_size + sizeof<internal::extended>
  basic_wchar_size: # 532
    value: size._sizeof + sizeof<internal::basic> + csd_version_wchar_size
  extended_wchar_size: # 540
    value: basic_wchar_size + sizeof<internal::extended>

seq:
  - id: size
    -orig-id: dwOSVersionInfoSize
    type: u4
    valid:
      any-of:
        - basic_char_size
        - extended_char_size
        - basic_wchar_size
        - extended_wchar_size
  - id: sized
    size: size - size._sizeof
    type:
      switch-on: size
      cases:
        basic_char_size: internal(false, false)
        extended_char_size: internal(false, true)
        basic_wchar_size: internal(true, false)
        extended_wchar_size: internal(true, true)

types:
  internal:
    params:
      - id: is_wide
        type: bool
      - id: is_extended
        type: bool
    seq:
      - id: basic
        type: basic
      - id: csd_version_wchar
        -orig-id: szCSDVersion
        type: str
        encoding: utf-16
        size: _root.csd_version_wchar_size
        if: is_wide
      - id: csd_version_char
        -orig-id: szCSDVersion
        type: str
        encoding: ascii
        size: _root.csd_version_char_size
        if: not is_wide
      - id: extended
        type: extended
        if: is_extended
    instances:
      csd_version:
        value: is_wide?csd_version_wchar:csd_version_char
    types:
      basic:
        seq:
          - id: major
            -orig-id:
              - dwMajorVersion
              - MajorVersion
            type: u4
          - id: minor
            -orig-id:
              - dwMinorVersion
              - MinorVersion
            type: u4
          - id: build
            -orig-id:
              - dwBuildNumber
              - BuildNumber
            type: u4
          - id: platform
            -orig-id:
              - dwPlatformId
              - PlatformId
            type: u4
            enum: platform
        enums:
          platform:
            0:
              id: win32s
              -orig-id: VER_PLATFORM_WIN32s
              doc: 3.1
            1:
              id: windows
              -orig-id: VER_PLATFORM_WIN32_WINDOWS
              doc: 95 to ME
            2:
              id: win32_nt
              -orig-id: VER_PLATFORM_WIN32_NT
              doc: 2000 to 7
      extended:
        seq:
          - id: service_pack_major
            -orig-id: wServicePackMajor
            type: u2
          - id: service_pack_minor
            -orig-id: wServicePackMinor
            type: u2
          - id: suite_mask
            -orig-id: wSuiteMask
            size: 2
            type: windows_suite_mask
          - id: product_type
            -orig-id: wProductType
            type: u1
            enum: product_type
          - id: reserved
            -orig-id: wReserved
            type: u1
        enums:
          product_type:
            1:
              id: nt_workstation
              -orig-id: VER_NT_WORKSTATION
            2:
              id: nt_domain_controller
              -orig-id: VER_NT_DOMAIN_CONTROLLER
            3:
              id: nt_server
              -orig-id: VER_NT_SERVER

enums:
  verify_type_mask: # dwTypeMask argument of VerifyVersionInfoA. The names must match to the ones in internal::basic
    0x0000001:
      id: minor
      -orig-id: VER_MINORVERSION
    0x0000002:
      id: major
      -orig-id: VER_MAJORVERSION
    0x0000004:
      id: build
      -orig-id: VER_BUILDNUMBER
    0x0000008:
      id: platform_id
      -orig-id: VER_PLATFORMID
    0x0000010:
      id: service_pack_minor
      -orig-id: VER_SERVICEPACKMINOR
    0x0000020:
      id: service_pack_major
      -orig-id: VER_SERVICEPACKMAJOR
    0x0000040:
      id: suite_mask
      -orig-id: VER_SUITENAME
    0x0000080:
      id: product_type
      -orig-id: VER_PRODUCT_TYPE
