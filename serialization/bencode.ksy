meta:
  id: bencode
  title: BEncode
  file-extension: torrent
  xref:
    justsolve: Bencode
    mime: application/x-bittorrent  # for most of them
    wikidata: Q871923
  endian: le
  encoding: ascii
  license: Unlicense
doc: |
  Binary serialization for a kind of subset of JSON, but that can be human-readable and editable in text editors indicating byte positions.
  Used in BitTorrent protocol.

  Sample: d6:kaitail2:isi146e9:% awesomeee

doc-ref: https://www.bittorrent.org/beps/bep_0003.html#bencoding
-webide-representation: '{value}'
seq:
  - id: type_byte
    type: u1
  - id: value
    type:
      switch-on: is_buffer
      cases:
        false: non_buffer(type_byte)
        true: buffer(type_byte)
instances:
  is_buffer:
    value: (48 <= type_byte) and (type_byte <= 58)
types:
  non_buffer:
    -webide-representation: '<{type}>: {value}'
    params:
      - id: type_byte
        type: u1
    seq:
      - id: value
        type:
          switch-on: type
          cases:
            type::dict: bdict
            type::int: bint
            type::list: blist

    instances:
      type:
        value: type_byte
        enum: type
    types:
      bint:
        -webide-representation: '{value}'
        seq:
          - id: int_str
            type: strz
            encoding: ascii
            terminator: 101  # type::end.to_i
        instances:
          value:
            value: int_str.to_i
      blist:
        seq:
          - id: values
            type: bencode
            repeat: until
            repeat-until: _.type_byte == type::end.to_i
      bdict:
        seq:
          - id: items
            type: kwpair
            repeat: until
            repeat-until: _.key.type_byte == type::end.to_i
            doc: Keys must appear in sorted order.
        types:
          kwpair:
            -webide-representation: '{key}: {value}'
            seq:
              - id: key
                type: bencode
                valid:
                  expr: key.is_buffer or is_end
              - id: value
                type: bencode
                if: not is_end
            instances:
              is_end:
                value: key.type_byte == type::end.to_i

  buffer:
    -webide-representation: '{value}'
    params:
      - id: first_digit_byte
        type: u1
    seq:
      - id: rest_size_str
        type: str
        terminator: 58  # ":"
      - id: value
        -affected-by:
          - 216
          - 88
        size: "(((rest_size_str.length & 1 != 0 ? 5 : 1)) * ((rest_size_str.length & 2 != 0 ? 25 : 1)) * ((rest_size_str.length & 4 != 0 ? 625 : 1)) * ((rest_size_str.length & 8 != 0 ? 390625 : 1)) * ((rest_size_str.length & 16 != 0 ? 152587890625 : 1)) * ((rest_size_str.length & 32 != 0 ? 0x4ee2d6d415b85acef81 : 1)) * ((rest_size_str.length & 64 != 0 ? 0x184f03e93ff9f4daa797ed6e38ed64bf6a1f01 : 1)) * ((rest_size_str.length & 128 != 0 ? 0x24ee91f2603a6337f19bccdb0dac404dc08d3cff5ec2374e42f0f1538fd03df99092e953e01 : 1)) << rest_size_str.length) * (first_digit_byte - 48) + (rest_size_str.length > 0 ? rest_size_str.to_i : 0)"  # first_digit * ( 10 ** rest_size_str.length ) + rest_size_str.to_i

enums:
  type:
    108: list  # l
    100: dict  # d
    105: int   # i
    101: end   # e
