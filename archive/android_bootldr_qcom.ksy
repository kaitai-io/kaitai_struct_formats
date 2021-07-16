meta:
  id: android_bootldr_qcom
  title: Qualcomm Snapdragon (MSM) bootloader.img format
  file-extension: img
  tags:
    - archive
    - android
  license: CC0-1.0
  endian: le
doc: |
  A bootloader for Android used on various devices powered by Qualcomm
  Snapdragon chips:

  <https://en.wikipedia.org/wiki/Devices_using_Qualcomm_Snapdragon_processors>

  Although not all of the Snapdragon based Android devices use this particular
  bootloader format it is known that devices with the following chips have
  used it:

  * MSM8960
  * MSM8974
  * MSM8992
  * APQ8064-1AA

  Sample files can be downloaded from:

  <https://developers.google.com/android/images>
  <https://tmp.androidfilehost.com/?w=files&flid=300713#:~:text=bootloader.img>
doc-ref: https://android.googlesource.com/device/lge/hammerhead/+/7618a7/releasetools.py
seq:
  - id: magic
    contents: BOOTLDR!
  - id: num_images
    type: u4
  - id: ofs_img_bodies
    -orig-id: start_offset
    type: u4
  - id: len_img_bodies
    -orig-id: bootldr_size
    type: u4
  - id: img_info_headers
    type: img_info_header
    repeat: expr
    repeat-expr: num_images
types:
  img_info_header:
    -webide-representation: '{name}'
    seq:
      - id: name
        size: 64
        type: strz
        encoding: UTF-8
      - id: len_body
        type: u4
