meta:
  id: android_vbmeta
  title: Android VBMeta
  file-extension: img
  xref:
    wikidata: Q101208368
  license: CC0-1.0
  ks-version: 0.9
  endian: be

doc: |
  Verified boot is the process of assuring the end user of the
  integrity of the software running on a device. The central data
  structure used in android verified boot is the VBMeta struct.
  This data structure contains a number of descriptors (and other
  metadata) and all of this data is cryptographically signed.
  Descriptors are used for image hashes, image hashtree metadata,
  and so-called chained partitions. VBMeta struct is stored on a
  special vbmeta partition on a device.


doc-ref:
  - https://android.googlesource.com/platform/external/avb/+/refs/tags/android-11.0.0_r31/#android-verified-boot-2_0
  - https://android.googlesource.com/platform/external/avb/+/refs/tags/android-11.0.0_r31/libavb/avb_vbmeta_image.h#125

seq:
  - id: header
    type: vbmeta_header
    size: 256
  - id: authentication_data
    type: vbmeta_authentication_data
    size: header.authentication_data_block_size
  - id: auxiliary_data
    type: vbmeta_auxiliary_data
    size: header.auxiliary_data_block_size

types:
  position:
    seq:
      - id: offset
        type: u8
      - id: size
        type: u8
  vbmeta_version:
    seq:
      - id: major
        type: u4
        doc: The major version of libavb required for this header.
      - id: minor
        type: u4
        doc: The minor version of libavb required for this header.
  vbmeta_header:
    seq:
      - id: magic
        contents: AVB0
      - id: required_libavb_version
        type: vbmeta_version
      - id: authentication_data_block_size
        type: u8
        doc: The size of the signature block
      - id: auxiliary_data_block_size
        type: u8
      - id: algorithm_type
        type: u4
        enum: algorithm_types
        doc: The verification algorithm used, see |AvbAlgorithmType| enum.
      - id: hash_pos
        type: position
        valid:
          expr: |
            (
              algorithm_type == algorithm_types::sha256_rsa2048 or
              algorithm_type == algorithm_types::sha256_rsa4096 or
              algorithm_type == algorithm_types::sha256_rsa8192
            ) ? _.size == 32
            : (
              algorithm_type == algorithm_types::sha512_rsa2048 or
              algorithm_type == algorithm_types::sha512_rsa4096 or
              algorithm_type == algorithm_types::sha512_rsa8192
            ) ? _.size == 64
            : true
        doc: Position of hash data in "Authentication data" block.
      - id: signature_pos
        type: position
        doc: Position of signature data in "Authentication data" block.
      - id: public_key_pos
        type: position
        doc: Position of public key in "Auxiliary data" block.
      - id: public_key_metadata_pos
        type: position
        doc: Position of public key metadata in "Auxiliary data" block.
      - id: descriptors_pos
        type: position
        doc: Position of descriptor data in "Auxiliary data" block.
      - id: rollback_index
        type: u8
        doc: |
          The rollback index which can be used to prevent rollback to
          older versions.
      - id: flags
        type: u4
        doc: |
          Flags from the AvbVBMetaImageFlags enumeration. This must be
          set to zero if the vbmeta image is not a top-level image.
      - id: reserved0
        contents: [0, 0, 0, 0]
        doc: |
          Reserved to ensure |release_string| start on a 16-byte boundary.
          Must be set to zeroes.
      - id: release_string
        size: 48
        type: strz
        encoding: ASCII
        doc: |
          The release string from avbtool, e.g. "avbtool 1.0.0" or
          "avbtool 1.0.0 xyz_board Git-234abde89". Is guaranteed to be NUL
          terminated. Applications must not make assumptions about how this
          string is formatted.
      - id: reserved
        size: 80
        doc: |
          Padding to ensure struct is size AVB_VBMETA_IMAGE_HEADER_SIZE
          bytes. This must be set to zeroes.
    instances:
      is_hashtree_disabled:
        value: flags & 1 != 0
      is_verification_disabled:
        value: flags & 2 != 0
  vbmeta_public_key_header:
    doc: The header for a serialized RSA public key
    seq:
      - id: key_num_bits
        type: u4
        doc: The size of the key in bits
      - id: n0inv
        type: u4
        doc: Precomputed value for optimization of verification.
  property_descriptor:
    doc: A descriptor for properties (free-form key/value pairs)
    seq:
      - id: key_num_bytes
        type: u8
      - id: value_num_bytes
        type: u8
      - id: key
        size: key_num_bytes
      - id: stub1
        contents: [0]
      - id: value
        size: value_num_bytes
      - id: stub2
        contents: [0]
  hashtree_descriptor:
    doc: A descriptor containing information about a dm-verity hashtree.
    seq:
      - id: dm_verity_version
        type: u4
      - id: image_size
        type: u8
      - id: tree_offset
        type: u8
      - id: tree_size
        type: u8
      - id: data_block_size
        type: u4
      - id: hash_block_size
        type: u4
      - id: fec_num_roots
        type: u4
      - id: fec_offset
        type: u8
      - id: fec_size
        type: u8
      - id: hash_algorithm
        size: 32
      - id: partition_name_len
        type: u4
      - id: salt_len
        type: u4
      - id: root_digest_len
        type: u4
      - id: flags
        type: u4
        enum: descriptor_hashtree_flags
      - id: reserved
        size: 60
      - id: partition_name
        type: str
        size: partition_name_len
        encoding: utf-8
      - id: salt
        size: salt_len
      - id: root_digest
        size: root_digest_len
  hash_descriptor:
    doc: A descriptor containing information about hash for an image.
    seq:
      - id: image_size
        type: u8
      - id: hash
        size: 32
      - id: partition_name_len
        type: u4
      - id: salt_len
        type: u4
      - id: digest_len
        type: u4
      - id: flags
        type: u4
        enum: descriptor_hash_flags
      - id: reserved
        size: 60
      - id: partition_name
        type: str
        size: partition_name_len
        encoding: utf-8
      - id: salt
        size: salt_len
      - id: digest
        size: digest_len
  kernel_cmdline_descriptor:
    doc: A descriptor containing information to be appended to the kernel command-line.
    seq:
      - id: flags
        type: u4
        enum: descriptor_cmdline_flags
      - id: kernel_cmdline_length
        type: u4
      - id: cmdline
        type: str
        size: kernel_cmdline_length
        encoding: utf-8
  chain_partition_descriptor:
    doc: A descriptor containing a pointer to signed integrity data stored on another partition.
    seq:
      - id: roolback_index_location
        type: u4
      - id: partition_name_len
        type: u4
      - id: public_key_len
        type: u4
      - id: reserved
        size: 64
      - id: partition_name
        type: str
        size: partition_name_len
        encoding: utf-8
      - id: public_key
        size: public_key_len
  vbmeta_descriptor:
    -webide-representation: '{tag}: {len_data:dec} bytes'
    seq:
      - id: tag
        type: u8
        enum: descriptor_types
      - id: len_data
        type: u8
      - id: data
        size: len_data
        type:
          switch-on: tag
          cases:
            descriptor_types::property: property_descriptor
            descriptor_types::hashtree: hashtree_descriptor
            descriptor_types::hash: hash_descriptor
            descriptor_types::kernel_cmdline: kernel_cmdline_descriptor
            descriptor_types::chain_partition: chain_partition_descriptor
  vbmeta_descriptors:
    seq:
      - id: descriptors
        type: vbmeta_descriptor
        repeat: eos
  vbmeta_authentication_data:
    instances:
      hash:
        pos: _root.header.hash_pos.offset
        size: _root.header.hash_pos.size
        doc: |
          A checksum of merged vbmeta header and auxiliary data blocks.
          contents: sha256(header + vbmeta_auxiliary_data)
          if: header.algorithm_type == algorithm_types::sha256_*
          contents: sha512(header + vbmeta_auxiliary_data)
          if: header.algorithm_type == algorithm_types::sha512_*
      signature:
        pos: _root.header.signature_pos.offset
        size: _root.header.signature_pos.size
  vbmeta_auxiliary_data:
    instances:
      public_key:
        pos: _root.header.public_key_pos.offset
        size: _root.header.public_key_pos.size
        type: vbmeta_public_key_header
      public_key_metadata:
        pos: _root.header.public_key_metadata_pos.offset
        size: _root.header.public_key_metadata_pos.size
      descriptors:
        pos: _root.header.descriptors_pos.offset
        size: _root.header.descriptors_pos.size
        type: vbmeta_descriptors

enums:
  algorithm_types:
    0: none
    1: sha256_rsa2048
    2: sha256_rsa4096
    3: sha256_rsa8192
    4: sha512_rsa2048
    5: sha512_rsa4096
    6: sha512_rsa8192
  descriptor_types:
    0: property
    1: hashtree
    2: hash
    3: kernel_cmdline
    4: chain_partition
  descriptor_cmdline_flags:
    1: use_only_if_hashtree_not_disabled
    2: use_only_if_hashtree_disabled
  descriptor_hashtree_flags:
    1: do_not_use_ab
  descriptor_hash_flags:
    1: do_not_use_ab
