meta:
  id: quicktime_mov
  endian: be
  application: QuickTime, MP4 ISO 14496-14 media
# https://developer.apple.com/library/content/documentation/QuickTime/QTFF/QTFFChap1/qtff1.html#//apple_ref/doc/uid/TP40000939-CH203-BBCGDDDF
seq:
  - id: atoms
    type: atom
    repeat: eos
types:
  atom:
    seq:
      - id: len32
        type: u4
      - id: atom_type
        type: u4
        enum: atom_type
      - id: len64
        type: u8
        if: len32 == 1
      - id: body
        size: len
        type:
          switch-on: atom_type
          cases:
            # Atom types which actually just contain other atoms inside it
            'atom_type::dinf': quicktime_mov
            'atom_type::mdia': quicktime_mov
            'atom_type::minf': quicktime_mov
            'atom_type::moof': quicktime_mov
            'atom_type::moov': quicktime_mov
            'atom_type::stbl': quicktime_mov
            'atom_type::traf': quicktime_mov
            'atom_type::trak': quicktime_mov

            # Leaf atoms that have some distinct format inside
            'atom_type::ftyp': ftyp_body
            'atom_type::tkhd': tkhd_body
            'atom_type::mvhd': mvhd_body
    instances:
      len:
        value: 'len32 == 0 ? (_io.size - 8) : (len32 == 1 ? len64 - 16 : len32 - 8)'
  # https://developer.apple.com/library/content/documentation/QuickTime/QTFF/QTFFChap1/qtff1.html#//apple_ref/doc/uid/TP40000939-CH203-CJBCBIFF
  ftyp_body:
    seq:
      - id: major_brand
        type: u4
        enum: brand
      - id: minor_version
        size: 4
      - id: compatible_brands
        type: u4
        enum: brand
        repeat: eos
  # https://developer.apple.com/library/content/documentation/QuickTime/QTFF/QTFFChap2/qtff2.html#//apple_ref/doc/uid/TP40000939-CH204-BBCGFGJG
  mvhd_body:
    seq:
      - id: version
        type: u1
        doc: Version of this movie header atom
      - id: flags
        size: 3
      - id: creation_time
        type: u4
      - id: modification_time
        type: u4
      - id: time_scale
        type: u4
        doc: >
          A time value that indicates the time scale for this movie—that is, the number of time units that pass per second in its time coordinate system. A time coordinate system that measures time in sixtieths of a second, for example, has a time scale of 60.
      - id: duration
        type: u4
        doc: >
          A time value that indicates the duration of the movie in time scale units. Note that this property is derived from the movie’s tracks. The value of this field corresponds to the duration of the longest track in the movie.
      - id: preferred_rate
        type: fixed32
        doc: The rate at which to play this movie. A value of 1.0 indicates normal rate.
      - id: preferred_volume
        type: fixed16
        doc: How loud to play this movie’s sound. A value of 1.0 indicates full volume.
      - id: reserved1
        size: 10
      - id: matrix
        size: 36
        doc: A matrix shows how to map points from one coordinate space into another.
      - id: preview_time
        type: u4
        doc: The time value in the movie at which the preview begins.
      - id: preview_duration
        type: u4
        doc: The duration of the movie preview in movie time scale units.
      - id: poster_time
        type: u4
        doc: The time value of the time of the movie poster.
      - id: selection_time
        type: u4
        doc: The time value for the start time of the current selection.
      - id: selection_duration
        type: u4
        doc: The duration of the current selection in movie time scale units.
      - id: current_time
        type: u4
        doc: The time value for current time position within the movie.
      - id: next_track_id
        type: u4
        doc: Indicates a value to use for the track ID number of the next track added to this movie. Note that 0 is not a valid track ID value.
  # https://developer.apple.com/library/content/documentation/QuickTime/QTFF/QTFFChap2/qtff2.html#//apple_ref/doc/uid/TP40000939-CH204-25550
  tkhd_body:
    seq:
      - id: version
        type: u1
      - id: flags
        size: 3
      - id: creation_time
        type: u4
      - id: modification_time
        type: u4
      - id: track_id
        type: u4
        doc: Integer that uniquely identifies the track. The value 0 cannot be used.
      - id: reserved1
        size: 4
      - id: duration
        type: u4
      - id: reserved2
        size: 8
      - id: layer
        type: u2
      - id: alternative_group
        type: u2
      - id: volume
        type: u2
      - id: reserved3
        type: u2
      - id: matrix
        size: 36
      - id: width
        type: fixed32
      - id: height
        type: fixed32
  # fixed-point 32-bit number
  fixed32:
    seq:
      - id: int_part
        type: s2
      - id: frac_part
        type: u2
  # fixed-point 16-bit number
  fixed16:
    seq:
      - id: int_part
        type: s1
      - id: frac_part
        type: u1
enums:
  atom_type:
    0x58747261: xtra
    0x64696e66: dinf
    0x64726566: dref
    0x65647473: edts
    0x656c7374: elst
    0x66726565: free
    0x66747970: ftyp
    0x68646c72: hdlr    
    0x696f6473: iods
    0x6d646174: mdat
    0x6d646864: mdhd
    0x6d646961: mdia
    0x6d657461: meta
    0x6d696e66: minf
    0x6d6f6f66: moof
    0x6d6f6f76: moov
    0x6d766864: mvhd
    0x736d6864: smhd
    0x7374626c: stbl
    0x7374636f: stco
    0x73747363: stsc
    0x73747364: stsd
    0x7374737a: stsz
    0x73747473: stts
    0x746b6864: tkhd
    0x74726166: traf
    0x7472616b: trak
    0x74726566: tref
    0x75647461: udta
    0x766d6864: vmhd
  brand:
    0x61766331: avc1
    0x64617368: dash
    0x69736f36: iso6
    0x69736f6d: isom
    0x6d703431: mp41
    0x6d703432: mp42
    0x71742020: qt
