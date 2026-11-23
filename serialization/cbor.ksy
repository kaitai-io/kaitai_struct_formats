meta:
  id: cbor
  title: Concise Binary Object Representation
  endian: be
  license: Unlicense
  xref:
    mime: application/cbor
    rfc:
      - 7049
      - 8152
      - 8610
      - 8392
    wikidata: Q28455556
doc: |
  A binary format capable of serialization of superset of JSON.
seq:
  - id: ib
    type: ib
  - id: payload
    type:
      switch-on: ib.major_type
      cases:
        type::pos_uint: cuint(ib)
        type::neg_uint: cuint(ib)
        type::byte_str: byte_str(ib)
        type::text_str: text_str(ib)
        type::cbor_array: cbor_array(ib)
        type::cbor_map: cmap(ib)
        type::tag: tag(ib)
        type::simple_or_float: simple_or_float(ib)
types:
  ib:
    seq:
      - id: major_type
        type: b3
        enum: type
      - id: additional_info
        type: b5
    instances:
      is_raw_value:
        value: additional_info < 24
      value:
        value: additional_info
        if: is_raw_value
      is_extension:
        value: additional_info == 24
      is_integer_length:
        value: 24 <= additional_info and additional_info <= 27
      integer_length:
        value: additional_info - 24
        if: is_integer_length
      is_reserved:
        value: 28 <= additional_info and additional_info <= 30
      is_indefinite_length:
        value: additional_info == 31
  cuint:
    params:
      - id: ib
        type: ib
    seq:
      - id: value_with_length
        type:
          switch-on: ib.integer_length
          cases:
            0: u1
            1: u2
            2: u4
            3: u8
        if: ib.is_integer_length
    instances:
      is_negative:
        value: ib.major_type == type::neg_uint
      raw_value:
        value: "ib.is_raw_value ? ib.value : value_with_length"
      modulus:
        value: "is_negative ? 1 + raw_value : raw_value"
      value:
        value: "is_negative ? -modulus : modulus"
  byte_str:
    params:
      - id: ib
        type: ib
    seq:
      - id: length_obj
        type: cuint(ib)
      - id: value
        size: length
    instances:
      length:
        value: length_obj.value
  text_str:
    params:
      - id: ib
        type: ib
    seq:
      - id: length_obj
        type: cuint(ib)
      - id: value
        type: str
        encoding: utf-8
        size: length
        doc: No escaping is used.
    instances:
      length:
        value: length_obj.value
  cbor_array:
    params:
      - id: ib
        type: ib
    seq:
      - id: length
        type: cuint(ib)
      - id: items
        type: cbor
        repeat: expr
        repeat-expr: length.value
  cmap:
    params:
      - id: ib
        type: ib
    seq:
      - id: length
        type: cuint(ib)
      - id: items
        type: pair
        repeat: expr
        repeat-expr: length.value
    types:
      pair:
        seq:
          - id: key
            type: cbor
          - id: value
            type: cbor
  simple_or_float:
    params:
      - id: ib
        type: ib
    seq:
      - id: value
        type:
          switch-on: type
          cases:
            type::simple: simple_or_float(ib)
            #"type::f2": f2
            type::f4: f4
            type::f8: f8
    instances:
      type:
        value: ib.additional_info
        enum: type
    enums:
      type:
        20: "false"
        21: "true"
        22: "null"
        23: undefined
        24: simple
        25: f2
        26: f4
        27: f8
        31: chain_break
  tag:
    doc: Marks the underlying CBOR structure to be transformed by decoder into the corresponding object. Should not cause security issues by itself since non-private tags are standardized and there is no dangerous tags there.
    params:
      - id: ib
        type: ib
    seq:
      - id: tag_value
        type: cuint(ib)
      - id: tagged
        type: cbor
    instances:
      tag:
        value: tag_value.value
        enum: tag
      value:
        pos: 0
        type:
          switch-on: tag
          cases:
            tag::big_float: big_float(tagged)
            tag::decimal: decimal(tagged)
            tag::positive_big_num: positive_big_num(tagged)
            tag::negative_big_num: negative_big_num(tagged)
    types:
      big_float_common:
        params:
          - id: tagged
            type: cbor
        instances:
          array_valid:
            value: tagged.ib.major_type == type::cbor_array
          arr:
            value: tagged.payload.as<cbor_array>
            if: array_valid
          array_length_valid:
            value: array_valid and arr.length.value == 2
          exponent_valid:
            value: array_length_valid and (arr.items[0].ib.major_type == type::pos_uint or arr.items[0].ib.major_type == type::neg_uint)
          mantissa_obj:
            value: arr.items[1]
            if: array_length_valid
          mantissa_is_integer:
            value: mantissa_obj.ib.major_type == type::pos_uint or mantissa_obj.ib.major_type == type::neg_uint
            if: array_length_valid
          mantissa_is_tag:
            value: mantissa_obj.ib.major_type == type::tag
          mantissa_tag:
            value: mantissa_obj.payload.as<tag>
            if: mantissa_is_tag
          mantissa_is_big_integer:
            value: mantissa_is_tag and (mantissa_tag.tag == tag::negative_big_num or mantissa_tag.tag == tag::positive_big_num)
            if: array_length_valid
          exponent:
            value: arr.items[0].payload.as<cuint>.value
            if: exponent_valid
          mantissa_int:
            value: arr.items[1].payload.as<cuint>.value
            if: mantissa_valid and mantissa_is_integer
          mantissa_bigint_obj:
            value: mantissa_tag.value.as<positive_big_num>   # or negative_big_num
            if: array_length_valid and mantissa_is_big_integer
          mantissa_bigint_valid:
            value: mantissa_is_big_integer and mantissa_bigint_obj.valid
          mantissa_bigint:
            value: mantissa_bigint_obj.value
            if: mantissa_bigint_valid
          mantissa_valid:
            value: mantissa_is_integer or mantissa_bigint_valid
          mantissa:
            value: 'mantissa_is_integer ? mantissa_int : (mantissa_bigint_valid ? mantissa_bigint : 0)'
            if: mantissa_valid
          valid:
            value: exponent_valid and mantissa_valid
      # Kaitai has neither inheritance no duck typing, so have to repeat code
      big_float:
        params:
          - id: tagged
            type: cbor
        instances:
          bfc:
            pos: 0
            type: big_float_common(tagged)
          scale:
            pos: 0
            type: pow2(bfc.exponent)
            if: bfc.valid
            # a dirty and limited workaround for Kaitai not having a power operation. The limitation is: exponent is only allowed to be 64 bits
          float_approximation:
            value: bfc.mantissa*scale.value
            if: bfc.valid
        types:
          pow2:
            -affected-by: 216
            params:
              - id: log
                type: s8
            instances:
              is_positive:
                value: log >= 0
              mod:
                value: "is_positive ? log : -log"
              positive_pow:
                value: 1 << mod
              value:
                value: "is_positive ? positive_pow : 1./positive_pow"
      decimal:
        params:
          - id: tagged
            type: cbor
        instances:
          bfc:
            pos: 0
            type: big_float_common(tagged)
          scale:
            pos: 0
            type: pow10(bfc.exponent)
            if: bfc.valid
            # a dirty and broken workaround for Kaitai not having a power operation. Has limitations: exponent is only allowed to be 8 bit because the result is already too big
          float_approximation:
            value: bfc.mantissa * scale.value
            if: bfc.valid
        types:
          pow10:
            -affected-by: 216
            params:
              - id: log
                type: s1
            instances:
              is_positive:
                value: log >= 0
              mod:
                value: "is_positive ? log : -log"
              positive_pow:
                value: |
                  (mod & 1 != 0 ? 5 : 1)
                  * (mod & 2 != 0 ? 25 : 1)
                  * (mod & 4 != 0 ? 625 : 1)
                  * (mod & 8 != 0 ? 390625 : 1)
                  * (mod & 16 != 0 ? 152587890625 : 1)
                  * (mod & 32 != 0 ? 0x4ee2d6d415b85acef81 : 1)
                  * (mod & 64 != 0 ? 0x184f03e93ff9f4daa797ed6e38ed64bf6a1f01 : 1)
                  * (mod & 128 != 0 ? 0x24ee91f2603a6337f19bccdb0dac404dc08d3cff5ec2374e42f0f1538fd03df99092e953e01 : 1)
                  << mod
                doc-ref: https://github.com/kaitai-io/kaitai_struct/issues/216#issuecomment-513705803
              value:
                value: "is_positive ? positive_pow : 1./positive_pow"
      positive_big_num:
        params:
          - id: tagged
            type: cbor
        instances:
          valid:
            value: tagged.ib.major_type == type::byte_str
          tagged_arr_obj:
            value: tagged.payload.as<byte_str>
            if: valid
          reduction:
            pos: 0
            type: iteration(_index)
            repeat: expr
            repeat-expr: tagged_arr_obj.length
            if: valid
          value:
            value: reduction[tagged_arr_obj.length - 1].res
            if: valid
        types:
          iteration:
            params:
              - id: idx
                type: u1
            instances:
              prev:
                value: "idx == 0 ? 0. : (_parent.reduction[idx - 1].as<iteration>.res).as<f8>"
              res:
                value: prev * 256. + _parent.tagged_arr_obj.value[idx]
      negative_big_num:
        params:
          - id: tagged
            type: cbor
        instances:
          positive:
            pos: 0
            type: positive_big_num(tagged)
          value:
            value: -1. - positive.value
          valid:
            value: positive.valid
    enums:
      tag:
        0:
          id: date_time
          doc-ref:
            - https://tools.ietf.org/rfc/rfc3339.txt
            - https://tools.ietf.org/rfc/rfc4287.txt
        1:
          id: epoch_time
        2:
          id: positive_big_num
        3:
          id: negative_big_num
        4:
          id: decimal
          -orig-id: Decimal fraction
        5:
          id: big_float
        21:
          id: base64_url
          doc: no trailing =
        22:
          id: base64
        23:
          id: base16
        24:
          id: encoded_cbor_data_item
          doc: the binary contains CBOR which parsing is meant to be deferred
        32:
          id: uri
          doc-ref: https://tools.ietf.org/rfc/rfc3986.txt
        33:
          id: base64_url_str
          doc-ref: https://tools.ietf.org/rfc/rfc4648.txt
        34:
          id: base64_str
          doc-ref: https://tools.ietf.org/rfc/rfc4648.txt
        35:
          id: reg_exp
          doc-ref: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions#Writing_a_regular_expression_pattern
        36:
          id: mime_message
          doc-ref: https://tools.ietf.org/rfc/rfc2045.txt
        98:
          id: cose_sign
          doc: COSE Signed Data Object
        18:
          id: cose_sign1
          doc: COSE Single Signer Data
        96:
          id: cose_encrypt
          doc: COSE Encrypted DataObject
        16:
          id: cose_encrypt0
          doc: COSE Single Recipient Encrypted Data Object
        97:
          id: cose_mac
          doc: COSE MACed Data Object
        17:
          id: cose_mac0
          doc: COSE Mac w/o Recipients Object
        61:
          id: cwt
          doc: CBOR Web Token
        55799:
          id: self_describe

enums:
  type:
    0: pos_uint
    1: neg_uint
    2: byte_str
    3: text_str
    4: cbor_array
    5: cbor_map
    6: tag
    7: simple_or_float
