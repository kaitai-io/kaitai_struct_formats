meta:
  id: windows_processor_type
  title: Microsoft Windows `dwProcessorType` field of various structures, describing processor concrete type
  license: Unlicese
  endian: le
doc-ref:
  - https://learn.microsoft.com/en-us/previous-versions/ms942639(v=msdn.10)
  - https://github.com/reactos/reactos/blob/4363e74ddcb26a528c2723ab0afe5af3443bde6f/sdk/include/xdk/winnt_old.h#L423-L447
  - https://github.com/mirror/mingw-w64/blob/0f2264e7b8fedbe225921367e82aeb97ddfed46b/mingw-w64-headers/include/winnt.h#L5448-L5470
  - https://learn.microsoft.com/en-us/windows/win32/api/minidumpapiset/ns-minidumpapiset-minidump_system_info
doc: |
  Contains the info about Windows processor types.
-orig-id: dwProcessorType
seq:
  - id: type
    type: u4
    enum: type
enums:
  type:
    386:
      id: x86_i386
      -orig-id: PROCESSOR_INTEL_386
    486:
      id: x86_i486
      -orig-id: PROCESSOR_INTEL_486
    586:
      id: x86_i586
      -orig-id: PROCESSOR_INTEL_PENTIUM
    8664:
      id: x86_64
      -orig-id: PROCESSOR_AMD_X8664
    2200:
      id: ia64
      -orig-id: PROCESSOR_INTEL_IA64

    18767:
      id: optil
      -orig-id: PROCESSOR_OPTIL

    0x720:
      id: arm_720
      -orig-id: PROCESSOR_ARM720
    0x820:
      id: arm_820
      -orig-id: PROCESSOR_ARM820
    0x920:
      id: arm_920
      -orig-id: PROCESSOR_ARM920
    70001:
      id: arm_7tdmi
      -orig-id: PROCESSOR_ARM_7TDMI
    2577:
      id: arm_strongarm
      -orig-id: PROCESSOR_STRONGARM

    4000:
      id: mips_r4000
      -orig-id: PROCESSOR_MIPS_R4000
    2000:
      id: mips_r2000
      -orig-id: PROCESSOR_MIPS_R2000
    3000:
      id: mips_r3000
      -orig-id: PROCESSOR_MIPS_R3000

    21064:
      id: alpha_21064
      -orig-id: PROCESSOR_ALPHA_21064

    601:
      id: ppc_601
      -orig-id: PROCESSOR_PPC_601
    603:
      id: ppc_603
      -orig-id: PROCESSOR_PPC_603
    604:
      id: ppc_604
      -orig-id: PROCESSOR_PPC_604
    620:
      id: ppc_620
      -orig-id: PROCESSOR_PPC_620

    860:
      id: intel_860
      -orig-id: PROCESSOR_INTEL_860
      doc: is it Xeon?

    10003:
      id: superh_hitachi_3
      -orig-id: PROCESSOR_HITACHI_SH3
    10004:
      id: superh_hitachi_3e
      -orig-id: PROCESSOR_HITACHI_SH3E
    10005:
      id: superh_hitachi_4
      -orig-id: PROCESSOR_HITACHI_SH4
    103:
      id: superh_shx_3
      -orig-id: PROCESSOR_SHx_SH3
    104:
      id: superh_shx_4
      -orig-id: PROCESSOR_SHx_SH4

    821:
      id: motorola_821
      -orig-id: PROCESSOR_MOTOROLA_821
