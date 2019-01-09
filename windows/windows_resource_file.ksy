meta:
  id: windows_resource_file
  title: Windows resource file
  file-extension: res
  xref:
    justsolve: Windows_resource
    wikidata: Q1417897
  license: CC0-1.0
  endian: le
doc: |
  Windows resource file (.res) are binary bundles of
  "resources". Resource has some sort of ID (numerical or string),
  type (predefined or user-defined), and raw value. Resource files can
  be seen standalone (as .res file), or embedded inside PE executable
  (.exe, .dll) files.

  Typical use cases include:

  * providing information about the application (such as title, copyrights, etc)
  * embedding icon(s) to be displayed in file managers into .exe
  * adding non-code data into the binary, such as menus, dialog forms,
    cursor images, fonts, various misc bitmaps, and locale-aware
    strings

  Windows provides special API to access "resources" from a binary.

  Normally, resources files are created with `rc` compiler: it takes a
  .rc file (so called "resource-definition script") + all the raw
  resource binary files for input, and outputs .res file. That .res
  file can be linked into an .exe / .dll afterwards using a linker.

  Internally, resource file is just a sequence of individual resource
  definitions. RC tool ensures that first resource (#0) is always
  empty.
seq:
  - id: resources
    type: resource
    repeat: eos
types:
  resource:
    doc: |
      Each resource has a `type` and a `name`, which can be used to
      identify it, and a `value`. Both `type` and `name` can be a
      number or a string.
    doc-ref: https://msdn.microsoft.com/en-us/library/windows/desktop/ms648027.aspx
    seq:
      - id: value_size
        -orig-id: DataSize
        type: u4
        doc: Size of resource value that follows the header
      - id: header_size
        -orig-id: HeaderSize
        type: u4
        doc: |
          Size of this header (i.e. every field except `value` and an
          optional padding after it)
      - id: type
        -orig-id: TYPE
        type: unicode_or_id
      - id: name
        -orig-id: NAME
        type: unicode_or_id
      - id: padding1
        size: (4 - _io.pos) % 4
      - id: format_version
        -orig-id: DataVersion
        type: u4
      - id: flags
        -orig-id: MemoryFlags
        type: u2
      - id: language
        -orig-id: LanguageId
        type: u2
      - id: value_version
        -orig-id: Version
        type: u4
        doc: Version for value, as specified by a user.
      - id: characteristics
        -orig-id: Characteristics
        type: u4
        doc: Extra 4 bytes that can be used by user for any purpose.
      - id: value
        size: value_size
      - id: padding2
        size: (4 - _io.pos) % 4
    instances:
      type_as_predef:
        doc: |
          Numeric type IDs in range of [0..0xff] are reserved for
          system usage in Windows, and there are some predefined,
          well-known values in that range. This instance allows to get
          it as enum value, if applicable.
        value: type.as_numeric
        enum: predef_types
        if: not type.is_string and type.as_numeric <= 0xff
    enums:
      predef_types:
        # https://msdn.microsoft.com/en-us/library/windows/desktop/ms648009.aspx
        # Win16
        1: cursor
        2: bitmap
        3: icon
        4: menu
        5: dialog
        6: string
        7: fontdir
        8: font
        9: accelerator
        10: rcdata
        12: group_cursor
        14: group_icon
        # Win32
        11: messagetable
        16: version
        17: dlginclude
        19: plugplay
        20: vxd
        21: anicursor
        22: aniicon
        23: html
        24: manifest
  unicode_or_id:
    doc: |
      Resources use a special serialization of names and types: they
      can be either a number or a string.

      Use `is_string` to check which kind we've got here, and then use
      `as_numeric` or `as_string` to get relevant value.
    seq:
      - id: first
        type: u2
        if: save_pos1 >= 0
      - id: as_numeric
        type: u2
        if: not is_string
      - id: rest
        type: u2
        repeat: until
        repeat-until: _ == 0
        if: is_string
      - id: noop
        size: 0
        if: is_string and save_pos2 >= 0
    instances:
      # Super dirty hack to save start and end position in a stream to re-read it as string if needed
      save_pos1:
        value: _io.pos
      save_pos2:
        value: _io.pos
      is_string:
        value: first != 0xffff
      as_string:
        pos: save_pos1
        type: str
        size: save_pos2 - save_pos1 - 2
        encoding: UTF-16LE
        if: is_string
