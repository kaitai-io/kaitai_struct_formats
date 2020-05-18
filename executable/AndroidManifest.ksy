meta:
  id: android_manifest
  title: Android Binary manifest xml
  file-extension: xml
  endian: le
doc: |
    Android manifest has its own binary xml format.
    It is not documented.
seq:
  - id: hdr
    type: header
  - id: strings_table_info_size
    size: 4
    doc: |
      Size of all fields related to strings table.
      Size of strings table info often counts from 0x8 byte until
      first byte of strings table.
      It should be equal 7*4 + 4*strings_count. 
      7 - is a number of previous fields (4 bytes size).
      If it is not equal to that then there is an error in manifest strings offset 
  - id: styles_offset
    size: 4
  - id: strings_offset_table
    size: hdr.strings_count*4
    doc: table of strings offsets
  - id: strings
    type: manifest_string
    repeat: expr
    repeat-expr: hdr.strings_count*2
    doc: |
      Table of all strings in manifest. Strings are in UTF-16 encoding.
      Each string has its length in the beginning.
  - id: padding
    size: (4 - _io.pos) % 4
    doc: | 
      Resource header should be aligned to 4 bytes.
      Kaitai doesn't have 'align' keyword so we use this hack.
  - id: resource_hdr
    type: resource_header
  - id: resource_id
    type: u4
    repeat: expr
    repeat-expr: (resource_hdr.id_len-8)/4
  - id: xml_el
    type: xml_element
    repeat: eos
types:
  resource_header:
    seq:
    - id: table_id
      type: u2
      doc: | 
        id of type of table (strings, offsets, resources)
        for resources should be 0x0180
    - id: len
      type: u2
    - id: id_len
      type: u4
  file_remainder:
    seq:
    - id: remainder
      size: 1
      repeat: eos
      doc: we don't need this to build plaintext XML
  xml_element:
    seq:
    - id: id
      type: u2
    - id: body
      type:
        switch-on: id
        cases:
          256: xml_ns_start
          257: xml_ns_end
          258: xml_tag_start
          259: xml_tag_end
          300: xml_text
          _: file_remainder
  xml_element_header:
    seq:
    - id: signature
      size: 2
    - id: len
      type: u4
    - id: skip_2
      size: 8
      doc: skip line number and unknown 0xffffffff
  xml_ns_start:
    seq:
    - id: hdr
      type: xml_element_header
    - id: name_id
      type: u4
    - id: namespace_id
      type: u4
  xml_ns_end:
    seq:
    - id: signature
      size: 8
  xml_tag_start:
    seq:
    - id: hdr
      type: xml_element_header
    - id: namespace_id
      type: u4
    - id: name_id
      type: u4
    - id: flag_skip
      size: 4
    - id: attr_count
      type: u4
    - id: class_attr_id
      type: u4
      doc: |
        All above ids are used in picking names from resources.arsc file
    - id: attr_data
      size: 20
      repeat: expr
      repeat-expr: attr_count
  xml_tag_end:
    seq:
    - id: hdr
      type: xml_element_header
    - id: namespace_id
      type: u4
    - id: name_id
      type: u4
  xml_text:
    seq:
    - id: hdr
      type: xml_element_header
    - id: id
      type: u4
    - id: skip
      size: 8
  small_header:
    seq:
    - id: magic
      size: 2
      contents: [0x03, 0x00]
      doc: indicates binary form
    - id: len
      type: u2
      doc: small header includes magic, small header length, length of manifest 
    - id: file_len
      type: u4
      doc: length of manifest file
  header:
    seq:
    - id: small_hdr
      type: small_header
    - id: table_id
      type: u2
      doc: id of type of table (strings, offsets, resources)
    - id: len
      type: u2
      doc: full header includes all previous fields
    - id: string_table_len
      size: 4
    - id: strings_count
      type: u4
      doc: number of strings in manifest
    - id: styles_count
      size: 4
      doc: number of styles in manifest 
    - id: flags
      size: 4
      doc: |
        Indicates if strings in utf8 or utf16. 
        0x00000100 - utf8
   
  manifest_string:
    seq:
      - id: len
        type: u2
        doc: length of utf16 string
      - id: string
        type: strz
        encoding: UTF-16LE
        size: len*2
        doc: |
          The problem is kaitai doesn't correctly supports
          UTF-16 strings. Kaitai's 'terminator' keyword assumes
          null byte is [0x00] not UTF-16 null byte [0x00, 0x00]
      
    
  
