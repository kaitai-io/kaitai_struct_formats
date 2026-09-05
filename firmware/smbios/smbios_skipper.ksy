meta:
  id: smbios_skipper
  endian: le
  imports:
    - strings
seq:
  - id: length
    type: u1
  - id: rest
    size: length - 2
  - id: strings_array
    type: strings
    # Repeat until [00, 00] is matched, this mean, double terminator byte (0)
    # the trick here is _.string.length is the last string we have parsed and
    # strings_array has to contain at least 2 elements.
    repeat: until
    repeat-until: _.string.length == 1 and strings_array.size > 1
