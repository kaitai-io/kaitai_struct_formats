meta:
  id: windows_diagnostics_framework_rbs
  title: RBS
  application:
    - Windows Diagnostics Framework
    - Diagnostic Data Viewer
  file-extension: rbs
  license: MIT
  encoding: utf-8
  endian: le
doc: |
  The file format used by Windows Diagnostics Framework (including so called telemetery).
  If you have Windows with "telemetry" (Windows 10 and Windows 7,8,8.1 with the updates containing telemetry), you can find these files in %ProgramData%\Microsoft\Diagnosis directory.
doc-ref: https://github.com/bluec0re/windows-rbs-parser
seq:
  - id: header
    type: header
  - id: reserved_size
    size: header.reserved_space_size
    type: reserved_space
types:
  reserved_space:
    seq:
      - id: items
        size: _root.header.items_collection_size
        type: items_collection
    types:
      items_collection:
        seq:
          - id: items
            type: item
            repeat: expr
            repeat-expr: _root.header.elements_count
  header:
    seq:
      - id: signature
        contents: ["UTCRBES"]
      - id: version_str
        type: str
        size: 1
      - id: unkn0
        size: 8
        doc: "Doesn't match any data inside of JSON"
      - id: items_collection_size
        type: u4
      - id: items_collection_size_again
        type: u4
        doc: "Usisally matches items_collection_size"
      - id: unkn1
        type: u4
        doc: "usually 0"
      - id: reserved_space_size
        type: u4
      - id: unkn2
        size: 4
        if: "version >=5"
      - id: elements_count
        type: u4
        -orig-id: num_elements
      - id: elements_count_again
        -orig-id: num_elements2
        type: u4
        doc: "Usisally matches elements_count"
        if: "version < 5"
      - id: unkn3
        type: u2
      - id: unkn4
        size: 5
        if: "version >=5"
    instances:
      version:
        value: version_str.to_i
  item:
    seq:
      - id: header
        type: header
      - id: data
        size: header.size
        process: "kaitai.compress.zlib(-1, 15)"
        doc: "JSON-serialized data, though JSON looks not very valid. Some info about the data in JSON may be found in the documents by the links in -doc-ref."
        doc-ref:
          - "https://autoriteitpersoonsgegevens.nl/sites/default/files/atoms/files/public_version_dutch_dpa_informal_translation_summary_of_investigation_report.pdf"
          - "https://github.com/MicrosoftDocs/windows-itpro-docs/tree/master/windows/privacy"
          - "https://docs.microsoft.com/windows/privacy/windows-diagnostic-data"
    types:
      header:
        seq:
          - id: unkn0
            size: 4
          - id: index
            type: u4
          - id: unkn1
            size: 4
          - id: unkn2
            size: 8
            if: "_root.header.version >=5"
          - id: size
            type: u4
          - id: unkn3
            type: u4
            doc: "bluec0re suspects it is the type"
          - id: unkn4
            type:
              switch-on: "_root.header.version >=5"
              cases:
                "false": u2
                "true": u1
