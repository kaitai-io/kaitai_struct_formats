meta:
  id: glossary_index
  title: glossary index
  application:
    - glossary
  -filename-regex: ^top_index\.bin$
  endian: le
  license: MIT
  encoding: utf-8

doc-ref: https://github.com/waltonseymour/glossary/blob/7cfc390d20afd7373749aa94e0b4ce0f30709f97/src/write.rs

doc: |
  'glossary' is a tool written in Rust to index flat files delimited by line breaks.
  In fact the index can be used for any binary files.

params:
  - id: index_io
    type: io
    -filename-regex: ^index\.bin$
    doc: A KaitaiStream for index.bin file

seq:
  - id: records
    type: record_descriptor
    repeat: eos

types:
  record_descriptor:
    seq:
      - id: size
        -orig-id: num_key_bytes
        type: u8
      - id: offset
        type: u8
    instances:
      record:
        io: _root.index_io
        pos: offset
        type: record(size)
    types:
      record:
        params:
          - id: size
            -orig-id: num_key_bytes
            type: u8
        seq:
          - id: key
            -orig-id: key_bytes
            size: size
          - id: offset
            type: u8
