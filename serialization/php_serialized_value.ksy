meta:
  id: php_serialized_value
  title: Serialized PHP value
  application: PHP
  license: CC0-1.0
  ks-version: 0.9
  # No endianness, since all numbers are stored as ASCII decimal.
  # This encoding is only used to parse numbers. All strings, class names, etc.
  # are treated as raw byte arrays, because PHP strings are byte strings
  # with no particular encoding.
  encoding: ASCII
doc: |
  A serialized PHP value, in the format used by PHP's built-in `serialize` and
  `unserialize` functions. This format closely mirrors PHP's data model:
  it supports all of PHP's scalar types (`NULL`, booleans, numbers, strings),
  associative arrays, objects, and recursive data structures using references.
  The only PHP values not supported by this format are *resources*,
  which usually correspond to native file or connection handles and cannot be
  meaningfully serialized.

  There is no official documentation for this data format;
  this spec was created based on the PHP source code and the behavior of
  `serialize`/`unserialize`. PHP makes no guarantees about compatibility of
  serialized data between PHP versions, but in practice, the format has
  remained fully backwards-compatible - values serialized by an older
  PHP version can be unserialized on any newer PHP version.
  This spec supports serialized values from PHP 7.3 or any earlier version.
doc-ref:
  - 'https://www.php.net/manual/en/function.serialize.php'
  - 'https://www.php.net/manual/en/function.serialize.php#66147'
  - 'https://www.php.net/manual/en/function.unserialize.php'
  - 'https://github.com/php/php-src/blob/php-7.3.5/ext/standard/var_unserializer.re'
  - 'https://github.com/php/php-src/blob/php-7.3.5/ext/standard/var.c#L822'
seq:
  - id: type
    type: u1
    enum: value_type
    doc: A single-character code indicating the type of the serialized value.
  - id: contents
    type:
      switch-on: type
      cases:
        'value_type::null': null_contents
        'value_type::bool': bool_contents
        'value_type::int': int_contents
        'value_type::float': float_contents
        'value_type::string': string_contents
        'value_type::php_6_string': string_contents
        'value_type::array': array_contents
        'value_type::php_3_object': php_3_object_contents
        'value_type::object': object_contents
        'value_type::custom_serialized_object':
          custom_serialized_object_contents
        'value_type::variable_reference': int_contents
        'value_type::object_reference': int_contents
    doc: |
      The contents of the serialized value, which vary depending on the type.
enums:
  value_type:
    0x43: # 'C'
      id: custom_serialized_object
      doc: |
        An `object` whose class implements a custom serialized format using
        `Serializable`. Available since PHP 5.1.
    0x4e: # 'N'
      id: 'null'
      doc: A `NULL` value.
    0x4f: # 'O'
      id: object
      doc: |
        An `object` value (including its class name) serialized in the
        default format. Available since PHP 4.
    0x52: # 'R'
      id: variable_reference
      doc: |
        An additional reference to a value that has already appeared earlier.
        Available since PHP 4.0.4.
    0x53: # 'S'
      id: php_6_string
      doc: |
        A `string` value from PHP 6. PHP 6 was never released, but support for
        deserializing PHP 6 strings was added in PHP 5.2.1 and is still present
        as of PHP 7.3. In all versions that support them (other than PHP 6),
        they are deserialized exactly like regular strings.
    0x61: # 'a'
      id: array
      doc: An `array` value.
    0x62: # 'b'
      id: bool
      doc: A `bool` value. Available since PHP 4.
    0x64: # 'd'
      id: float
      doc: A `float` value.
    0x69: # 'i'
      id: int
      doc: An `int` value.
    0x6f: # 'o'
      id: php_3_object
      doc: |
        An `object` value (without a class name), as serialized by PHP 3.

        PHP 4 through 7.3 included code to deserialize PHP 3 objects,
        which has now been removed from the development repo and will likely
        no longer be included in PHP 7.4. However, apparently this code
        has been broken ever since it was added - it cannot even deserialize
        a simple PHP 3 object like `o:0:{}`. If the code worked, PHP 3 objects
        deserialized under PHP 4 and higher would have the class `stdClass`.
    0x72: # 'r'
      id: object_reference
      doc: |
        An `object` value which shares its identity with another `object`
        that has already appeared earlier. Available since PHP 5.
    0x73: # 's'
      id: string
      doc: A `string` value.
  bool_value:
    0x30: false # '0'
    0x31: true # '1'
types:
  null_contents:
    doc: |
      The contents of a null value (`value_type::null`). This structure
      contains no actual data, since there is only a single `NULL` value.
    seq:
      - id: semicolon
        contents: ';'
  bool_contents:
    doc: The contents of a boolean value (`value_type::bool`).
    seq:
      - id: colon
        contents: ':'
      - id: value_dec
        type: u1
        enum: bool_value
        doc: |
          The value of the `bool`: `0` for `false` or `1` for `true`.
      - id: semicolon
        contents: ';'
    instances:
      value:
        value: 'value_dec == bool_value::true'
        doc: The value of the `bool`, parsed as a boolean.
  int_contents:
    doc: |
      The contents of an integer-like value:
      either an actual integer (`value_type::int`) or a reference
      (`value_type::variable_reference`, `value_type::object_reference`).
    seq:
      - id: colon
        contents: ':'
      - id: value_dec
        type: str
        terminator: 0x3b # ';'
        doc: The value of the `int`, in ASCII decimal.
    instances:
      value:
        value: value_dec.to_i
        doc: The value of the `int`, parsed as an integer.
  float_contents:
    doc: The contents of a floating-point value.
    seq:
      - id: colon
        contents: ':'
      - id: value_dec
        type: str
        terminator: 0x3b # ';'
        doc: |
          The value of the `float`, in ASCII decimal, as generated by PHP's
          usual double-to-string conversion. In particular, this means that:

          * A decimal point may not be included (for integral numbers)
          * The number may use exponent notation (e. g. `1.0E+16`)
          * Positive and negative infinity are represented as `INF`
            and `-INF`, respectively
          * Not-a-number is represented as `NAN`
  length_prefixed_quoted_string:
    doc: |
      A quoted string prefixed with its length.

      Despite the quotes surrounding the string data, it can contain
      arbitrary bytes, which are never escaped in any way.
      This does not cause any ambiguities when parsing - the bounds of
      the string are determined only by the length field, not by the quotes.
    seq:
      - id: len_data_dec
        type: str
        terminator: 0x3a # ':'
        doc: |
          The length of the string's data in bytes, in ASCII decimal.
          The quotes are not counted in this length number.
      - id: opening_quote
        contents: '"'
      - id: data
        size: len_data
        doc: The data contained in the string. The quotes are not included.
      - id: closing_quote
        contents: '"'
    instances:
      len_data:
        value: len_data_dec.to_i
        doc: |
          The length of the string's contents in bytes, parsed as an integer.
          The quotes are not counted in this size number.
  string_contents:
    doc: |
      The contents of a string value.

      Note: PHP strings can contain arbitrary byte sequences.
      They are not necessarily valid text in any specific encoding.
    seq:
      - id: colon
        contents: ':'
      - id: string
        type: length_prefixed_quoted_string
      - id: semicolon
        contents: ';'
    instances:
      value:
        value: string.data
        doc: The value of the string, as a byte array.
  mapping_entry:
    doc: A mapping entry consisting of a key and a value.
    seq:
      - id: key
        type: php_serialized_value
        doc: The key of the entry.
      - id: value
        type: php_serialized_value
        doc: The value of the entry.
  count_prefixed_mapping:
    doc: A mapping (a sequence of key-value pairs) prefixed with its size.
    seq:
      - id: num_entries_dec
        type: str
        terminator: 0x3a # ':'
        doc: The number of key-value pairs in the mapping, in ASCII decimal.
      - id: opening_brace
        contents: '{'
      - id: entries
        type: mapping_entry
        repeat: expr
        repeat-expr: num_entries
        doc: The key-value pairs contained in the mapping.
      - id: closing_brace
        contents: '}'
    instances:
      num_entries:
        value: num_entries_dec.to_i
        doc: |
          The number of key-value pairs in the mapping, parsed as an integer.
  array_contents:
    doc: The contents of an array value.
    seq:
      - id: colon
        contents: ':'
      - id: elements
        type: count_prefixed_mapping
        doc: |
          The array's elements. Keys must be of type `int` or `string`,
          values may have any type.
  php_3_object_contents:
    doc: |
      The contents of a PHP 3 object value. Unlike its counterpart in PHP 4
      and above, it does not contain a class name.
    seq:
      - id: colon
        contents: ':'
      - id: properties
        type: count_prefixed_mapping
        doc: |
          The object's properties. Keys must be of type `string`,
          values may have any type.
  object_contents:
    doc: |
      The contents of an object value serialized in the default format.
      Unlike its PHP 3 counterpart, it contains a class name.
    seq:
      - id: colon1
        contents: ':'
      - id: class_name
        type: length_prefixed_quoted_string
        doc: The name of the object's class.
      - id: colon2
        contents: ':'
      - id: properties
        type: count_prefixed_mapping
        doc: |
          The object's properties. Keys ust be of type `string`,
          values may have any type.
  custom_serialized_object_contents:
    doc: |
      The contents of an object value that implements a custom
      serialized format using `Serializable`.
    seq:
      - id: colon1
        contents: ':'
      - id: class_name
        type: length_prefixed_quoted_string
        doc: The name of the object's class.
      - id: colon2
        contents: ':'
      - id: len_data_dec
        type: str
        terminator: 0x3a # ':'
        doc: |
          The length of the serialized data in bytes, in ASCII decimal.
          The braces are not counted in this size number.
      - id: opening_brace
        contents: '{'
      - id: data
        size: len_data
        doc: |
          The custom serialized data. The braces are not included.

          Although the surrounding braces make it look like a regular
          serialized object, this field is actually more similar to a string:
          it can contain arbitrary data that is not required to follow
          any common structure.
      - id: closing_quote
        contents: '}'
    instances:
      len_data:
        value: len_data_dec.to_i
        doc: |
          The length of the serialized data in bytes, parsed as an integer.
          The braces are not counted in this length number.
