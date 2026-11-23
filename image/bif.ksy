meta:
  id: bif
  file-extension: bif
  endian: le
  title: Roku Base Index Frames (BIF) image archive format
  license: MIT
seq:
  - id: header
    type: header
    doc: |
      BIF header, containing magic, version, number of images,
      timestamp multiplier, and reserved bytes
  - id: images
    type: image_data(_index)
    repeat: expr
    repeat-expr: header.num_images
    doc: |
      Image data section, containing timestamps, offsets,
      and JPEG data of each image
types:
  header:
    seq:
      - id: magic
        contents: [0x89, 0x42, 0x49, 0x46, 0x0d, 0x0a, 0x1a, 0x0a]
        doc: |
          This is a file identifier.
          It contains enough information to identify the file type uniquely.
      - id: version
        type: u4
        doc: |
          This space is reserved for a revision number.
          The current specification is file format version 0.
      - id: num_images
        type: u4
        doc: |
          This is an unsigned 32-bit value (N) that represents the
          number of BIF images in the file. The number of entries
          in the index will be N+1, including the end-of-data entry.
      - id: timestamp_multiplier
        type: u4
        doc: |
          This specifies the denomination of the frame timestamp values.
          In order to obtain the "real" timestamp (in milliseconds) of a frame, 
          this value is multiplied by the timestamp entry in the BIF index.
          If this value is 0, the timestamp multiplier shall be 1000 milliseconds.
      - id: reserved
        size: 44
        doc: |
          These bytes are reserved for future expansion. They shall be 0.
  image_data:
    params:
      - id: i
        type: u4
    seq:
      - id: timestamp
        type: u4
        doc: |
          Frame timestamp. The absolute timstamps of the BIF captures
          can be obtained by multiplying the frame timestamp by the timestamp multiplier.
      - id: offset
        type: u4
        doc: Absolute offset of JPEG image in BIF
    instances:
      jpeg:
        pos: offset
        size: 'i != _root.header.num_images - 1 ? _parent.images[i + 1].offset - offset : _io.size - offset'
        doc: JPEG image file
