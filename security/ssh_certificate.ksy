meta:
  id: ssh_certificate
  title: OpenSSH Certificate
  license: CC0-1.0
  imports:
    - /security/ssh_public_key
  endian: be
doc: |
  OpenSSH Certificates are simple certs used by OpenSSH.
doc-ref: 'https://cvsweb.openbsd.org/cgi-bin/cvsweb/~checkout~/src/usr.bin/ssh/PROTOCOL.certkeys?rev=1.17&content-type=text/plain'
seq:
  - id: cert_type
    type: cstring_utf8
    doc: type of ssh certificate
  - id: body
    type: cert_body
types:
  cert_body:
    seq:
      - id: nonce
        type: cstring_bytes
        doc: CA-provided random bitstring to prevent hash collisions in the signature
      - id: key
        type:
          switch-on: _parent.cert_type.value
          cases:
            '"ssh-rsa-cert-v01@openssh.com"': ssh_public_key::key_rsa
            '"ssh-dss-cert-v01@openssh.com"': ssh_public_key::key_dsa
            '"ecdsa-sha2-nistp256-cert-v01@openssh.com"': ssh_public_key::key_ecdsa
            '"ecdsa-sha2-nistp384-cert-v01@openssh.com"': ssh_public_key::key_ecdsa
            '"ecdsa-sha2-nistp521-cert-v01@openssh.com"': ssh_public_key::key_ecdsa
            '"ssh-ed25519-cert-v01@openssh.com"': ssh_public_key::key_ed25519
      - id: serial
        type: u8
        doc: optional serial number; if zero the CA doesn't use serial numbers
      - id: type
        type: u4
        enum: cert_type
        doc: specifies the certificate type (user vs host)
      - id: key_id
        type: cstring_utf8
      - id: valid_principals
        type: packed_cstring
        doc: |
          As a special case, a zero-length "valid principals" field means
          the certificate is valid for any principal of the specified type.
      - id: valid_after
        type: u8
        doc: Unix timestamp (seconds since 1970-01-01 00:00:00)
      - id: valid_before
        type: u8
        doc: |
          Unix timestamp (seconds since 1970-01-01 00:00:00)
          When "forever" is requested this is set to 0xFFFF_FFFF_FFFF_FFFF
      - id: critical_options
        type: packed_cstring_tuple
        doc: |
          Contains zero or more options that are considered "critical".
          They are considered "critical" as implementations must refuse
          to authorize a certificate that has unrecognized options. This
          prevents an unknown restriction in the certificate from failing to
          be applied.
      - id: extensions
        type: packed_cstring_tuple
        doc: |
          Contains zero or more optional extensions. These extensions
          are not critical, and an implementation that encounters one
          that it does not recognize may safely ignore it.
      - id: reserved
        type: cstring_bytes
        doc: Unused currently
      - id: signature_key
        type: cstring_sshkey
        doc: |
          The signature key field contains the CA key used to sign the
          certificate. The valid key types for CA keys are ssh-rsa,
          ssh-dss, ssh-ed25519 and the ECDSA types ecdsa-sha2-nistp256,
          ecdsa-sha2-nistp384, ecdsa-sha2-nistp521. "Chained" certificates, where
          the signature key type is a certificate type itself are NOT supported.
          Note that it is possible for a RSA certificate key to be signed by a
          Ed25519 or ECDSA CA key and vice-versa.
      - id: signature
        type: packed_cstring_tuple
        doc: |
          signature is computed over all preceding fields from the initial string
          up to, and including the signature key. Signatures are computed and
          encoded according to the rules defined for the CA's public key algorithm
          (RFC4253 section 6.6 for ssh-rsa and ssh-dss, RFC5656 for the ECDSA
          types), and draft-josefsson-eddsa-ed25519-03 for Ed25519.
    enums:
      cert_type:
        1: user
        2: host
  packed_cstring:
    seq:
      - id: len_packed_strings
        type: u4
      - id: packed_strings
        size: len_packed_strings
        type: cstrings
  packed_cstring_tuple:
    seq:
      - id: len_packed_strings
        type: u4
      - id: packed_strings
        type: cstring_tuples
        size: len_packed_strings
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
      - id: len_value
        type: u4
      - id: value
        type: ssh_public_key
  cstring_bytes:
    doc: |
      Arbitrary length binary string. Strings are allowed to contain
      arbitrary binary data, including null characters and 8-bit
      characters. They are stored as a uint32 containing its length
      (number of bytes that follow) and zero (= empty string) or more
      bytes that are the value of the string. Terminating null
      characters are not used.

      Strings are also used to store text. In that case, US-ASCII is
      used for internal names, and ISO-10646 UTF-8 for text that might
      be displayed to the user. The terminating null character SHOULD
      NOT normally be stored in the string. For example: the US-ASCII
      string "testing" is represented as 00 00 00 07 t e s t i n g. The
      UTF-8 mapping does not alter the encoding of US-ASCII characters.
    doc-ref: 'https://tools.ietf.org/html/rfc4251#section-5'
    seq:
      - id: len_value
        type: u4
      - id: value
        size: len_value
    -webide-representation: '{len_value:dec} bytes'
  cstring_utf8:
    doc: variant of cstring_bytes that decodes to UTF-8
    seq:
      - id: len_value
        type: u4
      - id: value
        type: str
        encoding: UTF-8
        size: len_value
    -webide-representation: '{value}'
