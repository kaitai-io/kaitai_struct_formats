meta:
  id: specpr
  title: "SPECtrum Processing Routines Data Format 3/4/88"
  file-extension: spec
  license: Unlicense
  #encoding: "utf-8"
  encoding: "ascii"
  endian: be
doc: |
  Specpr records are fixed format, 1536 bytes/record. Record number
  counting starts at 0. Binary data are in IEEE format real numbers
  and non-byte swapped integers (compatiible with all Sun
  Microsystems, and Hewlett Packard workstations (Intel and some DEC
  machines are byte swapped relative to Suns and HPs). Each record may
  contain different information according to the following scheme.

  You can get some library of spectra from
  ftp://ftpext.cr.usgs.gov/pub/cr/co/denver/speclab/pub/spectral.library/splib06.library/
seq:
  - id: records
    type: record
    repeat: eos
types:
  icflag:
    doc: "it is big endian"
    seq:
      - id: reserved
        type: b26
      - id: isctb_type
        type: b1
        doc: |
          =0 ctb is civil time
          =1 ctb is universal time
      - id: iscta_type
        type: b1
        doc: |
          =0 cta is civil time
          =1 cta is universal time
      - id: coordinate_mode
        type: b1
        doc: |
          RA, Dec / Long., Lat flag
          =0 the array "ira" and "idec" corresponds to the right ascension and declination of an astronomical object.
          =1 the array "ira" and "idec" correspond to the longitude and latitude of a spot on a planetary surface.
      - id: errors
        type: b1
        doc: >
          flag to indicate whether or not the data for the error bar (1 sigma standard deviation of the mean) is in the next record set.
          =0: no errors, =1: errors in next record set.
      # - id: type
        # type: b2
        # enum: record_type
      - id: text
        type: b1
        doc: |
          =0 the data in the array "data" is data
          =1 the data in the array "data" is ascii text as is most of the header info.
      - id: continuation
        type: b1
        doc: |
          =0 first record of a spectrum consists of: header then 256 data channels
          =1 continuation data record consisting of:
            # bit flags followed by 1532 bytes of
            # real data (bit 1=0) (383 channels)
            # or 1532 bytes of text (bit 1=1).
            # A maximum of 12 continuation records
            # are allowed for a total of 4852
            # channels (limited by arrays of 4864)
            # or 19860 characters of text (bit 1=1).
    instances:
      type:
        value: text.to_i * 1 + continuation.to_i * 2
        enum: record_type
  identifiers:
    seq:
      - id: ititle
        type: str
        size: 40
        pad-right: 0x20
        doc: "Title which describes the data"
      - id: usernm
        type: str
        size: 8
        doc: "The name of the user who created the data record"
  coarse_timestamp:
    seq:
     - id: scaled_seconds
       type: s4
    instances:
      seconds:
        value: scaled_seconds * 24000.
  illum_angle:
    seq:
     - id: angl
       type: s4
       doc: >
          (Integer*4 number, in arc-seconds*6000).
          (90 degrees=1944000000; -90 deg <= angle <= 90 deg)
    instances:
      seconds_total:
        value: angl / 6000
      minutes_total:
        value: seconds_total / 60
      degrees_total:
        value: minutes_total / 60
  data_initial:
    seq:
      - id: ids
        type: identifiers
      - id: iscta
        type: coarse_timestamp
        doc: "Civil or Universal time when data was last processed"
      - id: isctb
        type: coarse_timestamp
        doc: "Civil or Universal time at the start of the spectral run"
      - id: jdatea
        type: s4
        doc: "Date when data was last processed. Stored as integer*4 Julian Day number *10"
      - id: jdateb
        type: s4
        doc: "Date when the spectral run began. Stored as integer*4 Julian Day number *10"
      - id: istb
        type: coarse_timestamp
        doc: "Siderial time when the spectral run started. See flag #05."
      - id: isra
        type: s4
        doc: "Right ascension coordinates of an astronomical  object, or longitude on a planetary surface (integer*4 numbers in seconds *1000) (RA in RA seconds, Longitude in arc-seconds) See flag #06."
      - id: isdec
        type: s4
        doc: "Declination coordinates of an astronomical object, or latitude on a planetary surface (integer*4 number in arc-seconds *1000). See flag #06."
      - id: itchan
        type: s4
        doc: "Total number of channels in the spectrum (integer*4 value from 1 to 4852)"
      - id: irmas
        type: s4
        doc: "The equivalent atmospheric thickness through which the observation was obtained (=1.0 overhead scaled: airmass*1000; integer*4)."
      - id: revs
        type: s4
        doc: "The number of independent spectral scans which were added to make the spectrum (integer*4 number)."
      - id: iband
        type: s4
        doc: "The channel numbers which define the band normalization (scaling to unity). (integers*4)."
        repeat: expr
        repeat-expr: 2
      - id: irwav
        type: s4
        doc: "The record number within the file where the wavelengths are found (integer*4)."
      - id: irespt
        type: s4
        doc: "The record pointer to where the resolution can be found (or horizontal error bar) (integer*4)."
      - id: irecno
        type: s4
        doc: "The record number within the file where the data is located (integer*4 number)."
      - id: itpntr
        type: s4
        doc: "Text data record pointer. This pointer points to a data record where additional text describing the data may be found.  (32 bit integer)"
      - id: ihist
        type: str
        size: 60
        pad-right: 0x20
        doc: "The program automatic 60 character history."
      - id: mhist
        type: str
        size: 74
        doc: "Manual history. Program automatic for large history requirements."
        repeat: expr
        repeat-expr: 4
      - id: nruns
        type: s4
        doc: "The number of independent spectral runs which were summed or averaged to make this spectrum (integer*4)."
      - id: siangl
        type: illum_angle
        doc: >
          The angle of incidence of illuminating radiation
                integrating sphere = 2000000000
                Geometric albedo   = 2000000001
      - id: seangl
        type: illum_angle
        doc: >
          The angle of emission of illuminating radiation
                integrating sphere = 2000000000
                Geometric albedo   = 2000000001
      - id: sphase
        type: s4
        doc: >
          The phase angle between iangl and eangl
          (Integer*4 number, in arc-seconds*1500).
          (180 degrees=972000000; -180 deg <= phase <= 180 deg)
                integrating sphere = 2000000000
      - id: iwtrns
        type: s4
        doc: "Weighted number of runs (the number of runs of the spectrum with the minimum runs which was used in processing this spectrum, integer*4)."
      - id: itimch
        type: s4
        doc: "The time observed in the sample beam for each half chop in milliseconds (for chopping spectrometers only). (integer*4)"
      - id: xnrm
        type: f4
        doc: "The band normalization factor. For data scaled to 1.0, multiply by this number to recover photometric level (32 bit real number)."
      - id: scatim
        type: f4
        doc: "The time it takes to make one scan of the entire spectrum in seconds (32 bit real number)."
      - id: timint
        type: f4
        doc: "Total integration time (usually=scatime * nruns) (32 bit real number)."
      - id: tempd
        type: f4
        doc: "Temperature in degrees Kelvin (32 bit real number)."
      - id: data
        type: f4
        doc: "The spectral data (256 channels of 32 bit real data numbers)."
        repeat: expr
        repeat-expr: 256
    instances:
      phase_angle_arcsec:
        value: sphase / 1500.
        doc: "The phase angle between iangl and eangl in seconds"
  data_continuation:
    seq:
      - id: cdata
        type: f4
        repeat: expr
        repeat-expr: 383
        doc: "The continuation of the data values (383 channels of 32 bit real numbers)."
  text_initial:
    seq:
      - id: ids
        type: identifiers
      - id: itxtpt
        type: u4
        doc: "Text data record pointer. This pointer points  to a data record where additional text may be may be found."
      - id: itxtch
        type: s4
        doc: "The number of text characters (maximum= 19860)."
      - id: itext
        type: str
        size: 1476
        doc: "1476 characters of text.  Text has embedded newlines so the number of lines available is limited only by the number of characters available."
  text_continuation:
    seq:
      - id: tdata
        type: str
        size: 1532
        doc: "1532 characters of text."
  record:
    seq:
    - id: icflag
      type: icflag
      doc: "Total number of bytes comprising the document."
    - id: content
      size: 1536 - 4
      type:
        switch-on: icflag.type
        cases:
          'record_type::data_initial': data_initial
          'record_type::data_continuation': data_continuation
          'record_type::text_initial': text_initial
          'record_type::text_continuation': text_continuation
enums:
  record_type: # if I use 0b notation it doesn't work
    0: data_initial
    2: data_continuation
    1: text_initial
    3: text_continuation
