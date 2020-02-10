meta:
  id: gps_almanac
  endian: be
doc: |
  The almanac data are a reduced-precision subset of the clock and ephemeris parameters. The data occupy all bits of words three through ten of each page except the eight MSBs of word three (data ID and SV ID), bits 17 through 24 of word five (SV health), and the 50 bits devoted to parity. The number of bits, the scale factor (LSB), the range, and the units of the almanac parameters are given in Table 20-VI. The algorithms and other material related to the use of the almanac data are given in paragraph 20.3.3.5.2.
  The almanac message for any dummy SVs shall contain alternating ones and zeros with valid parity.
  Users are cautioned against attempting to track a dummy SV since the results are unpredictable.
  The almanac parameters shall be updated by the CS at least once every 6 days while the CS is able to upload the SVs. If the CS is unable to upload the SVs, the accuracy of the almanac parameters transmitted by the SVs will degrade over time.
  For Block II and IIA SVs, three sets of almanac shall be used to span at least 60 days. The first and second sets will be transmitted for up to six days each; the third set is intended to be transmitted for the remainder of the 60 days minimum, but the actual duration of transmission will depend on the individual SV's capability to retain data in memory. All three sets are based on six-day curve fits that correspond to the first six days of the transmission interval.
  For Block IIR/IIR-M, IIF, and GPS III SVs, five sets of almanac shall be used to span at least 60 days. The first, second, and third sets will be transmitted for up to six days each; the fourth and fifth sets will be transmitted for up to 32 days; the fifth set is intended to be transmitted for the remainder of the 60 days minimum, but the actual duration of transmission will depend on the individual SV's capability to retain data in memory.
  The first, second, and third sets are based on six day curve fits. The fourth and fifth sets are based on 32 day curve fits.
doc-ref: https://www.gps.gov/technical/icwg/IS-GPS-200H.pdf PDF page 125, 
seq:
  - id: eccentricity_ # e
    type: u2
  - id: almanac_reference_time_ # t_oa
    type: u1
  - id: correction_to_inclination_ #δi****
    type: s2
  - id: rate_of_right_ascension_ # Ω•
    type: s2
  - id: the_semi_major_axis_sqrt_ # A
    type: b24
  - id: longitude_of_ascending_node_of_orbit_plane_at_weekly_epoch_ # Ω0
    type: bs24
  - id: argument_of_perigee_ # ω
    type: bs24
  - id: mean_anomaly_at_reference_time_ # M0
    type: bs24
  - id: clock_bias_ # a_f0
    type: bs11
  - id: clock_drift_ # a_f1
    type: bs11
instances:
  inclination_at_reference_time:
    value: 0.30
    doc: i_0 circles/2.
  eccentricity:
    value: eccentricity_*2**-21
    doc: dimensionless
  almanac_reference_time:
    value: almanac_reference_time_*2**12
    doc: t_oa seconds. Max range is 602,112
  correction_to_inclination:
    value: correction_to_inclination_*2**-19
    doc: δi circles/2. Relative to i_0
  inclination:
    value: inclination_at_reference_time+correction_to_inclination
    doc: i circles/2
  rate_of_right_ascension: # 
    value: rate_of_right_ascension_*2**-38
    doc: Ω• circles/2/sec
  the_semi_major_axis_sqrt:
    value: the_semi_major_axis_sqrt_*2**-11
    doc: A meters
  longitude_of_ascending_node_of_orbit_plane_at_weekly_epoch:
    value: longitude_of_ascending_node_of_orbit_plane_at_weekly_epoch_.value*2**-23
    doc: Ω0 circles/2
  argument_of_perigee:
    value: argument_of_perigee_.value*2**-23
    doc: ω circles/2
  mean_anomaly_at_reference_time:
    value: mean_anomaly_at_reference_time_.value*2**-23
    doc: M0 circles/2
  clock_bias:
    value: clock_bias_.value*2**-20
    doc: |
      a_f0 seconds
      value from ephemeris is preferred over almanac
  clock_drift:
    value: clock_drift_.value*2**-38
    doc: |
      a_f0 seconds
      value from ephemeris is preferred over almanac
types:
  bs24:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b23
    instances:
      value:
        value: (sign?ext_mod-(1<<23):ext_mod)
  bs11:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b10
    instances:
      value:
        value: (sign?ext_mod-(1<<10):ext_mod)