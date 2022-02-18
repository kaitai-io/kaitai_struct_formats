meta:
  id: ext2
  title: ext2 filesystem
  xref:
    forensicswiki: Extended_File_System_(Ext)
    justsolve: Ext2
    wikidata: Q283527
  tags:
    - filesystem
    - linux
  license: CC0-1.0
  endian: le
instances:
  # https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/filesystems/ext2.rst?id=a9edc03f13db#n116
  bg1:
    pos: 1024
    type: block_group
  root_dir:
    value: bg1.block_groups[0].inodes[1].as_dir
types:
  block_group:
    seq:
      - id: super_block
        type: super_block_struct
        size: 1024
      # https://www.nongnu.org/ext2-doc/ext2.html#BLOCK-GROUP-DESCRIPTOR-TABLE
      - id: block_groups
        type: bgd
        repeat: expr
        repeat-expr: super_block.block_group_count
  # https://www.nongnu.org/ext2-doc/ext2.html#super_block
  # https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/ext2/ext2.h?id=cd913c76f489#n412
  # https://ext4.wiki.kernel.org/index.php/Ext4_Disk_Layout#The_Super_Block
  super_block_struct:
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
        enum: state_enum
      - id: errors
        type: u2
        enum: errors_enum
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
      state_enum:
        1: valid_fs
        2: error_fs
      errors_enum:
        1: act_continue
        2: act_ro
        3: act_panic
  # https://www.nongnu.org/ext2-doc/ext2.html#BLOCK-GROUP-DESCRIPTOR-STRUCTURE
  # https://web.archive.org/web/20160804172310/http://virtualblueness.net/Ext2fs-overview/Ext2fs-overview-0.1-7.html
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
        pos: block_bitmap_block * _root.bg1.super_block.block_size
        size: 1024
      inode_bitmap:
        pos: inode_bitmap_block * _root.bg1.super_block.block_size
        size: 1024
      # https://www.nongnu.org/ext2-doc/ext2.html#INODE-TABLE
      # https://web.archive.org/web/20161114202411/http://www.virtualblueness.net/Ext2fs-overview/Ext2fs-overview-0.1-10.html
      inodes:
        pos: inode_table_block * _root.bg1.super_block.block_size
        type: inode
        repeat: expr
        repeat-expr: _root.bg1.super_block.inodes_per_group
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
    instances:
      as_dir:
        io: 'block[0].body._io'
        pos: 0
        type: dir
  block_ptr:
    seq:
      - id: ptr
        type: u4
    instances:
      body:
        pos: ptr * _root.bg1.super_block.block_size
        size: _root.bg1.super_block.block_size
        type: raw_block
  raw_block:
    seq:
      - id: body
        size: _root.bg1.super_block.block_size
  # https://www.nongnu.org/ext2-doc/ext2.html#LINKED-DIRECTORY-ENTRY-STRUCTURE
  dir:
    seq:
      - id: entries
        type: dir_entry
        repeat: eos
  dir_entry:
    seq:
      - id: inode_ptr
        type: u4
      - id: rec_len
        type: u2
      - id: name_len
        type: u1
      - id: file_type
        type: u1
        enum: file_type_enum
      - id: name
        size: name_len
        type: str
        encoding: UTF-8
      - id: padding
        size: rec_len - name_len - 8
    instances:
      inode:
        value: '_root.bg1.block_groups[(inode_ptr - 1) / _root.bg1.super_block.inodes_per_group].inodes[(inode_ptr - 1) % _root.bg1.super_block.inodes_per_group]'
    enums:
      # https://www.nongnu.org/ext2-doc/ext2.html#IFDIR-FILE-TYPE
      file_type_enum:
        0: unknown
        1: reg_file
        2: dir
        3: chrdev
        4: blkdev
        5: fifo
        6: sock
        7: symlink
