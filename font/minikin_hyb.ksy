meta:
  id: minikin_hyb
  title: Libminikin text layout format
  file-extension: hyb
  tags:
    - android
  license: CC0-1.0
  endian: le
doc: |
  Text layout format as used on Android

  https://lwn.net/Articles/662569/
doc-ref: https://android.googlesource.com/platform/frameworks/minikin/+/6c8722e/doc/hyb_file_format.md
seq:
  - id: magic
    contents: [0x68, 0x79, 0xad, 0x62]
  - id: version
    type: u4
    valid: 0
  - id: ofs_alphabet
    -orig-id: alphabet_offset
    type: u4
  - id: ofs_trie
    -orig-id: trie_offset
    type: u4
  - id: ofs_pattern
    -orig-id: ofs_pattern
    type: u4
  - id: file_size
    type: u4
instances:
  alphabet:
    pos: ofs_alphabet
    type: alphabet
  trie:
    pos: ofs_trie
    type: trie
  pattern:
    pos: ofs_pattern
    type: pattern
types:
  alphabet:
    seq:
      - id: version
        type: u4
      - id: alphabet_table
        type:
          switch-on: version
          cases:
            0: alphabet_direct
            1: alphabet_general
  alphabet_direct:
    seq:
      - id: min_codepoint
        type: u4
      - id: max_codepoint
        type: u4
      - id: alphabet_data
        size: max_codepoint - min_codepoint
      - id: padding
        size: (-(max_codepoint - min_codepoint) % 4)
    instances:
      size:
        value: 8 + (max_codepoint - min_codepoint)
  alphabet_general:
    seq:
      - id: num_entries
        -orig-id: n_entries
        type: u4
      - id: entries
        type: u4
        repeat: expr
        repeat-expr: num_entries
    instances:
      size:
        value: 4 + num_entries * 4
  trie:
    seq:
      - id: version
        type: u4
        valid: 0
      - id: char_mask
        type: u4
      - id: link_shift
        type: u4
      - id: link_mask
        type: u4
      - id: pattern_shift
        type: u4
      - id: num_entries
        -orig-id: n_entries
        type: u4
      - id: entries
        type: u4
        repeat: expr
        repeat-expr: num_entries
    instances:
      size:
        value: num_entries * 4 + 6*4
  pattern:
    seq:
      - id: version
        type: u4
        valid: 0
      - id: num_entries
        -orig-id: n_entries
        type: u4
      - id: ofs_pattern
        -orig-id: pattern_offset
        type: u4
      - id: len_pattern
        -orig-id: pattern_size
        type: u4
      - id: entries
        type: u4
        repeat: expr
        repeat-expr: num_entries
      - id: pattern_buf
        size: len_pattern
    instances:
      size:
        value: len_pattern + num_entries * 4 + 4*4
