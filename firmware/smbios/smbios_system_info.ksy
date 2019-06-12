meta:
  id: system_information
  endian: le
  imports:
    - strings
seq:
  - id: length
    type: u1
  - id: handle
    type: u2
  - id: manufacturer_index
    type: u1
  - id: product_name_index
    type: u1
  - id: version_index
    type: u1
  - id: serial_number_index
    type: u1
  - id: uuid
    size: 16
  - id: wake_up_type
    type: u1
  - id: sku_number_index
    type: u1
  - id: family_index
    type: u1
  - id: strings_array
    type: strings
    repeat: until
    repeat-until: _.string.length == 1 and strings_array.size > 1
instances:
  manufacturer:
    value: strings_array[manufacturer_index - 1]
    if: manufacturer_index > 0
  product_name:
    value: strings_array[product_name_index - 1]
    if: product_name_index > 0
  version:
    value: strings_array[version_index - 1]
    if: version_index > 0
  serial_number:
    value: strings_array[serial_number_index - 1]
    if: serial_number_index > 0
  sku_number:
    value: strings_array[sku_number_index - 1]
    if: sku_number_index > 0
  family:
    value: strings_array[family_index - 1]
    if: family_index > 0


