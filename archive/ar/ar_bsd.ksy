meta:
  id: ar_bsd
  title: Unix ar archive (BSD/Darwin variant)
  application: ar
  file-extension:
    - a # Unix/generic
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
  The BSD variant of the Unix ar archive format (see the `ar_generic` spec for general info about the ar format). This variant is also used on Darwin-based systems (mainly Apple's macOS and iOS).
  
  BSD archives support member names that contain spaces or are longer than 16 bytes by storing the name as part of the member data rather than in the fixed-size name field.
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
types:
  regular_member_name:
    seq:
      - id: name
        terminator: 0x20
        pad-right: 0x20
        doc: The member name, right-padded with spaces.
    doc: |
      A regular (or "short") member name, stored directly in the name field.
      
      Note: Since regular names in BSD archives are terminated using spaces, file names that contain spaces cannot be stored as regular names. Such names must be stored as long names, even if they are not longer than 16 bytes.
  long_member_name:
    seq:
      - id: magic
        contents: '#1/'
        doc: Indicates a long member name.
      - id: name_size
        type: space_padded_number(13, 10)
        doc: The size of the long member name in bytes.
    doc: A long member name, stored at the start of the member's data.
  member_name:
    seq:
      - id: first_three_bytes
        size: long_name_magic.length
        doc: Internal helper field, do not use.
    instances:
      long_name_magic:
        value: '[0x23, 0x31, 0x2f]'
        doc: The ASCII bytes "#1/", indicating a long member name.
      is_long:
        value: first_three_bytes == long_name_magic
        doc: Whether this is a reference to a long name (stored at the start of the archive data) or a regular name.
      regular:
        pos: 0
        type: regular_member_name
        if: not is_long
      long:
        pos: 0
        type: long_member_name
        if: is_long
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
      - id: size_raw
        -orig-id: ar_size
        size: 10
        type: space_padded_number(10, 10)
        doc: The size of the member's data. The long member name (if any) counts toward the data size, but the trailing padding byte (if any) does not.
      - id: header_terminator
        -orig-id: ar_fmag
        contents: "`\n"
        doc: Marks the end of the header.
      - id: long_name
        size: name_internal.long.name_size.value
        terminator: 0x00
        pad-right: 0x00
        if: name_internal.is_long
        doc: The member's long name, if any, possibly right-padded with null bytes.
      - id: data
        size: size
        doc: The member's data.
      - id: padding
        contents: "\n"
        if: size_raw.value % 2 != 0
        doc: An extra newline is added as padding after members with an odd data size. This ensures that all members are 2-byte-aligned.
    instances:
      name:
        value: 'name_internal.is_long ? long_name : name_internal.regular.name'
        doc: |
          The name of the archive member. Because the encoding of member names varies across systems, the name is exposed as a byte array.
          
          Names are usually unique within an archive, but this is not required - the `ar` command even provides various options to work with archives containing multiple identically named members.
      size:
        value: 'name_internal.is_long ? size_raw.value - name_internal.long.name_size.value : size_raw.value'
        doc: The size of the member's data, excluding any long member name.
    doc: |
      An archive member's header and data.
      
      By default, modern ar implementations set the modification timestamp, user ID and group ID to 0 and the mode to 644 (octal), regardless of the file's original metadata, to make archive creation reproducible.
