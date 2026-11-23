meta:
  id: asn1_ber_length
  title: ASN.1 BER length
  license: CC0-1.0
  xref:
    justsolve: BER
    wikidata: Q2738854
  
doc: Basic Encoding Rules (BER) length formatting rules.
doc-ref: https://en.wikipedia.org/wiki/X.690#BER_encoding X.690 BER encoding

seq:
  - id: length_short_len_byte
    type: u1
  - id: length_long_len_bytes
    type: u1
    if: (length_short_len_byte >= 0x7F)
    repeat: expr
    repeat-expr: length_short_len_byte - 0x80
instances:
  val_len:
    value: (length_short_len_byte <= 0x7F)
      ? (length_short_len_byte)
      : (length_short_len_byte == 0x81)
      ? ((length_long_len_bytes[0] << 0))
      : (length_short_len_byte == 0x82)
      ? ((length_long_len_bytes[0] << 8) | (length_long_len_bytes[1] << 0))
      : (length_short_len_byte == 0x83)
      ? ((length_long_len_bytes[0] << 16) | (length_long_len_bytes[1] << 8) | (length_long_len_bytes[2] << 0)) 
      : 0
  len_len:
    value: (length_short_len_byte >= 0x7F) ? (1 + (length_short_len_byte - 0x80)) : (1)
