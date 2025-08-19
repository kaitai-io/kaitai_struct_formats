meta:
  id: dted
  title: DIGITAL TERRAIN ELEVATION DATA (DTED)
  file-extension:
    - dt0
    - dt1
    - dt2
  encoding: ASCII
  endian: be
  ks-version: 0.8
  license: MIT
doc: |
  PERFORMANCE SPECIFICATION DIGITAL TERRAIN ELEVATION DATA (DTED). |
  MIL-PRF-89020B (23 May 2000) |
  https://dds.cr.usgs.gov/srtm/version2_1/Documentation/MIL-PDF-89020B.pdf
seq:
  - id: uhl
    type: uhl_header
    doc: User Header Label (UHL)
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
    doc: |
      User Header Label (UHL). The UHL is used for magnetic tape and CD-ROM. |
      Fixed Length = 80 ASCII Characters
    seq:
      - id: recognition_sentinel
        contents: UHL
        doc: |
          Recognition sentinel ("UHL")
      - id: fixed_by_standard
        contents: "1"
        doc: |
          Fixed by standard ("1")
      - id: longitude_of_origin
        type: angle(3,0)
        doc: |
          Longitude of origin (lower left corner of data set; full degree | 
          value; leading zero(s) for all subfields: degrees, minutes and |
          seconds). H is the Hemisphere of the data.
      - id: latitude_of_origin
        type: angle(3,0)
        doc: |
          Latitude of origin (lower left corner of data set; full degree |
          value; leading zero(s) for all sub fields: (degrees, minutes and |
          seconds). H is the Hemisphere of the data.
      - id: longitude_interval_seconds
        type: ascii_int
        doc: |
          Longitude data interval in tenths of seconds.
      - id: latitude_interval_seconds
        type: ascii_int
        doc: |
          Latitude data interval in tenths of seconds.
      - id: absolute_vertical_accuracy
        type: str
        size: 4
        doc: |
          Absolute Vertical Accuracy in Meters. (With 90% assurance that |
          the linear errors will not exceed this value relative to mean sea |
          level (Right justified)).
      - id: security_code
        type: str
        size: 3
        doc: |
          Security code. (Left Justified)
      - id: unique_reference
        type: str
        size: 12
        doc: |
          Unique reference number
      - id: number_of_longitude_lines
        type: ascii_int
        doc: |
          Count of the number of longitude (profiles) lines for a full |
          one-degree cell. Count is based on the Level of DTED and the |
          latitude zone of the cell. (See Table I, II and III).
      - id: number_of_latitude_points
        type: ascii_int
        doc: |
          Count of the number of latitude points per longitude line for |
          a full one-degree cell. ( e.g. 1201 for DTED1, 3601.for DTED2).
      - id: multiple_accuracy
        type: str
        size: 1
        encoding: ASCII
        doc: |
          0 - Single |
          1 - Multiple
      - id: reserved
        type: str
        size: 24
        doc: |
          Unused portion for future use.
  dsi_header:
    doc: |
      Data Set Identification (DSI) Record. The DSI is used for magnetic |
      tape and CD-ROM. Fixed Length = 648 ASCII Characters |
      Note: *These fields, to be defined by producer, may be left blank.
    seq:
      - id: recognition_sentinel
        contents: DSI
        doc: |
          Recognition Sentinel ("DSI").
      - id: security_classification_code
        type: u1
        enum: security_classification_enum
        doc: |
          Security Classification Code
      - id: security_control_and_release_markings
        type: str
        size: 2
        doc: |
          Security Control and Release Markings. For DoD use only.
      - id: security_handling_description
        type: str
        size: 27
        doc: |
          Security Handling Description. Other security description. (Free |
          text or blank filled).
      - id: reserved_for_future_use1
        type: str
        size: 26
        doc: |
          Reserved for future use. (Blank filled).
      - id: nima_series_designator_for_product_level
        type: str
        size: 5
        doc: |
          NIMA Series Designator for or DTED2 product level (DTED0, DTED1 or |
          DTED2).
      - id: unique_reference_number
        type: str
        size: 15
        doc: |
          *Unique reference number. (For producing nations own use (free |
          text or zero filled)).
      - id: reserved_for_future_use2
        type: str
        size: 8
        doc: |
          Reserved for future use. (Blank filled).
      - id: data_edition_number
        type: str
        size: 2
        doc: |
          Data Edition Number (01-99).
      - id: match_merge_version
        type: str
        size: 1
        doc: |
          Match/Merge Version (A-Z).
      - id: maintenance_date
        type: date
        doc: |
          Match/Merge Date. Zero filled until used. (YYMM)
      - id: match_merge_date
        type: date
        doc: |
          Match/Merge Date. Zero filled until used. (YYMM)
      - id: maintenance_description
        type: str
        size: 4
        doc: |
          Maintenance Description Code. Zero filled until used. (0000 or ANNN)
      - id: producer_code
        type: str
        size: 8
        doc: |
          Producer Code.(Country - Free Text) (FIPS 10-4 Country Codes used 
          for first 2 characters) (CCAAABBB).
      - id: reserved_for_future_use3
        type: str
        size: 16
        doc: |
          Reserved for future use. (Blank filled).
      - id: product_specification
        type: str
        size: 9
        doc: |
          Product Specification. (Alphanumeric field) (AAAAAAAAA)
      - id:  product_specification_number
        type: str
        size: 2
        doc: |
          First digit is Product Specification Amendment Number and second |
          digit is the Change Number.
      - id:  product_specification_date
        type: date
        doc: |
          Date of Product Specification.
      - id:  vertical_datum
        type: str
        size: 3
        doc: |
          Vertical Datum (MSL, E96)
      - id:  horizontal_datum_code
        type: str
        size: 5
        doc: |
          Horizontal Datum Code (Current Version World Geodetic System) (WGS84).
      - id:  digitizing_collection_system
        type: str
        size: 10
        doc: |
          Digitizing/Collection System. (Free text).
      - id:  compilation_date
        type: date
        doc: |
          Compilation Date. (Most descriptive year/month) (YYMM).
      - id:  reserved_for_future_use4
        type: str
        size: 22
        doc: |
          Reserved for future use. (Blank filled).
      - id: latitude_of_origin
        type: angle(2,1)
        doc: |
          Latitude of origin of data— leading zero for values less than 10; H |
          is the hemisphere of the data. (DDMMSS.SH)
      - id: longitude_of_origin
        type: angle(3,1)
        doc: |
          Longitude of origin of data— leading zeroes for values less than |
          100; H is the hemisphere of the data. (DDDMMSS.SH)
      - id: latitude_of_sw_corner
        type: angle(2,0)
        doc: |
          Latitude of SW corner of data, bounding rectangle— leading zero for |
          values less than 10; H is the hemisphere of the data. (DDMMSSH)
      - id: longitude_of_sw_corner
        type: angle(3,0)
        doc: |
          Longitude of SW corner of data, bounding rectangle— leading zeroes |
          for values less than 100; H is the hemisphere of the data. (DDDMMSSH)
      - id: latitude_of_nw_corner
        type: angle(2,0)
        doc: |
          Latitude of NW corner of data, bounding rectangle— leading zero for |
          values less than 10; H is the hemisphere of the data. (DDMMSSH)
      - id: longitude_of_nw_corner
        type: angle(3,0)
        doc: |
          Longitude of NW corner of data, bounding rectangle— leading zeroes |
          for values less than 100; H is the hemisphere of the data. (DDDMMSSH)
      - id: latitude_of_ne_corner
        type: angle(2,0)
        doc: |
          Latitude of NE corner of data, bounding rectangle— leading zero for |
          values less than 10; H is the hemisphere of the data. (DDMMSSH)
      - id: longitude_of_ne_corner
        type: angle(3,0)
        doc: |
          Longitude of NE corner of data, bounding rectangle— leading zeroes |
          for values less than 100; H is the hemisphere of the data. (DDDMMSSH)
      - id: latitude_of_se_corner
        type: angle(2,0)
        doc: |
          Latitude of SE corner of data, bounding rectangle— leading zero for |
          values less than 10; H is the hemisphere of the data. (DDMMSSH)
      - id: longitude_of_se_corner
        type: angle(3,0)
        doc: |
          Longitude of SE corner of data, bounding rectangle— leading zeroes |
          for values less than 100; H is the hemisphere of the data. (DDDMMSSH)
      - id:  clockwise_orientation_angle
        type: angle(3,1)
        doc: |
          Clockwise orientation angle of data with respect to true North. |
          (Will usually be all zeros.)
      - id:  latitude_interval
        type: ascii_int
        doc: |
          Latitude interval in tenths of seconds between rows of elevation |
          values (SSSS).
      - id:  longitude_interval
        type: ascii_int
        doc: |
          Longitude interval in tenths of seconds between columns of elevation |
          values (SSSS).
      - id:  number_of_latitude_lines
        type: ascii_int
        doc: |
          Number of Latitude lines. For magnetic tape, this is the actual |
          count of the number of latitude points (rows that contain data). |
          For CD-ROM, this is the count of the number of latitude points in |
          a full one-degree cell. (e.g. 1201 for DTED1, 3601 for DTED2) |
          (0000-9999).
      - id:  number_of_longitude_lines
        type: ascii_int
        doc: |
          Number of Longitude lines. For magnetic tape, this is the actual |
          count of the number of longitude points (columns that contain data). |
          For CD-ROM, this is the count of the number of longitude points in a |
          full one-degree cell. The count is based on the level of DTED and |
          the latitude zone of the cell. (See Table II and III) (0000-9999). 
      - id:  partial_cell_indicator_text
        type: str
        size: 2
        doc: |
          Partial Cell Indicator 
          00 = Complete 1° cell 
          01-99 = % of data coverage.
      - id:  reserved_for_nima_use_only
        type: str
        size: 101
        doc: |
          Reserved for NIMA use only. (Free text or Blank filled.)
      - id:  reserved_for_producing_nation_use_only
        type: str
        size: 100
        doc: |
          Reserved for producing nation use only. (Free text or blank filled.)
      - id:  reserved_for_free_text_comments
        type: str
        size: 155
        doc: |
          Reserved for free text comments. (Free text or Blank filled.)
    instances:
      partial_cell_indicator:
        value: (partial_cell_indicator_text.to_i == 0)? 100.0 : partial_cell_indicator_text.to_i
        doc: |
          Partial Cell Indicator (% of data coverage)
  acc_header:
    doc: |
      Accuracy Description (ACC) Record. The ACC is used for magnetic tape and |
      CD-ROM. Fixed Length = 2700 ASCII Characters |
      Note: *If Product has subregional accuracies, the overall accuracy of |
      the product will be the worst accuracy.
    seq:
      - id: recognition_sentinel
        contents: ACC
        doc: |
          Recognition Sentinel ("ACC").
      - id: absolute_horizontal_accuracy
        type: ascii_int_maybe
        doc: |
          *Absolute Horizontal Accuracy of Product in meters (0000-9999 or Not |
          Available (NA))
      - id: absolute_vertical_accuracy
        type: ascii_int_maybe
        doc: |
          *Absolute Vertical Accuracy of Product in meters (0000-9999 or Not |
          Available (NA))
      - id: relative_horizontal_accuracy_of_product_in_meters
        type: ascii_int_maybe
        doc: |
          *Relative (Point-to-Point) Horizontal Accuracy of Product in meters. |
          (0000-9999 or Not Available (NA))
      - id: relative_vertical_accuracy_or_product_in_meters
        type: ascii_int_maybe
        doc: |
          *Relative (Point-to-Point) Vertical Accuracy of Product in meters. |
          (0000-9999 or Not Available (NA))
      - id: reserved_for_future_use1
        type: str
        size: 4
        doc: |
          Reserved for future use. (Blank filled.)
      - id: reserved_for_nima_use_only1
        type: str
        size: 1
        doc: |
          Reserved for NIMA use only.
      - id: reserved_for_future_use2
        type: str
        size: 31
        doc: |
          Reserved for future use. (Blank filled.)
      - id: multiple_accuracy_outline_flag
        type: str
        size: 2
        doc: |
          Multiple Accuracy Outline Flag. |
          00 = No accuracy subregions provided. |
          02-09 = Number of accuracy subregions per 1° cell (maximum 9).
      - id: subregion
        type: acc_subregion
        repeat: expr
        repeat-expr: 9
      - id: reserved_for_nima_use_only2
        type: str
        size: 18
        doc: |
          Reserved for NIMA use only.
      - id: reserved_for_future_use3
        type: str
        size: 69
        doc: |
          Reserved for future use.
  acc_subregion:
    doc: |
      Start of Accuracy Sub region Description. Repeat to maximum of nine |
      times. Only the number of subregions defined in the Multiple Accuracy |
      Outline Flag are populated. Blank fill all unused coordinate pairs |
      within a subregion. (1 Sub region = 284 ASCII Characters). Refer |
      to 3.13.5.1 for accuracy subregion description.
    seq:
      - id: absolute_horizontal_accuracy_or_subregion_in_meters
        type: ascii_int_maybe
        doc: |
          Absolute Horizontal Accuracy of Sub region in meters (0000-9999 or |
          Not Available (NA) )
      - id: absolute_vertical_accuracy_or_subregion_in_meters
        type: ascii_int_maybe
        doc: |
          Absolute Vertical Accuracy of Sub region in meters (0000-9999 or |
          Not Available (NA) )
      - id: relative_horizontal_accuracy_of_subregion_in_meters
        type: ascii_int_maybe
        doc: |
          Relative (Point-to-Point) Horizontal Accuracy of Sub region in |
          meters. (0000-9999 or Not Available (NA))
      - id: relative_vertical_accuracy_of_subregion_in_meters
        type: ascii_int_maybe
        doc: |
          Relative (Point-to-Point) Vertical Accuracy of Subregion in meters. |
          (0000-9999 or Not Available (NA))
      - id: number_of_coordinates_in_accuracy_subregion_outline
        type: str
        size: 2
        doc: |
          Number of coordinates in accuracy sub region outline. (Maximum of |
          14 coordinate pairs. The first coordinate is the most southwestern. |
          Coordinates are input clockwise. Implied closing from last to first |
          coordinate pairs.) (03-14)
      - id: coordinate_pair
        type: coordinate_pair
        repeat: expr
        repeat-expr: 14
        doc: |
          Start of Coordinate Pair Description. Repeat to maximum of fourteen |
          times to outline subregion. Blank fill all unused accuracy |
          subregions and unused portions of subregions.
  data_record:
    doc: |
      Data Record Description. The Data Record is used for magnetic tape and |
      CD-ROM. |
      Each elevation is a true value as determined by the Earth Gravity |
      Model (EGM) 1996 recorded to the nearest meter. The horizontal position |
      is referenced to precise longitude-latitude locations in terms of the |
      current World Geodetic System (WGS), determined for each file by |
      reference to the origin at the southwest corner. The elevations are |
      evenly spaced in latitude and longitude at the interval designated in |
      the user header label in South to North profile sequence.
    seq:
      - id: recognition_sentinal
        contents: [0xAA]
        doc: |
          Recognition Sentinel.
      - id: data_block_count
        type: b24
        doc: |
          Sequential count of the block within the file, starting with zero |
          for the first block (Fixed Binary). (Data block count)
      - id: logitude_count
        type: fixed_binary
        doc: |
          Count of the meridian. True longitude = longitude count x data |
          interval + origin (Offset from the SW corner longitude) |
          (Fixed Binary).
      - id: latitude_count
        type: fixed_binary
        doc: |
          Count of the parallel. True latitude = latitude count x data |
          interval + origin (Offset from the SW corner latitude) |
          (Fixed Binary).
      - id: elevations
        type: fixed_binary
        repeat: expr
        repeat-expr: _parent.uhl.number_of_latitude_points.value
        doc: |
          True elevation value of point N of meridian in meters (Fixed Binary).
      - id: checksum
        type: s4
        doc: |
          Algebraic addition of contents of block. Sum is computed as an 
          integer summation of 8-bit values (Fixed Binary).
  fixed_binary:
    doc: |
      Fixed Binary denotes signed magnitude, right-justified binary integers.
    seq:
      - id: is_negative
        type: b1
      - id: value
        type: b15
    instances:
      meters:
        value: value * (is_negative? -1 : 1)
  ascii_int:
    seq:
      - id: text
        type: str
        size: 4
    instances:
      value:
        value: text.to_i
  ascii_int_maybe:
    seq:
      - id: text
        type: str
        size: 4
    instances:
      has_value:
        value: text != "    " and text != "NA"
      value:
        value: text.to_i
        if: has_value
  coordinate_pair:
    doc: |
      Typed used group 2 angles to form a coordinate.  It is accurate to the |
      tenth of a second.
    seq:
      - id: latitude
        type: angle(2,1)
        doc: |
          Latitude—leading zero for values less than 10; H is the hemisphere |
          of the data. (DDMMSS.SH)
      - id: longitude
        type: angle(3,1)
        doc: |
          Longitude—leading zero for values less than 100; H is the hemisphere |
          of the data. (DDDMMSS.SH)
  angle:
    params:
      - id: len_degrees
        type: u1
      - id: has_decimal_point
        type: u1
    seq:
      - id: degrees
        type: str
        size: len_degrees
      - id: minutes
        type: str
        size: 2
      - id: seconds
        type: str
        size: 2
      - id: decimal_point
        type: str
        size: 1
        if: has_decimal_point == 1
      - id: tenths_of_seconds
        type: str
        size: 1
        if: has_decimal_point == 1
      - id: hemisphere
        type: str
        size: 1
    instances:
      has_value:
        value: minutes != "  "
        doc: |
          Some angles are for completly blank ascii strings so we need to |
          check for that
      value:
        value: (degrees.to_i + minutes.to_i/60.0 + seconds.to_i/3600.0 + (has_decimal_point==1?tenths_of_seconds.to_i/36000.0 : 0)) * (hemisphere == 'N'? 1 : -1)
        if: has_value
        doc: |
          Degree decimal floating point representation
  date:
    seq:
      - id: year_text
        type: str
        size: 2
      - id: month_text
        type: str
        size: 2
    instances:
      year:
        value: year_text.to_i
      month:
        value: month_text.to_i
enums:
  security_classification_enum:
    83: secrete
    67: confidential
    85: unclassified
    82: restricted
