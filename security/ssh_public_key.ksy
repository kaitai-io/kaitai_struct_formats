meta:
  id: ssh_public_key
  title: SSH public key
  license: CC0-1.0
  endian: be
doc: |
  SSH public keys are encoded in a special binary format, typically represented
  to end users as either one-liner OpenSSH format or multi-line PEM format
  (commerical SSH). Text wrapper carries extra information about user who
  created the key, comment, etc, but the inner binary is always base64-encoded
  and follows the same internal format.

  This format spec deals with this internal binary format (called "blob" in
  openssh sources) only. Buffer is expected to be raw binary and not base64-d.
  Implementation closely follows code in OpenSSH.
doc-ref: 'https://github.com/openssh/openssh-portable/blob/master/sshkey.c#L1970'
seq:
  - id: key_name
    type: cstring
  - id: body
    type:
      switch-on: key_name.value
      cases:
        '"ssh-rsa"': key_rsa
        '"ecdsa-sha2-nistp256"': key_ecdsa
        '"ssh-ed25519"': key_ed25519
        '"ssh-dss"': key_dsa
types:
  key_rsa:
    doc-ref: 'https://github.com/openssh/openssh-portable/blob/master/sshkey.c#L2011-L2028'
    seq:
      - id: rsa_e
        type: bignum2
        doc: Public key exponent, designated `e` in RSA documentation.
      - id: rsa_n
        type: bignum2
        doc: |
          Modulus of both public and private keys, designated `n` in RSA
          documentation. Its length in bits is designated as "key length".
    instances:
      key_length:
        -webide-parse-mode: eager
        value: rsa_n.length_in_bits
        doc: Key length in bits
  key_ecdsa:
    doc-ref: 'https://github.com/openssh/openssh-portable/blob/master/sshkey.c#L2060-L2103'
    seq:
      - id: curve_name
        type: cstring
      - id: ec
        type: elliptic_curve
  key_ed25519:
    doc-ref: 'https://github.com/openssh/openssh-portable/blob/master/sshkey.c#L2111-L2124'
    seq:
      - id: len_pk
        type: u4
        # must be 0x20
      - id: pk
        size: len_pk
  key_dsa:
    doc-ref: 'https://github.com/openssh/openssh-portable/blob/master/sshkey.c#L2036-L2051'
    seq:
      - id: dsa_p
        type: bignum2
      - id: dsa_q
        type: bignum2
      - id: dsa_g
        type: bignum2
      - id: dsa_pub_key
        type: bignum2
  cstring:
    doc: |
      A integer-prefixed string designed to be read using `sshbuf_get_cstring`
      and written by `sshbuf_put_cstring` routines in ssh sources. Name is an
      obscure misnomer, as typically "C string" means a null-terminated string.
    doc-ref: 'https://github.com/openssh/openssh-portable/blob/master/sshbuf-getput-basic.c#L181'
    -webide-representation: '{value}'
    seq:
      - id: len
        type: u4
      - id: value
        type: str
        size: len
        encoding: ASCII
  bignum2:
    doc: |
      Big integers serialization format used by ssh, v2. In the code, the following
      routines are used to read/write it:

      * sshbuf_get_bignum2
      * sshbuf_get_bignum2_bytes_direct
      * sshbuf_put_bignum2
      * sshbuf_get_bignum2_bytes_direct
    doc-ref: |
      https://github.com/openssh/openssh-portable/blob/master/sshbuf-getput-crypto.c#L35
      https://github.com/openssh/openssh-portable/blob/master/sshbuf-getput-basic.c#L431
    seq:
      - id: len
        type: u4
      - id: body
        size: len
    instances:
      length_in_bits:
        value: (len - 1) * 8
        doc: |
          Length of big integer in bits. In OpenSSH sources, this corresponds to
          `BN_num_bits` function.
  elliptic_curve:
    doc: |
      Elliptic curve dump format used by ssh. In OpenSSH code, the following
      routines are used to read/write it:

      * sshbuf_get_ec
      * get_ec
    doc-ref: |
      https://github.com/openssh/openssh-portable/blob/master/sshbuf-getput-crypto.c#L90
      https://github.com/openssh/openssh-portable/blob/master/sshbuf-getput-crypto.c#L76
    seq:
      - id: len
        type: u4
      - id: body
        size: len
