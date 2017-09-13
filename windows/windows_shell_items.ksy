meta:
  id: windows_shell_items
  title: Windows Shell Items
  endian: le
  xref:
    forensicswiki: Shell Item
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
    repeat-until: _.len_body == 0
    doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.2.1'
types:
  shell_item:
    -orig-id: ItemID
    doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.2.2'
    seq:
      - id: len_body
        type: u2
      - id: data
        size: len_body - 2
        if: len_body >= 2
