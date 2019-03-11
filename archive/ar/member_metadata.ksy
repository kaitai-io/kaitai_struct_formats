meta:
  id: member_metadata
  title: Unix ar archive member metadata
  license: CC0-1.0
  imports:
    - space_padded_number
doc: An archive member's metadata (timestamp, user and group ID, mode).
seq:
  - id: modified_timestamp
    -orig-id: ar_date
    type: space_padded_number(12, 10)
    doc: The member's modification time, as a Unix timestamp.
  - id: user_id
    -orig-id: ar_uid
    type: space_padded_number(6, 10)
    doc: The member's owner user ID.
  - id: group_id
    -orig-id: ar_gid
    type: space_padded_number(6, 10)
    doc: The member's owner group ID.
  - id: mode
    -orig-id: ar_mode
    type: space_padded_number(8, 8)
    doc: The member's mode bits (in octal, unlike all other numerical fields).
