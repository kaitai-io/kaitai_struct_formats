meta:
  id: windef_resource_data
  endian: le
  title: Windows Defender quarantine resourcedata file
  license: MIT
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  ResourceData files store suspected malware and metadata and are created by Windows Defender.
  The parser was created analyzing different files from the ResourceData subdirectory in the Windows Defender quarantine directory.
  The file is encrypted. It contains a binary security descriptor and the suspected malware.
  The name of the file is the same as the matching Resources file which contains more information about this suspected malware.
doc-ref: https://github.com/ernw/quarantine-formats/blob/master/docs/Windows_Defender.md
seq:
  - id: encryptedfile
    type: rc4encrypted
    process: util.custom_arc4.custom_arc4([0x1E, 0x87, 0x78, 0x1B, 0x8D, 0xBA, 0xA8, 0x44, 0xCE, 0x69,
                                           0x70, 0x2C, 0x0C, 0x78, 0xB7, 0x86, 0xA3, 0xF6, 0x23, 0xB7,
                                           0x38, 0xF5, 0xED, 0xF9, 0xAF, 0x83, 0x53, 0x0F, 0xB3, 0xFC,
                                           0x54, 0xFA, 0xA2, 0x1E, 0xB9, 0xCF, 0x13, 0x31, 0xFD, 0x0F,
                                           0x0D, 0xA9, 0x54, 0xF6, 0x87, 0xCB, 0x9E, 0x18, 0x27, 0x96,
                                           0x97, 0x90, 0x0E, 0x53, 0xFB, 0x31, 0x7C, 0x9C, 0xBC, 0xE4,
                                           0x8E, 0x23, 0xD0, 0x53, 0x71, 0xEC, 0xC1, 0x59, 0x51, 0xB8,
                                           0xF3, 0x64, 0x9D, 0x7C, 0xA3, 0x3E, 0xD6, 0x8D, 0xC9, 0x04,
                                           0x7E, 0x82, 0xC9, 0xBA, 0xAD, 0x97, 0x99, 0xD0, 0xD4, 0x58,
                                           0xCB, 0x84, 0x7C, 0xA9, 0xFF, 0xBE, 0x3C, 0x8A, 0x77, 0x52,
                                           0x33, 0x55, 0x7D, 0xDE, 0x13, 0xA8, 0xB1, 0x40, 0x87, 0xCC,
                                           0x1B, 0xC8, 0xF1, 0x0F, 0x6E, 0xCD, 0xD0, 0x83, 0xA9, 0x59,
                                           0xCF, 0xF8, 0x4A, 0x9D, 0x1D, 0x50, 0x75, 0x5E, 0x3E, 0x19,
                                           0x18, 0x18, 0xAF, 0x23, 0xE2, 0x29, 0x35, 0x58, 0x76, 0x6D,
                                           0x2C, 0x07, 0xE2, 0x57, 0x12, 0xB2, 0xCA, 0x0B, 0x53, 0x5E,
                                           0xD8, 0xF6, 0xC5, 0x6C, 0xE7, 0x3D, 0x24, 0xBD, 0xD0, 0x29,
                                           0x17, 0x71, 0x86, 0x1A, 0x54, 0xB4, 0xC2, 0x85, 0xA9, 0xA3,
                                           0xDB, 0x7A, 0xCA, 0x6D, 0x22, 0x4A, 0xEA, 0xCD, 0x62, 0x1D,
                                           0xB9, 0xF2, 0xA2, 0x2E, 0xD1, 0xE9, 0xE1, 0x1D, 0x75, 0xBE,
                                           0xD7, 0xDC, 0x0E, 0xCB, 0x0A, 0x8E, 0x68, 0xA2, 0xFF, 0x12,
                                           0x63, 0x40, 0x8D, 0xC8, 0x08, 0xDF, 0xFD, 0x16, 0x4B, 0x11,
                                           0x67, 0x74, 0xCD, 0x0B, 0x9B, 0x8D, 0x05, 0x41, 0x1E, 0xD6,
                                           0x26, 0x2E, 0x42, 0x9B, 0xA4, 0x95, 0x67, 0x6B, 0x83, 0x98,
                                           0xDB, 0x2F, 0x35, 0xD3, 0xC1, 0xB9, 0xCE, 0xD5, 0x26, 0x36,
                                           0xF2, 0x76, 0x5E, 0x1A, 0x95, 0xCB, 0x7C, 0xA4, 0xC3, 0xDD,
                                           0xAB, 0xDD, 0xBF, 0xF3, 0x82, 0x53
                                          ])
    size-eos: true
types:
  rc4encrypted:
    seq:
      - id: fixed
        contents: [0x03, 0, 0, 0, 0x02, 0, 0, 0]
        size: 8
      - id: len_binarysd
        type: u4
      - id: padding
        size: 0x08
      - id: binarysd
        type: binarysd
        size: len_binarysd
      - id: unknown1
        size: 0x08
      - id: len_mal_file
        type: u8
      - id: unknown2
        size: 0x04
      - id: mal_file
        size: len_mal_file
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
