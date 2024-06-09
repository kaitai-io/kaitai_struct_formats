meta:
  id: glibc_utmp
  title: utmp log file, Linux/glibc version
  xref:
    wikidata: Q3570128
  tags:
    - linux
    - log
  license: CC0-1.0
  endian: le
seq:
  - id: records
    size: 0x180
    type: record
    repeat: eos
types:
  record:
    seq:
      - id: ut_type
        type: s4
        doc: Type of login
        enum: entry_type
      - id: pid
        type: u4
        doc: Process ID of login process
      - id: line
        type: str
        encoding: UTF-8
        size: 32
        doc: Devicename
      - id: id
        type: str
        encoding: UTF-8
        size: 4
        doc: Inittab ID
      - id: user
        type: str
        encoding: UTF-8
        size: 32
        doc: Username
      - id: host
        type: str
        encoding: UTF-8
        size: 256
        doc: Hostname for remote login
      - id: exit
        type: u4
        doc: Exit status of a process marked as DEAD_PROCESS
      - id: session
        type: s4
        doc: Session ID, used for windowing
      - id: tv
        type: timeval
        doc: Time entry was made
      - id: addr_v6
        size: 16
        doc: Internet address of remote host
      - id: reserved
        size: 20
  timeval:
    seq:
      - id: sec
        type: s4
        doc: Seconds
      - id: usec
        type: s4
        doc: Microseconds
enums:
  entry_type:
    0: empty
    1: run_lvl
    2: boot_time
    3: new_time
    4: old_time
    5: init_process
    6: login_process
    7: user_process
    8: dead_process
    9: accounting
