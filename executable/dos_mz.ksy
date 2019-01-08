meta:
  id: dos_mz
  title: DOS MZ executable
  file-extension:
    - exe
    - ovl
  xref:
    justsolve: MS-DOS_EXE
    pronom: x-fmt/409
    wikidata: Q1882110
  license: CC0-1.0
  endian: le
doc: |
  DOS MZ file format is a traditional format for executables in MS-DOS
  environment. Many modern formats (i.e. Windows PE) still maintain
  compatibility stub with this format.

  As opposed to .com file format (which basically sports one 64K code
  segment of raw CPU instructions), DOS MZ .exe file format allowed
  more flexible memory management, loading of larger programs and
  added support for relocations.
seq:
  - id: hdr
    type: mz_header
  - id: mz_header2
    size: hdr.ofs_relocations - 0x1c
  - id: relocations
    type: relocation
    repeat: expr
    repeat-expr: hdr.num_relocations
  - id: body
    size-eos: true
types:
  mz_header:
    seq:
      - id: magic
        size: 2
      - id: last_page_extra_bytes
        type: u2
      - id: num_pages
        type: u2
      - id: num_relocations
        type: u2
      - id: header_size
        type: u2
      - id: min_allocation
        type: u2
      - id: max_allocation
        type: u2
      - id: initial_ss
        type: u2
      - id: initial_sp
        type: u2
      - id: checksum
        type: u2
      - id: initial_ip
        type: u2
      - id: initial_cs
        type: u2
      - id: ofs_relocations
        type: u2
      - id: overlay_id
        type: u2
  relocation:
    seq:
      - id: ofs
        type: u2
      - id: seg
        type: u2
#instances:
#  relocations:
#    pos: ofs_relocations
#    type: relocation
#    repeat: expr
#    repeat-expr: hdr.num_relocations
