meta:
  id: game_4x4_evolution_pod
  file-extension: pod
  application: 4x4 Evolution
  license: CC0-1.0
  endian: le
doc-ref: 'https://www.watto.org/specs.html?specs=Archive_POD'
seq:
  - id: header
    type: archive_header
  - id: details_directory
    type: details_directory
    repeat: expr
    repeat-expr: header.num_files
types:
  archive_header:
    seq:
      - id: num_files
        type: u4
        doc: The number of files in the archive
      - id: description
        type: str
        size: 80
        terminator: 0
        encoding: UTF-8
        doc: A description for the archive
  details_directory:
    seq:
      - id: filename
        type: str
        size: 32
        terminator: 0
        encoding: UTF-8
      - id: length
        type: u4
        doc: The length of the file data
      - id: offset
        type: u4
        doc: The offset to the file data in the archive
    instances:
      file_data:
        pos: offset
        size: length