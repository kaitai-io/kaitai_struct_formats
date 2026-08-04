meta:
  id: fileinfo_fi
  title: Norton FileInfo file description database
  application: Norton Utilities File Info
  file-extension: fi
  tags:
    - dos
  license: CC0-1.0
  endian: le
  bit-endian: be
doc: |
  fileinfo.fi files store detailed file description alongside file names
  that are displayed by the fi.exe program. This format was used by Norton
  Utilities 4 on MS-DOS systems.
doc-ref:
  - https://en.wikipedia.org/wiki/Norton_Utilities
seq:
  - id: header
    type: header
  - id: records
    type: record
    repeat: expr
    repeat-expr: header.num_records
types:
  header:
    seq:
      - id: magic
        contents: ['PNCI', 0]
      - id: num_records
        type: u2
        doc: Number of records in the file.
      - id: checksum
        type: u2
        doc: Checksum of remaining header bytes, equal to header_checksum.
      - id: record_in_use
        type: b1
        repeat: expr
        repeat-expr: 1024
        doc: |
          Bit mask of valid records, starting with the highest bit in the first
          byte and ending with the lowest bit in the bitmask_len byte. This
          structure limits the number of records in the file to 1024, although
          Norton Utilities caps the maximum at 769.
  record:
    seq:
      - id: file_name
        size: 12
        type: strz
        encoding: IBM437
        doc: |
          This contains the short 8.3 MS-DOS file name.  The first character
          is set to 0xE5 and the appropriate bit in the bitmask is cleared when
          the entry has been deleted. Even though file names must be ASCII, the
          encoding is set here to IBM437 because the 0xE5 for deleted entries
          is not ASCII; IBM437 is a superset of ASCII.
      - id: comment
        size: 65
        terminator: 0
        doc: |
          This is not defined as a string because the encoding is unknown; it
          is often IBM437 but can be something else depending on the code page
          in use when the entry was created.
  record_checksum_iter:
    params:
      - id: idx
        type: u1
        doc: |
          The index into the record_in_use array in calculating the checksum.
          This is the index into groups of 8 bits in record_in_use, so ranges
          from 0..127.
    instances:
      prev:
        value: 'idx == 0 ? 0 : (_parent.record_checksum_reduction[idx - 1].as<record_checksum_iter>.res).as<u2>'
      res:
        value: |
          prev + (
            (_root.header.record_in_use[idx * 8 + 0].as<u2> << 7) +
            (_root.header.record_in_use[idx * 8 + 1].as<u2> << 6) +
            (_root.header.record_in_use[idx * 8 + 2].as<u2> << 5) +
            (_root.header.record_in_use[idx * 8 + 3].as<u2> << 4) +
            (_root.header.record_in_use[idx * 8 + 4].as<u2> << 3) +
            (_root.header.record_in_use[idx * 8 + 5].as<u2> << 2) +
            (_root.header.record_in_use[idx * 8 + 6].as<u2> << 1) +
            (_root.header.record_in_use[idx * 8 + 7].as<u2> << 0))
        doc: |
          Add one additional checksum byte from 8 record_in_use bits. The
          calculation is done in groups of 8 to reduce the amount of recursion
          necessary to calculate the entire record_in_use checksum, which
          otherwise exceeds the maximum Python recursion limit.
instances:
  record_checksum_reduction:
    type: record_checksum_iter(_index)
    repeat: expr
    repeat-expr: _root.header.record_in_use.size / 8
    doc: |
      Structure used in calculating record_checksum.
  record_checksum:
    value: record_checksum_reduction[_root.header.record_in_use.size / 8 - 1].res
    doc: |
      Partial sum used in calculating header_checksum.
  header_checksum:
    value: (header.magic[0].as<u1> + header.magic[1].as<u1> + header.magic[2].as<u1> + header.magic[3].as<u1> + header.num_records / 256 + header.num_records % 256 + record_checksum) % 65536
    doc: |
      Calculate the expected header checksum from the header data. This is the
      value that should be found in header.checksum in a valid file.
