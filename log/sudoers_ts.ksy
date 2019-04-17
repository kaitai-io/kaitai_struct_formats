meta:
  id: sudoers_ts
  title: Sudoers Time Stamp file
  license: CC0-1.0
  endian: le
doc: |
  This spec can be used to parse sudo time stamp files located in directories
  such as /run/sudo/ts/$USER or /var/lib/sudo/ts/$USER.
doc-ref: https://www.sudo.ws/man/1.8.27/sudoers_timestamp.man.html
seq:
  - id: records
    type: record
    repeat: eos
types:
  record:
    seq:
      - id: version
        doc: version number of the timestamp_entry struct
        type: u2
      - id: len_record
        doc: size of the record in bytes
        type: u2
        -orig-id: size
      - id: payload
        size: len_record - 4
        type:
          switch-on: version
          cases:
            1: record_v1
            2: record_v2
  record_v1:
    seq:
      - id: type
        doc: record type
        type: u2
        enum: ts_type
      - id: flags
        doc: record flags
        type: ts_flag
      - id: auth_uid
        doc: user ID that was used for authentication
        type: u4
      - id: sid
        doc: session ID associated with tty/ppid
        type: u4
      - id: ts
        doc: time stamp, from a monotonic time source
        type: timespec
      - id: ttydev
        doc: device number of the terminal associated with the session
        if: type == ts_type::tty
        type: u4
      - id: ppid
        doc: ID of the parent process
        if: type == ts_type::ppid
        type: u4
  record_v2:
    seq:
      - id: type
        doc: record type
        type: u2
        enum: ts_type
      - id: flags
        doc: record flags
        type: ts_flag
      - id: auth_uid
        doc: user ID that was used for authentication
        type: u4
      - id: sid
        doc: ID of the user's terminal session, if present (when type is TS_TTY)
        type: u4
      - id: start_time
        doc: start time of the session leader for records of type TS_TTY or of the parent process for records of type TS_PPID
        type: timespec
      - id: ts
        doc: actual time stamp, from a monotonic time source
        type: timespec
      - id: ttydev
        doc: device number of the terminal associated with the session
        if: type == ts_type::tty
        type: u4
      - id: ppid
        doc: ID of the parent process
        if: type == ts_type::ppid
        type: u4
  timespec:
    seq:
      - id: sec
        type: s8
        doc: seconds
      - id: nsec
        type: s8
        doc: nanoseconds
  ts_flag:
    seq:
      - id: reserved0
        doc: Reserved (unused) bits
        type: b6
      - id: anyuid
        doc: ignore uid
        type: b1
        -orig-id: TS_ANYUID
      - id: disabled
        doc: entry disabled
        type: b1
        -orig-id: TS_DISABLED
      - id: reserved1
        doc: Reserved (unused) bits
        type: b8
enums:
  ts_type:
    1: global
    2: tty
    3: ppid
    4: lockexcl
