meta:
  id: zisofs
  title: zisofs
  xref:
    justsolve: Zisofs
    wikidata: Q105854284
  tags:
    - archive
    - filesystem
  license: CC0-1.0
  endian: le
doc: |
  zisofs is a compression format for files on ISO9660 file system. It has
  limited support across operating systems, mainly Linux kernel. Typically a
  directory tree is first preprocessed by mkzftree (from the zisofs-tools
  package before being turned into an ISO9660 image by mkisofs, genisoimage
  or similar tool. The data is zlib compressed.

  The specification here describes the structure of a file that has been
  preprocessed by mkzftree, not of a full ISO9660 ziso. Data is not
  decompressed, as blocks with length 0 have a special meaning. Decompression
  and deconstruction of this data should be done outside of Kaitai Struct.
doc-ref: https://web.archive.org/web/20200612093441/https://dev.lovelyhq.com/libburnia/web/-/wikis/zisofs
seq:
  - id: header
    size: 16
    type: header
  - id: block_pointers
    type: u4
    repeat: expr
    repeat-expr: header.num_blocks + 1
    doc: |
      The final pointer (`block_pointers[header.num_blocks]`) indicates the end
      of the last block. Typically this is also the end of the file data.
instances:
  blocks:
    type: 'block(block_pointers[_index], block_pointers[_index + 1])'
    repeat: expr
    repeat-expr: header.num_blocks
types:
  header:
    seq:
      - id: magic
        contents: [0x37, 0xe4, 0x53, 0x96, 0xc9, 0xdb, 0xd6, 0x07]
      - id: uncompressed_size
        type: u4
        doc: Size of the original uncompressed file
      - id: len_header
        type: u1
        valid: 4
        doc: header_size >> 2 (currently 4)
      - id: block_size_log2
        type: u1
        valid:
          any-of: [15, 16, 17]
      - id: reserved
        contents: [0, 0]
    instances:
      block_size:
        value: 1 << block_size_log2
      num_blocks:
        value: '(uncompressed_size / block_size) + (uncompressed_size % block_size != 0 ? 1 : 0)'
        doc: ceil(uncompressed_size / block_size)
  block:
    -webide-representation: '[{ofs_start}, {ofs_end}): {len_data:dec} bytes'
    params:
      - id: ofs_start
        type: u4
      - id: ofs_end
        type: u4
    instances:
      len_data:
        value: ofs_end - ofs_start
      data:
        io: _root._io
        pos: ofs_start
        size: len_data
