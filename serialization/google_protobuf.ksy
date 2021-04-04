meta:
  id: google_protobuf
  title: Google Protocol Buffers (protobuf)
  xref:
    justsolve: Protobuf
    wikidata: Q1645574
  license: MIT
  ks-version: 0.7
  imports:
    - /common/vlq_base128_le
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
doc-ref: https://developers.google.com/protocol-buffers/docs/encoding
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
