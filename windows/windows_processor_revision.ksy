meta:
  id: windows_processor_revision
  title: Microsoft Windows `wProcessorRevision` field of various structures, describing processor revision
  license: Unlicese
  endian: le
  ks-opaque-types: true
  -affected-by: 703
  imports:
    - /windows/windows_processor_architecture
doc-ref:
  - https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info
  - https://learn.microsoft.com/en-us/previous-versions/ms942639(v=msdn.10)
  - https://learn.microsoft.com/en-us/windows/win32/api/minidumpapiset/ns-minidumpapiset-minidump_system_info
doc: |
  Decodes the info about Windows processor revision.
-orig-id: wProcessorRevision
params:
  - id: oem_id
    type: windows_processor_architecture
  - id: level
    type: u2
seq:
  - id: revision
    -orig-id: wProcessorRevision
    size: 2
    type:
      switch-on: oem_id.arch
      cases:
        windows_processor_architecture::arch::intel: rev_x86
        windows_processor_architecture::arch::x86_64: rev_x86
        windows_processor_architecture::arch::ia32_on_win64: rev_x86
        windows_processor_architecture::arch::mips: rev_mips
        windows_processor_architecture::arch::alpha: rev_alpha
        windows_processor_architecture::arch::alpha64: rev_alpha
        windows_processor_architecture::arch::ppc: rev_ppc
        _: u2
types:
  rev_x86:
    seq:
      - id: revision
        size: 2
        type:
          switch-on: _parent.level
          cases:
            0: u2
            1: u2
            2: u2
            3: u2
            4: rev_i486
            _: rev_i586
    types:
      rev_i486:
        seq:
          - id: value
            size: 1
            type:
              switch-on: hi
              cases:
                0xFF: v1
                _: v2(hi)
        instances:
          hi:
            pos: 1
            type: u1
        types:
          v1:
            seq:
              - id: y
                type: b4
              - id: stepping_id
                type: b4
            instances:
              model_no:
                value: y - 0xA
          v2:
            params:
              - id: xx
                type: u1
            seq:
              - id: minor_stepping
                type: u1
            instances:
              stepping_letter:
                value: xx + 0x41
      rev_i586:
        seq:
          - id: stepping
            type: u1
          - id: model
            type: u1
  rev_mips:
    seq:
      - id: revision
        type: u1
        doc: low-order 8 bits of the PRId register
      - id: unkn
        type: u1
        doc: according to the docs are 0
  rev_alpha:
    doc: low-order 16 bits of the processor revision number from the firmware
    seq:
      - id: pass
        type: u1
        doc: low-order 8 bits of the PRId register
      - id: model
        type: u1
  rev_ppc:
    doc: low-order 16 bits of the Processor Version Register
    seq:
      - id: minor
        type: u1
      - id: major
        type: u1
