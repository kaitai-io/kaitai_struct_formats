meta:
  id: joda_time
  title: Joda-Time timezone
  application:
    - Joda-Time library
  license: Apache-2.0
  ks-version: 0.9
  encoding: utf-8
  endian: be

doc: Joda-Time is a time manipulation library for Java. It stores info about timezones in own binary format. The timezones are embedded into the jars (can be downloaded from https://github.com/JodaOrg/joda-time/releases/) and can be unpacked from them.
doc-ref: https://github.com/JodaOrg/joda-time/blob/e37246fb936b2c242812235dff53c749e18ec200/src/main/java/org/joda/time/tz/DateTimeZoneBuilder.java#L110
seq:
  - id: encoding
    type: str
    size: 1
  - id: payload
    type:
      switch-on: encoding
      cases:
        '"F"': fixed
        '"C"': precalculated  # cached
        '"P"': precalculated
types:
  pas_str:
    doc-ref: https://docs.oracle.com/javase/7/docs/api/java/io/DataInput.html#readUTF()
    seq:
      - id: length
        type: u2
      - id: value
        type: str
        size: length
  fixed:
    seq:
      - id: name_key
        -orig-id: nameKey
        type: pas_str
      - id: wall_offset
        -orig-id: wallOffset
        type: millis
      - id: standard_offset
        -orig-id: standardOffset
        type: millis
  precalculated:
    -orig-id: PrecalculatedZone
    seq:
      - id: pool_size
        -orig-id: poolSize
        type: u2
      - id: pool
        type: pas_str
        repeat: expr
        repeat-expr: pool_size
      - id: seasons_count
        -orig-id: size
        type: u4
      - id: seasons
        type: season
        repeat: expr
        repeat-expr: seasons_count
      - id: tail_present
        type: u1
      - id: tail
        type: dst_zone
        if: tail_present != 0
        doc: optional zone for getting info beyond precalculated tables

    types:
      season:
        seq:
          - id: transition
            type: millis
          - id: wall_offsets
            type: millis
          - id: standard_offsets
            type: millis
          - id: index
            type:
              switch-on: _parent.pool_size < 256
              cases:
                true: u1
                false: u2

  millis:
    seq:
      - id: type
        type: b2
      - id: hi_u
        type: sb6
      - id: payload
        type:
          switch-on: type
          cases:
            0: form_0(hi)
            1: form_1(hi)
            2: form_2(hi)
            3: form_3
      instances:
        hi:
          value: (value ^ 0x3F) - 0x3F
          doc-ref: https://graphics.stanford.edu/~seander/bithacks.html#VariableSignExtend

    types:
      form_0:
        params:
          - id: v
            type: s1
        instances:
          value:
            value: v * 30 * 60000
      form_1:
        params:
          - id: v
            type: s1
        seq:
          - id: lo1
            type: u2
          - id: lo2
            type: u1
        instances:
          value:
            value: (hi << 24 | lo1 << 8 | lo2) * 60000
      form_2:
        params:
          - id: v
            type: s1
        seq:
          - id: lo
            type: u4be
        instances:
          value:
            value: (hi << 32 | lo) * 1000
      form_3:
        seq:
          - id: value
            type: u8
  dst_zone:
    seq:
      - id: standard_offset
        -orig-id: standardOffset
        type: millis
      - id: start_recurrence
        -orig-id: startRecurrence
        type: recurrence
      - id: end_recurrence
        -orig-id: endRecurrence
        type: recurrence

  recurrence:
    seq:
      - id: of_year
        -orig-id: ofYear
        type: of_year
      - id: name_key
        -orig-id: nameKey
        type: pas_str
      - id: save_millis
        -orig-id: saveMillis
        type: millis

  of_year:
    seq:
      - id: mode
        type: u1
        doc: w or s
      - id: month_of_year
        -orig-id: monthOfYear
        type: u1
      - id: day_of_month
        -orig-id: dayOfMonth
        type: s1
      - id: day_of_week
        -orig-id: dayOfWeek
        type: u1
      - id: advance_day_of_week
        -orig-id: advanceDayOfWeek
        type: u1
      - id: millis_of_day
        -orig-id: millisOfDay
        type: millis
