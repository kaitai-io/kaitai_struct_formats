meta:
  id: csv
  title: Comma-separated values
  application: 
  file-extension: csv
  xref:
    fileformat: csv
    justsolve: CSV
    loc: fdd000323
    mime: text/csv
    pronom: x-fmt/18
    rfc: 4180
    wikidata: Q935809
  encoding: UTF-8
  license: Unlicense

doc: |
  a widespread format where values and lines are separated by something. For now it is only CSV because of Kaitai limitations.

seq:
  - id: rows
    type: row
    terminator: 10
    eos-error: false
    repeat: eos
types:
  row:
    seq:
      - id: cells
        type: str
        terminator: 44
        eos-error: false
        repeat: eos
