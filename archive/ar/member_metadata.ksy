meta:
  id: member_metadata
  title: Unix ar archive member metadata
  license: CC0-1.0
  imports:
    - space_padded_number
doc: |
  An archive member's metadata (timestamp, user and group ID, mode).
  
  Modern ar implementations support adding archive members in a reproducible mode: the original file's metadata is ignored, the timestamp, UID and GID are set to 0, and the mode to 644 (octal). This mode is usually enabled by default and must be explicitly disabled to store the real file metadata in the archive.
  
  Rarely, all fields in the metadata may be blank (only spaces). This is the case in particular for the '//' member (the long name list) of SysV archives.
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
    doc: |
      The member's mode bits (file type and permissions).
      
      In practice, archive members are always regular files (file type S_IFREG). Implementations of the ar tool generally do not add non-regular files to archives - such files will either be rejected (e. g. directories) or be treated as regular files (e. g. symlinks). Technically, the ar format does not prohibit members with non-regular file type bits, but such members have no agreed format or semantics.
      
      Archive members added in reproducible mode will have their mode set to 644 (octal). Note that in this case the file type bits are all zeroes, unlike in non-reproducible mode where the file type is explicitly S_IFREG. Both cases represent regular files and should be considered equivalent.
