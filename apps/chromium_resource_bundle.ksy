meta:
  id: chromium_resource_bundle
  title: Chromium 96 .pak File
  application: Chromium 96
  file-extension: pak
  endian: le

seq:
  # data_pack.cc: DataPack::LoadFromPath()
  # Can optionally start with a GZipHeader: GZipHeader::ReadMore()

  # DataPack::LoadImpl()
  - id: version
    type: u4
    enum: version
  - id: header
    type: header_v5
    if: version == version::v5
  - id: entries
    type: entry(_index)
    repeat: expr
    repeat-expr: header.resource_count
  - id: aliases
    type: alias
    repeat: expr
    repeat-expr: header.alias_count

types:
  header_v5:
    seq:
      - id: text_encoding
        type: u4
        enum: text_encoding_type
      - id: resource_count
        type: u2
      - id: alias_count
        type: u2

  entry: # DataPack::Entry
    params:
      - id: i
        type: u4
    seq:
      - id: resource_id
        type: u2
      - id: file_offset
        type: u4
    instances:
      resource_size:
        value: 'i < _parent.header.resource_count - 1 ? _parent.entries[i+1].file_offset - _parent.entries[i].file_offset : _io.size - _parent.entries[i].file_offset'
      body:
        pos: file_offset
        size: resource_size
    -webide-representation: '{resource_id}: {file_offset}'

  alias: # DataPack::Alias
    seq:
      - id: resource_id
        type: u2
      - id: entry_index
        type: u2
    -webide-representation: '{entry_index} -> {resource_id}'

enums:
  text_encoding_type: # ResourceHandle::TextEncodingType
    0: binary
    1: utf8
    2: utf16

  version:
    4: v4 # kFileFormatV4
    5: v5 # kFileFormatV5
