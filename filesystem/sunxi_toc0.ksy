meta:
  id: sunxi_toc0
  title: Allwinner (sunxi) TOC0 image
  license: CC-BY-4.0
  endian: le
  encoding: ascii

doc: |
  Allwinner (sunxi) TOC0 images.

doc-ref: https://linux-sunxi.org/TOC0

seq:
  - id: header
    type: header
  - id: items
    type: item
    repeat: expr
    repeat-expr: header.items_count

types:
  align_power_of_2:
    # todo: move to common
    params:
      - id: alignment
        type: u1
    instances:
      minus_1:
        value: alignment - 1
      next:
        value: (_io.pos + minus_1) & ~minus_1
      size:
        value: next - _io.pos
    seq:
      - id: padding
        size: size

  header:
    seq:
      - id: name
        -orig-id: TOC0_NAME
        type: strz
        doc: there exist impls where it occupies 8 bytes, and there exist ones where 16. I hypothesize that it is just 8-byte aligned.
      - id: alignment
        type: align_power_of_2(8)
      - id: signature
        type: u4
        valid:
          eq: 0x89119800
        -orig-id: TOC0_MAGIC
      - id: checksum
        -orig-id: TOC0_CHECK_SUM
        type: u4
        doc-ref: https://github.com/u-boot/u-boot/blob/c738adb8dbbf28a34f8574239a241e85d46f3877/tools/mksunxiboot.c#L32-L46
      - id: serial_num
        -orig-id: TOC0_SERIAL_NUM
        type: u4
      - id: encryption
        -orig-id: TOC0_STATUS
        type: u4
        enum: encryption
      - id: items_count
        -orig-id: TOC0_NUM_ITEMS
        type: u4
      - id: total_length
        -orig-id: TOC0_LENGTH
        type: u4
        doc: Total length of the TOC0 image. This must be a multiple of the storage block size (e.g. 512B or 8KiB).
      - id: boot_device
        -orig-id: TOC0_BOOT_MEDIA
        doc: The first byte is the boot device, written by SBROM. The meaning of the other three bytes is unknown.
        type: u1
        #enum: boot_device_type
      - id: unkn0
        size: 3
      - id: reserved_or_unknown
        -orig-id: TOC_MAIN_INFO_END
        type: u4
        repeat: until
        repeat-until: _ == 0x3B45494D  # "MIE;"
        doc: contrary to the doc in the wiki and the open sources, the distance between terminator is not fixed and it seems it can be arbitrary.
    enums:
      encryption:
        0: plain
        1: ssk
        2: bssk
      #boot_device_type: {}

    types:
      version:
        seq:
          - id: major
            type: u4
          - id: minor
            type: u4
  item:
    seq:
      - id: name
        -orig-id: TOC0_ITEMn_ID
        type: strz
        size: 64
      - id: data_offset
        -orig-id: TOC0_ITEMn_OFFSET
        type: u4
      - id: data_len
        -orig-id: TOC0_ITEMn_LENGTH
        type: u4
      - id: encryption
        -orig-id: TOC0_ITEMn_STATUS
        type: u4
        enum: encryption
      - id: type
        -orig-id: TOC0_ITEMn_TYPE
        type: u4
        enum: type
      - id: entry_point
        -orig-id: TOC0_ITEMn_RUN_ADDR
        type: u4
      - id: index
        -orig-id: TOC0_ITEMn_RESERVED
        type: u4
      - id: reserved_or_unknown
        -orig-id: TOC_ITEM_INFO_END
        type: u4
        repeat: until
        repeat-until: _ == 0x3B454949  # "IIE;"
    instances:
      payload:
        pos: data_offset
        size: data_len
        type:
          switch-on: type
          cases:
            type::key_cert: keys
    enums:
      encryption:
        0: none
        1: aes
      type:
        0: normal
        1: key_cert
        2: signature_cert
        3: binary

  keys:
    seq:
      - id: vendor
        -orig-id: VENDOR_ID
        type: u4
        doc: Arbitrary identifier, must match eFUSE value if programmed
      - id: key0_n_len
        -orig-id: KEY0_N_LEN
        type: u4
        doc: Length of KEY0 modulus, in bytes. In practice, only 2048-bit keys are supported.
      - id: key0_e_len
        -orig-id: KEY0_E_LEN
        type: u4
        doc: Length of KEY0 exponent, in bytes
      - id: key1_n_len
        -orig-id: KEY1_N_LEN
        type: u4
        doc: Length of KEY0 modulus, in bytes. In practice, only 2048-bit keys are supported.
      - id: key1_e_len
        -orig-id: KEY1_E_LEN
        type: u4
        doc: Length of KEY0 exponent, in bytes
      - id: sig_len
        -orig-id: SIG_LEN
        type: u4
        doc: Length of signature (signed by KEY0), in bytes. In practice, only 2048-bit signatures are supported.
      - id: key0
        size: 512
        doc: KEY0 modulus, followed by KEY0 exponent
      - id: key1
        size: 512
        doc: KEY1 modulus, followed by KEY1 exponent
      - id: reserved
        size: 32
      - id: signature
        size-eos: true
