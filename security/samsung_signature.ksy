meta:
  id: samsung_signature
  title: Samsung Crypto Signature for Android Firmware Images
  license: CC0-1.0
  encoding: utf-8

doc: |
  Signature that Samsung appends to Android image files.
  Only part of the fields reversed. A phone's bootloader
  checks images signature validity during boot.

types:
  samsung_signature:
    seq:
      - id: signer_name
        type: strz
        size: 16
      - id: signer_ver
        type: strz
        size: 16
      - id: firmware_ver
        type: strz
        size: 32
        doc: android firmware version string
      - id: firmware_timestamp
        type: strz
        size: 16
      - id: phone_model
        type: strz
        size: 32
      - id: board1
        type: strz
        size: 16
      - id: board2
        type: strz
        size: 16
