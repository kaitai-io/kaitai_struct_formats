meta:
  id: apple_single_double
  title: AppleSingle / AppleDouble
  endian: be
  xref:
    forensicswiki: AppleDouble_header_file
    justsolve: AppleDouble
    rfc: 1740
    wikidata: Q4781113
  license: CC0-1.0
doc: |
  AppleSingle and AppleDouble files are used by certain Mac
  applications (e.g. Finder) to store Mac-specific file attributes on
  filesystems that do not support that.

  Syntactically, both formats are the same, the only difference is how
  they are being used:

  * AppleSingle means that only one file will be created on external
    filesystem that will hold both the data (AKA "data fork" in Apple
    terminology), and the attributes (AKA "resource fork").
  * AppleDouble means that two files will be created: a normal file
    that keeps the data ("data fork") is kept separately from an
    auxiliary file that contains attributes ("resource fork"), which
    is kept with the same name, but starting with an extra dot and
    underscore `._` to keep it hidden.

  In modern practice (Mac OS X), Finder only uses AppleDouble to keep
  compatibility with other OSes, as virtually nobody outside of Mac
  understands how to access data in AppleSingle container.
doc-ref: http://kaiser-edv.de/documents/AppleSingle_AppleDouble.pdf
seq:
  - id: magic
    type: u4
    enum: file_type
  - id: version
    type: u4
  - id: reserved
    size: 16
    doc: Must be all 0.
  - id: num_entries
    type: u2
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
enums:
  file_type:
    0x00051600: apple_single
    0x00051607: apple_double
types:
  entry:
    seq:
      - id: type
        type: u4
        enum: types
      - id: ofs_body
        type: u4
      - id: len_body
        type: u4
    instances:
      body:
        pos: ofs_body
        size: len_body
        type:
          switch-on: type
          cases:
            'types::finder_info': finder_info
    enums:
      types:
        1:
          id: data_fork
        2:
          id: resource_fork
        3:
          id: real_name
          doc: File name on a file system that supports all the attributes.
        4:
          id: comment
        5:
          id: icon_bw
        6:
          id: icon_color
        8:
          id: file_dates_info
          doc: File creation, modification, access date/timestamps.
        9:
          id: finder_info
        10:
          id: macintosh_file_info
        11:
          id: prodos_file_info
        12:
          id: msdos_file_info
        13:
          id: afp_short_name
        14:
          id: afp_file_info
        15:
          id: afp_directory_id
  finder_info:
    -orig-id: FInfo
    doc: Information specific to Finder
    doc-ref: older Inside Macintosh, Volume II page 84 or Volume IV page 104.
    seq:
      - id: file_type
        -orig-id: fdType
        size: 4
      - id: file_creator
        -orig-id: fdCreator
        size: 4
      - id: flags
        -orig-id: fdFlags
        type: u2
      - id: location
        -orig-id: fdLocation
        type: point
        doc: File icon's coordinates when displaying this folder.
      - id: folder_id
        -orig-id: fdFldr
        type: u2
        doc: File folder ID (=window).
  point:
    doc: Specifies 2D coordinate in QuickDraw grid.
    seq:
      - id: x
        type: u2
      - id: y
        type: u2
