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
  # The ar format is somewhat unusual: although it can store arbitrary data files, the ar format itself is text-based - all fields and magic numbers are pure ASCII.
  # In particular, numerical values are stored as ASCII-encoded decimal and octal numbers, rather than packed byte values.  Because of this, the ar format has no endianness.
  # Note: the encoding specified here is not used to interpret member names. As different systems use different encodings, they are exposed as byte arrays.
  encoding: ASCII
doc: |
  The Unix ar archive format, as created by the `ar` utility. It is a simple uncompressed flat archive format, but is rarely used for general-purpose archiving. Instead, it is commonly used by linkers to collect multiple object files along with a symbol table into a static library. The Debian package format (.deb) is also based on the ar format.
  
  The ar format is not standardized and several variants have been developed, which differ mainly in how member names and the symbol table (if any) are stored. This specification describes the System V variant, including the GNU and Windows variants that derive from it.
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
      parsed:
        pos: 0
        type:
          switch-on: 'first_char == 0x2f ? second_char >= ascii_zero and second_char <= ascii_nine ? 1 : 2 : 0'
          cases:
            0: regular_member_name
            1: long_member_name
            2: special_member_name
        doc: The parsed version of the member name, with terminators and padding removed and long names resolved.
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
        doc: Internal helper field, do not use directly, use the `data` instance instead.
      - id: padding
        contents: "\n"
        if: size % 2 != 0
        doc: An extra newline is added as padding after members with an odd data size. This ensures that all members are 2-byte-aligned.
    instances:
      name:
        value: name_internal.parsed
        doc: |
          The name of the archive member. Because the encoding of member names varies across systems, the name is exposed as a byte array.
          
          Names are usually unique within an archive, but this is not required - the `ar` command even provides various options to work with archives containing multiple identically named members.nce with a `name` attribute.
      size:
        value: size_dec.to_i
        doc: The size of the member's data, parsed as an integer.
      data:
        value: data_internal.data
        doc: The member's data.
    doc: |
      An archive member's header and data.
      
      By default, modern ar implementations set the modification timestamp, user ID and group ID to 0 and the mode to 644 (octal), regardless of the file's original metadata, to make archive creation reproducible.
      
      Rarely, the modification timestamp, user ID, group ID and mode fields may be blank (only spaces). This is the case in particular for the '//' member (the long name list) of SysV archives.
