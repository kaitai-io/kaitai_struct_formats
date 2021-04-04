meta:
  id: pcx_dcx
  file-extension: dcx
  xref:
    justsolve: DCX
    mime: image/x-dcx
    pronom: x-fmt/348
    wikidata: Q28205890
  license: CC0-1.0
  imports:
    - pcx
  endian: le
doc: |
  DCX is a simple extension of PCX image format allowing to bundle
  many PCX images (typically, pages of a document) in one file. It saw
  some limited use in DOS-era fax software, but was largely
  superseded with multi-page TIFFs and PDFs since then.
seq:
  - id: magic
    contents: [0xb1, 0x68, 0xde, 0x3a]
  - id: files
    type: pcx_offset
    repeat: until
    repeat-until: _.ofs_body == 0
types:
  pcx_offset:
    seq:
      - id: ofs_body
        type: u4
    instances:
      body:
        pos: ofs_body
        type: pcx
        if: ofs_body != 0
