meta:
  id: windows_timezone_information
  title: Microsoft Windows (DYNAMIC_)?TIME_ZONE_INFORMATION structure
  license: Unlicense
  endian: le
  imports:
    - /windows/windows_systemtime
doc: |
  Microsoft Windows (DYNAMIC_)?TIME_ZONE_INFORMATION structure, stores info about timezone.

doc-ref:
  - https://learn.microsoft.com/en-us/windows/win32/api/timezoneapi/ns-timezoneapi-time_zone_information
  - https://learn.microsoft.com/en-us/windows/win32/api/timezoneapi/ns-timezoneapi-dynamic_time_zone_information
-orig-id:
  - TIME_ZONE_INFORMATION
  - _TIME_ZONE_INFORMATION
seq:
  - id: basic
    type: basic
    -orig-id: TIME_ZONE_INFORMATION
  - id: dynamic
    type: dynamic
    if: _io.pos < _io.size

types:
  basic:
    seq:
      - id: bias
        -orig-id: Bias
        type: bias
      - id: standard
        -orig-id: StandardName, StandardDate, StandardBias
        type: piece
      - id: daylight
        -orig-id: DaylightName, DaylightDate, DaylightBias
        type: piece
    types:
      bias:
        seq:
          - id: bias
            -orig-id: Bias
            type: s4
            -unit: minute
            doc: in minutes, negative (GTM+3 will be -180)
        instances:
          gtm_hour_bias:
            value: bias / -60.
      piece:
        seq:
          - id: name
            -orig-id: StandardName, DaylightName
            type: str
            encoding: utf-16
            size: 32 * 2
          - id: date
            -orig-id: StandardDate, StandardDate
            type: windows_systemtime
          - id: bias
            -orig-id: StandardBias, DaylightBias
            type: bias
            doc: delta to `_parent.bias`
  dynamic:
    -orig-id: DYNAMIC_TIME_ZONE_INFORMATION
    seq:
      - id: time_zone_key_name
        -orig-id: TimeZoneKeyName
        type: str
        encoding: utf-16
        size: 128 * 2
      - id: dynamic_daylight_saving_disabled
        -orig-id: DynamicDaylightTimeDisabled
        type: u1
