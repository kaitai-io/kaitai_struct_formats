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
  # The ar format is somewhat unusual: although it can store arbitrary data files, the ar format itself is text-based - all fields and magic numbers are pure ASCII.
  # In particular, numerical values are stored as ASCII-encoded decimal and octal numbers, rather than packed byte values.  Because of this, the ar format has no endianness.
  # Note: the encoding specified here is not used to interpret member names. As different systems use different encodings, they are exposed as byte arrays.
  encoding: ASCII
doc: |
  The Unix ar archive format, as created by the `ar` utility. It is a simple uncompressed flat archive format, but is rarely used for general-purpose archiving. Instead, it is commonly used by linkers to collect multiple object files along with a symbol table into a static library. The Debian package format (.deb) is also based on the ar format.
  
  The ar format is not standardized and several variants have been developed, which differ mainly in how member names and the symbol table (if any) are stored. This specification describes the BSD variant, which is also used on Darwin-based systems (mainly Apple's macOS and iOS).
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
  member_name:
    seq:
      - id: first_three_bytes
        size: long_name_magic.length
        doc: Internal helper field, do not use.
    instances:
      long_name_magic:
        value: '[0x23, 0x31, 0x2f]'
        doc: The ASCII bytes "#1/", indicating a long member name.
      is_long_name:
        value: first_three_bytes == long_name_magic
        doc: Whether this is a reference to a long name (stored at the start of the archive data) or a regular name.
      regular_name:
        pos: 0
        size-eos: true
        terminator: 0x20
        pad-right: 0x20
        doc: The regular member name, right-padded with spaces.
        if: not is_long_name
      long_name_size_dec:
        pos: long_name_magic.length
        size-eos: true
        type: str
        terminator: 0x20
        pad-right: 0x20
        doc: The size of the long member name in bytes, in ASCII decimal, right-padded with spaces.
        if: is_long_name
      long_name_size:
        value: long_name_size_dec.to_i
        doc: The size of the long member name in bytes, parsed as an integer.
        if: is_long_name
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
      - id: size_raw_dec
        -orig-id: ar_size
        size: 10
        type: str
        terminator: 0x20
        pad-right: 0x20
        doc: The size of the member's data, in ASCII decimal, right-padded with spaces. The long member name (if any) counts toward the data size, but the trailing padding byte (if any) does not.
      - id: header_terminator
        -orig-id: ar_fmag
        contents: "`\n"
        doc: Marks the end of the header.
      - id: long_name
        size: name_internal.long_name_size
        terminator: 0x00
        pad-right: 0x00
        if: name_internal.is_long_name
        doc: The member's long name, if any, possibly right-padded with null bytes.
      - id: data
        size: size
        doc: The member's data.
      - id: padding
        contents: "\n"
        if: size % 2 != 0
        doc: An extra newline is added as padding after members with an odd data size. This ensures that all members are 2-byte-aligned.
    instances:
      size_raw:
        value: size_raw_dec.to_i
        doc: The size of the member's data, including any long member name, parsed as an integer.
      name:
        value: 'name_internal.is_long_name ? long_name : name_internal.regular_name'
        doc: |
          The name of the archive member. Because the encoding of member names varies across systems, the name is exposed as a byte array.
          
          Names are usually unique within an archive, but this is not required - the `ar` command even provides various options to work with archives containing multiple identically named members.
      size:
        value: 'name_internal.is_long_name ? size_raw - name_internal.long_name_size : size_raw'
        doc: The size of the member's data, excluding any long member name.
    doc: |
      An archive member's header and data.
      
      By default, modern ar implementations set the modification timestamp, user ID and group ID to 0 and the mode to 644 (octal), regardless of the file's original metadata, to make archive creation reproducible.
      
      Rarely, the modification timestamp, user ID, group ID and mode fields may be blank (only spaces). This is the case in particular for the '//' member (the long name list) of SysV archives.
