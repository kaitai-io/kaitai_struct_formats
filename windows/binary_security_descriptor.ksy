meta:
  id: binarysd
  endian: le
  title: Windows Binary Security Descriptor parser
  license: MIT
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
doc-ref: |
  https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-dtyp/2918391b-75b9-4eeb-83f0-7fdc04a5c6c9
  https://docs.microsoft.com/en-us/windows/win32/secauthz/sid-strings
  https://docs.microsoft.com/en-us/windows/win32/secauthz/well-known-sids
  https://itconnect.uw.edu/wares/msinf/other-help/understanding-sddl-syntax/
  https://github.com/ernw/quarantine-formats/blob/master/docs/Binary_Security_Descriptor.md
seq:
  - id: fixed
    contents: [0x03, 0, 0, 0, 0x02, 0, 0, 0]
    size: 8
  - id: len_binarysd
    type: u4
  - id: padding
    type: u8
  - id: binarysd
    type: binarysd
    size: len_binarysd
types:
  binarysd:
    seq:
    - id: revision
      type: u1
    - id: reserved
      size: 1
      contents: [0]
    - id: flags
      type: binarysd_flags
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
  binarysd_flags:
    seq:
      - id: dacl_trusted
        type: b1
        doc: DACL Trusted
      - id: server_security
        type: b1
        doc: Server Security
      - id: sacl_defaulted
        type: b1
        doc: SACL defaulted
      - id: sacl_present
        type: b1
        doc: SACL present
      - id: dacl_defaulted
        type: b1
        doc: DACL defaulted
      - id: dacl_present
        type: b1
        doc: DACL present
      - id: group_defaulted
        type: b1
        doc: Group defaulted
      - id: owner_defaulted
        type: b1
        doc: Owner defaulted
      - id: self_relative
        type: b1
        doc: Self-Relative
      - id: control_valid
        type: b1
        doc: Control Valid
      - id: sacl_protected
        type: b1
        doc: SACL-protected
      - id: dacl_protected
        type: b1
        doc: DACL-protected
      - id: sacl_auto_inherited
        type: b1
        doc: SACL auto-inherited
      - id: dacl_auto_inherited
        type: b1
        doc: DACL auto-inherited
      - id: sacl_inheritance_required
        type: b1
        doc: SACL Inheritance Required
      - id: dacl_inheritance_required
        type: b1
        doc: DACL Inheritance Required
  acl:
    seq:
      - id: revision
        type: u1
      - id: reserved
        size: 1
        contents: [0]
      - id: acl_size
        type: u2
      - id: ace_count
        type: u2
      - id: reserved2
        size: 2
        contents: [0, 0]
      - id: ace_list
        type: ace_list
        size: acl_size - 8
  ace_list:
    seq:
      - id: ace
        type: ace
        repeat: eos
  ace:
    doc-ref: https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-dtyp/628ebb1d-c509-4ea0-a10f-77ef97ca4586
    seq:
      - id: access_allow_type
        type: u1
      - id: flags
        type: ace_flags
      - id: ace_size
        type: u2
      - id: access_mask
        type: access_mask
      - id: sid
        type: sid
        size: ace_size - 8
  ace_flags:
    seq:
        - id: failed_access
          type: b1
        - id: successful_access
          type: b1
        - id: unknown
          type: b1
        - id: inherited
          type: b1
        - id: inherit_only
          type: b1
        - id: no_propagate_inherit
          type: b1
        - id: container_inherit
          type: b1
        - id: object_inherit
          type: b1
  access_mask:
    doc-ref: https://docs.microsoft.com/en-us/windows/win32/secauthz/access-mask
    seq:
      - id: specific_rights
        type: access_mask_specific_rights
      - id: standard_rights
        type: access_mask_standard_rights
      - id: generic_rights
        type: access_mask_generic_rights
  access_mask_specific_rights:
    seq:
      - id: flags
        size: 2
        doc: |
          Documentation says that this is an access mask, but there is no documentation about the different flags
        doc-ref: https://docs.microsoft.com/en-us/windows/win32/secauthz/access-mask
  access_mask_standard_rights:
    seq:
      - id: unknown1
        type: b1
      - id: unknown2
        type: b1
      - id: unknown3
        type: b1
      - id: synchronize
        type: b1
        doc: SYNCHRONIZE
      - id: write_owner
        type: b1
        doc: WRITE_OWNER
      - id: write_dacl
        type: b1
        doc: WRITE_DACL
      - id: read_control
        type: b1
        doc: READ_CONTROL
      - id: standard_delete
        type: b1
        doc: DELETE
  access_mask_generic_rights:
    seq:
      - id: generic_read
        type: b1
        doc: GENERIC_READ
      - id: generic_write
        type: b1
        doc: GENERIC_WRITE
      - id: generic_execute
        type: b1
        doc: GENERIC_EXECUTE
      - id: generic_all
        type: b1
        doc: GENERIC_ALL
      - id: reserved1
        type: b1
        doc: reserved
      - id: reserved2
        type: b1
        doc: reserved
      - id: maximum_allowed
        type: b1
        doc: MAXIMUM_ALLOWED
      - id: access_system_security
        type: b1
        doc: ACCESS_SYSTEM_SECURITY
  sid:
    seq:
      - id: revision
        type: u1
      - id: num_chunk
        type: u1
      - id: reserved
        size: 2
        contents: [0, 0]
      - id: first_chunk
        type: u4be
      - id: chunk
        type: u4
        repeat: expr
        repeat-expr: num_chunk
