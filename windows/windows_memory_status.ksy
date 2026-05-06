meta:
  id: windows_memory_status
  title: Windows MEMORYSTATUS(EX)? structure
  license: Unlicense
  endian: le
doc: |
  A structure describing amount of memory available in system in some moment of time.
doc-ref:
  - https://github.com/reactos/reactos/blob/6b6a045766c2b22a68139a9cb702f5510eed97e8/sdk/include/psdk/winbase.h#L1215-L1225
  - https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-globalmemorystatusex
  - https://learn.microsoft.com/en-us/windows/win32/api/winbase/ns-winbase-memorystatus
  - https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-globalmemorystatus
  - https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-globalmemorystatusex

-orig-id:
  - MEMORYSTATUS
  - MEMORYSTATUSEX
  - _MEMORYSTATUS
  - _MEMORYSTATUSEX

instances:
  basic_size:
    value: size._sizeof + sizeof<internal::basic>
  extended_size:
    value: basic_size + sizeof<internal::extended>
seq:
  - id: size
    -orig-id: dwOSVersionInfoSize
    type: u4
    valid:
      any-of:
        - basic_size
        - extended_size
  - id: sized
    size: size - size._sizeof
    type:
      switch-on: size
      cases:
        basic_size: internal(false)
        extended_size: internal(true)

types:
  internal:
    params:
      - id: is_extended
        type: bool
    seq:
      - id: basic
        type: basic
      - id: extended
        type: extended
        if: is_extended
    types:
      basic:
        seq:
          - id: memory_load_percent
            -orig-id: dwMemoryLoad
            doc: in percents
            -unit: "%"
            type: u4
          - id: physical_total
            -orig-id:
              - dwTotalPhys
              - ullTotalPhys
            type: u8
          - id: physical_available
            -orig-id:
              - dwAvailPhys
              - ullAvailPhys
            type: u8
          - id: page_total
            -orig-id:
              - dwTotalPageFile
              - ullTotalPageFile
            type: u8
          - id: page_available
            -orig-id:
              - dwAvailPageFile
              - ullAvailPageFile
            type: u8
          - id: virtual_total
            -orig-id:
              - dwTotalVirtual
              - ullTotalVirtual
            type: u8
          - id: virtual_available
            -orig-id:
              - dwAvailVirtual
              - ullAvailVirtual
            type: u8
        instances:
          memory_load:
            value: memory_load_percent / 100.

      extended:
        seq:
          - id: virtual_available_extended
            -orig-id: ullAvailExtendedVirtual
            type: u8
