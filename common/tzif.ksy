meta:
  id: tzif
  title: The Time Zone Information Format (TZif)
  xref:
    mime:
      - application/tzif
      - application/tzif-leap
    rfc: 8536
  license: CC0-1.0
  ks-version: 0.9
  endian: be
doc: |
  TZif is the binary file format used to represent data for a single time zone
  compiled by the _zic_ compiler from information in the IANA time zone
  database. It is used by most UNIX systems to calculate local time for a time
  zone, usually identified by a time zone identifier string referring to a
  relatively populous location within the geographic region covered by the time
  zone, for example: "America/New_York" or "Europe/Paris". This identifier is
  external to the TZif file itself.
seq:
  - id: v1_struct
    type: tz_struct(false)
  - id: v2_struct
    type: tz_struct(true)
    if: version >= 2
    valid:
      expr: '_.header.ver_byte == _root.v1_struct.header.ver_byte'
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
        type: >-
          tz_data(is_ts64, header.num_transitions, header.num_local_time_types,
          header.len_tz_designations, header.num_leap_second_records,
          header.num_std_flags, header.num_ut_flags)
  tz_header:
    doc-ref: https://tools.ietf.org/html/rfc8536#section-3.1
    seq:
      - id: magic
        contents: TZif
      - id: ver_byte
        -orig-id: ver
        type: u1
        valid:
          expr: '_ == 0 or (_ >= 0x32 and _ <= 0x39)'
          # not sure what would be used after 0x39, but unlikely to get there
        doc: |
          Identifies version of file's format. Version 1 sets the byte to ASCII
          NUL. Version 2 onwards sets it to the corresponding ASCII digit.
      - id: reserved
        size: 15
        doc: Fifteen bytes defaulting to zeros, reserved for future use.
      - id: num_ut_flags
        -orig-id: isutcnt
        type: u4
        # validated in 'num_local_time_types' below
        doc: |
          Number of UT/local indicators contained in the data block. MUST
          either be 0 or equal to `num_local_time_types`.
      - id: num_std_flags
        -orig-id: isstdcnt
        type: u4
        # validated in 'num_local_time_types' below
        doc: |
          Number of standard/wall indicators contained in the data block. MUST
          either be 0 or equal to `num_local_time_types`.
      - id: num_leap_second_records
        -orig-id: leapcnt
        type: u4
        doc: Number of leap-second records contained in the data block.
      - id: num_transitions
        -orig-id: timecnt
        type: u4
        doc: |
          Number of transition times and transition types (same number)
          contained in the data block.
      - id: num_local_time_types
        -orig-id: typecnt
        type: u4
        valid:
          expr: >
            _ != 0 and (num_ut_flags == 0 or _ == num_ut_flags) and
            (num_std_flags == 0 or _ == num_std_flags)
        doc: |
          Number of local time type records contained in the data block. MUST
          NOT be 0.
      - id: len_tz_designations
        -orig-id: charcnt
        type: u4
        valid:
          expr: '_ != 0'
        doc: |
          Total number of octets used by the set of time zone designations
          contained in the data block. MUST NOT be 0.
    instances:
      version:
        value: 'ver_byte >= 0x32 ? ver_byte - 0x30 : 1'
        doc: |
          File format version number derived from `ver_byte`. The most recent
          version as of March 2021 is 4.
  tz_data:
    doc-ref: https://tools.ietf.org/html/rfc8536#section-3.2
    params:
      - id: is_ts64
        type: bool
        doc: |
          Chooses whether to use 64-bit or 32-bit time values. Set to `false`
          for 32-bit time values (used in the version 1 data block). Set to
          `true` for 64-bit time values (used in the version 2+ data block).
      - id: num_transitions
        type: u4
        doc: Number of transition times and transition types (same number).
      - id: num_local_time_types
        type: u4
        doc: Number of local time types.
      - id: len_tz_designations
        type: u4
        doc: |
          Length of space (in octets) holding the time zone designation strings.
      - id: num_leap_second_records
        type: u4
        doc: Number of leap-second records.
      - id: num_std_flags
        type: u4
        doc: Number of standard/wall indicator flags.
      - id: num_ut_flags
        type: u4
        doc: Number of UT/local indicator flags.
    seq:
      - id: transition_times
        type:
          switch-on: is_ts64
          cases:
            false: s4
            true: s8
        repeat: expr
        repeat-expr: num_transitions
        # Note: `num_transitions` also as repeat count for `transition_types`.
        doc: |
          Array of POSIX time values sorted in ascending order. Each is used as
          a transition time at which the rules for computing local time change.
      - id: transition_types
        type: u1
        repeat: expr
        repeat-expr: num_transitions
        # Note: `num_transitions` also as repeat count for `transition_times`.
        doc: |
          Array of transition type numbers. All but the last one map transition
          times in the `transition_times` array to local time type records in
          the `local_time_types` array. (The last one is present only for
          consistency checking with the POSIX-style TZ string at the end of the
          file.) The transition type numbers MUST be less than
          `num_local_time_types` (the length of the `local_time_types` array).
      - id: local_time_types
        type: tz_local_time_type
        repeat: expr
        repeat-expr: num_local_time_types
        doc: Local time type records.
      - id: tz_designations
        size: len_tz_designations
        valid:
          expr: '_.last == 0'
          # Technically, the last byte of `tz_designations` does not have to be
          # NUL; there just needs to be a NUL byte at or beyond the greatest
          # `desig_idx` in the local time type records.  Practically, writers
          # do not put junk after the last NUL byte.
        doc: |
          Space for one or more NUL-terminated time zone designation strings.
          Two designation strings MAY overlap if one is a suffix of the other.
          The character encoding is not specified. For POSIX compatibility,
          designation strings SHOULD consist of between three (3) and six (6)
          ASCII characters from the set of alphanumerics, '-', and '+'.
      - id: leap_second_records
        type: tz_leap_second_record(is_ts64)
        repeat: expr
        repeat-expr: num_leap_second_records
        doc: |
          Array of leap-second records sorted in ascending order of occurrence
          time for successive leap-second corrections. For versions 1 to 3, the
          first leap-second record, if present, MUST have a non-negative
          occurrence time and MUST have a correction value of either negative
          one (-1) or one (1). For version 4+, the first leap-second value may
          have any value to support TZif files with reduced timestamp range.
          Each succeeding leap-second record MUST have an occurrence time at
          least 2419199 greater than that of the previous record. The correction
          values of two successive leap-second records except the last two
          records MUST differ by exactly one (1). For versions 1 to 3, the
          correction values of the last two leap-second records MUST differ by
          exactly one (1). For version 4+, the correction values of the last two
          leap-second records MUST differ by no more than one (1) but MAY be
          equal. If the last two correction values are equal then the last
          leap-second record denotes the expiration of the leap-second table
          instead of a leap second.
      - id: std_flags
        # standard/wall indicators
        type: u1
        repeat: expr
        repeat-expr: num_std_flags
        doc: |
          Array of values indicating whether the transition times associated
          with the corresponding local time types were specified as standard
          time or wall-clock time. If the length of the array is zero then all
          transition times associated with local time types are assumed to be
          specified as wall-clock time. Each value MUST be 0 or 1. A value of
          one (1) indicates standard time. A value of zero (0) indicates
          wall-clock time. The value MUST be one (1) if the corresponding
          UT/local indicator in the `ut_flags` array is one (1).
      - id: ut_flags
        # UT/local indicators
        type: u1
        repeat: expr
        repeat-expr: num_ut_flags
        doc: |
          Array of values indicating whether the transition times associated
          with the corresponding local time types were specified as UT or local
          time. If the length of the array is zero then all transition times
          associated with local time types are assumed to be specified as local
          time. Each values MUST be 0 or 1. A value of one (1) indicates UT. A
          value of zero (0) indicates local time. If the value is one (1) then
          the corresponding standard/wall indicator in `std_flags` MUST also be
          set to one (1).
  tz_local_time_type:
    doc-ref: https://tools.ietf.org/html/rfc8536#section-3.2
    seq:
      - id: ut_offset
        -orig-id: utoff
        type: s4
        doc: |
          Number of seconds to be added to UT in order to determine local time.
          The value MUST NOT be -2**31 and SHOULD be in the range [-89999,
          93599].
      - id: dst_flag
        -orig-id: dst
        type: u1
        valid:
          any-of: [0, 1]
        doc: |
          Indicates whether local time should be considered Daylight Saving Time
          (DST). The value MUST be 0 or 1. A value of one (1) indicates that
          this time type is DST. A value of zero (0) indicates that this time
          type is standard time.
      - id: desig_idx
        -orig-id: idx
        type: u1
        valid:
          expr: '_ < _parent.len_tz_designations'
        doc: |
          Specifies a zero-based index into the `_parent.tz_designations` array
          of time zone designation octets. The index MUST be less than
          `_parent.len_tz_designations`. The time zone designation string for
          this local time type starts at the specified index within the array
          and MUST be NUL-terminated, but MAY be empty.
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
      - id: occurrence
        -orig-id: occur
        type:
          switch-on: is_ts64
          cases:
            false: s4
            true: s8
        doc: |
          A POSIX time value specifying the time at which a leap-second
          correction occurs.
      - id: correction
        -orig-id: corr
        type: s4
        doc: |
          A signed integer specifying the value of leap-second correction on or
          after the occurrence.
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
          The string is either empty or is a POSIX-style TZ string specifying
          the rule for computing local time changes after the last transition
          time stored in the version 2+ data block. If the string is empty, the
          corresponding information is not available. If the string is nonempty,
          it MUST NOT contain NUL octets, MUST NOT be NUL-terminated, and SHOULD
          NOT begin with the ':' (colon) character. If the string is nonempty
          and one or more transitions appear in the version 2+ data, the string
          MUST be consistent with the last version 2+ transition. For version
          3+, the string MAY utilize the extensions to POSIX TZ strings
          described in section 3.3.1 of RFC 8536.
      - id: tail_nl
        contents: [0x0a]
