meta:
  id: gps_mgl_enigma_waypoint
  title: MGL Avionics Enigma Waypoint format
  application: Enigma software
  file-extension:
    - ewd # WAYPOINT.EWD usually
    - rte # MYROUTE.RTE usually
  license: Proprietary # Public domain dedication and then ... some conditions that are incompatible to free software and public damain. See the -license-header
  endian: le
  encoding: ascii

  -license-header: | # the conditions contradict each other and seem to be unenforceable, but I'm not your attorney
    MGL Avionics places this document and the data format it describes in the public domain in order to foster the use of a common, compact waypoint and route file format that is particularly optimized for use with resource limited systems and/or systems that require fast access to individual items in the waypoint files in order to increase overall systems performance.
    In order to allow recognition of the format any party adopting this format agrees to refer to this format as the “Enigma waypoint format”. All data using this format should be considered to be in the public domain and the implementer will make reasonable effort to allow any interested party to use the data.
    Exceptions:
      MGL Avionics reserves copyright and denies use of this data format for any military or related purpose.

doc: |
  Waypoint format used by Enigma series of EFIS instruments from MGL Avionics.
  It is common to create an index file containing a simple list of indexes, one to each entry in the waypoint file, sorted by a particular criteria (for example distance of the waypoint to a given location), rather than sorting the actual waypoint list itself. This is a method commonly employed by database applications.

doc-ref: https://mglavionics.co.za/Docs/Enigma%20Waypoint%20format.pdf

seq:
  - id: waypoints
    type: waypoint
    repeat: eos
    doc: There is no demand that waypoints are stored in any particular order in the waypoint file. They might be sorted by short name or waypoint type but this is of little consequence. The order of waypoints in the file matters only for route files. Route waypoints are stored in the file in order of their appearance in the route. A route should have at least one waypoint.

types:
  waypoint:
    seq:
      - id: lat
        type: sph_coord
        doc: Positive values are in the Nothern Hemisphere
      - id: lon
        type: sph_coord
        doc: Positive values are in the Eastern Hemisphere
      - id: data_raw
        type: u4
      - id: type
        type: u1
        enum: type
      - id: name_short
        type: dc_str(6)
        doc: This entry is used as “key” and in aviation terms would contain the short identifier of an airfield or navaid beacon. This key is used to lookup related data in other databases, for example an airport data base containing details of an airport such as frequencies and runway headings.
      - id: name_long
        type: dc_str(27)
        doc: an arbitrary human-readable description of the waypoint (e.g. "Los Angeles International"), not used as a search key

    instances:
      is_data_frequency:
        value: 9 <= type.to_i and type.to_i <= 25
      altitude:
        value: "( ( data_raw < 0x80000000 ) ? data_raw : ( ( data_raw & 0x7FFFFFFF ) - 0x80000000 ) )"
        doc: in feet
        if: not is_data_frequency
      frequency:
        value: data_raw
        doc: in kHz
        if: is_data_frequency

  dc_str:
    params:
      - id: max_size
        type: u1
    seq:
      - id: size
        type: u1
      - id: value
        type: str
        size: value_size
      - id: garbage
        type: str
        size: max_size - value_size
    instances:
      value_size:
        value: max_size > size ? size : max_size

  sph_coord:
    seq:
      - id: raw
        type: s4
    instances:
      value:
        value: raw / 180000.

enums:
  type:  # Contact info@MGLAvionics.co.za if you add any waypoint type, so they can update their PDF
    0: unspecified
    1:
      id: airport_minor
      doc: Typical assignment for medium sized airports
    2:
      id: airport_major
      doc: Typical assignment for large and international airports
    3:
      id: seaplane_base
    4:
      id: airfield
      doc: Typical assignment for smaller municipal airfields, glider fields etc
    5:
      id: airfield_private
    6:
      id: ultralight_field
    7:
      id: intersection
      doc: reporting point, boundary crossing
    8: heliport
    9:
      id: tacan
      doc-ref: https://en.wikipedia.org/wiki/Tactical_air_navigation_system
    10: ndb_or_dme
    11:
      id: ndb
      doc-ref:
        - https://en.wikipedia.org/wiki/Non-directional_beacon
        - https://github.com/tejeez/rtl_coherent
    12: vor_or_dme
    13: vortac
    14: fan_marker
    15:
      id: vor
      doc-ref: https://github.com/martinber/vor-python-decoder
    16: rep_pt
    17:
      id: lfr
      doc-ref: https://en.wikipedia.org/wiki/Low-frequency_radio_range
    18: uhf_ndb
    19: m_ndb
    20: m_ndb_or_dme
    21:
      id: lom
      doc-ref: https://en.wikipedia.org/wiki/Marker_beacon
    22:
      id: lmm
      doc-ref: https://en.wikipedia.org/wiki/Marker_beacon
    23: loc_or_sdf
    24: mls_or_ismls
    25:
      id: other_nav
      doc: Navaid not falling into any of the above types
    26:
      id: altitude_change
      doc: Location at which altitude should be changed
