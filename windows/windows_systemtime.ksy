meta:
  id: windows_systemtime
  endian: le
  title: Microsoft Windows SYSTEMTIME structure
# https://msdn.microsoft.com/en-us/library/windows/desktop/ms724950.aspx
doc: |
  Microsoft Windows SYSTEMTIME structure, stores individual components
  of date and time as individual fields, up to millisecond precision.
seq:
  - id: year
    type: u2
    doc: Year
  - id: month
    type: u2
    doc: Month (January = 1)
  - id: dow
    type: u2
    doc: Day of week (Sun = 0)
  - id: day
    type: u2
    doc: Day of month
  - id: hour
    type: u2
    doc: Hours
  - id: min
    type: u2
    doc: Minutes
  - id: sec
    type: u2
    doc: Seconds
  - id: msec
    type: u2
    doc: Milliseconds
