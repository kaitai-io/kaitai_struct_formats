meta:
  id: aix_utmp
  title: utmp log file, IBM AIX version
  license: CC0-1.0
  endian: be
doc: |
  This spec can be used to parse utmp, wtmp and other similar as created by
  IBM AIX. Spec is based on IBM Knowledge Base article:
  https://www.ibm.com/support/knowledgecenter/en/ssw_aix_71/com.ibm.aix.files/utmp.h.htm
seq:
  - id: records
    type: record
    repeat: eos
types:
  record:
    seq:
    - id: ut_user
      doc: User login name
      size: 256
      type: str
      encoding: utf-8
    - id: ut_id
      doc: /etc/inittab id
      size: 14
      type: str
      encoding: utf-8
    - id: ut_line
      doc: device name (console, lnxx)
      size: 64
      type: str
      encoding: utf-8
    - id: ut_pid
      type: u8
      doc: process id
    - id: ut_type
      type: s2
      doc: Type of login
      enum: entry_type
    - id: ut_time
      type: s8
      doc: time entry was made
    - id: ut_exit
      type: exit_status
      doc: the exit status of a process marked as DEAD PROCESS
    - id: ut_host
      size: 256
      doc: host name
      type: str
      encoding: utf-8
    - id: dbl_word_pad
      type: s4
    - id: reserved_a
      size: 8
    - id: reserved_v
      size: 24
  exit_status:
    seq:
    - id: e_termination
      type: s2
      doc: process termination status
    - id: e_exit
      type: s2
      doc: process exit status
enums:
  entry_type:
    0: empty
    1: run_lvl
    2: boot_time
    3: old_time
    4: new_time
    5: init_process
    6: login_process
    7: user_process
    8: dead_process
    9: accounting