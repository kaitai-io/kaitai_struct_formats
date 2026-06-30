meta:
  id: ballistic_ng_ctl
  title: BallisticNG Custom Track
  file-extension: ctl
  endian: le
  license: CC0-1.0
doc-ref:
  - https://ballisticng-documentation.readthedocs.io/en/latest/ingame/layout_creator.html#ctl-custom-track-layout-specification
seq:
  - id: version
    type: s4
  - id: auto_juncion_threshold
    type: f4
  - id: hyper_speed_enabled
    type: s4
    if: _root.version > 5
  - id: speed_class
    type: s4
    if: _root.version > 5
  - id: speed_mode
    type: s4
    if: version > 5
  - id: physics_mode
    type: s4
    if: version > 5
  - id: mesh_floor_enabled
    type: u1
    if: version > 7
  - id: ship_speed_multiplier
    type: f4
    if: version > 12
  - id: reference_image_path_len
    type: u1
    if: version > 5
  - id: reference_image_path
    type: str
    encoding: UTF-8
    size: reference_image_path_len
    if: version > 5
  - id: reference_is_locked
    type: u1
    if: version > 6
  - id: reference_pos
    type: f4
    if: version > 5
    repeat: expr
    repeat-expr: 3
  - id: reference_width
    type: f4
    if: version > 5
  - id: route_count
    type: s4
  - id: routes
    type: route
    repeat: expr
    repeat-expr: route_count
  - id: physics_zone_count
    type: s4
    if: version > 7
  - id: physics_zones
    type: physics_zone
    if: version > 7
    repeat: expr
    repeat-expr: physics_zone_count
types:
  route:
    seq:
      - id: connect_entrance
        type: u1
      - id: connect_exit
        type: u1
      - id: use_new_smoothing_algorithm
        type: u1
        if: _root.version > 13
      - id: entrance_offset
        type: f4
        if: _root.version > 13
      - id: exit_offset
        type: f4
        if: _root.version > 13
      - id: auto_junction_smooth_entrance
        type: s4
      - id: auto_junction_smooth_exit
        type: s4
      - id: link_index
        type: s4
      - id: spline_closed
        type: u1
      - id: control_point_count
        type: s4
      - id: control_points
        type: control_point
        repeat: expr
        repeat-expr: control_point_count
  control_point:
    seq:
      - id: pos
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: rot
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: side_connect
        type: u1
      - id: maglock
        type: u1
      - id: no_tilt_lock
        type: u1
        if: _root.version > 8
      - id: allow_oob
        type: u1
        if: _root.version > 9
      - id: is_jump
        type: u1
        if: _root.version > 1
      - id: is_teleporter
        type: u1
        if: _root.version > 11
      - id: left_wall
        type: u1
      - id: right_wall
        type: u1
      - id: tangent_distance
        type: f4
        if: _root.version > 2
      - id: tangent_yaw
        type: f4
        if: _root.version > 3
      - id: tangent_pitch
        type: f4
        if: _root.version > 4
      - id: track_shape_interpolation_type
        type: u1
        enum: track_shape_interpolation_type
        if: _root.version > 10
      - id: left_floor_extent
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: left_wall_extent
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: right_floor_extent
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: right_wall_extent
        type: f4
        repeat: expr
        repeat-expr: 3
  physics_zone:
    seq:
      - id: unk_1
        type: s4
      - id: pos
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: euler
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: scale
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: gravity_multiplier
        type: f4
      - id: track_tracking_multiplier
        type: f4
      - id: grip_multiplier
        type: f4
      - id: air_resistance_multiplier
        type: f4
      - id: zero_gravity
        type: u1
      - id: zero_gravity_tracking_multiplier
        type: f4
      - id: zero_gravity_pitch_rotation_multiplier
        type: f4
      - id: zero_gravity_pitch_force
        type: f4
      - id: zero_gravity_pitch_speed
        type: f4
      - id: spring_to_track
        type: u1
      - id: track_spring_force
        type: f4
      - id: track_spring_min_threshold
        type: f4
      - id: track_spring_max_threshold
        type: f4
      - id: track_spring_damping
        type: f4
      - id: track_spring_tracking_multiplier
        type: f4
      - id: track_spring_speed_multiplier
        type: f4
enums:
  track_shape_interpolation_type:
    0: linear
    1: in_hold
    2: out_hold
    3: in_sine
    4: in_cubic
    5: in_quint
    6: in_circ
    7: in_quad
    8: in_quart
    9: in_expo
    10: out_sine
    11: out_cubic
    12: out_quint
    13: out_circ
    14: out_quat
    15: out_quart
    16: out_expo
    17: in_out_sine
    18: in_out_cubic
    19: in_out_quint
    20: in_out_circ
    21: in_out_quad
    22: in_out_quart
    23: in_out_expo
    24: out_in_sine
    25: out_in_cubic
    26: out_in_quint
    27: out_in_circ
    28: out_in_quad
    29: out_in_quart
    30: out_in_expo
