meta:
  id: norton_fileinfo_fi
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
  that are displayed by the fi.exe program. This format was used by [Norton
  Utilities](https://en.wikipedia.org/wiki/Norton_Utilities) 4 on MS-DOS
  systems.
seq:
  - id: header
    type: header
  - id: records
    type: record
    repeat: expr
    repeat-expr: header.num_records
instances:
  record_checksum_reduction:
    type: 'record_checksum_iter(_index, _index == 0 ? 0 : record_checksum_reduction[_index - 1].res)'
    repeat: expr
    repeat-expr: _root.header.record_in_use.size
    doc: |
      Expression used in calculating `expected_record_checksum.`
  record_checksum:
    value: record_checksum_reduction[_root.header.record_in_use.size - 1].res
    doc: |
      Partial checksum of `record_in_use` used in calculating
      `calculated_header_checksum`.
  calculated_header_checksum:
    value: |
      (
        header.magic[0].as<u1>
        + header.magic[1].as<u1>
        + header.magic[2].as<u1>
        + header.magic[3].as<u1>
        + header.num_records / 256
        + header.num_records % 256
        + record_checksum
      ) % 65536
    doc: |
      Calculate the expected header checksum from the header data. This is the
      value that should be found in `header.checksum` in a valid file.
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
        doc: Checksum of remaining header bytes, equal to `calculated_header_checksum`.
      - id: record_in_use
        type: b1
        repeat: expr
        repeat-expr: 1024
        doc: |
          Bit mask of valid records, starting with the highest bit in the first
          byte and ending with the lowest bit in the last byte. This structure
          limits the number of records in the file to 1024, although Norton
          Utilities caps the maximum at 769, keeping the file size under
          64 KiB.
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
        type: u2
        doc: |
          The index into the `record_in_use` array for this part of the
          checksum.
      - id: prev
        type: u2
        doc: |
          The sum of the values of all previous (lower) indexes.
    instances:
      res:
        value: |
          prev + (_root.header.record_in_use[idx].to_i << (7 - (idx % 8)))
        doc: |
          Add one additional checksum byte from the given `record_in_use` bit.
