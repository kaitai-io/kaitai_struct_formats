meta:
  id: glb
  title: glTF binary format
  file-extension: glb
  endian: le
  license: MIT
  doc-ref: https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#binary-gltf-layout
  xref:
    mime: model/gltf-binary

seq:
  - id: header
    type: header
  - id: chunks
    type: chunk
    repeat: eos

types:

  header:
    seq:
      - id: magic
        contents: 'glTF'
      - id: version
        type: u4
      - id: length
        type: u4

  chunk:
    seq:
      - id: length
        type: u4
      - id: type
        type: u4
        enum: chunk_type
      - id: data
        size: length
        type:
          switch-on: type
          cases:
            'chunk_type::json': json
            'chunk_type::bin': bin

  json:
    seq:
      - id: data
        type: str
        encoding: UTF-8
        size-eos: true
        doc: |
          This is where GLB deviates from being an elegant format.
          To parse the rest of the file, you have to parse the JSON first.

  bin:
    seq:
      - id: data
        size-eos: true

enums:
  chunk_type:
    # Literally "JSON"
    0x4E4F534A: json
    # Literally "BIN\0"
    0x004E4942: bin
