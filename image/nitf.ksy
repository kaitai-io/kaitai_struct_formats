meta:
  id: nitf
  title: National Imagery Transmission Format
  file-extension:
    - ntf
    - nitf
    - ntf.r0
    - ntf.r1
    - ntf.r2
    - ntf.r3
    - ntf.r4
    - ntf.r5
  ks-version: 0.9
  encoding: UTF-8
  endian: be
  license: CC-BY-SA-4.0
doc: |
  Implemented by River Loop Security.
doc-ref: https://gwg.nga.mil/ntb/baseline/docs/2500c/2500C.pdf
seq:
  - id: header
    type: header
  - id: image_segments
    type: image_segment(_index)
    repeat: expr
    repeat-expr: header.numi.to_i 
  - id: graphics_segments
    type: graphics_segment(_index)
    repeat: expr
    repeat-expr: header.nums.to_i
  - id: text_segments
    type: text_segment(_index)
    repeat: expr
    repeat-expr: header.numt.to_i
  - id: data_extension_segments
    type: data_extension_segment(_index)
    repeat: expr
    repeat-expr: header.numdes.to_i
  - id: reserved_extension_segments
    type: reserved_extension_segment(_index)
    repeat: expr
    repeat-expr: header.numres.to_i
types:
  header:
    seq:
      - id: fhdr
        contents: 'NITF'
      - id: fver
        contents: '02.10'
      - id: clevel
        size: 2
      - id: stype
        contents: 'BF01'
      - id: ostaid
        type: str
        size: 10
      - id: fdt
        type: date_time
      - id: ftitle
        type: str
        size: 80
      - id: fclasnfo
        type: clasnfo
      - id: fscop
        type: str
        size: 5
      - id: fscpys
        type: str
        size: 5
      - id: encryp
        type: encrypt
      - id: fbkgc
        size: 3
      - id: oname
        type: str
        size: 24
      - id: ophone
        type: str
        size: 18
      - id: fl
        type: str
        size: 12
      - id: hl
        type: str
        size: 6
      - id: numi
        type: str
        size: 3
      - id: linfo
        type: length_image_info
        repeat: expr
        repeat-expr: numi.to_i
      - id: nums
        type: str
        size: 3
      - id: lnnfo
        type: length_graphic_info
        repeat: expr
        repeat-expr: nums.to_i
      - id: numx
        type: str
        size: 3
      - id: numt
        type: str
        size: 3
      - id: ltnfo
        type: length_text_info
        repeat: expr
        repeat-expr: numt.to_i
      - id: numdes
        type: str
        size: 3
      - id: ldnfo
        type: length_data_info
        repeat: expr
        repeat-expr: numdes.to_i
      - id: numres
        type: str
        size: 3
      - id: lrnfo
        type: length_reserved_info
        repeat: expr
        repeat-expr: numres.to_i
      - id: user_defined_header
        type: tre_header
      - id: extended_header
        type: tre_header
  date_time:
    seq:
      - type: str
        size: 14
  encrypt:
    seq:
      - type: str
        size: 1
  clasnfo:
    instances:
      total_size: 
        value: (1 + 2 + 11 + 2 + 20 + 2 + 8 + 4 + 1 + 8 + 43 + 1 + 40 + 1 + 8 + 15)
    seq:
      - id: sclas
        type: str
        size: 1
      - id: sclsy
        type: str
        size: 2
      - id: scode
        type: str
        size: 11
      - id: sctlh
        type: str
        size: 2
      - id: srel
        type: str
        size: 20
      - id: sdctp
        type: str
        size: 2
      - id: sdcdt
        type: str
        size: 8
      - id: sdcxm
        type: str
        size: 4
      - id: sdg
        type: str
        size: 1
      - id: sdgdt
        type: str
        size: 8
      - id: scltx
        type: str
        size: 43
      - id: scatp
        type: str
        size: 1
      - id: scaut
        type: str
        size: 40
      - id: scrsn
        type: str
        size: 1
      - id: ssrdt
        type: str
        size: 8
      - id: sctln
        type: str
        size: 15
  length_image_info:
    seq:
      - id: lish
        type: str
        size: 6
      - id: li
        type: str
        size: 10
  length_graphic_info:
    seq:
      - id: lssh
        type: str
        size: 4
      - id: ls
        type: str
        size: 6
  length_text_info:
    seq:
      - id: ltsh
        type: str
        size: 4
      - id: lt
        type: str
        size: 5
  length_data_info:
    seq:
      - id: ldsh
        type: str
        size: 4
      - id: ld
        type: str
        size: 9
  length_reserved_info:
    seq:
      - id: lrsh
        type: str
        size: 4
      - id: lr
        type: str
        size: 7
  image_segment:
    params:
      - id: idx
        type: u2
    instances:
      has_mask:
        value: image_sub_header.ic.substring(0, 1) == 'M' or image_sub_header.ic.substring(1, 2) == 'M'
    seq:
      - id: image_sub_header
        type: image_sub_header
      - id: image_data_mask
        type: image_data_mask
        if: has_mask
      - id: image_data_field
        size: _parent.header.linfo[idx].li.to_i - image_data_mask.total_size
  image_sub_header:
    seq:
      - id: im
        contents: 'IM'
      - id: iid1
        type: str
        size: 10
      - id: idatim
        type: date_time
      - id: tgtid
        type: str
        size: 17
      - id: iid2
        type: str
        size: 80
      - id: iclasnfo
        type: clasnfo
      - id: encryp
        type: encrypt
      - id: isorce
        type: str
        size: 42
      - id: nrows
        type: str
        size: 8
      - id: ncols
        type: str
        size: 8
      - id: pvtype
        type: str
        size: 3
      - id: irep
        type: str
        size: 8
      - id: icat
        type: str
        size: 8
      - id: abpp
        type: str
        size: 2
      - id: pjust
        type: str
        size: 1
      - id: icords
        type: str
        size: 1
      - id: igeolo
        type: str
        size: 60
      - id: nicom
        type: str
        size: 1
      - id: icom
        type: image_comment
        repeat: expr
        repeat-expr: nicom.to_i
      - id: ic
        type: str
        size: 2
      - id: comrat
        type: str
        size: 4
      - id: nbands
        type: str
        size: 1
      - id: xbands
        type: str
        size: 5
        if: nbands.to_i == 0
      - id: bands
        type: band_info
        repeat: expr
        repeat-expr: "nbands.to_i != 0 ? nbands.to_i : xbands.to_i"
      - id: isync
        type: str
        size: 1
      - id: imode
        type: str
        size: 1
      - id: nbpr
        type: str
        size: 4
      - id: nbpc
        type: str
        size: 4
      - id: nppbh
        type: str
        size: 4
      - id: nppbv
        type: str
        size: 4
      - id: nbpp
        type: str
        size: 2
      - id: idlvl
        type: str
        size: 3
      - id: ialvl
        type: str
        size: 3
      - id: iloc
        type: str
        size: 10
      - id: imag
        type: str
        size: 4
      - id: udidl
        type: str
        size: 5
      - id: udofl
        type: str
        size: 3
        if: udidl.to_i != 0
      - id: udid
        type: u1
        if: udidl.to_i > 2
        repeat: expr
        repeat-expr: udidl.to_i - 3
      - id: image_extended_sub_header
        type: tre_header
  band_info:
    seq:
      - id: irepband
        type: str
        size: 2
      - id: isubcat
        type: str
        size: 6
      - id: ifc
        contents: 'N'
      - id: imflt
        type: str
        size: 3
      - id: nluts
        type: str
        size: 1
      - id: nelut
        type: str
        size: 5
        if: nluts.to_i != 0
      - id: lutd
        size: nelut.to_i
        repeat: expr
        repeat-expr: nluts.to_i
  image_comment:
    seq:
      - type: str
        size: 80
  image_data_mask:
    instances:
      tpxcd_size:
        value: "(tpxcdlnth % 8 == 0 ? tpxcdlnth : tpxcdlnth + (8 - tpxcdlnth % 8)) / 8"
      bmrtmr_count:
        value: >
          _parent.image_sub_header.nbpr.to_i * _parent.image_sub_header.nbpc.to_i * 
          (_parent.image_sub_header.imode != 'S' ? 
            1 :  
            (_parent.image_sub_header.nbands.to_i != 0 ?
              _parent.image_sub_header.nbands.to_i : 
              _parent.image_sub_header.xbands.to_i))
      has_bmr:
        value: bmrlnth != 0
      has_tmr:
        value: tmrlnth != 0
      bmrbnd_size: 
        value: "has_bmr ? bmrtmr_count * 4 : 0"
      tmrbnd_size:
        value: "has_tmr ? bmrtmr_count * 4 : 0"
      total_size:
        value: 4 + 2 + 2 + 2 + tpxcd_size + bmrbnd_size + tmrbnd_size
    seq:
      - id: imdatoff
        type: u4
      - id: bmrlnth
        type: u2
      - id: tmrlnth
        type: u2
      - id: tpxcdlnth
        type: u2
      - id: tpxcd
        size: tpxcd_size
      - id: bmrbnd
        type: u4
        repeat: expr
        repeat-expr: bmrtmr_count
        if: has_bmr
      - id: tmrbnd
        type: u4
        repeat: expr
        repeat-expr: bmrtmr_count
        if: has_tmr
  graphics_segment:
    params:
      - id: idx
        type: u2
    seq:
      - id: graphic_sub_header
        type: graphic_sub_header
      - id: graphic_data_field
        size: _parent.header.lnnfo[idx].ls.to_i
  graphic_sub_header:
    seq:
      - id: sy
        contents: 'SY'
      - id: sid
        type: str
        size: 10
      - id: sname
        type: str
        size: 20
      - id: sclasnfo
        type: clasnfo
      - id: encryp
        type: encrypt
      - id: sfmt
        contents: 'C'
      - id: sstruct
        type: str
        size: 13
      - id: sdlvl
        type: str
        size: 3
      - id: salvl
        type: str
        size: 3
      - id: sloc
        type: str
        size: 10
      - id: sbnd1
        type: str
        size: 10
      - id: scolor
        type: str
        size: 1
      - id: sbnd2
        type: str
        size: 10
      - id: sres2
        type: str
        size: 2
      - id: graphics_extended_sub_header
        type: tre_header
  tre_header:
    seq:
      - id: hdl
        type: str
        size: 5
      - id: ofl
        type: str
        size: 3
        if: hdl.to_i != 0
      - id: hd
        type: u1
        if: hdl.to_i > 2
        repeat: expr
        repeat-expr: hdl.to_i - 3
  text_segment:
    params:
      - id: idx
        type: u2
    seq:
      - id: text_sub_header
        size: 1
      - id: text_data_field
        size: _parent.header.ltnfo[idx].lt.to_i
  text_sub_header:
    seq:
      - id: txtdt
        type: str
        size: 14
      - id: txtitl
        type: str
        size: 80
      - id: tclasnfo
        type: clasnfo
      - id: encryp
        type: encrypt
      - id: txtfmt
        type: str
        size: 3
      - id: text_extended_sub_header
        type: tre_header
  data_extension_segment:
    params:
      - id: idx
        type: u2
    seq:
      - id: data_sub_header
        type: data_sub_header(_parent.header.ldnfo[idx].ldsh.to_i)
      - id: data_data_field
        size: _parent.header.ldnfo[idx].ld.to_i
  data_sub_header_base:
    seq:
      - id: de
        contents: 'DE'
      - id: desid
        type: str
        size: 25
      - id: desver
        type: str
        size: 2
      - id: declasnfo
        type: clasnfo
  data_sub_header:
    instances:
      tre_ofl:
        value: des_base.desid == 'TRE_OVERFLOW'
    params:
      - id: total_size
        type: u2
    seq:
      - id: des_base
        type: data_sub_header_base
      - id: desoflw
        type: str
        size: 6
        if: tre_ofl
      - id: desitem
        type: str
        size: 3
        if: tre_ofl
      - id: desshl
        type: str
        size: 4
      - id: desshf
        type: str
        size: desshl.to_i
      - id: desdata
        type: str
        size: >
          total_size - (2 + 25 + 2 + des_base.declasnfo.total_size + 
            (tre_ofl ? 6 + 3 : 0) + 4 + desshl.to_i)
  data_sub_header_tre:
    seq:
      - id: des_base
        type: data_sub_header_base
      - id: desoflw
        type: str
        size: 6
        if: des_base.desid == 'TRE_OVERFLOW'
      - id: desitem
        type: str
        size: 3
        if: des_base.desid == 'TRE_OVERFLOW'
      - id: desshl
        type: str
        size: 4
      - id: desdata
        type: str
        size: desshl.to_i
  data_sub_header_streaming:
    seq:
      - id: des_base
        type: data_sub_header_base
      - id: desshl
        type: str
        size: 4
      - id: sfh_l1
        type: str
        size: 7
      - id: sfh_delim1
        type: u4
      - id: sfh_dr
        type: u1
        repeat: expr
        repeat-expr: sfh_l1.to_i
      - id: sfh_delim2
        type: u4
      - id: sfh_l2
        type: str
        size: 7
  reserved_extension_segment:
    params:
      - id: idx
        type: u2
    seq:
      - id: reserved_sub_header
        type: reserved_sub_header(_parent.header.lrnfo[idx].lrsh.to_i)
      - id: reserved_data_field
        size: _parent.header.lrnfo[idx].lr.to_i
  reserved_sub_header:
    params:
      - id: total_size
        type: u2
    seq:
      - id: re
        contents: 'RE'
      - id: resid
        type: str
        size: 25
      - id: resver
        type: str
        size: 2
      - id: reclasnfo
        type: clasnfo
      - id: resshl
        type: str
        size: 4
      - id: resshf
        type: str
        size: resshl.to_i
      - id: resdata
        type: str
        size: total_size - (2 + 25 + 2 + reclasnfo.total_size + 4 + resshl.to_i)
  tre:
    seq:
      - id: etag
        type: str
        size: 6
      - id: el
        type: str
        size: 5
      - id: edata
        type: str
        size: el.to_i
