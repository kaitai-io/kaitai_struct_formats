meta:
  id: selinux_policy_binary
  title: SELinux file policy binary
  file-extension: bin
  license: CC0-1.0
  encoding: ASCII
  endian: le
doc: |
  This format is the result of compiled policies.
  This format has no specification.
  The source of truth is the code of its library: one reader and one writer.
  The same parser handles together 3 file types: kernel, module and base,
    with 2 ranges of versions: 15-33 for kernel, and 4-21 for base or module files, and 2 systems: Linux or Xen.

doc-ref:
  - https://github.com/SELinuxProject/selinux/blob/820f019ed9e3b9a9e3e62ae378f99282990976a2/libsepol/src/policydb.c
  - https://github.com/SELinuxProject/selinux/blob/820f019ed9e3b9a9e3e62ae378f99282990976a2/libsepol/src/write.c
seq:
  - id: magic
    type: u4
    enum: magics
    valid:
      any-of:
        - magics::kernel
        - magics::module
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L4225 policydb_read
  - id: len_policydb
    -orig-id: len
    type: u4
    valid:
      min: 1
      min: 32
  - id: policydb
    -orig-id: policydb_str
    type: str
    size: len_policydb
    valid:
      expr: '(magic == magics::kernel and (_ == "SE Linux" or _ == "XenFlask")) or (magic == magics::module and _ == "SE Linux Module")'
  - id: policy_type
    type: u4
    enum: policy_types
    if: 'magic == magics::module'
  - id: policy_version
    -orig-id: policyvers
    type: u4
    valid:
      min: 'magic == magics::kernel ? 15 : 4'
      max: 'magic == magics::kernel ? 33 : 21'        
  - id: config
    -orig-id: config
    type: u4
  - id: num_symbols
    -orig-id: sym_num
    type: u4
    valid:
      min: 5
  - id: object_contexts_count
    -orig-id: ocon_num
    type: u4
    valid:
      min: 0
      max: 9
  - id: module_header
    type: module_header
    if: 'magic == magics::module'
  - id: policy_capabilities
    -orig-id: policycaps
    type: extensible_bitmap
    if: '(_root.type_ == policy_types::kernel and policy_version >= 22) or (policy_version >= 7)'
  - id: permissive_map
    type: extensible_bitmap
    if: '(_root.type_ == policy_types::kernel and policy_version >= 23)'
  - id: symbols
    type: symbols
  - id: access_vector_table
    type: access_vector_table
    if: '(_root.type_ == policy_types::kernel)'
  - id: conditional_list
    type: conditional_list
    if: '_root.type_ == policy_types::kernel and policy_version >= 16'
  - id: role_trans
    type: role_trans
    if: '_root.type_ == policy_types::kernel'
  - id: role_allow
    type: role_allow
    if: '_root.type_ == policy_types::kernel'
  - id: filename_trans
    type: filename_trans
    if: '_root.type_ == policy_types::kernel and policy_version >= 25'
  - id: avrule_block
    type: avrule_block
    if: '_root.type_ != policy_types::kernel'
  - id: scope_list
    type: scope_list
    repeat: expr
    repeat-expr: _root.num_symbols
    if: '_root.type_ != policy_types::kernel'
  - id: ocontext_selinux
    type: ocontext_selinux
    if: '_root.target == targets::selinux'
  - id: ocontext_xen
    type: ocontext_xen
    if: '_root.target == targets::xen'
  - id: genfs
    type: genfs
  - id: range
    type: range
    if: '(_root.type_ == policy_types::kernel and policy_version >= 19) or (_root.type_ == policy_types::base and policy_version == 5)'
  - id: type_attr_map
    type: extensible_bitmap
    repeat: expr
    repeat-expr: symbols.types.num_primary_names
    if: '_root.type_ == policy_types::kernel'

instances:
  boundary_feature: # policydb_has_boundary_feature
    value: |
      (_root.type_ == policy_types::kernel and _root.version >= 24) or
      (_root.type_ != policy_types::kernel and _root.version >= 9)
  version:
    value: '_root.policy_version'
  type_:
    value: |
      _root.magic == magics::kernel ? policy_types::kernel :
      (_root.policy_type == policy_types::module ? policy_types::module : policy_types::base)
  target:
    value: |
      _root.magic == magics::kernel and _root.policydb == "XenFlask" ?
      targets::xen : targets::selinux
  mls:
    value: '_root.config & 1'

enums:
  magics:
    0xf97c_ff8c: kernel
    0xf97c_ff8d: module
  targets:
    0: selinux
    1: xen
  policy_types:
    0: kernel
    1: base
    2: module
  expression_types:
    1: not
    2: and
    3: or
    4: attr
    5: names


types:
  module_header:
    seq:
      - id: len_name
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: name
        type: str
        size: len_name
      - id: len_version
        -orig-id: len # again
        type: u4
        valid:
          min: 1
      - id: version
        type: str
        size: len_version

  extensible_bitmap:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/ebitmap.c#L539 ebitmap_read
    seq:
      - id: mapsize
        type: u4
        valid: 0x40
      - id: highbit
        type: u4
        valid:
          expr: '_ & 0x3F == 0'
      - id: num_nodes
        type: u4
        valid:
          expr: 'not ((highbit != 0) and (_ == 0))'
      - id: nodes
        type: ebitmap_node
        repeat: expr
        repeat-expr: num_nodes

  ebitmap_node:
    seq:
      - id: startbit
        type: u4
      - id: map
        type: u8

  symbols:
    seq:
      - id: commons
        type: commons
      - id: classes
        type: classes
      - id: roles
        type: roles
      - id: types
        type: types_
      - id: users
        type: users
      # 5 symbols: all of them
      - id: conditional_booleans
        -orig-id: bools
        type: bools
        # 6 symbols: mod or base or kern[16-18]
        if: '_root.num_symbols >= 6'
      - id: security_levels
        -orig-id: levels
        type: levels
        if: '_root.num_symbols >= 7'
      - id: categories
        -orig-id: cats
        type: cats
        # 8 symbols: mod or base or kern[19-]
        if: '_root.num_symbols >= 8'

  commons:
    seq:
      - id: num_primary_names
        -orig-id: nprim
        type: u4
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: commons
        type: common
        repeat: expr
        repeat-expr: num_elements

  classes:
    seq:
      - id: num_primary_names
        -orig-id: nprim
        type: u4
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: classes
        type: class
        repeat: expr
        repeat-expr: num_elements

  roles:
    seq:
      - id: num_primary_names
        -orig-id: nprim
        type: u4
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: roles
        type: role
        repeat: expr
        repeat-expr: num_elements

  types_:
    seq:
      - id: num_primary_names
        -orig-id: nprim
        type: u4
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: types
        type: type_
        repeat: expr
        repeat-expr: num_elements

  users:
    seq:
      - id: num_primary_names
        -orig-id: nprim
        type: u4
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: users
        type: user
        repeat: expr
        repeat-expr: num_elements

  bools:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/conditional.c#L567 cond_read_bool
    seq:
      - id: num_primary_names
        -orig-id: nprim
        type: u4
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: bools
        type: bool
        repeat: expr
        repeat-expr: num_elements

  levels:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3414 sens_read
    seq:
      - id: num_primary_names
        -orig-id: nprim
        type: u4
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: levels
        type: level
        repeat: expr
        repeat-expr: num_elements

  cats:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3460 cat_read
    seq:
      - id: num_primary_names
        -orig-id: nprim
        type: u4
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: cats
        type: cat
        repeat: expr
        repeat-expr: num_elements

  common:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L2093 common_read
    seq:
      - id: len_key
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: value
        type: u4
      - id: num_primary_names
        -orig-id: nprim
        type: u4
        valid:
          max: 32
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: key
        type: str
        size: len_key
      - id: permissions
        type: permission
        repeat: expr
        repeat-expr: num_elements

  permission:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L2057 perm_read
    seq:
      - id: len_key
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: value
        type: u4
      - id: key
        type: str
        size: len_key

  class:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L2241 class_read
    seq:
      - id: len_key
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: len_common_key # can be null
        -orig-id: len2
        type: u4
      - id: value
        type: u4
      - id: num_primary_names
        -orig-id: perm_nprim
        type: u4
        valid:
          max: 32
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: num_constraints
        -orig-id: ncons
        type: u4
      - id: key
        type: str
        size: len_key
      - id: common_key
        -orig-id: comkey
        type: str
        size: len_common_key
        if: len_common_key > 0
      - id: permissions
        type: permission
        repeat: expr
        repeat-expr: num_elements
      - id: constraints
        type: constraint
        repeat: expr
        repeat-expr: num_constraints
      
      - id: num_validatetrans
        -orig-id: ncons # yes, same name
        type: u4
        if: '(_root.type_ == policy_types::kernel and _root.version >= 19) or (_root.type_ == policy_types::base and _root.version >= 5)'
      - id: validate_trans
        -orig-id: validatetrans
        type: constraint
        repeat: expr
        repeat-expr: num_validatetrans
        if: '(_root.type_ == policy_types::kernel and _root.version >= 19) or (_root.type_ == policy_types::base and _root.version >= 5)'

      - id: default_user
        type: u4
        if: '(_root.type_ == policy_types::kernel and _root.version >= 27) or (_root.type_ == policy_types::base and _root.version >= 15)'
      - id: default_role
        type: u4
        if: '(_root.type_ == policy_types::kernel and _root.version >= 27) or (_root.type_ == policy_types::base and _root.version >= 15)'
      - id: default_range
        type: u4
        if: '(_root.type_ == policy_types::kernel and _root.version >= 27) or (_root.type_ == policy_types::base and _root.version >= 15)'
        
      - id: default_type
        type: u4
        if: '(_root.type_ == policy_types::kernel and _root.version >= 28) or (_root.type_ == policy_types::base and _root.version >= 16)'

  constraint: # read_cons_helper
    seq:
      - id: permissions
        type: u4
      - id: num_expressions
        -orig-id: nexpr
        type: u4
      - id: expressions
        type: expression
        repeat: expr
        repeat-expr: num_expressions

  expression:
    seq:
      - id: type
        type: u4
        enum: expression_types
      - id: attribute
        -orig-id: attr
        type: u4
      - id: operator
        -orig-id: op
        type: u4
      - id: names
        type: extensible_bitmap
        if: 'type == expression_types::names'
      - id: type_names
        type: type_set
        if: 'type == expression_types::names and ((_root.type_ == policy_types::kernel and _root.version >= 29) or (_root.type_ != policy_types::kernel))'

  mls_range:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L1850 mls_read_range_helper
    seq:
      - id: items
        type: u4
      - id: sensitivity0
        -orig-id: level[0].sens
        type: u4
      - id: sensitivity1
        -orig-id: level[1].sens
        type: u4
        if: items > 1
      - id: category0
        -orig-id: level[0].cat
        type: extensible_bitmap
      - id: category1
        -orig-id: level[1].cat
        type: extensible_bitmap
        if: items > 1
  
  context:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#2018 context_read_and_validate
    seq:
      - id: user
        type: u4
      - id: role
        type: u4
      - id: type
        type: u4
      - id: mls_range
        type: mls_range
        if: '(_root.type_ == policy_types::kernel and _root.version >= 19) or (_root.type_ == policy_types::base and _root.version >= 5)'

  role:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L2352 role_read
    seq:
      - id: len_key
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: value
        type: u4
      - id: bounds
        type: u4
        if: '_root.boundary_feature'
      - id: key
        type: str
        size: len_key
      - id: dominates
        type: extensible_bitmap
      - id: types_eb
        type: extensible_bitmap
        if: _root.type_ == policy_types::kernel
      - id: types_ts
        type: type_set
        if: not (_root.type_ == policy_types::kernel)
      - id: flavor
        type: u4
        if: '(_root.type_ != policy_types::kernel and _root.version >= 13)'
      - id: roles
        type: extensible_bitmap
        if: '(_root.type_ != policy_types::kernel and _root.version >= 13)'

  type_:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#2431 type_read
    seq:
    # 3: kern <= 23
    # 4: kern >= 24 or !kern <= 7 or !kern == 9
    # 5: !kern == 8 or !kern >= 10
      - id: len_key
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: value
        type: u4
      - id: primary
        type: u4
        if: '(_root.boundary_feature and (_root.type_ != policy_types::kernel and _root.version >= 10)) or not _root.boundary_feature'
      - id: properties
        type: u4
        if: '_root.boundary_feature'
      - id: bounds
        type: u4
        if: '_root.boundary_feature'
      - id: flavor
        type: u4
        if: 'not _root.boundary_feature and (_root.type_ != policy_types::kernel)'
      - id: flags
        type: u4
        if: 'not _root.boundary_feature and (_root.type_ != policy_types::kernel and _root.version >= 8)'
      - id: types
        type: extensible_bitmap
        if: '_root.type_ != policy_types::kernel'
      - id: key
        type: str
        size: len_key

  type_set:
    seq:
      - id: types
        type: extensible_bitmap
      - id: negset
        type: extensible_bitmap
      - id: flag
        type: u4

  user:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3327 user_read
    seq:
      - id: len_key
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: value
        type: u4
      - id: bounds
        type: u4
        if: _root.boundary_feature
      - id: key
        type: str
        size: len_key
      - id: roles_eb
        type: extensible_bitmap
        if: '_root.type_ == policy_types::kernel'
      - id: roles_rs
        type: role_set
        if: '_root.type_ != policy_types::kernel'
      - id: exp_range
        type: mls_range
        if: '(_root.type_ == policy_types::kernel and _root.version >= 19) or (_root.type_ == policy_types::module and _root.version >= 5 and _root.version < 6) or (_root.type_ == policy_types::base and _root.version >= 5 and _root.version < 6)'
      - id: exp_dftlevel
        type: mls_level
        if: '(_root.type_ == policy_types::kernel and _root.version >= 19) or (_root.type_ == policy_types::module and _root.version >= 5 and _root.version < 6) or (_root.type_ == policy_types::base and _root.version >= 5 and _root.version < 6)'
      - id: range
        type: mls_semantic_range
        if: '(_root.type_ == policy_types::module or _root.type_ == policy_types::base) and (_root.version >= 6)'
      - id: dfltlevel
        type: mls_semantic_range
        if: '(_root.type_ == policy_types::module or _root.type_ == policy_types::base) and (_root.version >= 6)'

  role_set:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L1813 role_set_read
    seq:
      - id: roles
        type: extensible_bitmap
      - id: flags
        type: u4

  mls_level:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3303 mls_read_level
    seq:
      - id: sensitivity
        -orig-id: sens
        type: u4
      - id: category
        -orig-id: cat
        type: extensible_bitmap

  mls_semantic_range:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L1955 mls_read_semantic_range_helper
    seq:
      - id: level0
        type: mls_semantic_level
      - id: level1
        type: mls_semantic_level

  mls_semantic_level:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L1907 mls_read_semantic_level_helper
    seq:
      - id: sensitivity
        -orig-id: sens
        type: u4
      - id: num_categories
        -orig-id: ncat
        type: u4
      - id: categories
        -orig-id: cat
        type: semantic_category
        repeat: expr
        repeat-expr: num_categories

  semantic_category:
    seq:
      - id: low
        type: u4
      - id: high
        type: u4

  bool:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/cond_read_bool.c#L567 cond_read_bool
    seq:
      - id: value
        type: u4
      - id: state
        type: u4
      - id: len_key
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: key
        type: str
        size: len_key
      - id: flags
        type: u4
        if: '(_root.type_ != policy_types::kernel and _root.version >= 14)' 


  level:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3414 sens_read
    seq:
      - id: len_key
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: isalias
        type: u4
      - id: key
        type: str
        size: len_key
      - id: level
        type: mls_level

  cat:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3460 cat_read
    seq:
      - id: len_key
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: value
        type: u4
      - id: isalias
        type: u4
      - id: key
        type: str
        size: len_key

  access_vector_table:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/avtab.c#L591 avtab_read
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: access_vectors_old
        type: access_vector_old
        repeat: expr
        repeat-expr: num_elements
        if: _root.version < 20
      - id: access_vectors
        type: access_vector
        repeat: expr
        repeat-expr: num_elements
        if: _root.version >= 20


  access_vector_old:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/avtab.c#L434 avtab_read_item
    seq:
      - id: total
        -orig-id: items2
        type: u4
        valid:
          min: 5
          max: 8
      - id: source_type
        type: u4
      - id: target_type
        type: u4
      - id: target_class
        type: u4
      - id: value
        -orig-id: val
        type: u4
      - id: datas
        type: u4
        repeat: expr
        repeat-expr: 8

  access_vector:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/avtab.c#L572 avtab_read_item
    seq:
      - id: source_type
        type: u2
      - id: target_type
        type: u2
      - id: target_class
        type: u2
      - id: specified
        type: u2
      - id: xperms_specified
        type: u1
        if: '(specified & 0x700) != 0'
      - id: xperms_drivers
        type: u1
        if: '(specified & 0x700) != 0'
      - id: xperms_perms
        type: u4
        if: '(specified & 0x700) != 0'
        repeat: expr
        repeat-expr: 8
      - id: data
        type: u4
        if: '(specified & 0x700) == 0'
    
  conditional_list:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/conditional.c#L821 cond_read_list
    seq:
      - id: num_nodes
        -orig-id: len
        type: u4
      - id: conditional_nodes
        type: conditional_node
        repeat: expr
        repeat-expr: num_nodes

  conditional_node:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/conditional.c#L747 cond_read_node
    seq:
      - id: current_state
        -orig-id: cur_state
        type: u4
      - id: num_items
        -orig-id: len
        type: u4
      - id: conditional_node_items
        type: conditional_node_item
        repeat: expr
        repeat-expr: num_items
      - id: true_list
        type: cond_av_list
        if: _root.type_ == policy_types::kernel
      - id: false_list
        type: cond_av_list
        if: _root.type_ == policy_types::kernel
      - id: avtrue_list
        type: avrule_list
        if: _root.type_ != policy_types::kernel
      - id: avfalse_list
        type: avrule_list
        if: _root.type_ != policy_types::kernel
      - id: flags
        type: u4
        if: '_root.type_ != policy_types::kernel and _root.version >= 14'

  conditional_node_item:
    seq:
      - id: expr_type
        type: u4
      - id: boolean
        type: u4

  cond_av_list:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/conditional.c#L696 cond_read_av_list
    seq:
      - id: num_vectors
        -orig-id: len
        type: u4
      - id: access_vectors_old
        type: access_vector_old
        repeat: expr
        repeat-expr: num_vectors
        if: _root.version < 20
      - id: access_vectors
        type: access_vector
        repeat: expr
        repeat-expr: num_vectors
        if: _root.version >= 20

  avrule_list:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3716 avrule_read_list
    seq:
      - id: num_rules
        -orig-id: len
        type: u4
      - id: avrules
        type: avrule
        repeat: expr
        repeat-expr: num_rules
  
  avrule:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3510 avrule_read
    seq:
      - id: specified
        type: u4
      - id: flags
        type: u4
      - id: stypes
        type: type_set
      - id: ttypes
        type: type_set
      - id: num_items
        -orig-id: len
        type: u4
      - id: avrule_items
        type: avrule_item
        repeat: expr
        repeat-expr: num_items
      - id: avrule_specified
        type: avrule_specified
        if: '(specified & (0x0100 | 0x0200 | 0x0400 | 0x0800)) != 0'

  avrule_item:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3510 avrule_read
    seq:
      - id: tclass
        type: u4
      - id: data
        type: u4

  avrule_specified:
    seq:
      - id: xperms_specified
        type: u1
      - id: xperms_driver
        type: u1
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: perms
        type: u4
        repeat: expr
        repeat-expr: num_elements
  
  role_trans:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3716 role_trans_read
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: role_trans_items
        type: role_trans_item
        repeat: expr
        repeat-expr: num_elements

  role_trans_item:
    seq:
      - id: role
        type: u4
      - id: type
        type: u4
      - id: new_role
        type: u4
      - id: tclass
        type: u4
        if: '(_root.type_ == policy_types::kernel and _root.version >= 26)'

  role_allow:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L2567 role_allow_read
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: role_allow_items
        type: role_allow_item
        repeat: expr
        repeat-expr: num_elements

  role_allow_item:
    seq:
      - id: role
        type: u4
      - id: new_role
        type: u4

  filename_trans:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L2845 filename_trans_read
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: items_32
        type: filename_trans_item_old
        repeat: expr
        repeat-expr: num_elements
        if: '_root.version < 33'
      - id: items_33
        type: filename_trans_item
        repeat: expr
        repeat-expr: num_elements
        if: '_root.version >= 33'

  filename_trans_item_old:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L2674 filename_trans_read_one_compat
    seq:
      - id: len_name
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: name
        type: str
        size: len_name
      - id: stype
        type: u4
      - id: ttype
        type: u4
      - id: tclass
        type: u4
      - id: otype
        type: u4


  filename_trans_item:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L2756 filename_trans_read_one
    seq:
      - id: len_name
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: name
        type: str
        size: len_name
      - id: ttype
        type: u4
      - id: tclass
        type: u4
      - id: num_items
        -orig-id: ndatum
        type: u4
        valid:
          min: 1
      - id: items
        type: filename_trans_item_item
        repeat: expr
        repeat-expr: num_items

  filename_trans_item_item:
    seq:
      - id: stypes
        type: extensible_bitmap
      - id: otype
        type: u4

  avrule_block:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L4030 avrule_block_read
    seq:
      - id: num_blocks
        type: u4
      - id: avrule_block_items
        type: avrule_block_item
        repeat: expr
        repeat-expr: num_blocks

  avrule_block_item:
    seq:
      - id: num_decls
        type: u4
      - id: curdecl
        type: avrule_decl
        repeat: expr
        repeat-expr: num_decls
  
  avrule_decl:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3980 avrule_decl_read
    seq:
      - id: decl_id
        type: u4
      - id: enabled
        type: u4
      - id: cond_list
        type: conditional_list
      - id: avrules
        type: avrule_list
      - id: role_tr_rules
        type: role_trans_rule
      - id: role_allow_rules
        type: role_allow_rule

      - id: filename_trans_rules
        type: filename_trans_rule
        if: _root.version >= 11
      - id: range_tr_rules
        type: range_trans_rule
        if: _root.version >= 6
      - id: required
        type: scope_index
      - id: declared
        type: scope_index
      - id: symbols
        type: symbols

  role_trans_rule:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3749 role_trans_rule_read
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: items
        type: role_trans_rule_item
        repeat: expr
        repeat-expr: num_elements

  role_trans_rule_item:
    seq:
      - id: roles
        type: role_set
      - id: types
        type: role_set
      - id: classes
        type: extensible_bitmap
        if: _root.version >= 12
      - id: new_role
        type: u4

  role_allow_rule:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3801 role_allow_rule_read
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: role_allow_rule_items
        type: common
        repeat: expr
        repeat-expr: num_elements

  role_allow_rule_item:
    seq:
    - id: roles
      type: role_set
    - id: new_roles
      type: role_set

  filename_trans_rule:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3837 filename_trans_rule_read
    seq:
      - id: num_items
        type: u4
      - id: items
        type: filename_trans_rule_item
        repeat: expr
        repeat-expr: num_items

  filename_trans_rule_item:
    seq:
      - id: len_name
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: name
        type: str
        size: len_name
      - id: stypes
        type: type_set
      - id: ttypes
        type: type_set
      - id: tclass
        type: u4
      - id: otype
        type: u4
      - id: flags
        type: u4
        if: _root.version >= 21


  range_trans_rule:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3903 range_trans_rule_read
    seq:
      - id: num_items
        -orig-id: nel
        type: u4
      - id: items
        type: range_trans_rule_item
        repeat: expr
        repeat-expr: num_items

  range_trans_rule_item:
    seq:
      - id: stypes
        type: type_set
      - id: ttypes
        type: type_set
      - id: tclasses
        type: extensible_bitmap
      - id: trange
        type: mls_semantic_range

  scope_index:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3945 scope_index_read
    seq:
      - id: scopes
        type: extensible_bitmap
        repeat: expr
        repeat-expr: _root.num_symbols
      - id: num_maps
        type: u4
        valid:
          min: 0
      - id: class_perms_maps
        type: extensible_bitmap
        repeat: expr
        repeat-expr: num_maps

  scope_list:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: scopes
        type: scope
        repeat: expr
        repeat-expr: num_elements

  scope:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L4108 scope_read
    seq:
      - id: len_key
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: key
        type: str
        size: len_key
      - id: scope
        type: u4
      - id: num_ids
        -orig-id: decl_ids_len
        type: u4
        valid:
          min: 1
      - id: decl_ids
        type: u4
        repeat: expr
        repeat-expr: num_ids

  ocontext_selinux:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L2983 ocontext_read_selinux
    seq:
      - id: initial_sids
        type: initial_sids
        if: '_root.object_contexts_count >= 1'
      - id: filesystems
        type: filesystems
        if: '_root.object_contexts_count >= 2'
      - id: ports
        type: ports
        if: '_root.object_contexts_count >= 3'
      - id: network_interfaces
        type: filesystems # same
        if: '_root.object_contexts_count >= 4'
      - id: nodes
        type: nodes
        if: '_root.object_contexts_count >= 5'
      - id: fsuses
        type: fsuses
        if: '_root.object_contexts_count >= 6'
      - id: nodes6
        type: nodes6
        if: '_root.object_contexts_count >= 7'
      - id: ibpkeys
        type: ibpkeys
        if: '_root.object_contexts_count >= 8'
      - id: ibpendports
        type: ibpendports
        if: '_root.object_contexts_count >= 9'

  initial_sids:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: initial_sids
        type: initial_sid
        repeat: expr
        repeat-expr: num_elements

  initial_sid:
    seq:
      - id: sid0
        type: u4
      - id: context0
        type: context

  filesystems:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: filesystems
        type: filesystem
        repeat: expr
        repeat-expr: num_elements

  filesystem:
    seq:
      - id: len_key
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: key
        type: str
        size: len_key
      - id: context0
        type: context
      - id: context1
        type: context

  ports:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: ports
        type: port
        repeat: expr
        repeat-expr: num_elements

  port:
    seq:
      - id: protocol
        type: u4
      - id: low_port
        type: u4
      - id: high_port
        type: u4
      - id: context
        type: context

  nodes:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: nodes
        type: node
        repeat: expr
        repeat-expr: num_elements

  node:
    seq:
      - id: addr
        type: u4
      - id: mask
        type: u4
      - id: context
        type: context

  fsuses:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: fsuses
        type: fsuse
        repeat: expr
        repeat-expr: num_elements

  fsuse:
    seq:
      - id: behavior
        type: u4
      - id: len_name
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: name
        type: str
        size: len_name
      - id: context
        type: context

  nodes6:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: nodes6
        type: node6
        repeat: expr
        repeat-expr: num_elements

  node6:
    seq:
      - id: addresses
        -orig-id: addr
        type: u4
        repeat: expr
        repeat-expr: 4
      - id: masks
        -orig-id: mask
        type: u4
        repeat: expr
        repeat-expr: 4
      - id: context
        type: context

  ibpkeys:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: ibpkeys
        type: ibpkey
        repeat: expr
        repeat-expr: num_elements

  ibpkey:
    seq:
      - id: low_pkey
        type: u4
      - id: high_pkey
        type: u4
      - id: context
        type: context

  ibpendports:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: ibpendports
        type: ibpendport
        repeat: expr
        repeat-expr: num_elements

  ibpendport:
    seq:
      - id: len_name
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: port
        type: u4
      - id: name
        -orig-id: dev_name
        type: str
        size: len_name
      - id: context
        type: context


  ocontext_xen:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L2872 ocontext_read_xen
    seq:
      - id: xen_isids
        type: xen_isids
        if: '_root.object_contexts_count >= 1'
      - id: xen_pirqs
        type: xen_pirqs
        if: '_root.object_contexts_count >= 2'
      - id: xen_ioports
        type: xen_ioports
        if: '_root.object_contexts_count >= 3'
      - id: xen_iomems
        type: xen_iomems
        if: '_root.object_contexts_count >= 4'
      - id: xen_pcidevices
        type: xen_pcidevices
        if: '_root.object_contexts_count >= 5'
      - id: xen_devicetrees
        type: xen_devicetrees
        if: '_root.object_contexts_count >= 6'

  xen_isids:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: xen_isids
        type: xen_isid
        repeat: expr
        repeat-expr: num_elements

  xen_isid:
    seq:
      - id: sid0
        type: u4
      - id: context0
        type: context
  
  xen_pirqs:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: xen_pirqs
        type: xen_pirq
        repeat: expr
        repeat-expr: num_elements

  xen_pirq:
    seq:
      - id: pirq
        type: u4
      - id: context0
        type: context

  xen_ioports:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: xen_ioports
        type: xen_ioport
        repeat: expr
        repeat-expr: num_elements

  xen_ioport:
    seq:
      - id: low_port
        type: u4
      - id: high_port
        type: u4
      - id: context0
        type: context

  xen_iomems:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: xen_iomems
        type: xen_iomem
        repeat: expr
        repeat-expr: num_elements

  xen_iomem:
    seq:
      - id: low_iomem64
        type: u8
        if: '_root.version >= 30'
      - id: high_iomem64
        type: u8
        if: '_root.version >= 30'
      - id: low_iomem32
        type: u4
        if: '_root.version < 30'
      - id: high_iomem32
        type: u4
        if: '_root.version < 30'
      - id: context0
        type: context

  xen_pcidevices:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: xen_pcidevices
        type: xen_pcidevice
        repeat: expr
        repeat-expr: num_elements

  xen_pcidevice:
    seq:
      - id: device
        type: u4
      - id: context0
        type: context


  xen_devicetrees:
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: xen_devicetrees
        type: xen_devicetree
        repeat: expr
        repeat-expr: num_elements

  xen_devicetree:
    seq:
      - id: len_name
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: name
        type: str
        size: len_name
      - id: context0
        type: context

  genfs:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.c#L3180 genfs_read
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: items
        type: genfs_item
        repeat: expr
        repeat-expr: num_elements

  genfs_item:
    seq:
      - id: len_fstype
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: fstype
        type: str
        size: len_fstype
      - id: num_elements
        -orig-id: nel2
        type: u4
      - id: items
        type: genfs2_item
        repeat: expr
        repeat-expr: num_elements

  genfs2_item:
    seq:
      - id: len_name
        -orig-id: len
        type: u4
        valid:
          min: 1
      - id: name
        type: str
        size: len_name
      - id: sclass
        type: u4
      - id: context0
        type: context

  range:
    doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019e/libsepol/src/policydb.#L3620 range_read
    seq:
      - id: num_elements
        -orig-id: nel
        type: u4
      - id: items
        type: range_item
        repeat: expr
        repeat-expr: num_elements

  range_item:
    seq:
      - id: source_type
        type: u4
      - id: target_type
        type: u4
      - id: target_class
        type: u4
        if: '_root.type_ == policy_types::kernel and _root.version >= 21'
      - id: range_tr
        type: mls_range
