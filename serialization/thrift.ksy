meta:
  id: thrift_compact
  endian: le
  title: Thrift Compact Protocol
  license: MIT
  ks-version: '0.10'

doc: |
  Thrift Compact Protocol parser.
  
  This format uses variable-length encoding and recursive structures that
  terminate with a STOP field (byte 0x00). Fields are read using `repeat: until`
  with a condition that checks if the last read field is a STOP field.
  
  The struct parsing reads fields until a STOP field (field_header == 0x00) is
  encountered, allowing proper handling of conditionally terminated recursive
  structures.

doc-ref: https://github.com/apache/thrift/blob/master/doc/specs/thrift-compact-protocol.md

seq:
  - id: message
    type: compact_message

types:
  compact_message:
    seq:
      - id: protocol_id
        type: u1
        doc: Protocol ID (must be 0x82 for compact protocol)
        valid:
          eq: 0x82
      - id: version_and_type
        type: u1
        doc: Version (4 bits) and message type (4 bits)
      - id: seq_id
        type: varint_z
        doc: Sequence ID (zigzag-encoded)
      - id: name
        type: compact_string
        doc: Method name
      - id: fields
        type: compact_struct
        doc: Message fields (struct)
    instances:
      version:
        value: (version_and_type >> 4) & 0xF
        doc: Protocol version
      msg_type:
        value: version_and_type & 0xF
        doc: Message type (1=call, 2=reply, 3=exception, 4=oneway)

  compact_struct:
    seq:
      - id: fields
        type: compact_field
        repeat: until
        repeat-until: _.is_stop
        doc: |
          Fields of the struct. Uses `repeat: until` to read fields until
          a STOP field is encountered.
          
          The condition `_.is_stop` checks if the last read field
          is a STOP field (field_header == 0x00). When a STOP field is detected,
          the loop terminates.
          
          Each field is fully read before checking if it's a STOP field, which
          means the STOP field itself is included in the fields array.

  compact_field:
    seq:
      - id: field_header
        type: u1
        doc: |
          Field header byte. If this is 0x00, it's a STOP field.
          Otherwise:
          - Bits 0-3: field type (0-15)
          - Bits 4-7: field delta (0-15, or 0 if delta follows as varint)
      - id: extended_delta
        type: varint_z
        if: "not is_stop and has_extended_delta"
        doc: Full field id (i16, zigzag varint) when header delta is 0
      - id: value
        type: compact_value(field_type)
        if: "not is_stop"
        doc: Field value (type depends on field_type)
    instances:
      is_stop:
        value: field_header == 0
        doc: True if this is a STOP field
      field_type:
        value: field_header & 0xF
        doc: Field type (bits 0-3)
      field_delta_short:
        value: (field_header >> 4) & 0xF
        doc: Field delta from header (bits 4-7)
      has_extended_delta:
        value: field_delta_short == 0
        doc: True if full field id follows as varint (instead of delta)
      field_delta:
        value: "has_extended_delta ? extended_delta.value : field_delta_short"
        doc: Field id delta (if delta_short != 0) or absolute field id (if delta_short == 0)

  compact_value:
    params:
      - id: value_type
        type: u1
    seq:
      - id: byte_value
        type: s1
        if: value_type == 3
      - id: i16_value
        type: varint_z
        if: value_type == 4
      - id: i32_value
        type: varint_z
        if: value_type == 5
      - id: i64_value
        type: varint_z
        if: value_type == 6
      - id: double_value
        type: f8le
        if: value_type == 7
      - id: binary_value
        type: compact_string
        if: value_type == 8
      - id: list_value
        type: compact_list
        if: value_type == 9
      - id: set_value
        type: compact_list
        if: value_type == 10
      - id: map_value
        type: compact_map
        if: value_type == 11
      - id: struct_value
        type: compact_struct
        if: value_type == 12
    doc: Value of the field, type depends on value_type parameter

  compact_list:
    seq:
      - id: list_header
        type: u1
        doc: |
          List header: size (upper 4 bits) and element type (lower 4 bits)
          If size == 15, actual size follows as varint
      - id: extended_size
        type: varint_u
        if: has_extended_size
        doc: Actual list size (if header size was 15)
      - id: elements
        type: compact_value(element_type)
        repeat: expr
        repeat-expr: list_size
        doc: List elements
    instances:
      list_size_short:
        value: (list_header >> 4) & 0xF
        doc: List size from header (0-14, or 15 if extended)
      element_type:
        value: list_header & 0xF
        doc: Element type (0-15)
      has_extended_size:
        value: list_size_short == 15
        doc: True if extended size follows as varint
      list_size:
        value: "has_extended_size ? extended_size.value_u : list_size_short"
        doc: Final list size

  compact_map:
    seq:
      - id: size
        type: varint_u
        doc: |
          Map size (unsigned varint).
          In Thrift Compact Protocol the map header is:
          - if size == 0: just the size varint (0x00), and nothing else
          - else: size varint, then one byte: (key_type << 4) | value_type
      - id: type_byte
        type: u1
        if: map_size != 0
        doc: Key/value types packed into nibbles high=key, low=value
      - id: entries
        type: map_entry(key_type, value_type)
        repeat: expr
        repeat-expr: map_size
        doc: Map entries
    instances:
      map_size:
        value: size.value_u
        doc: Map size
      key_type:
        value: "map_size == 0 ? 0 : ((type_byte >> 4) & 0xF)"
        doc: Key type (0-15)
      value_type:
        value: "map_size == 0 ? 0 : (type_byte & 0xF)"
        doc: Value type (0-15)

  map_entry:
    params:
      - id: key_type
        type: u1
      - id: val_type
        type: u1
    seq:
      - id: key
        type: compact_value(key_type)
        doc: Map key
      - id: value
        type: compact_value(val_type)
        doc: Map value

  compact_string:
    seq:
      - id: len
        type: varint_u
        doc: String length (unsigned varint)
      - id: value
        type: str
        encoding: UTF-8
        size: length
        doc: String value
    instances:
      length:
        value: len.value_u
        doc: Decoded string length

  varint_u:
    seq:
      - id: bytes
        type: u1
        repeat: until
        repeat-until: (_ & 0x80) == 0
        doc: |
          Unsigned variable-length integer encoding (base-128 LE).
          Each byte: bit 7 = continuation flag, bits 0-6 = data.
    instances:
      value_u:
        value: "(bytes[0] & 0x7f)\n          + (bytes.size > 1 ? ((bytes[1] & 0x7f) << 7) : 0)\n          + (bytes.size > 2 ? ((bytes[2] & 0x7f) << 14) : 0)\n          + (bytes.size > 3 ? ((bytes[3] & 0x7f) << 21) : 0)\n          + (bytes.size > 4 ? ((bytes[4] & 0x7f) << 28) : 0)\n          + (bytes.size > 5 ? ((bytes[5] & 0x7f) << 35) : 0)\n          + (bytes.size > 6 ? ((bytes[6] & 0x7f) << 42) : 0)\n          + (bytes.size > 7 ? ((bytes[7] & 0x7f) << 49) : 0)\n          + (bytes.size > 8 ? ((bytes[8] & 0x7f) << 56) : 0)\n          + (bytes.size > 9 ? ((bytes[9] & 0x7f) << 63) : 0)"
        doc: Decoded unsigned integer value

  varint_z:
    seq:
      - id: bytes
        type: u1
        repeat: until
        repeat-until: (_ & 0x80) == 0
        doc: |
          Zigzag-encoded variable-length integer (base-128 LE).
    instances:
      value_u:
        value: "(bytes[0] & 0x7f)\n          + (bytes.size > 1 ? ((bytes[1] & 0x7f) << 7) : 0)\n          + (bytes.size > 2 ? ((bytes[2] & 0x7f) << 14) : 0)\n          + (bytes.size > 3 ? ((bytes[3] & 0x7f) << 21) : 0)\n          + (bytes.size > 4 ? ((bytes[4] & 0x7f) << 28) : 0)\n          + (bytes.size > 5 ? ((bytes[5] & 0x7f) << 35) : 0)\n          + (bytes.size > 6 ? ((bytes[6] & 0x7f) << 42) : 0)\n          + (bytes.size > 7 ? ((bytes[7] & 0x7f) << 49) : 0)\n          + (bytes.size > 8 ? ((bytes[8] & 0x7f) << 56) : 0)\n          + (bytes.size > 9 ? ((bytes[9] & 0x7f) << 63) : 0)"
        doc: Decoded unsigned integer value (before zigzag)
      value:
        value: "(value_u >> 1) ^ (-(value_u & 1))"
        doc: Decoded zigzag-signed integer value

enums:
  message_type:
    1: call
    2: reply
    3: exception
    4: oneway

  field_type:
    0: stop
    1: true
    2: false
    3: byte
    4: i16
    5: i32
    6: i64
    7: double
    8: binary
    9: list
    10: set
    11: map
    12: struct
