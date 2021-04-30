meta:
  id: binarysd
  endian: le
  title: Windows Binary Security Descriptor parser
  license: MIT
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  License: MIT
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
    - id: flag_dt
      type: b1
      doc: DACL Trustet
    - id: flag_ss
      type: b1
      doc: Server Security
    - id: flag_sd
      type: b1
      doc: SACL defaulted
    - id: flag_sp
      type: b1
      doc: SACL present
    - id: flag_dd
      type: b1
      doc: DACL defaulted
    - id: flag_dp
      type: b1
      doc: DACL present
    - id: flag_gd
      type: b1
      doc: Group defaulted
    - id: flag_od
      type: b1
      doc: Owner defaulted
    - id: flag_sr
      type: b1
      doc: Self-Relative
    - id: flag_rm
      type: b1
      doc: Control Valid
    - id: flag_ps
      type: b1
      doc: SACL-protected
    - id: flag_pd
      type: b1
      doc: DACL-protected
    - id: flag_si
      type: b1
      doc: SACL auto-inherited
    - id: flag_di
      type: b1
      doc: DACL auto-inherited
    - id: flag_ir
      type: b1
      doc: SACL Inheritance Required
    - id: flag_dr
      type: b1
      doc: DACL Inheritance Required
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
    seq:
      - id: access_allow_type
        type: u1
      - id: flag_fa
        type: b1
      - id: flag_sa
        type: b1
      - id: flag_unknown
        type: b1
      - id: flag_id
        type: b1
      - id: flag_io
        type: b1
      - id: flag_np
        type: b1
      - id: flag_ci
        type: b1
      - id: flag_oi
        type: b1
      - id: ace_size
        type: u2
      - id: acces_mask_specific_rights
        type: u2
        doc: |
          Documentation says that this is an access mask, but there is no documentation about the different flags
          see also https://docs.microsoft.com/en-us/windows/win32/secauthz/access-mask
      - id: access_mask_standard_rights_unknown1
        type: b1
      - id: access_mask_standard_rights_unknown2
        type: b1
      - id: access_mask_standard_rights_unknown3
        type: b1
      - id: access_mask_standard_rights_sy
        type: b1
        doc: SYNCHRONIZE
      - id: access_mask_standard_rights_wo
        type: b1
        doc: WRITE_OWNER
      - id: access_mask_standard_rights_wd
        type: b1
        doc: WRIDE_DACL
      - id: access_mask_standard_rights_rc
        type: b1
        doc: READ_CONTROL
      - id: access_mask_standard_rights_sd
        type: b1
        doc: DELETE
      - id: access_mask_generic_rights_gr
        type: b1
        doc: GENERIC_READ
      - id: access_mask_generic_rights_gw
        type: b1
        doc: GENERIC_WRITE
      - id: access_mask_generic_rights_gx
        type: b1
        doc: GENERIC_EXECUTE
      - id: access_mask_generic_rights_ga
        type: b1
        doc: GENERIC_ALL
      - id: access_mask_generic_rights_reserved1
        type: b1
        doc: reserved
      - id: access_mask_generic_rights_reserved2
        type: b1
        doc: reserved
      - id: access_mask_generic_rights_ma
        type: b1
        doc: MAXIMUM_ALLOWED
      - id: access_mask_generic_rights_as
        type: b1
        doc: ACCESS_SYSTEM_SECURITY
      - id: sid
        type: sid
        size: ace_size - 8
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
