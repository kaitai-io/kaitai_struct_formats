meta:
  id: efivar_signature_list
  title: UEFI Variable with Signature List
  license: CC0-1.0
  endian: le
doc: |
  Parse UEFI variables db and dbx that contain signatures, certificates and
  hashes. On a Linux system using UEFI, these variables are readable from
  /sys/firmware/efi/efivars/db-d719b2cb-3d3a-4596-a3bc-dad00e67656f,
  /sys/firmware/efi/efivars/dbDefault-8be4df61-93ca-11d2-aa0d-00e098032b8c,
  /sys/firmware/efi/efivars/dbx-d719b2cb-3d3a-4596-a3bc-dad00e67656f and
  /sys/firmware/efi/efivars/dbxDefault-8be4df61-93ca-11d2-aa0d-00e098032b8c.
  ("d719b2cb-3d3a-4596-a3bc-dad00e67656f" is defined as
  EFI_IMAGE_SECURITY_DATABASE_GUID and "8be4df61-93ca-11d2-aa0d-00e098032b8c"
  as EFI_GLOBAL_VARIABLE).
  Each file contains an EFI attribute (32-bit integer) followed by a list of
  EFI_SIGNATURE_LIST structures.
doc-ref: https://uefi.org/sites/default/files/resources/UEFI_Spec_2_8_final.pdf
seq:
  - id: var_attributes
    doc: Attributes of the UEFI variable
    type: efi_var_attr
  - id: signatures
    type: signature_list
    repeat: eos
types:
  signature_list:
    doc-ref: EFI_SIGNATURE_LIST
    seq:
      - id: signature_type
        doc: Type of the signature as a GUID
        -orig-id: SignatureType
        size: 0x10
      - id: len_signature_list
        doc: Total size of the signature list, including this header
        type: u4
        -orig-id: SignatureListSize
      - id: len_signature_header
        doc: Size of the signature header which precedes the array of signatures
        type: u4
        -orig-id: SignatureHeaderSize
      - id: len_signature
        doc: Size of each signature
        type: u4
        -orig-id: signatureSize
      - id: header
        doc: Header before the array of signatures
        -orig-id: SignatureHeader
        size: len_signature_header
      - id: signatures
        doc: An array of signatures
        -orig-id: Signatures
        size: len_signature
        repeat: expr
        repeat-expr: (len_signature_list - len_signature_header - 0x1c) / len_signature
        if: len_signature > 0
        type: signature_data
    instances:
      is_cert_sha256:
        doc: SHA-256 hash
        doc-ref: EFI_CERT_SHA256_GUID
        value: signature_type == [0x26, 0x16, 0xc4, 0xc1, 0x4c, 0x50, 0x92, 0x40, 0xac, 0xa9, 0x41, 0xf9, 0x36, 0x93, 0x43, 0x28]
      is_cert_rsa2048_key:
        doc: RSA-2048 key (only the modulus since the public key exponent is known to be 0x10001)
        doc-ref: EFI_CERT_RSA2048_GUID
        value: signature_type == [0xe8, 0x66, 0x57, 0x3c, 0x9c, 0x26, 0x34, 0x4e, 0xaa, 0x14, 0xed, 0x77, 0x6e, 0x85, 0xb3, 0xb6]
      is_cert_rsa2048_sha256:
        doc: RSA-2048 signature of a SHA-256 hash
        doc-ref: EFI_CERT_RSA2048_SHA256_GUID
        value: signature_type == [0x90, 0x61, 0xb3, 0xe2, 0x9b, 0x87, 0x3d, 0x4a, 0xad, 0x8d, 0xf2, 0xe7, 0xbb, 0xa3, 0x27, 0x84]
      is_cert_sha1:
        doc: SHA-1 hash
        doc-ref: EFI_CERT_SHA1_GUID
        value: signature_type == [0x12, 0xa5, 0x6c, 0x82, 0x10, 0xcf, 0xc9, 0x4a, 0xb1, 0x87, 0xbe, 0x01, 0x49, 0x66, 0x31, 0xbd]
      is_cert_rsa2048_sha1:
        doc: RSA-2048 signature of a SHA-1 hash
        doc-ref: EFI_CERT_RSA2048_SHA1_GUID
        value: signature_type == [0x4f, 0x44, 0xf8, 0x67, 0x43, 0x87, 0xf1, 0x48, 0xa3, 0x28, 0x1e, 0xaa, 0xb8, 0x73, 0x60, 0x80]
      is_cert_x509:
        doc: X.509 certificate
        doc-ref: EFI_CERT_X509_GUID
        value: signature_type == [0xa1, 0x59, 0xc0, 0xa5, 0xe4, 0x94, 0xa7, 0x4a, 0x87, 0xb5, 0xab, 0x15, 0x5c, 0x2b, 0xf0, 0x72]
      is_cert_sha224:
        doc: SHA-224 hash
        doc-ref: EFI_CERT_SHA224_GUID
        value: signature_type == [0x33, 0x52, 0x6e, 0x0b, 0x5c, 0xa6, 0xc9, 0x44, 0x94, 0x07, 0xd9, 0xab, 0x83, 0xbf, 0xc8, 0xbd]
      is_cert_sha384:
        doc: SHA-384 hash
        doc-ref: EFI_CERT_SHA384_GUID
        value: signature_type == [0x07, 0x53, 0x3e, 0xff, 0xd0, 0x9f, 0xc9, 0x48, 0x85, 0xf1, 0x8a, 0xd5, 0x6c, 0x70, 0x1e, 0x01]
      is_cert_sha512:
        doc: SHA-512 hash
        doc-ref: EFI_CERT_SHA512_GUID
        value: signature_type == [0xae, 0x0f, 0x3e, 0x09, 0xc4, 0xa6, 0x50, 0x4f, 0x9f, 0x1b, 0xd4, 0x1e, 0x2b, 0x89, 0xc1, 0x9a]
      is_cert_sha256_x509:
        doc: SHA256 hash of an X.509 certificate's To-Be-Signed contents, and a time of revocation
        doc-ref: EFI_CERT_X509_SHA256_GUID
        value: signature_type == [0x92, 0xa4, 0xd2, 0x3b, 0xc0, 0x96, 0x79, 0x40, 0xb4, 0x20, 0xfc, 0xf9, 0x8e, 0xf1, 0x03, 0xed]
      is_cert_sha384_x509:
        doc: SHA384 hash of an X.509 certificate's To-Be-Signed contents, and a time of revocation
        doc-ref: EFI_CERT_X509_SHA384_GUID
        value: signature_type == [0x6e, 0x87, 0x76, 0x70, 0xc2, 0x80, 0xe6, 0x4e, 0xaa, 0xd2, 0x28, 0xb3, 0x49, 0xa6, 0x86, 0x5b]
      is_cert_sha512_x509:
        doc: SHA512 hash of an X.509 certificate's To-Be-Signed contents, and a time of revocation
        doc-ref: EFI_CERT_X509_SHA512_GUID
        value: signature_type == [0x63, 0xbf, 0x6d, 0x44, 0x02, 0x25, 0xda, 0x4c, 0xbc, 0xfa, 0x24, 0x65, 0xd2, 0xb0, 0xfe, 0x9d]
      is_cert_der_pkcs7:
        doc: "DER-encoded PKCS #7 version 1.5 [RFC2315]"
        doc-ref: EFI_CERT_TYPE_PKCS7_GUID
        value: signature_type == [0x9d, 0xd2, 0xaf, 0x4a, 0xdf, 0x68, 0xee, 0x49, 0x8a, 0xa9, 0x34, 0x7d, 0x37, 0x56, 0x65, 0xa7]
  signature_data:
    doc-ref: EFI_SIGNATURE_DATA
    seq:
      - id: owner
        doc: An identifier which identifies the agent which added the signature to the list
        -orig-id: SignatureOwner
        size: 0x10
      - id: data
        doc: The format of the signature is defined by the SignatureType.
        -orig-id: SignatureData
        size-eos: true
  efi_var_attr:
    doc: Attributes of a UEFI variable
    seq:
      - id: enhanced_authenticated_access
        type: b1
        -orig-id: EFI_VARIABLE_ENHANCED_AUTHENTICATED_ACCESS
      - id: append_write
        type: b1
        -orig-id: EFI_VARIABLE_APPEND_WRITE
      - id: time_based_authenticated_write_access
        type: b1
        -orig-id: EFI_VARIABLE_TIME_BASED_AUTHENTICATED_WRITE_ACCESS
      - id: authenticated_write_access
        type: b1
        -orig-id: EFI_VARIABLE_AUTHENTICATED_WRITE_ACCESS
      - id: hardware_error_record
        type: b1
        -orig-id: EFI_VARIABLE_HARDWARE_ERROR_RECORD
      - id: runtime_access
        type: b1
        -orig-id: EFI_VARIABLE_RUNTIME_ACCESS
      - id: bootservice_access
        type: b1
        -orig-id: EFI_VARIABLE_BOOTSERVICE_ACCESS
      - id: non_volatile
        type: b1
        -orig-id: EFI_VARIABLE_NON_VOLATILE
      - id: reserved1
        doc: Reserved (unused) bits
        type: b24
