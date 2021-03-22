meta:
  id: gltf_binary
  title: GL Transmission Format, binary container
  file-extension: glb
  xref:
    mime: model/gltf-binary
    wikidata: Q28135989
  license: MIT
  endian: le

doc: |
  glTF is a format for distribution of 3D models optimized for being used in software

doc-ref: https://github.com/KhronosGroup/glTF/tree/2354846/specification/2.0#binary-gltf-layout

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
        contents: glTF
      - id: version
        type: u4
        doc: |
          Indicates the version of the Binary glTF container format.
          For this specification, should be set to 2.
      - id: length
        type: u4
        doc: Total length of the Binary glTF, including Header and all Chunks, in bytes.

  chunk:
    seq:
      - id: len_data
        type: u4
      - id: type
        type: u4
        enum: chunk_type
      - id: data
        size: len_data
        type:
          switch-on: type
          cases:
            'chunk_type::json': json
            'chunk_type::bin': bin

  json:
    seq:
      - id: data
        size-eos: true
        type: str
        encoding: UTF-8
        doc: |
          This is where GLB deviates from being an elegant format.
          To parse the rest of the file, you have to parse the JSON first.

  bin:
    seq:
      - id: data
        size-eos: true

enums:
  chunk_type:
    0x4E4F534A: json # "JSON"
    0x004E4942: bin  # "BIN\0"
