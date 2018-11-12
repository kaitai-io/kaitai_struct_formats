meta:
  id: ubifs
  endian: le
seq:
  - id: super_block
    type: index

instances:
  mst_chdr1:
    pos: super_block.sb.leb_size*1
    type: index
  mst_chdr2:
    pos: super_block.sb.leb_size*2
    type: index
  inodes:
    pos: super_block.sb.leb_size * mst_chdr1.mst.root_lnum + mst_chdr1.mst.root_offs
    type: index

types:
  index:
    seq:
      - id: hdr
        type: ubifs_common_hdr
      - id: inode
        type: ubifs_inode_node
        size: hdr.len - 24
        if: hdr.node_type == ubifs_node::ino
      - id: idx
        type: ubifs_idx_node
        size: hdr.len - 24
        if: hdr.node_type == ubifs_node::idx
      - id: data
        type: ubifs_data_node
        size: hdr.len - 24
        if: hdr.node_type == ubifs_node::data
      - id: dent
        type: ubifs_data_node
        size: hdr.len - 24
        if: hdr.node_type == ubifs_node::dent
      - id: sb
        type: ubifs_sb_node
        size: hdr.len - 24
        if: hdr.node_type == ubifs_node::sb
      - id: mst
        type: ubifs_mst_node
        size: hdr.len - 24
        if: hdr.node_type == ubifs_node::mst
      - id: pad
        type: ubifs_pad_node
        size: hdr.len - 24
        if: hdr.node_type == ubifs_node::pad
      - id: padding
        size: pad.pad_len
        if: hdr.node_type == ubifs_node::pad
      - id: cs
        size: hdr.len - 24
        if: hdr.node_type == ubifs_node::cs
  ubifs_common_hdr:
    seq:
      - id: magic       # UBIFS node magic number.
        contents: [0x31, 0x18, 0x10, 0x06]
      - id: crc         # CRC32 checksum of header.
        type: u4
      - id: sqnum       # Sequence number.
        type: u8
      - id: len         # Full node length.
        type: u4
      - id: node_type   # Node type.
        type: u1
        enum: ubifs_node
      - id: group_type  # Node group type.
        type: u1
        enum: node_group
      - id: padding     # Reserved for future, zeros.
        size: 2
  ubifs_dev_desc:
    seq:
      - id: new   # New type device descriptor.
        type: u4
      - id: huge  # huge type device descriptor.
        type: u8
  ubifs_inode_node:
    seq:
      - id: key          # Node key
        size: 16
        type: key_info
      - id: creat_sqnum  # Sequence number at time of creation.
        type: u8
      - id: size         # Inode size in bytes (uncompressed).
        type: u8
      - id: atime_sec    # Access time in seconds.
        type: u8
      - id: ctime_sec    # Creation time seconds.
        type: u8
      - id: mtime_sec    # Modification time in seconds.
        type: u8
      - id: atime_nsec   # Access time in nanoseconds.
        type: u4
      - id: ctime_nsec   # Creation time in nanoseconds.
        type: u4
      - id: mtime_nsec   # Modification time in nanoseconds.
        type: u4
      - id: nlink        # Number of hard links.
        type: u4
      - id: uid          # Owner ID.
        type: u4
      - id: gid          # Group ID.
        type: u4
      - id: mode         # Access flags.
        type: u4
      - id: flags        # Per-inode flags.
        type: u4
      - id: data_len     # Inode data length.
        type: u4
      - id: xattr_cnt    # Count of extended attr this inode has
        type: u4
      - id: xattr_size   # Summarized size of all extended attributes in bytes.
        type: u4
      - id: padding1     # Reserved for future, zeros.
        size: 4
      - id: xattr_names  # Sum of lengths of all extended. attribute names belonging to this inode.
        type: u4
      - id: compr_type   # Compression type used for this inode.
        type: u2
      - id: padding2     # Reserved for future, zeros.
        size: 26
      - id: data         # No size
        size-eos: true
  ubifs_dent_node:
    seq:
      - id: key      # Node key.
        size: 16
        type: key_info
      - id: inum     # Target inode number.
        type: u8
      - id: padding1 # Reserved for future, zeros.
        type: u1
      - id: type     # Type of target inode.
        type: u1
      - id: nlen     # Name length.
        type: u2
      - id: padding2 # Reserved for future, zeros.
        size: 4
      - id: name     # No size
        size-eos: true # buf[-self.nlen-1:-1]
        encoding: UTF-8
        type: str
  ubifs_data_node:
    seq:
      - id: key         # Node key.
        size: 16
        type: key_info
      - id: size        # Uncompressed data size.
        type: u4
      - id: compr_type  # Compression type UBIFS_COMPR_*
        type: u2
        enum: ubifs_compr
      - id: padding     # Reserved for future, zeros.
        size: 2
      - id: data         # No size
        size-eos: true
  ubifs_trun_node:
    seq:
      - id: inum      # Truncated inode number.
        type: u4
      - id: padding   # Reserved for future, zeros.
        size: 12
      - id: old_size  # size before truncation.
        type: u8
      - id: new_size  # Size after truncation.
        type: u8
  ubifs_pad_node:
    seq:
      - id: pad_len   # Number of bytes after this inode unused.
        type: u4
  ubifs_sb_node:
    seq:
      - id: padding           # Reserved for future, zeros.
        size: 2
      - id: key_hash          # Type of hash func used in keys.
        type: u1
      - id: key_fmt           # Format of the key.
        type: u1
      - id: flags             # File system flags.
        type: u4
      - id: min_io_size       # Min I/O unit size.
        type: u4
      - id: leb_size          # LEB size in bytes.
        type: u4
      - id: leb_cnt           # LEB count used by FS.
        type: u4
      - id: max_leb_cnt       # Max count of LEBS used by FS.
        type: u4
      - id: max_bud_bytes     # Max amount of data stored in buds.
        type: u8
      - id: log_lebs          # Log size in LEBs.
        type: u4
      - id: lpt_lebs          # Number of LEBS used for lprops table.
        type: u4
      - id: orph_lebs         # Number of LEBS used for recording orphans.
        type: u4
      - id: jhead_cnt         # Count of journal heads
        type: u4
      - id: fanout            # Tree fanout, max number of links per indexing node.
        type: u4
      - id: lsave_cnt         # Number of LEB numbers in LPT's save table.
        type: u4
      - id: fmt_version       # UBIFS on-flash format version.
        type: u4
      - id: default_compr     # Default compression used.
        type: u2
        enum: ubifs_compr
      - id: padding1          # Reserved for future, zeros.
        size: 2 
      - id: rp_uid            # Reserve pool UID
        type: u4
      - id: rp_gid            # Reserve pool GID
        type: u4
      - id: rp_size           # Reserve pool size in bytes
        type: u8
      - id: time_gran         # Time granularity in nanoseconds.
        type: u4
      - id: uuid              # UUID generated when the FS imagewas created.
        size: 16 
      - id: ro_compat_version # UBIFS R/O Compatibility version.
        type: u4
      - id: padding2          #Reserved for future, zeros
        size: 3968
  ubifs_mst_node:
    seq:
      - id: highest_inum # Highest inode number in the committed index.
        type: u8
      - id: cmt_no       # Commit Number.
        type: u8
      - id: flags        # Various flags.
        type: u4
      - id: log_lnum     # LEB num start of log.
        type: u4
      - id: root_lnum    # LEB num of root indexing node.
        type: u4
      - id: root_offs    # Offset within root_lnum
        type: u4
      - id: root_len     # Root indexing node length.
        type: u4
      - id: gc_lnum      # LEB reserved for garbage collection.
        type: u4
      - id: ihead_lnum   # LEB num of index head.
        type: u4
      - id: ihead_offs   # Offset of index head.
        type: u4
      - id: index_size   # Size of index on flash.
        type: u8
      - id: total_free   # Total free space in bytes.
        type: u8
      - id: total_dirty  # Total dirty space in bytes.
        type: u8
      - id: total_used   # Total used space in bytes (data LEBs)
        type: u8
      - id: total_dead   # Total dead space in bytes (data LEBs)
        type: u8
      - id: total_dark   # Total dark space in bytes (data LEBs)
        type: u8
      - id: lpt_lnum     # LEB num of LPT root nnode.
        type: u4
      - id: lpt_offs     # Offset of LPT root nnode.
        type: u4
      - id: nhead_lnum   # LEB num of LPT head.
        type: u4
      - id: nhead_offs   # Offset of LPT head.
        type: u4
      - id: ltab_lnum    # LEB num of LPT's own lprop table.
        type: u4
      - id: ltab_offs    # Offset of LPT's own lprop table.
        type: u4
      - id: lsave_lnum   # LEB num of LPT's save table.
        type: u4
      - id: lsave_offs   # Offset of LPT's save table.
        type: u4
      - id: lscan_lnum   # LEB num of last LPT scan.
        type: u4
      - id: empty_lebs   # Number of empty LEBs.
        type: u4
      - id: idx_lebs     # Number of indexing LEBs.
        type: u4
      - id: leb_cnt      # Count of LEBs used by FS.
        type: u4
      - id: padding      # Reserved for future, zeros.
        size: 344
  ubifs_ref_node:
    seq:
      - id: lnum     # Referred LEB number.
        type: u4
      - id: offs     # Start offset of referred LEB.
        type: u4
      - id: jhead    # Journal head number.
        type: u4
      - id: padding  # Reserved for future, zeros.
        size: 28
  ubifs_branch:
    seq:
      - id: lnum   # LEB number of target node.
        type: u4
      - id: offs   # Offset within lnum.
        type: u4
      - id: len    # Target node length.
        type: u4
      - id: key    # Using UBIFS_SK_LEN as size.
        size: 8
        type: key_info
    instances:
      inodes:
        io: _root._io
        pos: _root.super_block.sb.leb_size * lnum + offs
        type: index
        size: len
  ubifs_idx_node:
    seq:
      - id: child_cnt    # Number of child index nodes.
        type: u2
      - id: level        # Tree level.
        type: u2
      - id: branches     # No size
        type: ubifs_branch
        repeat: expr
        repeat-expr: child_cnt
  key_info:
    seq:
      - id: hkey
        type: u4
      - id: lkey
        type: u4
    instances:
      key_type:
        value: lkey >> 29
      ino_num:
        value: hkey & 0x1fffffff
      khash:
        value: lkey

enums:
  ubifs_flg:
    2: biglpt        # if 'big' LPT model is used if set.
    4: space_fixup   # first-mount 'fixup' of free space within
  node_group:
    0: not      # This node is not part of a group
    1: in       # This node is part of a group
    2: last_of  # This node is the last in a group
  mst_flg:
    1: dirty    # Rebooted uncleanly
    2: no_orphs # No orphans present
    4: rcvry    # Written by recovery
  ubifs_node:
    0 : ino       # Inode node
    1 : data      # Data node
    2 : dent      # Directory entry node
    3 : xent      # Extended attribute node
    4 : trun      # Truncation node
    5 : pad       # Padding node
    6 : sb        # Superblock node
    7 : mst       # Master node
    8 : ref       # LEB reference node
    9 : idx       # Index node
    10: cs        # Commit start node
    11: orph      # Orphan node
    12: cnt       # Count of supported node types
  ubifs_compr:
    0: none      # No compression
    1: lzo       # LZO compression
    2: zlib      # ZLIB compression
    3: cnt       # Count of supported compression types
  flash_inode_flg:
    1 : compr     # Use compression for this inode
    2 : sync      # Has to be synchronous I/O
    4 : immutable # Inode is immutable
    8 : append    # Writes may only append data
    16: dirsync   # I/O on this directory inode must be synchronous
    32: xattr     # This inode is inode for extended attributes
  key_types:
    0: ino       # Inode node key
    1: data      # Data node key
    2: dent      # Directory node key
    3: xent      # Extended attribute entry key
    4: cnt       # Supported key count
  ubifs_itype:
    0: reg  # Regular file
    1: dir  # Directory
    2: lnk  # Soft link
    3: blk  # Block device node
    4: chr  # Char device node
    5: fifo # FIFO
    6: sock # Socket
    7: cnt  # Support file type count
  consts:
    24: ubifs_common_hdr_sz
