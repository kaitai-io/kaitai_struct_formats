meta:
  id: parchive_v2
  title: Parity Volume Set v2
  application:
    - par2cmdline
    - LibPar2
    - MultiPar
    - Par-N-Rar
    - PAR Buddy
  file-extension: par2
  license: GNU-FDL-1.3-or-later
  xref:
    justsolve: Parity Volume Set
    wikidata: Q497118
  endian: le
  encoding: ASCII
doc-ref: http://parchive.sourceforge.net/docs/specifications/parity-volume-spec/article-spec.html
doc: |
  This document describes a file format for storing redundant data for a set of files.

  In operation, a user will select a set of files from which the redundant data is to be made. These are known as input files and the set of them is known as the recovery set. The user will provide these to a program which generates file(s) that match the specification in this document. The program is known as a PAR 2.0 Client or client for short, and the generated files are known as PAR 2.0 files or PAR files. If the files in the recovery set ever get damaged (e.g. when they are transmitted or stored on a faulty disk) the client can read the damaged input files, read the (possibly damaged) PAR files, and regenerate the original input files. Of course, not all damages can be repaired, but many can.

  A user can also name some input files that are not to be recovered if damaged. These input files are known as the non-recovery set. This feature is in the spec to keep the same functionality as PAR 1.0.

  The redundant data in the PAR files is computed using Reed-Solomon codes. These codes can take a set of equal-sized blocks of data and produce a number of same-sized recovery blocks. Then, given a subset of original data blocks and some recovery block, it is possible to reproduce the original data blocks. Reed-Solomon codes can do this recovery as long as the number of missing data blocks does not out number the recovery blocks. The design of the Reed-Solomon codes in this spec is based on James S. Plank's tech report at U. of Tennessee entitled A tutorial on Reed-Solomon coding for fault-tolerance in RAID-like systems. The tech report contains an error, so the design is changed slightly to fix the problem. PAR 2.0 uses a 16-bit Reed-Solomon code and can support 32768 blocks.

  The equal-sized blocks for the Reed-Solomon codes come from slices of the input files in the recovery set. The slices are consecutive equal-sized chunks of each file. If a file does not fill out the chunk, i.e. it ends mid-slice, the rest of the slice is treated as if it is padded with zero bytes.

  The PAR 2.0 file itself is made of packets - self-contained parts with their own checksum. This design prevents damage to one part of the file from making the whole file unusable.
  Packets have a type and each type of packet serves a different purpose. One describes a file. Another contains the checksums of the slices in a file. Another states which files are in the recovery set and which files are in the non-recovery set. And yet another contains a recovery slice - the recovery data produced by the Reed-Solomon code.

  A PAR 2.0 file is only *required* to contain 1 specific packet - the packet that identifies the type of client that created the file. This way, if clients are creating files that don't match the specification in some way, they can be tracked down.
  The packets for a recovery set and non-recovery set can be broken into multiple files. Files can contain duplicate packets - in fact, this is recommended for vital packets, such as the ones that describe the input files and the one that states which files are in the recovery set. Packets can appear in any order in a file.

  That is the official spec. To make sure clients work similarly, the following client conventions should be followed.
  PAR 2.0 files should always end in ".par2". For example, "file.par2". If a file contains recovery slices, the ".par2" should be preceded by ".volXX-YY" where XX to YY is the range of exponents for the recovery slices. For example, "file.vol20-29.par2". More than 2 digits should be used if necessary. Any exponents that contain fewer digits than the largest exponent should be preceded by zeros so that all filenames have the same length. For example, "file.vol075-149.par2". Exponents should start at 0 and go upwards.

  If multiple PAR files are generated, they may either have a constant number of slices per file (e.g. 20, 20, 20, ...) or exponentially increasing number of slices (e.g., 1, 2, 4, 8, ...). Note that to store 1023 slices takes 52 files if each has 20 slices, but takes only 10 files with the exponential pattern.

  When generating multiple PAR files, it is expected that one file be generated without any slices and containing all main, file description, and input file checksum packets. The other files should also include the main, file description and input file checksum packets. This repeats data that cannot be recovered.

  *NOTE: If the files are to be transmitted over usenet, it might be best to place the main, file description and input file checksum packets at the end, so that the equal-sized recovery slice packets are at the beginning. That way it may be possible to put a single recovery slice in each usenet message.*

  If just a single PAR file is generated, it is expected that the main, file description, and input file checksum packets are repeated multiple times and scattered through out the file. (Once again, repeating data that cannot be recovered.)

  It is recommended that users are warned when they create PAR files with names that are incompatible with Windows, Mac, or Linux systems. That is, file or directory names that are more than 255 characters long, start with a period (.) or a dash (-), or contain one of these characters: < > : " ' ` ? * & | [ ] \ ; or newline (\n).

  It is *strongly* recommended that clients query a user before writing to a file whose File Description packet contains an absolute pathname. For Windows, that means one starting with "C:\" or "//" for example. For UNIX, that means one starting with "/" or "//". For Mac, that means one starting with ":". This is to prevent PAR files of unknown origin from cracking a system by overwriting system files.
seq:
  - id: packets
    type: packet
    repeat: eos
types:
  md5:
    doc-ref: https://tools.ietf.org/html/rfc1321
    seq:
      - id: hash
        size: 16
  crc32:
    doc: The CRC32 is specified by CCITT and is the same as in Ethernet packets (and PKZIP, FDDI, etc.).
    doc-ref: http://www.ross.net/crc/download/crc_v3.txt
    seq:
      - id: hash
        size: 4
  pair:
    seq:
      - id: md5
        type: md5
        doc: to verify the slices have not been modified.
      - id: crc32
        type: crc32
        doc: to quickly locate the slices
  triplet:
    seq:
      - id: pair
        type: pair
      - id: exponent
        type: u4
  packet:
    seq:
      - id: preheader
        type: preheader
      - id: header
        type: header
      - id: body
        size: preheader.length - 32 - 32
        doc: Size *must* be a multiple of 4 bytes.
        type:
          switch-on: header.types.types[0].type
          cases:
            '"PAR 2.0"': official_types(header.types.types[1].type)
            #'"NewsPostUsenet"': example_news_post
    types:
      official_types:
        params:
          - id: subtype
            type: str
        seq:
          - id: body
            type:
              switch-on: subtype
              cases:
                '"Main"': main
                '"PkdMain"': packed_main
                '"RecvSlic"': recovery_slice
                '"PkdRecvS"': packed_recovery_slice
                '"FileDesc"': file_descriptor
                '"IFSC"': input_file_slice_checksum
                '"Creator"': creator
                '"UniFileN"': unicode_filename
                '"CommASCI"': ascii_comment
                '"CommUni"': unicode_comment
                '"FileSlic"': input_file_slice
                '"RFSC"': recovery_file_slice_checksum
        types:
          main:
            doc: The non-packed format requires, for each file, at least one slice and the number of slices is limited to 32,768.
            seq:
              - id: slice_size
                type: u8
                doc: "*must* be a multiple of 4 (and a multiple of the subslice size, if it is inside of packed_main)"
                valid:
                  expr: _ % 4 == 0
              - id: recovery_set_length
                type: u4
                doc: Number of files in the recovery set.
              - id: recovery_set
                type: md5
                doc: File IDs of all files in the recovery set. (See File Description packet.) These hashes are sorted by numerical value (treating them as 16-byte unsigned integers).
                repeat: expr
                repeat-expr: recovery_set_length
              - id: non_recovery_set
                type: md5
                doc: File IDs of all files in the non-recovery set. (See File Description packet.) These hashes are sorted by numerical value (treating them as 16-byte unsigned integers).
                repeat: eos

          packed_main:
            doc: |
              The packed main packet replaces the main packet when the client generates packed recover slice packets. The packed format allows recovery on units smaller than the slice size, which both increases the chance of recovery and allows more than 32,768 files.
            seq:
              - id: subslice_size
                type: u8
                doc: |
                  *must* be a multiple of 4. *must* equally divide the slice size. (See the description of packed recovery slice packets to see how this is used.)
              - id: main
                type: main
          recovery_slice:
            doc-ref: https://www.cs.utk.edu/~plank/plank/papers/SPE-9-97.html James S. Plank, A tutorial on Reed-Solomon coding for fault-tolerance in RAID-like systems
            doc: |
              The recovery slice packet contains one slice of recovery data. The recovery data is generated using a 16-bit Galois Field (GF) with generator 0x0001100B.

              The algorithm for computing recovery slices is based on James S. Plank's tech report at U. of Tennessee entitled A tutorial on Reed-Solomon coding for fault-tolerance in RAID-like systems. The input slices are ordered and assigned 16-bit constants. Recovery slices are assigned 16-bit exponents. Each 2-byte word of the recovery slice is the sum of the contributions from each input slice. The contribution of each input slice is the 2-byte word of the input slice multiplied by the input slice's constant raised to the recovery slice's exponent. All these computations (adds, multiplys, powers) are done using the 16-bit Galois Field operations.

              To generate the recovery data, the slices of the input files are assigned constants. This is based on the order the File IDs appear in the main packet and then by the order the slices appear in the file. So the first slice of the first file in the main packet is assigned the first constant. The second slice of the first file is assigned the second constant. And so on. If the last slice of the first file has the Nth constant, the first slice of the second file is assigned the (N+1)th. And so on.

              Here, the PAR 2.0 Spec diverges from Plank's paper. In Plank, the first constant is 1, the second 2, the third 3, etc. This is a bad approach because some constants have an order less than 65535. (That is, there exists constants N where N raised to a power less than 65535 is equal to 1 in the Galois Field.) These constants can prevent recovery matrices from being invertible and can, therefore, stop recovery. This spec does not use those constants. So, the first constant is the first power of two that has order 65535. The second constant is the next power of two that has order 65535. And so on. A power of two has order 65535 if the exponent is not equal to 0 modulus 3, 5, 17, or 257. In C code, that would be (n%3 != 0 && n%5 != 0 && n%17 != 0 && n%257 != 0).

              Note - this is the exponent being tested, and not the constant itself. There are 32768 valid constants. The first few are: 2, 4, 16, 128, 256, 2048, 8192, 16384, 4107, 32856, 17132
            seq:
              - id: exponent
                type: u4
              - id: recovery_data
                size-eos: true
          packed_recovery_slice:
            doc: |
              The packed recovery slice packet contains one slice of recovery data. The recovery data is generated in the same manner as the recovery slice packet; the only thing that differs is how the data from the input slices is laid out.

              Files are broken into subslices and the subslices are ordered, just as in the recovery slice packet - sorted first by the order of the File ID in the packed main packet and then by the order of the subslice within the file.

              These subslices are then grouped to together to make up the slices of input data used in the calculations. If X is the number of subslices in a slice, the first X subslices make up the first slice (which has the recovery constant 2). The next X subslices make up the second slice (which has the constant 4). Etc.

              In short, the input slices are made by packing the files together, with files starting on subslice boundaries rather than slice boundaries. Note that there are no subslice checksums, but there are file checksums, which can be used to detect bad regions that are smaller than a slice.
            seq:
              - id: exponent
                type: u4
              - id: recovery_data
                size-eos: true
          file_descriptor:
            doc: A file description packet is included for each input file - recoverable or non-recoverable.
            seq:
              - id: file_id
                type: md5
                doc: |
                  This uniquely identifies a file in the PAR file.

                  The File ID in this version is calculated as the MD5 Hash of the last 3 fields of the body of this packet: MD5-16k, length, and ASCII file name. Note: The length and MD5-16k are included because the Recovery Set ID is a hash of the File IDs and the Recovery Set ID should be a function of file contents as well as names.
              - id: checksum
                type: md5
                doc: hash of the entire file.
              - id: checksum_16k
                type: md5
                doc: |
                  The hash of the first 16kB of the file.

                  It is included to enable a client to identify a file if its name has been changed without the client reading the entire file. (Of course, that assumes the first 16kB hasn't been damaged or lost!)
              - id: length
                type: u8
                doc: Length of the file.
              - id: name
                type: str
                size-eos: true
                doc: |
                  File names can be of any length and not guaranteed to be null terminated!

                  File names are case sensitive.

                  If a client is doing recovery on an operating system that has case-insensitive filenames or limited-length filenames, it is up to the client to rename files and directories.

                  Subdirectories are indicated by an HTML-style '/' (a.k.a. the UNIX slash).

                  If the file's directory does not exist, the client *must* create it. The filename *must* be unique.
          input_file_slice_checksum:
            doc: |
              This packet type contains checksums for all the slices that are in an input file. If the file would end mid-slice, the remainder of the slice is filled with 0-value bytes.
            seq:
              - id: file_id
                type: md5
              - id: pairs
                type: pair
                repeat: eos
                doc: MD5 Hash and CRC32 pairs for the slices of the file. The Hash/CRC pairs are in the same order as their respective slices in the file. The Hash comes before the CRC in the array elements.
          creator:
            doc: This packet is used to identify the client that created the file. It is *required* to be in every PAR file. If a client is unable to process a recovery set, the contents of the creator packet *must* be shown to the user. The goal of this is that any client incompatibilities can be found and resolved quickly.
            seq:
              - id: application_info
                type: str
                doc: |
                  ASCII text identifying the client. This should also include a way to contact the client's creator - either through a URL or an email address.

                  NB: This is not a null terminated string!
                size-eos: true
          unicode_filename:
            doc: This packet provides an alternate name for a file. This packet overrides the default "ASCII" name in the file description packet.
            seq:
              - id: file_id
                type: md5
              - id: name
                type: str
                size-eos: true
                encoding: UTF-16
          ascii_comment:
            doc: The ASCII comment packet contains - would you believe it - a comment in ASCII text! This should be shown to the user. If multiple copies of the same comment are found, only one need be shown.
            seq:
              - id: comment
                type: str
                size-eos: true
          unicode_comment:
            doc: The Unicode comment packet contains a comment in Unicode text. This should be shown to the user. If multiple copies of the same comment are found, only one need be shown. If an analogous ASCII version of the same comment is included in the file, the ASCII comment should not be shown.
            seq:
              - id: ascii_comment_hash
                type: md5
                doc: If an ASCII comment packet exists in the file and is just a translation of the Unicode in this comment, this is the MD5 Hash of the ASCII comment packet. Otherwise, it is zeros.
              - id: comment
                type: str
                size-eos: true
                encoding: UTF-16
          input_file_slice:
            doc: |
              The input file slice packet is used if the user wants to include the input file inside the PAR file. This can be used to combine lots of small files into one file or to break a large file into smaller files (by distributing its slices into many PAR files). The length of the slice is determined by the slice size in the main packet, unless the slice would run off the end of the file. The packet contains an index for the slice and the slice. NOTE: The indices are not the same as the input slice constants used in making recovery slices.

              If files contain input slices, the ".par2" in the filename should be preceded by ".partXX-YY" where XX to YY is the indices of the slices. For example, "file.part00-09.par2" Indices are assigned to slices in the same order that constants were assigned in generating the recover packets.

              > ... based on the order the File IDs appear in the main packet and then by the order the slices appear in the file. So the first slice of the first file in the main packet is assigned the first constant. The second slice of the first file is assigned the second constant. And so on. If the last slice of the first file has the Nth constant, the first slice of the second file is assigned the (N+1)th. And so on.
            seq:
              - id: file_id
                type: md5
              - id: index
                type: u8
                doc: The index of the slice. (See description above.)
              - id: slice
                size-eos: true
                doc: |
                  The slice. If the file ends mid-slice, the field is zero padded with 0 to 3 bytes to make it end on a 4-byte alignment.

                  Contains bytes from (slice_size*index) to (slice_size*index + slice_size -1), unless the end of the file is reached.
          recovery_file_slice_checksum:
            doc: |
              So far, we've had input and recovery slices in the PAR file and input slices in an external file (i.e., the input file slice checksum packet). This packet covers the last combination - the recovery slices are in an external file (i.e., one where they don't have packet headers). This packet type may never be used, but it is included for completeness.

              There exists a file description packet for the file. The slices are generated the same as for the recovery slice packet.
            seq:
              - id: file_id
                type: md5
              - id: data
                type: triplet
                doc: MD5/CRC32/exponent triplets for the slices in the file in the same order as their respective slices in the file.
                repeat: eos
      preheader:
        seq:
          - id: signature
            contents: [PAR2, 0, PKT]
            doc: Magic sequence. Used to quickly identify location of packets.
          - id: length
            type: u8
            doc: |
              Length of the entire packet.
              *must* be multiple of 4.
              NB: Includes length of header.
          - id: checksum
            type: md5
            doc: |
              Used as a checksum for the packet. Calculation starts at first byte of Recovery Set ID and ends at last byte of body. Does not include the magic sequence, length field or this field. NB: The MD5 Hash, by its definition, includes the length as if it were appended to the packet.

              If the packet is damaged, the packet is ignored.
      header:
        seq:
          - id: recovery_set_id
            type: md5
            doc: |
              All packets that belong together have the same recovery set ID.
              Clients reading a file should just test that the Recovery Set ID is the same in all packets and not check that it was calculated to the right value; the method for calculating the Recovery Set ID could change in future versions.

              For now Recovery Set ID is the MD5 hash of the body of the main packet.
          - id: types
            type: type_markers
            size: 16
            doc: Can be anything. All beginning "PAR " (ASCII) are reserved for specification-defined packets. Application-specific packets are recommended to begin with the ASCII name of the client.
        types:
          type_markers:
            seq:
              - id: types
                type: type_marker
                repeat: eos
            types:
              type_marker:
                doc: |
                  Computes offset and size of the string terminated by \r\n
                  WARNING: some so(u)rcery follows
                seq:
                  - id: placeholder
                    type: placeholder
                    if: pos > -1 # to trigger getting and caching it
                  - size: 0
                    if: size > -1 # to trigger computing and caching it
                instances:
                  pos:
                    value: _io.pos # populated in the beginning
                  size:
                    value: _io.pos - pos
                  type:
                    pos: pos
                    size: size
                    type: strz
                types:
                  placeholder:
                    seq:
                      - id: placeholder
                        type: u1
                        repeat: until
                        repeat-until: _ == 0 or _io.eof
      #example_news_post:
      #  doc: |
      #    How to Add an Application-Specific Packet Type
      #    ==================================================
      #    Say the author of "NewsPost" wanted to add his own packet type - one that identified the names of the Usenet messages in which the files are posted. That author can create his own packet type. For example, here is the layout for one where the Usenet messages are identified by a newsgroup and a regular expression which all matches the names of the usenet articles.
      #    Including the name of the client in the packet type is the recommended way to ensure unique type names.
      #  seq:
      #    - id: file_id
      #      type: md5
      #    - id: name_length
      #      type: u4
      #      doc: The length of the string containing the name of the newsgroup. *must* be a multiple of 4.
      #    - id: newsgroup_name
      #      type: str
      #      size: name_length
      #      doc: The name of the newsgroup. For example, "alt.binaries.multimedia".
      #    - id: regex
      #      type: str
      #      size-eos: true
      #      doc: A regular expression matching the name of articles containing the file. For example, "Unaired Pilot - VCD,NTSC - (??/??)".
