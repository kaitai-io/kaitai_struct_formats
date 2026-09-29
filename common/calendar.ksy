meta:
  id: calendar
  title: Proleptic Gregorian calendar
  license: Unlicense
  endian: le
  xref:
    wikidata: Q1985727
-affected-by: https://github.com/kaitai-io/kaitai_struct_webide/issues/155
doc: |
  A set of types to compute a date from epoch offsets in days.
types:
  split_day_time:
    -web-ide-representation: "{day} {time}"
    doc: |
      This type is intended to facilitate splitting day from time within a day in a timestamp in seconds.
      The day can be passed to `epoch_date` then.
    params:
      - id: second_since_epoch
        type: u4
    seq:
      - id: time
        type: time(second_since_day)
    instances:
      hours_per_day:
        value: 24
      seconds_per_hour:
        value: &seconds_per_hour 3600
      seconds_per_day:
        value: seconds_per_hour * hours_per_day
      second_since_day:
        value: second_since_epoch % seconds_per_day
      day:
        value: second_since_epoch / seconds_per_day
  time:
    -web-ide-representation: "{hour}:{minute}:{second}"
    doc:
      Splits a timestamp within a day (in seconds) into clock time. Timezones are not taken into account.
    params:
      - id: seconds_since_day
        type: u4
    instances:
      seconds_per_hour:
        value: *seconds_per_hour
      seconds_per_minute:
        value: 60
      hour:
        value: seconds_since_day / seconds_per_hour
      second_in_hour:
        value: seconds_since_day % seconds_per_hour
      minute:
        value: second_in_hour / seconds_per_minute
      second:
        value: second_in_hour % seconds_per_minute
  cobol_date:
    meta:
      xref:
        iso: "1989:1985"
    -web-ide-representation: "{date}"
    params:
      - id: days_since_epoch
        -orig-id: z
        type: u4
        doc: the date in the form of count of days passed since epoch 1601-01-01
    seq:
      - id: date
        type: epoch_date(584694, days_since_epoch)
  unix_date:
    -web-ide-representation: "{date}"
    params:
      - id: days_since_epoch
        -orig-id: z
        type: u4
        doc: the date in the form of count of days passed since epoch 1970-01-01
    seq:
      - id: date
        type: epoch_date(719468, days_since_epoch)
  epoch_date:
    -web-ide-representation: "{date}"
    params:
      - id: epoch
        type: u4
        doc: the date in the form of count of days passed since epoch
      - id: days_since_epoch
        -orig-id: z
        type: u4
        doc: the date in the form of count of days passed since epoch
    seq:
      - id: date
        type: natural_epoch_date(epoch + days_since_epoch)
  natural_epoch_date:
    doc-ref: https://howardhinnant.github.io/date_algorithms.html#civil_from_days
    -web-ide-representation: "{year}-{month}-{day}"
    params:
      - id: days_since_natural_epoch
        -orig-id: z
        type: u4
        doc: the date in the form of count of days passed since epoch
    instances:
      year:
        -orig-id: y
        value: year_of_era + era * 400 + (month <= 2?1:0)
      month:
        -orig-id: m
        value: 'internal_month < 10 ? (internal_month+3) : (internal_month-9)'
      day:
        -orig-id: d
        value: day_of_year - (153 * internal_month + 2)/5 + 1
        #valid:
        #  min: 1
        #  max: 31
      leap_period:
        value: 4
      days_in_era:
        doc: civil calendar exactly repeats itself every this count of days.
        value: 146097
      max_day_in_era:
        value: days_in_era - 1
      era:
        value: '(days_since_natural_epoch >= 0 ? days_since_natural_epoch : days_since_natural_epoch - max_day_in_era) / days_in_era'
      day_of_era:
        value: days_since_natural_epoch - era * days_in_era
      era_beginning_years:
        value: 100
      days_in_year:
        value: 365
      days_in_era_beginning:
        value: days_in_year * era_beginning_years + era_beginning_years/leap_period - 1
      year_of_era:
        value: (day_of_era - day_of_era/(leap_period * days_in_year) + day_of_era/days_in_era_beginning - day_of_era/max_day_in_era) / days_in_year
        #valid:
        #  min: 0
        #  max: 399
      day_of_year:
        value: day_of_era - (days_in_year*year_of_era + year_of_era/4 - year_of_era/era_beginning_years)
        #valid:
        #  min: 0
        #  max: days_in_year
      internal_month:
        value: (5*day_of_year + 2)/153
        #valid:
        #  min: 0
        #  max: 11
