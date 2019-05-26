meta:
  id: osu_string
  endian: le
  imports:
    - /common/vlq_base128_le
seq:
  - id: indicator
    type: u1
  - id: string_length
    type: vlq_base128_le
    if: indicator == 0x0b
  - id: value
    type: str
    encoding: UTF-8
    size: string_length.value
    if: indicator == 0x0b
