meta:
  id: cntk
  title: Microsoft CogNitive ToolKit Computation NeTworK
  file-extension: model
  xref:
    wikidata: Q23680120
  endian: le
  encoding: UTF-16le
  license: MIT

doc: |
  A native CNTK format for serialization of a computation graph. These graphs are usually used to store machine-learning models, like neural networks and gradient boosted decision trees ensembles.
  The list of pretrained models is here: https://github.com/Microsoft/CNTK/blob/master/PretrainedModels/download_model.py
  Only some of them have this format.

doc-ref:
  - https://github.com/Microsoft/CNTK

seq:
  - id: network
    type: section_hardcode("CN")
types:
  vector_bool:
    seq:
      - id: count
        type: u8
      - id: values
        type: u1
  begin_marker:
    seq:
      - id: begin
        contents: ["B", 0]
      - id: name
        type: strz
        #terminator: [0, 0]
        #consume: true
  begin_marker_hardcode:
    params:
      - id: name
        type: str
    seq:
      - id: begin
        contents: ["B", 0]
      - id: marker
        contents: [name]
      - id: terminator
        contents: [0,0]
  end_marker:
    params:
      - id: name
        type: str
    seq:
      - id: end
        contents: ["E", 0]
      - id: marker
        contents: [name]
      - id: terminator
        contents: [0,0]
  section_contents:
    params:
      - id: section_name
        type: str
    seq:
      - id: contents
        parent: _parent._parent
        type:
          switch-on: section_name
          cases:
            "'CN'": computation_network
            "'Version'": version
            "'NodeList'": node_list
            "'Relation'": relation
            "'BMAT'": matrix
            "'RootNodes'": root_nodes
            "'FeatureNodes'": nodes_names
            "'LabelNodes'": nodes_names
            "'CriterionNodes'": nodes_names
            "'EvalNodes'": nodes_names
            "'OutputNodes'": nodes_names
    types:
      matrix:
        seq:
          - id: element_size
            -orig-id: elsize
            type: u8
          - id: name
            type: strz
          - id: format
            -orig-id: m_format
            type: format
          - id: rows
            -orig-id: numRows
            type: u8
          - id: cols
            -orig-id: numCols
            type: u8
          - id: data
            size: cols*rows*element_size
        types:
          format:
            seq:
              - id: reserved0
                type: b3
              - id: set_value_on_device
                type: b1
                -orig-id: bitPosSetValueOnDevice
                doc: in a setValue situation, the copy from buffer is already on the device
              - id: dont_own_buffer
                type: b1
                -orig-id: bitPosDontOwnBuffer
                doc: buffer is not owned by this matrix
              - id: compressed
                type: b1
                -orig-id: bitPosCompressed
                doc: a compressed sparse format (CSC/CSR)
              - id: sparse
                type: b1
                -orig-id: bitPosSparse
                doc: sparse matrix (COO if uncompressed)
              - id: row_major
                type: b1
                -orig-id: bitPosRowMajor
                doc: row major matrix
              - id: reserved1
                type: b24
      tensor_shape:
        seq:
          - id: rank
            type: u4
          - id: dims
            type: u4
            repeat: expr
            repeat-expr: real_rank
        instances:
          real_rank:
            value: "((rank>0) ? rank : 1)"
      version:
        seq:
          - id: major
            type: u4
          - id: reserved
            type: u4
      computation_network:
        seq:
          - id: version_
            -orig-id: Version
            type: section_hardcode("Version")
            doc: ""
          - id: node_count
            -orig-id: numNodes
            type: u8
            doc: ""
          - id: node_list
            -orig-id: NodeList
            type: section_hardcode("NodeList")
            doc: ""
          - id: relation
            -orig-id: Relation
            type: section_hardcode("Relation")
            doc: ""
          - id: root_nodes
            -orig-id: RootNodes
            type: section_hardcode("RootNodes")
            doc: ""
        instances:
          version:
            value: version_.contents.contents.as<version>

      relation:
        seq:
          - id: relations
            type: relation
            repeat: expr
            repeat-expr: "_parent.as<computation_network>.node_count" #section_contents->section->parent
        types:
          relation:
            seq:
              - id: name
                type: strz
                -orig-id: nodePtr->NodeName()
                
              - id: inputs_count
                -orig-id: nodePtr->GetNumInputs()
                type: u8

              - id: inputs
                type: strz
                repeat: expr
                repeat-expr: inputs_count
                doc: name of input node
      root_nodes:
        seq:
          - id: feature
            -orig-id: m_featureNodes
            type: section_hardcode("FeatureNodes")
            doc: ""
          - id: label
            -orig-id: 
            type: section_hardcode("LabelNodes")
            doc: ""
          - id: criterion
            -orig-id: 
            type: section_hardcode("CriterionNodes")
            doc: ""
          - id: eval
            -orig-id: 
            type: section_hardcode("EvalNodes")
            doc: ""
          - id: output
            -orig-id: 
            type: section_hardcode("OutputNodes")
            doc: ""
      nodes_names:
        seq:
          - id: count
            type: u8
          - id: names
            type: strz
            repeat: expr
            repeat-expr: count
      node_list:
        seq:
          - id: nodes
            -orig-id: m_nameToNodeMap
            type: node
            repeat: expr
            repeat-expr: "_parent.as<computation_network>.node_count"
        types:
          node:
            seq:
              - id: precision
                type: strz
                doc: |
                  "float", "double", "half", ""
              - id: operation_name
                -orig-id: OperationName
                type: strz
              - id: node_name
                -orig-id: NodeName
                type: strz
              - id: node_specific
                type:
                  switch-on: node_name
                  cases:
                    '"AveragePoolingNode"': node_generic
                    '"BatchNormalizationNode"': node_generic
                    '"ClassificationErrorNode"': classification_error
                    '"ErrorPrediction"': classification_error
                    '"ClipNode"': node_generic
                    '"ConvolutionNode"': convolution
                    '"CosDistanceNode"': node_generic
                    '"CosDistanceWithNegativeSamplesNode"': node_generic
                    '"CoshNode"': node_generic
                    '"CosineNode"': node_generic
                    '"CropNode"': node_generic
                    '"CrossEntropyNode"': node_generic
                    '"CrossEntropyWithSoftmaxNode"': node_generic
                    '"ForwardBackwardNode"': node_generic
                    '"DiagonalNode"': node_generic
                    '"DiagTimesNode"': node_generic
                    '"DropoutNode"': node_generic
                    '"DummyCriterionNode"': node_generic
                    '"DynamicAxisNode"': node_generic
                    '"EditDistanceErrorNode"': node_generic
                    '"AcosNode"': node_generic
                    '"AsinNode"': node_generic
                    '"ElementTimesNode"': element_times
                    '"ColumnElementTimes"': element_times
                    '"RowElementTimes"': element_times
                    '"Scale"': element_times
                    '"EnvironmentInputNode"': node_generic
                    '"EpochAccumulatorNode"': node_generic
                    '"EqualNode"': node_generic
                    '"ExpNode"': node_generic
                    '"FloorNode"': node_generic
                    '"FutureValueNode"': node_generic
                    '"GatherPackedNode"': node_generic
                    '"GMMLogLikelihoodNode"': node_generic
                    '"GreaterEqualNode"': node_generic
                    '"GreaterNode"': node_generic
                    '"HardmaxNode"': node_generic
                    '"IfNode"': node_generic
                    '"InputValue"': input_value
                    '"InvStdDevNode"': node_generic
                    '"LambdaRankNode"': node_generic
                    '"NDCG1EvalNode"': node_generic
                    '"KhatriRaoProductNode"': node_generic
                    '"LearnableParameter"': node_generic
                    '"LessEqualNode"': node_generic
                    '"LessNode"': node_generic
                    '"LogNode"': node_generic
                    '"LogPlusNode"': node_generic
                    '"LogSoftmaxNode"': node_generic
                    '"LookupTableNode"': node_generic
                    '"MatrixL1RegNode"': node_generic
                    '"MatrixL2RegNode"': node_generic
                    '"MaxPoolingNode"': node_generic
                    '"MeanNode"': node_generic
                    '"MinusNode"': node_generic
                    '"NegateNode"': node_generic
                    '"NotEqualNode"': node_generic
                    '"NoiseContrastiveEstimationNode"': node_generic
                    '"OptimizedRNNStackNode"': optimized_rnn_stack
                    '"RNN"': optimized_rnn_stack
                    '"PackedIndexNode"': node_generic
                    '"PastValueNode"': past_value
                    '"Delay"': past_value
                    '"PerDimMeanVarNormalizationNode"': node_generic
                    '"PerDimMeanVarDeNormalizationNode"': node_generic
                    '"PassNode"': node_generic
                    '"LabelsToGraphNode"': node_generic
                    '"PlusNode"': node_generic
                    '"PoolingNode"': pooling
                    '"RandomSampleNode"': node_generic
                    '"RandomSampleInclusionFrequencyNode"': node_generic
                    '"ReconcileDynamicAxisNode"': reconcile_dynamic_axis
                    '"ReconcileMBLayout"': reconcile_dynamic_axis
                    '"ReciprocalNode"': node_generic
                    '"RectifiedLinearNode"': node_generic
                    '"ReduceElementsNode"': node_generic
                    '"ReshapeNode"': node_generic
                    '"ROIPoolingNode"': roi_pooling
                    '"RowRepeatNode"': node_generic
                    '"RowStackNode"': node_generic
                    '"ScatterPackedNode"': node_generic
                    '"SequenceWithSoftmaxNode"': node_generic
                    '"LatticeSequenceWithSoftmaxNode"': node_generic
                    '"SequenceDecoderNode"': node_generic
                    '"ShiftNode"': node_generic
                    '"SigmoidNode"': node_generic
                    '"StableSigmoidNode"': node_generic
                    '"SinNode"': node_generic
                    '"SinhNode"': node_generic
                    '"SliceNode"': slice
                    '"RowSlice"': slice
                    '"SoftmaxNode"': node_generic
                    '"SparseInputValue"': node_generic
                    '"SqrtNode"': node_generic
                    '"SquareErrorNode"': node_generic
                    '"LogisticNode"': node_generic
                    '"SumColumnElementsNode"': node_generic
                    '"SumElementsNode"': node_generic
                    '"TanhNode"': node_generic
                    '"TraceNode"': node_generic
                    '"TimesNode"': node_generic
                    '"Transpose"': transpose_dimensions
                    '"TransposeDimensionsNode"': transpose_dimensions
                    '"TransposeTimesNode"': node_generic
                    '"QuantizedTimesNode"': node_generic
                    '"WhereNode"': node_generic
                    '"LegacyReshapeNode"': node_generic
                    '"MaxUnpoolingNode"': node_generic
                    '"CRFNode"': node_generic
                    '"AbsNode"': node_generic
                    '"ClassBasedCrossEntropyWithSoftmaxNode"': node_generic
                    '"StopGradientNode"': node_generic
                    '"PerDimMeanVarNormalizationNode"': node_generic
                    '"PerDimMeanVarDeNormalizationNode"': node_generic
            types:
              input_value:
                seq:
                  - id: rows
                    -orig-id: rowsDummy
                    type: u8
                  - id: cols
                    -orig-id: colsDummy
                    type: u8
                  - id: sample_layout
                    -orig-id: m_sampleLayout
                    type: tensor_shape
                  - id: nr_axes
                    -orig-id: nrAxes
                    type: u4
                  - id: dynamic_axis_node_name
                    -orig-id: m_dynamicAxisNodeName
                    type: strz
                  - id: learning_rate_multiplier
                    -orig-id: m_learningRateMultiplier
                    type: f4

              learnable_parameter:
                seq:
                  - id: learning_rate_multiplier
                    -orig-id: m_learningRateMultiplier
                    type: f4
                  - id: sample_layout
                    -orig-id: m_sampleLayout
                    type: tensor_shape
                  - id: value
                    -orig-id: Value()
                    type: section
              node_generic:
                seq: []
              classification_error:
                seq: []
              element_times:
                seq: []
              optimized_rnn_stack:
                seq: []
              past_value:
                seq: []
              slice:
                seq: []
              transpose_dimensions:
                seq: []
              reconcile_dynamic_axis:
                seq: []

              convolution:
                seq:
                  - id: kernel_shape
                    -orig-id: m_kernelShape
                    type: tensor_shape
                    if: (_parent.as<computation_network>.version.major) > 5
                  - id: map_count
                    -orig-id: m_mapCount
                    type: tensor_shape
                    if: _parent.as<computation_network>.version.major > 5
                  - id: stride
                    -orig-id: m_stride
                    type: tensor_shape
                    if: _parent.as<computation_network>.version.major > 5
                  - id: sharing
                    -orig-id: m_sharing
                    type: vector_bool
                    if: _parent.as<computation_network>.version.major > 5
                  - id: auto_pad
                    -orig-id: m_autoPad
                    type: vector_bool
                    if: _parent.as<computation_network>.version.major > 5
                  - id: lower_pad
                    -orig-id: m_lowerPad.Load(fstream);
                    type: tensor_shape
                    if: _parent.as<computation_network>.version.major > 5
                  - id: upper_pad
                    -orig-id: m_upperPad.Load(fstream);
                    type: tensor_shape
                    if: _parent.as<computation_network>.version.major > 5
                  - id: pool_kind
                    -orig-id: m_poolKind
                    type: s4
                    enum: pool_kind
                    if: _parent.as<computation_network>.version.major > 5
                  - id: image_layout
                    -orig-id: m_imageLayout
                    type: s4
                    enum: image_layout_kind
                    if: _parent.as<computation_network>.version.major > 5
                  - id: max_temp_mem_size_in_samples
                    -orig-id: m_maxTempMemSizeInSamples
                    type: s8
                    if: _parent.as<computation_network>.version.major > 5
                  - id: transpose
                    -orig-id: m_transpose
                    type: u1
                    if: _parent.as<computation_network>.version.major > 9
                  - id: output_shape
                    -orig-id: m_outputShape
                    type: tensor_shape
                    if: _parent.as<computation_network>.version.major > 20
                  - id: ceil_out_dim
                    -orig-id: m_ceilOutDim
                    type: u1
                    if: _parent.as<computation_network>.version.major > 21
                  - id: pool_include_pad
                    -orig-id: m_poolIncludePad
                    type: u1
                    if: _parent.as<computation_network>.version.major > 23
              roi_pooling:
                seq:
                  - id: roi_output_shape
                    -orig-id: m_roiOutputShape
                    type: tensor_shape
                  - id: pool_kind
                    -orig-id: m_poolKind
                    type: s4
                    -default: max
                    enum: pool_kind
                    if: _parent.as<computation_network>.version.major > 26
                  - id: spatial_scale
                    -orig-id: m_spatialScale
                    type: s4
                    enum: pool_kind
                    -default: 1.0/16.0
                    if: _parent.as<computation_network>.version.major > 26
              pooling:
                seq:
                  - id: window_width
                    -orig-id: m_windowWidth
                    type: u8
                  - id: image_layout_kind
                    -orig-id: m_imageLayoutKind
                    type: s4
                    enum: image_layout_kind
                  - id: window_height
                    -orig-id: m_windowHeight
                    type: u8
                  - id: horizontal_subsample
                    -orig-id: m_horizontalSubsample
                    type: u8
                  - id: vertical_subsample
                    -orig-id: m_verticalSubsample
                    type: u8
  section:
    seq:
      - id: begin_marker
        type: begin_marker
      - id: contents
        type: section_contents(begin_marker.name)
      - id: end_marker
        type: end_marker(begin_marker.name)
  section_hardcode:
    params:
      - id: name
        type: str
    seq:
      - id: begin_marker
        type: begin_marker_hardcode(name)
      - id: contents
        type: section_contents(begin_marker.name)
      - id: end_marker
        type: end_marker(begin_marker.name)

enums:
  pool_kind:
    0: none
    1: max
    2: average
  image_layout_kind:
    0: hwc # legacy; default for NDL
    1: chw # cudnn; default for BrainScript
