meta:
  id: quicktime_mov
  application: QuickTime, MP4 ISO 14496-14 media
  license: CC0-1.0
  endian: be
doc-ref: 'https://developer.apple.com/library/content/documentation/QuickTime/QTFF/QTFFChap1/qtff1.html#//apple_ref/doc/uid/TP40000939-CH203-BBCGDDDF'
seq:
  - id: atoms
    type: atom_list
types:
  atom_list:
    seq:
      - id: items
        type: atom
        repeat: eos
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
            'atom_type::dinf': atom_list
            'atom_type::mdia': atom_list
            'atom_type::minf': atom_list
            'atom_type::moof': atom_list
            'atom_type::moov': atom_list
            'atom_type::stbl': atom_list
            'atom_type::traf': atom_list
            'atom_type::trak': atom_list

            # Leaf atoms that have some distinct format inside
            'atom_type::ftyp': ftyp_body
            'atom_type::tkhd': tkhd_body
            'atom_type::mvhd': mvhd_body
    instances:
      len:
        value: 'len32 == 0 ? (_io.size - 8) : (len32 == 1 ? len64 - 16 : len32 - 8)'
  ftyp_body:
    doc-ref: 'https://developer.apple.com/library/content/documentation/QuickTime/QTFF/QTFFChap1/qtff1.html#//apple_ref/doc/uid/TP40000939-CH203-CJBCBIFF'
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
  mvhd_body:
    doc-ref: 'https://developer.apple.com/library/content/documentation/QuickTime/QTFF/QTFFChap2/qtff2.html#//apple_ref/doc/uid/TP40000939-CH204-BBCGFGJG'
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
        doc: |
          A time value that indicates the time scale for this
          movie—that is, the number of time units that pass per second
          in its time coordinate system. A time coordinate system that
          measures time in sixtieths of a second, for example, has a
          time scale of 60.
      - id: duration
        type: u4
        doc: |
          A time value that indicates the duration of the movie in
          time scale units. Note that this property is derived from
          the movie’s tracks. The value of this field corresponds to
          the duration of the longest track in the movie.
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
        doc: |
          Indicates a value to use for the track ID number of the next
          track added to this movie. Note that 0 is not a valid track
          ID value.
  tkhd_body:
    doc-ref: 'https://developer.apple.com/library/content/documentation/QuickTime/QTFF/QTFFChap2/qtff2.html#//apple_ref/doc/uid/TP40000939-CH204-25550'
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
  fixed32:
    doc: Fixed-point 32-bit number.
    seq:
      - id: int_part
        type: s2
      - id: frac_part
        type: u2
  fixed16:
    doc: Fixed-point 16-bit number.
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
  # http://www.mp4ra.org/filetype.html
  brand:
    0x33673261: x_3g2a
    0x33676536: x_3ge6
    0x33676539: x_3ge9
    0x33676639: x_3gf9
    0x33676736: x_3gg6
    0x33676739: x_3gg9
    0x33676839: x_3gh9
    0x33676d39: x_3gm9
    0x33677034: x_3gp4
    0x33677035: x_3gp5
    0x33677036: x_3gp6
    0x33677037: x_3gp7
    0x33677038: x_3gp8
    0x33677039: x_3gp9
    0x33677236: x_3gr6
    0x33677239: x_3gr9
    0x33677336: x_3gs6
    0x33677339: x_3gs9
    0x33677439: x_3gt9
    0x41525249: arri
    0x61766331: avc1
    0x6262786d: bbxm
    0x43414550: caep
    0x63617176: caqv
    0x63636666: ccff
    0x43446573: cdes
    0x64613061: da0a
    0x64613062: da0b
    0x64613161: da1a
    0x64613162: da1b
    0x64613261: da2a
    0x64613262: da2b
    0x64613361: da3a
    0x64613362: da3b
    0x64617368: dash
    0x64627931: dby1
    0x646d6231: dmb1
    0x64736d73: dsms
    0x64763161: dv1a
    0x64763162: dv1b
    0x64763261: dv2a
    0x64763262: dv2b
    0x64763361: dv3a
    0x64763362: dv3b
    0x64767231: dvr1
    0x64767431: dvt1
    0x64786f20: dxo
    0x656d7367: emsg
    0x6966726d: ifrm
    0x69736332: isc2
    0x69736f32: iso2
    0x69736f33: iso3
    0x69736f34: iso4
    0x69736f35: iso5
    0x69736f36: iso6
    0x69736f6d: isom
    0x4a325030: j2p0
    0x4a325031: j2p1
    0x6a703220: jp2
    0x6a706d20: jpm
    0x6a707369: jpsi
    0x6a707820: jpx
    0x6a707862: jpxb
    0x4c434147: lcag
    0x6c6d7367: lmsg
    0x4d344120: m4a
    0x4d344220: m4b
    0x4d345020: m4p
    0x4d345620: m4v
    0x4d46534d: mfsm
    0x4d475356: mgsv
    0x6d6a3273: mj2s
    0x6d6a7032: mjp2
    0x6d703231: mp21
    0x6d703431: mp41
    0x6d703432: mp42
    0x6d703731: mp71
    0x4d505049: mppi
    0x6d736468: msdh
    0x6d736978: msix
    0x4d534e56: msnv
    0x6e696b6f: niko
    0x6f646366: odcf
    0x6f706632: opf2
    0x6f707832: opx2
    0x70616e61: pana
    0x70696666: piff
    0x706e7669: pnvi
    0x71742020: qt
    0x72697378: risx
    0x524f5353: ross
    0x73647620: sdv
    0x53454155: seau
    0x5345424b: sebk
    0x73656e76: senv
    0x73696d73: sims
    0x73697378: sisx
    0x73737373: ssss
    0x75767675: uvvu
    0x58415643: xavc
