meta:
  id: bios_information
  endian: le
  imports:
    - strings
seq:
  - id: length
    type: u1
  - id: handle_index
    type: u2
  - id: vendor_index
    type: u1
  - id: bios_version
    type: u1
  - id: bios_starting_address_segment
    type: u2
  - id: bios_release_date_index
    type: u1
  - id: bios_rom_size
    type: u1
  - id: bios_characteristics
    type: u8
  - id: bios_characteristics_ext_bytes
    size: length - 0x12
  - id: strings_array
    type: strings
    # Repeat until [00, 00] is matched, this mean, double terminator byte (0)
    # the trick here is _.string.length is the last string we have parsed and
    # strings_array has to contain at least 2 elements.
    repeat: until
    repeat-until: _.string.length == 1 and strings_array.size > 1
instances:
  handle:
    value: strings_array[handle_index - 1]
    if: handle_index > 0
  vendor:
    value: strings_array[vendor_index - 1]
    if: vendor_index > 0
  bios_release_date:
    value: strings_array[bios_release_date_index - 1]
    if: bios_release_date_index > 0

