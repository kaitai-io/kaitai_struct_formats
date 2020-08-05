meta:
  id: squashfs_superblock
  title: SquashFS superblock
  file-extension:
    - squashfs
    - snap
  endian: le
  license: CC-0
doc-ref: https://github.com/AgentD/squashfs-tools-ng/blob/master/doc/format.txt
seq:
  - id: superblock
    type: superblock
types:
  superblock:
    seq:
      - id: magic
        contents: 'hsqs'
      - id: inode_count
        type: u4
      - id: mod_time
        type: u4
      - id: block_size
        type: u4
      - id: frag_count
        type: u4
      - id: compressor
        type: u2
      - id: block_log
        type: u2
      - id: flags
        type: u2
      - id: id_count
        type: u2
      - id: version_major
        contents: [ 4, 0 ]
      - id: version_minor
        contents: [ 0, 0 ]
      - id: root_inode_ref
        type: u8
      - id: bytes_used
        type: u8
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
        