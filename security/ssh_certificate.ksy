meta:
  id: ssh_certificate
  title: OpenSSH Certificate
  license: CC0-1.0
  endian: be
  imports:
    - /security/ssh_public_key
doc: |
  OpenSSH Certificates are simple certs used by OpenSSH.
doc-ref: 'https://cvsweb.openbsd.org/cgi-bin/cvsweb/~checkout~/src/usr.bin/ssh/PROTOCOL.certkeys?rev=HEAD&content-type=text/plain'
seq:
  - id: cert_type
    doc: type of ssh certificate
    type: cstring_utf8
  - id: body
    type:
      switch-on: cert_type.value
      cases:
        '"ssh-rsa-cert-v01@openssh.com"': cert_rsa
        '"ssh-dss-cert-v01@openssh.com"': cert_dss
        '"ecdsa-sha2-nistp256-cert-v01@openssh.com"': cert_ecdsa
        '"ecdsa-sha2-nistp384-cert-v01@openssh.com"': cert_ecdsa
        '"ecdsa-sha2-nistp521-cert-v01@openssh.com"': cert_ecdsa
        '"ssh-ed25519-cert-v01@openssh.com"': cert_ed25519
types:
  cert_rsa:
    doc-ref: 'https://tools.ietf.org/html/rfc4253#section-6.6'
    seq:
      - id: nonce
        doc: CA-provided random bitstring to prevent hash collisions in the signature
        type: cstring_bytes
      - id: rsa
        type: ssh_public_key::key_rsa
      - id: footer
        type: cert_footer
  cert_dss:
    seq:
      - id: nonce
        doc: CA-provided random bitstring to prevent hash collisions in the signature
        type: cstring_bytes
      - id: dsa
        type: ssh_public_key::key_dsa
      - id: footer
        type: cert_footer
  cert_ecdsa:
    seq:
      - id: nonce
        doc: CA-provided random bitstring to prevent hash collisions in the signature
        type: cstring_bytes
      - id: ecdsa
        type: ssh_public_key::key_ecdsa
      - id: footer
        type: cert_footer
  cert_ed25519:
    seq:
      - id: nonce
        doc: CA-provided random bitstring to prevent hash collisions in the signature
        type: cstring_bytes
      - id: ed25519
        type: ssh_public_key::key_ed25519
      - id: footer
        type: cert_footer
  cert_footer:
    seq:
      - id: serial
        doc: optional serial number; if zero the CA doesn't use serial numbers
        type: u8
      - id: type
        doc: specifies the certificate type (user vs host)
        type: u4
        enum: cert_type
      - id: key_id
        type: cstring_utf8
      - id: valid_principals
        doc: | 
          As a special case, a zero-length "valid principals"  field means
          the certificate is valid for any principal of the specified type.
        type: packed_cstring
      - id: valid_after
        doc: Unix timestamp (seconds since 1970-01-01 00:00:00)
        type: u8
      - id: valid_before
        doc: | 
          Unix timestamp (seconds since 1970-01-01 00:00:00)
          When "forever" is requested this is set to 0xFFFF_FFFF_FFFF_FFFF
        type: u8
      - id: critical_options
        doc: | 
          critical options is a set of zero or more key options encoded as
          below. All such options are "critical" in the sense that an implementation
          must refuse to authorise a key that has an unrecognised option.

          Generally, critical options are used to control features that restrict
          access where extensions are used to enable features that grant access.
          This ensures that certificates containing unknown restrictions do not
          inadvertently grant access while allowing new protocol features to be
          enabled via extensions without breaking certificates' backwards
          compatibility.
        type: packed_cstring_tuple
      - id: extensions
        doc: | 
          extensions is a set of zero or more optional extensions. These extensions
          are not critical, and an implementation that encounters one that it does
          not recognise may safely ignore it.
        type: packed_cstring_tuple
      - id: reserved
        doc: Unused currently
        type: cstring_bytes
      - id: signature_key
        doc: | 
          The signature key field contains the CA key used to sign the
          certificate. The valid key types for CA keys are ssh-rsa,
          ssh-dss, ssh-ed25519 and the ECDSA types ecdsa-sha2-nistp256,
          ecdsa-sha2-nistp384, ecdsa-sha2-nistp521. "Chained" certificates, where
          the signature key type is a certificate type itself are NOT supported.
          Note that it is possible for a RSA certificate key to be signed by a
          Ed25519 or ECDSA CA key and vice-versa.
        type: cstring_sshkey
      - id: signature
        doc: | 
          signature is computed over all preceding fields from the initial string
          up to, and including the signature key. Signatures are computed and
          encoded according to the rules defined for the CA's public key algorithm
          (RFC4253 section 6.6 for ssh-rsa and ssh-dss, RFC5656 for the ECDSA
          types), and draft-josefsson-eddsa-ed25519-03 for Ed25519.
        type: packed_cstring_tuple
    enums:
      cert_type:
        1: user
        2: host
  packed_cstring:
    seq:
      - id: len
        type: u4
      - id: packed_strings
        size: len
        type: cstrings
  packed_cstring_tuple:
    seq:
      - id: len
        type: u4
      - id: packed_strings
        type: cstring_tuples
        size: len
  cstrings:
    seq:
      - id: strings
        type: cstring_utf8
        repeat: eos
  cstring_tuples:
    seq:
      - id: strings
        type: cstring_tuple
        repeat: eos
  cstring_tuple:
    seq:
      - id: name
        type: cstring_utf8
      - id: data
        type: cstring_bytes
  cstring_sshkey:
    seq:
      - id: len
        type: u4
      - id: value
        type: ssh_public_key
  cstring_bytes:
    doc-ref: 'https://tools.ietf.org/html/rfc4251#section-5'
    doc: |
      Arbitrary length binary string.  Strings are allowed to contain
      arbitrary binary data, including null characters and 8-bit
      characters.  They are stored as a uint32 containing its length
      (number of bytes that follow) and zero (= empty string) or more
      bytes that are the value of the string.  Terminating null
      characters are not used.

      Strings are also used to store text.  In that case, US-ASCII is
      used for internal names, and ISO-10646 UTF-8 for text that might
      be displayed to the user.  The terminating null character SHOULD
      NOT normally be stored in the string.  For example: the US-ASCII
      string "testing" is represented as 00 00 00 07 t e s t i n g.  The
      UTF-8 mapping does not alter the encoding of US-ASCII characters.
    seq:
      - id: len
        type: u4
      - id: value
        size: len
  cstring_utf8:
    doc: variant of cstring_bytes that decodes to UTF-8
    seq:
      - id: len
        type: u4
      - id: value
        type: str
        encoding: UTF-8
        size: len
