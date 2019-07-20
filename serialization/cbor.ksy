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
        'type::uint': uint
        'type::neg_uint': uint
        'type::byte_str': byte_str
        'type::text_str': text_str
        'type::array': array
        'type::map': map
        'type::tag': tag
        'type::simple_or_float': simple_or_float
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
         value: "additional_info >= 24 and additional_info <= 27"
      integer_length:
        value: additional_info - 24
        if: is_integer_length
      is_reserved:
        value: "additional_info >= 28 and additional_info <= 30"
      is_indefinite_length:
        value: additional_info == 31
  uint:
    seq:
      - id: value_with_length
        type:
          switch-on: _parent.as<cbor>.ib.integer_length
          cases:
            0: u1
            1: u2
            2: u4
            3: u8
        if: _parent.as<cbor>.ib.is_integer_length
    instances:
      is_negative:
        value: "_parent.as<cbor>.ib.major_type == type::neg_uint"
      raw_value:
        value: "(_parent.as<cbor>.ib.is_raw_value?_parent.as<cbor>.ib.value:value_with_length)"
      modulus:
        value: "(is_negative?1+raw_value:raw_value)"
      value:
        value: "(is_negative?-modulus:modulus)"
  byte_str:
    seq:
      - id: length
        type: uint
      - id: value
        size: length.value
    instances:
      ib:
        value: _parent.ib
  text_str:
    seq:
      - id: length
        type: uint
      - id: value
        type: str
        encoding: utf-8
        size: length.value
        doc: "No escaping is used."
    instances:
      ib:
        value: _parent.ib
  array:
    seq:
      - id: length
        type: uint
      - id: items
        type: cbor
        repeat: expr
        repeat-expr: length.value
    instances:
      ib:
        value: _parent.ib
  map:
    seq:
      - id: length
        type: uint
      - id: items
        type: pair
        repeat: expr
        repeat-expr: length.value
    instances:
      ib:
        value: _parent.ib
    types:
      pair:
        seq:
          - id: key
            type: cbor
          - id: value
            type: cbor
  simple_or_float:
    seq:
      - id: value
        type:
          switch-on: type
          cases:
            "type::simple": simple_or_float
            #"type::f2": f2
            "type::f4": f4
            "type::f8": f8
    instances:
      type:
        value: _parent.as<cbor>.ib.additional_info
        enum: type
    enums:
      type:
        20: "false"
        21: "true"
        22: "null"
        23: "undefined"
        24: simple
        25: f2
        26: f4
        27: f8
        31: chain_break
  tag:
    doc: "Marks the underlying CBOR structure to be transformed by decoder into the corresponding object. Should not cause security issues by itself since non-private tags are standardized and there is no dangerous tags there."
    seq:
      - id: tag_value
        type: uint
      - id: tagged
        type: cbor
    instances:
      ib:
        value: _parent.ib
      tag:
        value: tag_value.value
        enum: tag
      value:
        pos: 0
        type:
          switch-on: tag
          cases:
            "tag::big_float": big_float
            "tag::decimal": decimal
    types:
      big_float_common:
        params:
          - id: arr
            type: array
        instances:
          exponent_valid:
            value: "arr.length.value >= 1 and (arr.items[0].ib.major_type == type::uint or arr.items[0].ib.major_type == type::neg_uint)"
          mantissa_valid:
            value: "arr.length.value >= 2 and (arr.items[1].ib.major_type == type::uint or arr.items[1].ib.major_type == type::neg_uint)"
            # bigint mantissa is not yet supported
          exponent:
            value: "arr.items[0].payload.as<uint>.value"
            if: exponent_valid
          mantissa:
            value: "arr.items[1].payload.as<uint>.value"
            if: mantissa_valid
          valid:
            value: exponent_valid and mantissa_valid
      # Kaitai has neither inheritance no duck typing, so have to repeat code
      big_float:
        instances:
          array_valid:
            value: _parent.as<tag>.tagged.ib.major_type == type::array
          arr:
            value: _parent.as<tag>.tagged.payload.as<array>
            if: array_valid
          array_length_valid:
            value: "array_valid and arr.length.value == 2"
          bfc:
            pos: 0
            type: big_float_common(arr)
            if: array_valid and array_length_valid
          scale:
            pos: 0
            type: pow2(bfc.exponent)
            # a dirty and limited workaround for Kaitai not having a power operation. The limitation is: exponent is only allowed to be 64 bits
          float_approximation:
            value: "bfc.mantissa*scale.value"
            if: bfc.valid
        types:
          pow2:
            params:
              - id: log
                type: u8
            instances:
              is_positive:
                value: log>=0
              mod:
                value: (is_positive?log:-log)
              positive_pow:
                value: "1<<mod"
              value:
                value: (is_positive?positive_pow:1./positive_pow)
      decimal:
        instances:
          array_valid:
            value: _parent.as<tag>.tagged.ib.major_type == type::array
          arr:
            value: _parent.as<tag>.tagged.payload.as<array>
            if: array_valid
          array_length_valid:
            value: "array_valid and arr.length.value == 2"
          bfc:
            pos: 0
            type: big_float_common(arr)
            if: array_valid and array_length_valid
          scale:
            pos: 0
            type: pow10(bfc.exponent)
            # a dirty and broken workaround for Kaitai not having a power operation. Has limitations: exponent is only allowed to be 8 bit
          float_approximation:
            value: "bfc.mantissa*scale.value"
            if: bfc.valid
        types:
          pow10:
            params:
              - id: log
                type: u1
            instances:
              is_positive:
                value: log>=0
              mod:
                value: (is_positive?log:-log)
              positive_pow:
                value: "(((log & 1 != 0 ? 5 : 1)) * ((log & 2 != 0 ? 25 : 1)) * ((log & 4 != 0 ? 625 : 1)) * ((log & 8 != 0 ? 390625 : 1)) * ((log & 16 != 0 ? 152587890625 : 1)) * ((log & 32 != 0 ? 0x4ee2d6d415b85acef81 : 1)) * ((log & 64 != 0 ? 0x184f03e93ff9f4daa797ed6e38ed64bf6a1f01 : 1)) * ((log & 128 != 0 ? 0x24ee91f2603a6337f19bccdb0dac404dc08d3cff5ec2374e42f0f1538fd03df99092e953e01 : 1))) << mod"
              value:
                value: (is_positive?positive_pow:1./positive_pow)
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
          doc: "no trailing ="
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
          id: cose_sign # COSE Signed Data Object
        18:
          id: cose_sign1 # COSE Single Signer Data
        96:
          id: cose_encrypt # COSE Encrypted DataObject
        16:
          id: cose_encrypt0 # COSE Single Recipient Encrypted Data Object
        97: 
          id: cose_mac # COSE MACed Data Object
        17:
          id: cose_mac0 # COSE Mac w/o Recipients Object
        61:
          id: cwt # CBOR Web Token
        55799:
          id: self_describe

enums:
  type:
    0: uint
    1: neg_uint
    2: byte_str
    3: text_str
    4: array
    5: map
    6: tag
    7: simple_or_float
