meta:
  id: windows_system_info
  title: Microsoft Windows SYSTEM_INFO structure
  license: Unlicese
  endian: le
  imports:
    - /windows/windows_processor_architecture
    - /windows/windows_processor_type
    - /windows/windows_processor_revision
doc-ref:
  - https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info
  - https://learn.microsoft.com/en-us/previous-versions/ms942639(v=msdn.10)
  - https://learn.microsoft.com/en-us/windows/win32/api/minidumpapiset/ns-minidumpapiset-minidump_system_info
seq:
  - id: oem_id
    size: 4
    type: windows_processor_architecture
  - id: page_size
    -orig-id: dwPageSize
    type: u4
  - id: min_app_address
    -orig-id: lpMinimumApplicationAddress
    type: u8
  - id: max_app_address
    -orig-id: lpMaximumApplicationAddress
    type: u8
  - id: cpu_mask
    -orig-id: dwActiveProcessorMask
    type: u8
  - id: cpu_count
    -orig-id: dwNumberOfProcessors
    type: u4
  - id: processor_type
    -orig-id: dwProcessorType
    type: windows_processor_type
  - id: allocation_granularity
    -orig-id: dwAllocationGranularity
    type: u4
  - id: processor_level
    -orig-id: wProcessorLevel
    type: u2
    doc: |
      Impl-defined processor level.
      Usually one-digit number. For example
      1 - PPC 601
      5 - i586
      4 - MIPS R4000
      General rule of thumb - larger the digit - better.
  - id: processor_revision
    -orig-id: wProcessorRevision
    size: 2
    type: windows_processor_revision(oem_id, processor_level)
