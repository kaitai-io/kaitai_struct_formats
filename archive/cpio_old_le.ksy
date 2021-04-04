meta:
  id: cpio_old_le
  title: cpio archive, old binary variant, little-endian
  file-extension: cpio
  xref:
    forensicswiki: Cpio
    justsolve: Cpio
    mime: application/x-cpio
    pronom: fmt/635
    wikidata: Q285296
  license: CC0-1.0
  endian: le
seq:
  - id: files
    type: file
    repeat: eos
types:
  file:
    seq:
      - id: header
        type: file_header
      - id: path_name
        size: header.path_name_size - 1
      - id: string_terminator
        contents: [0x00]
      - id: path_name_padding
        contents: [0x00]
        if: header.path_name_size % 2 == 1
      - id: file_data
        size: header.file_size.value
      - id: file_data_padding
        contents: [0x00]
        if: header.file_size.value % 2 == 1
      - id: end_of_file_padding
        size-eos: true
        if: path_name == [0x54, 0x52, 0x41, 0x49, 0x4c, 0x45, 0x52, 0x21, 0x21, 0x21] and header.file_size.value == 0
  file_header:
    seq:
      - id: magic
        contents: [0xC7, 0x71]
      - id: device_number
        type: u2
      - id: inode_number
        type: u2
      - id: mode
        type: u2
      - id: user_id
        type: u2
      - id: group_id
        type: u2
      - id: number_of_links
        type: u2
      - id: r_device_number
        type: u2
      - id: modification_time
        type: four_byte_unsigned_integer
      - id: path_name_size
        type: u2
      - id: file_size
        type: four_byte_unsigned_integer
  four_byte_unsigned_integer:
    seq:
      - id: most_significant_bits
        type: u2
      - id: least_significant_bits
        type: u2
    instances:
      value:
        value: least_significant_bits + (most_significant_bits << 16)
