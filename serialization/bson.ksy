meta:
  id: bson
  file-extension: bson
  xref:
    justsolve: BSON
    mime: application/bson
    wikidata: Q2661480
  license: CC0-1.0
  endian: le
doc: >
  BSON, short for Binary JSON, is a binary-encoded serialization of JSON-like documents. Like JSON, BSON supports the embedding of documents and arrays within other documents and arrays. BSON also contains extensions that allow representation of data types that are not part of the JSON spec. For example, BSON has a Date type and a BinData type.
  BSON can be compared to binary interchange formats, like Protocol Buffers. BSON is more "schemaless" than Protocol Buffers, which can give it an advantage in flexibility but also a slight disadvantage in space efficiency (BSON has overhead for field names within the serialized data).
  BSON was designed to have the following three characteristics:
    * Lightweight. Keeping spatial overhead to a minimum is important for any data representation format, especially when used over the network.
    * Traversable. BSON is designed to be traversed easily. This is a vital property in its role as the primary data representation for MongoDB.
    * Efficient. Encoding data to BSON and decoding from BSON can be performed very quickly in most languages due to the use of C data types.
seq:
  - id: len
    type: s4
    doc: "Total number of bytes comprising the document."
  - id: fields
    type: elements_list
    size: len - 5
  - id: terminator
    contents: [0]
types:
  code_with_scope:
    seq:
      - id: id
        type: s4
      - id: source
        type: string
      - id: scope
        type: bson
        doc: "mapping from identifiers to values, representing the scope in which the string should be evaluated."
  elements_list:
    seq:
      - id: elements
        type: element
        repeat: eos
  reg_ex:
    seq:
      - id: pattern
        type: cstring
      - id: options
        type: cstring
  string:
    seq:
      - id: len
        type: s4
      - id: str
        type: str
        encoding: UTF-8
        size: len-1
      - id: terminator
        contents: [0]
  cstring:
    seq:
      - id: str
        type: strz
        encoding: UTF-8
        doc: "MUST NOT contain '\\x00', hence it is not full UTF-8."
  f16:
    doc: "128-bit IEEE 754-2008 decimal floating point"
    seq:
      - id: str
        type: b1
      - id: exponent
        type: b15
      - id: significand_hi
        type: b49
      - id: significand_lo
        type: u8
  object_id:
    doc: "https://docs.mongodb.com/manual/reference/method/ObjectId/"
    seq:
      - id: epoch_time
        type: u4
        doc: "seconds since the Unix epoch"
      - id: machine_id
        type: u3
      - id: process_id
        type: u2
      - id: counter
        type: u3
        doc: "counter, starting with a random value."
  db_pointer:
    seq:
      - id: namespace
        type: string
      - id: id
        type: object_id
  timestamp:
    doc: "Special internal type used by MongoDB replication and sharding. First 4 bytes are an increment, second 4 are a timestamp."
    seq:
      - id: increment
        type: u4
      - id: timestamp
        type: u4
  bin_data:
    doc: "The BSON \"binary\" or \"BinData\" datatype is used to represent arrays of bytes. It is somewhat analogous to the Java notion of a ByteArray. BSON binary values have a subtype. This is used to indicate what kind of data is in the byte array. Subtypes from zero to 127 are predefined or reserved. Subtypes from 128-255 are user-defined."
    seq:
      - id: len
        type: s4
      - id: subtype
        type: u1
        enum: subtype
      - id: content
        size: len
        type:
          switch-on: subtype
          cases:
            'subtype::byte_array_deprecated': byte_array_deprecated
    types:
      byte_array_deprecated:
        doc: "The BSON \"binary\" or \"BinData\" datatype is used to represent arrays of bytes. It is somewhat analogous to the Java notion of a ByteArray. BSON binary values have a subtype. This is used to indicate what kind of data is in the byte array. Subtypes from zero to 127 are predefined or reserved. Subtypes from 128-255 are user-defined."
        seq:
          - id: len
            type: s4
          - id: content
            size: len
    enums:
      subtype:
        0x00: generic #Generic binary subtype
        0x01: function
        0x02: byte_array_deprecated #This used to be the default subtype, but was deprecated in favor of \\x00. Drivers and tools should be sure to handle \\x02 appropriately. The structure of the binary data (the byte* array in the binary non-terminal) must be an int32 followed by a (byte*). The int32 is the number of bytes in the repetition.
        0x03: uuid_deprecated #This used to be the UUID subtype, but was deprecated in favor of \\x04. Drivers and tools for languages with a native UUID type should handle \\x03 appropriately.
        0x04: uuid
        0x05: md5
        0x80: custom #\\x80-\\xFF "User defined" subtypes. The binary data can be anything.
  element:
    seq:
      - id: type_byte
        type: u1
        enum: bson_type
      - id: name
        type: cstring
      - id: content
        #if: "(type!=type::undefined && type!=type::null && type!=type::min_key && type!=type::max_key)"
        type:
          switch-on: type_byte
          cases:
            'bson_type::number_double': f8
            'bson_type::string': string
            'bson_type::document': bson
            'bson_type::array': bson
            'bson_type::bin_data': bin_data
            'bson_type::object_id': object_id
            'bson_type::boolean': u1
            'bson_type::utc_datetime': s8 #The int64 is UTC milliseconds since the Unix epoch.
            'bson_type::reg_ex': reg_ex
            'bson_type::db_pointer': db_pointer
            'bson_type::javascript': string
            'bson_type::symbol': string # a programming language (e.g., Python) symbol
            'bson_type::code_with_scope': code_with_scope
            'bson_type::number_int': s4
            'bson_type::timestamp': timestamp
            'bson_type::number_long': s8
            'bson_type::number_decimal': f16
    enums:
      bson_type:
        0x00: end_of_object
        0x01: number_double
        0x02: string
        0x03: document
        0x04: array #The document for an array is a normal BSON document with integer values for the keys, starting with 0 and continuing sequentially. For example, the array ['red', 'blue'] would be encoded as the document {'0': 'red', '1': 'blue'}. The keys must be in ascending numerical order.
        0x05: bin_data #This is the most commonly used binary subtype and should be the 'default' for drivers and tools.
        0x06: undefined
        0x07: object_id
        0x08: boolean
        0x09: utc_datetime
        0x0a: jst_null
        0x0b: reg_ex
        0x0c: db_pointer
        0x0d: javascript
        0x0e: symbol
        0x0f: code_with_scope
        0x10: number_int
        0x11: timestamp
        0x12: number_long
        0x13: number_decimal
        0x7f: max_key #Special type which compares higher than all other possible BSON element values.
        -1: min_key #Special type which compares lower than all other possible BSON element values.
  u3:
    doc: |
      Implements unsigned 24-bit (3 byte) integer.
    seq:
      - id: b1
        type: u1
      - id: b2
        type: u1
      - id: b3
        type: u1
    instances:
      value:
        value: 'b1 | (b2 << 8) | (b3 << 16)'
