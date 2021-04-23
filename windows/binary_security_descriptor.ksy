meta:
  id: binarysd
  endian: le
  title: Windows Binary Security Descriptor parser
  license: CC-BY-SA-4.0
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  License: CC-BY-SA-4.0 https://creativecommons.org/licenses/by-sa/4.0/
seq:
  - id: fixed
    contents: [0x03, 0, 0, 0, 0x02, 0, 0, 0]
    size: 8
  - id: length
    type: u4
  - id: padding
    type: u8
  - id: binarysd
    type: binarysd
    size: length
types:
  binarysd:
    seq:
    - id: revision
      type: u1
    - id: reserved
      size: 1
      contents: [0]
    - id: control_flags
      type: u2
    - id: owner_offset
      type: u4
    - id: group_offset
      type: u4
    - id: sacl_offset
      type: u4
    - id: dacl_offset
      type: u4
    instances:
      owner:
        pos: owner_offset
        type: sid
        if: 'owner_offset > 0'
      group:
        pos: group_offset
        type: sid
        if: 'group_offset > 0'
      dacl:
        pos: dacl_offset
        type: acl
        if: 'dacl_offset > 0'
      sacl:
        pos: sacl_offset
        type: acl
        if: 'sacl_offset > 0'
  acl:
    seq:
      - id: revision
        type: u1
      - id: reserved
        size: 1
        contents: [0]
      - id: aclsize
        type: u2
      - id: acecount
        type: u2
      - id: reserved2
        size: 2
        contents: [0, 0]
      - id: acelist
        type: acelist
        size: aclsize - 8
  acelist:
    seq:
      - id: ace
        type: ace
        repeat: eos
  ace:
    seq:
      - id: accessallowtype
        type: u1
      - id: flags
        type: u1
      - id: acesize
        type: u2
      - id: accessmask
        type: u4
      - id: sid
        type: sid
        size: acesize - 8
  sid:
    seq:
      - id: revision
        type: u1
      - id: number_of_chunks
        type: u1
      - id: reserved
        size: 2
        contents: [0, 0]
      - id: firstchunk
        type: u4be
      - id: chunk
        type: u4
        repeat: expr
        repeat-expr: number_of_chunks