meta:
  id: sunxi_fex
  title: Allwinner (sunxi) fex "script"
  license: GPL-2.0-or-later
  endian: le
  encoding: utf-8

doc: |
  Something like vendor-specific FDT residing in `soc-cfg` part of 0 image.
  It mostly mirrors content of `soc@<unit-address>` key in the FDT blob, **but not fully**!
  Some data is unique to this blob, and some data is unique to `dtb` blob.
  The format used ther is called "fex"

doc-ref:
  - https://linux-sunxi.org/Fex_Guide
  - https://github.com/linux-sunxi/sunxi-tools/blob/master/script.h
  - https://github.com/linux-sunxi/sunxi-tools/blob/master/script.c
  - https://github.com/linux-sunxi/sunxi-tools/blob/master/script_bin.h
  - https://github.com/linux-sunxi/sunxi-tools/blob/master/script_bin.c

-license: |
  Copyright (C) 2012  Alejandro Mery <amery@geeks.cl>
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later version.
  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
  You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

seq:
  - id: header
    -orig-id: script_head
    type: header
  - id: level_2
    type: level_2_node
    repeat: expr
    repeat-expr: header.count

types:
  header:
    -orig-id: script_head_t
    seq:
      - id: count
        -orig-id:
          - main_key_count
          - script_main_key_count
        type: u4
      - id: version
        type: u4
        repeat: expr
        repeat-expr: 3
  level_2_node:
    -orig-id: script_main_key_t
    seq:
      - id: key
        -orig-id: main_name
        size: 32
        type: strz
      - id: count
        -orig-id: length
        type: u4
      - id: offset_in_u4s
        -orig-id: offset
        type: u4
    instances:
      offset:
        value: offset_in_u4s * sizeof<u4>
      level_3:
        -orig-id: sub_key
        pos: offset
        type: level_3_node
        repeat: expr
        repeat-expr: count
    types:
      level_3_node:
        -orig-id: script_sub_key_t
        seq:
          - id: key
            -orig-id: sub_name
            size: 32
            type: strz
          - id: offset_in_u4s
            -orig-id: offset
            type: u4
          - id: size_in_u4s
            -orig-id: u32_count
            type: u2
          - id: type
            -orig-id: pattern
            type: u2
            enum: type
        instances:
          offset:
            value: offset_in_u4s * sizeof<u4>
          size:
            value: size_in_u4s * sizeof<u4>
          value:
            -orig-id: data
            pos: offset
            size: size
            type:
              switch-on: type
              cases:
                type::u32: u4
                type::string: strz
                type::gpio_u32: gpio_set
                #type::empty:
        types:
          gpio_set:
            -orig-id: script_gpio_set_t
            seq:
              - id: name
                -orig-id: gpio_name
                type: strz
                size: _io.size - sizeof<descriptor>
              - id: descriptor
                type: descriptor
            types:
              descriptor:
                seq:
                  - id: port
                    -orig-id: port
                    type: u4
                  - id: idx
                    -orig-id: port_num
                    type: u4
                    doc: "Index of this port in `allwinner,pname`"
                  - id: muxsel
                    -orig-id:
                      - allwinner,muxsel
                      - mul_sel  # likely a typo
                    type: u4
                  - id: pull
                    -orig-id:
                      - allwinner,pull
                      - pull
                    type: u4
                  - id: drive
                    -orig-id:
                      - allwinner,drive
                      - drv_level
                    type: u4
                  - id: data
                    -orig-id:
                      - data
                      - allwinner,data
                    type: u4
        enums:
          type:
            #-orig-id: SCRIPT_VALUE_
            1:
              id: u32
              -orig-id: SCRIPT_VALUE_TYPE_SINGLE_WORD
            2:
              id: string
              -orig-id: SCRIPT_VALUE_TYPE_STRING
            3:
              id: u32s
              -orig-id: SCRIPT_VALUE_TYPE_MULTI_WORD
            4:
              id: gpio_u32
              -orig-id: SCRIPT_VALUE_TYPE_GPIO
            5:
              id: empty
              -orig-id: SCRIPT_VALUE_TYPE_NULL
