meta:
  id: fxp
  title: VST 2.x plugin preset file
  file-extension: fxp
  license: CC0-1.0
  endian: be
doc: |
  The FXP format is developed by Steinberg Media Technologies GmbH for storing
  preset data of a VST 2.x plugin. Most of the data stored in an FXP file (apart
  from the header and preset name) is understood only by the plugin, i.e.
  `content` is either a list of all parameter values as a list of floats (size
  of this list is `num_params`) or just a blob of random binary data.
seq:
  - id: fmt_magic
    -orig-id: chunkMagic
    contents: 'CcnK'
  - id: len_chunk
    -orig-id: byteSize
    type: s4
    doc: 'Size of this chunk exclusive of `fmt_magic` + `len_chunk` itself.'
  - id: fx_magic
    type: str
    size: 4
    encoding: ASCII
    doc: |
      Identifies the kind of preset, FxCk for a `regular_chunk` or FPCh for an
      `opaque_chunk`.
  - id: fmt_version
    -orig-id: version
    type: u4
    doc: 'Format version, always equal to 1.'
  - id: fx_fourcc
    -orig-id: fxID
    type: str
    size: 4
    encoding: ASCII
    doc: 'VST FourCC as registered with Steinberg Media Technologies GmbH.'
  - id: fx_version
    type: u4
    doc: 'Version of the VST plugin whose preset this is.'
  - id: num_fx_params
    -orig-id: numParams
    type: u4
    doc: |
      Number of parameters contained in preset data. If `content` is of type
      `regular_chunk`, this is equal to the size of list of
      `regular_chunk.params`, else it is 1.
  - id: preset_name
    -orig-id: prgName
    type: str
    size: 28
    encoding: ASCII
    doc: 'Preset name'
  - id: preset_content
    -orig-id: content
    type:
      switch-on: fx_magic
      cases:
        '"FxCk"': regular_chunk
        '"FPCh"': opaque_chunk
    doc: |
      Plugin specific preset data chunk. Serialisation/deserialisation
      handled by the plugin. It is a developers choice to choose between a
      `regular_chunk` or `opaque_chunk`. Mostly, `opaque_chunk` is chosen these
      days as it allows for copy protection of preset data as well as storing
      non-integer data like strings for example.
types:
  regular_chunk:
    seq:
      - id: fx_params
        -orig-id: params
        repeat: expr
        repeat-expr: _root.num_fx_params
        type: f4
  opaque_chunk:
    seq:
      - id: len_chunk
        type: u4
      - id: chunk
        size: len_chunk
