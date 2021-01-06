meta:
  id: dbf
  application: dBASE
  file-extension: dbf
  xref:
    justsolve: DBF
    loc: fdd000325
    mime:
      - application/dbf
      - application/dbase
    pronom:
      - x-fmt/8 # dBASE Database II
      - x-fmt/9 # dBASE Database III
      - x-fmt/271 # dBASE Database III+
      - x-fmt/10 # dBASE Database IV
      - x-fmt/272 # dBASE Database V
    wikidata: Q16545707
  license: CC0-1.0
  endian: le
doc: |
  .dbf is a relational database format introduced in DOS database
  management system dBASE in 1982.

  One .dbf file corresponds to one table and contains a series of headers,
  specification of fields, and a number of fixed-size records.
doc-ref: http://www.dbase.com/Knowledgebase/INT/db7_file_fmt.htm
seq:
  - id: header1
    type: header1
  - id: header2
    size: header1.len_header - 12
    type: header2
  - id: records
    size: header1.len_record
    repeat: expr
    repeat-expr: header1.num_records
types:
  header1:
    doc-ref: http://www.dbase.com/Knowledgebase/INT/db7_file_fmt.htm - section 1.1
    seq:
      - id: version
        type: u1
      - id: last_update_y
        type: u1
      - id: last_update_m
        type: u1
      - id: last_update_d
        type: u1
      - id: num_records
        type: u4
      - id: len_header
        type: u2
      - id: len_record
        type: u2
    instances:
      dbase_level:
        value: 'version & 0b111'
  header2:
    seq:
      - id: header_dbase_3
        if: _root.header1.dbase_level == 3
        type: header_dbase_3
      - id: header_dbase_7
        if: _root.header1.dbase_level == 7
        type: header_dbase_7
      - id: fields
        type: field
        repeat: expr
        repeat-expr: 11
  header_dbase_3:
    seq:
      - id: reserved1
        size: 3
      - id: reserved2
        size: 13
      - id: reserved3
        size: 4
  header_dbase_7:
    seq:
      - id: reserved1
        contents: [0, 0]
      - id: has_incomplete_transaction
        type: u1
      - id: dbase_iv_encryption
        type: u1
      - id: reserved2
        size: 12
      - id: production_mdx
        type: u1
      - id: language_driver_id
        type: u1
      - id: reserved3
        contents: [0, 0]
      - id: language_driver_name
        size: 32
      - id: reserved4
        size: 4
  field:
    seq:
      - id: name
        type: strz
        encoding: ASCII
        size: 11
      - id: datatype
        type: u1
      - id: data_address
        type: u4
      - id: length
        type: u1
      - id: decimal_count
        type: u1
      - id: reserved1
        size: 2
      - id: work_area_id
        type: u1
      - id: reserved2
        size: 2
      - id: set_fields_flag
        type: u1
      - id: reserved3
        size: 8
