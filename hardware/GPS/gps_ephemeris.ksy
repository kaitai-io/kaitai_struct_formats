meta:
  id: gps_almanac
  endian: be
doc: |
  
doc-ref: https://www.gps.gov/technical/icwg/IS-GPS-200H.pdf PDF page 174, 
seq:
  - id: week_number
    type: b13
    doc: WN weeks
  - id: ed_accuracy_index_
    type: bs5
    doc: ura_ed_index (see text)
  - id: signal_health_
    type: b3
    doc: (L1/L2/L5) (see text)
  - id: data_predict_time_of_week_ # t_op
    type: b11
  - id: semi_major_axis_difference_at_reference_time_ # ∆A
    type: bs26
  - id: change_rate_in_semi_major_axis_ # A
    type: bs25

  - id: mean_motion_difference_from_computed_value_at_reference_time # ∆n_0
    type: bs17

  - id: rate_of_mean_motion_difference_from_computed_value # ∆^•n_0
    type: bs23

  - id: mean_anomaly_at_reference_time
    type: bs33
  - id: eccentricity
    type: b33
  - id: argument_of_perigee_
    type: bs33
  - id: ephemeris_data_reference_time_of_week_
    type: b11
  - id: longitude_of_ascending_node_of_orbit_plane_at_weekly_epoch_
    type: bs33
  - id: rate_of_right_ascension_difference_
    type: bs17
  - id: inclination_angle_at_reference_time_
    type: bs33
  - id: rate_of_inclination_angle_
    type: bs15
    doc: i0-n –DOT 2**-44 semi-circles/sec
  - id: amplitude_of_the_sine_harmonic_correction_term_to_the_angle_of_inclination_
    type: bs16
  - id: amplitude_of_the_cosine_harmonic_correction_term_to_the_angle_of_inclination_
    type: bs16
  - id: amplitude_of_the_sine_correction_term_to_the_orbit_radius_
    type: bs24
  - id: amplitude_of_the_cosine_correction_term_to_the_orbit_radius_
    type: bs24
  - id: amplitude_of_the_sine_harmonic_correction_term_to_the_argument_of_latitude_
    type: bs21
instances:
  ed_accuracy_index:
    value: ed_accuracy_index_.value
  signal_health:
    value: signal_health_
  data_predict_time_of_week_:
    value: data_predict_time_of_week__.value * 300
    doc: t_op seconds , eff range 604,500
  a_ref:
    value: 26559710
    doc: meters
  semi_major_axis_difference_at_reference_time:
    value: semi_major_axis_difference_at_reference_time_.value * 2**-9
    doc: ∆A meters Relative to a_ref
  change_rate_in_semi_major_axis:
    value: change_rate_in_semi_major_axis_.value * 2**-21
    doc: A meters/sec
  mean_motion_difference_from_computed_value_at_reference_time:
    value: mean_motion_difference_from_computed_value_at_reference_time_.value * 2**-44
    doc: ∆n_0 semi-circles/sec
  rate_of_mean_motion_difference_from_computed_value:
    value: rate_of_mean_motion_difference_from_computed_value_.value * 2**-57
    doc: ∆^•n_0 semi-circles/sec^2
  mean_anomaly_at_reference_time:
    value: mean_anomaly_at_reference_time_.value * 2**-32
    doc: M0-n semi-circles
  eccentricity:
    value: eccentricity_ * 2**-34
    doc: en 0.03 dimensionless
  argument_of_perigee:
    value: argument_of_perigee_.value *  2**-32
    doc: ωn semi-circles
  ephemeris_data_reference_time_of_week:
    value: ephemeris_data_reference_time_of_week_ * 300
    doc: toe, max 604500 seconds
  longitude_of_ascending_node_of_orbit_plane_at_weekly_epoch:
    value: longitude_of_ascending_node_of_orbit_plane_at_weekly_epoch_.value * 2**-32
    doc: Ω0-n semi-circles
  omega_ref:
    value: -2.6e-9
    doc: ΩREF semi-circles/second
  rate_of_right_ascension_difference:
    value: rate_of_right_ascension_difference_.value * 2**-44
    doc: ΔΩ semi-circles/sec, Relative to ΩREF
  inclination_angle_at_reference_time:
    value: inclination_angle_at_reference_time_.value * 
    doc:
  rate_of_inclination_angle:
    value: rate_of_inclination_angle_.value * 2**-32
    doc: i0-n semi-circles
  amplitude_of_the_sine_harmonic_correction_term_to_the_angle_of_inclination:
    value: amplitude_of_the_sine_harmonic_correction_term_to_the_angle_of_inclination_.value * 2**-30
    doc: Cis-n radians
  amplitude_of_the_cosine_harmonic_correction_term_to_the_angle_of_inclination:
    value: amplitude_of_the_cosine_harmonic_correction_term_to_the_angle_of_inclination_.value * 2**-30
    doc: Cic-n radians
  amplitude_of_the_sine_correction_term_to_the_orbit_radius:
    value: amplitude_of_the_sine_correction_term_to_the_orbit_radius_.value * 2**-8
    doc: Crs-n meters
  amplitude_of_the_cosine_correction_term_to_the_orbit_radius:
    value: amplitude_of_the_cosine_correction_term_to_the_orbit_radius_.value * 2**-8
    doc: Crc-n meters
  amplitude_of_the_sine_harmonic_correction_term_to_the_argument_of_latitude:
    value: amplitude_of_the_sine_harmonic_correction_term_to_the_argument_of_latitude_.value * 2**-30
    doc: Cus-n radians
types:
  bs5:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b4
    instances:
      value:
        value: (sign?ext_mod-(1<<4):ext_mod)
  bs11:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b10
    instances:
      value:
        value: (sign?ext_mod-(1<<10):ext_mod)
  bs15:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b14
    instances:
      value:
        value: (sign?ext_mod-(1<<14):ext_mod)
  bs16:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b15
    instances:
      value:
        value: (sign?ext_mod-(1<<15):ext_mod)
  bs17:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b16
    instances:
      value:
        value: (sign?ext_mod-(1<<16):ext_mod)
  bs21:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b20
    instances:
      value:
        value: (sign?ext_mod-(1<<203):ext_mod)
  bs23:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b22
    instances:
      value:
        value: (sign?ext_mod-(1<<22):ext_mod)
  bs24:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b23
    instances:
      value:
        value: (sign?ext_mod-(1<<23):ext_mod)
  bs25:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b24
    instances:
      value:
        value: (sign?ext_mod-(1<<24):ext_mod)
  bs26:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b25
    instances:
      value:
        value: (sign?ext_mod-(1<<25):ext_mod)
  bs33:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b32
    instances:
      value:
        value: (sign?ext_mod-(1<<32):ext_mod)