meta:
  id: dicom_le_explicit
  title: Digital Imaging and Communications in Medicine (DICOM) file format
  file-extension: dcm
  license: MIT
  endian: le
  imports:
    - dicom_common
doc-ref: http://dicom.nema.org/medical/dicom/current/output/html/part10.html
doc: |
  This grammar parses dicom files with explicit transfer syntax.
seq:
  - id: file_header
    type: t_file_header
  - id: dataset
    type: t_dataset_explicit
types:
  t_dataset_explicit:
    seq:
      - id: elements
        type: t_dataentry_explicit
        repeat: eos
