meta:
  id: str_pair_arr
  title: dmlc_core sptring pairs array
  license: Apache-2.0
  endian: le # in fact machine-endian
  encoding: ascii
  imports:
    - ./str_pair
doc: It's an array of string pairs serialized by dmlc-core
doc-ref: https://github.com/dmlc/dmlc-core/blob/a6c5701219e635fea808d264aefc5b03c3aec314/include/dmlc/serializer.h#L105L124
seq:
  - id: len
    type: u8
  - id: data
    type: str_pair
    repeat: expr
    repeat-expr: len
