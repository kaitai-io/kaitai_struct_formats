meta:
  id: utdf
  endian: be
  license: CC0-1.0
  ks-version: 0.11
  encoding: UTF-8
  file-extension: utdf
  doc: |
    UTDF file format as described in NASA's "Ground Network Tracking and Acquisition Data Handbook" (453-HDBK-GN).
    Files are composed of 75-byte messages containing groundstation metadata, pointing data, and Tx/Rx frequencies used for doppler tracking.
  
seq:
  - id: recs
    type: rec
    repeat: eos

types:
  rec:
    seq:
      - id: seq_start
        contents: [0xD, 0xA, 0x1]
      - id: router
        type: u2
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
      - id: tx_pad_id
        type: u1
      - id: rx_ant_size
        type: b4
      - id: rx_and_geom
        type: b4
      - id: rx_pad_id
        type: b4
      - id: mode_sys
        type: u2
      - id: validity
        type: b8
      - id: band
        type: b4
      - id: transmission_type
        type: b4
      - id: tracker_type
        type: b4
      - id: is_last_frame
        type: b1
      - id: tx_rate
        type: b11
      - id: spare
        size: 18
      - id: seq_end
        contents: [0x04, 0x0F, 0x0F]
      
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