meta:
  id: windows_evt_log
  title: Windows Event Log (EVT)
  file-extension: evt
  license: CC0-1.0
  endian: le
doc-ref: https://msdn.microsoft.com/en-us/library/bb309026(v=vs.85).aspx
doc: |
  EVT files are Windows Event Log files written by older Windows
  operating systems (2000, XP, 2003). They are used as binary log
  files by several major Windows subsystems and
  applications. Typically, several of them can be found in
  `%WINDIR%\system32\config` directory:

  * Application = `AppEvent.evt`
  * System = `SysEvent.evt`
  * Security = `SecEvent.evt`

  Alternatively, one can export any system event log as distinct .evt
  file using relevant option in Event Viewer application.

  A Windows application can submit an entry into these logs using
  [ReportEvent](https://msdn.microsoft.com/en-us/library/aa363679(v=vs.85).aspx)
  function of Windows API.

  Internally, EVT files consist of a fixed-size header and event
  records. There are several usage scenarios (non-wrapping vs wrapping
  log files) which result in slightly different organization of
  records.
seq:
  - id: header
    type: header
  - id: records
    type: record
    repeat: eos
types:
  header:
    doc-ref: https://msdn.microsoft.com/en-us/library/bb309024(v=vs.85).aspx
    seq:
      - id: len_header
        -orig-id: HeaderSize
        type: u4
        doc: Size of the header structure, must be 0x30.
      - id: magic
        -orig-id: Signature
        contents: "LfLe"
      - id: version_major
        -orig-id: MajorVersion
        type: u4
      - id: version_minor
        -orig-id: MinorVersion
        type: u4
      - id: ofs_start
        -orig-id: StartOffset
        type: u4
        doc: Offset of oldest record kept in this log file.
      - id: ofs_end
        -orig-id: EndOffset
        type: u4
        doc: Offset of EOF log record, which is a placeholder for new record.
      - id: cur_rec_idx
        -orig-id: CurrentRecordNumber
        type: u4
        doc: |
          Index of current record, where a new submission would be
          written to (normally there should to EOF log record there).
      - id: oldest_rec_idx
        -orig-id: OldestRecordNumber
        type: u4
        doc: Index of oldest record in the log file
      - id: len_file_max
        -orig-id: MaxSize
        type: u4
        doc: Total maximum size of the log file
      - id: flags
        -orig-id: Flags
        type: flags
      - id: retention
        -orig-id: Retention
        type: u4
      - id: len_header_2
        -orig-id: EndHeaderSize
        type: u4
        doc: Size of the header structure repeated again, and again it must be 0x30.
    types:
      flags:
        seq:
          - id: reserved
            type: b28
          - id: archive
            -orig-id: ELF_LOGFILE_ARCHIVE_SET
            type: b1
            doc: True if archive attribute has been set for this log file.
          - id: log_full
            -orig-id: ELF_LOGFILE_LOGFULL_WRITTEN            
            type: b1
            doc: True if last write operation failed due to log being full.
          - id: wrap
            -orig-id: ELF_LOGFILE_HEADER_WRAP
            type: b1
            doc: True if wrapping of record has occured.
          - id: dirty
            -orig-id: ELF_LOGFILE_HEADER_DIRTY
            type: b1
            doc: |
              True if write operation was in progress, but log file
              wasn't properly closed.
  record:
    doc-ref: https://msdn.microsoft.com/en-us/library/windows/desktop/aa363646(v=vs.85).aspx
    seq:
      - id: len_record
        -orig-id: Length
        type: u4
        doc: Size of whole record, including all headers, footers and data
      - id: type
        -orig-id: Reserved
        type: u4
        doc: |
          Type of record. Normal log records specify "LfLe"
          (0x654c664c) in this field, cursor records use 0x11111111.
      - id: body
        size: len_record - 12
        type:
          switch-on: type
          cases:
            0x654c664c: record_body
            0x11111111: cursor_record_body
        doc: |
          Record body interpretation depends on type of record. Body
          size is specified in a way that it won't include a 8-byte
          "header" (`len_record` + `type`) and a "footer"
          (`len_record2`).
      - id: len_record2
        type: u4
        doc: Size of whole record again.
  record_body:
    doc-ref: https://msdn.microsoft.com/en-us/library/windows/desktop/aa363646(v=vs.85).aspx
    seq:    
      - id: idx
        -orig-id: RecordNumber
        type: u4
        doc: Index of record in the file.
      - id: time_generated
        -orig-id: TimeGenerated
        type: u4
        doc: Time when this record was generated, POSIX timestamp format.
      - id: time_written
        -orig-id: TimeWritten
        type: u4
        doc: Time when thsi record was written into the log file, POSIX timestamp format.
      - id: event_id
        -orig-id: EventID
        type: u4
        doc: |
          Identifier of an event, meaning is specific to particular
          source of events / event type.
      - id: event_type
        -orig-id: EventType
        type: u2
        enum: event_types
        doc: Type of event.
        doc-ref: https://msdn.microsoft.com/en-us/library/windows/desktop/aa363662(v=vs.85).aspx
      - id: num_strings
        -orig-id: NumStrings
        type: u2
        doc: Number of strings present in the log.
      - id: event_category
        -orig-id: EventCategory
        type: u2
        doc-ref: https://msdn.microsoft.com/en-us/library/windows/desktop/aa363649(v=vs.85).aspx
      - id: reserved
        -orig-id: ReservedFlags, ClosingRecordNumber
        size: 6
      - id: ofs_strings
        -orig-id: StringOffset
        type: u4
        doc: Offset of strings present in the log
      - id: len_user_sid
        -orig-id: UserSidLength
        type: u4
      - id: ofs_user_sid
        -orig-id: UserSidOffset
        type: u4
      - id: len_data
        -orig-id: DataLength
        type: u4
      - id: ofs_data
        -orig-id: DataOffset
        type: u4
    instances:
#      strings:
#        pos: ofs_strings - 8
      user_sid:
        pos: ofs_user_sid - 8
        size: len_user_sid
      data:
        pos: ofs_data - 8
        size: len_data
    enums:
      event_types:
        1: error
        2: audit_failure
        3: audit_success
        4: info
        5: warning
  cursor_record_body:
    doc-ref: 'http://www.forensicswiki.org/wiki/Windows_Event_Log_(EVT)#Cursor_Record'
    seq:
      - id: magic
        contents: [0x22, 0x22, 0x22, 0x22, 0x33, 0x33, 0x33, 0x33, 0x44, 0x44, 0x44, 0x44]
      - id: ofs_first_record
        type: u4
      - id: ofs_next_record
        type: u4
      - id: idx_next_record
        type: u4
      - id: idx_first_record
        type: u4
