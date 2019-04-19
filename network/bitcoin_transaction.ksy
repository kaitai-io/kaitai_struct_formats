meta:
  id: bitcoin_transaction
  title: Bitcoin Transaction
  license: MIT
  endian: le
doc-ref: |
  https://bitcoin.org/en/developer-guide#transactions
  https://en.bitcoin.it/wiki/Transaction
seq:
  - id: version
    type: u4
    doc: |
      Version number.
  - id: num_vins
    type: u1
    doc: |
      Number of input transactions.
  - id: vins
    type: vin
    repeat: expr
    repeat-expr: num_vins
    doc: |
      Input transactions.
      An input refers to an output from a previous transaction.
  - id: num_vouts
    type: u1
    doc: |
      Number of output transactions.
  - id: vouts
    type: vout
    repeat: expr
    repeat-expr: num_vouts
    doc: |
      Output transactions.
  - id: locktime
    type: u4
types:
  vin:
    seq:
      - id: txid
        size: 32
        doc: |
          Previous transaction hash.
      - id: output_id
        type: u4
        doc: |
          ID indexing an ouput of the transaction refered by txid.
          This output will be used as an input in the present transaction.
      - id: script_len
        type: u1
        doc: |
          ScriptSig's length.
      - id: script_sig
        size: script_len
        type: script_signature
        doc: |
          ScriptSig.
        doc-ref: |
          https://en.bitcoin.it/wiki/Transaction#Input
          https://en.bitcoin.it/wiki/Script
      - id: end_of_vin
        contents: [0xff, 0xff, 0xff, 0xff]
        doc: |
          Magic number indicating the end of the current input.
  vout:
    seq:
      - id: amount
        type: u8
        doc: |
          Number of Satoshis to be transfered.
      - id: script_len
        type: u1
        doc: |
          ScriptPubKey's length.
      - id: script_pub_key
        size: script_len
        doc: |
          ScriptPubKey.
        doc-ref: |
          https://en.bitcoin.it/wiki/Transaction#Output
          https://en.bitcoin.it/wiki/Script
  script_signature:
    seq:
      - id: sig_stack_len
        type: u1
      - id: der_sig
        type: der_signature
        doc: |
          DER-encoded ECDSA signature.
        doc-ref: |
          https://en.wikipedia.org/wiki/X.690#DER_encoding
          https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
      - id: sig_type
        type: u1
        enum: sighash_type
        doc: |
          Type of signature.
      - id: pubkey_stack_len
        type: u1
      - id: pubkey
        type: public_key
        doc: |
          Public key (bitcoin address of the recipient).
  der_signature:
    seq:
      - id: sequence
        contents: [0x30]
      - id: sig_len
        type: u1
      - id: sep_1
        contents: [0x02]
      - id: sig_r_len
        type: u1
        doc: |
          'r' value's length.
      - id: sig_r
        size: sig_r_len
        doc: |
          'r' value of the ECDSA signature.
        doc-ref: 'https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm'
      - id: sep_2
        contents: [0x02]
      - id: sig_s_len
        type: u1
        doc: |
          's' value's length.
      - id: sig_s
        size: sig_s_len
        doc: |
          's' value of the ECDSA signature.
        doc-ref: 'https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm'
  public_key:
    seq:
      - id: type
        type: u1
      - id: x
        size: 32
        doc: |
          'x' coordinate of the public key on the elliptic curve.
      - id: y
        size: 32
        doc: |
          'y' coordinate of the public key on the elliptic curve.
enums:
  sighash_type:
    1: sighash_all
    2: sighash_none
    3: sighash_single
    80: sighash_anyonecanpay
