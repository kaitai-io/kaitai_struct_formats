meta:
  id: eink_wbf
  title: E-Ink® Waveform blob
  license: GPL-2.0
  file-extension: wbf
  endian: le
  bit-endian: le
  xref:
    wikidata: Q189897
  #imports:
  #  - /common/bcd
  ks-opaque-types: true  # https://github.com/KOLANICH-tools/inkwave.py/blob/master/inkwave/kaitai/eink_wbf_wav_addrs_collection.py
  -affected-by:
    - &opaque_interfaces_bug 500
    - &opaque_incompatible_with_import 295

-copyright:
  - Kaitai Struct spec and Python + KS-based version of `inkwave` is by KOLANICH 1n 2020-2021. I would be happy to relicense all of my original contributions to this spec under Unlicense, but it would be illegal without consent of other copyright holders. Reversing this format from scratch would have allowed to do that, but it is orders of magnitude more work, I preferred to rely on an existing working implementation (`inkwave`, which is under GPL v2, so this spec also has to be under GPL v2) in order to make creating this spec more feasible for me. Mentioning me in the `copyright`and licensing this spec under GPL is not meant to be interpreted as my approval of so called "intellectual property" system, that must be abolished. Restrictive licenses like GPL are also highly disapproved by me.    # This line is not a copyright notice like the one you are required to preserve under GPL and you are free to remove it, but it doesn't mean you have to.
  - Copyright 2018, 2021 Marc Juul
  - Copyright 2005-2017 Amazon Technologies, Inc.
  - Copyright 2004-2013 Freescale Semiconductor, Inc.

doc: |
  `.wbf` is the format stored on the flash chip present on the ribbon cable of some electronic paper displays made by the E Ink Corporation and `.wrf` is the input format used by the i.MX 508 EPDC (electronic paper display controller) and possibly the EPDCs of later i.MX chipsets.

  `inkwave` is a command-line utility for converting `.wbf` to `.wrf` files and displaying meta-data information from `.wbf` and `.wrf` files in a human readable format.

  In order to make full use of these displays it is necessary to read the `.wbf` data from the SPI flash chip, convert it to `.wrf` format and then pass it to the EPDC kernel module. Also in some firmwares the files are stored as they are.

  # Limitations and unsolved mysteries
  * https://github.com/kaitai-io/kaitai_struct/issues/815 . Partially overcome by `fixEnums` postprocessor.
  * The spec is currently not expressed entirely in KS, as the original code takes 2 passes, the first pass creates the state (`wav_addrs` array, you must pass it to `eink_wbf::temp_range` as a param of type `eink_wbf_wav_addrs_collection` (see the python file for the example of its impl)) used by the second pass. I don't beleive the format was really designed like that and I feel like it can be possible to get rid of the first pass and express the format entirely in KS, but it has not yet been done.
  * Again, the code within `inkwave` looks unnecessary complex, and this complexity has been transfered to this spec. I feel like it can be simplified a lot, but it has not yet been done.
  * `bits_per_pixel`
  * `mysterious_offset`
  * structure of `advanced_wfm_flags` is unknown
  * Each waveform segment (WUT?) ends with two bytes that do not appear to be part of the waveform itself. The first is always `0xff` and the second is unpredictable. Unfortunately `0xff` can occur inside of waveforms as well so it is not useful as an endpoint marker. The last byte might be a sort of checksum but does not appear to be a simple 1-byte sum like other 1-byte checksums used in .wbf files.

doc-ref:
  - https://github.com/fread-ink/inkwave
  - https://github.com/KOLANICH-tools/inkwave.py
  - https://web.archive.org/web/http://essentialscrap.com/eink/
  - https://web.archive.org/web/20200206095814/http://git.spritesserver.nl/espeink.git/
  - https://github.com/julbouln/ice40_eink_controller/tree/master/utils/wbf_dump

seq:
  - id: header
    type: header
    #size: sizeof<header>  # to create a substream. DO NOT DO THIS. Seems to be a bug in KSC. sizeof<header> is 50 instead of 48!
  - id: temp_range_table
    type: temp_range_table

instances:
  mysterious_offset:
    -orig-id: MYSTERIOUS OFFSET
    doc: All mode pointers in the `.wrf` file need to be offset by 63 bytes. Likely has something to do with how they are passed by the epdc kernel module to the epdc.
    value: 63

  xwia:
    pos: header.xwia
    type: xwia

  modes:
    pos: header.waveform_modes_table
    type: mode
    repeat: expr
    repeat-expr: _root.header.mode_count + 1

  wav_addrs_external:
    pos: 0
    type: eink_wbf_wav_addrs_collection(_root)
    doc: "`calc_length` needs an array of pointers to correctly determine lengths of waveforms"
    -affected-by: *opaque_interfaces_bug

types:
  passthrough:
    doc: a workaround for missingness of validation in `instance`s
    -affected-by: 859
    params:
      - id: value
        type: u4

  wav_addrs_collection:
    doc: A fake type that is not used, which only purpose is to calm down KSC in order to allow us to pass a custom opaque type needed by `calc_length`. Currently it won't work on strictly typed languages. It should be fixed by `interfaces` proposal
    -affected-by:
      - *opaque_interfaces_bug
      - 314
    seq:
      - id: arr
        type: u4
        repeat: expr
        repeat-expr: 0

  checksummed_ptr:
    doc: Pointer with checksum
    -affected-by: &checksumming_feature_request 81

    seq:
      - id: raw
        -orig-id: mode_start
        type: u4
      - id: validate_checksum
        type: passthrough(checksum)
        valid:
          expr: _.value == computed_checksum
    instances:
      ptr:
        value: raw & 0x00FFFFFF
      checksum:
        value: raw >> 24
      computed_checksum:
        value: ((ptr & 0xFF) + ((ptr >> 8) & 0xFF) + ((ptr >> 16) & 0xFF)) & 0xFF

  checksummer:
    meta:
      license: Unlicense
    -affected-by: *checksumming_feature_request
    doc: |
      A checksummer type.
    params:
      - id: init_value
        type: u1
    seq:
      - id: checksum_calculation
        type: checksum(_index)
        repeat: eos
    instances:
      calculated_checksum:
        value: checksum_calculation[checksum_calculation.size - 1].checksum
    types:
      checksum:
        params:
          - id: idx
            type: u1
        seq:
          - id: ch
            type: u1
        instances:
          is_first:
            value: idx == 0
          checksum:
            value: "(((is_first ? _parent.init_value : _parent.checksum_calculation[idx - 1].checksum) + ch) & 0xFF).as<u1>"

  temp_range_table:
    seq:
      - id: ranges
        type: range(_index)
        repeat: expr
        repeat-expr: _root.header.temperature_range_count + 1
      - id: checksum
        type: u1
        doc: must be equal to sum of all from + last to
        valid:
          expr: _ == calculated_checksum
    instances:
      calculated_checksum:
        -affected-by: *checksumming_feature_request
        value: ranges[ranges.size - 1].checksum
    types:
      range:
        params:
          - id: idx
            type: u1
        seq:
          - id: start_own
            type: u1
            if: is_full
          - id: stop
            type: u1
        instances:
          is_full:
            value: idx == 0
          start:
            value: "is_full ? start_own : _parent.ranges[idx - 1].stop"
          checksum:
            value: "(((is_full ? start_own : _parent.ranges[idx - 1].checksum) + stop) & 0xFF).as<u1>"

  xwia:
    meta:
      title: extra waveform info
    -orig-id: check_xwia
    seq:
      - id: len
        type: u1
      - id: checksummed
        size: len
        type: checksummer(len)
      - id: checksum
        type: u1
        doc: must be equal to sum of all from + last to
        valid:
          expr: _ == checksummed.calculated_checksum
    instances:
      value:
        io: checksummed._io
        pos: 0
        type: str
        encoding: ascii
        size-eos: true

  mode:
    seq:
      - id: ptr
        -orig-id: mode
        type: checksummed_ptr
      - type: unlazy_ranges
        doc: &unalazy_ranges_doc |
          It causes parsing of `ranges` array, this way populating `_root.wav_addrs_external` and doing the first pass
    instances:
      ranges:
        pos: ptr.ptr
        type: temp_ranges
    types:
      unlazy_ranges:
        doc: *unalazy_ranges_doc
        seq:
          - size: 0
            if: _parent.ranges.ranges.size != 0
      temp_ranges:
        -orig-id: parse_temp_ranges

        seq:
          - id: ranges
            type: temp_range
            repeat: expr
            repeat-expr: _root.header.temperature_range_count + 1
          #- id: validate_l
          #  type: passthrough(l)
          #  valid:
          #    expr: _.value >= 1

        types:
          temp_range:
            seq:
              - id: wav_addr
                type: checksummed_ptr
              - type: eink_wbf_wav_addrs_collection::add(wav_addr.ptr, _root.wav_addrs_external)
                doc: Adds `wav_addr` into `_root.wav_addrs_external`
            instances:
              wav_addrs:
                value: _root.wav_addrs_external.as<wav_addrs_collection>
                -affected-by: *opaque_interfaces_bug
              waveform:
                io: _root._io
                pos: wav_addr.ptr
                size: l
                type: waveform
              cl:
                pos: 0
                size: 0
                type: calc_length
              l:
                value: cl.size - 2
                doc: |
                  We are cutting off the last two bytes since we don't know what they are.
                  See section on unsolved mysteries at the top of this file.

            types:
              calc_length:
                -orig-id: get_waveform_length
                instances:
                  max_waveforms:
                    value: 4096
                    doc: |
                      there probably aren't any displays with more waveforms than this (we hope)
                      (technically the header allows for 256 * 256 waveforms but that's not realistic)
                  search:
                    pos: 0
                    type: search_iteration(_index)
                    repeat: until
                    repeat-until: _.is_over or _.is_terminator or _.is_found
                  size:
                    value: search[search.size-1].size
                types:
                  search_iteration:
                    params:
                      - id: i
                        type: u2
                    instances:
                      is_over:
                        value: i == _parent.as<calc_length>._parent.as<temp_range>.wav_addrs.arr.size - 2  # _parent.max_waveforms - 1 is the last waveform, but only the object for the pre-last is needed, because each one addresses the 2 waveforms, the current one and the next.
                      addr:
                        value: _parent.as<calc_length>._parent.as<temp_range>.wav_addrs.arr[i]
                      next_addr:
                        value: _parent.as<calc_length>._parent.as<temp_range>.wav_addrs.arr[i+1]
                      is_found:
                        value: addr == _parent.as<calc_length>._parent.as<temp_range>.wav_addr.ptr
                      is_terminator:
                        value: addr == 0
                      size:
                        value: _parent.as<calc_length>._parent.as<temp_range>.wav_addrs.arr[i + 1] - _parent.as<calc_length>._parent.as<temp_range>.wav_addr.ptr
                        if: is_found

              waveform:
                seq:
                  - id: waveform
                    type: waveform_piece(_index)
                    repeat: eos
                instances:
                  state_count:
                    value: waveform[waveform.size - 1].state_count
                types:
                  waveform_piece:
                    params:
                      - id: k
                        type: u2
                        doc: It is not the same as `i` in `inkwave`. `i` there is equivalent to our `_io.pos`. `j` is occupied in the loop writing output file
                    seq:
                      - id: current_byte
                        -orig-id: waveform[i]
                        type: u1
                        if: not is_end_of_stream  # don't remove, reading it has essential side effects
                      - id: count_read
                        type: u1
                        if: should_read_count
                        doc: &should_read_count_doc if `is_end_of_stream` is `false` and `should_read_count` is `true`, `count_read` still must be read, but it seems it is discarded. Maybe in that case it serves some other purpose
                    instances:
                      is_first:
                        value: k == 0
                      is_terminator:
                        value: current_byte == 0xFC
                        doc: |
                          0xfc is a start and end tag for a section
                          of one-byte bit-patterns with an assumed count of 1
                      fc_active:
                        value: (is_first?is_terminator:(is_terminator?(not _parent.as<waveform>.waveform[k - 1].fc_active):_parent.as<waveform>.waveform[k - 1].fc_active)).as<bool>
                        doc: |
                          `is_first?is_terminator` is because `fc_active` is set to `false` initially, then it is flipped if `is_terminator`, so essentially it is `fc_active = fc_active xor is_terminator`, and for the first iteration `fc_active = false xor is_terminator = is_terminator`
                      s:
                        pos: 0
                        type: packed_state(current_byte)
                      is_end_of_stream:
                        value: _io.pos >= _parent.as<waveform>._parent.as<temp_range>.l
                      should_read_count:
                        value: not is_end_of_stream and not is_terminator and not fc_active
                        doc: *should_read_count_doc
                      count:
                        value: |
                          (
                            not is_terminator
                          ?
                            (
                              fc_active
                            ?
                              1
                            :
                              (
                                is_end_of_stream
                              ?
                                1
                              :
                                count_read + 1
                              )
                            )
                          :
                            (
                              is_first
                            ?
                              0
                            :
                              _parent.as<waveform>.waveform[k - 1].count.as<u4>
                            )
                          )
                        doc: *should_read_count_doc
                      zero_pad:
                        value: fc_active?1:0
                        if: not is_terminator
                      state_count:
                        value: (is_first?0:_parent.as<waveform>.waveform[k - 1].state_count.as<u2>) + (is_terminator? 0 :count & 0x3FFF)
                        doc: |
                          WARNING, it is not exactly `state_count` from `inkwave`, it is divided by 4 (`>>2`) because there it is multiplied by 4, only to `>>8` later (we do `>>6`), but then write into file of other binary format as it is (looks like they have done bit packing in a wrong place, we fix that)
                          !!!WARNING!!!: Read this in each iteration in order to cache it, or you get your stack exceeded

                  packed_state:
                    params:
                      - id: b
                        type: u1
                    instances:
                      s0:
                        value: b & 0b11
                      s1:
                        value: (b >> 2) & 0b11
                      s2:
                        value: (b >> 4) & 0b11
                      s3:
                        value: (b >> 6) & 0b11


  header:
    -affected-by: 815
    -orig-id: waveform_data_header
    seq:
      - id: whole_header_crc32
        type: u4
        doc: whole header crc32, with the checksum field itself considered zeroed (start with `0x2144DF1C`)
      - id: size
        -orig-id: filesize
        type: u4
        doc: &filesize_checksum_docs |
          From the kernel it looks like sometimes `size` (header->`filesize`) can be zero. If this is the case there is a different method for calculating the checksum.
          Look at `eink_get_computed_waveform_checksum` in `eink_waveform.c`.
      - id: serial
        type: u4
      - id: run_type
        type: u1
        enum: run_type
      - id: fpl_platform
        type: u1
        enum: fpl_platform
      - id: fpl_lot
        type: u2
      - id: mode_version_or_adhesive_run_num
        type: u1
      - id: waveform_version
        type: u1
      - id: waveform_subversion
        type: u1
      - id: waveform_type
        type: u1
        enum: waveform_type
      - id: fpl_size
        type: u1
        enum: fpl_size
        doc: aka panel_size
      - id: mfg_code
        -orif-id: mfg_code
        type: u1
        enum: mfg_code
        doc: aka amepd_part_number

      - id: waveform_revision
        type: u1
        if: waveform_type.to_i >= waveform_type::wr.to_i
      - id: waveform_tuning_bias
        type: u1
        enum: tuning_bias
        if: waveform_type.to_i <= waveform_type::wj.to_i
      - id: waveform_tuning_bias_or_rev_or_unkn
        type: u1
        if: waveform_type::wj.to_i < waveform_type.to_i and waveform_type.to_i < waveform_type::wr.to_i
      - id: fpl_rate_bcd
        type: bcd(2, 4, false)
        #type: u1
        #enum: fpl_rate
        -affected-by: *opaque_incompatible_with_import
        doc: legacy frontplane rate encoded as BCD
        if: format_version == 0
      - id: timing_mode
        type: u1
        doc: newer frontplane rate encoded as binary number
        -unit: kHz
        if: format_version == 0

      - id: unkn
        type: u1
        if: format_version > 0
      - id: fpl_rate_direct
        type: u1
        doc: frontplane rate encoded directly
        if: format_version > 0

      - id: vcom_shifted
        type: u1

      - id: unknown1
        type: u2
      - id: xwia
        type: b24
        doc: address of extra waveform information
      - id: checksum_7_30
        -orig-id: cs1
        type: u1
        doc: checksum 1
        valid:
          expr: _ == checksummer_7_30.calculated_checksum

      - id: waveform_modes_table
        -orig-id: wmta
        type: b24
      - id: fvsn
        type: u1
      - id: luts
        type: u1
      - id: mode_count
        -orig-id: mc
        type: u1
        doc: length of mode table - 1
      - id: temperature_range_count
        -orif-id: trc
        type: u1
        doc: length of temperature table - 1
      - id: advanced_wfm_flags
        type: u1
      - id: eb
        type: u1
      - id: sb
        type: u1
      - id: format_version_repeat
        type: u1
      - id: reserved_or_unkn
        size: 4
      - id: cs2
        type: u1
        doc: checksum 2

    instances:
      fpl_rate:
        -affected-by: *opaque_incompatible_with_import
        value: "format_version > 0 ? fpl_rate_direct : (fpl_rate_bcd.as<bcd_mock>.as_int)"

      format_version:
        pos: 0x2a
        type: u1

      another_checksum_method:
        value: size == 0
        doc: *filesize_checksum_docs

      checksummer_7_30:
        pos: 7
        size: 23
        type: checksummer(0)

      bits_per_pixel:
        value: "((luts & 0xc) == 4) ? 5 : 4"
        doc: Dumping `wrf` for waveforms using 5 bits per pixel not yet supported in `inkwave`. Parsing, though, seems to be working.

    types:
      bcd_mock:
        -affected-by: *opaque_incompatible_with_import
        doc: FUCK
        instances:
          as_int:
            value: 0
      advanced_wfm_flags:
        seq:
          - id: voltage_control
            type: b1
          - id: algorithm_control
            type: b1
          - id: unkn
            type: b6

    enums:
      mfg_code:
        0x04: unkn_04
        0x0E: unkn_0e
        0x30: unkn_30
        0x32: unkn_32
        0x33:
          id: ed060scf_v220_6inch_tequila
          doc: ED060SCF (V220 6" Tequila)
        0x34:
          id: ed060scfh1_v220_tequila_hydis_line_2
          doc: ED060SCFH1 (V220 Tequila Hydis – Line 2)
        0x35:
          id: ed060scfh1_v220_tequila_hydis_line_3
          doc: ED060SCFH1 (V220 Tequila Hydis – Line 3)
        0x36:
          id: ed060scfc1_v220_tequila_cmo
          doc: ED060SCFC1 (V220 Tequila CMO)
        0x37:
          id: cpt_v220_tequila_cpt
          doc: ED060SCFT1 (V220 Tequila CPT)
        0x38:
          id: ed060scg_v220_whitney
          doc: ED060SCG (V220 Whitney)
        0x39:
          id: ed060scgh1_v220_whitney_hydis_line_2
          doc: ED060SCGH1 (V220 Whitney Hydis – Line 2)
        0x3A:
          id: ed060scgh1_v220_whitney_hydis_line_3
          doc: ED060SCGH1 (V220 Whitney Hydis – Line 3)
        0x3B:
          id: ed060scgc1_v220_whitney_cmo
          doc: ED060SCGC1 (V220 Whitney CMO)
        0x3C:
          id: ed060scgt1_v220_whitney_cpt
          doc: ED060SCGT1 (V220 Whitney CPT)
        0x4D: unkn_4d
        0x55: unkn_55
        0x59: unkn_59
        0x92: unkn_92
        0x9B: unkn_9b
        0xA0:
          id: unknown_lgd_a0
          doc: Unknown LGD panel
        0xA1:
          id: unknown_lgd_a1
          doc: Unknown LGD panel
        0xA2:
          id: unknown_lgd_a2
          doc: Unknown LGD panel
        0xA3:
          id: lb060s03_rd02_lgd_tequila_line_1
          doc: LB060S03-RD02 (LGD Tequila Line 1)
        0xA4:
          id: lgd_tequila_line_2
          doc: 2nd LGD Tequila Line
        0xA5:
          id: lb060s05_rd02_lgd_whitney_line_1
          doc: LB060S05-RD02 (LGD Whitney Line 1)
        0xA6:
          id: lgd_whitney_line_2
          doc: 2nd LGD Whitney Line
        0xA7:
          id: unknown_lgd_a7
          doc: Unknown LGD panel
        0xA8:
          id: unknown_lgd_a8
          doc: Unknown LGD panel
        0xCA:
          id: remarkable_panel
          doc: reMarkable panel?
        0xDB: unkn_db

      run_type:
        0x00: baseline
        0x01: test_or_trial
        0x02: production
        0x03: qualification
        0x04: v110_a
        0x05: v220_c
        0x06: d
        0x07: v220_e
        0x08: f
        0x09: g
        0x0A: h
        0x0B: i
        0x0C: j
        0x0D: k
        0x0E: l
        0x0F: m
        0x10: n
        0x11: unkn_11_likely_o

      fpl_platform:
        0x00: matrix_2_0
        0x01: matrix_2_1
        0x02: matrix_2_3_matrix_vixplex_100
        0x03: matrix_vizplex_110
        0x04: matrix_vizplex_110a
        0x05: matrix_vizplex_unknown
        0x06: matrix_vizplex_220
        0x07: matrix_vizplex_250
        0x08: matrix_vizplex_220e
        0x09: unkn_09

      fpl_size:
        0x00: r_5_0_inch
        0x01: r_6_0_inch
        0x02: r_6_1_inch
        0x03: r_6_3_inch
        0x04: r_8_0_inch
        0x05: r_9_7_inch
        0x06: r_9_9_inch
        0x07: r_unknown_07
        0x32: r_5_inch
        0x3C: r_6_inch_800x600_3c
        0x3D: r_6_1_inch_1024x768
        0x3F: r_6_inch_800x600_3f
        0x50: r_8_inch
        0x61: r_9_7_inch_1200x825
        0x63: r_9_7_inch_1600x1200

      fpl_rate:
        0x50: r_50_hz
        0x60: r_60_hz
        0x85: r_85_hz

      waveform_type:
        0x00: wx
        0x01: wy
        0x02: wp
        0x03: wz
        0x04: wq
        0x05: ta
        0x06: wu
        0x07: tb
        0x08: td
        0x09: wv
        0x0a: wt
        0x0b: te
        0x0c: xa
        0x0d: xb
        0x0e: we
        0x0f: wd
        0x10: xc
        0x11: ve
        0x12: xd
        0x13: xe
        0x14: xf
        0x15: wj
        0x16: wk
        0x17: wl
        0x18: vj
        0x2b: wr
        0x3c: aa
        0x4b: ac
        0x4c: bd
        0x50: ae

      tuning_bias:
        0x00: standard
        0x01: increased_ds_blooming_v110_v110e
        0x02: increased_ds_blooming_v220_v220e
        0x03: improved_temperature_range
        0x04: gc16_fast
        0x05: gc16_fast_gl16_fast
        0x06: unknown_06

      mode:
        # Modes to numbers bijection vary between manufacturers and devices. These ones are likely for matrices used in some Kindles, because Marc Juul has been researching into them.
        # Since mode number is tied to the index of a record in the mode table, there is no way to have an universal bijection, because if a manufacturer doesn't support a mode, he would skip it to spare space in the blob.
        # It is likely that the bijection of modes to numbers is provided for each display model by its manufacturer (since the blob is usually provided by the manufacturer and resides in the flash chip on the cable used to communicate with the display).
        # Modes [0; 2] are likely the same for most of devices.
        # The info about flashiness and ghostiness may be inaccurate.
        0x0:
          id: initialization
          -orig-id:
            - INIT
            - EPDC_WFTYPE_INIT
            - NTX_WFM_MODE_INIT
            - WAVEFORM_MODE_INIT
            - WF_UPD_MODE_INIT
          doc: whole display is initialized into white.
          -time: 2s
          -flashy: true
        0x1:
          id: direct_update_2
          -orig-id:
            - DU
            - EPDC_WFTYPE_DU
            - NTX_WFM_MODE_DU
            - WAVEFORM_MODE_DU
            - WF_UPD_MODE_MU
          doc: fast update into either black or white
          -time: 260ms
          -flashy: false
        0x2:
          id: grayscale_clearing_16
          -orig-id:
            - GC16
            - EPDC_WFTYPE_GC16
            - WAVEFORM_MODE_GC16
            - NTX_WFM_MODE_GC16
            - WF_UPD_MODE_GU
          doc: a non-ghosty mode that sets new image using 16 shades.
          -time: 450ms
          -flashy: true
        0x3:
          id: grayscale_clearing_16_fast
          -orig-id:
            - GC16_FAST
            - WAVEFORM_MODE_GC16_FAST
            - WF_UPD_MODE_GCF
          -flashy: true
        0x4:
          id: animation2
          -orig-id:
            - A2
            - EPDC_WFTYPE_A2
            - NTX_WFM_MODE_A2
            - WAVEFORM_MODE_A2
          -time: 120ms
          -flashy: false
          doc: fastest and ghosty
        0x5:
          id: gl16
          -orig-id:
            - GL16
            - WAVEFORM_MODE_GL16
            - EPDC_WFTYPE_GL16
            - NTX_WFM_MODE_GL16
            - WF_UPD_MODE_GL
          -time: 450ms
          -flashy: true
        0x6:
          id: gl16_fast
          -orig-id:
            - GL16_FAST
            - WAVEFORM_MODE_GL16_FAST
            - WF_UPD_MODE_GLF
          -flashy: true
        0x7:
          id: direct_update_4
          -orig-id:
            - DU4
            - WAVEFORM_MODE_DU4
          doc: a little less fast and more ghosty than DU update into states 0, 0.(3), 0.(6), 1
          -time: 290ms
          -flashy: false
        0x8:
          id: reagl
          -orig-id:
            - REAGL
            - WAVEFORM_MODE_REAGL
          -flashy: false
        0x9:
          id: reagl_dithered
          -orig-id:
            - REAGLD
            - WAVEFORM_MODE_REAGLD
          -flashy: false
        0xA:
          id: gl4
          -orig-id:
            - GL4
            - WAVEFORM_MODE_GL4
        0xB:
          id: gl16_inv
          -orig-id:
            - GL16_INV
            - WAVEFORM_MODE_GL16_INV
      #todo: GC4 A2IN A2OUT AA AAD GS16 GC16HQ GLR16 GLD16 GLKW16 GCK16 GCC16 GC32 GCF PU (pen update)
