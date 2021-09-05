meta:
  id: android_bootldr_asus
  title: ASUS Fugu bootloader.img format (version 2 and later)
  file-extension: img
  tags:
    - archive
    - android
  license: CC0-1.0
  ks-version: 0.9
  encoding: ASCII
  endian: le
doc: |
  A bootloader image which only seems to have been used on a few ASUS
  devices. The encoding is ASCII, because the `releasetools.py` script
  is written using Python 2, where the default encoding is ASCII.

  A test file can be found in the firmware files for the "fugu" device,
  which can be downloaded from <https://developers.google.com/android/images>
doc-ref: https://android.googlesource.com/device/asus/fugu/+/android-8.1.0_r5/releasetools.py
seq:
  - id: magic
    contents: BOOTLDR!
  - id: revision
    type: u2
    valid:
      min: 2
  - id: reserved1
    type: u2
  - id: reserved2
    type: u4
  - id: images
    type: image
    repeat: expr
    repeat-expr: 3
    doc: |
      Only three images are included: `ifwi.bin`, `droidboot.img`
      and `splashscreen.img`
types:
  image:
    -webide-representation: '{file_name}'
    seq:
      - id: chunk_id
        size: 8
        type: str
        valid:
          any-of:
            - '"IFWI!!!!"'
            - '"DROIDBT!"'
            - '"SPLASHS!"'
      - id: len_body
        type: u4
      - id: flags
        type: u1
        valid:
          expr: _ & 1 != 0
      - id: reserved1
        type: u1
      - id: reserved2
        type: u1
      - id: reserved3
        type: u1
      - id: body
        size: len_body
    instances:
      file_name:
        value: |
          chunk_id == "IFWI!!!!" ? "ifwi.bin" :
          chunk_id == "DROIDBT!" ? "droidboot.img" :
          chunk_id == "SPLASHS!" ? "splashscreen.img" :
          ""
