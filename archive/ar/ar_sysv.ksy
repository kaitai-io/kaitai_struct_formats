meta:
  id: ar_sysv
  title: Unix ar archive (System V/GNU/Windows variant)
  application: ar
  file-extension:
    - a # Unix/generic
    - lib # Windows
    - rlib # Rust
  xref:
    justsolve: AR
    mime: application/x-archive
    wikidata: Q300839
  license: CC0-1.0
  imports:
    - member_metadata
    - space_padded_number
doc: |
  The System V variant of the Unix ar archive format (see the `ar_generic` spec for general info about the ar format). This variant is also used on Linux and Windows systems.
  
  System V archives support member names that contain spaces by terminating the name field using a slash instead of a space. File names longer than 16 bytes are supported by storing the name in a special archive member called "//" and only storing a byte offset in the member name field.
doc-ref: |
  https://en.wikipedia.org/w/index.php?title=Ar_(Unix)&oldid=880452895#File_format_details
  https://docs.oracle.com/cd/E36784_01/html/E36873/ar.h-3head.html
  https://llvm.org/docs/CommandGuide/llvm-ar.html#file-format
  https://github.com/llvm/llvm-project/blob/llvmorg-7.0.1/llvm/lib/Object/Archive.cpp
seq:
  - id: magic
    -orig-id: ARMAG
    contents: "!<arch>\n"
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
      : members.size > 2 and members[2].name_internal.raw == long_name_list_name ? 2
      : -1
    doc: |
      The index of the special "long name list" member in the members array, or `-1` if this archive doesn't contain a long name list.
      
      Note: the long name list is only recognized if it is one of the first three archive members. This is because it it always appears immediately after the symbol table (or if there is no symbol table, at the very beginning of the archive). Windows archives can contain two symbol table members, so the long name list can be at most the third member.
  long_name_list:
    value: members[long_name_list_index]
    if: long_name_list_index != -1
    doc: A special archive member that holds a list of long names used by other archive members. (Optional, only present if the archive has members with long names.)
types:
  regular_member_name:
    seq:
      - id: name
        terminator: 0x2f
        pad-right: 0x20
        doc: The member name, terminated by a slash, and right-padded with spaces.
    doc: A regular (or "short") member name, stored directly in the name field.
  long_member_name:
    seq:
      - id: slash
        contents: "/"
      - id: offset
        type: space_padded_number(15, 10)
        doc: The byte offset in the long name list at which the actual member name is stored.
    instances:
      name:
        io: _root.long_name_list.data_internal._io
        pos: offset.value
        terminator: 0x2f
        doc: The member name stored in the long name list, terminated by a slash.
    doc: A long member name, stored as a reference into the long name list.
  special_member_name:
    seq:
      - id: name
        terminator: 0x20
        pad-right: 0x20
        doc: The member name, as a byte array, right-padded using ASCII spaces.
    doc: A "special" member name that does not follow the usual format. This kind of name is used for special members that do not represent a normal file, such as the symbol table (named "/", or on 64-bit Solaris "/SYM64/") and the long name list (named "//").
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
      is_regular:
        value: first_char != 0x2f
      regular:
        pos: 0
        type: regular_member_name
        if: is_regular
      is_long:
        value: first_char == 0x2f and second_char >= ascii_zero and second_char <= ascii_nine
      long:
        pos: 0
        type: long_member_name
        if: is_long
      special:
        pos: 0
        type: special_member_name
        if: not is_regular and not is_long
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
      - id: metadata
        type: member_metadata
        doc: The member's metadata (timestamp, user and group ID, mode).
      - id: size
        -orig-id: ar_size
        type: space_padded_number(10, 10)
        doc: The size of the member's data. The trailing padding byte (if any) does not count toward the data size.
      - id: header_terminator
        -orig-id: ar_fmag
        contents: "`\n"
        doc: Marks the end of the header.
      - id: data_internal
        type: member_data
        size: size.value
        doc: Internal helper field, do not use directly, use the `data` instance instead.
      - id: padding
        contents: "\n"
        if: size.value % 2 != 0
        doc: An extra newline is added as padding after members with an odd data size. This ensures that all members are 2-byte-aligned.
    instances:
      name:
        value: |
          name_internal.is_regular ? name_internal.regular.name
          : name_internal.is_long ? name_internal.long.name
          : name_internal.special.name
        doc: |
          The name of the archive member. Because the encoding of member names varies across systems, the name is exposed as a byte array.
          
          Names are usually unique within an archive, but this is not required - the `ar` command even provides various options to work with archives containing multiple identically named members.
      data:
        value: data_internal.data
        doc: The member's data.
    doc: |
      An archive member's header and data.
      
      By default, modern ar implementations set the modification timestamp, user ID and group ID to 0 and the mode to 644 (octal), regardless of the file's original metadata, to make archive creation reproducible.
      
      Rarely, the modification timestamp, user ID, group ID and mode fields may be blank (only spaces). This is the case in particular for the '//' member (the long name list).
