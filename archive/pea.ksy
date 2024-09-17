meta:
  id: pea
  title: PeaZIP archive file
  file-extension: pea
  application:
    - PeaZIP
    - PEA
    - UnPEA
  xref:
    wikidata: Q1275912
  endian: le
  license: Unlicense
doc: |
  Format for PeaZIP archiver. WARNING: don't design formats like this!
doc-ref:
  - https://github.com/giorgiotani/PeaZip/releases

seq:
  - id: archive_header
    type: archive_header
  - id: stream_header
    type: stream_header
  - id: compression_buffer_size
    type: u4
    if: stream_header.compression_algo.compress
  - id: crypto_subheader
    type: crypto_subheader
    if: stream_header.crypto_algo.require_password

types:
  archive_header:
    -orig-id: pea_archive_hdr
    seq:
      - id: signature
        contents: [0xEA]
      - id: format_version
        type: u1
        -orig-id: PEA_FILEFORMAT_VER
      - id: format_revision
        type: u1
        -orig-id: PEA_FILEFORMAT_REV
      - id: ecc_algo_archive
        type: u1
        enum: crypto_and_ecc
      - id: ecc_algo_volume
        type: u1
        enum: crypto_and_ecc
      - id: os
        -orig-id: get_OS
        type: u1
      - id: date_time_encoding
        -orig-id: get_system_datetimeencoding
        type: u1
      - id: string_encoding
        type: u1 # 1 ansi
      - id: cpu
        -orig-id: get_CPUe
        type: cpu_type
      - id: reserved0
        type: u1
  stream_header:
    seq:
      - id: trigger
        contents: [0, 0]
      - id: pea_pod_signature
        contents: ["POD", 0]
      - id: compression_algo
        type: compression_algo
        -orig-id: encode_compression
      - id: ecc_scheme_streamwide
        type: u1
        enum: crypto_and_ecc
      - id: ecc_algo_stream
        type: u1
        enum: crypto_and_ecc
      - id: ecc_algo_object
        type: u1
        enum: crypto_and_ecc
      - id: crypto_algo
        type: encryption_type
    types:
      compression_algo:
        seq:
          - id: algo
            type: u1
        instances:
          compress:
            value: algo > 0
          deflate_level:
            value: algo * 3
            if: compress
  cpu_type:
    seq:
      - id: is_big_endian
        type: b1
      - id: instruction_set
        type: b7
        enum: cpu
    enums:
      cpu:
        0x00: unknown
        0x01: generic_32_bit
        0x02: generic_64_bit
        0x11: i8086
        0x12: i8087
        0x13: i386
        0x21: x86_64
        0x31: motorolla_68k
        0x32: motorolla_68020
        0x33: motorolla_68
        0x34: sparc
        0x35: alpha
        0x35: power_pc
  
  crypto_subheader:
    seq:
      - id: fcs_sig
        -orig-id: FCAsig
        type: u1
      - id: flags
        type: u1
      - id: salts
        type: u4le
        repeat: expr
        repeat-expr: 3
      - id: pv_ver
        type: u2le

  encryption_type:
    seq:
      - id: algo
        type: u1
        enum: crypto_and_ecc
    instances:
      require_password:
        value: algo==crypto_and_ecc::eax256 or algo==crypto_and_ecc::tf256 or algo==crypto_and_ecc::sp256 or algo==crypto_and_ecc::eax or algo==crypto_and_ecc::tf or algo==crypto_and_ecc::sp or algo==crypto_and_ecc::hmac
enums:
  crypto_and_ecc:
    0x00:
      id: none
      -orig-id: NOALGO
    0x01:
      id: adler32
      -orig-id: ADLER32
    0x02:
      id: crc32
      -orig-id: CRC32
    0x03:
      id: crc64
      -orig-id: CRC64
    0x10:
      id: md5
      -orig-id: MD5
    0x11:
      id: ripemd160
      -orig-id: RIPEMD160
    0x12:
      id: sha1
      -orig-id: SHA1
    0x13:
      id: sha256
      -orig-id: SHA256
    0x14:
      id: sha512
      -orig-id: SHA512
    0x15:
      id: whirlpool
      -orig-id: WHIRLPOOL
    0x16:
      id: sha3_256
      -orig-id: SHA3_256
    0x17:
      id: sha3_512
      -orig-id: SHA3_512
    0x30:
      id: hmac
      -orig-id: HMAC
    0x31:
      id: eax
      -orig-id: EAX
    0x32:
      id: tf
      -orig-id: TF
    0x33:
      id: sp
      -orig-id: SP
    0x41:
      id: eax256
      -orig-id: EAX256
    0x42:
      id: tf256
      -orig-id: TF256
    0x43:
      id: sp256
      -orig-id: SP256
  os:
    0x00: unknown
    0x10:
      id: generic_windows
      -orig-id: MSWINDOWS
    0x11: win_32
    0x12: win_64
    0x13: win_ce
    0x21: go32v2
    0x22: os2
    0x30:
      id: generic_nix
      -orig-id: UNIX
    0x31: free_bsd
    0x32: net_bsd
    0x33: linux
    0x34: beos
    0x35: qnx
    0x36: sunos
    0x36: sunos
    0x37: darwin
    0x51: amiga
    0x52:
      id: atari_tos
      -orig-id: ATARI
    0x52:
      id: mac_classic
      -orig-id: MAC
    0x54:
      id: palm_os
      -orig-id: PALMOS
  date_time_encoding:
    0x00: unknown
    0x10: windows
    0x30: unix
    0x53: mac_classic
