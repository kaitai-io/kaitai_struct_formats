meta:
  id: squashfs_superblock
  title: SquashFS superblock
  file-extension:
    - squashfs
    - snap
  endian: le
  license: CC-0
  xref:
    wikidata: Q389314
doc: |
  SquashFS is a compressed filesystem in a file, that can be read-only
  accessed from low memory devices. It is popular for booting LiveCDs and
  packing self-contained binaries. SquashFS format is used by Ubuntu .snap
  packages. SquashFS is natively supported by Linux Kernel.
doc-ref: https://github.com/AgentD/squashfs-tools-ng/blob/master/doc/format.txt
seq:
  - id: superblock
    type: superblock
enums:
  compressor:
    1: gzip
    2: lzo
    3: lzma
    4: xz
    5: lz4
    6: zstd
types:
  flags:
    seq:
      # bit count starts from the largest, byte count form the smallest
      - id: nfs_export_table            # 0x0080
        type: b1
      - id: data_deduplicated           # 0x0040
        type: b1
      - id: fragments_always_generated  # 0x0020
        type: b1
      - id: fragments_not_used          # 0x0010
        type: b1
      - id: fragments_uncompresed       # 0x0008
        type: b1
      - type: b1                        # 0x0004 bit is unused
      - id: data_blocks_uncompresed     # 0x0002
        type: b1
      - id: inodes_uncompresed          # 0x0001
        type: b1
      # bits 0x0100 are below, starting from the largest
      - type: b4                        # bits 11110000 are unused
      - id: id_table_uncompresed        # 0x0800
        type: b1
      - id: compressor_options_present  # 0x0400
        type: b1
      - id: xattrs_absent               # 0x0200
        type: b1
      - id: xattrs_uncompressed         # 0x0100
        type: b1
  superblock:
    seq:
      - id: magic
        contents: 'hsqs'
      - id: inode_count
        type: u4
      - id: mod_time
        type: u4
        doc: Unix times of last modification.
      - id: block_size
        type: u4
        doc: |
          The size of a data block in bytes. Must be a power of two between
          4096 (4k) and 1048576 (1 MiB).
      - id: frag_count
        type: u4
        doc: The number of entries in the fragment table.
      - id: compressor
        type: u2
        enum: compressor
        doc: Compressor used for both data and meta data blocks.
      - id: block_log
        type: u2
        doc: |
          The log2 of the block size. If the two fields do not agree, the
          archive is considered corrupted.
      - id: flags
        type: flags
      - id: id_count
        type: u2
        doc: The number of entries in the ID lookup table.
      - id: version_major
        contents: [ 4, 0 ]
      - id: version_minor
        contents: [ 0, 0 ]
      - id: root_inode_ref
        type: u8
        doc: A reference to the inode of the root directory.
      - id: bytes_used
        type: u8
        doc: |
          The number of bytes used by the archive. Because SquashFS
          archives must be padded to a multiple of the underlying device
          block size, this can be less than the actual file size.
      - id: id_table_start
        type: u8
      - id: xattr_id_table_start
        type: u8
      - id: inode_table_start
        type: u8
      - id: directory_table_start
        type: u8
      - id: fragment_table_start
        type: u8
      - id: export_table_start
        type: u8
