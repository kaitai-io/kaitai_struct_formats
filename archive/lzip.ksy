meta:
  id: lzip
  title: Lzip compressed file
  file-extension: lz
  license: CC0-1.0
  endian: le
doc: |
  Lzip is a lossless compression format using LZMA. A version 1 file
  contains one or more independently compressed members, each with a
  header, an LZMA stream and a trailer containing a CRC32 checksum and
  the uncompressed and compressed sizes.

  Member sizes are stored only in the trailers, so this specification
  first builds an index by walking backwards from the end of the file,
  then parses the members in file order. It requires a seekable stream
  containing exactly the lzip file, without trailing data.

  The compressed data is exposed as bytes. This specification does not
  decompress the LZMA streams or verify the CRC32 checksums, uncompressed
  sizes or end-of-stream markers.
doc-ref:
  - https://www.nongnu.org/lzip/manual/lzip_manual.html#File-format
  - https://datatracker.ietf.org/doc/html/draft-diaz-lzip-14#section-2
seq:
  - id: member_index
    type: |
      index_entry(
        _index == 0 ? _io.size : member_index[_index - 1].ofs_start
      )
    repeat: until
    repeat-until: _.ofs_start == 0
    doc: Member boundaries in reverse file order, starting with the last member.
  - id: members
    size: member_index[member_index.size - 1 - _index].len_member
    type: member
    repeat: expr
    repeat-expr: member_index.size
    doc: Members in file order.
types:
  index_entry:
    params:
      - id: ofs_end
        type: s8
        doc: Offset immediately after this member, relative to the input stream.
    instances:
      len_member:
        pos: ofs_end - 8
        type: u8
        valid:
          min: 36
          max: ofs_end.as<u8>
        doc: |
          Total member size, including the 6-byte header and 20-byte trailer.
          The shortest LZMA stream is 10 bytes, so a member is at least
          36 bytes. The upper bound prevents seeking before the input stream.
      ofs_start:
        # Explicit casts preserve 64-bit offsets in generated code.
        value: (ofs_end - len_member.as<s8>).as<s8>
  member:
    seq:
      - id: header
        type: header
      - id: lzma_stream
        size: _io.size - 26
        valid:
          expr: lzma_stream[0] == 0
        doc: |
          Raw LZMA stream with properties lc=3, lp=0, pb=2 and an
          end-of-stream marker. The first byte must be zero.
      - id: crc32
        type: u4
        doc: CRC32 of the uncompressed data.
      - id: len_data
        type: u8
        valid:
          expr: _root.member_index.size == 1 or len_data > 0
        doc: Uncompressed size in bytes. Empty members are only allowed alone.
      - id: len_member
        type: u8
        valid: _io.size.as<u8>
        doc: Total member size, including the header and trailer.
  header:
    seq:
      - id: magic
        contents: [0x4c, 0x5a, 0x49, 0x50]
      - id: version
        type: u1
        valid: 1
      - id: dictionary_size_code
        type: u1
        valid:
          expr: |
            (dictionary_size_code & 0x1f) >= 12 and
            (dictionary_size_code & 0x1f) <= 29 and
            dictionary_size >= 4096
        doc: |
          Bits 0-4 encode the base-2 logarithm of a base size (12 to 29).
          Bits 5-7 encode the number of sixteenths to subtract from that
          base size. The resulting dictionary size must be at least 4 KiB.
    instances:
      dictionary_size:
        value: |
          (1 << (dictionary_size_code & 0x1f)) -
          ((1 << (dictionary_size_code & 0x1f)) >> 4) *
          (dictionary_size_code >> 5).as<s8>
        doc: Dictionary size in bytes, from 4 KiB to 512 MiB.
