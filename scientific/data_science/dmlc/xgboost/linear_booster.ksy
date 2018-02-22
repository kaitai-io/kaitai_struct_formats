meta:
  id: linear_booster
  title: xgboost linear booster
  application: xgboost
  license: Apache-2.0
  endian: le # in fact machine-endian
  encoding: ascii
  imports:
    - ../core/pas_str
    - ../core/f4_arr
  -orig-id: GBLinearModel
doc: gradient boosted linear model
doc-ref:
  - https://github.com/dmlc/xgboost/blob/ca3da55de47bfe693b50dd9000c4c84a1cc90180/src/gbm/gblinear_model.h#L72-L80
  - https://github.com/dmlc/xgboost/blob/a1bcd33a3b74f2e80b870c8f4d4f13e94375a8e4/src/gbm/gblinear_model.cc#L13-L45

seq:
  - id: param
    type: param
  - id: weight
    type: f4_arr
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
  param:
    -orig-id: GBLinearModelParam
    doc: model parameter
    doc-ref: https://github.com/dmlc/xgboost/blob/master/src/gbm/gblinear_model.h#L15L33
    seq:
      - id: num_feature
        type: u4
        doc: |
          Number of features used in classification.
          lower bound: 0
          default: 0
      - id: num_output_group
        type: u4
        doc: |
          Number of output groups in the setting.
          lower bound: 1
          default: 1
      - id: reserved
        type: reserved
        size: 32*4
  train_param:
    doc-ref: https://github.com/dmlc/xgboost/blob/master/src/gbm/gblinear.cc#L25L46
    -orig-id: GBLinearTrainParam
    seq:
      - id: updater
        type: pas_str
        doc: |
          Update algorithm for linear model. One of shotgun/coord_descent
          default: "shotgun"
      - id: debug_verbose
        type: s4
        doc: |
          flag to print out detailed breakdown of runtime
          lower bound: 0
          default: 0
      - id: tolerance
        type: f4
        doc: |
          Stop if largest weight update is smaller than this number.
          lower bound: 0.0f
          default: 0.0f
