meta:
  id: dicom_common
  title: Digital Imaging and Communications in Medicine (DICOM) file format
  file-extension: dcm
  license: MIT
  endian: le
doc-ref: http://dicom.nema.org/medical/dicom/current/output/html/part10.html
doc: |
  Common types for little endian DICOM files
seq: []
types:
  t_file_header:
    seq:
      - id: preamble
        size: 128
      - id: magic
        contents: 'DICM'
  t_dataentry_implicit:
    seq:
      - id: tag_group
        type: u2
      - id: tag_elem
        type: u2
      - id: header
        type: t_entry_header_implicit
        if: entry_implicit
      - id: header
        type: t_entry_header_explicit
        if: not entry_implicit
      - id: content
        size: header.content_length
        if: has_content
      - id: elements
        type: t_dataentry_implicit
        if: has_elements and not is_definite
        repeat: until
        repeat-until: _.is_closing_tag
      - id: elements
        type: t_elements
        if: has_elements and is_definite
        size: header.content_length
    types:
      t_elements:
        seq:
          - id: elements
            type: t_dataentry_implicit
            repeat: eos
    instances:
      entry_implicit:
        value: tag_group != 2 or tag_group == 0xfffe
      is_closing_tag:
        value: (tag_group == 0xfffe) and (tag_elem & 0xff00 == 0xe000) and (tag_elem != 0xe000)
      has_elements:
        value: (tag_group == 0xfffe and tag_elem == 0xe000) or header.is_seq
      has_content:
        value: not has_elements
      is_definite:
        value: header.content_length != 0xffffffff
      p_is_transfer_syntax_change_non_implicit:
        # '1.2.840.10008.1.2.1\0' (Explicit VR Little Endian)
        # See http://www.dicomlibrary.com/dicom/transfer-syntax/
        value: content != [49, 46, 50, 46, 56, 52, 48, 46, 49, 48, 48, 48, 56, 46, 49, 46, 50, 46, 49, 0]
      is_transfer_syntax_change_explicit:
        value: tag_group == 2 and tag_elem == 16 and p_is_transfer_syntax_change_non_implicit

  t_dataentry_explicit:
    seq:
      - id: tag_group
        type: u2
      - id: tag_elem
        type: u2
      - id: header
        if: header_is_implicit
        type: t_entry_header_implicit
      - id: header
        if: not header_is_implicit
        type: t_entry_header_explicit
      - id: content
        size: header.content_length
        if: has_content
      - id: elements
        type: t_dataentry_explicit
        if: has_elements and not is_definite
        repeat: until
        repeat-until: _.is_closing_tag
      - id: elements
        type: t_elements
        if: has_elements and is_definite
        size: header.content_length
    types:
      t_elements:
        seq:
          - id: elements
            type: t_dataentry_explicit
            repeat: eos
    instances:
      header_is_implicit:
        value: tag_group == 0xfffe
      is_closing_tag:
        value: tag_group == 0xfffe and tag_elem & 0xff00 == 0xe000 and tag_elem != 0xe000
      has_elements:
        value: (tag_group == 0xfffe and tag_elem == 0xe000) or header.is_seq
      has_content:
        value: not has_elements
      is_definite:
        value: header.content_length != 0xffffffff

  t_entry_header_explicit:
    seq:
      - id: vr
        type: str
        encoding: 'ascii'
        size: 2
      - id: p_reserved
        type: u2
        if: length_is_long
      - id: p_content_length_u4
        type: u4
        if: length_is_long
      - id: p_content_length_u2
        type: u2
        if: not length_is_long
    instances:
      content_length:
        value: 'length_is_long ? p_content_length_u4 : p_content_length_u2'
      length_is_long:
        value: not (vr == 'AE' or vr == 'AS' or vr == 'AT' or vr == 'CS' or vr == 'DA' or vr == 'DS' or vr == 'DT' or vr == 'FL' or vr == 'FD' or vr == 'IS' or vr == 'LO' or vr == 'PN' or vr == 'SH' or vr == 'SL' or vr == 'SS' or vr == 'ST' or vr == 'TM' or vr == 'UI' or vr == 'UL' or vr == 'US' or vr == 'LT')
      is_seq:
        value: vr == 'SQ'

  t_entry_header_implicit:
    seq:
      - id: content_length
        type: u4
    instances:
      is_seq:
        value: content_length == 0xffffffff
