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
  the table catalog. Table data itself is application-specific: records
  are variable-length, stored back to back without a slot directory,
  and are not covered here. Text values observed in data pages are
  NUL-terminated UTF-16LE strings (not Delphi-style length-prefixed
  strings), interleaved with non-semantic remains of serialized
  in-memory objects.

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
          page_size - 40 bytes. Meaning depends on page_type: table
          records for data pages, B-tree nodes for index pages, blob
          overflow for blob pages, catalog_entry sequence for the
          catalog page.

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
        doc: first page of the table's blob_data chain
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
    11: unknown_11
    12: index
