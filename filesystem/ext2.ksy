meta:
  id: ext2
  endian: le
instances:
  # http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/filesystems/ext2.txt#n106
  bg1:
    type: block_group
    pos: 1024
  root_dir:
    value: 'bg1.block_groups[0].inodes[1].block[0].body'
types:
  block_group:
    seq:
      - id: superblock
        type: superblock
        size: 1024
      # http://www.nongnu.org/ext2-doc/ext2.html#BLOCK-GROUP-DESCRIPTOR-TABLE
      - id: block_groups
        type: bgd
        repeat: expr
        repeat-expr: superblock.block_group_count
  # http://www.nongnu.org/ext2-doc/ext2.html#SUPERBLOCK
  # http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/fs/ext2/ext2.h#n416
  # https://ext4.wiki.kernel.org/index.php/Ext4_Disk_Layout#The_Super_Block
  superblock:
    seq:
      - id: inodes_count
        type: u4
      - id: blocks_count
        type: u4
      - id: r_blocks_count
        type: u4
      - id: free_blocks_count
        type: u4
      - id: free_inodes_count
        type: u4
      - id: first_data_block
        type: u4
      - id: log_block_size
        type: u4
      - id: log_frag_size
        type: u4
      - id: blocks_per_group
        type: u4
      - id: frags_per_group
        type: u4
      - id: inodes_per_group
        type: u4
      - id: mtime
        type: u4
      - id: wtime
        type: u4
      - id: mnt_count
        type: u2
      - id: max_mnt_count
        type: u2
      - id: magic
        contents: [0x53, 0xef]
      - id: state
        type: u2
        enum: state
      - id: errors
        type: u2
        enum: errors
      - id: minor_rev_level
        type: u2
      - id: lastcheck
        type: u4
      - id: checkinterval
        type: u4
      - id: creator_os
        type: u4
      - id: rev_level
        type: u4
      - id: def_resuid
        type: u2
      - id: def_resgid
        type: u2
#    -- EXT2_DYNAMIC_REV Specific --
      - id: first_ino
        type: u4
      - id: inode_size
        type: u2
      - id: block_group_nr
        type: u2
      - id: feature_compat
        type: u4
      - id: feature_incompat
        type: u4
      - id: feature_ro_compat
        type: u4
      - id: uuid
        size: 16
      - id: volume_name
        size: 16
      - id: last_mounted
        size: 64
      - id: algo_bitmap
        type: u4
#    -- Performance Hints --
      - id: prealloc_blocks
        type: u1
      - id: prealloc_dir_blocks
        type: u1
      - id: padding1
        size: 2
#    -- Journaling Support --
      - id: journal_uuid
        size: 16
      - id: journal_inum
        type: u4
      - id: journal_dev
        type: u4
      - id: last_orphan
        type: u4
#    -- Directory Indexing Support --
      - id: hash_seed
        type: u4
        repeat: expr
        repeat-expr: 4
      - id: def_hash_version
        type: u1
    instances:
      block_size:
        value: 1024 << log_block_size
      block_group_count:
        value: blocks_count / blocks_per_group
    enums:
      state:
        1: valid_fs
        2: error_fs
      errors:
        1: continue
        2: ro
        3: panic
  # http://www.nongnu.org/ext2-doc/ext2.html#BLOCK-GROUP-DESCRIPTOR-STRUCTURE
  # http://www.virtualblueness.net/Ext2fs-overview/Ext2fs-overview-0.1-7.html
  bgd:
    seq:
      - id: block_bitmap_block
        type: u4
      - id: inode_bitmap_block
        type: u4
      - id: inode_table_block
        type: u4
      - id: free_blocks_count
        type: u2
      - id: free_inodes_count
        type: u2
      - id: used_dirs_count
        type: u2
      - id: pad_reserved
        size: 2 + 12
    instances:
      block_bitmap:
        pos: block_bitmap_block * _root.bg1.superblock.block_size
        size: 1024
      inode_bitmap:
        pos: inode_bitmap_block * _root.bg1.superblock.block_size
        size: 1024
      # http://www.nongnu.org/ext2-doc/ext2.html#INODE-TABLE
      # http://www.virtualblueness.net/Ext2fs-overview/Ext2fs-overview-0.1-10.html
      inodes:
        pos: inode_table_block * _root.bg1.superblock.block_size
        type: inode
        repeat: expr
        repeat-expr: _root.bg1.superblock.inodes_per_group
  inode:
    seq:
      - id: mode
        type: u2
      - id: uid
        type: u2
      - id: size
        type: u4
      - id: atime
        type: u4
      - id: ctime
        type: u4
      - id: mtime
        type: u4
      - id: dtime
        type: u4
      - id: gid
        type: u2
      - id: links_count
        type: u2
      - id: blocks
        type: u4
      - id: flags
        type: u4
      - id: osd1
        type: u4
      - id: block
        type: block_ptr
        repeat: expr
        repeat-expr: 15
      - id: generation
        type: u4
      - id: file_acl
        type: u4
      - id: dir_acl
        type: u4
      - id: faddr
        type: u4
      - id: osd2
        size: 12
  block_ptr:
    seq:
      - id: ptr
        type: u4
    instances:
      body:
        pos: ptr * _root.bg1.superblock.block_size
        size: _root.bg1.superblock.block_size
