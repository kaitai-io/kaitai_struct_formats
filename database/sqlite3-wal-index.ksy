meta:
  id: sqlite3_wal_index
  file-extension:
    - sqlite-shm
    - db-shm
    - db3-shm
    - sqlite3-shm
doc: |
  SQLite3 is a popular serverless SQL engine, implemented as a library
  to be used within other applications. It keeps its databases as
  regular disk files.

  Write-Ahead Logging (WAL) is a journaling mode that enhances
  performance and allow more concurrency than the default rollback
  journal.

  The WAL Index is a shared memory object that allows faster lookup of
  pages stored in the WAL journal.
doc-ref:
  - https://www.sqlite.org/wal.html
  - https://sqlite.org/src/file?name=src/wal.c&ci=trunk
seq:
  - id: header
    type: header
  - id: header2
    type: header
  - id: ckpt_info
    type: ckpt_info
  - id: first_block
    type: index_block_one
  - id: index_blocks
    type: index_block
    repeat: eos

types:
  header:
    seq:
      - id: version
        type: b32
      - id: unused
        type: b32
      - id: change
        type: b32
      - id: init
        type: b8
      - id: big_end_cksum
        type: b8
      - id: page
        type: b16
      - id: mx_frame
        type: b32
      - id: n_page
        type: b32
      - id: frame_cksum_0
        type: b32
      - id: frame_cksum_1
        type: b32
      - id: salt_0
        type: b32
      - id: salt_1
        type: b32
      - id: cksum_0
        type: b32
      - id: cksum_1
        type: b32
  ckpt_info:
    seq:
      - id: n_backfill
        type: b32
      - id: read_mark
        type: read_mark_array
      - id: lock
        type: lock_array
      - id: n_backfill_attempted
        type: b32
      - id: not_used
        type: b32
  lock_array:
    seq:
      - id: lock
        type: b8
        repeat: expr
        repeat-expr: 8 # SQLITE_SHM_NLOCK
  read_mark_array:
    seq:
      - id: read_mark
        type: b32
        repeat: expr
        repeat-expr: 5 # WAL_NREADER
  index_block_one:
    seq:
      - id: page_mapping
        type: page_mapping_one
      - id: hash_table
        type: hash_table
  page_mapping_one:
    seq:
      - id: page_number
        type: b32
        repeat: expr
        repeat-expr: 4062 # HASHTABLE_NPAGE_ONE
  index_block:
    seq:
      - id: page_mapping
        type: page_mapping_one
      - id: hash_table
        type: hash_table
  page_mapping:
    seq:
      - id: page_number
        type: b32
        repeat: expr
        repeat-expr: 4096 # HASHTABLE_NPAGE
  hash_table:
    seq:
      - id: hash
        type: b16
        repeat: expr
        repeat-expr: 2*4096 # HASHTABLE_NSLOT

