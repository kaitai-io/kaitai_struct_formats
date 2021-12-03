meta:
  id: datrie
  title: Double array trie
  application: libdatrie
  license: LGPL-2.1-or-later
  endian: be

-copyright: |
  libdatrie - Double-Array Trie Library
  Copyright (C) 2006  Theppitak Karoonboonyanan <theppitak@gmail.com>

  This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

doc: |
  `libdatrie` is a C library for storing tries.

doc-ref: https://github.com/tlwg/libdatrie/tree/b174e656ed365771303c8d5fb1342583f5b3c2a8

seq:
  - id: alpha_map
    type: alpha_map
  - id: da
    type: da
  - id: tails
    type: tails

types:
  tails:
    -orig-id: tail
    seq:
      - id: signature
        -orig-id: TAIL_SIGNATURE
        contents: [0xDF, 0xFC, 0xDF, 0xFC]
      - id: first_free
        -orig-id: first_free
        type: u4
      - id: tail_count
        -orig-id: num_tails
        type: u4
      - id: tails
        type: tail
        repeat: expr
        repeat-expr: tail_count
    types:
      tail:
        seq:
          - id: next_free
            type: u4
          - id: data
            type: u4
          - id: length
            type: u2
          - id: suffix
            size: length
  da:
    seq:
      - id: header
        type: header
      - id: pool
        type: pool(header.cell_count - sizeof<header>/sizeof<cell>)
    types:
      header:
        seq:
          - id: signature
            -orig-id: DA_SIGNATURE
            contents: [0xDA, 0xFC, 0xDA, 0xFC]
          - id: cell_count
            type: u4
          - id: free_index
            type: u4
          - id: root_node_index
            type: u4
      pool:
        params:
          - id: cell_count
            type: u4
        seq:
          - id: pool_header
            type: header
          - id: cells
            type: cell
            repeat: expr
            repeat-expr: cell_count - sizeof<header>/sizeof<cell>
        types:
          header:
            seq:
              - id: pool_base
                -orig-id: DA_POOL_BEGIN
                type: u4
                valid:
                  eq: 3
              - id: pool_check
                type: u4
                valid:
                  eq: 0
      cell:
        seq:
          - id: base
            type: u4
          - id: check
            type: u4
  alpha_map:
    seq:
      - id: signature
        -orig-id: ALPHAMAP_SIGNATURE
        contents: [0xD9, 0xFC, 0xD9, 0xFC]
      - id: total_ranges
        type: u4
      - id: ranges
        type: range
        repeat: expr
        repeat-expr: total_ranges
    types:
      range:
        seq:
          - id: begin
            type: u4
          - id: end
            type: u4
