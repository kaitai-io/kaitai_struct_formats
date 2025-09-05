meta:
  id: marvell_berlin_image
  title: Marvell/Synaptics BG2/BG2CD secure boot image
  license: CC0-1.0
  endian: le

doc: |
  This format describes the bootable image header, which supports both signing
  and encryption, used by older versions of Marvell (now Synaptics)'s Berlin
  multimedia SoCs. The Chromecast 1 and Steam Link use these chips.

  Field names were taken from the DWARF debugging metadata in the
  berlin_tools/enc_tool_z2a0 binary from the Chromecast 1 bootloader source code
  release (linked below).

doc-ref: https://drive.google.com/file/d/0B3j4zj2IQp7MeFZFTk5uVzFjbHM/view?usp=drive_link

seq:
  - id: parent_key_id
    type: u4
    doc: 0 for unencrypted images
  - id: reserved0
    type: u4
  - id: key_data
    size: 0x38
    doc: |
      AES encryption key, wrapped into a 24-byte blob using a custom algorithm
      that involves 6 rounds of ECB encryption and some word-swapping and XOR
      that I can't be bothered to figure out; see keyWrap() in enc_tool_z2a0
  - id: signing_key_id
    type: u4
  - id: sign_type
    type: u1
  - id: sign_len
    type: u1
  - id: reserved1
    type: u2
  - id: hash_val
    size: 24
    doc: SHA-1 hash (why 4 extra bytes?) of all data bytes, not signed directly
  - id: bind_info
    size: 16
  - id: reserved2
    size: 12
  - id: image_size
    type: u4
  - id: signature
    size: sign_len
  - id: data
    size: image_size - sign_len
