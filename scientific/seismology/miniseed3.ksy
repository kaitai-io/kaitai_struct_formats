meta:
  id: miniseed3
  title: "MiniSEED 3 Data Format"
  file-extension: 
    - mseed3 
    - mseed
  license: MIT
  encoding: ascii
  endian: le
doc: |
  MiniSEED 3 is a binary data format defined by the International Federation of Digital 
  Seismograph Networks (FDSN) for data collection, archiving and exchange of seismological data. 
doc-ref: https://docs.fdsn.org/projects/miniseed3
seq:
  - id: data_record
    type: data_record
types:
  data_record: 
    doc-ref: https://docs.fdsn.org/projects/miniseed3/en/latest/definition.html#description-of-record-fields
    seq: 
      - id: record_header_indicator
        contents: "MS"
      - id: format_version
        type: u1
      - id: flags
        type: miniseed_flags 
      - id: record_start_time
        type: miniseed_time
      - id: data_payload_encoding
        type: u1
        enum: miniseed_data_encoding
      - id: sample_rate_or_period
        type: f8
      - id: number_of_samples
        type: u4
      - id: crc_of_the_record
        type: u4
      - id: data_publication_version
        type: u1
      - id: length_of_identifier
        type: u1
      - id: length_of_extra_headers
        type: u2
      - id: length_of_data_payload
        type: u4
      - id: source_identifier
        type: str
        size: length_of_identifier
        encoding: ASCII
      - id: extra_header_fields
        type: str
        size: length_of_extra_headers
        encoding: ASCII
      - id: data_payload
        type: 
          switch-on: data_payload_encoding
          cases: 
            'miniseed_data_encoding::encoding_text': miniseed_data_encoding_text 
            'miniseed_data_encoding::encoding_16_bit_integer': miniseed_data_encoding_16_bit_integer
            'miniseed_data_encoding::encoding_32_bit_integer': miniseed_data_encoding_32_bit_integer
            'miniseed_data_encoding::encoding_32_bit_float': miniseed_data_encoding_32_bit_float
            'miniseed_data_encoding::encoding_64_bit_float': miniseed_data_encoding_64_bit_float
            'miniseed_data_encoding::encoding_steim_1': miniseed_data_encoding_unknown # Not yet supported
            'miniseed_data_encoding::encoding_steim_2': miniseed_data_encoding_unknown # Not yet supported
            'miniseed_data_encoding::encoding_steim_3': miniseed_data_encoding_unknown # Not yet supported
            'miniseed_data_encoding::encoding_opaque_data': miniseed_data_encoding_unknown 
  miniseed_flags:
    seq:
      - id: calibration_signals_present
        type: b1
      - id: time_tag_is_questionable
        type: b1
      - id: clock_locked
        type: b1
      - id: reserved_flag_3
        type: b1
      - id: reserved_flag_4
        type: b1
      - id: reserved_flag_5
        type: b1
      - id: reserved_flag_6
        type: b1
      - id: reserved_flag_7
        type: b1 
  miniseed_time:
    seq:
      - id: nanosecond
        type: u4
      - id: year
        type: u2
      - id: day_of_year
        type: u2
      - id: hour
        type: u1
      - id: minute
        type: u1
      - id: second
        type: u1
  miniseed_data_encoding_unknown: 
    seq:
      - id: data
        type: u1
        repeat: eos
  miniseed_data_encoding_text: 
    seq:
      - id: data
        type: str
        size-eos: true
        encoding: UTF-8
  miniseed_data_encoding_16_bit_integer:
    seq:
      - id: data
        type: s2
        repeat: eos
  miniseed_data_encoding_32_bit_integer:
    seq:
      - id: data
        type: s4
        repeat: eos
  miniseed_data_encoding_32_bit_float:
    seq:
      - id: data
        type: f4
        repeat: eos
  miniseed_data_encoding_64_bit_float:
    seq:
      - id: data
        type: f8
        repeat: eos
enums:
  miniseed_data_encoding:
    0: encoding_text
    1: encoding_16_bit_integer
    3: encoding_32_bit_integer
    4: encoding_32_bit_float
    5: encoding_64_bit_float
    10: encoding_steim_1
    11: encoding_steim_2
    19: encoding_steim_3
    100: encoding_opaque_data
