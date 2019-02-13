meta:
  id: dted
  title: DIGITAL TERRAIN ELEVATION DATA (DTED)
  file-extension:
    - dt0
    - dt1
    - dt2
  endian: be
  ks-version: 0.8
doc-ref: |
  https://dds.cr.usgs.gov/srtm/version2_1/Documentation/MIL-PDF-89020B.pdf
doc: |
  PERFORMANCE SPECIFICATION DIGITAL TERRAIN ELEVATION DATA (DTED). |
  MIL-PRF-89020B (23 May 2000)
seq:
  - id: uhl
    type: uhl_header
  - id: dsi
    type: dsi_header
  - id: acc
    type: acc_header
  - id: records
    type: data_record
    repeat: expr
    repeat-expr: uhl.number_of_longitude_lines.value
types:
  uhl_header:
    seq:
      - id: recognition_sentinel
        contents: UHL
      - id: fixed_by_standard
        contents: "1"
      - id: longitude_of_origin
        type: angle_dddmmssh
      - id: latitude_of_origin
        type: angle_dddmmssh
      - id: longitude_interval_seconds
        type: ascii_int_ssss
      - id: latitude_interval_seconds
        type: ascii_int_ssss
      - id: absolute_vertical_accuracy
        type: str
        size: 4
        encoding: ASCII
      - id: security_code
        type: str
        size: 3
        encoding: ASCII
      - id: unique_reference
        type: str
        size: 12
        encoding: ASCII
      - id: number_of_longitude_lines
        type: ascii_int_ssss
      - id: number_of_latitude_points
        type: ascii_int_ssss
      - id: multiple_accuracy
        type: str
        size: 1
        encoding: ASCII
      - id: reserved
        type: str
        size: 24
        encoding: ASCII
  dsi_header:
    seq:
      - id: recognition_sentinel
        contents: DSI
      - id: security_classification_code
        type: u1
        enum: security_classification_enum
      - id: security_control_and_release_markings
        type: str
        size: 2
        encoding: ASCII
      - id: security_handling_description
        type: str
        size: 27
        encoding: ASCII
      - id: reserved_for_future_use1
        type: str
        size: 26
        encoding: ASCII
      - id: nima_series_designator_for_product_level
        type: str
        size: 5
        encoding: ASCII
      - id: unique_reference_number
        type: str
        size: 15
        encoding: ASCII
      - id: reserved_for_future_use2
        type: str
        size: 8
        encoding: ASCII
      - id: data_edition_number
        type: str
        size: 2
        encoding: ASCII
      - id: match_merge_version
        type: str
        size: 1
        encoding: ASCII
      - id: maintenance_date
        type: date_yymm
      - id: match_merge_date
        type: date_yymm
      - id: maintenance_description
        type: str
        size: 4
        encoding: ASCII
      - id: producer_code
        type: str
        size: 8
        encoding: ASCII
      - id: reserved_for_future_use3
        type: str
        size: 16
        encoding: ASCII
      - id: product_specification
        type: str
        size: 9
        encoding: ASCII
      - id:  product_specification_amendment_number
        type: str
        size: 1
        encoding: ASCII
      - id:  product_specification_change_number
        type: str
        size: 1
        encoding: ASCII
      - id:  product_specification_date
        type: date_yymm
      - id:  vertical_datum
        type: str
        size: 3
        encoding: ASCII
      - id:  horizontal_datum_code
        type: str
        size: 5
        encoding: ASCII
      - id:  digitizing_collection_system
        type: str
        size: 10
        encoding: ASCII
      - id:  compilation_date
        type: date_yymm
      - id:  reserved_for_future_use4
        type: str
        size: 22
        encoding: ASCII
      - id:  origin_of_data
        type: coordinate_pair_ddmmss_sh
      - id:  sw_corner_of_data
        type: coordinate_pair_ddmmssh
      - id:  nw_corner_of_data
        type: coordinate_pair_ddmmssh
      - id:  ne_corner_of_data
        type: coordinate_pair_ddmmssh
      - id:  se_corner_of_data
        type: coordinate_pair_ddmmssh
      - id:  clockwise_orientation_angle
        type: angle_dddmmss_sh
      - id:  latitude_interval
        type: ascii_int_ssss
      - id:  longitude_interval
        type: ascii_int_ssss
      - id:  number_of_latitude_lines
        type: ascii_int_ssss
      - id:  number_of_longitude_lines
        type: ascii_int_ssss
      - id:  partial_cell_indicator
        type: str
        size: 2
        encoding: ASCII
      - id:  reserved_for_nima_use_only
        type: str
        size: 101
        encoding: ASCII
      - id:  reserved_for_producing_nation_use_only
        type: str
        size: 100
        encoding: ASCII
      - id:  reserved_for_free_text_comments
        type: str
        size: 155
        encoding: ASCII
  acc_header:
    seq:
      - id: recognition_sentinel
        contents: ACC
      - id: absolute_horizontal_accuracy
        type: ascii_int_ssss
      - id: absolute_vertical_accuracy
        type: ascii_int_ssss
      - id: relative_horizontal_accuracy_of_product_in_meters
        type: ascii_int_ssss
      - id: relative_vertical_accuracy_or_product_in_meters
        type: ascii_int_ssss
      - id: reserved_for_future_use1
        type: str
        size: 4
        encoding: ASCII
      - id: reserved_for_nima_use_only1
        type: str
        size: 1
        encoding: ASCII
      - id: reserved_for_future_use2
        type: str
        size: 31
        encoding: ASCII
      - id: multiple_accuracy_outline_flag
        type: str
        size: 2
        encoding: ASCII
      - id: subregion
        type: acc_subregion
        repeat: expr
        repeat-expr: 9
      - id: reserved_for_nima_use_only2
        type: str
        size: 18
        encoding: ASCII
      - id: reserved_for_future_use3
        type: str
        size: 69
        encoding: ASCII
  acc_subregion:
    seq:
      - id: absolute_horizontal_accuracy_or_subregion_in_meters
        type: str
        size: 4
        encoding: ASCII
      - id: absolute_vertical_accuracy_or_subregion_in_meters
        type: str
        size: 4
        encoding: ASCII
      - id: relative_horizontal_accuracy_of_subregion_in_meters
        type: str
        size: 4
        encoding: ASCII
      - id: relative_vertical_accuracy_of_subregion_in_meters
        type: str
        size: 4
        encoding: ASCII
      - id: number_of_coordinates_in_accuracy_subregion_outline
        type: str
        size: 2
        encoding: ASCII
      - id: coordinate_pair
        type: coordinate_pair_ddmmss_sh
        repeat: expr
        repeat-expr: 14
  data_record:
    seq:
      - id: recognition_sentinal
        type: u1
      - id: data_block_count
        type: b24
      - id: logitude_count
        type: u2
      - id: latitude_count
        type: u2
      - id: elevations
        type: data_record_elevation
        repeat: expr
        repeat-expr: _parent.uhl.number_of_latitude_points.value
      - id: checksum
        type: s4
  data_record_elevation:
    seq:
      - id: is_negative
        type: b1
      - id: value
        type: b15
    instances:
      meters:
        value: value * (is_negative? -1 : 1)
  ascii_int_ssss:
    seq:
      - id: text
        type: str
        size: 4
        encoding: ASCII
    instances:
      value:
        value: text.to_i
  coordinate_pair_ddmmss_sh:
    seq:
      - id: latitude
        type: angle_ddmmss_sh
      - id: longitude
        type: angle_dddmmss_sh
  coordinate_pair_ddmmssh:
    seq:
      - id: latitude
        type: angle_ddmmssh
      - id: longitude
        type: angle_dddmmssh
  angle_ddmmss_sh:
    seq:
      - id: degrees
        type: str
        size: 2
        encoding: ASCII
      - id: minutes
        type: str
        size: 2
        encoding: ASCII
      - id: seconds
        type: str
        size: 4
        encoding: ASCII
      - id: hemisphere
        type: str
        size: 1
        encoding: ASCII
    instances:
      degree_decimal:
        value: (degrees.to_i + minutes.to_i/60.0 + seconds.to_i/3600.0) * (hemisphere == 'N'? 1 : -1)
  angle_dddmmss_sh:
    seq:
      - id: degrees
        type: str
        size: 3
        encoding: ASCII
      - id: minutes
        type: str
        size: 2
        encoding: ASCII
      - id: seconds
        type: str
        size: 4
        encoding: ASCII
      - id: hemisphere
        type: str
        size: 1
        encoding: ASCII
    instances:
      degree_decimal:
        value: (degrees.to_i + minutes.to_i/60.0 + seconds.to_i/3600.0) * (hemisphere == 'N'? 1 : -1)
  angle_ddmmssh:
    seq:
      - id: degrees
        type: str
        size: 2
        encoding: ASCII
      - id: minutes
        type: str
        size: 2
        encoding: ASCII
      - id: seconds
        type: str
        size: 2
        encoding: ASCII
      - id: hemisphere
        type: str
        size: 1
        encoding: ASCII
    instances:
      degree_decimal:
        value: (degrees.to_i + minutes.to_i/60.0 + seconds.to_i/3600.0) * (hemisphere == 'N'? 1 : -1)
  angle_dddmmssh:
    seq:
      - id: degrees
        type: str
        size: 3
        encoding: ASCII
      - id: minutes
        type: str
        size: 2
        encoding: ASCII
      - id: seconds
        type: str
        size: 2
        encoding: ASCII
      - id: hemisphere
        type: str
        size: 1
        encoding: ASCII
    instances:
      degree_decimal:
        value: (degrees.to_i + minutes.to_i/60.0 + seconds.to_i/3600.0) * (hemisphere == 'N'? 1 : -1)
  date_yymm:
    seq:
      - id: year
        type: str
        size: 2
        encoding: ASCII
      - id: month
        type: str
        size: 2
        encoding: ASCII
enums:
  security_classification_enum:
    83: secrete
    67: confidential
    85: unclassified
    82: restricted