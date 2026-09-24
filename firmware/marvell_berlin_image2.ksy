meta:
  id: marvell_berlin_image2
  title: Marvell/Synaptics BG2CDP/BG3/BG4CDP secure boot image
  license: CC0-1.0
  endian: le

doc: |
  This format describes both the bootable image header, which supports both
  signing and encryption, and the keystore block, which chains additional keys
  to the root of trust and is often prepended to bootable images, used by newer
  versions of Marvell (now Synaptics)'s Berlin multimedia SoCs. The Chromecast
  2, Chromecast Audio, Chromecast 3, and Chromecast Ultra use these chips.

  Field names for v1 structures were taken from the DWARF debugging metadata in
  the berlin_tools/sign_image binary from the BG2CDP Chromecast bootloader
  source code release (linked below). Field names for v4 structures were
  similarly taken from berlin_tools/sign_image_v4 in the BG4CDP bootloader.

doc-ref: https://drive.google.com/file/d/1KblViXoRkhFfjfXV-DQEhY0GdODwHBVg/view?usp=drive_link

seq:
  - id: header_version
    type: u4
  - id: magic_number
    type: u2
    enum: image_type
  - id: image
    type:
      switch-on: magic_number
      cases:
        'image_type::code': image_code
        'image_type::rsa': image_ext_rsa_key_v1
        'image_type::rsa2k': image_ext_rsa_key_v4(2048)
        'image_type::rsa4k': image_ext_rsa_key_v4(4096)
        'image_type::rsa8k': image_ext_rsa_key_v4(8192)
        'image_type::cust_key': image_cust_key_v1

types:
  image_code:
    seq:
      - id: versioned_image
        type:
          switch-on: _parent.header_version
          cases:
            1: image_code_v1
            0x20000000: image_code_v4

  image_code_v1:
    seq:
      - id: cust_key_type
        type: u1
        doc: 0 for unencrypted images
      - id: code_type
        type: u1
        enum: code_type
      - id: security_level
        type: u1
      - id: reserved0
        type: u1
      - id: user_data
        type: u2
      - id: wrapped_user_key
        size: 16
      - id: constraints
        type: constraints
      - id: reserved2
        type: u2
      - id: image_size
        type: u4
      - id: image_hash
        size: 32
        doc: SHA-256 hash of all data bytes, not signed directly
      - id: signature
        size: 256
        doc: Signature of all prior bytes in header
      - id: data
        size: image_size

  image_code_v4:
    seq:
      - id: cust_key_type
        type: u1
        doc: 0x00 for signing only
      - id: code_type
        type: u1
        enum: code_type
      - id: security_level
        type: u1
      - id: ext_rsa_type
        type: u1
      - id: user_data
        type: u2
      - id: wrapped_user_key
        size: 16
      - id: constraints
        type: constraints
      - id: header_hash_size
        type: u1
      - id: padding0
        size: 1
      - id: image_hash_size
        type: u2
        doc: 0x20 for SHA-256, 0x40 for SHA-512
      - id: padding1
        size: 2
      - id: image_size
        type: u4
      - id: image_hash
        size: 64
        type: padded_data(image_hash_size)
        doc: Hash of all data bytes, not signed directly
      - id: signature
        size: 1024
        doc: Signature of all prior bytes in header
      - id: data
        size: image_size

  image_ext_rsa_key_v1:
    seq:
      - id: cust_key_type
        type: u1
      - id: reserved0
        type: u1
      - id: signing_rights
        type: u2
      - id: root_rsa_key
        type: u1
      - id: pub_exponent
        type: u1
      - id: constraints
        type: constraints
      - id: reserved1
        type: u2
      - id: rsa_modulus
        size: 256
      - id: root_key_modulus
        size: 256
      - id: signature
        size: 256
        doc: Signature of all prior bytes in header

    instances:
      next:
        pos: 0x400
        size-eos: true
        type: marvell_berlin_image2

  image_ext_rsa_key_v4:
    params:
      - id: key_size
        type: u4

    seq:
      - id: cust_key_type
        type: u1
      - id: rsa_size
        type: u1
      - id: signing_rights
        type: u2
      - id: root_rsa_key
        type: u1
      - id: pub_exponent
        type: u1
      - id: constraints
        type: constraints
      - id: hash_size
        type: u2
      - id: rsa_modulus
        size: 1024
        type: padded_data(key_size / 8)
      # Montgomery parameters
      - id: rr
        size: 1024
        type: padded_data(key_size / 8)
      - id: n0_inv
        type: u4
      - id: reserved
        size: 12
      - id: signature
        size: 1024
        doc: Signature of all prior bytes in header

    instances:
      next:
        pos: 0x1000
        size-eos: true
        type: marvell_berlin_image2

  # v4 signing still uses v1 of this struct
  image_cust_key_v1:
    seq:
      - id: type
        type: u1
      - id: primary_aes_key_id
        type: u1
      - id: root_key_index
        type: u1
      - id: root_key_param
        type: u1
      - id: reserved0
        type: u2
      - id: wrapped_cust_key
        size: 16
      - id: signature
        size: 16

    instances:
      next:
        pos: 0x400
        size-eos: true
        type: marvell_berlin_image2

  constraints:
    seq:
      - id: market_id
        type: u4
      - id: market_id_mask
        type: u4
      - id: version
        type: u1
      - id: version_mask
        type: u1

  padded_data:
    params:
      - id: size
        type: u4

    seq:
      - id: data
        size: size

enums:
  image_type:
    0xc0de: code
    0xa2e1: rsa   # v1
    0x8f02: rsa2k # v4
    0x2f04: rsa4k # v4
    0xed08: rsa8k # v4
    0xc237: cust_key

  code_type:
    # From dump() in sign_image_v4
    0: level_1_boot
    1: level_2_boot
    2: marvell_av_firmware
    3: trustzone
    4: kernel
    5: oem_firmware
    6: arm_applications
    15: data
