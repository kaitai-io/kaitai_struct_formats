meta:
  id: instar_bneg
  title: Instar BNEG
  license: MIT
  endian: le
  encoding: ASCII
doc: |
  An old uClinux based firmware format for IP cameras. Test files:
  - https://wiki.instar.com/en/Downloads/Outdoor_Cameras/IN-2905_V2/
doc-ref:
  - https://web.archive.org/web/20160404193454/http://wiki.openipcam.com/index.php/Firmware_Structure
  - https://github.com/onekey-sec/unblob/blob/5d9fd6d8/unblob/handlers/archive/instar/bneg.py
seq:
  - id: header
    type: header
  - id: kernel
    size: header.len_kernel
  - id: rootfs
    size: header.len_rootfs
types:
  header:
    seq:
      - id: magic
        contents: 'BNEG'
      - id: major
        type: u4
        valid: 1
      - id: minor
        type: u4
        valid: 1
      - id: len_kernel
        type: u4
      - id: len_rootfs
        type: u4
