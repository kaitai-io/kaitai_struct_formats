meta:
  id: ogg
  title: Ogg media container file
  file-extension:
    - ogg
    - ogv
    - oga
    - spx
    - ogx
  xref:
    loc: fdd000026
    pronom: fmt/944
    wikidata: Q188199
  license: CC0-1.0
  endian: le
doc: |
  Ogg is a popular media container format, which provides basic
  streaming / buffering mechanisms and is content-agnostic. Most
  popular codecs that are used within Ogg streams are Vorbis (thus
  making Ogg/Vorbis streams) and Theora (Ogg/Theora).

  Ogg stream is a sequence Ogg pages. They can be read sequentially,
  or one can jump into arbitrary stream location and scan for "OggS"
  sync code to find the beginning of a new Ogg page and continue
  decoding the stream contents from that one.
seq:
  - id: pages
    repeat: eos
    type: page
types:
  page:
    doc: |
      Ogg page is a basic unit of data in an Ogg bitstream, usually
      it's around 4-8 KB, with a maximum size of 65307 bytes.
    seq:
      - id: sync_code
        contents: "OggS"
      - id: version
        contents: [0]
        doc: Version of the Ogg bitstream format. Currently must be 0.
      - id: reserved1
        type: b5
      - id: is_end_of_stream
        type: b1
        doc: |
          EOS (End Of Stream) mark. This page is the last page in the
          logical bitstream. The EOS flag must be set on the final page of
          every logical bitstream, and must not be set on any other page.
      - id: is_beginning_of_stream
        type: b1
        doc: |
          BOS (Beginning Of Stream) mark. This page is the first page in
          the logical bitstream. The BOS flag must be set on the first
          page of every logical bitstream, and must not be set on any
          other page.
      - id: is_continuation
        type: b1
        doc: |
          The first packet on this page is a continuation of the previous
          packet in the logical bitstream.
      - id: granule_pos
        type: u8
        doc: |
          "Granule position" is the time marker in Ogg files. It is an
          abstract value, whose meaning is determined by the codec. It
          may, for example, be a count of the number of samples, the
          number of frames or a more complex scheme.
      - id: bitstream_serial
        type: u4
        doc: |
          Serial number that identifies a page as belonging to a
          particular logical bitstream. Each logical bitstream in a file
          has a unique value, and this field allows implementations to
          deliver the pages to the appropriate decoder. In a typical
          Vorbis and Theora file, one stream is the audio (Vorbis), and
          the other is the video (Theora).
      - id: page_seq_num
        type: u4
        doc: |
          Sequential number of page, guaranteed to be monotonically
          increasing for each logical bitstream. The first page is 0, the
          second 1, etc. This allows implementations to detect when data
          has been lost.
      - id: crc32
        type: u4
        doc: |
          This field provides a CRC32 checksum of the data in the entire
          page (including the page header, calculated with the checksum
          field set to 0). This allows verification that the data has not
          been corrupted since it was created. Pages that fail the
          checksum should be discarded. The checksum is generated using a
          polynomial value of 0x04C11DB7.
      - id: num_segments
        type: u1
        doc: |
          The number of segments that exist in this page. There can be a
          maximum of 255 segments in any one page.
      - id: len_segments
        type: u1
        repeat: expr
        repeat-expr: num_segments
        doc: |
          Table of lengths of segments.
      - id: segments
        repeat: expr
        repeat-expr: num_segments
        size: len_segments[_index]
        doc: Segment content bytes make up the rest of the Ogg page.
