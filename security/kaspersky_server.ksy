meta:
  id: kasperskyserver
  endian: le
  title: Kaspersky for Windows Server quarantine file parser
  license: CC-BY-SA-4.0
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  License: CC-BY-SA-4.0 https://creativecommons.org/licenses/by-sa/4.0/
seq:
  - id: mal_file
    process: xor([0xe2, 0x45, 0x48, 0xec, 0x69, 0x0e, 0x5c, 0xac])
    size-eos: true
