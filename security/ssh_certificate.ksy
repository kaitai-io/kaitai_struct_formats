meta:
  id: ssh_certificate
  title: OpenSSH Certificate
  license: CC0-1.0
  endian: be
  imports:
    - /security/ssh_public_key
doc: |
  OpenSSH Certificates are simple certs used by OpenSSH.
doc-ref: 'https://cvsweb.openbsd.org/src/usr.bin/ssh/PROTOCOL.certkeys?annotate=HEAD'
seq:
  - id: cert_name
    type: ssh_public_key::cstring
  - id: body
    type:
      switch-on: cert_name.value
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
        type: ssh_public_key::cstring
      - id: rsa
        type: ssh_public_key::key_rsa
      - id: footer
        type: cert_footer
  cert_dss:
    seq:
      - id: nonce
        type: ssh_public_key::cstring
      - id: dsa
        type: ssh_public_key::key_dsa
      - id: footer
        type: cert_footer
  cert_ecdsa:
    seq:
      - id: nonce
        type: ssh_public_key::cstring
      - id: ecdsa
        type: ssh_public_key::key_ecdsa
      - id: footer
        type: cert_footer
  cert_ed25519:
    seq:
      - id: nonce
        type: ssh_public_key::cstring
      - id: ed25519
        type: ssh_public_key::key_ed25519
      - id: footer
        type: cert_footer
  cert_footer:
    seq:
      - id: serial
        type: u8
      - id: type
        type: u4
      - id: key_id
        type: ssh_public_key::cstring
      - id: validprincipals
        type: packed_cstring
      - id: valid_after
        type: u8
      - id: valid_before
        type: u8
      - id: critical_options
        type: packed_cstring_tuple
      - id: extensions
        type: packed_cstring_tuple
      - id: reserved
        type: ssh_public_key::cstring
      - id: signature_key
        type: cstring_sshkey
      - id: signature
        type: packed_cstring_tuple
  packed_cstring:
    seq:
      - id: len
        type: u4
      - id: packed_strings
        type: cstrings
        size: len
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
        type: ssh_public_key::cstring
        repeat: eos
  cstring_tuples:
    seq:
      - id: strings
        type: cstring_tuple
        repeat: eos
  cstring_tuple:
    seq:
      - id: name
        type: ssh_public_key::cstring
      - id: data
        type: ssh_public_key::cstring
  cstring_sshkey:
    seq:
      - id: len
        type: u4
      - id: value
        type: ssh_public_key
