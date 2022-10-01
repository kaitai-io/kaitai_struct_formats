meta:
  id: android_img
  title: Android Boot Image
  file-extension: img
  tags:
    - archive
    - android
  license: CC0-1.0
  endian: le
doc-ref:
  - https://source.android.com/devices/bootloader/boot-image-header
  - https://android.googlesource.com/platform/system/tools/mkbootimg/+/b4b04c2a965d9b3ce1ebf0442fc8047fe103d4e6/include/bootimg/bootimg.h
seq:
  - id: header
    type:
      switch-on: _root.header_version
      cases:
        0: header012
        1: header012
        2: header012
        3: header34
        4: header34
  - id: boot_signature
    size: header.as<header34>.header.len_signature
    if: header_version == 4
instances:
  header_version:
    pos: 40
    type: u4
    valid:
      max: 4
types:
  header012:
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
  header34:
    seq:
      - id: header
        type: header34_contents
        size: 4096
      - id: kernel_img
        size: header.len_kernel
      - id: padding1
        size: -header.len_kernel % 4096
      - id: ramdisk_img
        size: header.len_ramdisk
      - id: padding2
        size: -header.len_ramdisk % 4096
    instances:
      name:
        value: '""'
      cmdline:
        value: header.cmdline
      extra_cmdline:
        value: '""'
      os_version:
        value: header.os_version
  header34_contents:
    seq:
      - id: magic
        contents: ANDROID!
      - id: len_kernel
        type: u4
      - id: len_ramdisk
        type: u4
      - id: os_version
        type: os_version
      - id: header_size
        type: u4
      - id: reserved
        size: 16
      - id: header_version
        type: u4
      - id: cmdline
        type: strz
        size: 1536
        encoding: ASCII
      - id: len_signature
        type: u4
        if: _root.header_version == 4
