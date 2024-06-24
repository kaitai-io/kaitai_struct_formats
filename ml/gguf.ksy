meta:
  id: gguf
  title: GGML model file
  file-extension: gguf
  license: CC0-1.0
  ks-version: 0.10
  endian: le
  bit-endian: le
doc: |
  GGUF is a file format for storing models for inference with GGML and 
  executors based on GGML. GGUF is a binary format that is designed for
  fast loading and saving of models, and for ease of reading. Models 
  are traditionally developed using PyTorch or another framework, and 
  then converted to GGUF for use in GGML.

  It is a successor file format to GGML, GGMF and GGJT, and is designed 
  to be unambiguous by containing all the information needed to load a 
  model. It is also designed to be extensible, so that new information 
  can be added to models without breaking compatibility.
doc-ref:
  - https://github.com/ggerganov/ggml/blob/master/docs/gguf.md
seq:
  - id: magic
    contents: GGUF
  - id: version
    type: u4
  - id: num_infos
    type: u8
    doc: The number of tensors in the file
  - id: num_kv
    type: u8
    doc: The number of header key-value pairs
  - id: kv
    type: gguf_kv
    repeat: expr
    repeat-expr: num_kv
  - id: infos
    type: gguf_tensor_info
    repeat: expr
    repeat-expr: num_infos
  - id: data
    type: gguf_tensor_data(_io.pos)
    
    
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
    seq:
      - id: key
        type: gguf_str
      - id: type
        type: u4
        enum: gguf_type
      - id: value
        type: gguf_value(type)
         

  gguf_str:
    -webide-representation: '"{data}"'
    seq:
      - id: size
        type: u8
      - id: data
        size: size
        type: str
        encoding: ascii

  gguf_array:
    # Note that this is more permissive than the parser defined
    # by the GGML library which does not permit nested arrays.
    -webide-representation: '[{elems}]'
    seq:
      - id: type
        type: u4
        enum: gguf_type
      - id: num_elems
        type: u8
      - id: elems
        type: gguf_value(type) # Allows for nested arrays
        repeat: expr
        repeat-expr: num_elems

  gguf_bool:
    # This type is used as a work-around for languages (like C++) that do not support variant types.
    -webide-representation: '{value}'
    seq:
      - id: value
        type: b1

  gguf_uint8:
    # This type is used as a work-around for languages (like C++) that do not support variant types.
    -webide-representation: '{value:dec}'
    seq:
      - id: value
        type: u1

  gguf_int8:
    # This type is used as a work-around for languages (like C++) that do not support variant types.
    -webide-representation: '{value:dec}'
    seq:
      - id: value
        type: s1
        
  gguf_uint16:
    # This type is used as a work-around for languages (like C++) that do not support variant types.
    -webide-representation: '{value:dec}'
    seq:
      - id: value
        type: u2

  gguf_int16:
    # This type is used as a work-around for languages (like C++) that do not support variant types.
    -webide-representation: '{value:dec}'
    seq:
      - id: value
        type: s2

  gguf_uint32:
    # This type is used as a work-around for languages (like C++) that do not support variant types.
    -webide-representation: '{value:dec}'
    seq:
      - id: value
        type: u4

  gguf_int32:
    # This type is used as a work-around for languages (like C++) that do not support variant types.
    -webide-representation: '{value:dec}'
    seq:
      - id: value
        type: s4
  
  gguf_uint64:
    # This type is used as a work-around for languages (like C++) that do not support variant types.
    -webide-representation: '{value:dec}'
    seq:
      - id: value
        type: u8

  gguf_int64:
    # This type is used as a work-around for languages (like C++) that do not support variant types.
    -webide-representation: '{value:dec}'
    seq:
      - id: value
        type: s8

  gguf_float32:
    # This type is used as a work-around for languages (like C++) that do not support variant types.
    -webide-representation: '{value}'
    seq:
      - id: value
        type: f4

  gguf_float64:
    # This type is used as a work-around for languages (like C++) that do not support variant types.
    -webide-representation: '{value}'
    seq:
      - id: value
        type: f8
    
  gguf_tensor_info:
    -webide-representation: '{type}[{dims}] {name}'
    seq:
      - id: name
        type: gguf_str
      - id: num_dims
        type: u4
      - id: dims
        type: gguf_uint64
        repeat: expr
        repeat-expr: num_dims
      - id: type
        type: u4
        enum: ggml_type
      - id: offset
        type: u8
  
  gguf_tensor_data:
    params:
      - id: offset
        type: u8
    instances:
      padding:
        # This hardcodes the default GGUF file alignment (32).
        pos: offset
        size: 32 - (offset % 32)
      data:
        pos: offset + padding.size
        size-eos: true

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
    
  ggml_type:
    0: ggml_type_f32
    1: ggml_type_f16
    2: ggml_type_q4_0
    3: ggml_type_q4_1
    4: ggml_type_q4_2
    5: ggml_type_q4_3
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
