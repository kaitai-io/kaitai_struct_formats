meta:
  id: safetensors
  title: A file format used by HuggingFace to allow safe deserialization of pytorch models.
  application:
    - HuggingFace Hub
    - HuggingFace python packages
  file-extension:
    - safetensors
    - sftr
  license: Unlicense
  endian: le
  encoding: utf-8
  imports:
    - /common/ndarray_descriptor
    - /common/ndarray
  ks-opaque-types: true
doc: |
  Serialization format used by HuggingFace to allow safe deserialization of pytorch models.
  To parse it properly you need a parser for JSON.

  Samples: https://github.com/KOLANICH/kaitai_struct_samples/tree/safetensors/serialization/safetensors

doc-ref:
  - https://github.com/huggingface/safetensors

seq:
  - id: preheader
    type: preheader
  - id: header_str
    type: strz
    encoding: ascii
    size: preheader.header_size
    doc: |
      {"__metadata__":{"string": "string"},"tensor_name":{"dtype":"U8","shape":[6],"data_offsets":[0,6]}}
  - id: tensors
    size-eos: true
    type: tensors
instances:
  header:
    -affected-by: 314
    value: real_parsed_header.as<fake_parsed_header>

  real_parsed_header:
    -affected-by: 314
    pos: 0
    type: safe_tensors_parsed_header(header_str)
    doc:  download it from https://raw.githubusercontent.com/KOLANICH-libs/pysafetensors/305ba67aecda0ce58a7a2f3ae9116f8df6f5a725/pysafetensors/kaitai/safe_tensors_parsed_header.py

types:
  tensors:
    seq:
      - id: data
        type: tensor(_index)
        repeat: expr
        repeat-expr: _root.header.tensors.size

  tensor:
    params:
      - id: idx
        type: u8

    instances:
      header:
        value: _root.header.tensors[idx]
      size:
        value: header.offsets.stop - header.offsets.start

      dims_m_2:
        value: header.dimensions.as<u8> - 2

      flat:
        io: _parent._io
        pos: header.offsets.start
        size: size

      ndarray:
        io: _parent._io
        pos: header.offsets.start
        size: size
        type: ndarray(header.descriptor)

  fake_parsed_header:
    -affected-by: 314
    seq:
      - id: tensors
        type: fake_tensor_header
        repeat: expr
        repeat-expr: 0
    types:
      fake_tensor_header:
        -affected-by: 314
        seq:
          - id: name
            type: str
            size: 0

          - id: offsets
            type: range
        instances:
          descriptor:
            pos: 0
            type: ndarray_descriptor(ndarray_descriptor::item_type::u1, [0])
        types:
          range:
            seq:
              - id: start
                type: u8
              - id: stop
                type: u8

  preheader:
    seq:
      - id: header_size
        type: u8
