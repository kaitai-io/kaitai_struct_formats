meta:
  id: str_pair
  title: dmlc_core string
  license: Apache-2.0
  endian: le # in fact machine-endian
  encoding: ascii
  imports:
    - ./pas_str
doc: It's a pair of strings serialized by dmlc-core
doc-ref: https://github.com/dmlc/dmlc-core/blob/a6c5701219e635fea808d264aefc5b03c3aec314/include/dmlc/serializer.h#L178L188
seq:
  - id: pair
    type: pas_str
    repeat: expr
    repeat-expr: 2
