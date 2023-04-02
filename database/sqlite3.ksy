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

  Each page would be of some type (btree, ptrmap, lock_byte, or free),
  and generally, they would be reached via the links starting from the
  first page. The first page is always a btree page for the implicitly
  defined `sqlite_schema` table.
doc-ref: https://www.sqlite.org/fileformat.html
seq:
  - id: header
    type: database_header
instances:
  pages:
    type:
      switch-on: '(_index == header.lock_byte_page_index ? 0 : _index >= header.first_ptrmap_page_index and _index <= header.last_ptrmap_page_index ? 1 : 2)'
      cases:
        0: lock_byte_page(_index + 1)
        1: ptrmap_page(_index + 1)
        # TODO: Free pages and cell overflow pages are incorrectly interpreted as btree pages
        # This is unfortunate, but unavoidable since there's no way to recognize these types at
        # this point in the parser.
        2: btree_page(_index + 1)
    pos: 0
    size: header.page_size
    repeat: expr
    repeat-expr: header.num_pages
types:
  database_header:
    seq:
      - id: magic
        contents: ["SQLite format 3", 0]
      - id: page_size_raw
        type: u2
        doc: |
          The database page size in bytes. Must be a power of two between
          512 and 32768 inclusive, or the value 1 representing a page size
          of 65536. The interpreted value is available as `page_size`.
      - id: write_version
        type: u1
        enum: format_version
        doc: File format write version
      - id: read_version
        type: u1
        enum: format_version
        doc: File format read version
      - id: page_reserved_space_size
        type: u1
        doc: Bytes of unused "reserved" space at the end of each page. Usually 0.
      - id: max_payload_fraction
        type: u1
        doc: Maximum embedded payload fraction. Must be 64.
      - id: min_payload_fraction
        type: u1
        doc: Minimum embedded payload fraction. Must be 32.
      - id: leaf_payload_fraction
        type: u1
        doc: Leaf payload fraction. Must be 32.
      - id: file_change_counter
        type: u4
      - id: num_pages
        type: u4
        doc: Size of the database file in pages. The "in-header database size".
      - id: first_freelist_trunk_page
        type: freelist_trunk_page_pointer
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
      - id: reserved_header_bytes
        size: 20
      - id: version_valid_for
        type: u4
      - id: sqlite_version_number
        type: u4
    instances:
      page_size:
        value: 'page_size_raw == 1 ? 0x10000 : page_size_raw'
        doc: The database page size in bytes
      usable_size:
        value: 'page_size - page_reserved_space_size'
        doc: The "usable size" of a database page
      overflow_min_payload_size:
        value: ((usable_size-12)*32/255)-23
        doc: The minimum amount of payload that must be stored on the btree page before spilling is allowed
      table_max_overflow_payload_size:
        value: usable_size - 35
        doc: The maximum amount of payload that can be stored directly on the b-tree page without spilling onto an overflow page. Value for table page
      index_max_overflow_payload_size:
        value: ((usable_size-12)*64/255)-23
        doc: The maximum amount of payload that can be stored directly on the b-tree page without spilling onto an overflow page. Value for index page
      idx_lock_byte_page:
        value: '1073741824 / page_size'
      num_ptrmap_entries_max:
        value: usable_size/5
        doc: The maximum number of ptrmap entries per ptrmap page
      idx_first_ptrmap_page:
        value: 'largest_root_page > 0 ? 1 : 0'
        doc: The index (0-based) of the first ptrmap page
      num_ptrmap_pages:
        value: 'idx_first_ptrmap_page > 0 ? (num_pages / num_ptrmap_entries_max) + 1 : 0'
        doc: The number of ptrmap pages in the database
      idx_last_ptrmap_page:
        value: 'idx_first_ptrmap_page + num_ptrmap_pages - (idx_first_ptrmap_page + num_ptrmap_pages >= idx_lock_byte_page ? 0 : 1)'
        doc: The index (0-based) of the last ptrmap page (inclusive)
  lock_byte_page:
    params:
      - id: page_number
        type: u4
    seq: []
    doc: |
      The lock-byte page is the single page of the database file that contains the bytes at offsets between
      1073741824 and 1073742335, inclusive. A database file that is less than or equal to 1073741824 bytes
      in size contains no lock-byte page. A database file larger than 1073741824 contains exactly one
      lock-byte page.
      The lock-byte page is set aside for use by the operating-system specific VFS implementation in implementing
      the database file locking primitives. SQLite does not use the lock-byte page.
  ptrmap_page:
    params:
      - id: page_number
        type: u4
    seq:
      - id: entries
        type: ptrmap_entry
        repeat: expr
        repeat-expr: num_entries
    instances:
      first_page:
        value: '3 + (_root.header.num_ptrmap_entries_max * (page_number - 2))'
      last_page:
        value: 'first_page + _root.header.num_ptrmap_entries_max - 1'
      num_entries:
        value: '(last_page > _root.header.num_pages ? _root.header.num_pages : last_page) - first_page + 1'
  ptrmap_entry:
    seq:
      - id: type
        type: u1
        enum: ptrmap_page_type
      - id: page_number
        type: u4
  btree_page_pointer:
    seq:
      - id: page_number
        type: u4
    instances:
      page:
        io: _root._io
        pos: (page_number - 1) * _root.header.page_size
        size: _root.header.page_size
        type: btree_page(page_number)
        if: page_number != 0
  btree_page:
    params:
      - id: page_number
        type: u4
    seq:
      - id: database_header
        type: database_header
        if: page_number == 1
      - id: page_type
        type: u1
        enum: btree_page_type
      - id: first_freeblock
        type: u2
        doc: The start of the first freeblock on the page, or is zero if there are no freeblocks.
      - id: num_cells
        type: u2
        doc: The number of cells on the page
      - id: ofs_cell_content_area_raw
        type: u2
        doc: |
          The start of the cell content area. A zero value for this integer is interpreted as 65536.
          The interpreted value is available as `cell_content_area`.
      - id: num_frag_free_bytes
        type: u1
        doc: The number of fragmented free bytes within the cell content area.
      - id: right_ptr
        type: btree_page_pointer
        if: page_type == btree_page_type::index_interior or page_type == btree_page_type::table_interior
        doc: |
          The right-most pointer. This value appears in the header of interior
          b-tree pages only and is omitted from all other pages.
      - id: cells
        type: cell_pointer
        repeat: expr
        repeat-expr: num_cells
    instances:
      ofs_cell_content_area:
        value: 'ofs_cell_content_area_raw == 0 ? 65536 : ofs_cell_content_area_raw'
      cell_content_area:
        pos: ofs_cell_content_area
        size: _root.header.usable_size - ofs_cell_content_area
      reserved_space:
        pos: _root.header.page_size - _root.header.page_reserved_space_size
        size-eos: true
        if: _root.header.page_reserved_space_size != 0
  cell_pointer:
    seq:
      - id: ofs_content
        type: u2
    instances:
      content:
        pos: ofs_content
        type:
          switch-on: _parent.page_type
          cases:
            btree_page_type::table_leaf: table_leaf_cell
            btree_page_type::table_interior: table_interior_cell
            btree_page_type::index_leaf: index_leaf_cell
            btree_page_type::index_interior: index_interior_cell
  table_leaf_cell:
    doc-ref: 'https://www.sqlite.org/fileformat.html#b_tree_pages'
    seq:
      - id: payload_size
        type: vlq_base128_be
      - id: row_id
        type: vlq_base128_be
      - id: payload
        type:
          switch-on: '(payload_size.value > _root.header.table_max_overflow_payload_size ? 1 : 0)'
          cases:
            0: record
            1: overflow_record(payload_size.value, _root.header.table_max_overflow_payload_size)
  table_interior_cell:
    doc-ref: 'https://www.sqlite.org/fileformat.html#b_tree_pages'
    seq:
      - id: left_child_page
        type: btree_page_pointer
      - id: row_id
        type: vlq_base128_be
  index_leaf_cell:
    doc-ref: 'https://www.sqlite.org/fileformat.html#b_tree_pages'
    seq:
      - id: payload_size
        type: vlq_base128_be
      - id: payload
        type:
          switch-on: '(payload_size.value > _root.header.index_max_overflow_payload_size ? 1 : 0)'
          cases:
            0: record
            1: overflow_record(payload_size.value, _root.header.index_max_overflow_payload_size)
  index_interior_cell:
    doc-ref: 'https://www.sqlite.org/fileformat.html#b_tree_pages'
    seq:
      - id: left_child_page
        type: btree_page_pointer
      - id: payload_size
        type: vlq_base128_be
      - id: payload
        type:
          switch-on: '(payload_size.value > _root.header.index_max_overflow_payload_size ? 1 : 0)'
          cases:
            0: record
            1: overflow_record(payload_size.value, _root.header.index_max_overflow_payload_size)
  record:
    doc-ref: 'https://sqlite.org/fileformat2.html#record_format'
    seq:
      - id: header_size
        type: vlq_base128_be
      - id: header
        type: record_header
        size: header_size.value - 1
      - id: values
        type: value(header.value_types[_index])
        repeat: expr
        repeat-expr: header.value_types.size
  record_header:
    seq:
      - id: value_types
        type: serial_type
        repeat: eos
  serial_type:
    -webide-representation: "{type:dec}"
    seq:
      - id: raw_value
        type: vlq_base128_be
    instances:
      type:
        value: 'raw_value.value >= 12 ? ((raw_value.value % 2 == 0) ? 12 : 13 + _root.header.text_encoding - 1) : raw_value.value'
        enum: serial
      variable_size:
        value: '(raw_value.value % 2 == 0) ? (raw_value.value - 12) / 2 : (raw_value.value - 13) / 2'
        if: raw_value.value >= 12
  value:
    params:
      - id: serial_type
        type: serial_type
    seq:
      - id: value
        type:
          switch-on: serial_type.type
          cases:
            serial::nil: null_value
            serial::two_comp_8: s1
            serial::two_comp_16: s2
            serial::two_comp_24: b24
            serial::two_comp_32: s4
            serial::two_comp_48: b48
            serial::two_comp_64: s8
            serial::ieee754_64: f8
            serial::integer_0: int_0
            serial::integer_1: int_1
            serial::blob: blob(serial_type.variable_size)
            serial::string_utf8: string_utf8(serial_type.variable_size)
            serial::string_utf16_le: string_utf16_le(serial_type.variable_size)
            serial::string_utf16_be: string_utf16_be(serial_type.variable_size)
  null_value:
    -webide-representation: "NULL"
    seq: []
  int_0:
    -webide-representation: "0"
    seq: []
  int_1:
    -webide-representation: "1"
    seq: []
  string_utf8:
    params:
      - id: len_value
        type: u4
    seq:
      - id: value
        size: len_value
        type: str
        encoding: UTF-8
  string_utf16_be:
    params:
      - id: len_value
        type: u4
    seq:
      - id: value
        size: len_value
        type: str
        encoding: UTF-16BE
  string_utf16_le:
    params:
      - id: len_value
        type: u4
    seq:
      - id: value
        size: len_value
        type: str
        encoding: UTF-16LE
  blob:
    params:
      - id: len_value
        type: u4
    seq:
      - id: value
        size: len_value
  overflow_record:
    params:
      - id: payload_size
        type: u8
      - id: overflow_payload_size_max
        type: u8
    seq:
      - id: inline_payload
        size: '(inline_payload_size <= overflow_payload_size_max ? inline_payload_size : _root.header.overflow_min_payload_size)'
      - id: overflow_page_number
        type: overflow_page_pointer
    instances:
      inline_payload_size:
        value: _root.header.overflow_min_payload_size+((payload_size-_root.header.overflow_min_payload_size)%(_root.header.usable_size-4))
  overflow_page_pointer:
    seq:
      - id: page_number
        type: u4
    instances:
      page:
        io: _root._io
        pos: (page_number - 1) * _root.header.page_size
        size: _root.header.page_size
        type: overflow_page
        if: page_number != 0
  overflow_page:
    seq:
      - id: next_page_number
        type: overflow_page_pointer
      - id: content
        size: _root.header.page_size - 4
  freelist_trunk_page_pointer:
    seq:
      - id: page_number
        type: u4
    instances:
      page:
        io: _root._io
        pos: (page_number - 1) * _root.header.page_size
        size: _root.header.page_size
        type: freelist_trunk_page
        if: page_number != 0
  freelist_trunk_page:
    seq:
      - id: next_page
        type: freelist_trunk_page_pointer
      - id: num_free_pages
        type: u4
      - id: free_pages
        type: u4
        repeat: expr
        repeat-expr: num_free_pages
enums:
  format_version:
    1: legacy
    2: wal
  btree_page_type:
    0x02: index_interior
    0x05: table_interior
    0x0a: index_leaf
    0x0d: table_leaf
  ptrmap_page_type:
    1: root_page
    2: free_page
    3: overflow1
    4: overflow2
    5: btree
  serial:
    # Value is a NULL.
    0: nil
    # Value is an 8-bit twos-complement integer.
    1: two_comp_8
    # Value is a big-endian 16-bit twos-complement integer.
    2: two_comp_16
    # Value is a big-endian 24-bit twos-complement integer.
    3: two_comp_24
    # Value is a big-endian 32-bit twos-complement integer.
    4: two_comp_32
    # Value is a big-endian 48-bit twos-complement integer.
    5: two_comp_48
    # Value is a big-endian 64-bit twos-complement integer.
    6: two_comp_64
    # Value is a big-endian IEEE 754-2008 64-bit floating point number.
    7: ieee754_64
    # Value is the integer 0. (Only available for schema format 4 and higher.)
    8: integer_0
    # Value is the integer 1. (Only available for schema format 4 and higher.)
    9: integer_1
    # Reserved for internal use. These serial type codes will never appear in a
    # well-formed database file, but they might be used in transient and temporary
    # database files that SQLite sometimes generates for its own use. The meanings
    # of these codes can shift from one release of SQLite to the next.
    10: internal_1
    11: internal_2
    # The serial types for blob and string are 'N >= 12 and even' and 'N >=13 and odd' respectively
    # The enum here differs slightly to have a single value for blob and a value per text encoding
    # for string.
    #
    # Value is a BLOB that is (N-12)/2 bytes in length.
    12: blob
    # Value is a string in the text encoding and (N-13)/2 bytes in length. The nul terminator is
    # not stored.
    13: string_utf8
    14: string_utf16_le
    15: string_utf16_be
