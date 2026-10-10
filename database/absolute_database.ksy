meta:
  id: absolute_database
  title: ComponentAce Absolute Database embedded database file
  application: ComponentAce Absolute Database (Delphi/C++Builder embedded DBMS)
  file-extension: abs
  endian: le
  license: CC0-1.0
  ks-version: 0.9

doc: |
  Single-file embedded SQL database format of the Absolute Database
  engine (ComponentAce, Delphi/C++Builder). Known applications include
  the Agelong Tree 3 genealogy software (which stores its databases
  with a custom `.atd` extension and a custom page size of 8112).

  No official documentation of the on-disk format exists. This spec
  was produced by reverse engineering a real database file (engine
  version 5.12, 2007); structure and field names follow the engine's
  own declarations in `ABSTypes.pas` (`TABSDBHeader`,
  `TABSDiskPageHeader`, `TABSPageItemID`), recovered from the shipped
  compiled units and verified byte-for-byte against real files.

  Scope: container level only — file header, pages, page header and
  the table catalog. Data-page internals are described only as far as
  they are engine-level facts; the record field layout itself is
  application-specific and is not parsed here:

  - data pages (type 10) hold records in fixed-size slots; the slot
    geometry (bitmap width, base offset of the slot area, slot size,
    slot count) is a per-table constant derived from the table schema.
    The general body layout is described by the `data_page_body`
    type; since the geometry is not recoverable from the page itself,
    it comes as that type's parameters;
  - a data page body starts with a slot occupancy bitmap
    (ceil(slot_count/8) bytes, LSB-first); a cleared bit marks a
    deleted record — the slot bytes are not zeroed and keep stale
    copies of older data, so only records reachable from the table's
    B-tree are live;
  - the table schema (a zlib-compressed list of fields with names,
    types and sizes) is stored in the table's blob_data chain whose
    first page is rooted in the catalog entry;
  - storage is copy-on-write: a modified page is rewritten to a fresh
    page number and its stale image remains in the file, unreachable
    from the B-tree (observed: blob chains with object_ids absent
    from the catalog);
  - index pages come in two flavors (types 11 and 12); in the
    examined database both have identical leaf entry layout
    (fixed-size entries: key + NUL + record locator page/item_no),
    while branches have a different header and variable-length keys.
    The engine-level distinction between the flavors was not
    confirmed — type 11 hosts a secondary full-name index;
  - text values inside slots are NUL-terminated UTF-16LE strings (not
    Delphi-style length-prefixed); bytes right of the terminating NUL
    within the slot keep non-semantic remains (stale copies of older
    string versions, remains of serialized in-memory objects) which
    the engine ignores.

seq:
  - id: header
    type: db_header
  - id: pages
    type: page
    size: header.page_size
    repeat: expr
    repeat-expr: header.total_page_count

types:
  db_header:
    doc: TABSDBHeader, as declared in ABSTypes.pas
    seq:
      - id: signature
        contents: 'ABS0LUTEDATABASE'
        doc: 16 bytes; the "O" of "ABSOLUTEDATABASE" is replaced with NUL
      - id: header_size
        type: u2
        doc: size of the fixed part of the header (observed 76 = 0x4C)
      - id: version
        type: f8
        doc: engine file format version (observed 5.12, of 2007-01-20)
      - id: page_size
        type: u2
        doc: engine allows 512..65536; 8192 is a common default
      - id: page_count_in_extent
        type: u2
      - id: total_page_count
        type: u4
      - id: last_used_page_no
        type: u4
      - id: state
        type: u4
        doc: internal state flags
      - id: write_changes_state
        type: u1
      - id: encrypted
        type: u1
        doc: ByteBool; non-zero means the trailer holds a TABSCryptoHeader
      - id: reserved
        size: 32
      - id: trailer
        size: 304
        doc: extension area; total header size observed 0x17C = 380 bytes

  page:
    seq:
      - id: signature
        type: str
        size: 4
        encoding: ASCII
        doc: '"ABSP" on allocated pages; completely zero-filled pages have no signature'
      - id: page
        type: disk_page
        if: signature == "ABSP"

  disk_page:
    doc: TABSDiskPageHeader, as declared in ABSTypes.pas; the "ABSP" signature precedes it
    seq:
      - id: state
        type: u4
        doc: internal state of the page
      - id: page_type
        type: u2
        enum: page_type
        doc: types 11 and 12 are two B-tree index flavors with identical
          leaf entry layout; the engine-level distinction is unconfirmed
          (see spec doc)
      - id: next_page_no
        type: u4
        doc: index of the next page in a chain; 0xFFFFFFFF = none
      - id: crc32
        type: u4
        doc: observed 0 (not computed in engine version 5.12)
      - id: crc_type
        type: u1
      - id: hash_type
        type: u1
      - id: cipher_type
        type: u1
      - id: mac_type
        type: u1
      - id: object_id
        type: u4
        doc: |
          TABSObjectID of the owning table (the key used in the
          catalog); 0xFFFFFFFF on system/service pages.
      - id: record_id
        type: page_item_id
        doc: TABSPageItemID; page_no = 0xFFFFFFFF when the page belongs to a single object
      - id: reserved
        size: 8
      - id: body
        size-eos: true
        doc: |
          page_size - 40 bytes. Meaning depends on page_type: slot-
          organized table records for data pages (parse in general
          form with data_page_body, supplying the table's slot
          geometry), B-tree nodes for index pages, blob overflow for
          blob pages, catalog_entry sequence for the catalog page.

  data_page_body:
    doc: |
      General form of a data page (page_type = data) body: slot
      occupancy bitmap, padding up to the base of the slot area, then
      fixed-size record slots. The four geometry constants are
      per-table values derived from the table schema (which is kept
      in the table's blob_data chain, see catalog_entry) and are not
      recoverable from the page alone, so they come as parameters:
      parse the page body (disk_page body bytes, see disk_page) with
      this type, passing the geometry. A cleared bitmap bit marks a
      deleted record; slot bytes are not zeroed and keep stale copies
      of older data, so only records reachable from the table's
      B-tree are live. The field layout inside a slot is derived from
      the table schema and stays out of scope of this spec.
    params:
      - id: len_slot_bitmap
        type: u1
        doc: bitmap width, ceil(num_slots / 8)
      - id: base
        type: u1
        doc: offset of the slot area from the start of the body
      - id: len_slots
        type: u2
        doc: size of one record slot
      - id: num_slots
        type: u1
    seq:
      - id: slot_bitmap
        size: len_slot_bitmap
        doc: bit i (LSB of byte i/8) set — slot i holds a live record
      - id: pad
        size: base - len_slot_bitmap
        doc: purpose not established (observed 1..5 bytes, always wider
          than the bitmap)
      - id: slots
        size: len_slots
        repeat: expr
        repeat-expr: num_slots
        doc: raw record slots
      - id: tail
        size-eos: true

  page_item_id:
    doc: TABSPageItemID, as declared in ABSTypes.pas (TABSRecordID = TABSPageItemID)
    seq:
      - id: page_no
        type: u4
      - id: page_item_no
        type: u2

  catalog_entry:
    doc: |
      Table catalog entry, as found in the body of a catalog page
      (page_type = catalog). Entries are packed into fixed slots of
      0x110 bytes back to back; the sequence ends when the page body
      (or free space, zero-filled) is exhausted.
    seq:
      - id: reserved
        size: 0x22
      - id: object_id
        type: u4
        doc: table identifier; matches object_id of the table's data pages
      - id: blob_page_8
        type: u4
        doc: |
          first page of the table's blob_data chain; for engine-observed
          files the chain holds the table schema (zlib-compressed list
          of fields), from which the data-page slot geometry derives
      - id: blob_page_9
        type: u4
        doc: first page of the table's blob_index chain
      - id: blob_page_7
        type: u4
        doc: first page of the table's blob_dir chain
      - id: name_len
        type: u1
      - id: name
        type: str
        size: name_len
        encoding: ASCII
        doc: table name (ShortString / TABSObjectName)

enums:
  page_type:
    2: superblock
    3: header_mirror
    4: allocator
    5: allocator_alt
    6: catalog
    7: blob_dir
    8: blob_data
    9: blob_index
    10: data
    11: name_index
    12: index
