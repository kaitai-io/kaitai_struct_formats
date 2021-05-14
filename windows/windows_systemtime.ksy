meta:
  id: windows_systemtime
  title: Microsoft Windows SYSTEMTIME structure
  license: CC0-1.0
  endian: le
doc: |
  Microsoft Windows SYSTEMTIME structure, stores individual components
  of date and time as individual fields, up to millisecond precision.
doc-ref: https://docs.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-systemtime
seq:
  - id: year
    -orig-id: wYear
    type: u2
    doc: Year
  - id: month
    -orig-id: wMonth
    type: u2
    doc: Month (January = 1)
  - id: dow
    -orig-id: wDayOfWeek
    type: u2
    doc: Day of week (Sun = 0)
  - id: day
    -orig-id: wDay
    type: u2
    doc: Day of month
  - id: hour
    -orig-id: wHour
    type: u2
    doc: Hours
  - id: min
    -orig-id: wMinute
    type: u2
    doc: Minutes
  - id: sec
    -orig-id: wSecond
    type: u2
    doc: Seconds
  - id: msec
    -orig-id: wMilliseconds
    type: u2
    doc: Milliseconds
