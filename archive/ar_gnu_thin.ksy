meta:
  id: ar_gnu_thin
  title: GNU binutils thin ar archive
  application: ar
  file-extension:
    - a
  license: CC0-1.0
  # The ar format is somewhat unusual: although it can store arbitrary data files, the ar format itself is text-based - all fields and magic numbers are pure ASCII.
  # In particular, numerical values are stored as ASCII-encoded decimal and octal numbers, rather than packed byte values.  Because of this, the ar format has no endianness.
  # Note: the encoding specified here is not used to interpret member names. As different systems use different encodings, they are exposed as byte arrays.
  encoding: ASCII
doc: |
  The thin ar archive format, as created by the GNU binutils `ar` utility using the `T` flag. Thin archives are used by GNU binutils as a more efficient format for locally-created static libraries than the regular ar format. Thin archives only store the paths of all contained files (relative to the archive), but not the files' actual data - to read data from the archive, the original files need to be looked up and read. This makes thin archives unsuitable for general-purpose archiving (in fact, GNU `ar` does not support manually extracting thin archives), they are only meant to be used as a static library format.
  
  The internal structure of thin archives is very similar to regular System V/GNU ar archives, but the formats are not compatible.
doc-ref: https://sourceware.org/binutils/docs/binutils/ar.html
seq:
  - id: magic
    -orig-id: ARMAG
    contents: "!<thin>\n"
    doc: Magic number.
  - id: members
    type: member
    repeat: eos
    doc: List of archive members. May be empty.
instances:
  long_name_list_name:
    value: '[0x2f, 0x2f, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20]'
    doc: The name of the special "long name list" member. This is a byte array containing "//" (two slashes) right-padded using 14 spaces (in ASCII).
  long_name_list_index:
    value: |
      members.size > 0 and members[0].name_internal.raw == long_name_list_name ? 0
      : members.size > 1 and members[1].name_internal.raw == long_name_list_name ? 1
      : -1
    doc: |
      The index of the special "long name list" member in the members array, or `-1` if this archive doesn't contain a long name list.
      
      Note: the long name list is only recognized if it is one of the first two archive members. This is because it it always appears immediately after the symbol table (or if there is no symbol table, at the very beginning of the archive).
  long_name_list:
    value: members[long_name_list_index]
    if: long_name_list_index != -1
    doc: A special archive member that holds a list of long names used by other archive members. (Optional, only present if the archive has members with long names.)
types:
  long_member_name:
    seq:
      - id: slash
        contents: "/"
      - id: offset_dec
        type: str
        terminator: 0x20
        pad-right: 0x20
        doc: A byte offset in ASCII decimal, right-padded using spaces. This indicates where the actual member name is stored in the long name list.
    instances:
      offset:
        value: offset_dec.to_i
        doc: The offset of the file name, parsed as an integer.
      name:
        io: _root.long_name_list.data_internal._io
        pos: offset
        # The terminator is actually a slash followed by a newline, but multi-character terminators are not supported by Kaitai, and it's very unlikely that a path will contain a newline.
        terminator: 0x0a
        doc: The member name (actually a relative path) stored in the long name list, terminated by a slash and a newline. For technicaly reasons, includes the terminating slash (but not the newline).
    doc: A long member name (actually a relative path), stored as a reference into the long name list.
  special_member_name:
    seq:
      - id: name
        terminator: 0x20
        pad-right: 0x20
        doc: The member name, as a byte array, right-padded using ASCII spaces.
    doc: A "special" member name that does not follow the usual format. This kind of name is used for special members that do not represent a normal file, such as the symbol table (named "/") and the long name list (named "//").
  member_name:
    seq:
      - id: raw
        size: 16
        doc: The name of the archive member as a 16-byte array, including any padding spaces at the end.
    instances:
      ascii_zero:
        value: 0x30
      ascii_nine:
        value: 0x39
      first_char:
        pos: 0
        type: u1
      second_char:
        pos: 1
        type: u1
      is_long:
        value: first_char == 0x2f and second_char >= ascii_zero and second_char <= ascii_nine
      long:
        pos: 0
        type: long_member_name
        if: is_long
      special:
        pos: 0
        type: special_member_name
        if: not is_long
  member_data:
    seq:
      - id: data
        size-eos: true
    doc: Dummy type representing a member's data. This type is used instead of a normal byte array to allow "looking into" it using instances (this is needed to handle long member names).
  member:
    seq:
      - id: name_internal
        -orig-id: ar_name
        size: 16
        type: member_name
        doc: Internal helper field, do not use directly, use the `name` instance instead.
      - id: modified_timestamp_dec
        -orig-id: ar_date
        size: 12
        type: str
        terminator: 0x20
        pad-right: 0x20
        doc: The member's modification time, as a Unix timestamp, in ASCII decimal, right-padded with spaces.
      - id: user_id_dec
        -orig-id: ar_uid
        size: 6
        type: str
        terminator: 0x20
        pad-right: 0x20
        doc: The member's user ID, in ASCII decimal, right-padded with spaces.
      - id: group_id_dec
        -orig-id: ar_gid
        size: 6
        type: str
        terminator: 0x20
        pad-right: 0x20
        doc: The member's group ID, in ASCII decimal, right-padded with spaces.
      - id: mode_oct
        -orig-id: ar_mode
        size: 8
        type: str
        terminator: 0x20
        pad-right: 0x20
        doc: The member's mode bits, in ASCII octal, right-padded with spaces.
      - id: size_dec
        -orig-id: ar_size
        size: 10
        type: str
        terminator: 0x20
        pad-right: 0x20
        doc: The size of the member's data, in ASCII decimal, right-padded with spaces. The trailing padding byte (if any) does not count toward the data size.
      - id: header_terminator
        -orig-id: ar_fmag
        contents: "`\n"
        doc: Marks the end of the header.
      - id: data_internal
        type: member_data
        size: size
        if: not name_internal.is_long
        doc: Internal helper field, do not use directly, use the `data` instance instead.
      - id: padding
        contents: "\n"
        if: not name_internal.is_long and size % 2 != 0
        doc: An extra newline is added as padding after members with an odd data size. This ensures that all members are 2-byte-aligned.
    instances:
      name:
        value: 'name_internal.is_long ? name_internal.long.name : name_internal.special.name'
        doc: |
          The name of the archive member. Because the encoding of member names varies across systems, the name is exposed as a byte array.
          
          Names are usually unique within an archive, but this is not required - the `ar` command even provides various options to work with archives containing multiple identically named members.
      size:
        value: size_dec.to_i
        doc: The size of the member's data, parsed as an integer.
      data:
        value: data_internal.data
        if: not name_internal.is_long
        doc: The member's data. Only present for special members.
    doc: |
      An archive member's header and data.
      
      By default, modern ar implementations set the modification timestamp, user ID and group ID to 0 and the mode to 644 (octal), regardless of the file's original metadata, to make archive creation reproducible.
      
      Rarely, the modification timestamp, user ID, group ID and mode fields may be blank (only spaces). This is the case in particular for the '//' member (the long name list).
