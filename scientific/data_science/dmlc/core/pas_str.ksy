meta:
  id: pas_str
  title: dmlc_core string
  license: Apache-2.0
  endian: le # in fact machine-endian
  encoding: ascii
doc: It's a string serialized by dmlc-core. It is called pas_str because such a format is known as pascal string.
doc-ref: https://github.com/dmlc/dmlc-core/blob/a6c5701219e635fea808d264aefc5b03c3aec314/include/dmlc/serializer.h#L155L175
seq:
  - id: len
    type: u8
  - id: str
    type: str
    size: len
