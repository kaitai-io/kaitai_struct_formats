meta:
  id: bmfont
  title: BMFont binary file
  file-extension: fnt
  license: CC0-1.0
  endian: le
  bit-endian: le
doc-ref: https://www.angelcode.com/products/bmfont/doc/file_format.html  
seq:
  - id: magic
    contents: ['BMF', 3]
  - id: info
    type: info
  - id: common
    type: common 
  - id: pages
    type: pages
  - id: chars
    type: chars
  - id: kernings
    type: kernings
    if: not _io.eof
types:
  info:
    seq:
      - id: magic
        contents: [1]
      - id: block_size
        type: s4
      - id: size
        type: s2        
      - id: smooth
        type: b1
      - id: unicode
        type: b1
      - id: italic
        type: b1
      - id: bold
        type: b1
      - id: reserved
        type: b4        
      - id: charset
        type: u1
      - id: stretch_h
        type: u2
      - id: aa
        type: s1
      - id: padding_up
        type: u1
      - id: padding_right
        type: u1
      - id: padding_down
        type: u1
      - id: padding_left
        type: u1        
      - id: spacing_horiz
        type: u1
      - id: spacing_vert
        type: u1
      - id: outline
        type: u1        
      - id: face
        type: str
        size: block_size - 14
        terminator: 0        
        encoding: UTF-8
  common:
    seq:        
      - id: magic
        contents: [2]
      - id: block_size
        type: s4
      - id: line_height
        type: u2
      - id: base
        type: u2        
      - id: scale_w
        type: u2
      - id: scale_h
        type: u2
      - id: pages
        type: u2   
      - id: reserved
        type: b7        
      - id: packed
        type: b1
      - id: alpha_channel
        type: u1
      - id: red_channel
        type: u1
      - id: green_channel
        type: u1
      - id: blue_channel
        type: u1        
  pages:
    seq:        
      - id: magic
        contents: [3]
      - id: block_size
        type: s4
      - id: page
        type: strz
        encoding: UTF-8
        repeat: expr
        repeat-expr: _root.common.pages
  chars:
    seq:
      - id: magic
        contents: [4]
      - id: block_size
        type: s4
      - id: char
        type: char
        repeat: expr
        repeat-expr: block_size / 20
  char:
    seq:
      - id: id
        type: u4
      - id: x
        type: u2
      - id: y
        type: u2
      - id: width
        type: u2
      - id: height
        type: u2    
      - id: xoffset
        type: s2
      - id: yoffset
        type: s2        
      - id: xadvance
        type: s2                
      - id: page
        type: s1
      - id: chnl
        type: s1
  kernings:
    seq:
      - id: magic
        contents: [5]
      - id: block_size
        type: s4
      - id: kerning
        type: kerning
        repeat: expr
        repeat-expr: block_size / 10
  kerning:
    seq:
      - id: first
        type: u4
      - id: second
        type: u4
      - id: amount
        type: s2
