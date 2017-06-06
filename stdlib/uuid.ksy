meta:
  id: uuid
  endian: le
  license: Unlicense
doc: "UUID according to https://www.ietf.org/rfc/rfc4122.txt"
seq:
  - id: time_low
    type: u4be
    doc: The low field of the timestamp
  - id: time_mid
    type: u2be
    doc: The middle field of thetimestamp
  - id: time_hi_and_version
    type: u2be
    doc: The high field of the timestamp multiplexed with the version number
  - id: clock_seq_hi_and_reserved
    type: u1
    doc: The high field of the clock sequence multiplexed with the variant
  - id: clock_seq_low
    type: u1
    doc: The low field of the clock sequence
  - id: node
    type: u4be
    doc: The spatially unique node identifier
  - id: node1
    type: u2be
    doc: The spatially unique node identifier

instances:
  variant:
    doc: >
      The variant field determines the layout of the UUID.  That is, the interpretation of all other bits in the UUID depends on the setting of the bits in the variant field.  As such, it could more accurately be called a type field; we retain the original term for compatibility.  The variant field consists of a variable number of the most significant bits of octet 8 of the UUID.
    pos: 0
    type: b1
    enum: variants
    repeat: until
    repeat-until: _ == 0
enums:
  variants:
    0: ncs_backward_compatibility
    2: current
    6: microsoft_backward_compatibility
    7: future
  versions:
    1: time # The time-based version specified in this document.
    2: dce # DCE Security version, with embedded POSIX UIDs.
    3: name_md5 #The name-based version specified in this document that uses MD5 hashing.
    4: random #The randomly or pseudo-randomly generated version specified in this document.
    5: name_sha1 #The name-based version specified in this document that uses SHA-1 hashing.