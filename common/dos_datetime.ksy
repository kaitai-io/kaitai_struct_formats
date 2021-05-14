meta:
  id: dos_datetime
  title: MS-DOS datetime
  xref:
    justsolve: MS-DOS_date/time
  tags:
    - dos
  license: CC0-1.0
  ks-version: 0.9
  bit-endian: le
doc: |
  MS-DOS date and time are packed 16-bit values that specify local date/time.
  The time is always stored in the current UTC time offset set on the computer
  which created the file. Note that the daylight saving time (DST) shifts
  also change the UTC time offset.

  For example, if you pack two files A and B into a ZIP archive, file A last modified
  at 2020-03-29 00:59 UTC+00:00 (GMT) and file B at 2020-03-29 02:00 UTC+01:00 (BST),
  the file modification times saved in MS-DOS format in the ZIP file will vary depending
  on whether the computer packing the files is set to GMT or BST at the time of ZIP creation.

    - If set to GMT:
        - file A: 2020-03-29 00:59 (UTC+00:00)
        - file B: 2020-03-29 01:00 (UTC+00:00)
    - If set to BST:
        - file A: 2020-03-29 01:59 (UTC+01:00)
        - file B: 2020-03-29 02:00 (UTC+01:00)

  It follows that you are unable to determine the actual last modified time
  of any file stored in the ZIP archive, if you don't know the locale time
  setting of the computer at the time it created the ZIP.

  This format is used in some data formats from the MS-DOS era, for example:

    - [zip](/zip/)
    - [rar](/rar/)
    - [vfat](/vfat/) (FAT12)
    - [lzh](/lzh/)
    - [cab](http://justsolve.archiveteam.org/wiki/Cabinet)

doc-ref:
  - https://docs.microsoft.com/en-us/windows/win32/sysinfo/ms-dos-date-and-time
  - https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-dosdatetimetofiletime
  - https://github.com/reactos/reactos/blob/c6b6444/dll/win32/kernel32/client/time.c#L82-L87 DosDateTimeToFileTime
  - https://download.microsoft.com/download/0/8/4/084c452b-b772-4fe5-89bb-a0cbf082286a/fatgen103.doc page 25/34
-webide-representation: "{date} {time}"
seq:
  - id: time
    type: time
  - id: date
    type: date
types:
  time:
    -webide-representation: "{padded_hour}:{padded_minute}:{padded_second}"
    seq:
      - id: second_div_2
        type: b5
        valid:
          max: 29 # 0-58 seconds
      - id: minute
        type: b6
        valid:
          max: 59
      - id: hour
        type: b5
        valid:
          max: 23
    instances:
      second:
        value: 2 * second_div_2
      padded_second:
        value: '(second <= 9 ? "0" : "") + second.to_s'
      padded_minute:
        value: '(minute <= 9 ? "0" : "") + minute.to_s'
      padded_hour:
        value: '(hour <= 9 ? "0" : "") + hour.to_s'
  date:
    -webide-representation: "{padded_year}-{padded_month}-{padded_day}"
    seq:
      - id: day
        type: b5
        valid:
          min: 1
      - id: month
        type: b4
        valid:
          min: 1
          max: 12
      - id: year_minus_1980
        type: b7
    instances:
      year:
        value: 1980 + year_minus_1980
        doc: only years from 1980 to 2107 (1980 + 127) can be represented
      padded_day:
        value: '(day <= 9 ? "0" : "") + day.to_s'
      padded_month:
        value: '(month <= 9 ? "0" : "") + month.to_s'
      padded_year:
        value: |
          (year <= 999 ? "0" +
            (year <= 99 ? "0" +
              (year <= 9 ? "0" : "")
            : "")
          : "") + year.to_s
