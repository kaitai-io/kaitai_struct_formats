meta:
  id: checksum_simple_additive_u1
  license: Unlicense
  title: Computes a simple additive checksum
  endian: le
doc: |
  assert calcChecksum(0xFF, b"abcde") == 238
  assert calcChecksum(0xFF, b"abcdef") == 84
  assert calcChecksum(0xFF, b"abcdefgh") == 35
  assert calcChecksum(0xFF, bytes(range(256))) == 127

  assert calcChecksum(0, b"abcde") == 239
  assert calcChecksum(0, b"abcdef") == 85
  assert calcChecksum(0, b"abcdefgh") == 36
  assert calcChecksum(0, bytes(range(256))) == 128
params:
  - id: initial
    type: u1
  - id: data
    type: bytes
instances:
  reduction:
    pos: 0
    size: 0
    type: iteration(_index)
    repeat: expr
    repeat-expr: data.size
  value:
    value: reduction[data.size - 1].res & 0xFF
types:
  iteration:
    params:
      - id: idx
        type: u4
    instances:
      prev:
        value: "idx == 0 ? _root.initial : (_parent.reduction[idx - 1].as<iteration>.res).as<u1>"
      res:
        value: prev + _parent.data[idx]
