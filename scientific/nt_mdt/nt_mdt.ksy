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
doc: |
  A native file format of NT-MDT scientific software. Usually contains
  any of:

  * [Scanning probe](https://en.wikipedia.org/wiki/Scanning_probe_microscopy) microscopy scans and spectra
  * [Raman spectra](https://en.wikipedia.org/wiki/Raman_spectroscopy)
  * results of their analysis

  Some examples of mdt files can be downloaded at:

  * https://www.ntmdt-si.ru/resources/scan-gallery
  * http://callistosoft.narod.ru/Resources/Mdt.zip
doc-ref: https://svn.code.sf.net/p/gwyddion/code/trunk/gwyddion/modules/file/nt-mdt.c
seq:
  - id: signature
    contents: [0x01, 0xb0, 0x93, 0xff]
  - id: size
    type: u4
    doc: File size (w/o header)
  - id: reserved0
    size: 4
  - id: last_frame
    type: u2
  - id: reserved1
    size: 18
  - id: wrond_doc
    size: 1
    doc: "documentation specifies 32 bytes long header, but zeroth frame starts at 33th byte in reality"
  - id: frames
    size: size
    type: framez
types:
  uuid:
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
        repeat-expr: '_root.last_frame+1'
  title:
    seq:
      - id: title_len
        type: u4
      - id: title
        type: str
        encoding: cp1251
        size: title_len
  xml:
    seq:
      - id: xml_len
        type: u4
      - id: xml
        type: str
        encoding: UTF-16LE
        size: xml_len
  version:
    seq:
      - id: minor
        type: u1
      - id: major
        type: u1
  frame:
    seq:
      - id: size
        type: u4
        doc: "h_sz"
      - id: main
        type: frame_main
        size: size - 4
    enums:
      frame_type:
        0: scanned
        1: spectroscopy
        3: text
        105: old_mda
        106: mda
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
            seq:
              - id: year
                type: u2
                doc: "h_yea"
              - id: month
                type: u2
                doc: "h_mon"
              - id: day
                type: u2
                doc: "h_day"
          time:
            seq:
              - id: hour
                type: u2
                doc: "h_h"
              - id: min
                type: u2
                doc: "h_m"
              - id: sec
                type: u2
                doc: "h_s"
      frame_main:
        seq:
          - id: type
            type: u2
            enum: frame_type
            doc: "h_what"
          - id: version
            type: version
          - id: date_time
            type: date_time
          - id: var_size
            type: u2
            doc: "h_am, v6 and older only"
          - id: frame_data
            -orig-id: dataframe
            size-eos: true
            type:
              switch-on: type
              cases:
                'frame_type::scanned': fd_scanned
                'frame_type::mda': fd_meta_data
                'frame_type::spectroscopy': fd_spectroscopy
                'frame_type::curves': fd_spectroscopy
                'frame_type::curves_new': fd_curves_new
            doc: ""
      dots:
        seq:
          - id: fm_ndots
            type: u2
          - id: coord_header
            -orig-id: coordheader
            type: dots_header
            if: fm_ndots > 0
          - id: coordinates
            type: dots_data
            repeat: expr
            repeat-expr: fm_ndots
          - id: data
            type: data_linez(_index)
            repeat: expr
            repeat-expr: fm_ndots
        types:
          dots_header:
            seq:
              - id: header_size
                -orig-id: headersize
                type: s4
              - id: header
                size: header_size
                type: header_
            types:
              header_:
                seq:
                  - id: coord_size
                    -orig-id: coordsize
                    type: s4
                  - id: version
                    type: s4
                  - id: xyunits
                    type: s2
                    enum: unit
          dots_data:
            seq:
              - id: coord_x
                type: f4
              - id: coord_y
                type: f4
              - id: forward_size
                type: s4
              - id: backward_size
                type: s4
          data_linez:
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
      axis_scale:
        seq:
          - id: offset
            type: f4
            doc: "x_scale->offset = gwy_get_gfloat_le(&p);# r0 (physical units)"
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
            doc: "U"

      fd_curves_new:
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
      fd_spectroscopy:
        seq:
          - id: vars
            type: vars
            size: _parent.var_size
          - id: fm_mode
            type: u2
          - id: fm_xres
            type: u2
          - id: fm_yres
            type: u2

          - id: dots
            type: dots

          - id: data
            type: s2
            repeat: expr
            repeat-expr: fm_xres*fm_yres

          - id: title
            type: title
          - id: xml
            type: xml
        types:
          vars:
            seq:
              - id: x_scale
                type: axis_scale
              - id: y_scale
                type: axis_scale
              - id: z_scale
                type: axis_scale
              - id: sp_mode
                type: u2
              - id: sp_filter
                type: u2
              - id: u_begin
                type: f4
              - id: u_end
                type: f4
              - id: z_up
                type: s2
              - id: z_down
                type: s2
              - id: sp_averaging
                type: u2
              - id: sp_repeat
                type: u1 # bool
              - id: sp_back
                type: u1 # bool
              - id: sp_4nx
                type: s2
              - id: sp_osc
                type: u1 # bool
              - id: sp_n4
                type: u1
              - id: sp_4x0
                type: f4
              - id: sp_4xr
                type: f4
              - id: sp_4u
                type: s2
              - id: sp_4i
                type: s2
              - id: sp_nx
                type: s2
      fd_meta_data:
        seq:
          - id: head_size
            type: u4
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
          - id: title
            type: str
            size: name_size
            encoding: UTF-8
          - id: xml
            type: str
            size: comm_size
            encoding: UTF-8
          - id: struct_len
            type: u4
          - id: array_size
            type: u8
          - id: cell_size
            type: u4
          - id: n_dimensions
            type: u4
          - id: n_mesurands
            type: u4
          - id: dimensions
            type: calibration
            repeat: expr
            repeat-expr: n_dimensions
          - id: mesurands
            type: calibration
            repeat: expr
            repeat-expr: n_mesurands
        instances:
          image:
            pos: data_offset
            type: image
            size: data_size
        types:
          image:
            seq:
              - id: image
                type: vec
                repeat: eos
            types:
              vec:
                seq:
                  - id: items
                    type:
                      switch-on: _parent._parent.mesurands[_index].data_type
                      cases:
                        "data_type::uint8": u1
                        "data_type::uint16": u2
                        "data_type::uint32": u4
                        "data_type::uint64": u8
                        "data_type::int8": s1
                        "data_type::int16": s2
                        "data_type::int32": s4
                        "data_type::int64": s8
                        "data_type::float32": f4
                        "data_type::float64": f8
                        #"data_type::float48": s8
                        #"data_type::float80": s8
                        #"data_type::floatfix": s8
                    repeat: expr
                    repeat-expr: _parent._parent.n_mesurands
          calibration:
            seq:
              - id: len_tot
                type: u4
              - id: len_struct
                type: u4
              - id: len_name
                type: u4
              - id: len_comment
                type: u4
              - id: len_unit
                type: u4
              - id: si_unit
                type: u8
              - id: accuracy
                type: f8
              - id: function_id_and_dimensions
                type: u8
              - id: bias
                type: f8
              - id: scale
                type: f8
              - id: min_index
                type: u8
              - id: max_index
                type: u8
              - id: data_type
                type: s4
                enum: data_type
              - id: len_author
                type: u4
              - id: name
                type: str
                encoding: utf-8
                size: len_name
              - id: comment
                type: str
                encoding: utf-8
                size: len_comment
              - id: unit
                type: str
                encoding: utf-8
                size: len_unit
              - id: author
                type: str
                encoding: utf-8
                size: len_author
            instances:
              count:
                -orig-id: nx, ny and nz
                value: max_index - min_index + 1
      fd_scanned:
        seq:
          - id: vars
            type: vars
            size: _parent.var_size
          - id: orig_format
            type: u4
            doc: "s_oem"
            if: false

          - id: tune
            type: u4
            enum: lift_mode
            doc: "z_tune"
            if: false

          - id: feedback_gain
            type: f8
            doc: "s_fbg"
            if: false

          - id: dac_scale
            type: s4
            doc: "s_s"
            if: false

          - id: overscan
            type: s4
            doc: "s_xov (in %)"
            if: false

            #Frame mode stuff
          - id: fm_mode
            type: u2
            doc: "m_mode"
          - id: fm_xres
            type: u2
            doc: "m_nx"
          - id: fm_yres
            type: u2
            doc: "m_ny"
          - id: dots
            type: dots


          - id: image
            type: s2
            repeat: expr
            repeat-expr: fm_xres * fm_yres

            #Stuff after data
          - id: title
            type: title
          - id: xml
            type: xml
        types:
          vars:
            seq:
              - id: x_scale
                type: axis_scale
              - id: y_scale
                type: axis_scale
              - id: z_scale
                type: axis_scale

              - id: channel_index
                type: u1
                enum: adc_mode
                doc: "s_mode"

              - id: mode
                type: u1
                enum: mode
                doc: "s_dev"

              - id: xres
                type: u2
                doc: "s_nx"
              - id: yres
                type: u2
                doc: "s_ny"
              - id: ndacq
                type: u2
                doc: "Step (DAC)"
              - id: step_length
                type: f4
                doc: "s_rs in Angstrom's (Angstrom*gwy_get_gfloat_le(&p))"

              - id: adt
                type: u2
                doc: "s_adt"

              - id: adc_gain_amp_log10
                type: u1
                doc: "s_adc_a"

              - id: adc_index
                type: u1
                doc: "ADC index"

                #XXX: Some fields have different meaning in different versions
              - id: input_signal_or_version
                type: u1
                doc: "MDTInputSignal smp_in; s_smp_in (for signal) s_8xx (for version)"

              - id: substr_plane_order_or_pass_num
                type: u1
                doc: "s_spl or z_03"

              - id: scan_dir
                type: scan_dir
                doc: "s_xy TODO: interpretation"
              - id: power_of_2
                type: u1
                doc: "s_2n (bool)"

              - id: velocity
                type: f4 # frame->velocity = Angstrom*gwy_get_gfloat_le(&p);
                doc: "s_vel (Angstrom/second)"

              - id: setpoint
                type: f4 # frame->setpoint = Nano*gwy_get_gfloat_le(&p);
                doc: "s_i0"

              - id: bias_voltage
                type: f4 # frame->bias_voltage = gwy_get_gfloat_le(&p);
                doc: "s_ut"

              - id: draw
                type: u1
                doc: "s_draw (bool)"

              - id: reserved
                type: u1

              - id: xoff
                type: s4
                doc: "s_x00 (in DAC quants)"

              - id: yoff
                type: s4
                doc: "s_y00 (in DAC quants)"

              - id: nl_corr
                type: u1
                doc: "s_cor (bool)"
          dot:
            seq:
              - id: x
                type: s2
              - id: y
                type: s2
          scan_dir:
            seq:
              - id: unkn
                type: b4
              - id: double_pass
                type: b1
              - id: bottom
                type: b1
                doc: "Bottom - 1 Top - 0"
              - id: left
                type: b1
                doc: "Left - 1 Right - 0"
              - id: horizontal
                type: b1
                doc: "Horizontal - 1 Vertical - 0"
        enums:
          mode:
            0: stm
            1: afm
            2: unknown2
            3: unknown3
            4: unknown4
          input_signal:
            0: extension_slot
            1: bias_v
            2: ground
          lift_mode:
            0: step
            1: fine
            2: slope
enums:
  spm_technique:
    0: contact_mode
    1: semicontact_mode
    2: tunnel_current
    3: snom

  data_type:
    0: unknown0
    '-1': int8
    1: uint8
    '-2': int16
    2: uint16
    '-4': int32
    4: uint32
    '-8': int64
    8: uint64
    '-5892': float32
    '-9990': float48
    '-13320': float64
    '-16138': float80
    '-65544': floatfix


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
