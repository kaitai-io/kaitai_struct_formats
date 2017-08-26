meta:
  id: andes_firmware
  endian: le
  title: Andes Firmware Image layout as seen in MT76 Wifi Chipsets
  license: CC0-1.0
  application: Firmware Image wifi chipset
doc: Firmware image found with MediaTek MT76xx wifi chipsets.
seq:
  - id: image_header
    type: image_header
    size: 32
  - id: ilm
    size: image_header.ilm_len
  - id: dlm
    size: image_header.dlm_len
types:
  image_header:
    seq:
      - id: ilm_len
        type: u4
      - id: dlm_len
        type: u4
      - id: fw_ver
        type: u2
      - id: build_ver
        type: u2
      - id: extra
        type: u4
      - id: build_time
        type: str
        size: 16
        encoding: UTF-8
