meta:
  id: utdf
  title: Universal Tracking Data Format
  file-extension: utdf
  license: CC0-1.0
  ks-version: 0.11
  encoding: UTF-8
  endian: be
doc: |
  UTDF file format as described in NASA's "Ground Network Tracking and Acquisition Data Handbook" (453-HDBK-GN).
  Files are composed of 75-byte messages containing groundstation metadata, pointing data, and Tx/Rx frequencies used for doppler tracking.
  
seq:
  - id: recs
    type: rec
    size: 75
    repeat: eos

types:
  rec:
    seq:
      - id: seq_start
        contents: [0xD, 0xA, 0x1]
      - id: tracking_router
        type: u2
        enum: tracking_router_name
      - id: year
        type: u1
      - id: sic
        type: u2
      - id: vid
        type: u2
      - id: soy
        type: u4
      - id: ms
        type: u4
      - id: angle_one
        type: u4
      - id: angle_two
        type: u4
      - id: rtlt  
        size: 6
      - id: f_d
        size: 6
      - id: agc
        type: u2
      - id: f_tx
        type: u4
      - id: tx_ant_size
        type: b4
      - id: tx_ant_geom
        type: b4
        enum: antenna_geom
      - id: tx_pad_id
        type: u1
      - id: rx_ant_size
        type: b4
      - id: rx_and_geom
        type: b4
        enum: antenna_geom
      - id: rx_pad_id
        type: b4
      - id: mode_sys
        type: u2
      - id: validity
        type: validity_bits
      - id: band
        type: b4
        enum: band
      - id: transmission_type
        type: b4
        enum: tx_type
      - id: tracker_type
        type: b4
        enum: tracker_type
      - id: is_last_frame
        type: b1
      - id: tx_rate
        type: b11
#      - id: spare
#        size: 18
#      - id: seq_end
#        contents: [0x04, 0x0F, 0x0F]

      
    instances:
      angle_one_cnv:
        value: angle_one * 8.381903173e-8
      angle_two_cnv:
        value: angle_two * 8.381903173e-8
      f_d_cnts:
        value: ((f_d[0] * 0x10000000000) +
                (f_d[1] * 0x100000000)   +
                (f_d[2] * 0x1000000)     +
                (f_d[3] * 0x10000)       +
                (f_d[4] * 0x100)         +
                (f_d[5]))
      rec_freq_mhz:
        value: f_d_cnts*.0001 - 240000
      f_tx_mhz:
        value: f_tx * 10e-6
        
    types:
      validity_bits:
        seq:
          - id: validity_sidelobe
            type: b1
          - id: destruct_dotr
            type: b1
          - id: refraction_correction_to_r_dotr
            type: b1
          - id: refraction_correction_to_angles
            type: b1
          - id: angle_data_correction
            type: b1
          - id: angle_valid
            type: b1
          - id: dotr_valid
            type: b1
          - id: r_valid
            type: b1
      
    enums:
      tracking_router_name:
        0x4141: aa_gfsc
        0x4444: dd_gfsc
        0x4646: ff_gfsc_france_cnes
        0x4848: hh_gfsc_japan
        0x4949: ii_gfsc_germany_esro
        0x4A4A: jj_gfsc_jsc
      antenna_geom:
        0x0: az_el
        0x1: xy_pos_x_south
        0x2: xy_pos_x_east
        0x3: ra_dec
        0x4: hr_dec
      band:
        0x1: vhf
        0x2: uhf
        0x3: s_band
        0x4: c_band
        0x5: x_band
        0x6: ku_band
        0x7: visible
        0x8: s_band_tx_ku_band_rx
      tx_type:
        0x0: test
        0x1: spare
        0x2: simulated
        0x3: resubmit
        0x4: real_time
        0x5: playback
      tracker_type:
        0x0: c_band_pulse_track
        0x1: sre_rer
        0x2: xy_angles_only
        0x4: sgls
        0x6: tdrss
        0x7: stgt_wsgtu
        0x8: tdrss_ttc
      
        
