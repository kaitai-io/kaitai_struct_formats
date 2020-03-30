meta:
  id: android_img
  title: Android Boot Image
  license: CC0-1.0
  file-extension: img
  endian: le
doc-ref: https://source.android.com/devices/bootloader/boot-image-header
seq:
  - id: magic
    contents: ANDROID!
  - id: kernel
    type: load
  - id: ramdisk
    type: load
  - id: second
    type: load
  - id: tags_load
    type: u4
  - id: page_size
    type: u4
  - id: header_version
    type: u4
  - id: os_version
    type: os_version
  - id: name
    type: strz
    size: 16
    encoding: ASCII
  - id: cmdline
    type: strz
    size: 512
    encoding: ASCII
  - id: sha
    size: 32
  - id: extra_cmdline
    type: strz
    size: 1024
    encoding: ASCII
  - id: recovery_dtbo
    type: size_offset
    if: header_version > 0
  - id: boot_header_size
    type: u4
    if: header_version > 0
  - id: dtb
    type: load_long
    if: header_version > 1
instances:
  base:
    value: kernel.addr - 0x00008000
    doc: base loading address
  kernel_offset:
    value: kernel.addr - base
    doc: kernel offset from base
  ramdisk_offset:
    value: 'ramdisk.addr > 0 ? ramdisk.addr - base : 0'
    doc: ramdisk offset from base
  second_offset:
    value: 'second.addr > 0 ? second.addr - base : 0'
    doc: 2nd bootloader offset from base
  tags_offset:
    value: tags_load - base
    doc: tags offset from base
  dtb_offset:
    value: 'dtb.addr > 0 ? dtb.addr - base : 0'
    if: header_version > 1
    doc: dtb offset from base
  kernel_img:
    pos: page_size
    size: kernel.size
  ramdisk_img:
    pos: ((page_size + kernel.size + page_size - 1) / page_size) * page_size
    size: ramdisk.size
    if: ramdisk.size > 0
  second_img:
    pos: ((page_size + kernel.size + ramdisk.size + page_size - 1) / page_size) * page_size
    size: second.size
    if: second.size > 0
  recovery_dtbo_img:
    pos: recovery_dtbo.offset
    size: recovery_dtbo.size
    if: header_version > 0 and recovery_dtbo.size > 0
  dtb_img:
    pos: ((page_size + kernel.size + ramdisk.size + second.size + recovery_dtbo.size + page_size - 1) / page_size) * page_size
    size: dtb.size
    if: header_version > 1 and dtb.size > 0
types:
  load:
    seq:
      - id: size
        type: u4
      - id: addr
        type: u4
  load_long:
    seq:
      - id: size
        type: u4
      - id: addr
        type: u8
  size_offset:
    seq:
      - id: size
        type: u4
      - id: offset
        type: u8
  os_version:
    seq:
      - id: version
        type: u4
    instances:
      major:
        value: (version >> 25) & 0x7f
      minor:
        value: (version >> 18) & 0x7f
      patch:
        value: (version >> 11) & 0x7f
      year:
        value: ((version >> 4) & 0x7f) + 2000
      month:
        value: version & 0xf
