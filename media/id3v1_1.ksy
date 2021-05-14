meta:
  id: id3v1_1
  title: ID3v1.1 tag for .mp3 files
  file-extension: mp3
  xref:
    forensicswiki: ID3
    justsolve: ID3
    loc: fdd000107 # ID3v1
    wikidata: Q1054220
  license: CC0-1.0
doc: |
  ID3v1.1 tag is a method to store simple metadata in .mp3 files. The
  tag is appended to the end of file and spans exactly 128 bytes.

  This type is supposed to be used on full .mp3 files, seeking to
  proper position automatically. If you're interesting in parsing only
  the tag itself, please use `id3v1_1::id3_v1_1_tag` subtype.
doc-ref: https://id3.org/ID3v1
instances:
  id3v1_tag:
    pos: _io.size - 128
    type: id3_v1_1_tag
types:
  id3_v1_1_tag:
    doc: |
      ID3v1.1 tag itself, a fixed size 128 byte structure. Contains
      several metadata fields as fixed-size strings.

      Note that string encoding is not specified by standard, so real
      encoding used would vary a lot from one implementation to
      another. Most Windows-based applications tend to use "ANSI"
      (i.e. locale-dependent encoding, usually one byte per
      character). Some embedded applications allow selection of
      charset.
    seq:
      - id: magic
        contents: 'TAG'
      - id: title
        size: 30
        doc: Song title
      - id: artist
        size: 30
        doc: Artist name
      - id: album
        size: 30
        doc: Album title
      - id: year
        type: str
        encoding: ASCII
        size: 4
        doc: Year of release
      - id: comment
        size: 30
        doc: Arbitary comment
      - id: genre
        type: u1
        enum: genre_enum
    enums:
      genre_enum:
        0: blues
        1: classic_rock
        2: country
        3: dance
        4: disco
        5: funk
        6: grunge
        7: hip_hop
        8: jazz
        9: metal
        10: new_age
        11: oldies
        12: other
        13: pop
        14: rnb
        15: rap
        16: reggae
        17: rock
        18: techno
        19: industrial
        20: alternative
        21: ska
        22: death_metal
        23: pranks
        24: soundtrack
        25: euro_techno
        26: ambient
        27: trip_hop
        28: vocal
        29: jazz_funk
        30: fusion
        31: trance
        32: classical
        33: instrumental
        34: acid
        35: house
        36: game
        37: sound_clip
        38: gospel
        39: noise
        40: alternrock
        41: bass
        42: soul
        43: punk
        44: space
        45: meditative
        46: instrumental_pop
        47: instrumental_rock
        48: ethnic
        49: gothic
        50: darkwave
        51: techno_industrial
        52: electronic
        53: pop_folk
        54: eurodance
        55: dream
        56: southern_rock
        57: comedy
        58: cult
        59: gangsta
        60: top_40
        61: christian_rap
        62: pop_funk
        63: jungle
        64: native_american
        65: cabaret
        66: new_wave
        67: psychadelic
        68: rave
        69: showtunes
        70: trailer
        71: lo_fi
        72: tribal
        73: acid_punk
        74: acid_jazz
        75: polka
        76: retro
        77: musical
        78: rock_n_roll
        79: hard_rock
        80: folk
        81: folk_rock
        82: national_folk
        83: swing
        84: fast_fusion
        85: bebob
        86: latin
        87: revival
        88: celtic
        89: bluegrass
        90: avantgarde
        91: gothic_rock
        92: progressive_rock
        93: psychedelic_rock
        94: symphonic_rock
        95: slow_rock
        96: big_band
        97: chorus
        98: easy_listening
        99: acoustic
        100: humour
        101: speech
        102: chanson
        103: opera
        104: chamber_music
        105: sonata
        106: symphony
        107: booty_bass
        108: primus
        109: porn_groove
        110: satire
        111: slow_jam
        112: club
        113: tango
        114: samba
        115: folklore
        116: ballad
        117: power_ballad
        118: rhythmic_soul
        119: freestyle
        120: duet
        121: punk_rock
        122: drum_solo
        123: a_capella
        124: euro_house
        125: dance_hall
