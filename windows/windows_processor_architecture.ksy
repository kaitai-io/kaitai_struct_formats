meta:
  id: windows_processor_architecture
  title: Microsoft Windows `dwOemId` union or just its `wProcessorArchitecture` field of various structures, describing general processor architecture
  license: Unlicese
  endian: le
doc-ref:
  - https://learn.microsoft.com/en-us/previous-versions/ms942639(v=msdn.10)
  - https://github.com/reactos/reactos/blob/fe777bb52f67921b26bf5791b06a5c712f5be3f6/sdk/include/ndk/ketypes.h#L105-L115
  - https://github.com/reactos/reactos/blob/4363e74ddcb26a528c2723ab0afe5af3443bde6f/sdk/include/xdk/winnt_old.h#L448-L458
  - https://github.com/mirror/mingw-w64/blob/0f2264e7b8fedbe225921367e82aeb97ddfed46b/mingw-w64-headers/include/winnt.h#L5472-L5488
doc: |
  Stores the info about Windows processor archiectures. By default takes 4 bytes with the second `reserved` field`. Limit to 2 bytes if you don't need that.
-orig-id: dwOemId
seq:
  - id: arch
    -orig-id: wProcessorArchitecture
    type: u2
    enum: arch
  - id: reserved
    -orig-id: wReserved
    type: u2
    if: with_reserved
instances:
  with_reserved:
    value: _io.size - _io.pos >= 2
  oem_id:
    -orig-id: dwOemId
    value: (reserved << 16) | arch.to_i
    if: with_reserved
enums:
  arch:
    0:
      id: intel
      -orig-id: PROCESSOR_ARCHITECTURE_INTEL
      doc: x86
    1:
      id: mips
      -orig-id: PROCESSOR_ARCHITECTURE_MIPS
    2:
      id: alpha
      -orig-id: PROCESSOR_ARCHITECTURE_ALPHA
    3:
      id: ppc
      -orig-id: PROCESSOR_ARCHITECTURE_PPC
    4:
      id: superh
      -orig-id: PROCESSOR_ARCHITECTURE_SHX
      doc: undocumented
    5:
      id: arm32
      -orig-id: PROCESSOR_ARCHITECTURE_ARM
    6:
      id: ia64
      -orig-id: PROCESSOR_ARCHITECTURE_IA64
    7:
      id: alpha64
      -orig-id: PROCESSOR_ARCHITECTURE_ALPHA64
      doc: undocumented
    8:
      id: msil
      -orig-id: PROCESSOR_ARCHITECTURE_MSIL
      doc: intermediate language for CLR, including OptIL
    9:
      id: x86_64
      -orig-id: PROCESSOR_ARCHITECTURE_AMD64
    10:
      id: ia32_on_win64
      -orig-id: PROCESSOR_ARCHITECTURE_IA32_ON_WIN64
    11:
      id: neutral
      -orig-id: PROCESSOR_ARCHITECTURE_NEUTRAL
    12:
      id: aarch64
      -orig-id: PROCESSOR_ARCHITECTURE_ARM64
      doc: ARM64
    13:
      id: arm32_on_win64
      -orig-id: PROCESSOR_ARCHITECTURE_ARM32_ON_WIN64
    14:
      id: ia32_on_arm64
      -orig-id: PROCESSOR_ARCHITECTURE_IA32_ON_ARM64
    0xFFFF:
      id: unknown
      -orig-id: PROCESSOR_ARCHITECTURE_UNKNOWN
