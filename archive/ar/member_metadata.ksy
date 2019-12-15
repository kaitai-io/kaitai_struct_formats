meta:
  id: member_metadata
  title: Unix ar archive member metadata
  license: CC0-1.0
  imports:
    - space_padded_number
doc: An archive member's metadata (timestamp, user and group ID, mode).
seq:
  - id: modified_timestamp_raw
    -orig-id: ar_date
    type: space_padded_number(12, 10)
    doc: Unparsed version of modified_timestamp.
  - id: user_id_raw
    -orig-id: ar_uid
    type: space_padded_number(6, 10)
    doc: Unparsed version of user_id.
  - id: group_id_raw
    -orig-id: ar_gid
    type: space_padded_number(6, 10)
    doc: Unparsed version of group_id.
  - id: mode_raw
    -orig-id: ar_mode
    type: space_padded_number(8, 8)
    doc: Unparsed version of mode. (This number is stored in octal, unlike all other fields.)
instances:
  modified_timestamp:
    value: modified_timestamp_raw.value
    doc: The member's modification time, as a Unix timestamp.
  user_id:
    value: user_id_raw.value
    doc: The member's owner user ID.
  group_id:
    value: group_id_raw.value
    doc: The member's owner group ID.
  mode:
    value: mode_raw.value
    doc: The member's mode bits.
