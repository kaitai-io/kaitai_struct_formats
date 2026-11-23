meta:
  id: pepakura_pdo
  endian: le
  file-extension: pdo
  title: Pepakura PDO v3
  application:
   - Pepakura Designer
   - Pepakura Reader
  encoding: UTF-8
  license: ?
doc: |
  A proprietary format of popular software for creation of (ki|o)rigami.
  Files for testing: https://github.com/daeken/PepakuraReverse/tree/master/pdos
doc-ref:
  - https://github.com/daeken/PepakuraReverse
seq:
  - id: signature
    contents: "version 3\n"
  - id: lock_status
    type: u4
    enum: lock_status # 4 is unlocked, 5 is locked, all others undefined
  - id: unknown0
    type: u4
  - id: version
    type: u4

  - id: creator
    type: wstr
    doc: 'This will be empty for en-us, "Pepakura Designer 3" elsewhere'
    if: _root.lock_status == lock_status::locked
  - id: key
    type: u4
    if: _root.lock_status == lock_status::locked

  - id: locale
    type: wstr
    doc: "Empty for en-us"
  - id: codepage
    type: wstr

  - id: unknown1
    type: u4
  - id: hexstring
    type: wstr

  - id: unknown2
    type: bool
    if: _root.lock_status == lock_status::locked
  - id: unknown3
    type: bool
    if: _root.lock_status == lock_status::locked

  - id: unknown4
    type: f8
    repeat: expr
    repeat-expr: 4

  - id: geometry_count
    type: u4
  - id: geometry
    type: geometry
    repeat: expr
    repeat-expr: geometry_count

  - id: textures_count
    type: u4
  - id: textures
    type: texture
    repeat: expr
    repeat-expr: textures_count

  - id: some_flag
    type: bool
  - id: if_some_flag
    type: if_some_flag
    if: some_flag

  - id: unknown3
    type: bool
    repeat: expr
    repeat-expr: 5
  - id: unknown4
    type: u4
  - id: unknown5
    type: bool
  - id: unknown6
    type: u4
    repeat: expr
    repeat-expr: 4

  - id: some_flag_2
    type: u4
  - id: unknown7
    type: f8
    repeat: expr
    repeat-expr: 2
    if: some_flag_2 == 0x0b

  - id: unknown8
    type: u4
    repeat: expr
    repeat-expr: 3

  - id: unknown9
    type: f8
    repeat: expr
    repeat-expr: 6

  - id: unknowna
    type: f8
    repeat: expr
    repeat-expr: 6

  - id: unknownb
    type: bool

  - id: unknownc
    type: f8


  - id: unknownd
    type: wstr
    if: _root.lock_status == lock_status::locked
  - id: unknowne
    type: wstr
    if: _root.lock_status == lock_status::locked

  - id: eof
    contents: [0x0F, 0x27, 0, 0]

types:
  bool:
    seq:
      - id: value_
        type: u1
    instances:
      value:
        value: value_!=0
  wstr:
    seq:
      - id: len
        type: u4
      - id: content
        type: str
        size: len
        doc: 'For "locked" files, the value _root.key gets subtracted from each byte to "decrypt" it.'
  geometry:
    seq:
      - id: name
        type: wstr
      - id: unknown0
        type: bool

      - id: vertices_count
        type: u4
      - id: vertices
        type: coord_3
        repeat: expr
        repeat-expr: vertices_count

      - id: shapes_count
        type: u4
      - id: shapes
        type: shape
        repeat: expr
        repeat-expr: shapes_count

      - id: unknown1_count
        type: u4
      - id: unknown1
        type: unknown_t_0
        repeat: expr
        repeat-expr: unknown1_count
    types:
      shape:
        seq:
          - id: unknown0
            type: u4
          - id: part
            type: u4
            doc: "The part number in Pepakura"
          - id: unknown1
            type: f8
            repeat: expr
            repeat-expr: 4

          - id: points_count
            type: u4
          - id: points
            type: point
            repeat: expr
            repeat-expr: points_count

        types:
          point:
            seq:
              - id: index
                type: u4
                doc: "Index into Vertices"
              - id: coord
                type: coord_2
                doc: "2D coordinates"
              - id: unknown0
                type: f8
                repeat: expr
                repeat-expr: 2

              - id: unknown1
                type: bool

              - id: unknown2
                type: f8
                repeat: expr
                repeat-expr: 3

              - id: unknown3
                type: u4
                repeat: expr
                repeat-expr: 3

              - id: edge_color
                type: rgb_f4

      unknown_t_0:
        seq:
          - id: unknown0
            type: u4
            repeat: expr
            repeat-expr: 4

          - id: unknown1
            type: bool
            repeat: expr
            repeat-expr: 2

          - id: unknown2
            type: u4


  texture:
    seq:
      - id: name
        type: wstr
      - id: unknown0
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: unknown1
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: unknown2
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: unknown3
        type: f4
        repeat: expr
        repeat-expr: 4

      - id: has_image
        type: bool
      - id: image
        type: image
        if: has_image

    types:
      image:
        seq:
          - id: width
            type: u4
            doc: "In pixels"
          - id: height
            type: u4
            doc: "In pixels"

          - id: compressed_size
            type: u4
          - id: image_data
            size: compressed_size
            process: zlib
            repeat: eos

  if_some_flag:
    seq:
      - id: unknown0
        type: f8

      - id: unknown1
        type: bool

      - id: unknown2
        type: f8
        repeat: expr
        repeat-expr: 4

      - id: unknown3_count
        type: u4
      - id: unknown3
        type: unknown_t_1
        repeat: expr
        repeat-expr: unknown3_count

      - id: strings_count
        type: u4
      - id: strings
        type: text
        repeat: expr
        repeat-expr: strings_count
        doc: "This holds text strings for rendering on the page"

      - id: unknown4_count
        type: u4
      - id: unknown4
        type: unknown_t_3
        repeat: expr
        repeat-expr: unknown4_count

      - id: unknown5_count
        type: u4
      - id: unknown5
        type: unknown_t_3
        repeat: expr
        repeat-expr: unknown5_count

    types:
      unknown_t_1:
        seq:
         - id: unknown0
           type: u4

         - id: unknown1
           type: f8
           repeat: expr
           repeat-expr: 4

         - id: unknown2
           type: wstr
           if: _root.lock_status == lock_status::locked

         - id: unknown3_count
           type: u4
         - id: unknown3
           type: unknown_t_2
           repeat: expr
           repeat-expr: unknown3_count
        types:
          unknown_t_2:
            seq:
              - id: unknown0
                type: bool

              - id: unknown1
                type: u4

              - id: have_unknown2
                type: bool
              - id: unknown2
                type: u4
                repeat: expr
                repeat-expr: 2
                if: have_unknown2

              - id: have_unknown3
                type: bool

              - id: unknown3
                type: u4
                repeat: expr
                repeat-expr: 2
                if: have_unknown3
      unknown_t_3:
        seq:
         - id: unknown0
           type: f8
           repeat: expr
           repeat-expr: 4

         - id: unknown1
           type: u4
           repeat: expr
           repeat-expr: 2

         - id: unknown2_compressed_size
           type: u4

         - id: unknown2
           size: unknown2_compressed_size
           process: zlib
      text:
        doc: A string for rendering on the page
        seq:
         - id: unknown0
           type: f8
           repeat: expr
           repeat-expr: 5

         - id: unknown1
           type: u4
           repeat: expr
           repeat-expr: 2

         - id: font
           type: wstr

         - id: lines_count
           type: u4
         - id: lines
           type: wstr
           repeat: expr
           repeat-expr: lines_count
  rgb_f4:
    seq:
      - id: r
        type: f4
      - id: g
        type: f4
      - id: b
        type: f4
  coord_2:
    seq:
      - id: x
        type: f8
      - id: y
        type: f8
  coord_3:
    seq:
      - id: xy
        type: coord_2
      - id: z
        type: f8
    instances:
      x:
        value: xy.x
      y:
        value: xy.y
enums:
  lock_status: #all others undefined
    4: unlocked
    5: locked 
