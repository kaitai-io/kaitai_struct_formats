meta:
  id: chrome_pak
  title: Chrome PAK serialization format
  file-extension: pak
  tags:
    - archive
    - serialization
  license: CC0-1.0
  endian: le
doc: |
  Format mostly used by Google Chrome and various Android apps to store
  resources such as translated strings, help messages and images.
doc-ref:
  - https://dev.chromium.org/developers/design-documents/linuxresourcesandlocalizedstrings # version 4
  - https://chromium.googlesource.com/chromium/src/tools/grit/+/3c36f27/grit/format/data_pack.py # version 4
  - https://chromium.googlesource.com/chromium/src/tools/grit/+/8a23eae/grit/format/data_pack.py # version 5
seq:
  - id: version
    type: u4
    valid:
      any-of: [4, 5]
    doc: only versions 4 and 5 are supported
  - id: num_resources_v4
    type: u4
    if: version == 4
  - id: encoding
    type: u1
    enum: encodings
    doc: |
      Character encoding of all text resources in the PAK file. Note that
      the file can **always** contain binary resources, this only applies to
      those that are supposed to hold text.

      In practice, this will probably always be `encodings::utf8` - I haven't
      seen any organic file that would state otherwise. `UTF8` is also usually
      hardcoded in Python scripts from the GRIT repository that generate .pak
      files (for example
      [`pak_util.py:79`](https://chromium.googlesource.com/chromium/src/tools/grit/+/8a23eae/pak_util.py#79)).
  - id: v5_part
    type: header_v5_part
    if: version == 5
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
  num_resources:
    value: 'version == 5 ? v5_part.num_resources : num_resources_v4'
  num_aliases:
    value: 'version == 5 ? v5_part.num_aliases : 0'
types:
  header_v5_part:
    seq:
      - id: encoding_padding
        size: 3
      - id: num_resources
        type: u2
      - id: num_aliases
        type: u2
  resource:
    -webide-representation: '{id:dec} - o:{ofs_body} s:{len_body}'
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
  alias:
    -webide-representation: '{id:dec} -> resources[{resource_idx:dec}] ({resource})'
    seq:
      - id: id
        type: u2
      - id: resource_idx
        type: u2
        valid:
          max: _parent.num_resources - 1
    instances:
      resource:
        value: _parent.resources[resource_idx]
enums:
  encodings:
    0:
      id: binary
      doc: file is not expected to contain any text resources
    1:
      id: utf8
      doc: all text resources are encoded in UTF-8
    2:
      id: utf16
      doc: all text resources are encoded in UTF-16
