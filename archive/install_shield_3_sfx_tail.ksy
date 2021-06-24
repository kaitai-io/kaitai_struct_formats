meta:
  id: install_shield_3_sfx_tail
  title: InstallShield 3 self-extracting installer tail data
  license: MIT
  imports:
    - /common/dos_datetime_backwards
  endian: le
doc: |
  The data format used in InstallShield 3 self-extracting installers.
  These installers start with a normal Microsoft PE executable,
  which is directly followed by the data in this format.

  This is only a very thin wrapper around ZIP files.
  These ZIP files can also be carved from the installer
  using a program that can search for ZIP data embedded in a file,
  such as 7-Zip in "parser mode" (type `#`) or Binwalk.
doc-ref: http://kannegieser.net/veit/quelle/stix_src.arj # STIX.PAS, STSFX.PAS
seq:
  - id: files
    type: file
    repeat: eos
instances:
  path_encryption_key:
    value: '[0xb3, 0xf2, 0xea, 0x1f, 0xaa, 0x27, 0x66, 0x13]'
types:
  file:
    seq:
      - id: len_path_encrypted
        type: u4
        doc: Byte length of the encrypted path name.
      - id: path_encrypted
        size: len_path_encrypted
        doc: |
          Path name for this file,
          encrypted using a relatively simple algorithm.
          The path name can be decrypted bytewise using the formula
          `byte_rot_right((path_encrypted[i] ^ path_encryption_key[7-(i%8)]), 7-(i%8)) ^ path_encryption_key[i%8]`,
          where `i` is the (0-based) index of the byte in question.
      - id: modified
        type: dos_datetime_backwards
        doc: Modification date/time of the file.
      - id: len_data
        type: u4
        doc: Byte length of the zipped file.
      - id: data
        size: len_data
        doc: |
          The zipped file.
          The data should be a ZIP archive containing exactly one file
          which should be located at top level
          and whose name should match the one stored in path_encrypted
          (without any leading directories).
