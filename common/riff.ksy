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
seq:
  - id: riff_chunk
    type: chunk
types:
  parent_chunk_data:
    seq:
      - id: form_type
        type: u4be
        enum: form_type
      - id: subchunks
        type: chunk
        repeat: eos
  chunk:
    doc: |
      All registered subchunks in the INFO chunk are NULL-terminated strings,
      but the unregistered might not be. By convention, the registered
      chunk IDs are in uppercase and the unregistered IDs are in lowercase.

      If the chunk ID is a child of the INFO chunk and contains a lowercase
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
          switch-on: chunk_id
          cases:
            0x52494646: parent_chunk_data # chunk_id::riff
            0x4c495354: parent_chunk_data # chunk_id::list
        if: not is_info_tag or is_unregistered_tag
      - id: string_data
        size: chunk_size
        type: strz
        if: is_info_tag and not is_unregistered_tag
      - id: pad_byte
        size: chunk_size % 2
    instances:
      is_info_tag:
        value: _parent.as<parent_chunk_data>.form_type == form_type::info
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

enums:
  chunk_id:
    0x52494646: riff
    0x4c495354: list
  form_type:
    0x494e464f: info
    0x57415645: wave
    0x41564920: avi
    0x524d4944: rmid
    0x444c5320: dls
    0x7366626b: sfbk
