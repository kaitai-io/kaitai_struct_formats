meta:
  id: edid
  endian: le
seq:
  - id: magic
    contents: [0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00]
  - id: mfg_bytes
    type: u2
  - id: product_code
    type: u2
    doc: Manufacturer product code
  - id: serial
    type: u4
    doc: Serial number
  - id: mfg_week
    type: u1
    doc: Week of manufacture. Week numbering is not consistent between manufacturers.
  - id: mfg_year_mod
    type: u1
    doc: Year of manufacture, less 1990. (1990–2245). If week=255, it is the model year instead.
  - id: edid_version_major
    type: u1
    doc: EDID version, usually 1 (for 1.3)
  - id: edid_version_minor
    type: u1
    doc: EDID revision, usually 3 (for 1.3)
  - id: input_flags
    type: u1
  - id: screen_size_h
    type: u1
    doc: Maximum horizontal image size, in centimetres (max 292 cm/115 in at 16:9 aspect ratio)
  - id: screen_size_v
    type: u1
    doc: Maximum vertical image size, in centimetres. If either byte is 0, undefined (e.g. projector)
  - id: gamma_mod
    type: u1
    doc: Display gamma, datavalue = (gamma*100)-100 (range 1.00–3.54)
  - id: features_flags
    type: u1
  - id: chromacity
    size: 10
instances:
  mfg_id_ch1:
    value: '(mfg_bytes & 0b0111110000000000) >> 10'
  mfg_id_ch2:
    value: '(mfg_bytes & 0b0000001111100000) >> 5'
  mfg_id_ch3:
    value: '(mfg_bytes & 0b0000000000011111)'
  mfg_year:
    value: mfg_year_mod + 1990
  gamma:
    value: (gamma_mod + 100) / 100.0
    if: gamma_mod != 0xff
