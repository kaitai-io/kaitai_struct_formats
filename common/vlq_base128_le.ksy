meta:
  id: vlq_base128_le
  title: Variable length quantity, unsigned/signed integer, base128, little-endian
  license: CC0-1.0
  ks-version: 0.7
doc: |
  A variable-length unsigned/signed integer using base128 encoding. 1-byte groups
  consist of 1-bit flag of continuation and 7-bit value chunk, and are ordered
  "least significant group first", i.e. in "little-endian" manner.

  This particular encoding is specified and used in:

  * DWARF debug file format, where it's dubbed "unsigned LEB128" or "ULEB128".
    http://dwarfstd.org/doc/dwarf-2.0.0.pdf - page 139
  * Google Protocol Buffers, where it's called "Base 128 Varints".
    https://developers.google.com/protocol-buffers/docs/encoding?csw=1#varints
  * Apache Lucene, where it's called "VInt"
    https://lucene.apache.org/core/3_5_0/fileformats.html#VInt
  * Apache Avro uses this as a basis for integer encoding, adding ZigZag on
    top of it for signed ints
    https://avro.apache.org/docs/current/spec.html#binary_encode_primitive

  More information on this encoding is available at https://en.wikipedia.org/wiki/LEB128

  This particular implementation supports serialized values to up 8 bytes long.
-webide-representation: '{value:dec}'
seq:
  - id: groups
    type: group
    repeat: until
    repeat-until: not _.has_next
types:
  group:
    -webide-representation: '{value}'
    doc: |
      One byte group, clearly divided into 7-bit "value" chunk and 1-bit "continuation" flag.
    seq:
      - id: b
        type: u1
    instances:
      has_next:
        value: (b & 0b1000_0000) != 0
        doc: If true, then we have more bytes to read
      value:
        value: b & 0b0111_1111
        doc: The 7-bit (base128) numeric value chunk of this group
instances:
  len:
    value: groups.size
  value:
    value: >-
      groups[0].value
      + (len >= 2 ? (groups[1].value << 7) : 0)
      + (len >= 3 ? (groups[2].value << 14) : 0)
      + (len >= 4 ? (groups[3].value << 21) : 0)
      + (len >= 5 ? (groups[4].value << 28) : 0)
      + (len >= 6 ? (groups[5].value << 35) : 0)
      + (len >= 7 ? (groups[6].value << 42) : 0)
      + (len >= 8 ? (groups[7].value << 49) : 0)
    doc: Resulting unsigned value as normal integer
  sign_bit:
    value: '1 << (7 * len - 1)'
  value_signed:
    value: '(value ^ sign_bit) - sign_bit'
    doc-ref: https://graphics.stanford.edu/~seander/bithacks.html#VariableSignExtend
