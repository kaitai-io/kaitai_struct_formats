meta:
  id: mod
  title: Protracker 1.1B Module Format
  application:
    - Ultimate Soundtracker
    - Protracker
    - Modedit
    - ProTracker clone
    - MilkyTracker
    - libmodplug
    - Mikmod
  file-extension: mod
  xref:
    wikidata: Q1370814
  license: Unlicense
  endian: le
  encoding: UTF-8
doc: |
  An old tracker music file format.
  This ksy is based on the spec by Steinar Midtskogen.
  You can get some files to test by the following links:
    * https://modarchive.org/
    * http://www.keygenmusic.net/
doc-ref: https://web.archive.org/web/20020415142434/http://www.cwi.nl:80/ftp/audio/MOD-info Steinar Midtskogen<steinarm@ifi.uio.no> Old MOD. format + PowerPacking
seq:
  - id: song_name
    type: strz
    size: 20
    doc: Remember to put trailing null bytes at the end...
  - id: samples
    type: sample
    repeat: expr
    repeat-expr: application_id.sample_count
  - id: song_length
    type: u1
    doc: Range is 1-128.
  - id: special
    type: u1
    doc: Well... this little byte here is set to 127, so that old trackers will search through all patterns when loading. Noisetracker uses this byte for restart, but we don't. Protracker uses 0x7F.
    valid:
      eq: 127
  - id: song_positions
    type: pattern_index
    doc: Each hold a number from 0-63 that tells the tracker what pattern to play at that position.
    repeat: expr
    repeat-expr: 128
  - id: application_id_string
    type: application_id_string
    doc: "For the description see application_id type"
  - id: patterns
    type: pattern
    repeat: expr
    repeat-expr: song_positions.last.index
    doc: Number of patterns stored is equal to the highest pattern_number in the song position table (at offset 952-1079).

instances:
  application_id_31_pos:
    pos: 0
    type: application_id_pos_calc(31)
  application_id_15_pos:
    pos: 0
    type: application_id_pos_calc(15)
  application_id_31:
    pos: application_id_31_pos.pos
    type: application_id(31)
  application_id_15:
    pos: application_id_15_pos.pos
    type: application_id(15)
    if: not application_id_31.is_detected
  application_id:
    value: "(application_id_31.is_detected ? application_id_31 : application_id_15)"

types:
  application_id_pos_calc:
    -affected-by: 84
    #I have to do this shit manually :(
    params:
      - id: sample_count
        type: u1
    instances:
      pos:
        value: 20 + sizeof<sample>*sample_count + sizeof<u1> + sizeof<u1> + sizeof<pattern_index>*128
        doc: 20 is for `song_name`, `u1`s for `song_length` and `special`
  application_id_string:
    seq:
      - id: id
        type: str
        size: 4
        encoding: ascii
        doc: "For the description see application_id type"
  application_id:
    doc: |
      The four letters (in regex format)
        "M([\.!])K\1" - ProTracker 1 and 2. 4 channels, 31 sample. Supposedly it means Michael Kleps.
        "M&K!" - NoiseTracker, 4 channels, 15 samples. Supposedly M is for Mahoney and K for Kaktus.
        "FEST" - NoiseTracker, 4 channels
        "N.T." - NoiseTracker, 4 channels
        "NSMS" - Kingdom.mod, 4 channels
        "CD\d1" - Atari Oktalyzer, \d is number of channels
        "FA\d{2}" - Atari Falcon, \d{2} is number of channels
        "FLT[48]" - StarTrekker
        "O[KC]TA" - Amiga Oktalyzer
        "TDZ\d" - Taketracker, \d channels
        "\dCHN" - FastTracker II, \d is number of channels
        "\d{2}CH" - FastTracker, \d{2} is number of channels
        "\d{2}CN" - TakeTracker, \d{2} is number of channels
    params:
      - id: sample_count
        type: u1
    seq:
      - id: id
        type: application_id_string
    instances:
      is_detected:
        value: channels_count > 0
      channels_count:
        value: |
          (
               id.id == "M&K!"
            or id.id == "M!K!"
            or id.id == "M.K."
            or id.id == "FEST"
            or id.id == "N.T."
            or id.id == "NSMS"
            or id.id == "OKTA"
            or id.id == "OCTA"
          ) ? 4 :
            (
              (
                id.id.substring(0, 2) == "CD" ?
                id.id.substring(2, 3).to_i :
                (
                  id.id.substring(0, 2) == "FA" ?
                  id.id.substring(2, 4).to_i :
                  (
                    id.id.substring(0, 3)=="FLT" or id.id.substring(0, 3)=="TDZ" ?
                    id.id.substring(3, 4).to_i
                    :
                    (
                      id.id.substring(1,4)=="CHN" ?
                      id.id.substring(0, 1).to_i
                      :
                      (
                        id.id.substring(2,4) == "CH" or id.id.substring(2,4) == "CN" ?
                        id.id.substring(0, 2).to_i
                        : 0
                      )
                    )
                  )
                )
              )
            )
  bs4:
    seq:
      - id: sign
        type: b1
      - id: ext_mod
        type: b3
    instances:
      value:
        value: "(sign ? ext_mod - 0b1000 : ext_mod)"
  sample:
    -orig-id: sampleinfo
    seq:
      - id: name
        type: strz
        size: 22
        doc: Pad with null bytes.
      - id: length_words
        type: u2
        doc: Stored as number of words. Multiply by two to get real sample length in bytes.
      - id: reserved0
        type: b4
        doc: The upper four bits of fine_tune are not used, and should be set to zero.
      - id: fine_tune
        type: bs4
        doc: Lower four bits are the fine_tune value, stored as a SIGNED four bit number.
      - id: volume
        type: u1
        doc: From 0 to 64.
      - id: repeat_point
        type: u2
        doc:  Stored as number of words offset from start of sample. Multiply by two to get offset in bytes.
      - id: repeat_length
        type: u2
        doc:  Stored as number of words in loop. Multiply by two to get replen in bytes.
  pattern:
    seq:
      - id: sequence
        type: position
        repeat: expr
        repeat-expr: 64
    types:
      position:
        seq:
          - id: channels
            type: note
            repeat: expr
            repeat-expr: _root.application_id.channels_count
        types:
          note:
            seq:
              - id: sample_no_hi
                type: b4
              - id: period
                type: b12
              - id: sample_no_lo
                type: b4
              - id: effect_command
                type: b12
            instances:
              sample_no:
                value: (sample_no_hi<<4) | sample_no_lo

  pattern_index:
    seq:
      - id: index
        -orig-id: pattern_number
        type: u1
    instances:
      pattern:
        value: _parent.patterns[index]
