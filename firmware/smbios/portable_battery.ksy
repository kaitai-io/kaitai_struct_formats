meta:
  id: portable_battery
  endian: le
  imports:
    - strings
seq:
  - id: length
    type: u1
  - id: handle
    type: u2
  - id: location_index
    type: u1
  - id: manufacturer_index
    type: u1
  - id: manufacture_date_index
    type: u1
  - id: serial_number_index
    type: u1
  - id: device_name_index
    type: u1
  - id: device_chemistry
    type: u1
  - id: design_capacity
    type: u2
  - id: design_voltaje
    type: u2
  - id: sbds_version_number_index
    type: u1
  - id: maximum_error_in_battery_data
    type: u1
  - id: sbds_serial_number
    type: u2
  - id: dbds_manufacture_date
    type: u2
  - id: sbds_device_chemistry_index
    type: u1
  - id: design_capacity_multiplier
    type: u1
  - id: oem_specific
    type: u4
  - id: strings_array
    type: strings
    # Repeat until [00, 00] is matched, this mean, double terminator byte (0)
    # the trick here is _.string.length is the last string we have parsed and
    # strings_array has to contain at least 2 elements.
    repeat: until
    repeat-until: _.string.length == 1 and strings_array.size > 1
instances:
  location:
    value: strings_array[location_index - 1]
    if: location_index > 0
  manufacturer:
    value: strings_array[manufacturer_index - 1]
    if: manufacturer_index > 0
  manufacture_date:
    value: strings_array[manufacture_date_index - 1]
    if: manufacture_date_index > 0
  serial_number:
    value: strings_array[serial_number_index - 1]
    if: serial_number_index > 0
  device_name:
    value: strings_array[device_name_index - 1]
    if: device_name_index > 0
  sbds_version_number:
    value: strings_array[sbds_version_number_index - 1]
    if: sbds_version_number_index > 0
  sbds_device_chemistry:
    value: strings_array[sbds_device_chemistry_index - 1]
    if: sbds_device_chemistry_index > 0


