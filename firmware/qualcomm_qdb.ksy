meta:
  id: qualcomm_qdb
  title: Qualcomm Qshrink hash database file
  application: Qualcomm QXDM
  file-extension: qdb
  license: CC0-1.0

doc: |
  This format is nothing more than zlib-compressed text appended to a trivially
  simple binary header. The text, which is almost but not quite XML, maps
  diagnostic codes emitted by Qualcomm modem firmware to textual log messages.
  A file of this type typically resides on the "modem" partition of a Qualcomm
  device with a name like "qdsp6m.qdb".

doc-ref:
  - https://github.com/mzakocs/qualcomm_baseband_scripts/blob/main/qshrink4_qdb_ghidra_script.py

seq:
  - id: magic
    contents: [0x7f, "QDB"]
  - id: guid
    size: 0x10
    doc: Matches the content's top-level <GUID> element

instances:
  content:
    pos: 0x40
    size-eos: true
    process: zlib
    doc: zlib-compressed text containing mapping entries and metadata
