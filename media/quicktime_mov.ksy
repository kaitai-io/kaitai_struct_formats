meta:
  id: quicktime_mov
  application: QuickTime, MP4 ISO 14496-14 media
  xref:
    justsolve: QuickTime
    loc: fdd000052
    pronom: x-fmt/384
    wikidata: Q942350
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
          movie - the number of time units that pass per second
          in its time coordinate system. A time coordinate system that
          measures time in sixtieths of a second, for example, has a
          time scale of 60.
      - id: duration
        type: u4
        doc: |
          A time value that indicates the duration of the movie in
          time scale units. Note that this property is derived from
          the movie's tracks. The value of this field corresponds to
          the duration of the longest track in the movie.
      - id: preferred_rate
        type: fixed32
        doc: The rate at which to play this movie. A value of 1.0 indicates normal rate.
      - id: preferred_volume
        type: fixed16
        doc: How loud to play this movie's sound. A value of 1.0 indicates full volume.
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

  # https://mp4ra.org/#/brands
  #
  # JS code to scrape the enum `brand` (paste into the browser JS console on the above page):
  # ```javascript
  # copy(Array.from(document.querySelector('tbody').querySelectorAll('tr')).map(r => {
  #   const code = r.querySelector('td:nth-child(1)').innerText.replace(/\$20/g, '\x20');
  #   if (!code.trim()) return null;
  #   return [
  #     '0x' + Array.from((new TextEncoder()).encode(code), b => b.toString(16).padStart(2, '0')).join(''),
  #     (/^\d/.test(code) ? 'x_' : '') + code.trim().toLowerCase(),
  #   ];
  # }).filter(entry => !!entry).map(entry => `    ${entry[0]}: ${entry[1]}\n`).join(''));
  # ```
  brand:
    0x33673261: x_3g2a
    0x33676536: x_3ge6
    0x33676537: x_3ge7
    0x33676539: x_3ge9
    0x33676639: x_3gf9
    0x33676736: x_3gg6
    0x33676739: x_3gg9
    0x33676839: x_3gh9
    0x33676d39: x_3gm9
    0x33676d41: x_3gma
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
    0x33677438: x_3gt8
    0x33677439: x_3gt9
    0x33677476: x_3gtv
    0x33677672: x_3gvr
    0x33767261: x_3vra
    0x33767262: x_3vrb
    0x3376726d: x_3vrm
    0x61647469: adti
    0x61696433: aid3
    0x41525249: arri
    0x61763031: av01
    0x61766331: avc1
    0x61766369: avci
    0x61766373: avcs
    0x61766465: avde
    0x61766966: avif
    0x6176696f: avio
    0x61766973: avis
    0x6262786d: bbxm
    0x43414550: caep
    0x43446573: cdes
    0x6361346d: ca4m
    0x63613473: ca4s
    0x63616161: caaa
    0x63616163: caac
    0x6361626c: cabl
    0x63616d61: cama
    0x63616d63: camc
    0x63617176: caqv
    0x63617375: casu
    0x63636561: ccea
    0x63636666: ccff
    0x63646d31: cdm1
    0x63646d34: cdm4
    0x63656163: ceac
    0x63666864: cfhd
    0x63667364: cfsd
    0x63686431: chd1
    0x63686466: chdf
    0x63686576: chev
    0x63686864: chhd
    0x63686831: chh1
    0x636c6731: clg1
    0x636d6632: cmf2
    0x636d6663: cmfc
    0x636d6666: cmff
    0x636d666c: cmfl
    0x636d6673: cmfs
    0x636d686d: cmhm
    0x636d6873: cmhs
    0x636f6d70: comp
    0x63736831: csh1
    0x63756431: cud1
    0x63756438: cud8
    0x63757664: cuvd
    0x63766964: cvid
    0x63777674: cwvt
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
    0x64747331: dts1
    0x64747332: dts2
    0x64747333: dts3
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
    0x68656963: heic
    0x6865696d: heim
    0x68656973: heis
    0x68656978: heix
    0x68656f69: heoi
    0x68657663: hevc
    0x68657664: hevd
    0x68657669: hevi
    0x6865766d: hevm
    0x68657673: hevs
    0x68657678: hevx
    0x68766365: hvce
    0x68766369: hvci
    0x68766378: hvcx
    0x68767469: hvti
    0x69667364: ifsd
    0x69666873: ifhs
    0x69666864: ifhd
    0x69666878: ifhx
    0x69666868: ifhh
    0x69666875: ifhu
    0x69666872: ifhr
    0x69666161: ifaa
    0x6966726d: ifrm
    0x696d3169: im1i
    0x696d3174: im1t
    0x696d3269: im2i
    0x696d3274: im2t
    0x69736332: isc2
    0x69736f32: iso2
    0x69736f33: iso3
    0x69736f34: iso4
    0x69736f35: iso5
    0x69736f36: iso6
    0x69736f37: iso7
    0x69736f38: iso8
    0x69736f39: iso9
    0x69736f61: isoa
    0x69736f62: isob
    0x69736f63: isoc
    0x69736f6d: isom
    0x6a326b69: j2ki
    0x6a326b73: j2ks
    0x6a326973: j2is
    0x4a325030: j2p0
    0x4a325031: j2p1
    0x6a703220: jp2
    0x6a706567: jpeg
    0x6a706773: jpgs
    0x6a706d20: jpm
    0x6a706f69: jpoi
    0x6a707369: jpsi
    0x6a707820: jpx
    0x6a707862: jpxb
    0x6a786c20: jxl
    0x6a787320: jxs
    0x6a787363: jxsc
    0x6a787369: jxsi
    0x6a787373: jxss
    0x4c434147: lcag
    0x6c687465: lhte
    0x6c687469: lhti
    0x6c6d7367: lmsg
    0x4d344120: m4a
    0x4d344220: m4b
    0x4d345020: m4p
    0x4d345620: m4v
    0x4d413142: ma1b
    0x4d413141: ma1a
    0x4d46534d: mfsm
    0x4d475356: mgsv
    0x4d694142: miab
    0x4d694143: miac
    0x6d696166: miaf
    0x4d69416e: mian
    0x4d694275: mibu
    0x4d69436d: micm
    0x6d696631: mif1
    0x4d694841: miha
    0x4d694842: mihb
    0x4d694845: mihe
    0x4d695072: mipr
    0x6d6a3273: mj2s
    0x6d6a7032: mjp2
    0x6d703231: mp21
    0x6d703431: mp41
    0x6d703432: mp42
    0x6d703731: mp71
    0x4d505049: mppi
    0x6d707566: mpuf
    0x6d736631: msf1
    0x6d736468: msdh
    0x6d736978: msix
    0x4d534e56: msnv
    0x6e696b6f: niko
    0x6e6c736c: nlsl
    0x6e726173: nras
    0x6f613264: oa2d
    0x6f61626c: oabl
    0x6f646366: odcf
    0x6f6d7070: ompp
    0x6f706632: opf2
    0x6f707832: opx2
    0x6f766470: ovdp
    0x6f766c79: ovly
    0x70616666: paff
    0x70616e61: pana
    0x70696666: piff
    0x706d6666: pmff
    0x706e7669: pnvi
    0x71742020: qt
    0x72656c6f: relo
    0x72697378: risx
    0x524f5353: ross
    0x73647620: sdv
    0x53454155: seau
    0x5345424b: sebk
    0x73656e76: senv
    0x73696d73: sims
    0x73697378: sisx
    0x73697469: siti
    0x736c6831: slh1
    0x736c6832: slh2
    0x736c6833: slh3
    0x73737373: ssss
    0x74746d6c: ttml
    0x74747776: ttwv
    0x75687669: uhvi
    0x756e6966: unif
    0x75767675: uvvu
    0x76777074: vwpt
    0x58415643: xavc
    0x79743420: yt4
    0x63686432: chd2
    0x63696e74: cint
    0x636c6732: clg2
    0x63756432: cud2
    0x63756439: cud9
    0x6d696632: mif2
    0x70726564: pred
