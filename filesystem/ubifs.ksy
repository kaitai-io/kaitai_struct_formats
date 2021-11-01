meta:
  id: ubifs
  title: UBIFS
  license: GPL-2.0-only
  endian: le
  encoding: UTF-8
doc: |
  The UBIFS file system is a file system for flash file systems. It works on
  top of UBI (Unsorted Block Images), which works as an abstraction layer so
  UBIFS does not need to care about low level details. This specification only
  covers UBIFS, not UBI.

  A UBIFS image is divided in several Logical Erase Blocks (LEB). The first
  LEB (LEB0) contains the superblock node, which includes information about LEB
  size, amongst others. The next two LEBs (LEB1 and LEB2) comprise the so called
  "master area" and both contain a copy of the master node, which includes
  information about where to find the index node, which is then used to access
  all the files on the file system.
doc-ref:
  - https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/ubifs/ubifs-media.h
  - https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/ubifs/key.h
  - http://www.linux-mtd.infradead.org/doc/ubifs.pdf
seq:
  - id: lebs
    size: super.node_header.leb_size
    repeat: expr
    repeat-expr: super.node_header.num_leb

# some instances to access important data structures directly
instances:
  super:
    pos: 0
    type: superblock_node
    doc: |
      The superblock node will always be at the start of
      the first LEB.
  master_1:
    pos: super.node_header.leb_size
    type: masterblock_node
    size: super.node_header.leb_size
    doc: |
      LEB1 contains a copy of the master node. Technically the master node
      could reside anywhere in the master area (LEB1 and LEB2), but on a
      cleanly generated system it will almost certainly be at the beginning
      of LEB1.
  master_2:
    pos: super.node_header.leb_size * 2
    size: super.node_header.leb_size
    type: masterblock_node
    doc: |
      LEB2 contains a copy of the master node. Technically the master node
      could reside anywhere in the master area (LEB1 and LEB2), but on a
      cleanly generated system it will almost certainly be at the beginning
      of LEB2.
  index:
    pos: super.node_header.leb_size * master_1.node_header.leb_root
    size: super.node_header.leb_size
    type: dummy
    doc: The LEB containing the index is declared in the master node.
  index_root:
    pos: master_1.node_header.ofs_root
    io: index._io
    type: index_block
    doc: The offset into the index LEB for the root index

types:
  dummy: {}
  masterblock_node:
    seq:
      - id: header
        type: common_header
      - id: node_header
        size: header.len_full_node - header._sizeof
        type: master_header
  index_block:
    seq:
      - id: header
        type: common_header
      - id: node_header
        size: header.len_full_node - header._sizeof
        type: index_header
  superblock_node:
    seq:
      - id: header
        type: common_header
      - id: node_header
        size: header.len_full_node - header._sizeof
        type: superblock_header

  block:
    seq:
      - id: header
        type: common_header
      - id: node_header
        size: header.len_full_node - header._sizeof
        type:
          switch-on: header.node_type
          cases:
            node_types::inode: inode_header
            node_types::data: data_header
            node_types::directory: directory_header
            # Extended attribute entry nodes are identical to directory entry nodes
            node_types::extended_attribute: directory_header
            node_types::truncation: truncation_header
            node_types::padding: padding_header
            node_types::superblock: superblock_header
            node_types::master: master_header
            node_types::reference: reference_header
            node_types::index: index_header
            node_types::commit_start: commit_start_header
            #node_types::orphan:
            #node_types::authentication
            #node_types::signature

  # Common types
  common_header:
    seq:
      - id: magic
        type: u4
        valid: 0x06101831
        doc: UBIFS node magic number (%UBIFS_NODE_MAGIC)
      - id: crc
        type: u4
        doc: CRC-32 checksum of the node header
      - id: sequence_number
        -orig-id: sqnum
        type: u8
        doc: sequence number
      - id: len_full_node
        -orig-id: len
        type: u4
        doc: full node length
      - id: node_type
        type: u1
        doc: node type
        enum: node_types
      - id: group_type
        type: u1
        doc: node group type
      - id: padding
        size: 2
        contents: [0x00, 0x00]
        doc: reserved for future, zeroes
  padding_byte:
    seq:
      - id: padding
        contents: [0x00]

  # Node types
  commit_start_header:
    seq:
      - id: commit_number
        -orig-id: cmt_no
        type: u8
        doc: commit number
  data_header:
    seq:
      - id: key
        type: longkey
        doc: node key
      - id: len_uncompressed
        -orig-id: size
        type: u4
        doc: uncompressed data size in bytes
      - id: compression
        type: u2
        enum: compression
        doc: compression type (%UBIFS_COMPR_NONE, %UBIFS_COMPR_LZO, etc)
      - id: len_compressed_data
        -orig-id: compr_size
        type: u2
        doc: compressed data size in bytes, only valid when data is encrypted
      - id: data
        size-eos: true
  directory_header:
    seq:
      - id: key
        type: longkey
        doc: node key
      - id: inode_number
        -orig-id: inum
        type: u8
        doc: target inode number
      - id: padding1
        contents: [0x00]
        doc: reserved for future, zeroes
      - id: inode_type
        -orig-id: type
        type: u1
        enum: inode_types
        doc: type of the target inode (%UBIFS_ITYPE_REG, %UBIFS_ITYPE_DIR, etc)
      - id: len_name
        -orig-id: nlen
        type: u2
        doc: name length
      - id: cookie
        type: u4
        doc: A 32bits random number, used to construct a 64bits identifier.
      - id: name
        size: len_name
        type: strz
        doc: zero-terminated name
  index_header:
    seq:
      - id: num_children
        -orig-id: child_cnt
        type: u2
        doc: number of child index nodes
      - id: level
        type: u2
        doc: tree level
      - id: branches
        type: branch
        repeat: expr
        repeat-expr: num_children
        doc: LEB number / offset / length / key branches
  inode_header:
    seq:
      - id: key
        type: longkey
        doc: node key
      - id: sequence_number
        -orig-id: creat_sqnum
        type: u8
        doc: sequence number at time of creation
      - id: len_uncompressed
        -orig-id: size
        type: u8
        doc: inode size in bytes (amount of uncompressed data)
      - id: atime_sec
        type: u8
        doc: access time seconds
      - id: ctime_sec
        type: u8
        doc: creation time seconds
      - id: mtime_sec
        type: u8
        doc: modification time seconds
      - id: atime_nsec
        type: u4
        doc: access time nanoseconds
      - id: ctime_nsec
        type: u4
        doc: creation time nanoseconds
      - id: mtime_nsec
        type: u4
        doc: modification time nanoseconds
      - id: num_links
        -orig-id: nlink
        type: u4
        doc: number of hard links
      - id: uid
        type: u4
        doc: owner ID
      - id: gid
        type: u4
        doc: group ID
      - id: mode
        type: u4
        doc: access flags
      - id: flags
        type: u4
        doc: per-inode flags (%UBIFS_COMPR_FL, %UBIFS_SYNC_FL, etc)
      - id: len_data
        -orig-id: data_len
        type: u4
        doc: inode data length
      - id: xattr_cnt
        type: u4
        doc: count of extended attributes this inode has
      - id: xattr_size
        type: u4
        doc: summarized size of all extended attributes in bytes
      - id: padding1
        size: 4
        contents: [0x00, 0x00, 0x00, 0x00]
      - id: xattr_names
        type: u4
        doc: |
          sum of lengths of all extended attribute names belonging
          to this inode
      - id: compression
        -orig-type: compr_type
        type: u2
        enum: compression
        doc: compression type used for this inode
      - id: padding2
        type: padding_byte
        repeat: expr
        repeat-expr: 26
        doc: reserved for future, zeroes
      - id: data
        size: len_data
    instances:
      compressed:
        value: flags & 0x01 == 0x01
        doc: use compression for this inode
      synchronous:
        value: flags & 0x02 == 0x02
        doc: I/O on this inode has to be synchronous
      immutable:
        value: flags & 0x04 == 0x04
        doc: inode is immutable
      append:
        value: flags & 0x08 == 0x08
        doc: writes to the inode may only append data
      dirsync:
        value: flags & 0x10 == 0x10
        doc: I/O on this directory inode has to be synchronous
      xattr:
        value: flags & 0x20 == 0x20
        doc: this inode is the inode for an extended attribute value
      encrypted:
        value: flags & 0x40 == 0x40
        doc: use encryption for this inode
      is_socket:
        value: mode & 0o0170000 == 0o140000
      is_link:
        value: mode & 0o0170000 == 0o120000
      is_regular:
        value: mode & 0o0170000 == 0o100000
      is_block_device:
        value: mode & 0o0170000 == 0o60000
      is_dir:
        value: mode & 0o0170000 == 0o40000
      is_character_device:
        value: mode & 0o0170000 == 0o20000
      is_fifo:
        value: mode & 0o0170000 == 0o10000
  master_header:
    seq:
      - id: highest_inum
        type: u8
        doc: highest inode number in the committed index
      - id: commit_number
        -orig-id: cmt_no
        type: u8
        doc: commit number
      - id: flags
        type: u4
        doc: various flags (%UBIFS_MST_DIRTY, etc)
      - id: leb_log
        -orig-id: log_lnum
        type: u4
        doc: start of the log
      - id: leb_root
        -orig-id: root_lnum
        type: u4
        doc: LEB number of the root indexing node
      - id: ofs_root
        -orig-id: root_offs
        type: u4
        doc: offset within @root_lnum
      - id: root_indexing_length
        -orig-id: root_len
        type: u4
        doc: root indexing node length
      - id: leb_garbage_collect
        -orig-id: gc_lnum
        type: u4
        doc: |
          LEB reserved for garbage collection (%-1 value means the
          LEB was not reserved and should be reserved on mount)
      - id: leb_index_head
        -orig-id: ihead_lnum
        type: u4
        doc: LEB number of index head
      - id: ofs_ihead
        -orig-id: ihead_offs
        type: u4
        doc: offset of index head
      - id: len_index
        -orig-id: index_size
        type: u8
        doc: size of index on flash
      - id: total_free
        type: u8
        doc: total free space in bytes
      - id: total_dirty
        type: u8
        doc: total dirty space in bytes
      - id: total_used
        type: u8
        doc: total used space in bytes (includes only data LEBs)
      - id: total_dead
        type: u8
        doc: total dead space in bytes (includes only data LEBs)
      - id: total_dark
        type: u8
        doc: total dark space in bytes (includes only data LEBs)
      - id: leb_lpt
        -orig-id: lpt_lnum
        type: u4
        doc: LEB number of LPT root nnode
      - id: ofs_lpt
        -orig-id: lpt_offs
        type: u4
        doc: offset of LPT root nnode
      - id: leb_nhead
        -orig-id: nhead_lnum
        type: u4
        doc: LEB number of LPT head
      - id: ofs_nhead
        -orig-id: nhead_offs
        type: u4
        doc: offset of LPT head
      - id: leb_lprops_table
        -orig-id: ltab_lnum
        type: u4
        doc: LEB number of LPT's own lprops table
      - id: ofs_ltab
        -orig-id: ltab_offs
        type: u4
        doc: offset of LPT's own lprops table
      - id: leb_save_table
        -orig-id: lsave_lnum
        type: u4
        doc: LEB number of LPT's save table (big model only)
      - id: ofs_lsave
        -orig-id: lsave_offs
        type: u4
        doc: offset of LPT's save table (big model only)
      - id: leb_last_lpt_scan
        -orig-id: lscan_lnum
        type: u4
        doc: LEB number of last LPT scan
      - id: empty_lebs
        type: u4
        doc: number of empty logical eraseblocks
      - id: idx_lebs
        type: u4
        doc: number of indexing logical eraseblocks
      - id: leb_cnt
        type: u4
        doc: count of LEBs used by file-system
      - id: hash_root_index
        size: 64
        doc: the hash of the root index node
      - id: hash_lpt
        size: 64
        doc: the hash of the LPT
      - id: hmac
        size: 64
        doc: HMAC to authenticate the master node
      - id: padding
        type: padding_byte
        repeat: expr
        repeat-expr: 152
        doc: reserved for future, zeroes
    instances:
      dirty:
        value: flags & 1 == 1
        doc: master node is dirty
      no_orphans:
        value: flags & 2 == 2
        doc: no orphan inodes present
      recovery:
        value: flags & 4 == 4
        doc: written by recovery
  orphan_header:
    seq:
      - id: commit_number
        type: u8
        doc: commit number (also top bit is set on the last node of the commit)
      - id: inode_numbers
        type: u8
        repeat: eos
        doc: inode numbers of orphans
  padding_header:
    seq:
      - id: len_padding
        type: u4
        doc: how many bytes after this node are unused (because padded)
  reference_header:
    seq:
      - id: leb_number
        -orig-id: lnum
        type: u4
        doc: the referred logical eraseblock number
      - id: ofs_leb
        -orig-id: offs
        type: u4
        doc: start offset in the referred LEB
      - id: journal_head_number
        -orig-id: jhead
        type: u4
        doc: joural head number
      - id: padding
        type: padding_byte
        repeat: expr
        repeat-expr: 28
        doc: reserved for future, zeroes
    doc: logical eraseblock reference node.
  signature_header:
    seq:
      - id: type
        type: u4
      - id: len_signature
        type: u4
      - id: padding
        type: padding_byte
        repeat: expr
        repeat-expr: 32
      - id: signature
        size: len_signature
  superblock_header:
    seq:
      - id: padding1
        size: 2
        contents: [0x00, 0x00]
        doc: reserved for future, zeroes
      - id: key_hash
        type: u1
        doc: type of hash function used in keys
      - id: key_fmt
        type: u1
        enum: key_formats
        valid:
          any-of:
            - key_formats::simple
        doc: format of the key
      - id: flags
        type: u4
        doc: file-system flags (%UBIFS_FLG_BIGLPT, etc)
      - id: min_io_size
        type: u4
        doc: minimal input/output unit size
      - id: leb_size
        type: u4
        doc: logical eraseblock size in bytes
      - id: num_leb
        -orig-id: leb_cnt
        type: u4
        doc: count of LEBs used by file-system
      - id: max_leb_cnt
        type: u4
        doc: maximum count of LEBs used by file-system
      - id: max_bud_bytes
        type: u8
        doc: maximum amount of data stored in buds
      - id: log_lebs
        type: u4
        doc: log size in logical eraseblocks
      - id: lpt_lebs
        type: u4
        doc: number of LEBs used for lprops table
      - id: orph_lebs
        type: u4
        doc: number of LEBs used for recording orphans
      - id: jhead_cnt
        type: u4
        doc: count of journal heads
      - id: fanout
        type: u4
        doc: tree fanout (max. number of links per indexing node)
      - id: lsave_cnt
        type: u4
        doc: number of LEB numbers in LPT's save table
      - id: fmt_version
        type: u4
        valid:
          min: 4
        doc: UBIFS on-flash format version
      - id: default_compression
        -orig-id: default_compr
        type: u2
        enum: compression
      - id: padding2
        size: 2
        contents: [0x00, 0x00]
        doc: reserved for future, zeroes
      - id: reserve_pool_uid
        -orig: rp_uid
        type: u4
        doc: reserve pool UID
      - id: reserve_pool_gid
        -orig: rp_gid
        type: u4
        doc: reserve pool GID
      - id: reserve_pool_size
        type: u8
        doc: size of the reserved pool in bytes
      - id: time_granularity
        type: u4
        doc: time granularity in nanoseconds
      - id: uuid
        size: 16
        doc: UUID generated when the file system image was created
      - id: ro_compat_version
        type: u4
        doc: UBIFS R/O compatibility version
      - id: hmac
        size: 64
        doc: HMAC to authenticate the superblock node
      - id: hmac_wkm
        size: 64
        doc: |
          HMAC of a well known message (the string "UBIFS") as a convenience
          to the user to check if the correct key is passed
      - id: hash_algo
        type: u2
        doc: The hash algo used for this filesystem (one of enum hash_algo)
      - id: hash_mst
        size: 64
        doc: |
          hash of the master node, only valid for signed images in which the
          master node does not contain a hmac
      - id: padding3
        type: padding_byte
        repeat: expr
        repeat-expr: 3774
        doc: reserved for future, zeroes
    instances:
      biglpt:
        value: flags & 0x02 == 0x02
        doc: if "big" LPT model is used if set
      space_fixup:
        value: flags & 0x04 == 0x04
        doc: first-mount "fixup" of free space within LEBs needed
      double_hash:
        value: flags & 0x08 == 0x08
        doc: |
          store a 32bit cookie in directory entry nodes to
          support 64bit cookies for lookups by hash
      encrypted:
        value: flags & 0x10 == 0x10
        doc: filesystem contains encrypted files
      authenticated:
        value: flags & 0x20 == 0x20
        doc: this filesystem contains hashes for authentication
  truncation_header:
    seq:
      - id: inode_number
        -orig-id: inum
        type: u4
        doc: truncated inode number
      - id: padding
        type: padding_byte
        repeat: expr
        repeat-expr: 12
        doc: reserved for future, zeroes
      - id: old_size
        type: u8
        doc: size before truncation
      - id: new_size
        type: u8
        doc: size after truncation
    doc: This node exists only in the journal and never goes to the main area.

  branch:
    seq:
      - id: target_leb
        -orig-id: lnum
        type: u4
        doc: LEB number of the target node
      - id: ofs_target
        -orig-id: offs
        type: u4
        doc: offset within @lnum
      - id: len_target
        -orig-id: len
        type: u4
        doc: target node length
      - id: key
        # assume "simple key length" as "simple key" is
        # the only key supported right now
        type: key
        doc: |
          In an authenticated UBIFS we have the hash of the referenced node after @key.
          This can't be added to the struct type definition because @key is a
          dynamically sized element already.
    instances:
      branch_target:
        pos: target_leb * _root.super.node_header.leb_size + ofs_target
        size: len_target
        io: _root._io
        type: block

  # Key types
  key:
    seq:
      - id: inode_number
        type: u4
      - id: key_value
        type: u4
    instances:
      type:
        value: key_value >> 29
        enum: key_types
      value:
        value: key_value & 0x1fffffff
    doc: |
      Keys are 64-bits long. The first 32-bits are the inode number, or the
      parent inode number in case of a directory entry. The next 3 bits are
      the node type. The last 29 bits are the block number (data entries)
      or the directory entry hash in case of a directory entry.
  longkey:
    seq:
      - id: inode_number
        type: u4
      - id: key_value
        type: u4
      - id: unused
        size: 8
    doc: |
      Keys are 64-bits long. The first 32-bits are the inode number, or the
      parent inode number in case of a directory entry. The next 3 bits are
      the node type. The last 29 bits are the block number (data entries)
      or the directory entry hash in case of a directory entry.

      In case of a "longkey" (16 bytes) the last two bytes are currently
      unused.
    instances:
      type:
        value: key_value >> 29
        enum: key_types
      value:
        value: key_value & 0x1fffffff

enums:
  compression:
    0:
      id: no_compression
      -orig-id: UBIFS_COMPR_NONE
      doc: no compression
    1:
      id: lzo
      -orig-id: UBIFS_COMPR_LZO
      doc: LZO compression
    2:
      id: zlib
      -orig-id: UBIFS_COMPR_ZLIB
      doc: zlib compression
    3:
      id: zstd
      -orig-id: UBIFS_COMPR_ZSTD
      doc: zstd compression
  inode_types:
    0: 
      id: regular
      -orig-id: UBIFS_ITYPE_REG
      doc: regular file
    1:
      id: directory
      -orig-id: UBIFS_ITYPE_DIR
      doc: directory
    2:
      id: link
      -orig-id: UBIFS_ITYPE_LNK
      doc: soft link
    3:
      id: block_device
      -orig-id: UBIFS_ITYPE_BLK
      doc: block device node
    4:
      id: character_device
      -orig-id: UBIFS_ITYPE_CHR
      doc: character device node
    5:
      id: fifo
      -orig-id: UBIFS_ITYPE_FIFO
      doc: fifo
    6:
      id: socket
      -orig-id: UBIFS_ITYPE_SOCK
      doc: socket
  node_types:
    0:
      id: inode
      -orig-id: UBIFS_INO_NODE
      doc: inode node
    1: 
      id: data
      -orig-id: UBIFS_DATA_NODE
      doc: data node
    2:
      id: directory
      -orig-id: UBIFS_DENT_NODE
      doc: directory entry node
    3:
      id: extended_attribute
      -orig-id: UBIFS_XENT_NODE
      doc: extended attribute node
    4:
      id: truncation
      -orig-id: UBIFS_TRUN_NODE
      doc: truncation node
    5:
      id: padding
      -orig-id: UBIFS_PAD_NODE
      doc: padding node
    6:
      id: superblock
      -orig-id: UBIFS_SB_NODE
      doc: superblock node
    7:
      id: master
      -orig-id: UBIFS_MST_NODE
      doc: master node
    8:
      id: reference
      -orig-id: UBIFS_REF_NODE
      doc: LEB reference node
    9:
      id: index
      -orig-id: UBIFS_IDX_NODE
      doc: index node
    10:
      id: commit_start
      -orig-id: UBIFS_CS_NODE
      doc: commit start node
    11:
      id: orphan
      -orig-id: UBIFS_ORPH_NODE
      doc: orphan node
    12:
      id: authentication
      -orig-id: UBIFS_AUTH_NODE
      doc: authentication node
    13:
      id: signature
      -orig-id: UBIFS_SIG_NODE
      doc: signature node
  hashes:
    0:
      id: r5
      -orig-id: UBIFS_KEY_HASH_R5
      doc: R5 hash
    1:
      id: test_hash
      -orig-id: UBIFS_KEY_HASH_TEST
      doc: test hash which just returns first 4 bytes of the name
  key_formats:
    0:
      id: simple
      -orig-id: UBIFS_SIMPLE_KEY_FMT
      doc: |
        The simple key format uses 29 bits for storing UBIFS
        block number and hash value.
  key_types:
    0:
      id: inode
      -orig-id: UBIFS_INO_KEY
      doc: inode node key
    1:
      id: data
      -orig-id: UBIFS_DATA_KEY
      doc: data node key
    2:
      id: directory
      -orig-id: UBIFS_DENT_KEY
      doc: directory entry node key
    3:
      id: extended_attribute
      -orig-id: UBIFS_XENT_KEY
      doc: extended attribute node key
