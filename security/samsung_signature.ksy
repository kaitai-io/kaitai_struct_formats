meta:
  id: samsung_signature
  title: Samsung Crypto Signature for Android Firmware Images
  license: CC0-1.0

doc: |
  Signature that samsung appends to android images files.
  Only part of the fields reversed. A phone's bootloader
  checks images signature validity during boot.

types:
  samsung_signature:
    seq:
      - id: signer_name
        type: strz
        size: 16
        encoding: ASCII
      - id: signer_ver
        type: strz
        size: 16
        encoding: ASCII
      - id: firmware_ver
        type: strz
        size: 32
        encoding: ASCII
        doc: android firmware version string
      - id: firmware_timestamp
        type: strz
        size: 16
        encoding: ASCII
      - id: phone_model
        type: strz
        size: 32
        encoding: ASCII
      - id: board1
        type: strz
        size: 16
        encoding: ASCII
      - id: board2
        type: strz
        size: 16
        encoding: ASCII
