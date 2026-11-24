meta:
  id: nix_nar
  title: Nix Archive (NAR)
  file-extension: nar
  license: MIT
  endian: le
doc: |
    Nix Archive (NAR) format. A simple, reproducible binary archive
    format used by the Nix package manager to serialize file system objects.
doc-ref: https://github.com/NixOS/nix/blob/88907193c54fcd5184cf59d14b693188e2875168/doc/manual/source/protocols/nix-archive/index.md Git tag "2.36.0"

seq:
  - id: magic
    type: padded_str
    valid:
      expr: _.body == 'nix-archive-1'
    doc: "Magic string, must be 'nix-archive-1'."
  - id: root_node
    type: node
    doc: "The root of the archive, which is always a single node."

types:
  padded_str:
    doc: |
      A string, prefixed with its length (u8le) and
      padded with null bytes to the next 8-byte boundary.
    seq:
      - id: len_str
        type: u8
      - id: body
        size: len_str
        type: str
        encoding: ASCII
      - id: padding
        size: (8 - (len_str % 8)) % 8

  padded_bytes:
    doc: |
      A byte sequence, prefixed with its length (u8le) and
      padded with null bytes to the next 8-byte boundary.
    seq:
      - id: len_body
        type: u8
      - id: body
        size: len_body
      - id: padding
        size: (8 - (len_body % 8)) % 8

  node:
    doc: "A single filesystem node (file, directory, or symlink)."
    seq:
      - id: open_paren
        type: padded_str
        valid:
          expr: _.body == '('
        doc: "Must be '(', a token starting the node definition."
      - id: type_key
        type: padded_str
        valid:
          expr: _.body == 'type'
        doc: "Must be 'type'."
      - id: type_val
        type: padded_str
        valid:
          # https://github.com/NixOS/nix/blob/88907193c54fcd5184cf59d14b693188e2875168/src/libutil/archive.cc#L289 (Git tag "2.36.0")
          expr: _.body == 'regular' or _.body == 'directory' or _.body == 'symlink'
        doc: "The type of the node: 'regular', 'directory', or 'symlink'."
      - id: body
        type:
          switch-on: type_val.body
          cases:
            "'directory'": type_directory
            "'regular'": type_regular
            "'symlink'": type_symlink
      - id: close_paren
        type: padded_str
        valid:
          expr: _.body == ')'
        if: "type_val.body != 'directory'"
        doc: "Must be ')', a token ending the node definition."

  type_directory:
    doc: "A directory node, containing a list of entries."
    seq:
      - id: entries
        type: dir_entry
        repeat: until
        repeat-until: _.kind.body == ')'
    types:
      dir_entry:
        doc: "A single entry within a directory, or a terminator."
        seq:
          - id: kind
            type: padded_str
            valid:
              expr: _.body == 'entry' or _.body == ')'
            doc: "Must be 'entry' (for a child node) or '' (for terminator)."
          - id: open_paren
            type: padded_str
            valid:
              expr: _.body == '('
            if: 'kind.body == "entry"'
          - id: name_key
            type: padded_str
            valid:
              expr: _.body == 'name'
            if: 'kind.body == "entry"'
          - id: name
            type: padded_bytes
            if: 'kind.body == "entry"'
            doc: |
              Name of the entry, as raw bytes. Nix 2.36.0
              [doesn't check the encoding](https://github.com/NixOS/nix/blob/88907193c54fcd5184cf59d14b693188e2875168/src/libutil/archive.cc#L245-L248),
              and real NARs contain names that aren't valid UTF-8.
          - id: node_key
            type: padded_str
            valid:
              expr: _.body == 'node'
            if: 'kind.body == "entry"'
          - id: node
            type: node
            if: 'kind.body == "entry"'
            doc: "The child node, present only if kind is 'entry'."
          - id: close_paren
            type: padded_str
            valid:
              expr: _.body == ')'
            if: 'kind.body == "entry"'
        instances:
          is_terminator:
            value: kind.body == ')'

  type_regular:
    doc: "A regular file node."
    seq:
      - id: first_key
        type: padded_str
        valid:
          expr: _.body == 'executable' or _.body == 'contents'
        doc: Either `executable` or `contents`.
      - id: executable_val
        type: padded_str
        valid:
          expr: _.body == ''
        if: is_executable
        doc: Must be empty.
      - id: contents_key
        type: padded_str
        valid:
          expr: _.body == 'contents'
        if: is_executable
      - id: file_data
        type: file_content
    instances:
      is_executable:
        value: first_key.body == 'executable'
        doc: True if the file has the `executable` attribute.
    types:
      file_content:
        doc: "The raw data of the file, prefixed by length."
        seq:
          - id: len_contents
            type: u8
          # The `if` is always false, so this field reads nothing. Its only
          # purpose is to evaluate `nar_offset` right before `contents`.
          - size: 0
            if: nar_offset < 0
          - id: contents
            size: len_contents
          - id: padding
            size: (8 - (len_contents % 8)) % 8
        instances:
          nar_offset:
            value: _io.pos
            doc: |
              Offset of `contents` in the stream. It corresponds to
              [`narOffset`](https://github.com/NixOS/nix/blob/88907193c54fcd5184cf59d14b693188e2875168/src/libutil/include/nix/util/source-accessor.hh#L134-L138)
              in Nix.

  type_symlink:
    doc: "A symbolic link node."
    seq:
      - id: target_key
        type: padded_str
        valid:
          expr: _.body == 'target'
        doc: "Must be 'target'."
      - id: target_val
        type: padded_bytes
        doc: |
          The destination path of the symlink, as raw bytes. Nix 2.36.0
          [doesn't check the encoding](https://github.com/NixOS/nix/blob/88907193c54fcd5184cf59d14b693188e2875168/src/libutil/archive.cc#L280-L282).
