meta:
  id: java_class
  file-extension: class
  xref:
    justsolve: Java
    pronom: x-fmt/415
    wikidata: Q2193155
  license: CC0-1.0
  endian: be
doc-ref:
  - https://docs.oracle.com/javase/specs/jvms/se19/html/jvms-4.html
  - https://docs.oracle.com/javase/specs/jls/se6/jls3.pdf
  - https://github.com/openjdk/jdk/blob/jdk-21%2B14/src/jdk.hotspot.agent/share/classes/sun/jvm/hotspot/runtime/ClassConstants.java
  - https://github.com/openjdk/jdk/blob/jdk-21%2B14/src/java.base/share/native/include/classfile_constants.h.template
  - https://github.com/openjdk/jdk/blob/jdk-21%2B14/src/hotspot/share/classfile/classFileParser.cpp
seq:
  - id: magic
    contents: [0xca, 0xfe, 0xba, 0xbe]
  - id: version_minor
    type: u2
  - id: version_major
    type: u2
    valid:
      # https://github.com/file/file/blob/905ca555/magic/Magdir/cafebabe#L11-L12
      min: 43
  - id: constant_pool_count
    type: u2
  - id: constant_pool
    type: 'constant_pool_entry(_index != 0 ? constant_pool[_index - 1].is_two_entries : false)'
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
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4
    params:
      - id: is_prev_two_entries
        type: bool
    seq:
      - id: tag
        type: u1
        enum: tag_enum
        if: not is_prev_two_entries
      - id: cp_info
        type:
          switch-on: tag
          cases:
            tag_enum::class_type: class_cp_info
            tag_enum::field_ref: field_ref_cp_info
            tag_enum::method_ref: method_ref_cp_info
            tag_enum::interface_method_ref: interface_method_ref_cp_info
            tag_enum::string: string_cp_info
            tag_enum::integer: integer_cp_info
            tag_enum::float: float_cp_info
            tag_enum::long: long_cp_info
            tag_enum::double: double_cp_info
            tag_enum::name_and_type: name_and_type_cp_info
            tag_enum::utf8: utf8_cp_info
            tag_enum::method_handle: method_handle_cp_info
            tag_enum::method_type: method_type_cp_info
            tag_enum::invoke_dynamic: invoke_dynamic_cp_info
            tag_enum::dynamic: dynamic_cp_info
            tag_enum::module: module_package_cp_info
            tag_enum::package: module_package_cp_info
        if: not is_prev_two_entries
    instances:
      is_two_entries:
        value: 'is_prev_two_entries ? false : tag == tag_enum::long or tag == tag_enum::double'
    enums:
      tag_enum:
        1:
          id: utf8
          -orig-id: CONSTANT_Utf8
        3:
          id: integer
          -orig-id: CONSTANT_Integer
        4:
          id: float
          -orig-id: CONSTANT_Float
        5:
          id: long
          -orig-id: CONSTANT_Long
        6:
          id: double
          -orig-id: CONSTANT_Double
        7:
          id: class_type
          -orig-id: CONSTANT_Class
        8:
          id: string
          -orig-id: CONSTANT_String
        9:
          id: field_ref
          -orig-id: CONSTANT_Fieldref
        10:
          id: method_ref
          -orig-id: CONSTANT_Methodref
        11:
          id: interface_method_ref
          -orig-id: CONSTANT_InterfaceMethodref
        12:
          id: name_and_type
          -orig-id: CONSTANT_NameAndType
        15:
          id: method_handle
          -orig-id: CONSTANT_MethodHandle
        16:
          id: method_type
          -orig-id: CONSTANT_MethodType
        17:
          id: dynamic
          -orig-id: CONSTANT_Dynamic
        18:
          id: invoke_dynamic
          -orig-id: CONSTANT_InvokeDynamic
        19:
          id: module
          -orig-id: CONSTANT_Module
        20:
          id: package
          -orig-id: CONSTANT_Package

  version_guard:
    doc: |
      `class` file format version 45.3 (appeared in the very first publicly
      known release of Java SE AND JDK 1.0.2, released 23th January 1996) is so
      ancient that it's taken for granted. Earlier formats seem to be
      undocumented. Changes of `version_minor` don't change `class` format.
      Earlier `version_major`s likely belong to Oak programming language, the
      proprietary predecessor of Java.
    doc-ref:
      - "James Gosling, Bill Joy and Guy Steele. The Java Language Specification. English. Ed. by Lisa Friendly. Addison-Wesley, Aug. 1996, p. 825. ISBN: 0-201-63451-1."
      - "Frank Yellin and Tim Lindholm. The Java Virtual Machine Specification. English. Ed. by Lisa Friendly. Addison-Wesley, Sept. 1996, p. 475. ISBN: 0-201-63452-X."
    params:
      - id: major
        type: u2
    seq:
      - size: 0
        valid:
          expr: _root.version_major >= major

  class_cp_info:
    -orig-id: CONSTANT_Class_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.1
    seq:
      - id: name_index
        type: u2
    instances:
      name_as_info:
        value: _root.constant_pool[name_index - 1].cp_info.as<utf8_cp_info>
      name_as_str:
        value: name_as_info.value
  field_ref_cp_info:
    -orig-id: CONSTANT_Fieldref_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.2
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
    -orig-id: CONSTANT_Methodref_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.2
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
    -orig-id: CONSTANT_InterfaceMethodref_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.2
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
    -orig-id: CONSTANT_String_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.3
    seq:
      - id: string_index
        type: u2
  integer_cp_info:
    -orig-id: CONSTANT_Integer_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.4
    seq:
      - id: value
        type: u4
  float_cp_info:
    -orig-id: CONSTANT_Float_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.5
    seq:
      - id: value
        type: f4
  long_cp_info:
    -orig-id: CONSTANT_Long_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.5
    seq:
      - id: value
        type: u8
  double_cp_info:
    -orig-id: CONSTANT_Double_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.6
    seq:
      - id: value
        type: f8
  name_and_type_cp_info:
    -orig-id: CONSTANT_NameAndType_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.6
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
  utf8_cp_info:
    -orig-id: CONSTANT_Utf8_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.7
    seq:
      - id: str_len
        type: u2
      - id: value
        type: str
        size: str_len
        encoding: UTF-8
  method_handle_cp_info:
    -orig-id: CONSTANT_MethodHandle_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.8
    seq:
      - type: version_guard(51)
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
  method_type_cp_info:
    -orig-id: CONSTANT_MethodType_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.9
    seq:
      - type: version_guard(51)
      - id: descriptor_index
        type: u2
  dynamic_cp_info:
    -orig-id: CONSTANT_Dynamic_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se19/html/jvms-4.html#jvms-4.4.10
    seq:
      - type: version_guard(55)
      - id: bootstrap_method_attr_index
        type: u2
      - id: name_and_type_index
        type: u2
  invoke_dynamic_cp_info:
    -orig-id: CONSTANT_InvokeDynamic_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.10
    seq:
      - type: version_guard(51)
      - id: bootstrap_method_attr_index
        type: u2
      - id: name_and_type_index
        type: u2
  module_package_cp_info:
    -orig-id:
      - CONSTANT_Module_info
      - CONSTANT_Package_info
    doc: |
      Project Jigsaw modules introduced in Java 9
    doc-ref:
      - https://docs.oracle.com/javase/specs/jvms/se19/html/jvms-3.html#jvms-3.16
      - https://docs.oracle.com/javase/specs/jvms/se19/html/jvms-4.html#jvms-4.4.11
      - https://docs.oracle.com/javase/specs/jvms/se19/html/jvms-4.html#jvms-4.4.12
    seq:
      - type: version_guard(53)
      - id: name_index
        type: u2
    instances:
      name_as_info:
        value: _root.constant_pool[name_index - 1].cp_info.as<utf8_cp_info>
      name_as_str:
        value: name_as_info.value
  field_info:
    -orig-id: field_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.5
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
  attribute_info:
    -orig-id: attribute_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7
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
        doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.3
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
            doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.3
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
        doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.5
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
        doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.10
        seq:
          - id: sourcefile_index
            type: u2
        instances:
          sourcefile_as_str:
            value: _root.constant_pool[sourcefile_index - 1].cp_info.as<utf8_cp_info>.value
      attr_body_line_number_table:
        doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7.12
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
    -orig-id: method_info
    doc-ref: https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.6
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
