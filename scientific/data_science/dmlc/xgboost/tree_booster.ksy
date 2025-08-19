meta:
  id: tree_booster
  title: xgboost tree booster
  application: xgboost
  license: Apache-2.0
  endian: le # in fact machine-endian
  encoding: ascii
  imports:
    - ../core/pas_str
    - ../core/str_pair_arr
    - ../core/f4_arr
    - ../core/str_arr
  -orig-id: GBTreeModel
doc: Gradient boosting tree ensembles
doc-ref:
  - https://github.com/dmlc/xgboost/blob/3c9b04460a2e8aaec7a3aff494b3bcb9ff6a8b70/src/gbm/gbtree_model.h#L118-L124
  - https://github.com/dmlc/xgboost/blob/81210420c68334300a7f13a07cbaea269f917478/src/gbm/gbtree_model.cc#L13-L64
seq:
  - id: param
    type: param
  - id: trees
    type: reg_tree
    repeat: expr
    repeat-expr: param.num_trees
    doc: vector of trees stored in the model
  - id: trees_infos
    type: u4
    repeat: expr
    repeat-expr: param.num_trees
    doc: some information indicator of the tree, reserved
types:
  reserved:
    seq:
      - id: zero
        type: zero_fill
        repeat: eos
    types:
      zero_fill:
        seq:
          - id: zero
            contents: [0]
  placeholder:
    doc: needed only to have _io
    seq:
      - size-eos: true
  param:
    -orig-id: GBTreeModelParam
    doc: model parameters
    doc-ref: https://github.com/dmlc/xgboost/blob/master/src/gbm/gbtree_model.h#L15L60
    seq:
      - id: num_trees
        type: u4
        doc: number of trees
      - id: num_roots
        type: u4
        doc: |
          Tree updater sequence
          number of roots
          lower_bound: 1
          default : 1
      - id: num_feature
        type: u4
        doc: |
          Number of features used for training and prediction.
          number of features to be used by trees
          lower_bound: 0
      - id: pad_32bit
        type: u4
        doc: pad this space, for backward compatibility reason.
      - id: num_pbuffer_deprecated
        type: u8
        doc: deprecated padding space.
      - id: num_output_group
        type: u4
        doc: |
          Number of output groups to be predicted, used for multi-class classification.
          How many output group a single instance can produce.
          This affects the behavior of number of output we have: suppose we have n instance and k group, output will be k * n.
          lower_bound: 1
          default : 1
      - id: size_leaf_vector
        type: u4
        doc: |
          Reserved option for vector tree
          lower_bound: 0
          default : 0
      - id: reserved
        type: reserved
        size: 32*4
  reg_tree:
    doc: |
      define regression tree to be the most common tree model.
      This is the data structure used in xgboost's major tree models.
    doc-ref: https://github.com/dmlc/xgboost/blob/master/include/xgboost/tree_model.h#L308L343
    -orig-id: "class RegTree: public TreeModel<bst_float, RTreeNodeStat>"
    seq:
      - id: param
        type: param
      - id: nodes
        type: node
        repeat: expr
        repeat-expr: param.num_nodes
      - id: stats
        type: node_stat
        repeat: expr
        repeat-expr: param.num_nodes
      - id: leaf_vector
        type: f4_arr
        size: param.num_nodes * param.size_leaf_vector+8
        if: param.size_leaf_vector != 0
    types:
      node_stat:
        -orig-id: RTreeNodeStat
        doc: node statistics used in regression tree
        doc-ref: https://github.com/dmlc/xgboost/blob/master/include/xgboost/tree_model.h#L404L413
        seq:
          - id: loss_chg
            type: f4
            doc: loss change caused by current split
          - id: sum_hess
            type: f4
            doc: sum of hessian values, used to measure coverage of data
          - id: base_weight
            type: f4
            doc: weight of current node
          - id: leaf_child_cnt
            type: u4
            doc: number of child that is leaf node known up to now
      feature_vector:
        -orig-id: FVec
        doc: dense feature vector that can be taken by RegTree and can be construct from sparse feature vector.
        doc-ref: https://github.com/dmlc/xgboost/blob/master/include/xgboost/tree_model.h#L439L484
        seq:
          - id: data
            type: entry
            repeat: eos
        types:
          entry:
            seq:
              - id: placeholder
                type: placeholder
                size: 4
            instances:
              fvalue:
                pos: 0
                io: placeholder._io
                type: f4
              flag:
                pos: 0
                io: placeholder._io
                type: u4
      param:
        doc-ref: https://github.com/dmlc/xgboost/blob/master/include/xgboost/tree_model.h#L26L63
        -orig-id: TreeParam
        doc: model parameters
        seq:
          - id: num_roots
            type: u4
            doc: |
              Number of start root of trees.
              number of start root
              lower_bound: 1
              default: 1
          - id: num_nodes
            type: u4
            doc: total number of nodes
          - id: num_deleted
            type: u4
            doc: number of deleted nodes
          - id: max_depth
            type: u4
            doc: maximum depth, this is a statistics of the tree
          - id: num_feature
            type: u4
            doc: |
              Number of features used in tree construction.
              number of features used for tree construction
          - id: size_leaf_vector
            type: u4
            doc: |
              Size of leaf vector, reserved for vector tree
              leaf vector size, used for vector tree used to store more than one dimensional information in tree
              lower_bound: 0
              default: 0
          - id: reserved
            #type: reserved
            size: 31*4
            doc: reserved part, make sure alignment works for 64bit
      node:
        doc: tree node
        doc-ref: https://github.com/dmlc/xgboost/blob/master/include/xgboost/tree_model.h#L78L192
        seq:
          - id: parent_packed
            -orig-id: parent_
            type: u4
            doc: |
              pointer to parent, highest bit is used to indicate whether it's a left child or not
              name `parent_` cannot be used, incompatible to JS target
          - id: cleft_
            type: u4
            doc: pointer to left
          - id: cright_
            type: u4
            doc: spointer to right
          - id: sindex_
            type: u4
            doc: split feature index, left split or right split depends on the highest bit
          - id: info_
            type: f4
            -orig-id: Info info_
            doc: |
              extra info
              in leaf node, we have weights, in non-leaf nodes, we have split condition
        instances:
          right:
            value: _parent.as<reg_tree>.nodes[cright_]
            if: not is_leaf
          left:
            value: _parent.as<reg_tree>.nodes[cleft_]
            if: not is_leaf
          leaf_value:
            value: info_
            if: is_leaf
          split_cond:
            value: info_
            if: not is_leaf
          is_root:
            doc: whether current node is root
            value: parent_packed == 0xffffffff
          parent:
            doc: get parent of the node
            value: parent_packed & 0x7fffffff
          is_deleted:
            doc: whether this node is deleted
            value: sindex_ == 0xffffffff
          is_left_child:
            doc: whether current node is left child
            value: parent_packed & 0x80000000 != 0
          split_index:
            doc: feature index of split condition
            value: sindex_ & 0x7fffffff
          default_left:
            doc: when feature is unknown, whether goes to left child
            value: sindex_ & 0x80000000 != 0
          is_leaf:
            doc: whether current node is leaf node
            value: cleft_  == 0xffffffff
