meta:
  id: tzif
  title: The Time Zone Information Format (TZif)
  xref:
    mime: application/tzif
    # mime: "application/tzif-leap" if leap-second records are included
    rfc: 8536
  license: CC0-1.0
  ks-version: 0.8
  endian: be
doc: |
  TZif is the binary file format used to represent data for a single time zone
  compiled by the _zic_ compiler from information in the IANA time zone
  database. It is used by most UNIX systems to calculate local time for a time
  zone, usually identified by a time zone identifier string referring to a
  relatively populous location within the geographic region covered by the time
  zone, for example: "America/New_York" or "Europe/Paris". This identifier is
  external to the TZif file itself.
doc-ref: https://tools.ietf.org/html/rfc8536
seq:
  - id: v1_struct
    type: tz_struct(false)
  - id: v2_struct
    type: tz_struct(true)
    if: version >= 2
  - id: v2_footer
    type: tz_footer
    if: version >= 2
instances:
  version:
    value: v1_struct.header.version
types:
  tz_struct:
    params:
      - id: is_ts64
        type: bool
        doc: |
          Chooses whether to use 64-bit or 32-bit time values. Set to `false`
          for 32-bit time values (used in the version 1 data block). Set to
          `true` for 64-bit time values (used in the version 2+ data block).
    seq:
      - id: header
        type: tz_header
      - id: data
        type: tz_data(is_ts64)
  tz_header:
    doc-ref: https://tools.ietf.org/html/rfc8536#section-3.1
    seq:
      - id: magic
        contents: TZif
      - id: ver_byte
        -orig-id: ver
        type: u1
        doc: |
          File format version: 0x00 Version 1; 0x32 Version 2; 0x33 Version 3.
          The additional header block for version 2+ after the version 1 data
          block MUST have the same version as as the first header block.
      - id: reserved
        size: 15
        doc: Reserved bytes MUST be 0.
      - id: num_is_ut_flags
        -orig-id: isutcnt
        type: u4
        doc: |
          Number of UT/local indicators contained in the data block. MUST
          either be 0 or equal to `num_local_time_types`.
      - id: num_is_std_flags
        -orig-id: isstdcnt
        type: u4
        doc: |
          Number of standard/wall indicators contained in the data block. MUST
          either be 0 or equal to `num_local_time_types`.
      - id: num_leap_second_records
        -orig-id: leapcnt
        type: u4
        doc: Number of leap-second records contained in the data block.
      - id: num_transition_times
        -orig-id: timecnt
        type: u4
        doc: Number of transition times contained in the data block.
      - id: num_local_time_types
        -orig-id: typecnt
        type: u4
        doc: |
          Number of local time type records contained in the data block. MUST
          NOT be 0.
      - id: len_tz_designations
        -orig-id: charcnt
        type: u4
        doc: |
          Total number of octets used by the set of time zone designations
          contained in the data block. MUST NOT be 0. Includes the trailing NUL
          (0x00) octet at the end of the last time zone designation.
    instances:
      version:
        value: 'ver_byte >= 0x32 ? ver_byte - 0x30 : 1'
  tz_data:
    doc-ref: https://tools.ietf.org/html/rfc8536#section-3.2
    params:
      - id: is_ts64
        type: bool
        doc: |
          Chooses whether to use 64-bit or 32-bit time values. Set to `false`
          for 32-bit time values (used in the version 1 data block). Set to
          `true` for 64-bit time values (used in the version 2+ data block).
    seq:
      - id: transition_times
        type:
          switch-on: is_ts64
          cases:
            false: s4
            true: s8
        repeat: expr
        repeat-expr: _parent.header.num_transition_times
        doc: |
          A series of UNIX leap-time values sorted in strictly ascending order.
          Each value is used as a transition time at which the rules for
          computing local time may change. Each time value SHOULD be at least
          -2**59.
      - id: transition_types
        type: u1
        repeat: expr
        repeat-expr: _parent.header.num_transition_times
        doc: |
          Transition types specifying the type of local time of the
          corresponding transition time. These values serve as zero-based
          indices into the array of local time type records. Each type index
          MUST be in the range [0, `_parent.header.num_local_time_types` - 1].
      - id: local_time_types
        type: tz_local_time_type
        repeat: expr
        repeat-expr: _parent.header.num_local_time_types
        doc: Local time type records.
      - id: tz_designations
        size: _parent.header.len_tz_designations
        doc: |
          Space for a series of NUL-terminated (0x00) time zone designation
          strings. Two designations MAY overlap if one is a suffix of the other.
          The character encoding of time zone designation strings is not
          specified. For interoperbility, time zone designations SHOULD consist
          of at least three (3) and no more than six (6) ASCII characters from
          the set of alphanumerics, '-', and '+'. This is for compatibility with
          POSIX requirements for time zone abbreviations.
      - id: leap_second_records
        type: tz_leap_second_record(is_ts64)
        repeat: expr
        repeat-expr: _parent.header.num_leap_second_records
        doc: Leap-second records.
      - id: is_std_flags
        # standard/wall indicators
        type: u1
        repeat: expr
        repeat-expr: _parent.header.num_is_std_flags
        doc: |
          Values indicating whether the transition times associated with the
          local time types were specified as standard time or wall-clock time.
          The value MUST be 0 or 1. A value of one (1) indicates standard time.
          The value MUST be set to one (1) if the corresponding UT/local
          indicator is set to one (1). A value of zero (0) indicates wall time.
          If `_parent.header.num_is_std_flags` is zero (0), all transition times
          associated with local time types are assumed to be specified as wall
          time.
      - id: is_ut_flags
        # UT/local indicators
        type: b8
        repeat: expr
        repeat-expr: _parent.header.num_is_ut_flags
        doc: |
          Values indicating whether the transition times associate with the
          local time types were specified as UT or local time. The value MUST be
          0 or 1. A value of one (1) indicates UT, and the corresponding
          standard/wall indicator in `is_std` MUST also be set to one (1). A
          value of zero (0) indicates local time. If
          `_parent.header.num_is_ut_flags` is zero (0), all transition times
          associated with local time types are assumed to be specified as local
          time.
  tz_local_time_type:
    doc-ref: https://tools.ietf.org/html/rfc8536#section-3.2
    seq:
      - id: utoff
        type: s4
        doc: |
          Number of seconds to be added to UT in order to determine local time.
          The value MUST NOT be -2**31 and SHOULD be in the range [-89999,
          93599].
      - id: is_dst
        -orig-id: dst
        type: u1
        doc: |
          Indicates whether local time should be considered Daylight Saving Time
          (DST). The value MUST be 0 or 1. A value of one (1) indicates that
          this time type is DST. A value of zero (0) indicates that this time
          type is standard time.
      - id: desig_idx
        -orig-id: idx
        type: u1
        doc: |
          Specifies a zero-based index into the series of time zone designation
          octets, thereby selecting a particular designation string. Each index
          MUST be in the range [0, `_parent._parent.header.len_tz_designations`
          - 1]; it designates the NUL-terminated string of octets starting at
          position `desig_idx` in the time zone designations. (This string MAY
          be empty.) A NUL octet MUST exist in the time zone designations at or
          after position `desig_idx`.
  tz_leap_second_record:
    doc-ref: https://tools.ietf.org/html/rfc8536#section-3.2
    params:
      - id: is_ts64
        type: bool
        doc: |
          Chooses whether to use 64-bit or 32-bit time values. Set to `false`
          for 32-bit time values (used in the version 1 data block). Set to
          `true` for 64-bit time values (used in the version 2+ data block).
    seq:
      - id: occurence
        -orig-id: occur
        type:
          switch-on: is_ts64
          cases:
            false: s4
            true: s8
        doc: |
          A UNIX leap time value specifying the time at which a leap-second
          cottection occurs. The first value, if present, MUST be nonnegative,
          and each later value MUST be at least 2419199 greater than the
          previous value.
      - id: correction
        -orig-id: corr
        type: s4
        doc: |
          A signed integer specifying the value of leap-second correction
          (LEAPCORR) on or after the occurrence. The correction value in the
          first leap-second record, if present, MUST be either one (1) or
          negative one (-1). The correction values in adjacent leap-second
          records MUST differ by exactly one (1). The value of LEAPCORR is zero
          (0) for timestamps that occur before the occurrence time in the first
          leap-second record (or for all timestamps if there are no leap-second
          records).
  tz_footer:
    doc-ref: https://tools.ietf.org/html/rfc8536#section-3.3
    seq:
      - id: head_nl
        contents: [0x0a]
      - id: tz_string
        type: str
        encoding: ASCII
        terminator: 0x0a
        consume: false
        doc: |
          A rule for computing local time changes after the last transition time
          stored in the version 2+ data block. The string is either empty or
          uses the expanded format of the `TZ` environment variable as defined
          by POSIX with ASCII encoding, possibly utilizing extensions for
          version 3+ data blocks as described in section 3.3.1 of RFC 8536. If
          the string is empty, the corresponding information is not available.
          If the string is nonempty and one or more transitions appear in the
          version 2+ data, the string MUST be consistent with the last version
          2+ transition. The string MUST NOT contain NUL octets or by
          NUL-terminated, and it SHOULD NOT begin with the ':' (colon)
          character.
      - id: tail_nl
        contents: [0x0a]
