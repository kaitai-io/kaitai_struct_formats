meta:
  id: windows_platform_binary_table
  title: Windows Platform Binary Table
  license: Unlicense
  ks-version: 0.9
  bit-endian: le
  encoding: utf-8
  endian: le

doc-ref: https://download.microsoft.com/download/8/A/2/8A2FB72D-9B96-4E2D-A559-4A27CF905A80/windows-platform-binary-table.docx
doc: |
  Windows platform Binary table is a file format enablind vendors to preinstall eiter needed essential software, or malware and spyware.

seq:
  - id: handoff_memory_size
    type: u4
  - id: handoff_memory_location
    type: u8
  - id: content_layout
    -orig-id: Content Layout
    type: u1
    enum: layout
  - id: content_type
    -orig-id: Content Type
    type: u1
    enum: type
  - id: arguments
    -orig-id: Content Type–Specific Fields
    type:
      switch-on: content_type
      cases:
        type::native_executable: native_executable_args

instances:
  handoff_memory_buffer:
    pos: handoff_memory_location
    size: handoff_memory_size

types:
  native_executable_args:
    -orig-id: Type 1–Specific (native user-mode application)
    seq:
      - id: length
        type: u2
      - id: arguments
        size: length
        type: str

enums:
  layout:
    1:
      id: pe
  type:
    1:
      id: native_executable
      -orig-id: native user-mode application
      doc-ref:
        - https://docs.microsoft.com/en-us/sysinternals/resources/inside-native-applications
        - https://conshell.net/wiki/Native_Executables_(Windows)
