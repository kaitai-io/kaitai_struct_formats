meta:
  id: systemd_journal
  title: systemd journal file
  file-extension: journal
  xref:
    forensicswiki: Systemd
  tags:
    - linux
    - log
  license: CC0-1.0
  endian: le
doc: |
  systemd, a popular user-space system/service management suite on Linux,
  offers logging functionality, storing incoming logs in a binary journal
  format.

  On live Linux system running systemd, these journals are typically located at:

  * /run/log/journal/machine-id/*.journal (volatile, lost after reboot)
  * /var/log/journal/machine-id/*.journal (persistent, but disabled by default on Debian / Ubuntu)
doc-ref: https://www.freedesktop.org/wiki/Software/systemd/journal-files/
seq:
  - id: header
    type: header
    size: len_header
  - id: objects
    type: journal_object
    repeat: expr
    repeat-expr: header.num_objects
instances:
  len_header:
    pos: 0x58
    type: u8
    doc: |
      Header length is used to set substream size, as it thus required
      prior to declaration of header.
  data_hash_table:
    pos: header.ofs_data_hash_table
    size: header.len_data_hash_table
  field_hash_table:
    pos: header.ofs_field_hash_table
    size: header.len_field_hash_table
enums:
  state:
    0:
      id: offline
      doc: File is closed and thus not being written into right now
    1:
      id: online
      doc: File is open and thus might be undergoing update at the moment
    2:
      id: archived
      doc: File has been rotated, no further updates to this file are to be expected
types:
  header:
    seq:
      - id: signature
        contents: LPKSHHRH
      - id: compatible_flags
        type: u4
      - id: incompatible_flags
        type: u4
      - id: state
        type: u1
        enum: state
      - id: reserved
        size: 7
      - id: file_id
        size: 16
      - id: machine_id
        size: 16
      - id: boot_id
        size: 16
      - id: seqnum_id
        size: 16
      - id: len_header
        -orig-id: header_size
        type: u8
      - id: len_arena
        -orig-id: arena_size
        type: u8
      - id: ofs_data_hash_table
        -orig-id: data_hash_table_offset
        type: u8
      - id: len_data_hash_table
        -orig-id: data_hash_table_size
        type: u8
      - id: ofs_field_hash_table
        -orig-id: field_hash_table_offset
        type: u8
      - id: len_field_hash_table
        -orig-id: field_hash_table_size
        type: u8
      - id: ofs_tail_object
        -orig-id: tail_object_offset
        type: u8
      - id: num_objects
        -orig-id: n_objects
        type: u8
      - id: num_entries
        -orig-id: n_entries
        type: u8
      - id: tail_entry_seqnum
        type: u8
      - id: head_entry_seqnum
        type: u8
      - id: ofs_entry_array
        -orig-id: entry_array_offset
        type: u8
      - id: head_entry_realtime
        type: u8
      - id: tail_entry_realtime
        type: u8
      - id: tail_entry_monotonic
        type: u8

      # Added in 187
      - id: num_data
        -orig-id: n_data
        type: u8
        if: not _io.eof
      - id: num_fields
        -orig-id: n_fields
        type: u8
        if: not _io.eof

      # Added in 189
      - id: num_tags
        -orig-id: n_tags
        type: u8
        if: not _io.eof
      - id: num_entry_arrays
        -orig-id: n_entry_arrays
        type: u8
        if: not _io.eof
  journal_object:
    doc-ref: 'https://www.freedesktop.org/wiki/Software/systemd/journal-files/#objects'
    seq:
      - id: padding
        size: (8 - _io.pos) % 8
      - id: object_type
        type: u1
        enum: object_types
      - id: flags
        type: u1
      - id: reserved
        size: 6
      - id: len_object
        type: u8
      - id: payload
        size: len_object - 16
        type:
          switch-on: object_type
          cases:
            'object_types::data': data_object
    enums:
      object_types:
        0: unused
        1: data
        2: field
        3: entry
        4: data_hash_table
        5: field_hash_table
        6: entry_array
        7: tag
  data_object:
    doc: |
      Data objects are designed to carry log payload, typically in
      form of a "key=value" string in `payload` attribute.
    doc-ref: 'https://www.freedesktop.org/wiki/Software/systemd/journal-files/#dataobjects'
    seq:
      - id: hash
        type: u8
      - id: ofs_next_hash
        -orig-id: next_hash_offset
        type: u8
      - id: ofs_head_field
        -orig-id: head_field_offset
        type: u8
      - id: ofs_entry
        -orig-id: entry_offset
        type: u8
      - id: ofs_entry_array
        -orig-id: entry_array_offset
        type: u8
      - id: num_entries
        -orig-id: n_entries
        type: u8
      - id: payload
        size-eos: true
    instances:
      next_hash:
        io: _root._io
        pos: ofs_next_hash
        type: journal_object
        if: ofs_next_hash != 0
      head_field:
        io: _root._io
        pos: ofs_head_field
        type: journal_object
        if: ofs_head_field != 0
      entry:
        io: _root._io
        pos: ofs_entry
        type: journal_object
        if: ofs_entry != 0
      entry_array:
        io: _root._io
        pos: ofs_entry_array
        type: journal_object
        if: ofs_entry_array != 0
