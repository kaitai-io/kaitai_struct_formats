meta:
  id: nt_mdt
  title: NT-MDT data
  application:
    - Nova
    - Image Analysis
    - NanoEducator
    - Gwyddion
    - Callisto
  file-extension: mdt
  license: GPL-3.0-or-later
  endian: le
  imports:
    - /common/ieee754_float/f10le
    - ./nt_mdt_color_table
doc: |
  A native file format of NT-MDT scientific software. Usually contains
  any of:

  * [Scanning probe](https://en.wikipedia.org/wiki/Scanning_probe_microscopy) microscopy scans and spectra
  * [Raman spectra](https://en.wikipedia.org/wiki/Raman_spectroscopy)
  * results of their analysis

  Some examples of mdt files can be downloaded at:

  * <https://www.ntmdt-si.ru/resources/scan-gallery>
  * <http://callistosoft.narod.ru/Resources/Mdt.zip>
  * <https://figshare.com/ndownloader/files/21743859>
doc-ref: https://svn.code.sf.net/p/gwyddion/code/trunk/gwyddion/modules/file/nt-mdt.c
seq:
  - id: signature
    contents: [0x01, 0xb0, 0x93, 0xff]
  - id: size
    type: u4
    doc: File size (w/o header)
  - id: reserved0
    size: 4
  - id: last_frame_index
    type: u2
  - id: reserved1
    size: 18
  - id: wrong_doc
    size: 1
    doc: documentation specifies 32 bytes long header, but zeroth frame starts at 33th byte in reality
  - id: frames
    size: size
    type: framez
types:
  placeholder:
    doc: needed only to have _io
    seq:
      - size-eos: true
  uuid: # a temporary solution
    seq:
      - id: data
        type: u1
        repeat: expr
        repeat-expr: 16
  framez:
    seq:
      - id: frames
        type: frame
        repeat: expr
        repeat-expr: _root.last_frame_index+1
  title:
    to-string: title
    seq:
      - id: title_len
        type: u4
      - id: title
        type: str
        encoding: cp1251
        size: title_len
  xml:
    to-string: xml
    seq:
      - id: xml_len
        type: u4
      - id: xml
        type: str
        encoding: UTF-16LE
        size: xml_len
  version:
    to-string: '"version " + major.to_s + "." + minor.to_s'
    seq:
      - id: minor
        type: u1
      - id: major
        type: u1
  scalar:
    params:
      - id: type
        type: s4
        enum: data_type
    seq:
      - id: value
        type:
          switch-on: type
          cases:
            data_type::uint8: u1
            data_type::uint16: u2
            data_type::uint32: u4
            data_type::uint64: u8
            data_type::int8: s1
            data_type::int16: s2
            data_type::int32: s4
            data_type::int64: s8
            data_type::float32: f4
            data_type::float64: f8
            #"data_type::float48": s8
            #"data_type::float80": f10le # doesn't work because of KaitaiStruct type system limitations
            #"data_type::floatfix": s8
            #enums are not properly passed
  vec2_u2:
    doc: usually sizes of the image
    to-string: '"u2<" + x.to_s + ", " + y.to_s + ">"'
    seq:
      - id: value
        type: u2
        -orig-id: fm_xres, fm_yres, xres, yres
        repeat: expr
        repeat-expr: 2
    instances:
      x:
        -orig-id: fm_xres, xres
        value: value[0]
      y:
        -orig-id: fm_yres, yres
        value: value[1]
  vec2_s4:
    to-string: '"s4<" + x.to_s + ", " + y.to_s + ">"'
    seq:
      - id: value
        type: s4
        -orig-id: s_x00, s_y00
        repeat: expr
        repeat-expr: 2
    instances:
      x:
        -orig-id: s_x00
        value: value[0]
      y:
        -orig-id: s_y00
        value: value[1]
  frame:
    seq:
      - id: size
        type: u4
        doc: h_sz
      - id: main
        type: frame_main
        size: size - 4
    enums:
      frame_type:
        0: scanned
        1: spectroscopy
        3: text
        105: old_metadata
        106: metadata
        107: palette
        190: curves_new
        201: curves
    types:
      date_time:
        seq:
          - id: date
            type: date
          - id: time
            type: time
        types:
          date:
            to-string: year.to_s + "-" + month.to_s + "-" + day.to_s
            seq:
              - id: year
                type: u2
                doc: h_yea
              - id: month
                type: u2
                doc: h_mon
              - id: day
                type: u2
                doc: h_day
          time:
            to-string: hour.to_s + ":" + minute.to_s + ":" + second.to_s
            seq:
              - id: hour
                type: u2
                doc: h_h
              - id: minute
                -orig-id: min
                type: u2
                doc: h_m
              - id: second
                -orig-id: sec
                type: u2
                doc: h_s
      frame_main:
        seq:
          - id: type
            type: u2
            enum: frame_type
            doc: h_what
          - id: version
            type: version
          - id: date_time
            type: date_time
          - id: var_size
            type: u2
            doc: h_am, v6 and older only
          - id: frame_data
            -orig-id: dataframe
            size-eos: true
            type:
              switch-on: type
              cases:
                frame_type::scanned: scanned
                frame_type::metadata: meta_data
                frame_type::spectroscopy: scanned
                frame_type::curves: scanned
                frame_type::curves_new: curves_new
                frame_type::text: text
            doc: ""
        types:
          curves_new:
            seq:
              - id: block_count
                type: u4
              - id: blocks_headers
                type: block_descr
                repeat: expr
                repeat-expr: block_count
              - id: blocks_names
                type: str
                encoding: UTF-8
                size: blocks_headers[_index].name_len
                repeat: expr
                repeat-expr: block_count
              - id: blocks_data
                size: blocks_headers[_index].len
                repeat: expr
                repeat-expr: block_count
            types:
              block_descr:
                seq:
                  - id: name_len
                    type: u4
                  - id: len
                    type: u4
          meta_data:
            seq:
              - id: head_size
                type: u4
              - id: header
                type: header
                size: head_size-4
              - id: title
                type: str
                size: header.name_size
                encoding: UTF-8
              - id: xml
                type: str
                size: header.comm_size
                encoding: UTF-8
              - id: frame_spec
                size: header.spec_size
                type: frame_spec
                if: header.spec_size != 0
              - id: view_info
                size: header.view_info_size
              - id: source_info
                size: header.source_info_size
              - id: total_size
                type: u4
              - id: calibrations
                type: calibrations
            instances:
              data:
                io: _root._io
                pos: header.data_offset
                type: data
                size: header.data_size
            types:
              header:
                seq:
                  - id: tot_len
                    type: u4
                  - id: guids
                    type: uuid
                    repeat: expr
                    repeat-expr: 2
                  - id: frame_status
                    size: 4
                  - id: name_size
                    type: u4
                  - id: comm_size
                    type: u4
                  - id: view_info_size
                    type: u4
                  - id: spec_size
                    type: u4
                  - id: source_info_size
                    type: u4
                  - id: var_size
                    type: u4
                  - id: data_offset
                    type: u4
                  - id: data_size
                    type: u4
              calibrations:
                seq:
                  - id: header_len
                    type: u4
                  - id: header
                    size: header_len
                    type: header
                  - id: dimensions
                    type: calibration
                    repeat: expr
                    repeat-expr: header.n_dimensions
                  - id: mesurands
                    type: calibration
                    repeat: expr
                    repeat-expr: header.n_mesurands
                # instances:
                  # sizes_product_internal:
                    # pos: 0
                    # size: 0
                    # type: sizes_product
                  # sizes_product:
                    # value: sizes_product_internal.internal.value
                types:
                  header:
                    seq:
                      - id: array_size
                        type: u8
                      - id: cell_size
                        type: u4
                      - id: n_dimensions
                        type: u4
                      - id: n_mesurands
                        type: u4
                  calibration:
                    seq:
                      - id: len_tot
                        type: u4
                      - id: internal
                        type: calibration_internal
                    types:
                      calibration_internal:
                        seq:
                          - id: len_header
                            type: u4
                          - id: header
                            size: len_header
                            type: header
                          - id: name
                            type: str
                            encoding: utf-8
                            size: header.len_name
                          - id: comment
                            type: str
                            encoding: utf-8
                            size: header.len_comment
                          - id: unit
                            type: str
                            encoding: cp1251
                            size: header.len_unit
                          - id: author
                            type: str
                            encoding: utf-8
                            size: header.len_author
                        types:
                          header:
                            seq:
                              - id: len_name
                                type: u4
                              - id: len_comment
                                type: u4
                              - id: len_unit
                                type: u4
                              - id: unit_si_code #?
                                type: u8
                                enum: unit_si_code
                              - id: accuracy
                                type: f8
                              - id: function_id_and_dimensions
                                type: u8
                              - id: bias
                                type: f8
                              - id: scale
                                type: f8
                              - id: min_index_placeholder
                                type: placeholder
                                size: 8
                              - id: max_index_placeholder
                                type: placeholder
                                size: 8
                              - id: data_type
                                type: s4
                                enum: data_type
                              - id: len_author
                                type: u4
                              - id: garbage
                                size-eos: true
                                doc: Garbage from memory!
                            instances:
                              min_index:
                                pos: 0
                                io: min_index_placeholder._io
                                type: scalar(data_type)
                              max_index:
                                pos: 0
                                io: max_index_placeholder._io
                                type: scalar(data_type)
                              count:
                                -orig-id: nx, ny and nz
                                value: max_index.value - min_index.value + 1
                              semireal:
                                value: scale * (count - 1)
                            enums:
                              unit_si_code:
                                0x0000000000000001: none
                                0x0000000000000101: meter
                                0x0000000000100001: ampere2
                                0x000000fffd010200: volt2
                                0x0000000001000001: second
                  # sizes_product:
                    # params:
                      # - id: total
                        # type: u4
                    # instances:
                      # internal:
                        # pos: 0
                        # size: 0
                        # type: sizes_product_internal(0, total)
                      # mesurands:
                        # value: _parent.mesurands
                    # types:
                      # sizes_product_internal:
                        # params:
                          # - id: idx
                            # type: u4
                          # - id: total
                            # type: u4
                        # instances:
                          # mesurands:
                            # value: _parent.mesurands
                          # next:
                            # pos: 0
                            # size: 0
                            # type: 'sizes_product_internal(idx+1, total)'
                            # if: 'idx < total'
                          # value:
                            # value: 'idx < total ? (next.value * measurands[idx].count.to_i) : 1'
              data:
                doc: a vector of data
                seq:
                  - id: values
                    type: cell
                    #size: _parent.calibrations.header.cell_size
                    #repeat: expr
                    #repeat-expr: '_parent.calibrations.header.array_size / _parent.calibrations.header.cell_size'
                    repeat: eos
                types:
                  cell:
                    seq:
                      - id: values
                        type:
                          switch-on: _parent._parent.calibrations.mesurands[_index].internal.header.data_type
                          cases:
                            data_type::uint8: u1
                            data_type::uint16: u2
                            data_type::uint32: u4
                            data_type::uint64: u8
                            data_type::int8: s1
                            data_type::int16: s2
                            data_type::int32: s4
                            data_type::int64: s8
                            data_type::float32: f4
                            data_type::float64: f8
                            #"data_type::float48": s8
                            data_type::float80: f10le
                            #"data_type::floatfix": s8
                        repeat: expr
                        repeat-expr: _parent._parent.calibrations.header.n_mesurands
          scanned:
            seq:
              - id: vars
                type: vars
                size: _parent.var_size

              # it seems these also belong to vars (of scanned image frame) (it's commented-out gwyddion code), but where?
              - id: orig_format
                type: u4
                doc: s_oem
                if: false

              - id: tune
                type: u4
                enum: lift_mode
                doc: z_tune
                if: false

              - id: feedback_gain
                type: f8

                if: false

              - id: dac_scale
                type: s4
                doc: s_s
                if: false
              - id: overscan
                type: s4
                doc: s_xov (in %)
                if: false
              # end of supposed vars
              - id: data
                type: data

                #Stuff after data
              - id: title
                type: title
                if: _io.size >= _io.pos + 4
              - id: xml
                type: xml
                if: _io.size >= _io.pos + 4
              - id: unkn # may be view_info_size ?
                type: u4
                if: _io.size >= _io.pos + 4
              - id: frame_spec_with_size
                type: frame_spec_with_size
                if: _io.size >= _io.pos + 4
              - id: unkn1
                type: u4
                if: _io.size >= _io.pos + 4
              - id: additional_guids
                type: additional_guids
                if: _io.size >= _io.pos + 4
            #instances:
            #   semireal:
            #     value: image.size.size[i]*vars.scales.scales[i].step
            #     repeat: expr
            #     repeat-expr: 2
            types:
              data:
                seq:
                  #Frame mode stuff
                  - id: mode
                    -orig-id: fm_mode
                    type: u2
                    #enum: spm_mode #?
                  - id: size
                    type: vec2_u2
                  - id: dots
                    type: dots

                  - id: data
                    type: s2
                    repeat: expr
                    repeat-expr: size.x*size.y
                types:
                  dots:
                    seq:
                      - id: count
                        -orig-id: fm_ndots
                        type: u2
                      - id: header
                        -orig-id: coordheader
                        type: header
                        if: count > 0
                      - id: coordinates
                        type: data
                        repeat: expr
                        repeat-expr: count
                      - id: data
                        type: data_line(_index)
                        repeat: expr
                        repeat-expr: count
                    types:
                      header:
                        seq:
                          - id: size
                            -orig-id: headersize
                            type: s4
                          - id: header
                            size: size
                            type: internal
                        types:
                          internal:
                            seq:
                              - id: coord_size
                                -orig-id: coordsize
                                type: s4
                              - id: version
                                type: s4
                              - id: xyunits
                                type: s2
                                enum: unit
                      data:
                        seq:
                          - id: coords
                            -orig-id: coord_x, coord_y
                            type: f4
                            repeat: expr
                            repeat-expr: 2
                          - id: forward_size
                            type: s4
                          - id: backward_size
                            type: s4
                        instances:
                          x:
                            -orig-id: coord_x
                            value: coords[0]
                          y:
                            -orig-id: coord_y
                            value: coords[1]
                      data_line:
                        params:
                          - id: index
                            type: u2
                        seq:
                          - id: forward
                            type: s2
                            repeat: expr
                            repeat-expr: _parent.coordinates[index].forward_size
                          - id: backward
                            type: s2
                            repeat: expr
                            repeat-expr: _parent.coordinates[index].backward_size
              vars:
                seq:
                  - id: scales
                    type: scales
                  - id: tvars
                    type:
                      switch-on: _parent._parent.type
                      cases:
                        frame_type::scanned: image
                        frame_type::spectroscopy: curve
                        frame_type::curves: curve
                types:
                  image:
                    seq:
                      - id: adc_mode
                        -orig-id: channel_index
                        type: u1
                        enum: adc_mode
                        doc: s_mode

                      - id: mode
                        type: u1
                        enum: mode
                        doc: s_dev
                      - id: size
                        type: vec2_u2
                      - id: ndacq
                        type: u2
                        doc: Step (DAC)
                      - id: step_length
                        type: f4
                        doc: in m

                      - id: adt # ADC Averaging?
                        type: u2
                        doc: s_adt

                      - id: adc_gain_amp_log10
                        type: u1
                        doc: s_adc_a

                      - id: adc_index
                        type: u1
                        doc: ADC index

                        #XXX: Some fields have different meaning in different versions
                      - id: input_signal_or_version
                        type: u1
                        doc: MDTInputSignal smp_in; s_smp_in (for signal) s_8xx (for version)

                      - id: substr_plane_order_or_pass_num
                        type: u1
                        doc: s_spl or z_03

                      - id: scan_dir
                        type: scan_dir
                        doc: 's_xy TODO: interpretation'

                      - id: power_of_2
                        type: u1
                        doc: s_2n (bool)

                      - id: velocity
                        type: f4
                        doc: s_vel (Å/s)

                      - id: setpoint
                        type: f4 # frame->setpoint = Nano*gwy_get_gfloat_le(&p);
                        doc: s_i0 (Ampere)

                      - id: bias_voltage
                        type: f4 # frame->bias_voltage = gwy_get_gfloat_le(&p);
                        doc: s_ut (Volt)

                      - id: draw
                        type: u1
                        doc: s_draw (bool)

                      - id: reserved
                        type: u1

                      - id: offset
                        type: vec2_s4
                        doc: in DAC quants

                      - id: nl_corr
                        type: u1
                        doc: s_cor (bool)
                      - id: unkn1
                        type: u2
                      - id: unkn2
                        type: u2
                      - id: feedback_gain
                        doc: s_fbg
                        type: f4
                      - id: unkn3_1
                        size: 2 * 16
                      - id: unkn3_2
                        size: 7
                      - id: lock_in_low_pass
                        type: f4
                      - id: unkn3_3
                        size: 23
                      - id: lock_in_harmonic
                        type: u1
                      - id: unkn3_4
                        type: u1
                      - id: generator_freq_sweep_range
                        type: f4
                        repeat: expr
                        repeat-expr: 2
                      - id: generator_freq
                        type: f4
                      - id: generator_amplitude
                        type: f4
                      - id: unkn4
                        size: 4
                      - id: unkn5
                        type: f4
                      - id: generator_phase
                        type: f4
                      - id: lock_in_gain
                        type: f4
                      - id: unkn6_1
                        size: 3*4 + 2
                        doc: |
                          lock_in preamp =  1 b'\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01'
                          lock_in preamp = 10 b'\x04\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01'
                      - id: laser
                        type: u1
                        doc: bool
                      - id: unkn6_3
                        size: 27
                      - id: unkn7
                        type: f4
                      - id: unkn8
                        type: f4
                      - id: unkn9
                        type: f4
                      - id: unkn10
                        type: f4
                      - id: unkn11
                        size: 16
                      - id: unkn12
                        type: f4
                  curve:
                    seq:
                      - id: mode
                        -orig-id: sp_mode
                        type: u2
                      - id: filter
                        -orig-id: sp_filter
                        type: u2
                      - id: u_begin
                        type: f4
                      - id: u_end
                        type: f4
                      - id: z_up
                        type: s2
                      - id: z_down
                        type: s2
                      - id: averaging
                        -orig-id: sp_averaging
                        type: u2
                      - id: repeat
                        -orig-id: sp_repeat
                        type: u1 # bool
                      - id: back
                        -orig-id: sp_back
                        type: u1 # bool
                      - id: sp_4nx
                        type: s2
                      - id: osc
                        -orig-id: sp_osc
                        type: u1 # bool
                      - id: n4
                        -orig-id: sp_n4
                        type: u1
                      - id: sp_4x0
                        -orig-id: sp_4x0
                        type: f4
                      - id: sp_4xr
                        -orig-id: sp_4xr
                        type: f4
                      - id: sp_4u
                        -orig-id: sp_4u
                        type: s2
                      - id: sp_4i
                        -orig-id: sp_4i
                        type: s2
                      - id: nx
                        -orig-id: sp_nx
                        type: s2
              dot:
                seq:
                  - id: x
                    type: s2
                  - id: y
                    type: s2
              scan_dir:
                to-string: |
                  (double_pass? "II" : "I" ) + " " +
                  (horizontal?
                    (bottom? "↑" : "↓" ) +
                    (left? "↠" : "↞" )
                  :
                    (left? "→" : "←" ) +
                    (bottom? "↟" : "↡" )
                  )
                seq:
                  - id: unkn
                    type: b4
                  - id: double_pass
                    type: b1
                  - id: bottom
                    type: b1
                    doc: Bottom - 1 Top - 0
                  - id: left
                    type: b1
                    doc: Left - 1 Right - 0
                  - id: horizontal
                    type: b1
                    doc: Horizontal - 1 Vertical - 0
              frame_spec_with_size:
                seq:
                  - id: size
                    type: u4
                  - id: frame_spec
                    type: frame_spec
                    size: size
                    if: size != 0
            enums:
              mode:
                0: stm
                1: afm
                2: unknown2
                3: unknown3
                4: unknown4
                5: unknown5
              input_signal:
                0: extension_slot
                1: bias_v
                2: ground
              lift_mode:
                0: step
                1: fine
                2: slope
          text:
            seq:
              - id: size
                type: u4
              - id: unkn0
                type: u4
              - id: vars
                size: _parent.var_size
              - id: text
                type: strz
                encoding: cp1251
                size: size
              - id: title
                type: title
                if: _io.size >= _io.pos + 4
              - id: xml
                type: xml
                if: _io.size >= _io.pos + 4
              - id: unkn1
                type: u4
                if: _io.size >= _io.pos + 4
              - id: unkn2
                type: u4
                if: _io.size >= _io.pos + 4
              - id: unkn3
                type: u4
                if: _io.size >= _io.pos + 4
              - id: additional_guids
                type: additional_guids
                if: _io.size >= _io.pos + 4
      additional_guids:
        seq:
          - id: size
            type: u4
          - id: guids
            size: size
            type: guids
            if: size != 0
        types:
          guids:
            seq:
              - id: guids
                type: uuid
                repeat: eos
      frame_spec:
        seq:
          - id: unkn
            size: 8*16 + 8
          - id: colors_count
            type: u4le
          - id: color_scheme
            type: nt_mdt_color_table(colors_count, 0)
            size-eos: true
      scales:
        seq:
          - id: scales
            -orig-id: x_scale, y_scale, z_scale
            type: axis_scale
            repeat: expr
            repeat-expr: 3
        instances:
          x:
            value: scales[0]
          y:
            value: scales[1]
          z:
            value: scales[2]
        types:
          axis_scale:
            seq:
              - id: offset
                type: f4
                doc: x_scale->offset = gwy_get_gfloat_le(&p);# r0 (physical units)
              - id: step
                type: f4
                doc: >
                  x_scale->step = gwy_get_gfloat_le(&p);
                  r (physical units)
                  x_scale->step = fabs(x_scale->step);
                  if (!x_scale->step) {
                    g_warning("x_scale.step == 0, changing to 1");
                    x_scale->step = 1.0;
                  }
              - id: unit
                type: s2 # x_scale->unit = (gint16)gwy_get_guint16_le(&p);
                enum: unit
                doc: U

enums:
  spm_technique:
    0: contact_mode
    1: semicontact_mode
    2: tunnel_current
    3: snom

  data_type:
    0: unknown0
    -1: int8
    1: uint8
    -2: int16
    2: uint16
    -4: int32
    4: uint32
    -8: int64
    8: uint64
    -5892: float32
    -9990: float48
    -13320: float64
    -16138: float80
    -65544: floatfix


  xml_scan_location:
    0: hlt
    1: hlb
    2: hrt
    3: hrb
    4: vlt
    5: vlb
    6: vrt
    7: vrb

  xml_param_type:
    0: none
    1: laser_wavelength
    2: units
    0xff: data_array

  spm_mode:
    0: constant_force
    1: contact_constant_height
    2: contact_error
    3: lateral_force
    4: force_modulation
    5: spreading_resistance_imaging
    6: semicontact_topography
    7: semicontact_error
    8: phase_contrast
    9: ac_magnetic_force
    10: dc_magnetic_force
    11: electrostatic_force
    12: capacitance_contrast
    13: kelvin_probe
    14: constant_current
    15: barrier_height
    16: constant_height
    17: afam
    18: contact_efm
    19: shear_force_topography
    20: sfom
    21: contact_capacitance
    22: snom_transmission
    23: snom_reflection
    24: snom_all
    25: snom

  adc_mode:
    0xFF: off
    0: height
    1: dfl
    2: lateral_f
    3: bias_v
    4: current
    5: fb_out
    6: mag
    7: mag_sin #MAG*Sin
    8: mag_cos #MAG*Cos
    9: rms
    10: calc_mag
    11: phase1
    12: phase2
    13: calc_phase
    14: ex1
    15: ex2
    16: hv_x
    17: hv_y
    18: snap_back
  consts:
    32: file_header_size
    22: frame_header_size
    8: frame_mode_size
    30: axis_scales_size
    77: scan_vars_min_size
    38: spectro_vars_min_size
  unit:
    -10: raman_shift
    -9: reserved0
    -8: reserved1
    -7: reserved2
    -6: reserved3
    -5: meter
    -4: centi_meter
    -3: milli_meter
    -2: micro_meter
    -1: nano_meter
    0: angstrom
    1: nano_ampere
    2: volt
    3: none
    4: kilo_hertz
    5: degrees
    6: percent
    7: celsius_degree # -orig-id: celsium_degree
    8: volt_high
    9: second
    10: milli_second
    11: micro_second
    12: nano_second
    13: counts
    14: pixels
    15: reserved_sfom0
    16: reserved_sfom1
    17: reserved_sfom2
    18: reserved_sfom3
    19: reserved_sfom4
    20: ampere2
    21: milli_ampere
    22: micro_ampere
    23: nano_ampere2
    24: pico_ampere
    25: volt2
    26: milli_volt
    27: micro_volt
    28: nano_volt
    29: pico_volt
    30: newton
    31: milli_newton
    32: micro_newton
    33: nano_newton
    34: pico_newton
    35: reserved_dos0
    36: reserved_dos1
    37: reserved_dos2
    38: reserved_dos3
    39: reserved_dos4
    87: unknown87
