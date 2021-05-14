meta:
  id: sqlite3
  title: SQLite3 database file
  file-extension:
    - sqlite
    - db
    - db3
    - sqlite3
  xref:
    forensicswiki: SQLite_database_format
    justsolve: SQLite
    loc: fdd000461
    pronom: fmt/729
    wikidata: Q28600453
  license: CC0-1.0
  imports:
    - /common/vlq_base128_be
  endian: be
doc: |
  SQLite3 is a popular serverless SQL engine, implemented as a library
  to be used within other applications. It keeps its databases as
  regular disk files.

  Every database file is segmented into pages. First page (starting at
  the very beginning) is special: it contains a file-global header
  which specifies some data relevant to proper parsing (i.e. format
  versions, size of page, etc). After the header, normal contents of
  the first page follow.

  Each page would be of some type, and generally, they would be
  reached via the links starting from the first page. First page type
  (`root_page`) is always "btree_page".
doc-ref: https://www.sqlite.org/fileformat.html
seq:
  - id: magic
    contents: ["SQLite format 3", 0]
  - id: len_page_mod
    type: u2
    doc: |
      The database page size in bytes. Must be a power of two between
      512 and 32768 inclusive, or the value 1 representing a page size
      of 65536.
  - id: write_version
    type: u1
    enum: versions
  - id: read_version
    type: u1
    enum: versions
  - id: reserved_space
    type: u1
    doc: Bytes of unused "reserved" space at the end of each page. Usually 0.
  - id: max_payload_frac
    type: u1
    doc: Maximum embedded payload fraction. Must be 64.
  - id: min_payload_frac
    type: u1
    doc: Minimum embedded payload fraction. Must be 32.
  - id: leaf_payload_frac
    type: u1
    doc: Leaf payload fraction. Must be 32.
  - id: file_change_counter
    type: u4
  - id: num_pages
    type: u4
    doc: Size of the database file in pages. The "in-header database size".
  - id: first_freelist_trunk_page
    type: u4
    doc: Page number of the first freelist trunk page.
  - id: num_freelist_pages
    type: u4
    doc: Total number of freelist pages.
  - id: schema_cookie
    type: u4
  - id: schema_format
    type: u4
    doc: The schema format number. Supported schema formats are 1, 2, 3, and 4.
  - id: def_page_cache_size
    type: u4
    doc: Default page cache size.
  - id: largest_root_page
    type: u4
    doc: The page number of the largest root b-tree page when in auto-vacuum or incremental-vacuum modes, or zero otherwise.
  - id: text_encoding
    type: u4
    enum: encodings
    doc: The database text encoding. A value of 1 means UTF-8. A value of 2 means UTF-16le. A value of 3 means UTF-16be.
  - id: user_version
    type: u4
    doc: The "user version" as read and set by the user_version pragma.
  - id: is_incremental_vacuum
    type: u4
    doc: True (non-zero) for incremental-vacuum mode. False (zero) otherwise.
  - id: application_id
    type: u4
    doc: The "Application ID" set by PRAGMA application_id.
  - id: reserved
    size: 20
  - id: version_valid_for
    type: u4
  - id: sqlite_version_number
    type: u4
  - id: root_page
    type: btree_page
instances:
  len_page:
    value: 'len_page_mod == 1 ? 0x10000 : len_page_mod'
types:
  btree_page:
    seq:
      - id: page_type
        type: u1
      - id: first_freeblock
        type: u2
      - id: num_cells
        type: u2
      - id: ofs_cells
        type: u2
      - id: num_frag_free_bytes
        type: u1
      - id: right_ptr
        type: u4
        if: page_type == 2 or page_type == 5
      - id: cells
        type: ref_cell
        repeat: expr
        repeat-expr: num_cells
  ref_cell:
    seq:
      - id: ofs_body
        type: u2
    instances:
      body:
        pos: ofs_body
        type:
          switch-on: _parent.page_type
          cases:
            0x0d: cell_table_leaf
            0x05: cell_table_interior
            0x0a: cell_index_leaf
            0x02: cell_index_interior
  cell_table_leaf:
    doc-ref: 'https://www.sqlite.org/fileformat.html#b_tree_pages'
    seq:
      - id: len_payload
        type: vlq_base128_be
      - id: row_id
        type: vlq_base128_be
      - id: payload
        size: len_payload.value
        type: cell_payload
      # TODO: overflow
  cell_table_interior:
    doc-ref: 'https://www.sqlite.org/fileformat.html#b_tree_pages'
    seq:
      - id: left_child_page
        type: u4
      - id: row_id
        type: vlq_base128_be
  cell_index_leaf:
    doc-ref: 'https://www.sqlite.org/fileformat.html#b_tree_pages'
    seq:
      - id: len_payload
        type: vlq_base128_be
      - id: payload
        size: len_payload.value
        type: cell_payload
      # TODO: overflow
  cell_index_interior:
    doc-ref: 'https://www.sqlite.org/fileformat.html#b_tree_pages'
    seq:
      - id: left_child_page
        type: u4
      - id: len_payload
        type: vlq_base128_be
      - id: payload
        size: len_payload.value
        type: cell_payload
  cell_payload:
    doc-ref: 'https://sqlite.org/fileformat2.html#record_format'
    seq:
      - id: len_header_and_len
        type: vlq_base128_be
      - id: column_serials
        size: len_header_and_len.value - 1
        type: serials
      - id: column_contents
        repeat: expr
        repeat-expr: column_serials.entries.size
        type: column_content(column_serials.entries[_index])
  serials:
    seq:
      - id: entries
        type: vlq_base128_be
        repeat: eos
  serial:
    seq:
      - id: code
        type: vlq_base128_be
    instances:
      is_blob:
        value: 'code.value >= 12 and (code.value % 2 == 0)'
      is_string:
        value: 'code.value >= 13 and (code.value % 2 == 1)'
      len_content:
        value: (code.value - 12) / 2
        if: code.value >= 12
  column_content:
    params:
      - id: ser
        type: struct
    seq:
      - id: as_int
        type:
          switch-on: serial_type.code.value
          cases:
            1: u1
            2: u2
            3: b24
            4: u4
            5: b48
            6: u8
        if: serial_type.code.value >= 1 and serial_type.code.value <= 6
      - id: as_float
        type: f8
        if: serial_type.code.value == 7
      - id: as_blob
        size: serial_type.len_content
        if: serial_type.is_blob
      - id: as_str
        type: str
        size: serial_type.len_content
        encoding: UTF-8
#        if: _root.text_encoding == encodings::utf_8 and serial_type.is_string
    instances:
      serial_type:
        value: ser.as<serial>
enums:
  versions:
    1: legacy
    2: wal
  encodings:
    1: utf_8
    2: utf_16le
    3: utf_16be
