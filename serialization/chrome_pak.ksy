meta:
  id: chrome_pak
  title: Chrome PAK serialization format
  file-extension: pak
  license: CC0-1.0
  endian: le
doc: |
  Format mostly used by Google Chrome and various Android apps to store
  resources such as translated strings, help messages and images.
doc-ref:
  - http://dev.chromium.org/developers/design-documents/linuxresourcesandlocalizedstrings # version 4
  - https://chromium.googlesource.com/chromium/src/tools/grit/+/22f7a68bb5ad68fe4192d0f34466049038735b9c/grit/format/data_pack.py # version 4
  - https://chromium.googlesource.com/chromium/src/tools/grit/+/c1a76d6143016e9b2c292236bab623d1497cd31f/grit/format/data_pack.py # version 5
seq:
  - id: version
    type: u4
    valid:
      any-of: [4, 5]
    doc: only versions 4 and 5 are supported
  - id: header
    type:
      switch-on: version
      cases:
        4: header4
        5: header5
types:
  header4:
    seq:
      - id: number_of_resources
        type: u4
      - id: encoding
        type: u1
        enum: encoding
      - id: resources
        type: resource
        repeat: expr
        repeat-expr: number_of_resources + 1
        doc: |
          The length is calculated by looking at the offset of
          the next item, so an extra entry is stored with id 0
          and offset pointing to the end of the resources.
  header5:
    seq:
      - id: encoding
        type: u1
        enum: encoding
      - id: ignore
        size: 3
        doc: These three bytes have no meaning in the file
      - id: number_of_resources
        type: u2
      - id: number_of_aliases
        type: u2
      - id: resources
        type: resource
        repeat: expr
        repeat-expr: number_of_resources + 1
        doc: |
          The length is calculated by looking at the offset of
          the next item, so an extra entry is stored with id 0
          and offset pointing to the end of the resources.
      - id: aliases
        type: alias
        repeat: expr
        repeat-expr: number_of_aliases
  alias:
    seq:
      - id: id
        type: u2
      - id: index
        type: u2
  resource:
    seq:
      - id: id
        type: u2
      - id: offset
        type: u4
enums:
  encoding:
    0: binary
    1: utf8
    2: utf16
