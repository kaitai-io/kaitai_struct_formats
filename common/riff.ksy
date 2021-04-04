meta:
  id: riff
  title: Resource Interchange File Format (RIFF)
  xref:
    justsolve: RIFF
    loc: fdd000025
    wikidata: Q1196805
  license: CC0-1.0
  endian: le
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
  chunk_id:
    value: chunk.id
    enum: fourcc
  is_riff_chunk:
    value: 'chunk_id == fourcc::riff'
  parent_chunk_data:
    io: chunk.data_slot._io
    pos: 0
    type: parent_chunk_data
    if: is_riff_chunk
  subchunks:
    io: parent_chunk_data.subchunks_slot._io
    pos: 0
    type: chunk_type
    repeat: eos
    if: is_riff_chunk
types:
  chunk:
    seq:
      - id: id
        type: u4
      - id: len
        type: u4
      - id: data_slot
        type: slot
        size: len
      - id: pad_byte
        size: len % 2 # if size is odd, there is 1 padding byte
    types:
      slot: {} # Keeps _io for later use of same substream
  parent_chunk_data:
    seq:
      - id: form_type
        type: u4
      - id: subchunks_slot
        type: slot
        size-eos: true
    types:
      slot: {} # Keeps _io for later use of same substream

  chunk_type:
    seq:
      - id: save_chunk_ofs
        size: 0
        if: chunk_ofs < 0
      - id: chunk
        type: chunk
    instances:
      chunk_ofs:
        value: _io.pos
      chunk_id:
        value: chunk.id
        enum: fourcc
      chunk_id_readable:
        pos: chunk_ofs
        size: 4
        type: str
        encoding: ASCII
      chunk_data:
        io: chunk.data_slot._io
        pos: 0
        type:
          switch-on: chunk_id
          cases:
            'fourcc::list': list_chunk_data
  list_chunk_data:
    seq:
      - id: save_parent_chunk_data_ofs
        size: 0
        if: parent_chunk_data_ofs < 0
      - id: parent_chunk_data
        type: parent_chunk_data
    instances:
      parent_chunk_data_ofs:
        value: _io.pos
      form_type:
        value: parent_chunk_data.form_type
        enum: fourcc
      form_type_readable:
        pos: parent_chunk_data_ofs
        size: 4
        type: str
        encoding: ASCII
      subchunks:
        io: parent_chunk_data.subchunks_slot._io
        pos: 0
        type:
          switch-on: form_type
          cases:
            'fourcc::info': info_subchunk
            _: chunk_type
        repeat: eos
  info_subchunk:
    meta:
      encoding: UTF-8
    doc: |
      All registered subchunks in the INFO chunk are NULL-terminated strings,
      but the unregistered might not be. By convention, the registered
      chunk IDs are in uppercase and the unregistered IDs are in lowercase.

      If the chunk ID of an INFO subchunk contains a lowercase
      letter, this chunk is considered as unregistered and thus we can make
      no assumptions about the type of data.
    seq:
      - id: save_chunk_ofs
        size: 0
        if: chunk_ofs < 0
      - id: chunk
        type: chunk
    instances:
      chunk_ofs:
        value: _io.pos
      chunk_id_readable:
        value: id_chars.to_s('ASCII')
      chunk_data:
        io: chunk.data_slot._io
        pos: 0
        type:
          switch-on: is_unregistered_tag
          cases:
            false: strz
      id_chars:
        pos: chunk_ofs
        size: 4
      is_unregistered_tag:
        value: >-
          (id_chars[0] >= 97 and id_chars[0] <= 122) or
          (id_chars[1] >= 97 and id_chars[1] <= 122) or
          (id_chars[2] >= 97 and id_chars[2] <= 122) or
          (id_chars[3] >= 97 and id_chars[3] <= 122)
        doc: |
          Check if chunk_id contains lowercase characters ([a-z], ASCII 97 = a, ASCII 122 = z).
enums:
  fourcc:
  # little-endian
    0x46464952: riff
    0x5453494c: list
    0x4f464e49: info
