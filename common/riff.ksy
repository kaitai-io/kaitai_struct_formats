meta:
  id: riff
  title: Resource Interchange File Format (RIFF)
  license: CC0-1.0
  endian: le
  encoding: ASCII
  imports:
    - /common/riff/chunk
    - /common/riff/parent_chunk_data
  xref:
    justsolve: RIFF
    loc: fdd000025
    wikidata: Q1196805
doc: |
  The Resource Interchange File Format (RIFF) is a generic file container format
  for storing data in tagged chunks. It is primarily used to store multimedia
  such as sound and video, though it may also be used to store any arbitrary data.

  The Microsoft implementation is mostly known through container formats
  like AVI, ANI and WAV, which use RIFF as their basis.
doc-ref: https://www.johnloomis.org/cpe102/asgn/asgn1/riff.html
seq:
  - id: chunk
    type: chunk
instances:
  is_riff_chunk:
    value: chunk.id == 'RIFF'
  parent_chunk_data:
    io: chunk.data_slot._io
    pos: 0
    if: is_riff_chunk
    type: parent_chunk_data
  subchunks:
    io: parent_chunk_data.subchunks_slot._io
    pos: 0
    if: is_riff_chunk
    type: chunk_type
    repeat: eos
types:
  chunk_type:
    seq:
      - id: chunk
        type: chunk
    instances:
      chunk_data:
        io: chunk.data_slot._io
        pos: 0
        type:
          switch-on: chunk.id
          cases:
            '"LIST"': list_chunk_data
  list_chunk_data:
    seq:
      - id: parent_chunk_data
        type: parent_chunk_data
    instances:
      subchunks:
        io: parent_chunk_data.subchunks_slot._io
        pos: 0
        type:
          switch-on: parent_chunk_data.form_type
          cases:
            '"INFO"': info_subchunk
            _: chunk_type
        repeat: eos
  info_subchunk:
    doc: |
      All registered subchunks in the INFO chunk are NULL-terminated strings,
      but the unregistered might not be. By convention, the registered
      chunk IDs are in uppercase and the unregistered IDs are in lowercase.

      If the chunk ID of an INFO subchunk contains a lowercase
      letter, this chunk is considered as unregistered and thus we can make
      no assumptions about the type of data.
    seq:
      - id: id
        type: u4be
      - id: len
        type: u4
      - id: data
        size: len
        type:
          switch-on: is_unregistered_tag
          cases:
            false: strz
      - id: pad_byte
        size: len % 2
    instances:
      id_char:
        value: >-
          [
            (id & 0xff000000) >> 24,
            (id & 0x00ff0000) >> 16,
            (id & 0x0000ff00) >> 8,
            (id & 0x000000ff) >> 0
          ]
      is_unregistered_tag:
        doc: |
          Check if chunk_id contains lowercase characters ([a-z], ASCII 97 = a, ASCII 122 = z).
        value: >-
          (
            (id_char[0] >= 97 and id_char[0] <= 122) or
            (id_char[1] >= 97 and id_char[1] <= 122) or
            (id_char[2] >= 97 and id_char[2] <= 122) or
            (id_char[3] >= 97 and id_char[3] <= 122)
          )
