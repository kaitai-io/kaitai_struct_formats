meta:
  id: vlq_base128_le
  title: Variable length quantity, unsigned/signed integer, base128, little-endian
  xref:
    justsolve: Variable-length_quantity
    wikidata: Q6457577
  license: CC0-1.0
  ks-version: '0.10'
  bit-endian: be
doc: |
  A variable-length unsigned/signed integer using base128 encoding. 1-byte groups
  consist of 1-bit flag of continuation and 7-bit value chunk, and are ordered
  "least significant group first", i.e. in "little-endian" manner.

  This particular encoding is specified and used in:

  * DWARF debug file format, where it's dubbed "unsigned LEB128" or "ULEB128".
    <https://dwarfstd.org/doc/dwarf-2.0.0.pdf> - page 139
  * Google Protocol Buffers, where it's called "Base 128 Varints".
    <https://protobuf.dev/programming-guides/encoding/#varints>
  * Apache Lucene, where it's called "VInt"
    <https://lucene.apache.org/core/3_5_0/fileformats.html#VInt>
  * Apache Avro uses this as a basis for integer encoding, adding ZigZag on
    top of it for signed ints
    <https://avro.apache.org/docs/1.12.0/specification/#primitive-types-1>

  More information on this encoding is available at <https://en.wikipedia.org/wiki/LEB128>

  This particular implementation supports integer values up to 64 bits (i.e. the
  maximum unsigned value supported is `2**64 - 1`), which implies that serialized
  values can be up to 10 bytes in length.

  If the most significant 10th byte (`groups[9]`) is present, its `has_next`
  must be `false` (otherwise we would have 11 or more bytes, which is not
  supported) and its `value` can be only `0` or `1` (because a 9-byte VLQ can
  represent `9 * 7 = 63` bits already, so the 10th byte can only add 1 bit,
  since only integers up to 64 bits are supported). These restrictions are
  enforced by this implementation. They were inspired by the Protoscope tool,
  see <https://github.com/protocolbuffers/protoscope/blob/8e7a6aafa2c9958527b1e0747e66e1bfff045819/writer.go#L644-L648>.
-webide-representation: '{value:dec}'
seq:
  - id: groups
    # NOTE: with KSC 0.11, handling `_index == 9` as a special case is needed
    # for PHP, otherwise `TypeError: Argument #3 ($multiplier) must be of type
    # int, float given` would occur.
    type: |
      group(
        _index,
        _index != 0 ? groups[_index - 1].interm_value : 0,
        _index != 0 ? (_index == 9 ? 0x8000_0000_0000_0000 : groups[_index - 1].multiplier * 128) : 1
      )
    repeat: until
    repeat-until: not _.has_next
types:
  group:
    -webide-representation: '{value}'
    doc: |
      One byte group, clearly divided into 7-bit "value" chunk and 1-bit "continuation" flag.
    params:
      - id: idx
        type: s4
      - id: prev_interm_value
        type: u8
      - id: multiplier
        type: u8
    seq:
      - id: has_next
        type: b1
        valid: 'idx == 9 ? false : has_next'
        doc: |
          If `true`, then we have more bytes to read.

          Since this implementation only supports serialized values up to 10
          bytes, this must be `false` in the 10th group (`groups[9]`).
      - id: value
        type: b7
        valid:
          # # As of KSC 0.11, this causes `if (!(_value <= (Idx == 9 ? 1 :
          # # 127))) { throw new ValidationGreaterThanError(...); }` to be
          # # generated in the C# code, which fails to compile with the message
          # # `error CS0034: Operator '<=' is ambiguous on operands of type
          # # 'ulong' and 'int'`. To work around that, we add type casting
          # # (`.as<u8>`).
          # max: 'idx == 9 ? 1 : 0b111_1111'
          max: '(idx == 9 ? 1 : 0b111_1111).as<u8>'
        doc: |
          The 7-bit (base128) numeric value chunk of this group

          Since this implementation only supports integer values up to 64 bits,
          the `value` in the 10th group (`groups[9]`) can only be `0` or `1`
          (otherwise the width of the represented value would be 65 bits or
          more, which is not supported).
    instances:
      interm_value:
        # We intentionally use addition (`+`) and multiplication (`*`), not
        # bitwise OR (`|`) and left shift (`<<`), in order to get better
        # precision in JavaScript, especially with respect to the Web IDE. Using
        # any bitwise operators (like `|` and `<<`) in JavaScript truncates the
        # result to a signed 32-bit integer (except `>>>`, which yields an
        # unsigned 32-bit integer).
        #
        # Avoiding bitwise operators allows greater precision than 32 bits. We
        # are still limited by the fact that the built-in `Number` type in
        # JavaScript can only exactly represent integers from `-2**53 + 1` to
        # `2**53 - 1` (these bounds are available as constants
        # `Number.MIN_SAFE_INTEGER` and `Number.MAX_SAFE_INTEGER`), so for any
        # integer that requires more than 53 bits of precision, we get
        # approximate values. But 53 bits is still better than 32.
        #
        # Full 64-bit integer support in JavaScript is only possible via the
        # `BigInt` type: https://github.com/kaitai-io/kaitai_struct/issues/183
        value: (prev_interm_value + value * multiplier).as<u8>
instances:
  len:
    value: groups.size
  value:
    value: groups.last.interm_value
    doc: Resulting unsigned value as normal integer
  sign_bit:
    value: '(len == 10 ? 0x8000_0000_0000_0000 : groups.last.multiplier * 0b100_0000).as<u8>'
  value_signed:
    # NOTE 1: the expression `-(sign_bit - (value - sign_bit))` performing
    # signed extension is carefully written to avoid overflows in statically
    # typed languages like C++ (where they would cause undefined behavior) or
    # Nim. The goal is to achieve mathematically exactly `value - 2 * sign_bit`.
    #
    # NOTE 2: the `sign_bit > 0` check is a hack for PHP (it is required only
    # because KSC 0.11 does not abstract from the fact that PHP has only
    # **signed** 64-bit integers, which should be considered a bug because it
    # reduces portability between target languages). Since PHP only has signed
    # 64-bit integers, `sign_bit` will be `-0x8000_0000_0000_0000` if
    # `len == 10`, so the `value >= sign_bit` condition that is supposed to
    # detect whether the sign bit is set will not work (in reality, it will be
    # true for any `value`). However, the sign extension would only cause the
    # value to overflow and become a `float`. The fix in this case is to return
    # `value` as is, since it already represents the correct signed value.
    value: 'sign_bit > 0 and value >= sign_bit ? -(sign_bit - (value - sign_bit)).as<s8> : value.as<s8>'
    # # We don't use this anymore again because of JavaScript as explained
    # # above. Since it relies on bitwise XOR (`^`), it would truncate the value
    # # to 32 bits in the Web IDE.
    # value: '((value ^ sign_bit).as<s8> - sign_bit.as<s8>).as<s8>'
    # doc-ref: https://graphics.stanford.edu/~seander/bithacks.html#VariableSignExtend
