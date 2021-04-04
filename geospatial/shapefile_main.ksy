meta:
  id: shapefile_main
  title: Shapefile main file
  file-extension: shp
  xref:
    loc: fdd000280 # ESRI Shapefile
    pronom: x-fmt/235
    wikidata: Q27486884
  license: CC0-1.0
  endian: le
seq:
  - id: header
    type: file_header
  - id: records
    type: record
    repeat: eos
    doc: the size of this section of the file in bytes must equal (header.file_length * 2) - 100
types:
  file_header:
    seq:
      - id: file_code
        contents: [0x00, 0x00, 0x27, 0x0a]
        doc: corresponds to s4be value of 9994
      - id: unused_field_1
        contents: [0, 0, 0, 0]
      - id: unused_field_2
        contents: [0, 0, 0, 0]
      - id: unused_field_3
        contents: [0, 0, 0, 0]
      - id: unused_field_4
        contents: [0, 0, 0, 0]
      - id: unused_field_5
        contents: [0, 0, 0, 0]
      - id: file_length
        type: s4be
      - id: version
        contents: [0xe8, 0x03, 0x00, 0x00]
        doc: corresponds to s4le value of 1000
      - id: shape_type
        type: s4
        enum: shape_type
      - id: bounding_box
        type: bounding_box_x_y_z_m
  record:
    seq:
      - id: header
        type: record_header
      - id: contents
        type: record_contents
        doc: the size of this contents section in bytes must equal header.content_length * 2
  record_header:
    seq:
      - id: record_number
        type: s4be
      - id: content_length
        type: s4be
  record_contents:
    seq:
      - id: shape_type
        type: s4
        enum: shape_type
      - id: shape_parameters
        type:
          switch-on: shape_type
          cases:
            shape_type::point: point
            shape_type::poly_line: poly_line
            shape_type::polygon: polygon
            shape_type::multi_point: multi_point
            shape_type::point_z: point_z
            shape_type::poly_line_z: poly_line_z
            shape_type::polygon_z: polygon_z
            shape_type::multi_point_z: multi_point_z
            shape_type::point_m: point_m
            shape_type::poly_line_m: poly_line_m
            shape_type::polygon_m: polygon_m
            shape_type::multi_point_m: multi_point_m
            shape_type::multi_patch: multi_patch
        if: shape_type != shape_type::null_shape
  bounding_box_x_y_z_m:
    seq:
      - id: x
        type: bounds_min_max
      - id: y
        type: bounds_min_max
      - id: z
        type: bounds_min_max
      - id: m
        type: bounds_min_max
  bounding_box_x_y:
    seq:
      - id: x
        type: bounds_min_max
      - id: y
        type: bounds_min_max
  bounds_min_max:
    seq:
      - id: min
        type: f8
      - id: max
        type: f8
  point:
    seq:
      - id: x
        type: f8
      - id: y
        type: f8
  poly_line:
    seq:
      - id: bounding_box
        type: bounding_box_x_y
      - id: number_of_parts
        type: s4
      - id: number_of_points
        type: s4
      - id: parts
        type: s4
        repeat: expr
        repeat-expr: number_of_parts
      - id: points
        type: point
        repeat: expr
        repeat-expr: number_of_points
  polygon:
    seq:
      - id: bounding_box
        type: bounding_box_x_y
      - id: number_of_parts
        type: s4
      - id: number_of_points
        type: s4
      - id: parts
        type: s4
        repeat: expr
        repeat-expr: number_of_parts
      - id: points
        type: point
        repeat: expr
        repeat-expr: number_of_points
  multi_point:
    seq:
      - id: bounding_box
        type: bounding_box_x_y
      - id: number_of_points
        type: s4
      - id: points
        type: point
        repeat: expr
        repeat-expr: number_of_points
  point_z:
    seq:
      - id: x
        type: f8
      - id: y
        type: f8
      - id: z
        type: f8
      - id: m
        type: f8
  poly_line_z:
    seq:
      - id: bounding_box
        type: bounding_box_x_y
      - id: number_of_parts
        type: s4
      - id: number_of_points
        type: s4
      - id: parts
        type: s4
        repeat: expr
        repeat-expr: number_of_parts
      - id: points
        type: point
        repeat: expr
        repeat-expr: number_of_points
      - id: z_range
        type: bounds_min_max
      - id: z_values
        type: f8
        repeat: expr
        repeat-expr: number_of_points
      - id: m_range
        type: bounds_min_max
      - id: m_values
        type: f8
        repeat: expr
        repeat-expr: number_of_points
  polygon_z:
    seq:
      - id: bounding_box
        type: bounding_box_x_y
      - id: number_of_parts
        type: s4
      - id: number_of_points
        type: s4
      - id: parts
        type: s4
        repeat: expr
        repeat-expr: number_of_parts
      - id: points
        type: point
        repeat: expr
        repeat-expr: number_of_points
      - id: z_range
        type: bounds_min_max
      - id: z_values
        type: f8
        repeat: expr
        repeat-expr: number_of_points
      - id: m_range
        type: bounds_min_max
      - id: m_values
        type: f8
        repeat: expr
        repeat-expr: number_of_points
  multi_point_z:
    seq:
      - id: bounding_box
        type: bounding_box_x_y
      - id: number_of_points
        type: s4
      - id: points
        type: point
        repeat: expr
        repeat-expr: number_of_points
      - id: z_range
        type: bounds_min_max
      - id: z_values
        type: f8
        repeat: expr
        repeat-expr: number_of_points
      - id: m_range
        type: bounds_min_max
      - id: m_values
        type: f8
        repeat: expr
        repeat-expr: number_of_points
  point_m:
    seq:
      - id: x
        type: f8
      - id: y
        type: f8
      - id: m
        type: f8
  poly_line_m:
    seq:
      - id: bounding_box
        type: bounding_box_x_y
      - id: number_of_parts
        type: s4
      - id: number_of_points
        type: s4
      - id: parts
        type: s4
        repeat: expr
        repeat-expr: number_of_parts
      - id: points
        type: point
        repeat: expr
        repeat-expr: number_of_points
      - id: m_range
        type: bounds_min_max
      - id: m_values
        type: f8
        repeat: expr
        repeat-expr: number_of_points
  polygon_m:
    seq:
      - id: bounding_box
        type: bounding_box_x_y
      - id: number_of_parts
        type: s4
      - id: number_of_points
        type: s4
      - id: parts
        type: s4
        repeat: expr
        repeat-expr: number_of_parts
      - id: points
        type: point
        repeat: expr
        repeat-expr: number_of_points
      - id: m_range
        type: bounds_min_max
      - id: m_values
        type: f8
        repeat: expr
        repeat-expr: number_of_points
  multi_point_m:
    seq:
      - id: bounding_box
        type: bounding_box_x_y
      - id: number_of_points
        type: s4
      - id: points
        type: point
        repeat: expr
        repeat-expr: number_of_points
      - id: m_range
        type: bounds_min_max
      - id: m_values
        type: f8
        repeat: expr
        repeat-expr: number_of_points
  multi_patch:
    seq:
      - id: bounding_box
        type: bounding_box_x_y
      - id: number_of_parts
        type: s4
      - id: number_of_points
        type: s4
      - id: parts
        type: s4
        repeat: expr
        repeat-expr: number_of_parts
      - id: part_types
        type: s4
        enum: part_type
        repeat: expr
        repeat-expr: number_of_parts
      - id: points
        type: point
        repeat: expr
        repeat-expr: number_of_points
      - id: z_range
        type: bounds_min_max
      - id: z_values
        type: f8
        repeat: expr
        repeat-expr: number_of_points
      - id: m_range
        type: bounds_min_max
      - id: m_values
        type: f8
        repeat: expr
        repeat-expr: number_of_points
enums:
  shape_type:
    0: null_shape
    1: point
    3: poly_line
    5: polygon
    8: multi_point
    11: point_z
    13: poly_line_z
    15: polygon_z
    18: multi_point_z
    21: point_m
    23: poly_line_m
    25: polygon_m
    28: multi_point_m
    31: multi_patch
  part_type:
    0: triangle_strip
    1: triangle_fan
    2: outer_ring
    3: inner_ring
    4: first_ring
    5: ring
