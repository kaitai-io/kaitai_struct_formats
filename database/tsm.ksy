meta:
  id: tsm
  title: InfluxDB TSM file
  application: InfluxDB
  file-extension: tsm
  xref:
    wikidata: Q29168491
  license: MIT
  endian: be
  ks-version: '0.9'
doc: |
  InfluxDB is a scalable database optimized for storage of time
  series, real-time application metrics, operations monitoring events,
  etc, written in Go.

  Data is stored in .tsm files, which are kept pretty simple
  conceptually. Each .tsm file contains a header and footer, which
  stores offset to an index. Index is used to find a data block for a
  requested time boundary.
seq:
  - id: header
    type: header
instances:
  index:
    pos: _io.size - 8
    type: index
types:
  header:
    seq:
      - id: magic
        contents: [0x16, 0xd1, 0x16, 0xd1]
      - id: version
        type: u1
  index:
    seq:
      - id: offset
        type: u8
    instances:
      entries:
        pos: offset
        type: index_header
        repeat:
          until: _io.pos == _io.size - 8
    types:
      index_header:
        seq:
          - id: key_len
            type: u2
          - id: key
            type: str
            encoding: UTF-8
            size: key_len
          - id: type
            type: u1
          - id: entry_count
            type: u2

          - id: index_entries
            type: index_entry
            repeat:
              expr: entry_count
        types:
          index_entry:
            seq:
              - id: min_time
                type: u8
              - id: max_time
                type: u8
              - id: block_offset
                type: u8
              - id: block_size
                type: u4

            types:
              block_entry:
                seq:
                  - id: crc32
                    type: u4
                  - id: data
                    size: _parent.block_size - 4

            instances:
              block:
                io: _root._io
                pos: block_offset
                type: block_entry
