meta:
  id: google_protobuf
  title: Google Protocol Buffers (protobuf)
  ks-version: 0.7
# https://developers.google.com/protocol-buffers/docs/encoding
doc: |
  Google Protocol Buffers (AKA protobuf) is a popular data
  serialization scheme used for communication protocols, data storage,
  etc. There are implementations are available for almost every
  popular language. The focus points of this scheme are brevity (data
  is encoded in a very size-efficient manner) and extensibility (one
  can add keys to the structure, while keeping it readable in previous
  version of software).

  Protobuf uses semi-self-describing encoding scheme for its
  messages. It means that it is possible to parse overall structure of
  the message (skipping over fields one can't understand), but to
  fully understand the message, one needs a protocol definition file
  (`.proto`). To be specific:

  * "Keys" in key-value pairs provided in the message are identified
    only with an integer "field tag". `.proto` file provides info on
    which symbolic field names these field tags map to.
  * "Keys" also provide something called "wire type". It's not a data
    type in its common sense (i.e. you can't, for example, distinguish
    `sint32` vs `uint32` vs some enum, or `string` from `bytes`), but
    it's enough information to determine how many bytes to
    parse. Interpretation of the value should be done according to the
    type specified in `.proto` file.
  * There's no direct information on which fields are optional /
    required, which fields may be repeated or constitute a map, what
    restrictions are placed on fields usage in a single message, what
    are the fields' default values, etc, etc.
seq:
  - id: pairs
    type: pair
    repeat: eos
    doc: Key-value pairs which constitute a message
types:
  pair:
    doc: Key-value pair
    seq:
      - id: key
        type: vlq_base128_le
        doc: |
          Key is a bit-mapped variable-length integer: lower 3 bits
          are used for "wire type", and everything higher designates
          an integer "field tag".
      - id: value
        doc: |
          Value that corresponds to field identified by
          `field_tag`. Type is determined approximately: there is
          enough information to parse it unambiguously from a stream,
          but further infromation from `.proto` file is required to
          interprete it properly.
        type:
          switch-on: wire_type
          cases:
            'wire_types::varint': vlq_base128_le
            'wire_types::len_delimited': delimited_bytes
            'wire_types::bit_64': u8le
            'wire_types::bit_32': u4le
    instances:
      wire_type:
        value: 'key.value & 0b111'
        enum: wire_types
        doc: |
          "Wire type" is a part of the "key" that carries enough
          information to parse value from the wire, i.e. read correct
          amount of bytes, but there's not enough informaton to
          interprete in unambiguously. For example, one can't clearly
          distinguish 64-bit fixed-sized integers from 64-bit floats,
          signed zigzag-encoded varints from regular unsigned varints,
          arbitrary bytes from UTF-8 encoded strings, etc.
      field_tag:
        value: 'key.value >> 3'
        doc: |
          Identifies a field of protocol. One can look up symbolic
          field name in a `.proto` file by this field tag.
    enums:
      wire_types:
        0: varint
        1: bit_64
        2: len_delimited
        3: group_start
        4: group_end
        5: bit_32
  delimited_bytes:
    seq:
      - id: len
        type: vlq_base128_le
      - id: body
        size: len.value
# ========================================================================
  vlq_base128_le:
    meta:
      title: Variable length quantity, unsigned integer, base128, little-endian
    doc: |
      A variable-length unsigned integer using base128 encoding. 1-byte groups
      consists of 1-bit flag of continuation and 7-bit value, and are ordered
      "least significant group first", i.e. in "little-endian" manner.

      This particular encoding is specified and used in:

      * DWARF debug file format, where it's dubbed "unsigned LEB128" or "ULEB128".
        http://dwarfstd.org/doc/dwarf-2.0.0.pdf - page 139
      * Google Protocol Buffers, where it's called "Base 128 Varints".
        https://developers.google.com/protocol-buffers/docs/encoding?csw=1#varints
      * Apache Lucene, where it's called "VInt"
        http://lucene.apache.org/core/3_5_0/fileformats.html#VInt
      * Apache Avro uses this as a basis for integer encoding, adding ZigZag on
        top of it for signed ints
        http://avro.apache.org/docs/current/spec.html#binary_encode_primitive

      More information on this encoding is available at https://en.wikipedia.org/wiki/LEB128

      This particular implementation supports serialized values to up 8 bytes long.
    seq:
      - id: groups
        type: group
        repeat: until
        repeat-until: not _.has_next
    types:
      group:
        doc: |
          One byte group, clearly divided into 7-bit "value" and 1-bit "has continuation
          in the next byte" flag.
        seq:
          - id: b
            type: u1
        instances:
          has_next:
            value: (b & 0b1000_0000) != 0
            doc: If true, then we have more bytes to read
          value:
            value: b & 0b0111_1111
            doc: The 7-bit (base128) numeric value of this group
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
        doc: Resulting value as normal integer
