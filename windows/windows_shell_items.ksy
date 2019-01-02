meta:
  id: windows_shell_items
  title: Windows Shell Items
  xref:
    forensicswiki: Shell Item
  license: CC0-1.0
  endian: le
doc: |
  Windows Shell Items (AKA "shellbags") is an undocumented set of
  structures used internally within Windows to identify paths in
  Windows Folder Hierarchy. It is widely used in Windows Shell (and
  most visible in File Explorer), both as in-memory and in-file
  structures. Some formats embed them, namely:

  * Windows Shell link files (.lnk) Windows registry
  * Windows registry "ShellBags" keys

  The format is mostly undocumented, and is known to vary between
  various Windows versions.
doc-ref: https://github.com/libyal/libfwsi/blob/master/documentation/Windows%20Shell%20Item%20format.asciidoc
seq:
  - id: items
    -orig-id: IDList
    type: shell_item
    repeat: until
    repeat-until: _.len_data == 0
    doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.2.1'
types:
  shell_item:
    -orig-id: ItemID
    doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.2.2'
    seq:
      - id: len_data
        type: u2
      - id: data
        size: len_data - 2
        type: shell_item_data
        if: len_data >= 2
  shell_item_data:
    seq:
      - id: code
        type: u1
      - id: body1
        type:
          switch-on: code
          cases:
            0x1f: root_folder_body
      - id: body2
        type:
          switch-on: code & 0x70
          cases:
            0x20: volume_body
            0x30: file_entry_body
  root_folder_body:
    doc-ref: 'https://github.com/libyal/libfwsi/blob/master/documentation/Windows%20Shell%20Item%20format.asciidoc#32-root-folder-shell-item'
    seq:
      - id: sort_index
        type: u1
      - id: shell_folder_id
        size: 16
      # TODO: various extensions
  volume_body:
    doc-ref: 'https://github.com/libyal/libfwsi/blob/master/documentation/Windows%20Shell%20Item%20format.asciidoc#33-volume-shell-item'
    seq:
      - id: flags
        type: u1
  file_entry_body:
    doc-ref: 'https://github.com/libyal/libfwsi/blob/master/documentation/Windows%20Shell%20Item%20format.asciidoc#34-file-entry-shell-item'
    seq:
      - type: u1
      - id: file_size
        type: u4
      - id: last_mod_time
        type: u4
      - id: file_attrs
        type: u2
    instances:
      is_dir:
        value: _parent.code & 0x01 != 0
      is_file:
        value: _parent.code & 0x02 != 0
