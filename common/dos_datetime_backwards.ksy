meta:
  id: dos_datetime_backwards
  title: MS-DOS datetime (backwards order - date first)
  tags:
    - dos
  license: CC0-1.0
  imports:
    - dos_datetime
doc: |
  Same as dos_datetime,
  but with the date field first and the time second,
  instead of the usual order where the time comes first.
  This "backwards" order is used in a few formats,
  e. g. those from InstallShield 3.
seq:
  - id: date
    type: dos_datetime::date
  - id: time
    type: dos_datetime::time
