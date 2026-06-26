meta:
  id: fileinfo_fi
  title: Norton FileInfo file description database
  application: Norton Utilities File Info
  file-extension: fi
  tags:
    - dos
  license: CC0-1.0
  endian: le
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
        doc: Simple checksum of remaining header bytes.
      - id: bitmask
        size: 128
        doc: >-
          Bit mask of valid records, starting with the highest bit in the first
          byte and ending with the lowest bit in the bitmask_len byte. This
          structure limits the number of records in the file to 1024.
  record:
    seq:
      - id: file_name
        size: 12
        type: str
        terminator: 0
        encoding: IBM437
        doc: >-
          This contains the short 8.3 MS-DOS file name.  The first character
          is set to 0xE5 and the appropriate bit in the bitmask is cleared when
          the entry has been deleted. Even though file names must be ASCII, the
          encoding is set here to IBM437 because the 0xE5 for deleted entries
          is not ASCII; IBM437 is a superset.
      - id: comment
        size: 65
        terminator: 0
        doc: >-
          This is not defined as a string because the encoding is unknown; it
          is often IBM437 but can be something else depending on the code page
          in use when the entry was created.
