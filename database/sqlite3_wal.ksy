meta:
  id: sqlite3_wal
  file-extension:
    - sqlite-wal
    - db-wal
    - db3-wal
    - sqlite3-wal
  endian: be
  license: CC0-1.0
doc: |
  SQLite3 is a popular serverless SQL engine, implemented as a library
  to be used within other applications. It keeps its databases as
  regular disk files.

  Write-Ahead Logging (WAL) is a journaling mode that enhances
  performance and allow more concurrency than the default rollback
  journal.
doc-ref:
  - https://www.sqlite.org/wal.html
  - https://sqlite.org/src/file?name=src/wal.c&ci=trunk
seq:
  - id: header
    type: header
  - id: frames
    type: frame
    repeat: eos
types:
  header:
    seq:
      - id: magic
        type: u4
        valid:
          any-of: [0x377f0682, 0x377f0683]
      - id: file_format_version
        type: u4
      - id: len_database_page
        type: u4
      - id: checkpoint_sequence_number
        type: u4
      - id: salt1
        type: u4
      - id: salt2
        type: u4
      - id: checksum1
        type: u4
      - id: checksum2
        type: u4
  frame:
    seq:
      - id: frame_header
        type: frame_header
      - id: page_data
        size: _root.header.len_database_page
  frame_header:
    seq:
      - id: page_number
        type: u4
      - id: commit_db_pages
        type: u4
      - id: salt1
        type: u4
      - id: salt2
        type: u4
      - id: checksum1
        type: u4
      - id: checksum2
        type: u4
