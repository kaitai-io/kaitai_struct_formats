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
doc-ref: https://github.com/dmlc/xgboost/blob/master/src/learner.cc#L268L354
seq:
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
        contents: [0]
        repeat: eos
  model_param:
    doc: training parameter for regression
    doc-ref: https://github.com/dmlc/xgboost/blob/master/src/learner.cc#L38L70
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
      - id: reserved
        type: reserved
        size: 29*4
        doc: reserved field
