meta:
  id: prg_lcg
  title: Linear Congruential Generator
  xref:
    iso: 28640:2010
    wikidata: Q1190228
  license: Unlicense
  endian: le
doc: |
  A simple non-secure pseudorandom generator.
  initialize with
    initial_prg_state:
      pos: 0
      type: prg_lcg(a, c, count_of_bits_of_output, prg_seed)
  get pseudorandom value corresponding to seed `state.seed`
    value: state.value
  update the state:
    value: state.next

  for example, in order to get the second pseudorandom value you need
    value: initial_prg_state.next.value
params:
  - id: a
    type: u4
  - id: c
    type: u4
  - id: offset_bits
    type: u1
  - id: value_bits
    type: u1
  - id: initial_seed
    type: u4
instances:
  value_mask:
    value: (1 << value_bits) - 1
  state:
    pos: 0
    type: prg_lcg_state(initial_seed)
  next:
    value: state.next
  value:
    value: state.value
types:
  prg_lcg_state:
    params:
      - id: prev_seed
        type: u4
    instances:
      seed:
        value: prev_seed * _root.a + _root.c
      value:
        value: (seed >> _root.offset_bits) & _root.value_mask
      next:
        pos: 0
        type: prg_lcg_state(seed)
