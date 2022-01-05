meta:
  id: ruby_marshal
  license: CC0-1.0
  endian: le
doc: |
  Ruby's Marshal module allows serialization and deserialization of
  many standard and arbitrary Ruby objects in a compact binary
  format. It is relatively fast, available in stdlibs standard and
  allows conservation of language-specific properties (such as symbols
  or encoding-aware strings).

  Feature-wise, it is comparable to other language-specific
  implementations, such as:

  * Java's
    [Serializable](https://docs.oracle.com/javase/8/docs/api/java/io/Serializable.html)
  * .NET
    [BinaryFormatter](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.serialization.formatters.binary.binaryformatter)
  * Python's
    [marshal](https://docs.python.org/3/library/marshal.html),
    [pickle](https://docs.python.org/3/library/pickle.html) and
    [shelve](https://docs.python.org/3/library/shelve.html)

  From internal perspective, serialized stream consists of a simple
  magic header and a record.
doc-ref: 'https://docs.ruby-lang.org/en/2.4.0/marshal_rdoc.html#label-Stream+Format'
seq:
  - id: version
    contents: [4, 8]
  - id: records
    type: record
types:
  record:
    doc: |
      Each record starts with a single byte that determines its type
      (`code`) and contents. If necessary, additional info as parsed
      as `body`, to be determined by `code`.
    seq:
      - id: code
        type: u1
        enum: codes
      - id: body
        type:
          switch-on: code
          cases:
            'codes::bignum': bignum
            'codes::instance_var': instance_var
            'codes::packed_int': packed_int
            'codes::ruby_array': ruby_array
            'codes::ruby_hash': ruby_hash
            'codes::ruby_string': ruby_string
            'codes::ruby_struct': ruby_struct
            'codes::ruby_symbol': ruby_symbol
            'codes::ruby_symbol_link': packed_int
            'codes::ruby_object_link': packed_int
  packed_int:
    doc: |
      Ruby uses sophisticated system to pack integers: first `code`
      byte either determines packing scheme or carries encoded
      immediate value (thus allowing smaller values from -123 to 122
      (inclusive) to take only one byte. There are 11 encoding schemes
      in total:

      * 0 is encoded specially (as 0)
      * 1..122 are encoded as immediate value with a shift
      * 123..255 are encoded with code of 0x01 and 1 extra byte
      * 0x100..0xffff are encoded with code of 0x02 and 2 extra bytes
      * 0x10000..0xffffff are encoded with code of 0x03 and 3 extra
        bytes
      * 0x1000000..0xffffffff are encoded with code of 0x04 and 4
        extra bytes
      * -123..-1 are encoded as immediate value with another shift
      * -256..-124 are encoded with code of 0xff and 1 extra byte
      * -0x10000..-257 are encoded with code of 0xfe and 2 extra bytes
      * -0x1000000..0x10001 are encoded with code of 0xfd and 3 extra
         bytes
      * -0x40000000..-0x1000001 are encoded with code of 0xfc and 4
         extra bytes

      Values beyond that are serialized as bignum (even if they
      technically might be not Bignum class in Ruby implementation,
      i.e. if they fit into 64 bits on a 64-bit platform).
    doc-ref: 'https://docs.ruby-lang.org/en/2.4.0/marshal_rdoc.html#label-Fixnum+and+long'
    seq:
      - id: code
        type: u1
      - id: encoded
        type:
          switch-on: code
          cases:
            # 0x00: none
            0x01: u1
            0x02: u2
            0x03: u2
            0x04: u4
            0xff: u1
            0xfe: u2
            0xfd: u2
            0xfc: u4
      - id: encoded2
        type:
          switch-on: code
          cases:
            0x03: u1
            0xfd: u1
        doc: |
          One extra byte for 3-byte integers (0x03 and 0xfd), as
          there is no standard `u3` type in KS.
    instances:
      is_immediate:
        value: code > 4 and code < 0xfc
      value:
        value: >
          is_immediate ? (code < 0x80 ? code - 5 : (4 - (~code & 0x7f))) :
          code == 0 ? 0 :
          code == 0xff ? (encoded - 0x100) :
          code == 0xfe ? (encoded - 0x10000) :
          code == 0xfd ? ((encoded2 << 16 | encoded) - 0x1000000) :
          code == 0x03 ? (encoded2 << 16 | encoded) :
          encoded
  ruby_symbol:
    doc-ref: 'https://docs.ruby-lang.org/en/2.4.0/marshal_rdoc.html#label-Symbols+and+Byte+Sequence'
    seq:
      - id: len
        type: packed_int
      - id: name
        size: len.value
        type: str
        encoding: UTF-8
  ruby_string:
    doc-ref: 'https://docs.ruby-lang.org/en/2.4.0/marshal_rdoc.html#label-String'
    seq:
      - id: len
        type: packed_int
      - id: body
        size: len.value
  ruby_array:
    seq:
      - id: num_elements
        type: packed_int
      - id: elements
        type: record
        repeat: expr
        repeat-expr: num_elements.value
  ruby_hash:
    doc-ref: 'https://docs.ruby-lang.org/en/2.4.0/marshal_rdoc.html#label-Hash+and+Hash+with+Default+Value'
    seq:
      - id: num_pairs
        type: packed_int
      - id: pairs
        type: pair
        repeat: expr
        repeat-expr: num_pairs.value
  bignum:
    doc-ref: 'https://docs.ruby-lang.org/en/2.4.0/marshal_rdoc.html#label-Bignum'
    seq:
      - id: sign
        type: u1
        doc: A single byte containing `+` for a positive value or `-` for a negative value.
      - id: len_div_2
        type: packed_int
        doc: Length of bignum body, divided by 2.
      - id: body
        size: len_div_2.value * 2
        doc: Bytes that represent the number, see ruby-lang.org docs for reconstruction algorithm.
  ruby_struct:
    doc-ref: 'https://docs.ruby-lang.org/en/2.4.0/marshal_rdoc.html#label-Struct'
    seq:
      - id: name
        type: record
        doc: Symbol containing the name of the struct.
      - id: num_members
        type: packed_int
        doc: Number of members in a struct
      - id: members
        type: pair
        repeat: expr
        repeat-expr: num_members.value
  instance_var:
    doc-ref: 'https://docs.ruby-lang.org/en/2.4.0/marshal_rdoc.html#label-Instance+Variables'
    seq:
      - id: obj
        type: record
      - id: num_vars
        type: packed_int
      - id: vars
        type: pair
        repeat: expr
        repeat-expr: num_vars.value
  pair:
    seq:
      - id: key
        type: record
      - id: value
        type: record
enums:
  codes:
    0x22: ruby_string
    0x30: const_nil
    0x3a: ruby_symbol
    0x3b: ruby_symbol_link
    0x40: ruby_object_link
    0x46: const_false
    0x49: instance_var
    0x53: ruby_struct
    0x54: const_true
    0x5b: ruby_array
    0x69: packed_int
    0x6c: bignum
    0x7b: ruby_hash
