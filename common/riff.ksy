meta:
  id: riff
  title: Resource Interchange File Format (RIFF)
  license: CC0-1.0
  endian: le
  encoding: ASCII
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
  - id: riff_chunk
    type: chunk
types:
  parent_chunk_data:
    seq:
      - id: form_type
        type: str
        size: 4
        pad-right: 0x20
      - id: subchunks
        type:
          switch-on: form_type
          cases:
            '"INFO"': info_subchunk
            _: chunk
        repeat: eos
  chunk:
    seq:
      - id: chunk_id
        type: str
        size: 4
        pad-right: 0x20
      - id: chunk_size
        type: u4
      - id: chunk_data
        size: chunk_size
        type:
          switch-on: chunk_id
          cases:
            '"RIFF"': parent_chunk_data
            '"LIST"': parent_chunk_data
      - id: pad_byte
        size: chunk_size % 2
  info_subchunk:
    doc: |
      All registered subchunks in the INFO chunk are NULL-terminated strings,
      but the unregistered might not be. By convention, the registered
      chunk IDs are in uppercase and the unregistered IDs are in lowercase.

      If the chunk ID of an INFO subchunk contains a lowercase
      letter, this chunk is considered as unregistered and thus we can make
      no assumptions about the type of data.
    seq:
      - id: chunk_id
        type: u4be
      - id: chunk_size
        type: u4
      - id: chunk_data
        size: chunk_size
        type:
          switch-on: is_unregistered_tag
          cases:
            false: strz
      - id: pad_byte
        size: chunk_size % 2
    instances:
      chunk_id_char:
        value: >-
          [
            (chunk_id & 0xff000000) >> 24,
            (chunk_id & 0x00ff0000) >> 16,
            (chunk_id & 0x0000ff00) >> 8,
            (chunk_id & 0x000000ff) >> 0
          ]
      is_unregistered_tag:
        doc: |
          Check if chunk_id contains lowercase characters ([a-z], ASCII 97 = a, ASCII 122 = z).
        value: >-
          (
            (chunk_id_char[0] >= 97 and chunk_id_char[0] <= 122) or
            (chunk_id_char[1] >= 97 and chunk_id_char[1] <= 122) or
            (chunk_id_char[2] >= 97 and chunk_id_char[2] <= 122) or
            (chunk_id_char[3] >= 97 and chunk_id_char[3] <= 122)
          )
