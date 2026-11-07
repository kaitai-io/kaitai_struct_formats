meta:
  id: zlf
  title: ZLF (Z-Wave Log File)
  application: Silicon Labs Z-Wave Zniffer
  file-extension: zlf
  tags:
    - home-automation
    - z-wave
  license: MIT
  endian: le
doc: |
  Z-Wave Zniffer capture file format (.zlf). Produced by the Silicon Labs
  Zniffer application. The file starts with a 2048-byte header followed
  by a flat sequence of variable-length entries until EOF. There is no
  entry count -- you keep reading until there are not enough bytes left
  for the 14-byte minimum overhead.

  Each entry wraps a chunk of captured data together with a .NET DateTime
  timestamp, a control byte encoding direction and session ID, and an
  end marker that identifies the entry kind (RF data vs file attachment).

  A single data frame can span multiple consecutive entries. Frame
  completeness is determined by the data frame's internal
  `remaining_length` field, not by entry-level flags. Reassembly is a
  runtime concern for the consumer -- this spec covers the container
  format only.
doc-ref: https://www.silabs.com/documents/public/user-guides/INS10249-Z-Wave-Zniffer-User-Guide.pdf
seq:
  - id: header
    type: header
    doc: Fixed 2048-byte file header.
  - id: entries
    type: entry
    repeat: eos
    doc: Sequence of timestamped capture entries until EOF.
types:
  header:
    doc: |
      Fixed 2048-byte file header. Contains a version byte, 2045 bytes
      of reserved space (zeroed in all observed files), and a big-endian
      checksum over the header.
    seq:
      - id: version
        type: u1
        doc: Zniffer version that wrote the file.
      - id: reserved
        size: 2045
        doc: Reserved space, zeroed in all observed files.
      - id: checksum
        type: u2be
        doc: Big-endian checksum over the header bytes.

  entry:
    -webide-representation: "{timestamp} {end_marker} len={len_payload:dec}"
    doc: |
      A single ZLF entry. Wraps a chunk of captured data together with
      a timestamp, a control byte, and an end marker. The structure has
      14 bytes of fixed overhead plus a variable-length payload.

      Navigation: next entry offset = current_offset + 14 + len_payload.

      A single data frame can span multiple consecutive entries, so an
      individual entry's payload may be just a fragment that needs to be
      reassembled before parsing. Do not use the first byte of a
      continuation entry to detect boundaries -- it can be any byte
      value, including 0x21.
    seq:
      - id: timestamp
        type: dotnet_datetime
        doc: |
          .NET DateTime value encoded as ticks (100 ns units since
          0001-01-01). Bits 63-62 encode DateTimeKind (0 = Unspecified,
          1 = UTC, 2 = Local) and must be masked off before converting.
          In .NET, `DateTime.FromBinary()` handles this automatically.
      - id: control
        type: control_byte
        doc: Direction flag and session ID packed in one byte.
      - id: len_payload
        -orig-id: payload_length
        type: u4
        doc: |
          Number of payload bytes that follow. Does not include the
          end marker byte.
      - id: payload
        size: len_payload
        doc: |
          Raw payload bytes. The ZLF container does not distinguish
          first-in-frame entries from continuation entries, so this
          field is left unparsed. For first-in-frame entries the first
          byte is a Zniffer message type marker (0x21 = data frame,
          0x23 = command frame), but for continuation entries it is
          raw MPDU data -- the same byte value can appear either way.
          Interpreting the payload requires tracking frame boundaries
          across entries at runtime.
      - id: end_marker
        type: u1
        enum: end_markers
        doc: |
          Entry kind marker. Kind = 0xFE - end_marker.
          rf_data (0xFE) = captured RF data.
          file_attachment (0xF8) = embedded file (e.g. S0/S2 encryption
          keys for decrypting frames when the capture is reopened, see
          INS10249 section 7.5).
    instances:
      kind:
        value: 0xFE - end_marker.to_i
        doc: |
          Entry kind derived from end_marker: kind = 0xFE - end_marker.
          0 = RF data entry (captured frames).
          6 = file attachment (encryption keys, skip for RF parsing).

  dotnet_datetime:
    -webide-representation:
      "{date_year:dec}-{date_month:dec}-{date_day:dec}
      {time_hour:dec}:{time_minute:dec}:{time_second:dec}"
    doc: |
      .NET DateTime stored as 8 LE bytes. The Zniffer application is a
      .NET Windows application (INS10249 section 3.1 lists .NET Framework
      4.6.1 as a prerequisite), and timestamps are the raw output of
      `DateTime.ToBinary()`.

      Bits 63-62 = DateTimeKind, bits 61-0 = ticks (100 ns intervals
      since 0001-01-01 00:00:00). Split into two u4 fields so the Kaitai
      Web IDE (JavaScript) can compute `unix_epoch_s` without 64-bit
      integer overflow.

      For non-.NET consumers, convert ticks to Unix epoch seconds:
      `(ticks - 621355968000000000) / 10000000`, or to milliseconds
      (for JavaScript's Date) with
      `(ticks - 621355968000000000) / 10000`.

      Date components are computed using Howard Hinnant's
      `civil_from_days` algorithm (pure integer arithmetic, no loops).
    seq:
      - id: lo
        type: u4
        doc: Lower 32 bits of the raw 8-byte value.
      - id: hi
        type: u4
        doc: Upper 32 bits (includes DateTimeKind in bits 31-30).
    instances:
      datetime_kind:
        value: (hi >> 30) & 0x3
        enum: datetime_kinds
        doc: 0 = Unspecified, 1 = UTC, 2 = Local.
      ticks_hi:
        value: hi & 0x3FFFFFFF
        doc: Upper 30 bits of ticks (DateTimeKind masked off).
      unix_epoch_s:
        value: ticks_hi * 429.4967296 + lo / 10000000.0 - 62135596800
        doc: |
          Unix timestamp in seconds (since 1970-01-01 00:00:00 UTC).
          Computed as: (ticks_hi * 2^32 + lo) / 10,000,000 -
          epoch_offset. The constant 429.4967296 = 2^32 / 10,000,000.
      seconds_in_day:
        value: unix_epoch_s % 86400
        doc: Seconds elapsed in the current day (for time-of-day).
      time_hour:
        value: (seconds_in_day / 3600).to_i
        -webide-parse-mode: eager
        doc: Hour of day (0-23).
      time_minute:
        value: ((seconds_in_day % 3600) / 60).to_i
        -webide-parse-mode: eager
        doc: Minute (0-59).
      time_second:
        value: (seconds_in_day % 60).to_i
        -webide-parse-mode: eager
        doc: Second (0-59).
      unix_days:
        value: (unix_epoch_s / 86400).to_i
        doc: Days since 1970-01-01 (intermediate for date computation).
      civil_z:
        value: unix_days + 719468
        doc: Days since 0000-03-01 (Hinnant algorithm intermediate).
      civil_era:
        value: civil_z / 146097
        doc: 400-year era (Hinnant algorithm intermediate).
      civil_doe:
        value: civil_z - civil_era * 146097
        doc: Day of era 0-146096 (Hinnant algorithm intermediate).
      civil_yoe:
        value: >-
          (civil_doe - civil_doe / 1461 + civil_doe / 36524 - civil_doe
          / 146096) / 365
        doc: Year of era 0-399 (Hinnant algorithm intermediate).
      civil_doy:
        value: >-
          civil_doe - (365 * civil_yoe + civil_yoe / 4 - civil_yoe
          / 100)
        doc: Day of year 0-365 (Hinnant algorithm intermediate).
      civil_mp:
        value: (5 * civil_doy + 2) / 153
        doc: Month proxy 0-11 where March=0 (Hinnant intermediate).
      date_day:
        value: "civil_doy - (153 * civil_mp + 2) / 5 + 1"
        -webide-parse-mode: eager
        doc: Day of month (1-31).
      date_month:
        value: "civil_mp < 10 ? civil_mp + 3 : civil_mp - 9"
        -webide-parse-mode: eager
        doc: Month (1-12).
      date_year:
        value: "civil_yoe + civil_era * 400 + (date_month <= 2 ? 1 : 0)"
        -webide-parse-mode: eager
        doc: Year (e.g. 2025).

  control_byte:
    -webide-representation: "{direction}"
    doc: |
      Entry control byte. Bit 7 = direction, bits 6-0 = session ID.
      In observed files the session ID is 0x01. Most entries are
      direction=received (captured RF traffic), but a small number
      of direction=sent entries appear for command frames sent to
      the Zniffer module.
    seq:
      - id: direction
        type: b1
        enum: directions
        doc: 0 = received (incoming RF), 1 = sent (outgoing).
      - id: session_id
        type: b7
        doc: Capture session ID (0-127).

enums:
  end_markers:
    0xFE: rf_data
    0xF8: file_attachment

  directions:
    0: received
    1: sent

  datetime_kinds:
    0: unspecified
    1: utc
    2: local
