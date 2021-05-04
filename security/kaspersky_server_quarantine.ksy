meta:
  id: kaspersky_server_quarantine
  endian: le
  title: Kaspersky for Windows Server quarantine file
  license: MIT
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  Kaspersky Server quarantine files are created by Kaspersky for Windows Server.
  They store suspected malware. The malware is encrypted using an 8-byte XOR key.
  Metadata is stored separately in an SQLite database.
  The parser was created by analyzing different quarantine files.
doc-ref: https://github.com/ernw/quarantine-formats/blob/master/docs/Kaspersky_for_Windows_Server.md
seq:
  - id: mal_file
    process: xor([0xe2, 0x45, 0x48, 0xec, 0x69, 0x0e, 0x5c, 0xac])
    size-eos: true
