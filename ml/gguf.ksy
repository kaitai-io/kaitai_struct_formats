meta:
  id: gguf
  title: GGML model file
  file-extension: gguf
  license: CC0-1.0
  ks-version: '0.11'
doc: |
  GGUF is a file format for storing machine learning models for inference with
  the GGML library, or executors based on GGML. Models are typically developed
  using PyTorch or some other framework, and then converted to GGUF for use in
  GGML.

  GGUF is a successor file format to GGML, GGMF and GGJT, and is designed
  to be unambiguous by containing all the information needed to load a
  model. It is also designed to be extensible, so that new information
  can be added to models without breaking compatibility.
doc-ref: https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/docs/gguf.md Git tag "v0.27.0"
seq:
  - id: magic
    contents: GGUF
    doc: GGUF file magic
  - id: body
    type: gguf_body
instances:
  version_le:
    pos: 4
    type: u4le
  is_big_endian:
    # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L499-L509 (Git tag "v0.27.0")
    value: version_le & 0xffff == 0
types:
  gguf_body:
    meta:
      endian:
        switch-on: _root.is_big_endian
        cases:
          true: be
          false: le
    seq:
      - id: version
        type: u4
        valid:
          # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L494-L519 (Git tag "v0.27.0")
          min: 2
          max: 3
        doc: |
          File format version. Version 1 used 32-bit counts and lengths, which
          this Kaitai Struct implementation doesn't support, and neither does
          ggml.
      - id: num_tensor_infos
        type: u8
        doc: The number of tensors in the file
      - id: num_kv_pairs
        type: u8
        doc: The number of key-value pairs in the file header
      - id: kv_pairs
        type: 'gguf_kv(_index != 0 ? kv_pairs[_index - 1].alignment : 32)'
        repeat: expr
        repeat-expr: num_kv_pairs
        doc: Key-value pairs
      - id: tensor_infos
        type: 'gguf_tensor_info(_index != 0 ? tensor_infos[_index - 1].expected_next_offset : 0)'
        repeat: expr
        repeat-expr: num_tensor_infos
        doc: Tensor metadata
      - id: padding
        size: (alignment - _io.pos % alignment) % alignment
        if: num_tensor_infos > 0
        doc-ref: https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L780-L785 Git tag "v0.27.0"
      - size: 0
        if: ofs_tensor_data < 0
    instances:
      ofs_tensor_data:
        value: _io.pos
        doc: |
          Offset of the tensor data. Each tensor's `offset` is relative to this
          position.
      alignment:
        -orig-id: ALIGNMENT # used in the `gguf.md` document
        value: 'kv_pairs.size != 0 ? kv_pairs.last.alignment : 32'
        doc: |
          Global alignment - from the `general.alignment` key, or 32 if there's no
          such key.
        doc-ref: https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L622-L630 Git tag "v0.27.0"

    types:
      gguf_value:
        -webide-representation: '{value}'
        params:
          - id: type
            type: u4
            enum: gguf_type
        seq:
          - id: value
            type:
              switch-on: type
              cases:
                'gguf_type::gguf_type_uint8': gguf_uint8
                'gguf_type::gguf_type_int8': gguf_int8
                'gguf_type::gguf_type_uint16': gguf_uint16
                'gguf_type::gguf_type_int16': gguf_int16
                'gguf_type::gguf_type_uint32': gguf_uint32
                'gguf_type::gguf_type_int32': gguf_int32
                'gguf_type::gguf_type_float32': gguf_float32
                'gguf_type::gguf_type_bool': gguf_bool
                'gguf_type::gguf_type_string': gguf_str
                'gguf_type::gguf_type_array': gguf_array
                'gguf_type::gguf_type_uint64': gguf_uint64
                'gguf_type::gguf_type_int64': gguf_int64
                'gguf_type::gguf_type_float64': gguf_float64

      gguf_kv:
        -webide-representation: '{key}: {value}'
        params:
          - id: prev_alignment
            type: u4
        seq:
          - id: key
            type: gguf_str
            valid:
              # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L571-L574 (Git tag "v0.27.0")
              expr: _.size != 0
            -affected-by: 1260 # this `valid/expr` doesn't compile in C++11
          - id: type
            type: u4
            enum: gguf_type
            valid:
              # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L593-L612 (Git tag "v0.27.0")
              in-enum: true
          - id: value
            type: gguf_value(type)
            valid:
              # `general.alignment` must be a `uint32` and a power of 2:
              # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L622-L636 (Git tag "v0.27.0")
              expr: |
                key.data == "general.alignment"
                  ? (
                    type == gguf_type::gguf_type_uint32 and
                    _.value.as<gguf_uint32>.value != 0 and
                    _.value.as<gguf_uint32>.value & (_.value.as<gguf_uint32>.value - 1) == 0
                  )
                  : true
            -affected-by: 1260 # this `valid/expr` doesn't compile in C++11
        instances:
          alignment:
            value: |
              key.data == "general.alignment"
                ? value.value.as<gguf_uint32>.value
                : prev_alignment

      gguf_str:
        -webide-representation: '"{data}"'
        seq:
          - id: size
            type: u8
          - id: data
            size: size
            type: str
            encoding: UTF-8
            doc-ref: https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/docs/gguf.md?plain=1#L235-L236 Git tag "v0.27.0"

      gguf_array:
        doc: |
          Nested arrays are supported. Although ggml (v0.27.0) doesn't support them,
          they are explicitly allowed by `gguf.md` - see
          <https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/docs/gguf.md?plain=1#L221>.
        -webide-representation: '[{elems}]'
        seq:
          - id: type
            type: u4
            enum: gguf_type
            valid:
              # Like ggml, except that nested arrays are allowed (see the `doc` above):
              # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L593-L612 (Git tag "v0.27.0")
              in-enum: true
          - id: num_elems
            type: u8
          - id: elems
            type: gguf_value(type) # Allows for nested arrays
            repeat: expr
            repeat-expr: num_elems

      gguf_bool:
        # This type is used as a work-around for languages (like C++)
        # that do not support variant types.
        -webide-representation: '{value}'
        seq:
          - id: value_raw
            type: u1
            valid:
              # ggml doesn't check this, but `gguf.md` says that anything other than
              # 0 or 1 is invalid:
              # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/docs/gguf.md?plain=1#L213-L216 (Git tag "v0.27.0")
              max: 1
        instances:
          value:
            value: value_raw != 0
            doc-ref: https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L321 Git tag "v0.27.0"

      gguf_uint8:
        # This type is used as a work-around for languages (like C++)
        # that do not support variant types.
        -webide-representation: '{value:dec}'
        seq:
          - id: value
            type: u1

      gguf_int8:
        # This type is used as a work-around for languages (like C++)
        # that do not support variant types.
        -webide-representation: '{value:dec}'
        seq:
          - id: value
            type: s1

      gguf_uint16:
        # This type is used as a work-around for languages (like C++)
        # that do not support variant types.
        -webide-representation: '{value:dec}'
        seq:
          - id: value
            type: u2

      gguf_int16:
        # This type is used as a work-around for languages (like C++)
        # that do not support variant types.
        -webide-representation: '{value:dec}'
        seq:
          - id: value
            type: s2

      gguf_uint32:
        # This type is used as a work-around for languages (like C++)
        # that do not support variant types.
        -webide-representation: '{value:dec}'
        seq:
          - id: value
            type: u4

      gguf_int32:
        # This type is used as a work-around for languages (like C++)
        # that do not support variant types.
        -webide-representation: '{value:dec}'
        seq:
          - id: value
            type: s4

      gguf_uint64:
        # This type is used as a work-around for languages (like C++)
        # that do not support variant types.
        -webide-representation: '{value:dec}'
        seq:
          - id: value
            type: u8

      gguf_int64:
        # This type is used as a work-around for languages (like C++)
        # that do not support variant types.
        -webide-representation: '{value:dec}'
        seq:
          - id: value
            type: s8

      gguf_float32:
        # This type is used as a work-around for languages (like C++)
        # that do not support variant types.
        -webide-representation: '{value}'
        seq:
          - id: value
            type: f4

      gguf_float64:
        # This type is used as a work-around for languages (like C++)
        # that do not support variant types.
        -webide-representation: '{value}'
        seq:
          - id: value
            type: f8

      gguf_tensor_info:
        -webide-representation: '{type}[{dims}] {name}'
        params:
          - id: expected_offset
            type: u8
        seq:
          - id: name
            type: gguf_str
            valid:
              # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L657-L661 (Git tag "v0.27.0")
              expr: _.size < 64
            -affected-by: 1260 # this `valid/expr` doesn't compile in C++11
          - id: num_dims
            type: u4
            valid:
              # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L679-L684 (Git tag "v0.27.0")
              max: 4
          - id: dims
            type: s8
            valid:
              # ggml reads them as `int64_t` too (even though `gguf.md` says
              # `uint64_t`) and rejects negative ones:
              # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L691-L697 (Git tag "v0.27.0")
              min: 0
            repeat: expr
            repeat-expr: num_dims
          - id: type
            type: u4
            enum: ggml_type
            valid:
              # ggml accepts only types it can still read (`num_elements_per_block`
              # must not be 0), and only rows consisting of whole blocks:
              # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L729-L746 (Git tag "v0.27.0")
              expr: |
                _.to_i < 43 and
                num_elements_per_block != 0 and
                (num_dims > 0 ? dims[0] : 1) % num_elements_per_block == 0
          - id: offset
            type: u8
            # Each tensor's data must start right where the previous tensor's padded
            # data ends (the first tensor's data offset must be 0), as in ggml:
            # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L790-L820 (Git tag "v0.27.0")
            valid: expected_offset
            doc: Offset of the tensor's data, relative to `_parent.ofs_tensor_data`
        instances:
          num_elements:
            value: |
              (num_dims > 0 ? dims[0] : 1) *
              (num_dims > 1 ? dims[1] : 1) *
              (num_dims > 2 ? dims[2] : 1) *
              (num_dims > 3 ? dims[3] : 1)
          # `num_elements_per_block` and `len_block` are the `.blck_size` and
          # `.type_size` fields of `type_traits[type]` in ggml, see
          # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/ggml.c#L643-L957 (Git tag "v0.27.0")
          #
          # For removed types, both fields are 0, as in ggml.
          num_elements_per_block:
            -orig-id: blck_size
            value: |
              [
                1, 1, 32, 32, 0, 0, 32, 32, 32, 32,
                256, 256, 256, 256, 256, 256, 256, 256, 256, 256,
                32, 256, 256, 256, 1, 1, 1, 1, 1, 256,
                1, 0, 0, 0, 256, 256, 0, 0, 0, 32,
                64, 128, 64
              ][type.to_i]
            doc: Number of elements in a block
          len_block:
            -orig-id: type_size
            value: |
              [
                4, 2, 18, 20, 0, 0, 22, 24, 34, 36,
                84, 110, 144, 176, 210, 292, 66, 74, 98, 50,
                18, 110, 82, 136, 1, 2, 4, 8, 8, 56,
                2, 0, 0, 0, 54, 66, 0, 0, 0, 17,
                36, 18, 18
              ][type.to_i]
            doc: Size of a block in bytes
          num_blocks:
            value: num_elements / num_elements_per_block
          len_data:
            value: len_block * num_blocks
          len_padding:
            value: (_parent.alignment - len_data % _parent.alignment) % _parent.alignment
            doc: Number of padding bytes after the data
          expected_next_offset:
            value: offset + len_data + len_padding
            doc: '`offset` that the next tensor must have'
          data:
            pos: _parent.ofs_tensor_data + offset
            size: len_data
          padding:
            pos: _parent.ofs_tensor_data + offset + len_data
            size: len_padding
            doc: |
              Padding after the data. ggml requires it even after the last tensor
              when reading the tensor data.
            doc-ref: https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/src/gguf.cpp#L884-L893 Git tag "v0.27.0"

enums:
  gguf_type:
    0: gguf_type_uint8
    1: gguf_type_int8
    2: gguf_type_uint16
    3: gguf_type_int16
    4: gguf_type_uint32
    5: gguf_type_int32
    6: gguf_type_float32
    7: gguf_type_bool
    8: gguf_type_string
    9: gguf_type_array
    10: gguf_type_uint64
    11: gguf_type_int64
    12: gguf_type_float64

  # https://github.com/ggml-org/ggml/blob/a05c9922613c6a2230dbb1d0de679519ecafb4f0/include/ggml.h#L389-L434 (Git tag "v0.27.0")
  ggml_type:
    0: ggml_type_f32
    1: ggml_type_f16
    2: ggml_type_q4_0
    3: ggml_type_q4_1
    4:
      id: ggml_type_q4_2
      doc: |
        Removed from ggml in May 2023, before GGUF was introduced. ggml
        rejects it.
      doc-ref: https://github.com/ggml-org/llama.cpp/commit/b9fd7eee57df101d4a3e3eabc9fd6c2cb13c9ca1
    5:
      id: ggml_type_q4_3
      doc: |
        Removed from ggml in April 2023, before GGUF was introduced. ggml
        rejects it.
      doc-ref: https://github.com/ggml-org/llama.cpp/commit/36d19a603b221d1bd7897fcb10e823e2103b052d
    6: ggml_type_q5_0
    7: ggml_type_q5_1
    8: ggml_type_q8_0
    9: ggml_type_q8_1
    10: ggml_type_q2_k
    11: ggml_type_q3_k
    12: ggml_type_q4_k
    13: ggml_type_q5_k
    14: ggml_type_q6_k
    15: ggml_type_q8_k
    16: ggml_type_iq2_xxs
    17: ggml_type_iq2_xs
    18: ggml_type_iq3_xxs
    19: ggml_type_iq1_s
    20: ggml_type_iq4_nl
    21: ggml_type_iq3_s
    22: ggml_type_iq2_s
    23: ggml_type_iq4_xs
    24: ggml_type_i8
    25: ggml_type_i16
    26: ggml_type_i32
    27: ggml_type_i64
    28: ggml_type_f64
    29: ggml_type_iq1_m
    30: ggml_type_bf16
    31:
      id: ggml_type_q4_0_4_4
      doc: |
        Removed from ggml in December 2024 in favor of repacking
        `ggml_type_q4_0` at load time. ggml rejects it, although files with
        it exist, e.g.
        [`Qwen2.5-0.5B-Instruct-Q4_0_4_4.gguf`](https://huggingface.co/bartowski/Qwen2.5-0.5B-Instruct-GGUF/blob/41ba88dbac95fed2528c92514c131d73eb5a174b/Qwen2.5-0.5B-Instruct-Q4_0_4_4.gguf).
      doc-ref: https://github.com/ggml-org/llama.cpp/commit/19d8762ab61df8286367588a80b9c7db4cb568db
    32:
      id: ggml_type_q4_0_4_8
      doc: |
        Removed from ggml in December 2024 in favor of repacking
        `ggml_type_q4_0` at load time. ggml rejects it, although files with
        it exist, e.g.
        [`Qwen2.5-0.5B-Instruct-Q4_0_4_8.gguf`](https://huggingface.co/bartowski/Qwen2.5-0.5B-Instruct-GGUF/blob/41ba88dbac95fed2528c92514c131d73eb5a174b/Qwen2.5-0.5B-Instruct-Q4_0_4_8.gguf).
      doc-ref: https://github.com/ggml-org/llama.cpp/commit/19d8762ab61df8286367588a80b9c7db4cb568db
    33:
      id: ggml_type_q4_0_8_8
      doc: |
        Removed from ggml in December 2024 in favor of repacking
        `ggml_type_q4_0` at load time. ggml rejects it, although files with
        it exist, e.g.
        [`Qwen2.5-0.5B-Instruct-Q4_0_8_8.gguf`](https://huggingface.co/bartowski/Qwen2.5-0.5B-Instruct-GGUF/blob/41ba88dbac95fed2528c92514c131d73eb5a174b/Qwen2.5-0.5B-Instruct-Q4_0_8_8.gguf).
      doc-ref: https://github.com/ggml-org/llama.cpp/commit/19d8762ab61df8286367588a80b9c7db4cb568db
    34: ggml_type_tq1_0
    35: ggml_type_tq2_0
    36:
      id: ggml_type_iq4_nl_4_4
      doc: |
        Supported by ggml only from November to December 2024, and only for
        repacking tensors in memory - it was never written to files. ggml
        rejects it.
      doc-ref: https://github.com/ggml-org/llama.cpp/commit/19d8762ab61df8286367588a80b9c7db4cb568db
    37:
      id: ggml_type_iq4_nl_4_8
      doc: Reserved by ggml, but never supported. ggml rejects it.
      doc-ref: https://github.com/ggml-org/llama.cpp/commit/c202cef1686182a78f8f4e253ab8d0c0ffe2fcc8
    38:
      id: ggml_type_iq4_nl_8_8
      doc: Reserved by ggml, but never supported. ggml rejects it.
      doc-ref: https://github.com/ggml-org/llama.cpp/commit/c202cef1686182a78f8f4e253ab8d0c0ffe2fcc8
    39: ggml_type_mxfp4
    40: ggml_type_nvfp4
    41: ggml_type_q1_0
    42: ggml_type_q2_0
