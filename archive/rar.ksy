meta:
  id: rar
  title: RAR (Roshall ARchiver) archive files
  application: RAR archiver
  file-extension: rar
  xref:
    forensicswiki: rar
    justsolve: RAR
    loc: fdd000450
    mime:
      - application/vnd.rar
      - application/x-rar-compressed
    pronom:
      - x-fmt/264 # RAR 2.0
      - fmt/411 # RAR 2.9
      - fmt/613 # RAR 5.0
    wikidata: Q243303
  license: CC0-1.0
  ks-version: 0.7
  imports:
    - /common/dos_datetime
    - /common/vlq_base128_le
  endian: le
doc: |
  RAR is a archive format used by popular proprietary RAR archiver,
  created by Eugene Roshal. There are two major versions of format
  (v1.5-4.0 and RAR v5+).

  File format essentially consists of a linear sequence of
  blocks. Each block has fixed header and custom body (that depends on
  block type), so it's possible to skip block even if one doesn't know
  how to process a certain block type.

  Encrypted archives are not supported, although structures for holding
  of encryption parameters are present in this KSY.
doc-ref:
  - http://acritum.com/winrar/rar-format
  - https://github.com/pmachapman/unrar
seq:
  - id: magic
    type: magic_signature
    doc: File format signature to validate that it is indeed a RAR archive
  - id: blocks
    type:
      switch-on: magic.version
      cases:
        version::v4: block_v4
        version::v5: block_v5
    repeat: eos
    doc: Sequence of blocks that constitute the RAR file
types:
  magic_signature:
    doc: |
      RAR uses either 7-byte magic for RAR versions 1.5 to 4.0, and
      8-byte magic (and pretty different block format) for v5+. This
      type would parse and validate both versions of signature. Note
      that actually this signature is a valid RAR "block": in theory,
      one can omit signature reading at all, and read this normally,
      as a block, if exact RAR version is known (and thus it's
      possible to choose correct block format).
    seq:
      - id: magic1
        contents:
          - 'Rar!'
          - 0x1a
          - 0x07
        doc: "Fixed part of file's magic signature that doesn't change with RAR version"
      - id: version
        type: u1
        enum: version
        doc: |
          Variable part of magic signature: 0 means old (RAR 1.5-4.0)
          format, 1 means new (RAR 5+) format
      - id: magic3
        contents: [0]
        if: version == version::v5
        doc: New format (RAR 5+) magic contains extra byte
  block_v4:
    doc: |
      Basic block that RAR files consist of. There are several block
      types (see `block_type`), which have different `body` and
      `add_body`.
    seq:
      - id: crc16
        type: u2
        doc: CRC16 of whole block or some part of it (depends on block type)
      - id: block_type
        type: u1
        enum: block_v4_type
      - id: flags
        type: u2
      - id: block_size
        type: u2
        doc: Size of block (header + body, but without additional content)
      - id: add_size
        type: u4
        if: has_add
        doc: Size of additional content in this block
      - id: body
        size: body_size
        type:
          switch-on: block_type
          cases:
            'block_v4_type::file_header': block_v4_file_header
      - id: add_body
        size: add_size
        if: has_add
        doc: Additional content in this block
    instances:
      has_add:
        value: 'flags & 0x8000 != 0'
        doc: True if block has additional content attached to it
      header_size:
        value: 'has_add ? 11 : 7'
      body_size:
        value: block_size - header_size
  block_v4_file_header:
    seq:
      - id: low_unp_size
        type: u4
        doc: Uncompressed file size (lower 32 bits, if 64-bit header flag is present)
      - id: host_os
        type: u1
        enum: os_v4
        doc: Operating system used for archiving
      - id: file_crc32
        type: u4
      - id: file_time
        size: 4
        type: dos_datetime
        doc: Date and time in standard MS DOS format
      - id: rar_version
        type: u1
        doc: RAR version needed to extract file (Version number is encoded as 10 * Major version + minor version.)
      - id: method
        type: u1
        enum: method_v4
        doc: Compression method
      - id: name_size
        type: u2
        doc: File name size
      - id: attr
        type: u4
        doc: File attributes
      - id: high_pack_size
        type: u4
        doc: Compressed file size, high 32 bits, only if 64-bit header flag is present
        if: '_parent.flags & 0x100 != 0'
      - id: file_name
        size: name_size
      - id: salt
        type: u8
        if: '_parent.flags & 0x400 != 0'
#     - id: ext_time
#       variable size
#       if: '_parent.flags & 0x1000 != 0'
  block_v5:
    -webide-representation: '{header}'
    seq:
      - id: header
        type: header
      - id: data
        doc: |
          Block payload. Content is dependent on the type of block (`header.content.block_type`):

          - `file` records: compressed file data. If file is uncompressed, that is just a file data
          - `service` records:
            - `ACL`: access control lists of the file/folder from the previous block
            - `CMT`: null-terminated string with an archive comment
            - `QO`: index to some blocks of this file
            - `RR`: recovery information
        size: header.content.data_size.value
        if: header.content.flags.has_data
    types:
      header:
        -webide-representation: '{content}'
        seq:
          - id: crc32
            type: u4
          - id: content_size
            -orig-id: BlockSize
            type: vlq_base128_le
          - id: content
            type: content
            size: content_size.value
      content:
        -webide-representation: '{type}: {specific}; flags: {flags}'
        seq:
          - id: block_type
            -orig-id: HeaderType
            type: vlq_base128_le
            # Impossible to use enum because vlq_base128_le not the built-in type
            # enum: block_v5_type
          - id: flags
            type: flags
          - id: extra_size
            type: vlq_base128_le
            doc: Original unrar produces error if this size is >= sizeof of block_v5
            # valid: _.value < sizeof(block_v5)
            if: flags.has_extra
          - id: data_size
            -orig-id: PackSize
            type: vlq_base128_le
            if: flags.has_data
          - id: specific
            type:
              switch-on: block_type.value
              cases:
                # 0x00: mark # blocks of that type is not used in the original unrar utility
                0x01: main
                0x02: file_or_service
                0x03: file_or_service
                0x04: crypt(false)
                0x05: end
          - id: extra
            doc: |
              The original unrar looks for it from the end of block, so in the future
              additional fields can come between `specific` and `extra` fields
            size: extra_size.value
            type: extra
            if: flags.has_extra
        instances:
          type:
            value: block_type.value
            enum: block_v5_type
        types:
          flags:
            -webide-representation: '{this:flags}'
            seq:
              - id: value
                type: vlq_base128_le
            instances:
              has_extra:
                doc: Additional extra area is present in the end of block header
                value: (value.value & 0x0001) != 0
              has_data:
                doc: Additional data area is present in the end of block header
                value: (value.value & 0x0002) != 0
              skip_if_unknown:
                doc: Unknown blocks with this flag must be skipped when updating an archive
                value: (value.value & 0x0004) != 0
              # This flags relevant only for file_or_service records
              split_before:
                doc: |
                  Data area of this block is continuing from previous volume
                  (this flag is only applicable to file or service header type)
                value: (value.value & 0x0008) != 0
              split_after:
                doc: |
                  Data area of this block is continuing in next volume
                  (this flag is only applicable to file or service header type)
                value: (value.value & 0x0010) != 0
              sub_block:
                doc: |
                  Block depends on preceding file block
                  (this flag is only applicable to file or service header type)
                value: (value.value & 0x0020) != 0
              inherited:
                doc: |
                  Preserve a child block if host is modified
                  (this flag is only applicable to file or service header type)
                value: (value.value & 0x0040) != 0
          extra:
            seq:
              - id: entries
                type: extra_entry
                repeat: eos
          extra_entry:
            -webide-representation: '{field}'
            seq:
              - id: field_size
                type: vlq_base128_le
              - id: field
                size: field_size.value
                type:
                  switch-on: _parent._parent.block_type.value
                  cases:
                    0x01: main::extra
                    0x02: file_or_service::extra
                    0x03: file_or_service::extra
      main:
        -webide-representation: '{this:flags}, volume: {volume}'
        doc: |
          Specific content of the first block in the RAR file.

          Technically, this block is not required to be the first. Reader should find
          that block in the stream that it want to unpack. Practically that is always
          the first block of the archive.
        seq:
          - id: flags
            type: vlq_base128_le
          - id: volume
            doc: |
              Volume number of the multi-volume archive. The first volume (`0`)
              may not have this field
            -orig-id: VolNumber
            type: vlq_base128_le
            if: has_volume
        instances:
          multi_volume:
            doc: Archive split into several files
            value: (flags.value & 0x0001) != 0
          has_volume:
            value: (flags.value & 0x0002) != 0
          solid:
            value: (flags.value & 0x0004) != 0
          recovery_info:
            -orig-id: Protected
            doc: Archive contains information for restoration
            value: (flags.value & 0x0008) != 0
          locked:
            value: (flags.value & 0x0010) != 0
        types:
          extra:
            -webide-representation: '{type}: {content}'
            seq:
              - id: raw_type
                -orig-id: FieldType
                type: vlq_base128_le
              - id: content
                type:
                  switch-on: raw_type.value
                  cases:
                    0x01: locator
            instances:
              type:
                value: raw_type.value
                enum: extra_type
          locator:
            -webide-representation: '{this:flags}'
            seq:
              - id: flags
                type: vlq_base128_le
              - id: quick_open_off
                doc: Offset from the beginning of block if not `0`
                type: vlq_base128_le
                if: has_quick_open
              - id: recovery_off
                doc: Offset from the beginning of block if not `0`
                type: vlq_base128_le
                if: has_recovery
            instances:
              has_quick_open:
                doc: Quick open offset is present
                value: (flags.value & 0x01) != 0
              has_recovery:
                doc: Recovery record offset is present
                value: (flags.value & 0x02) != 0
        enums:
          extra_type:
            0x01: locator
      file_or_service:
        -webide-representation: '{file_name}, {unpacked_size}, {compression.method}'
        doc: |
          Specific content of the block that stores information about:

          - files and directories (`file` record, file name is the full name of file)
          - additional information (`service` record), which is identified by the file
            name field:
            - `ACL`: access control lists of files. That blocks is written just after
              the corresponding `file` block
            - `CMT`: archive comment
            - `QO`: quick open information (archive index?)
            - `RR`: recovery information
            - `STM`: additional NTFS streams of a file
        seq:
          - id: flags
            type: file_flags
          - id: unpacked_size
            doc: Only relevant if `is_unknown_unpacked_size` is `false`
            type: vlq_base128_le
          - id: attributes
            type: vlq_base128_le
          - id: mtime
            doc: File modification time
            type: u4
            if: flags.has_mtime
          - id: crc32
            type: u4
            if: flags.has_crc32
          - id: compression
            type: compression
          - id: host_os
            type: vlq_base128_le
            # enum: os_v5
          - id: file_name_len
            type: vlq_base128_le
          - id: file_name
            doc: Original unrar will read to the size or end-of-block
            type: str
            size: 'file_name_len.value < 2048 ? file_name_len.value : 2048'
            encoding: utf-8
            eos-error: false
        instances:
          os:
            value: host_os.value
            enum: os_v5
        types:
          file_flags:
            -webide-representation: '{this:flags}'
            seq:
              - id: value
                type: vlq_base128_le
            instances:
              is_directory:
                value: (value.value & 0x0001) != 0
              has_mtime:
                doc: Time field in Unix format is present
                value: (value.value & 0x0002) != 0
              has_crc32:
                doc: CRC32 field is present
                value: (value.value & 0x0004) != 0
              is_unknown_unpacked_size:
                value: (value.value & 0x0008) != 0
          compression:
            -webide-representation: '{method}, version: {version:dec}, solid: {solid}'
            seq:
              - id: value
                type: vlq_base128_le
            instances:
              method:
                value: (value.value >> 7) & 7
                enum: method_v5
              version:
                value: (value.value & 0x3f) + 50
              solid:
                doc: Only file blocks has it, service is not
                value: (value.value & 0x0040) != 0
          extra:
            -webide-representation: '{type}: {content}'
            seq:
              - id: raw_type
                -orig-id: FieldType
                type: vlq_base128_le
              - id: content
                type:
                  switch-on: raw_type.value
                  cases:
                    0x01: crypt(true)
                    0x02: hash
                    0x03: hi_precision_time
                    0x04: version
                    0x05: redirection
                    0x06: unix_owner
                    0x07: sub_data
            instances:
              type:
                value: raw_type.value
                enum: extra_type
          hash:
            -webide-representation: '{type}: {digest}'
            doc: (0x02) File hash
            seq:
              - id: raw_type
                type: vlq_base128_le
              - id: digest
                doc: Blake2 digest
                size: 32
                if: type == algo::blake2
            instances:
              type:
                value: raw_type.value
                enum: algo
            enums:
              algo:
                0: blake2
          hi_precision_time:
            -webide-representation: 'c:{ctime:dec}, m:{mtime:dec}, a:{atime:dec}'
            doc: (0x03) High precision file time
            seq:
              - id: flags
                type: vlq_base128_le
              - id: mtime
                type:
                  switch-on: is_unix
                  cases:
                    true : u4 # Unix
                    false: u8 # Windows
                if: has_mtime
              - id: ctime
                type:
                  switch-on: is_unix
                  cases:
                    true : u4 # Unix
                    false: u8 # Windows
                if: has_ctime
              - id: atime
                type:
                  switch-on: is_unix
                  cases:
                    true : u4 # Unix
                    false: u8 # Windows
                if: has_atime
              - id: mtime_ns
                type: u4
                if: is_unix and has_nanos and has_mtime
              - id: ctime_ns
                type: u4
                if: is_unix and has_nanos and has_ctime
              - id: atime_ns
                type: u4
                if: is_unix and has_nanos and has_atime
            instances:
              is_unix:
                doc: Use Unix time_t format
                value: (flags.value & 0x01) != 0
              has_mtime:
                doc: mtime is present
                value: (flags.value & 0x02) != 0
              has_ctime:
                doc: ctime is present
                value: (flags.value & 0x04) != 0
              has_atime:
                doc: atime is present
                value: (flags.value & 0x08) != 0
              has_nanos:
                doc: Unix format with nanosecond precision
                value: (flags.value & 0x10) != 0
          version:
            -webide-representation: '{version}'
            doc: (0x04) File version information
            seq:
              - id: flags
                type: vlq_base128_le
              - id: version
                type: vlq_base128_le
          redirection:
            -webide-representation: '{type}: {name}'
            doc: (0x05) File system redirection (links, etc.)
            seq:
              - id: raw_type
                -orig-id: RedirType
                type: vlq_base128_le
              - id: flags
                type: vlq_base128_le
              - id: name_len
                type: vlq_base128_le
              - id: name
                type: str
                size: 'name_len.value < 2048 ? name_len.value : 2048'
                encoding: utf-8
            instances:
              is_dir:
                -orig-id: DirTarget
                doc: Link target is directory
                value: (flags.value & 0x01) != 0
              type:
                value: raw_type.value
                enum: redirection_type
          unix_owner:
            -webide-representation: 'u:{user_id}/{user}, g:{group_id}/{group}'
            doc: (0x06) Unix owner and group information
            seq:
              - id: flags
                type: vlq_base128_le
              - id: user
                -orig-id: UnixOwnerName
                type: name
                if: has_user_name
              - id: group
                -orig-id: UnixGroupName
                type: name
                if: has_group_name
              - id: user_id
                -orig-id: UnixOwnerId
                type: vlq_base128_le
                if: has_user_id
              - id: group_id
                -orig-id: UnixGroupId
                type: vlq_base128_le
                if: has_group_id
            types:
              name:
                seq:
                  - id: len
                    type: vlq_base128_le
                  - id: name
                    type: str
                    size: 'len.value < 256 ? len.value : 256'
                    encoding: utf-8
            instances:
              has_user_name:
                -orig-id: UnixOwnerNumeric
                doc: User name string is present
                value: (flags.value & 0x01) != 0
              has_group_name:
                -orig-id: UnixGroupNumeric
                doc: Group name string is present
                value: (flags.value & 0x02) != 0
              has_user_id:
                doc: Numeric user ID is present
                value: (flags.value & 0x04) != 0
              has_group_id:
                doc: Numeric group ID is present
                value: (flags.value & 0x08) != 0
          sub_data:
            -webide-representation: '{content}'
            doc: (0x07) Service header subdata array
            seq:
              - id: content
                doc: For `RR` service record there is one byte with recovery percent
                size-eos: true
        enums:
          extra_type:
            0x01: crypt
            0x02: hash
            0x03: hi_precision_time
            0x04: version
            0x05: redirection
            0x06: unix_owner
            0x07: sub_data
          redirection_type:
            0x00: none
            0x01: unix_sym_link
            0x02: win_sym_link
            0x03: junction
            0x04: hard_link
            0x05: file_copy
      crypt:
        doc: |
          All data in the archive encrypted with AES-256 after end of this block.
          Parameters of an encryption algorithm contained within this block.

          In the real life this is the first block of an encrypted archive, so all
          other blocks in an archive is encrypted.

          Be notice, that the block size is encrypted as well, so we can not express
          the decryption functionality as a Kaitai Struct `process` key, because it
          is required a stream of known size.
        params:
          - id: extra
            doc: Block is used as an `extra` block for `file` or `service` record
            type: bool
        seq:
          - id: version
            doc: |
              Identifier of the encryption algorithm used. The only known algorithm
              is AES-256 (`0`)
            type: vlq_base128_le
          - id: flags
            type: vlq_base128_le
          - id: lg2_count
            doc: |
              LOG2 of maximum accepted iteration count.

              This number determines the iteration count for the [`pbkdf2`] key generation
              function. The count is `1 << lg2_count`.

              Currently the maximum is 24.

              [`pbkdf2`]: https://en.wikipedia.org/wiki/PBKDF2
            type: u1
            # valid: _ <= 24
          - id: salt
            size: 16
          - id: iv
            doc: Initialization vector for AES-256
            size: 16
            if: extra
          - id: password_check
            doc: |
              Value used to check the correctness of the entered password.

              This value calculated as [`pbkdf2`] derived key with additional 32
              iterations after the encryption key, split for 4 parts and XORed:

              ```
              [xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx] = pbkdf2(
                function         = hmac_sha256,
                password         = ***,
                salt             = _.salt,
                count            = (1 << lg2_count) + 32,
                derivedKeyLength = 32
              );
              password_check = [xxxxxxxx
                            xor xxxxxxxx
                            xor xxxxxxxx
                            xor xxxxxxxx]
              ```

              If value, calculated from the entered archive password do not match
              this value, password is invalid.

              [`pbkdf2`]: https://en.wikipedia.org/wiki/PBKDF2
            size: 8
            if: use_password_check
          - id: password_check_sum
            doc: |
              First 4 bytes of SHA-256(password_check)

              This field is used to determine corrupted archives. Because block's
              CRC32 is encrypted there is need another way to check data validity.
            size: 4
            if: use_password_check
            # valid: sha256(password_check)[0..4]
        instances:
          use_password_check:
            doc: Password check data is present
            value: (flags.value & 0x0001) != 0
          use_hash_mac:
            doc: Use MAC for unpacked data checksums
            value: (flags.value & 0x0002) != 0
            if: extra
      end:
        -webide-representation: '{this:flags}'
        doc: |
          Specific content of the last block in the RAR file.

          Technically, this block is not required to be the last.
          Practically that is always the last block of the archive.
        seq:
          - id: flags
            type: vlq_base128_le
        instances:
          has_next_volume:
            doc: Not last volume
            value: (flags.value & 0x0001) != 0
  block_v5_encrypted:
    seq:
      - id: iv
        doc: Initialization vector for AES-256
        size: 16
      - id: content
        doc: Encrypted block
        # process: aes(256, iv)
        type: block_v5
enums:
  version:
    0:
      id: v4
      doc: Format of RAR 1.5-4.0
    1:
      id: v5
      doc: Format of RAR 5.0+
  block_v4_type:
    0x72: marker
    0x73: archive_header
    0x74: file_header
    0x75: old_style_comment_header
    0x76: old_style_authenticity_info_76
    0x77: old_style_subblock
    0x78: old_style_recovery_record
    0x79: old_style_authenticity_info_79
    0x7a: subblock
    0x7b: terminator
  block_v5_type:
    0x00: mark
    0x01: main
    0x02: file
    0x03: service
    0x04: crypt
    0x05: end
    0xFF: unknown
  os_v4:
    0: ms_dos
    1: os_2
    2: windows
    3: unix
    4: mac_os
    5: beos
  os_v5:
    0: windows
    1: unix
  method_v4:
    0x30: store
    0x31: fastest
    0x32: fast
    0x33: normal
    0x34: good
    0x35: best
  method_v5:
    0: store
    1: fastest
    2: fast
    3: normal
    4: good
    5: best
