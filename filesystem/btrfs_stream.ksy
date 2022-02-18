meta:
  id: btrfs_stream
  application: Btrfs
  xref:
    wikidata: Q283820
  tags:
    - filesystem
    - linux
  license: CC0-1.0
  endian: le
doc: |
  Btrfs is a copy on write file system based on B-trees focusing on fault tolerance, repair and easy
  administration. Btrfs is intended to address the lack of pooling, snapshots, checksums, and
  integral multi-device spanning in Linux file systems.
  Given any pair of subvolumes (or snapshots), Btrfs can generate a binary diff between them by
  using the `btrfs send` command that can be replayed later by using `btrfs receive`, possibly on a
  different Btrfs file system. The `btrfs send` command creates a set of data modifications required
  for converting one subvolume into another.
  This spec can be used to disassemble the binary diff created by the `btrfs send` command.
  If you want a text representation you may want to checkout `btrfs receive --dump` instead.
doc-ref: https://btrfs.wiki.kernel.org/index.php/Design_notes_on_Send/Receive

seq:
  - id: header
    type: send_stream_header
  - id: commands
    type: send_command
    repeat: eos
types:
  send_stream_header:
    seq:
      - id: magic
        contents: ['btrfs-stream', 0x00]
      - id: version
        type: u4le
  send_command:
    seq:
      - id: len_data
        type: u4le
      - id: type
        type: u2le
        enum: command
      - id: checksum
        size: 4
        doc: CRC32 checksum of a whole send command, including the header, with this attribute set to 0.
      - id: data
        type: tlvs
        size: len_data
    types:
      tlvs:
        seq:
          - id: tlv
            type: tlv
            repeat: eos
      tlv:
        seq:
          - id: type
            enum: attribute
            type: u2le
          - id: length
            type: u2le
          - id: value
            size: length
            type:
              switch-on: type
              cases:
                #'attribute::unspec':
                'attribute::uuid': uuid
                'attribute::ctransid': u8le
                #'attribute:ino':
                'attribute::size': u8le
                'attribute::mode': u8le
                'attribute::uid': u8le
                'attribute::gid': u8le
                'attribute::rdev': u8le
                'attribute::ctime': timespec
                'attribute::mtime': timespec
                'attribute::atime': timespec
                'attribute::otime': timespec
                'attribute::xattr_name': string
                #'attribute::xattr_data':
                'attribute::path': string
                'attribute::path_to': string
                'attribute::path_link': string
                'attribute::file_offset': u8le
                #'attribute::data':
                'attribute::clone_uuid': uuid
                'attribute::clone_ctransid': u8le
                'attribute::clone_path': string
                'attribute::clone_offset': u8le
                'attribute::clone_len': u8le
      timespec:
        seq:
          - id: ts_sec
            type: s8le
          - id: ts_nsec
            type: s4le
      string:
        seq:
          - id: string
            type: str
            size-eos: true
            encoding: UTF-8
      uuid:
        seq:
          - id: uuid
            size: 16

# enum btrfs_send_cmd
# https://git.kernel.org/pub/scm/linux/kernel/git/kdave/btrfs-progs.git/tree/kernel-shared/send.h?id=979bda6f#n69
enums:
  command:
    0x00: unspec
    0x01: subvol
    0x02: snapshot
    0x03: mkfile
    0x04: mkdir
    0x05: mknod
    0x06: mkfifo
    0x07: mksock
    0x08: symlink
    0x09: rename
    0x0a: link
    0x0b: unlink
    0x0c: rmdir
    0x0d: set_xattr
    0x0e: remove_xattr
    0x0f: write
    0x10: clone
    0x11: truncate
    0x12: chmod
    0x13: chown
    0x14: utimes
    0x15: end
    0x16: update_extent
  attribute:
    0x00: unspec
    0x01: uuid
    0x02: ctransid
    0x03: ino
    0x04: size
    0x05: mode
    0x06: uid
    0x07: gid
    0x08: rdev
    0x09: ctime
    0x0a: mtime
    0x0b: atime
    0x0c: otime
    0x0d: xattr_name
    0x0e: xattr_data
    0x0f: path
    0x10: path_to
    0x11: path_link
    0x12: file_offset
    0x13: data
    0x14: clone_uuid
    0x15: clone_ctransid
    0x16: clone_path
    0x17: clone_offset
    0x18: clone_len
