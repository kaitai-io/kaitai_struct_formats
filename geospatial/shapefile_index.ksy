meta:
  id: shapefile_index
  title: Shapefile index file
  file-extension: shx
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
      - id: offset
        type: s4be
      - id: content_length
        type: s4be
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
  bounds_min_max:
    seq:
      - id: min
        type: f8be
      - id: max
        type: f8be
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
