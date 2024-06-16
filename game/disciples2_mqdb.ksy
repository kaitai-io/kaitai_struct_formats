meta:
  id: disciples2_mqdb
  application: Disciples 2
  file-extension: csg, ff, wdb, wdt
  license: GPL-3.0-or-later
  ks-version: 0.8
  endian: le
doc: |
  MqDB is a common format name for many game files with different contents
  used by Disciples 2 game and its Scenario Editor:
    - .csg files are custom campaigns (also known as sagas);
    - .ff files primarily used to store image and animation data;
    - .wdb and .wdt files are used for sounds.
  
  MqDB file consists of 24-byte header followed by 4-byte offset to the
  table of contents entries. Rest of the file contains records, contents of which
  depends on their IDs or expected by the game. Each record starts with record
  header and has an ID that expected to be unique. In case of records with
  duplicating IDs, game uses the first found ignoring the rest.
  There are some predefined IDs: 0 for table of contents and 2 for names list.
  Table of contents existence is mandatory: it is required for search and access
  of all other records.
  Names list record is used in .csg and .ff files to provide mapping between
  record names and IDs.
  
seq:
  - id: header
    type: mqdb_header
  - id: table_of_contents_offset
    type: u4
    doc: 'Offset to the table of contents entries from the beginning of file'
  - id: records
    type: mqrc
    repeat: eos
  
types:
  mqdb_header:
    seq:
      - id: signature
        contents: [M, Q, D, B]
      - id: unknown
        type: u4
      - id: version
        contents: [9, 0, 0, 0]
        doc: 'Game expects 9 when reading and always writes 9 when creating files'
      - id: unknown2
        size: 12
  mqrc_header:
    seq:
      - id: signature
        contents: [M, Q, R, C]
      - id: unknown
        type: u4
      - id: id
        type: u4
        doc: 'Unique record ID'
      - id: size
        type: u4
        doc: 'Records contents size in bytes'
      - id: allocated_size
        type: u4
        doc: 'Total size in bytes allocated for record contents'
      - id: used
        type: u4
        doc: 'Meaning assumed'
      - id: unknown2
        type: u4
  mqrc:
    seq:
      - id: header
        type: mqrc_header
      - id: contents
        size: header.allocated_size
        type:
          switch-on: header.id
          cases:
            0: table_of_contents
            2: names_list
            _: plain_data
  names_list_entry:
    seq:
      - id: name
        type: strz
        size: 256
        encoding: ascii
      - id: id
        type: u4
        doc: 'Record ID this name belongs to'
  names_list:
    seq:
      - id: entries_count
        type: u4
      - id: entries
        type: names_list_entry
        repeat: expr
        repeat-expr: entries_count
  plain_data:
    seq:
      - id: data
        type: u1
        repeat: eos
  table_of_contents_entry:
    seq:
      - id: id
        type: u4
        doc: 'Unique record ID'
      - id: size
        type: u4
        doc: 'Records contents size in bytes'
      - id: allocated_size
        type: u4
        doc: 'Total size in bytes allocated for record contents'
      - id: offset
        type: u4
        doc: 'Offset to the record from the beginning of file, in bytes'
  table_of_contents:
    seq:
      - id: entries_count
        type: u4
      - id: entries
        type: table_of_contents_entry
        repeat: expr
        repeat-expr: entries_count
      - id: padding
        type: u1
        repeat: eos
        doc: 'Table of contents record data is written in chunks of 1024 bytes'
