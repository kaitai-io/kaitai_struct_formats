meta:
  id: ar_generic
  title: Unix ar archive (generic superset)
  application: ar
  file-extension:
    - a # Unix/generic
    - lib # Windows
    - rlib # Rust
    - deb # Debian binary package
    - udeb # Debian binary package
  xref:
    justsolve: AR
    mime: application/x-archive
    wikidata: Q300839
  license: CC0-1.0
  imports:
    - member_metadata
    - space_padded_number
  # The ar format is somewhat unusual: although it can store arbitrary data files, the ar format itself is text-based - all fields and magic numbers are pure ASCII.
  # In particular, numerical values are stored as ASCII-encoded decimal and octal numbers, rather than packed byte values.  Because of this, the ar format has no endianness.
  # No string encoding is specified either. As different systems use different encodings, all text (i. e. file names) are exposed as byte arrays.
doc: |
  The Unix ar archive format, as created by the `ar` utility. It is a simple uncompressed flat archive format, but is rarely used for general-purpose archiving. Instead, it is commonly used by linkers to collect multiple object files along with a symbol table into a static library. The Debian package format (.deb) is also based on the ar format.
  
  The ar format is not standardized and several variants have been developed, which differ mainly in how member names and the symbol table (if any) are stored. This specification describes the basic structure shared by all ar variants.
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
  member:
    seq:
      - id: name
        -orig-id: ar_name
        size: 16
        # We don't set a terminator for the name field, because different ar format variants use different terminators (see doc).
        doc: |
          The name of the archive member, right-padded with spaces. Because the exact format of this field differs between format variants, it is exposed as a fixed-size byte array. Long member names are not processed, and no terminator or padding characters are removed. To read member names correctly from an archive whose format variant is known, use the `ar_bsd` or `ar_sysv` specification.
          
          Names are usually unique within an archive, but this is not required - the `ar` command even provides various options to work with archives containing multiple identically named members.
      - id: metadata
        type: member_metadata
        doc: The member's metadata (timestamp, user and group ID, mode).
      - id: size
        -orig-id: ar_size
        type: space_padded_number(10, 10)
        doc: The size of the member's data, in ASCII decimal, right-padded with spaces. The trailing padding byte (if any) does not count toward the data size.
      - id: header_terminator
        -orig-id: ar_fmag
        contents: "`\n"
        doc: Marks the end of the header.
      - id: data
        size: size.value
        doc: The member's data.
      - id: padding
        contents: "\n"
        if: size.value % 2 != 0
        doc: An extra newline is added as padding after members with an odd data size. This ensures that all members are 2-byte-aligned.
    doc: |
      An archive member's header and data.
      
      By default, modern ar implementations set the modification timestamp, user ID and group ID to 0 and the mode to 644 (octal), regardless of the file's original metadata, to make archive creation reproducible.
      
      Rarely, the modification timestamp, user ID, group ID and mode fields may be blank (only spaces). This is the case in particular for the '//' member (the long name list) of SysV archives.
