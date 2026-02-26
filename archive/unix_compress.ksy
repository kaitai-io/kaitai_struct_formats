meta:
  id: unix_compress
  title: Unix compress-compressed data
  application:
    - compress(1)
    - uncompress(1)
    - zcat(1)
  file-extension:
    # The extension is specifically uppercase.
    # Lowercase .z is used for pack-compressed data.
    # However, as a result of case-insensitive file systems,
    # compress-compressed files may also have a lowercase .z extension.
    - Z
    # For compress-compressed tar files (equivalent to .tar.Z).
    # Intended for compatibility with systems with a three-character
    # limit on file extensions, such as DOS.
    # As above, because of case-insensitive file systems, this
    # extension may appear as .taz or .TAZ instead.
    - taZ
    # Note: Rarely, files with one of the above extensions might
    # actually contain gzip-compressed data, even though the usual
    # extensions for gzip files are .gz and .tgz.
  xref:
    justsolve: Compress
    wikidata: Q291486
  license: CC0-1.0
  endian: be
doc: |
  The Unix compress compression format, an early compression format based on
  the LZW compression algorithm. The Unix `compress` utility could compress
  files into this format, and they could be decompressed using the utilities
  `uncompress` and `zcat`.
  
  Shortly after `compress` was released, the LZW algorithm that it used
  was patented. This made it unclear if `compress` could be used freely.
  These patents have expired worldwide in 2004, meaning that the LZW algorithm
  and the compress format can be used and implemented freely again.
  
  The compress format is obsolete - in practical use it has been superseded
  by other compression formats such as gzip and bzip2, which are more efficient
  and not affected by any patents. Despite this, many modern Unix derivatives
  still offer a `compress` implementation as part of the base system
  or installable via package manager. The `gzip(1)` utility also supports
  decompressing (but not compressing) data in the compress format.
  
  Note: Although POSIX specifies the command-line interface for the commands
  `compress`, `uncompress` and `zcat`, the file format used by these commands
  is not specified by the standard. However, the file format of the original
  `compress` has become a de facto standard and is supported and used by all
  modern `compress` implementations.
doc-ref:
  - 'https://github.com/vapier/ncompress'
  - 'https://salsa.debian.org/debian/ncompress'
  - 'https://svnweb.freebsd.org/base/head/usr.bin/compress/'
  - 'https://github.com/andrew-aladev/lzws'
seq:
  - id: magic
    contents: [0x1f, 0x9d]
  - id: block_mode
    -orig-id: BLOCK_MASK
    type: b1
    doc: |
      Indicates whether the data was compressed in block mode.
      
      Block compression is available since compress 2.3, and enabled by default
      since compress 2.5 (it can be disabled using the `-C` option).
      
      When using block compression, code 256 in the compressed data
      causes the compression dictionary to be reset to its initial state,
      and code 257 is the first free code in the initial dictionary.
      Otherwise, code 256 is the first free code and has no special meaning.
  - id: reserved
    type: b2
    doc: |
      Unused. According to a comment from the source code of `compress`:
      
      > Masks 0x40 and 0x20 are free.  I think 0x20 should mean that there is
      > a fourth header byte (for expansion).
      
      However, this suggested use has never been implemented.
  - id: max_bits
    -orig-id: BIT_MASK
    type: b5
    doc: |
      The maximum code length (in bits) that was selected when this data
      was compressed. This is not necessarily the highest code length
      actually *used* in the compressed data (for small files, this field is
      often higher than actually necessary).
      
      In practice, this value is almost always 16, which is the maximum
      supported by all known compress implementations. The original compress
      could also be compiled with a lower maximum bit width (down to 12 bits),
      so that it could run on machines with small address spaces
      or little physical memory.
      
      When compressing, the `-b` option can be used to select a lower
      maximum code length than what `compress` was compiled with (down to
      a minimum of 9 bits). This allowed compressing files so that they
      could be decompressed on another machine with a lower maximum bit width.
  - id: data
    size-eos: true
    doc: |
      The compressed data. This is a sequence of variable-length bit codes,
      stored in little-endian byte order and from least-significant to
      most-significant bit within each byte.
      
      Initially, codes are 9 bits long. Once all possible codes for the current
      bit count are used in the compression dictionary, the length of all
      subsequent codes increases by one bit. If block compression is used, the
      reset code (256) causes the code length to be reset to the initial
      9 bits.
      
      In general, codes are packed and not byte-aligned. However, after a code
      length increase or dictionary reset, padding codes (with the old
      bit length) are added until a multiple of 8 codes is reached.
      This ensures that the first code of the new length always starts on a
      byte boundary.
