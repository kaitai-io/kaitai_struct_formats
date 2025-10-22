meta:
  id: tpm_linux_bios_measurements
  title: TPM 2.0 BIOS measurements exposed by Linux kernel
  license: CC0-1.0
  endian: le
doc: |
  Linux kernel exposes the TPM 2.0 eventlog in a dedicated file,
  `/sys/kernel/security/tpm0/binary_bios_measurements`.
  This eventlog describes how the PCR (Platform Configuration Registers) were
  extended. It can either consist in:

  * a list of `tdTCG_PCR_EVENT` with SHA1 digests for each event which went to
    each PCR (this is the older format, sometimes referred to as
    "TPM 1.2 eventlog")
  * or a header and a list of `tdTCG_PCR_EVENT2` with several digests for each
    event (for example SHA1 and SHA256), which is called a Crypto Agile Log and
    has been introduced with TPM 2.0.

  The header of the Crypto Agile Log is a `tdTCG_EfiSpecIdEventStruct` structure
  embedded into a `tdTCG_PCR_EVENT` (not `tdTCG_PCR_EVENT2`). Among other
  things, this header specifies the size of the digest of every algorithm which
  is used in the eventlog.
doc-ref: https://trustedcomputinggroup.org/resource/tcg-efi-protocol-specification/
seq:
  - id: first_event
    type: tcg_pcr_event
    doc: First event of the eventlog
  - id: events2
    type: tcg_pcr_event2
    repeat: eos
    if: is_agile_log
    doc: Events of the Crypto Agile Log
instances:
  is_agile_log:
    value: first_event.pcr_index == tcg_pcr_index::pcr0_crtm_and_bios and first_event.event_type == tcg_event_type::no_action and first_event.digest.value == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  specid:
    pos: 0x20
    size: first_event.len_event
    type: tcg_efi_specid_event
    if: is_agile_log
    doc: Event Log Header
  events1:
    pos: 0
    type: tcg_pcr_event
    repeat: eos
    if: not is_agile_log
    doc: Events on TPM with only SHA1 digests
types:
  tcg_pcr_event:
    doc: SHA1 Event Log Entry
    doc-ref: tdTCG_PCR_EVENT
    seq:
      - id: pcr_index
        -orig-id: PCRIndex
        type: u4
        enum: tcg_pcr_index
        doc: Platform Configuration Register which is extended
      - id: event_type
        -orig-id: EventType
        type: u4
        enum: tcg_event_type
      - id: digest
        -orig-id: Digest
        type: sha1_digest
        doc: Value extended into PCR (SHA1 digest)
      - id: len_event
        -orig-id: EventSize
        type: u4
      - id: event
        -orig-id: Event
        size: len_event

  tcg_pcr_event2:
    doc: Crypto Agile Log Entry
    doc-ref: tdTCG_PCR_EVENT2
    seq:
      - id: pcr_index
        -orig-id: PCRIndex
        type: u4
        enum: tcg_pcr_index
        doc: Platform Configuration Register which is extended
      - id: event_type
        -orig-id: EventType
        type: u4
        enum: tcg_event_type
      - id: num_digests
        -orig-id: Count
        type: u4
      - id: digests
        -orig-id: Digests
        type: tpmt_ha
        repeat: expr
        repeat-expr: num_digests
        doc: List of digests extended to
      - id: len_event
        -orig-id: EventSize
        type: u4
      - id: event
        -orig-id: Event
        size: len_event

  tpmt_ha:
    doc: Digest with an identified hashing algorithm
    doc-ref: tdTPMT_HA
    seq:
      - id: alg_id
        -orig-id: AlgorithmId
        type: u2
        enum: tpm_alg_id
        doc: Identifier of hashing algorithm
      - id: digest
        -orig-id: Digest
        type:
          switch-on: alg_id
          cases:
            'tpm_alg_id::sha1': sha1_digest
            'tpm_alg_id::sha256': sha256_digest
            'tpm_alg_id::sha384': sha384_digest
            'tpm_alg_id::sha512': sha512_digest

  sha1_digest:
    doc: SHA1 digest
    seq:
      - id: value
        size: 20

  sha256_digest:
    doc: SHA256 digest
    seq:
      - id: value
        size: 32

  sha384_digest:
    doc: SHA384 digest
    seq:
      - id: value
        size: 48

  sha512_digest:
    doc: SHA512 digest
    seq:
      - id: value
        size: 64

  tcg_efi_specid_event:
    doc: TPM 2.0 Event Log Header
    doc-ref: tdTCG_EfiSpecIdEventStruct
    seq:
      - id: magic
        -orig-id: signature
        size: 16
        contents: [Spec ID Event03, 0]
      - id: platform_class
        -orig-id: platformClass
        type: u4
      - id: spec_version_minor
        -orig-id: specVersionMinor
        type: u1
      - id: spec_version_major
        -orig-id: specVersionMajor
        type: u1
      - id: spec_errata
        -orig-id: specErrata
        type: u1
      - id: len_uintn
        -orig-id: uintnSize
        type: u1
        doc: Size of the UINTN fields used in various data structures
      - id: num_algorithms
        -orig-id: numberOfAlgorithms
        type: u4
        doc: Number of hashing algorithms used in this event log (except the first event)
      - id: digest_sizes
        -orig-id: digestSizes
        type: tcg_efi_specid_event_algorithm_size
        repeat: expr
        repeat-expr: num_algorithms
      - id: len_vendor_info
        -orig-id: vendorInfoSize
        type: u1
      - id: vendor_info
        -orig-id: vendorInfo
        size: len_vendor_info
        doc: Provided for use by the BIOS implementer

  tcg_efi_specid_event_algorithm_size:
    doc-ref: tdTCG_EfiSpecIdEventAlgorithmSize
    seq:
      - id: algorithm
        -orig-id: algorithmId
        type: u2
        enum: tpm_alg_id
        doc: TCG defined hashing algorithm ID
      - id: len
        -orig-id: digestSize
        type: u2
        doc: size of the digest for the respective hashing algorithm

enums:
  tcg_pcr_index:
    0:
      id: pcr0_crtm_and_bios
      doc: PCR for CRTM (Core Root of Trust of Measurement), BIOS and Host Platform Extensions
    1:
      id: pcr1_bios_config
      doc: PCR for Host Platform Configuration (including BIOS configuration)
    2:
      id: pcr2_option_rom_code
      doc: PCR for Option ROM Code
    3:
      id: pcr3_option_rom_config
      doc: PCR for Option ROM Configuration and Data
    4:
      id: pcr4_ipl_code
      doc: PCR for Initial Program Load (IPL) Code (eg. the 0x1b8 first bytes of a MBR)
    5:
      id: pcr5_ipl_data
      doc: PCR for Initial Program Load (IPL) Code and Configuration Data
    6:
      id: pcr6_state_transition_and_wake_events
      doc: PCR for State Transition and Wake Events
    7:
      id: pcr7_host_platform_manufacturer_control
    8:
      id: pcr8_operating_system
    9:
      id: pcr9_operating_system
    10:
      id: pcr10_operating_system
    11:
      id: pcr11_operating_system
    12:
      id: pcr12_operating_system
    13:
      id: pcr13_operating_system
    14:
      id: pcr14_operating_system
    15:
      id: pcr15_operating_system
    16:
      id: pcr16_debug
    17:
      id: pcr17_trusted_os_locality_4
    18:
      id: pcr18_trusted_os_locality_3
    19:
      id: pcr19_trusted_os_locality_2
    20:
      id: pcr20_trusted_os_locality_1
    21:
      id: pcr21_trusted_os
    22:
      id: pcr22_trusted_os
    23:
      id: pcr23_application_specific

  tcg_event_type:
    0x00000000:
      id: preboot_cert
      -orig-id: EV_PREBOOT_CERT
    0x00000001:
      id: post_code
      -orig-id: EV_POST_CODE
    0x00000003:
      id: no_action
      -orig-id: EV_NO_ACTION
    0x00000004:
      id: separator
      -orig-id: EV_SEPARATOR
    0x00000005:
      id: action
      -orig-id: EV_ACTION
    0x00000006:
      id: event_tag
      -orig-id: EV_EVENT_TAG
    0x00000007:
      id: s_ctrm_contents
      -orig-id: EV_S_CRTM_CONTENTS
    0x00000008:
      id: s_ctrm_version
      -orig-id: EV_S_CRTM_VERSION
    0x00000009:
      id: cpu_microcode
      -orig-id: EV_CPU_MICROCODE
    0x0000000a:
      id: platform_config_flags
      -orig-id: EV_PLATFORM_CONFIG_FLAGS
    0x0000000b:
      id: table_of_devices
      -orig-id: EV_TABLE_OF_DEVICES
    0x0000000c:
      id: compact_hash
      -orig-id: EV_COMPACT_HASH
    0x0000000d:
      id: ipl
      -orig-id: EV_IPL
    0x0000000e:
      id: ipl_partition_data
      -orig-id: EV_IPL_PARTITION_DATA
    0x0000000f:
      id: nonhost_code
      -orig-id: EV_NONHOST_CODE
    0x00000010:
      id: nonhost_config
      -orig-id: EV_NONHOST_CONFIG
    0x00000011:
      id: nonhost_info
      -orig-id: EV_NONHOST_INFO
    0x00000012:
      id: omit_boot_device_events
      -orig-id: EV_OMIT_BOOT_DEVICE_EVENTS
    0x80000001:
      id: efi_variable_driver_config
      -orig-id: EV_EFI_VARIABLE_DRIVER_CONFIG
    0x80000002:
      id: efi_variable_boot
      -orig-id: EV_EFI_VARIABLE_BOOT
    0x80000003:
      id: efi_boot_services_application
      -orig-id: EV_EFI_BOOT_SERVICES_APPLICATION
    0x80000004:
      id: efi_boot_services_driver
      -orig-id: EV_EFI_BOOT_SERVICES_DRIVER
    0x80000005:
      id: efi_runtime_services_driver
      -orig-id: EV_EFI_RUNTIME_SERVICES_DRIVER
    0x80000006:
      id: efi_gpt_event
      -orig-id: EV_EFI_GPT_EVENT
    0x80000007:
      id: efi_action
      -orig-id: EV_EFI_ACTION
    0x80000008:
      id: efi_platform_firmware_blob
      -orig-id: EV_EFI_PLATFORM_FIRMWARE_BLOB
    0x80000009:
      id: efi_handoff_tables
      -orig-id: EV_EFI_HANDOFF_TABLES
    0x80000010:
      id: efi_hcrtm_event
      -orig-id: EV_EFI_HCRTM_EVENT
    0x800000e0:
      id: efi_variable_authority
      -orig-id: EV_EFI_VARIABLE_AUTHORITY

  tpm_alg_id:
    0x0000:
      id: error
      -orig-id: TPM_ALG_ERROR
    0x0001:
      id: rsa
      -orig-id: TPM_ALG_RSA
    0x0004:
      id: sha1
      -orig-id: TPM_ALG_SHA1
    0x0005:
      id: hmac
      -orig-id: TPM_ALG_HMAC
    0x0006:
      id: aes
      -orig-id: TPM_ALG_AES
    0x0007:
      id: mgf1
      -orig-id: TPM_ALG_MGF1
    0x0008:
      id: keyedhash
      -orig-id: TPM_ALG_KEYEDHASH
    0x000a:
      id: xor
      -orig-id: TPM_ALG_XOR
    0x000b:
      id: sha256
      -orig-id: TPM_ALG_SHA256
    0x000c:
      id: sha384
      -orig-id: TPM_ALG_SHA384
    0x000d:
      id: sha512
      -orig-id: TPM_ALG_SHA512
    0x0010:
      id: "null"
      -orig-id: TPM_ALG_NULL
    0x0012:
      id: sm3_256
      -orig-id: TPM_ALG_SM3_256
    0x0013:
      id: sm4
      -orig-id: TPM_ALG_SM4
    0x0014:
      id: rsassa
      -orig-id: TPM_ALG_RSASSA
    0x0015:
      id: rsaes
      -orig-id: TPM_ALG_RSAES
    0x0016:
      id: rsapss
      -orig-id: TPM_ALG_RSAPSS
    0x0017:
      id: oaep
      -orig-id: TPM_ALG_OAEP
    0x0018:
      id: ecdsa
      -orig-id: TPM_ALG_ECDSA
    0x0019:
      id: ecdh
      -orig-id: TPM_ALG_ECDH
    0x001a:
      id: ecdaa
      -orig-id: TPM_ALG_ECDAA
    0x001b:
      id: sm2
      -orig-id: TPM_ALG_SM2
    0x001c:
      id: ecschnorr
      -orig-id: TPM_ALG_ECSCHNORR
    0x001d:
      id: ecmqv
      -orig-id: TPM_ALG_ECMQV
    0x0020:
      id: kdf1_sp800_56a
      -orig-id: TPM_ALG_KDF1_SP800_56a
    0x0021:
      id: kdf2
      -orig-id: TPM_ALG_KDF2
    0x0022:
      id: kdf1_sp800_108
      -orig-id: TPM_ALG_KDF1_SP800_108
    0x0023:
      id: ecc
      -orig-id: TPM_ALG_ECC
    0x0025:
      id: symcipher
      -orig-id: TPM_ALG_SYMCIPHER
    0x0040:
      id: ctr
      -orig-id: TPM_ALG_CTR
    0x0041:
      id: ofb
      -orig-id: TPM_ALG_OFB
    0x0042:
      id: cbc
      -orig-id: TPM_ALG_CBC
    0x0043:
      id: cfb
      -orig-id: TPM_ALG_CFB
    0x0044:
      id: ecb
      -orig-id: TPM_ALG_ECB
