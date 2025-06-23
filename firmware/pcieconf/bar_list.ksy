meta:
  id: bar_list
  endian: le
  license: 0BSD

doc: PCI configuration space BAR segment

doc-ref:
  PCI LOCAL BUS SPECIFICATION, REV. 3.0
  p224, 6.2.5. Base Addresses

seq:
  - id: bar
    type: bar
    repeat: eos

types:
  bar:
    seq:
      - id: dword0
        type: u4
      - id: dword1
        type: u4
        if: 'addr_size == bar_size::size64'
    instances:
      space:
        value: dword0 & 0x1
        enum: bar_space
      addr_size:
        value: >-
          space == bar_space::mem ? (dword0 >> 1) & 3 : bar_size::size32
        enum: bar_size
      addr:
        type:
          switch-on: space
          cases:
            'bar_space::mem': bar_mem
            'bar_space::io': bar_io

  bar_mem:
    instances:
      addr:
        # TODO: elaborate on masking
        value: >-
         (_parent.dword0 & 0xfffffff0) |
         (_parent.addr_size == bar_size::size64
             ? _parent.dword1 << 32  : 0)
      prefetchable:
        value: (_parent.dword0 >> 3) & 1

  bar_io:
    instances:
      addr:
        # TODO: elaborate on masking
        value: _parent.dword0 & 0xfffffffc

enums:
  bar_space:
    0: mem
    1: io

  bar_size:
    0: size32
    1: reserved01
    2: size64
    3: reserved11
