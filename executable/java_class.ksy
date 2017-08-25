meta:
  id: java_class
  endian: be
  file-extension: class
  license: CC0-1.0
doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.1'
seq:
  - id: magic
    contents: [0xca, 0xfe, 0xba, 0xbe]
  - id: version_minor
    type: u2
  - id: version_major
    type: u2
  - id: constant_pool_count
    type: u2
  - id: constant_pool
    type: constant_pool_entry
    repeat: expr
    repeat-expr: constant_pool_count - 1
  - id: access_flags
    type: u2
  - id: this_class
    type: u2
  - id: super_class
    type: u2
  - id: interfaces_count
    type: u2
  - id: interfaces
    type: u2
    repeat: expr
    repeat-expr: interfaces_count
  - id: fields_count
    type: u2
  - id: fields
    type: field_info
    repeat: expr
    repeat-expr: fields_count
  - id: methods_count
    type: u2
  - id: methods
    type: method_info
    repeat: expr
    repeat-expr: methods_count
  - id: attributes_count
    type: u2
  - id: attributes
    type: attribute_info
    repeat: expr
    repeat-expr: attributes_count
types:
  constant_pool_entry:
    seq:
      - id: tag
        type: u1
        enum: tag_enum
      - id: cp_info
        type:
          switch-on: tag
          cases:
            'tag_enum::class_type': class_cp_info
            'tag_enum::field_ref': field_ref_cp_info
            'tag_enum::method_ref': method_ref_cp_info
            'tag_enum::interface_method_ref': interface_method_ref_cp_info
            'tag_enum::string': string_cp_info
            'tag_enum::integer': integer_cp_info
            'tag_enum::float': float_cp_info
            'tag_enum::long': long_cp_info
            'tag_enum::double': double_cp_info
            'tag_enum::name_and_type': name_and_type_cp_info
            'tag_enum::utf8': utf8_cp_info
            'tag_enum::method_handle': method_handle_cp_info
            'tag_enum::method_type': method_type_cp_info
            'tag_enum::invoke_dynamic': invoke_dynamic_cp_info
    enums:
      tag_enum:
        7: class_type
        9: field_ref
        10: method_ref
        11: interface_method_ref
        8: string
        3: integer
        4: float
        5: long
        6: double
        12: name_and_type
        1: utf8
        15: method_handle
        16: method_type
        18: invoke_dynamic
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4'
  class_cp_info:
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.1'
    seq:
      - id: name_index
        type: u2
    instances:
      name_as_info:
        value: _root.constant_pool[name_index - 1].cp_info.as<utf8_cp_info>
      name_as_str:
        value: name_as_info.value
  field_ref_cp_info:
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.2'
    seq:
      - id: class_index
        type: u2
      - id: name_and_type_index
        type: u2
    instances:
      class_as_info:
        value: _root.constant_pool[class_index - 1].cp_info.as<class_cp_info>
      name_and_type_as_info:
        value: _root.constant_pool[name_and_type_index - 1].cp_info.as<name_and_type_cp_info>
  method_ref_cp_info:
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.2'
    seq:
      - id: class_index
        type: u2
      - id: name_and_type_index
        type: u2
    instances:
      class_as_info:
        value: _root.constant_pool[class_index - 1].cp_info.as<class_cp_info>
      name_and_type_as_info:
        value: _root.constant_pool[name_and_type_index - 1].cp_info.as<name_and_type_cp_info>
  interface_method_ref_cp_info:
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.2'
    seq:
      - id: class_index
        type: u2
      - id: name_and_type_index
        type: u2
    instances:
      class_as_info:
        value: _root.constant_pool[class_index - 1].cp_info.as<class_cp_info>
      name_and_type_as_info:
        value: _root.constant_pool[name_and_type_index - 1].cp_info.as<name_and_type_cp_info>
  string_cp_info:
    seq:
      - id: string_index
        type: u2
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.3'
  integer_cp_info:
    seq:
      - id: value
        type: u4
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.4'
  float_cp_info:
    seq:
      - id: value
        type: f4
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.5'
  long_cp_info:
    seq:
      - id: value
        type: u8
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.5'
  double_cp_info:
    seq:
      - id: value
        type: f8
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.6'
  name_and_type_cp_info:
    seq:
      - id: name_index
        type: u2
      - id: descriptor_index
        type: u2
    instances:
      name_as_info:
        value: _root.constant_pool[name_index - 1].cp_info.as<utf8_cp_info>
      name_as_str:
        value: name_as_info.value
      descriptor_as_info:
        value: _root.constant_pool[descriptor_index - 1].cp_info.as<utf8_cp_info>
      descriptor_as_str:
        value: descriptor_as_info.value
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.6'
  utf8_cp_info:
    seq:
      - id: str_len
        type: u2
      - id: value
        type: str
        size: str_len
        encoding: UTF-8
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.7'
  method_handle_cp_info:
    seq:
      - id: reference_kind
        type: u1
        enum: reference_kind_enum
      - id: reference_index
        type: u2
    enums:
      reference_kind_enum:
        1: get_field
        2: get_static
        3: put_field
        4: put_static
        5: invoke_virtual
        6: invoke_static
        7: invoke_special
        8: new_invoke_special
        9: invoke_interface
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.8'
  method_type_cp_info:
    seq:
      - id: descriptor_index
        type: u2
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.9'
  invoke_dynamic_cp_info:
    seq:
      - id: bootstrap_method_attr_index
        type: u2
      - id: name_and_type_index
        type: u2
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.10'
  field_info:
    seq:
      - id: access_flags
        type: u2
      - id: name_index
        type: u2
      - id: descriptor_index
        type: u2
      - id: attributes_count
        type: u2
      - id: attributes
        type: attribute_info
        repeat: expr
        repeat-expr: attributes_count
    instances:
      name_as_str:
        value: _root.constant_pool[name_index - 1].cp_info.as<utf8_cp_info>.value
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.5'
  attribute_info:
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7'
    seq:
      - id: name_index
        type: u2
      - id: attribute_length
        type: u4
      - id: info
        size: attribute_length
        type:
          switch-on: name_as_str
          cases:
            '"Code"': attr_body_code # 4.7.3
            '"Exceptions"': attr_body_exceptions # 4.7.5
            '"SourceFile"': attr_body_source_file # 4.7.10
            '"LineNumberTable"': attr_body_line_number_table # 4.7.12
    instances:
      name_as_str:
        value: _root.constant_pool[name_index - 1].cp_info.as<utf8_cp_info>.value
    types:
      attr_body_code:
        doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.3'
        seq:
          - id: max_stack
            type: u2
          - id: max_locals
            type: u2
          - id: code_length
            type: u4
          - id: code
            size: code_length
          - id: exception_table_length
            type: u2
          - id: exception_table
            type: exception_entry
            repeat: expr
            repeat-expr: exception_table_length
          - id: attributes_count
            type: u2
          - id: attributes
            type: attribute_info
            repeat: expr
            repeat-expr: attributes_count
        types:
          exception_entry:
            doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.3'
            seq:
              - id: start_pc
                type: u2
                doc: |
                  Start of a code region where exception handler is being
                  active, index in code array (inclusive)
              - id: end_pc
                type: u2
                doc: |
                  End of a code region where exception handler is being
                  active, index in code array (exclusive)
              - id: handler_pc
                type: u2
                doc: Start of exception handler code, index in code array
              - id: catch_type
                type: u2
                doc: |
                  Exception class that this handler catches, index in constant
                  pool, or 0 (catch all exceptions handler, used to implement
                  `finally`).
            instances:
              catch_exception:
                value: _root.constant_pool[catch_type - 1]
                if: catch_type != 0
      attr_body_exceptions:
        doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.5'
        seq:
          - id: number_of_exceptions
            type: u2
          - id: exceptions
            type: exception_table_entry
            repeat: expr
            repeat-expr: number_of_exceptions
        types:
          exception_table_entry:
            seq:
              - id: index
                type: u2
            instances:
              as_info:
                value: _root.constant_pool[index - 1].cp_info.as<class_cp_info>
              name_as_str:
                value: as_info.name_as_str
      attr_body_source_file:
        doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.10'
        seq:
          - id: sourcefile_index
            type: u2
        instances:
          sourcefile_as_str:
            value: _root.constant_pool[sourcefile_index - 1].cp_info.as<utf8_cp_info>.value
      attr_body_line_number_table:
        doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.12'
        seq:
          - id: line_number_table_length
            type: u2
          - id: line_number_table
            type: line_number_table_entry
            repeat: expr
            repeat-expr: line_number_table_length
        types:
          line_number_table_entry:
            seq:
              - id: start_pc
                type: u2
              - id: line_number
                type: u2
  method_info:
    seq:
      - id: access_flags
        type: u2
      - id: name_index
        type: u2
      - id: descriptor_index
        type: u2
      - id: attributes_count
        type: u2
      - id: attributes
        type: attribute_info
        repeat: expr
        repeat-expr: attributes_count
    instances:
      name_as_str:
        value: _root.constant_pool[name_index - 1].cp_info.as<utf8_cp_info>.value
    doc-ref: 'https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.6'
