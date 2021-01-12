meta:
  id: xiaomi_depthmap
  endian: le
  title: Xiaomi depth images
  license: MIT
doc: |
  Parser for Depthmaps embedded in photos taken with last models of Xiaomi phones.
  Still WIP.
  See https://github.com/VincenzoLaSpesa/XiaomiDepthMapExtractor for more info.
seq:
  - id: magic
    contents: "PMPD"
  - id: image_info
    type: info
  - id: padding
    type: padding80  
  - id: depthmap_info
    type: type_depthmap_info
  - id: confidence_map
    doc: the confidence map, probably
    type: sector
    repeat: until
    repeat-until: not _.has_next
  - id: depthmap
    doc: the depthmap
    size-eos: true
    
types:
  info:
    doc: Header of the file. Contains the raw lenght and many fields i still don't undestand
    seq:
      - id: unknown1
        type: u2
      - id: unknown2
        type: u2
      - id: unknown3
        type: u2
      - id: unknown4
        type: u2
      - id: unknown5
        type: u2
      - id: unknown6
        type: u2
      - id: depth_size
        type: u2
      - id: unknown7
        type: u2
      - id: padding1
        size: 4
      - id: unknown8
        type: u4
      - id: unknown9
        type: u4
  
  padding80:
    doc: 1kb of 0x80
    seq:
    - id: head
      contents: [0x80]
    - id: padding 
      size: 1022
    - id: tail
      contents: [0x80]


  type_depthmap_info: 
    doc: 17+1007 = 1kb, info about the shape of the depthmap
    seq:
    - id: head
      contents: [01,00,0xFF,0xFF]
    - id: image_width
      type: u4
    - id: image_height_padded 
      type: u4
      doc: the size of the height _after padding_, the real image will be shorter
    - id: unknown1
      type: u4
    - id: is_landscape
      type: u1      
    - id: data
      size: 1007
  
  sector:
    doc: A sector of the confidence map, probably. I still don't undestand this part.
    seq:
      - id: padding
        size: 128
      - id: data
        size: 1024
    instances: 
      lookahead_data0:
        pos: _io.pos
        size: 128
      has_next: 
        value: lookahead_data0 == [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x21, 0x22, 0x23,0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F,0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B,0x3C, 0x3D, 0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50, 0x51, 0x52, 0x53,0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B,0x6C, 0x6D, 0x6E, 0x6F, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F]