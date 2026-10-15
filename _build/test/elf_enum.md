# ELF processor-specific enums

`elf_enum.js` compiles `executable/elf.ksy` with Kaitai Struct 0.11 and parses
480 complete ELF fixtures. It covers both ELF classes and byte orders, the
overlapping ARM/x86-64 unwind types, ARM/AArch64 attributes and overlay types,
all supported SPARC machine variants, RISC-V program headers, unknown values
and architectures, and common/GNU/LLVM values across four OS ABIs. It also
checks section and segment body dispatch, including GNU version sections,
string tables, interpreter strings and NOBITS sections.

Install the dependencies in a temporary directory, then run from the repository
root (POSIX shell):

```sh
npm install --prefix /tmp/kaitai-elf-test kaitai-struct-compiler@0.11.0 kaitai-struct@0.11.0 yaml@2.8.1
NODE_PATH=/tmp/kaitai-elf-test/node_modules node _build/test/elf_enum.js
```

In PowerShell:

```powershell
npm install --prefix "$env:TEMP\kaitai-elf-test" kaitai-struct-compiler@0.11.0 kaitai-struct@0.11.0 yaml@2.8.1
$env:NODE_PATH = "$env:TEMP\kaitai-elf-test\node_modules"
node _build/test/elf_enum.js
```

Optional arguments select another KSY file and export the binary fixtures with
a JSON manifest. Running against the original `elf.ksy` fails on the first ARM
fixture because `0x70000001` is incorrectly labeled `X86_64_UNWIND`.

## Accessing processor-specific types

`type_raw` preserves the original 32-bit value. `type` remains the common and
OS-specific enum view, so existing body dispatch and common enum comparisons
continue to work. Processor-specific members have moved into dedicated enums:

| Header | ELF machine | Instance | Enum |
| --- | --- | --- | --- |
| Section | ARM | `type_arm` | `sh_type_arm` |
| Section | AArch64 | `type_aarch64` | `sh_type_aarch64` |
| Section | x86-64 | `type_x86_64` | `sh_type_x86_64` |
| Section | SPARC, SPARC32PLUS, SPARCV9 | `type_sparc` | `sh_type_sparc` |
| Program | ARM | `type_arm` | `ph_type_arm` |
| Program | AArch64 | `type_aarch64` | `ph_type_aarch64` |
| Program | RISC-V | `type_riscv` | `ph_type_riscv` |

These instances are present only for the matching machine and the
`0x70000000..0x7fffffff` processor-specific range. Enum member names omit the
architecture prefix: for example, use `section.type_arm == sh_type_arm::exidx`
or `section.type_x86_64 == sh_type_x86_64::unwind`. The Web IDE eagerly evaluates
the applicable view.

Separate enums avoid duplicate keys without widening enum values beyond 32
bits. In Kaitai Struct 0.11, the 64-bit encoding suggested in issue #764 would
generate C# enum constants that do not fit the default `int` underlying type.
Common OS-range values are deliberately kept in the common enums: GNU and LLVM
extensions do not necessarily match the ELF header's OS ABI.
