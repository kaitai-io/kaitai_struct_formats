meta:
  id: dicom_le_generic
  title: Digital Imaging and Communications in Medicine (DICOM) file format
  file-extension: dcm
  license: MIT
  endian: le
  imports:
    - dicom_common
doc-ref: http://dicom.nema.org/medical/dicom/current/output/html/part10.html
doc: |
  This parser attempts to parse dicoms with both implicit and explicit transfer
  syntaxes.
seq:
  - id: file_header
    type: t_file_header
  - id: dataset
    type: t_dataset_generic
types:
  t_dataset_generic:
    seq:
      - id: elements1
        type: t_dataentry_implicit
        if: not _io.eof
        repeat: until
        repeat-until: _io.eof or _.is_transfer_syntax_change_explicit
      - id: elements2
        type: t_dataentry_explicit
        repeat: eos
