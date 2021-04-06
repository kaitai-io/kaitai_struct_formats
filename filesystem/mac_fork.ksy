meta:
  id: mak_res
  file-extension: rsr
  endian: be
  title: Resource fork
  # http://freshmeat.sourceforge.net/projects/macfork
  # https://en.wikipedia.org/wiki/Resource_fork
seq:
  - id: res_header
    type: res_header
instances:
  map: 
    pos: res_header.map_offset + 22
    type: res_map
types:
  res_header:
    seq:
    - id: data_offset
      type: u4
    - id: map_offset
      type: u4
    - id: data_length
      type: u4
    - id: map_length
      type: u4
  res_map_head:
    seq:
    - id: res_attr
      type: s2
    - id: type_offset
      type: s2
    - id: name_offset
      type: s2
    - id: num_types
      type: s2
  res_map:
    seq:
    - id: head
      type: res_map_head
    - id: types
      type: res_type
      repeat: expr
      repeat-expr: head.num_types + 1
  res_type:
    seq:
    - id: id
      type: strz
      size: 4
      encoding: ASCII
    - id: items
      type: s2
    - id: offset
      type: s2
    instances:
      res_list:
        pos: _root.res_header.map_offset + _root.map.head.type_offset + offset
        type: resource
        repeat: expr
        repeat-expr: items + 1
  resource:
    seq:
    - id: id
      type: s2
    - id: name_offset
      type: s2
    - id: data_offset_read
      type: u4
    - id: reserved
      type: u4
    instances:
      attr:
        value: data_offset >> 24
      data_offset:
        value: data_offset_read & 0xFFFFFF
      name:
        pos: _root.res_header.map_offset + _root.map.head.name_offset + name_offset
        type: mac_str
        if: name_offset != -1
      data:
        pos: _root.res_header.data_offset + data_offset
        type: res_data
  mac_str:
    seq:
    - id: len
      type: u1
    - id: value
      type: str
      size: len
      encoding: ASCII
  res_data:
    seq:
    - id: len
      type: u4
    - id: data
      size: len
