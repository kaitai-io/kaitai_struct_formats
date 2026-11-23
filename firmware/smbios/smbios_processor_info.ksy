meta:
  id: smbios_processor_info
  endian: le
  imports:
    - strings
seq:
  - id: length
    type: u1
  - id: handle
    type: u2
  - id: socket_designation_index
    type: u1
  - id: processor_type
    type: u1
  - id: processor_family
    type: u1
  - id: processor_manufacturer_index
    type: u1
  - id: processor_id
    type: u8
  - id: processor_version_index
    type: u1
  - id: voltage
    type: u1
  - id: external_clock
    type: u2
  - id: max_speed
    type: u2
  - id: current_speed
    type: u2
  - id: status
    type: u1
  - id: processor_upgrade
    type: u1
  - id: l1_cache_handle
    type: u2
  - id: l2_cache_handle
    type: u2
  - id: l3_cache_handle
    type: u2
  - id: serial_number_index
    type: u1
  - id: asset_tag_index
    type: u1
  - id: part_number_index
    type: u1
  - id: core_count
    type: u1
  - id: core_enabled
    type: u1
  - id: thread_count
    type: u1
  - id: processor_characteristics
    type: u2
  - id: processor_family_2
    type: u2
  - id: core_count_2
    type: u2
  - id: core_enabled_2
    type: u2
  - id: thread_count_2
    type: u2
  - id: strings_array
    type: strings
    # Repeat until [00, 00] is matched, this mean, double terminator byte (0)
    # the trick here is _.string.length is the last string we have parsed and
    # strings_array has to contain at least 2 elements.
    repeat: until
    repeat-until: _.string.length == 1 and strings_array.size > 1
instances:
  socket_designation:
    value: strings_array[socket_designation_index - 1]
    if: socket_designation_index > 0
  processor_manufacturer:
    value: strings_array[processor_manufacturer_index - 1]
    if: processor_manufacturer_index > 0
  processor_version:
    value: strings_array[processor_version_index - 1]
    if: processor_version_index > 0
  serial_number:
    value: strings_array[serial_number_index - 1]
    if: serial_number_index > 0
  asset_tag:
    value: strings_array[asset_tag_index - 1]
    if: asset_tag_index > 0
  part_number:
    value: strings_array[part_number_index - 1]
    if: part_number_index > 0
