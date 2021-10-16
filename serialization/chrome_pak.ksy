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
    type: file_header
types:
  file_header:
    seq:
      - id: num_resources_v4
        type: u4
        if: v == 4
      - id: encoding
        type: u1
        enum: encoding
      - id: v5_part
        type: header_v5_part
        if: v == 5
      - id: resources
        type: resource(_index, _index < num_resources)
        repeat: expr
        repeat-expr: num_resources + 1
        doc: |
          The length is calculated by looking at the offset of
          the next item, so an extra entry is stored with id 0
          and offset pointing to the end of the resources.
      - id: aliases
        type: alias
        repeat: expr
        repeat-expr: num_aliases
    instances:
      v:
        value: _parent.version
      num_resources:
        value: 'v == 5 ? v5_part.num_resources : num_resources_v4'
      num_aliases:
        value: 'v == 5 ? v5_part.num_aliases : 0'
  header_v5_part:
    seq:
      - id: encoding_padding
        size: 3
      - id: num_resources
        type: u2
      - id: num_aliases
        type: u2
  alias:
    seq:
      - id: id
        type: u2
      - id: index
        type: u2
  resource:
    -webide-representation: 'o:{ofs_body} s:{len_body}'
    params:
      - id: idx
        type: s4
      - id: has_body
        type: bool
    seq:
      - id: id
        type: u2
      - id: ofs_body
        type: u4
    instances:
      len_body:
        value: _parent.resources[idx + 1].ofs_body - ofs_body
        if: has_body
        doc: MUST NOT be accessed until the next `resource` is parsed
      body:
        pos: ofs_body
        size: len_body
        if: has_body
        doc: MUST NOT be accessed until the next `resource` is parsed
enums:
  encoding:
    0: binary
    1: utf8
    2: utf16
