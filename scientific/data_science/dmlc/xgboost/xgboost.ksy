meta:
  id: xgboost
  title: xgboost model
  application: xgboost
  license: Apache-2.0
  endian: le # in fact machine-endian
  encoding: ascii
  imports:
    - ../core/pas_str
    - ../core/str_pair_arr
    - ../core/str_arr
    - ./tree_booster
    - ./linear_booster
  -orig-id: Learner
doc: It is an xgboost tree model.
doc-ref:
  - https://github.com/dmlc/xgboost/blob/98d6faefd629050dc4c0347b8373a989d06a3864/src/learner.cc#L831-L1076
  - https://github.com/dmitryikh/leaves
seq:
  - id: binf_signature
    size: 4
    type: str
    # no validation, there are complications, also unneeded de-facto, since it is an optional element
    if: binf_signature_present
  - id: param
    -orig-id: mparam
    type: model_param
    doc: model parameter
  - id: name_obj_
    type: pas_str
    doc: name of objective function
  - id: name_gbm_
    type: pas_str
    doc: name of objective gbm
  - id: gbm_
    doc: The gradient booster used by the model
    type:
      switch-on: name_gbm_.str
      cases:
        '"gblinear"': linear_booster
        _: tree_booster
  - id: attributes_
    type: str_pair_arr
    if: param.contain_extra_attrs != 0
  - id: max_delta_step_str
    type: pas_str
    if: name_obj_.str == "count:poisson"
  - id: metrics_
    type: str_arr
    doc: The evaluation metrics used to evaluate the model.
    if: param.contain_eval_metrics != 0
instances:
  binf_signature_present:
    value: optional_binf_signature[0] == 0x62 and optional_binf_signature[1] ==  0x69 and optional_binf_signature[2] == 0x6e and optional_binf_signature[3] == 0x66
  optional_binf_signature:
    -orig-id: header
    pos: 0
    size: 4
  max_delta_step:
    value: max_delta_step_str.str.to_i
    doc: |
      maximum delta update we can add in weight estimation
      this parameter can be used to stabilize update
      default=0 means no constraint on weight delta
    doc-ref: param.h
    if: name_obj_.str == "count:poisson"
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
  model_param:
    -orig-id: LearnerModelParamLegacy
    doc: training parameter for regression
    doc-ref:
      - https://github.com/dmlc/xgboost/blob/98d6faefd629050dc4c0347b8373a989d06a3864/src/learner.cc#L78-L94
      - https://github.com/dmlc/xgboost/blob/98d6faefd629050dc4c0347b8373a989d06a3864/src/learner.cc#L162-L177
    seq:
      - id: base_score
        type: f4
        doc: |
          Global bias of the model.
          global bias
          default: 0.5
      - id: num_feature
        type: u4
        doc: |
          Number of features in training data, this parameter will be automatically detected by learner.
          number of features
          default: 0
      - id: num_class
        type: u4
        doc: |
          Number of class option for multi-class classifier. By default equals 0 and corresponds to binary classifier.
          number of classes, if it is multi-class classification
          default: 0
          lower bound: 0
      - id: contain_extra_attrs
        type: u4
        doc: Model contain additional properties
      - id: contain_eval_metrics
        type: u4
        doc: Model contain eval metrics
      - id: xgboost_version
        -orig-id: major_version, minor_version
        type: version
      - id: num_target
        type: u4
        doc: |
          Number of target for multi-target regression.
          default: 1
          lower bound: 1
      - id: reserved
        type: reserved
        size: 26*4
        doc: reserved field
    types:
      version:
        seq:
          - id: major
            -orig-id: major_version
            type: u4
          - id: minor
            -orig-id: minor_version
            type: u4
