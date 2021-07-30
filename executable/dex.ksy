meta:
  id: dex
  title: Android Dalvik VM executable (dex)
  file-extension: dex
  xref:
    pronom: fmt/694
    wikidata: Q29000585
  tags:
    - android
    - executable
  license: Apache-2.0
  imports:
    - /common/vlq_base128_le
  endian: le
doc: |
  Android OS applications executables are typically stored in its own
  format, optimized for more efficient execution in Dalvik virtual
  machine.

  This format is loosely similar to Java .class file format and
  generally holds the similar set of data: i.e. classes, methods,
  fields, annotations, etc.
doc-ref: https://source.android.com/devices/tech/dalvik/dex-format
seq:
  - id: header
    type: header_item
instances:
  string_ids:
    pos: header.string_ids_off
    type: string_id_item
    repeat: expr
    repeat-expr: header.string_ids_size
    doc: |
      string identifiers list.

      These are identifiers for all the strings used by this file, either for
      internal naming (e.g., type descriptors) or as constant objects referred to by code.

      This list must be sorted by string contents, using UTF-16 code point values
      (not in a locale-sensitive manner), and it must not contain any duplicate entries.
  type_ids:
    pos: header.type_ids_off
    type: type_id_item
    repeat: expr
    repeat-expr: header.type_ids_size
    doc: |
      type identifiers list.

      These are identifiers for all types (classes, arrays, or primitive types)
      referred to by this file, whether defined in the file or not.

      This list must be sorted by string_id index, and it must not contain any duplicate entries.
  proto_ids:
    pos: header.proto_ids_off
    type: proto_id_item
    repeat: expr
    repeat-expr: header.proto_ids_size
    doc: |
      method prototype identifiers list.

      These are identifiers for all prototypes referred to by this file.

      This list must be sorted in return-type (by type_id index) major order,
      and then by argument list (lexicographic ordering, individual arguments
      ordered by type_id index). The list must not contain any duplicate entries.
  field_ids:
    pos: header.field_ids_off
    type: field_id_item
    repeat: expr
    repeat-expr: header.field_ids_size
    doc: |
      field identifiers list.

      These are identifiers for all fields referred to by this file, whether defined in the file or not.

      This list must be sorted, where the defining type (by type_id index)
      is the major order, field name (by string_id index) is the intermediate
      order, and type (by type_id index) is the minor order.

      The list must not contain any duplicate entries.
  method_ids:
    pos: header.method_ids_off
    type: method_id_item
    repeat: expr
    repeat-expr: header.method_ids_size
    doc: |
      method identifiers list.

      These are identifiers for all methods referred to by this file,
      whether defined in the file or not.

      This list must be sorted, where the defining type (by type_id index
      is the major order, method name (by string_id index) is the intermediate
      order, and method prototype (by proto_id index) is the minor order.

      The list must not contain any duplicate entries.
  class_defs:
    pos: header.class_defs_off
    type: class_def_item
    repeat: expr
    repeat-expr: header.class_defs_size
    doc: |
      class definitions list.

      The classes must be ordered such that a given class's superclass and
      implemented interfaces appear in the list earlier than the referring class.

      Furthermore, it is invalid for a definition for the same-named class to
      appear more than once in the list.
  #call_site_ids:
  #  pos: header.???
  #  type: call_site_id_item
  #  repeat: expr
  #  repeat-expr: header.???
  #  doc: |
  #    call site identifiers list.
  #
  #    These are identifiers for all call sites referred to by this file,
  #    whether defined in the file or not.
  #
  #    This list must be sorted in ascending order of call_site_off.
  link_data:
    pos: header.link_off
    size: header.link_size
    doc: |
      data used in statically linked files.

      The format of the data in this section is left unspecified by this document.

      This section is empty in unlinked files, and runtime implementations may
      use it as they see fit.
  data:
    pos: header.data_off
    size: header.data_size
    doc: |
      data area, containing all the support data for the tables listed above.

      Different items have different alignment requirements, and padding bytes
      are inserted before each item if necessary to achieve proper alignment.
  map:
    pos: header.map_off
    type: map_list
types:
  header_item:
    seq:
      - id: magic
        contents: "dex\n"
      - id: version_str
        size: 4
        type: strz
        encoding: ascii
      - id: checksum
        type: u4
        doc: |
          adler32 checksum of the rest of the file (everything but magic and this field);
          used to detect file corruption
      - id: signature
        size: 20
        doc: |
          SHA-1 signature (hash) of the rest of the file (everything but magic, checksum,
          and this field); used to uniquely identify files
      - id: file_size
        type: u4
        doc: |
          size of the entire file (including the header), in bytes
      - id: header_size
        type: u4
        # guard: 0x70
        doc: |
          size of the header (this entire section), in bytes. This allows for at
          least a limited amount of backwards/forwards compatibility without
          invalidating the format.
      - id: endian_tag
        type: u4
        enum: endian_constant
      - id: link_size
        type: u4
        doc: |
          size of the link section, or 0 if this file isn't statically linked
      - id: link_off
        type: u4
        doc: |
          offset from the start of the file to the link section, or 0 if link_size == 0.
          The offset, if non-zero, should be to an offset into the link_data section.
          The format of the data pointed at is left unspecified by this document;
          this header field (and the previous) are left as hooks for use by runtime implementations.
      - id: map_off
        type: u4
        doc: |
          offset from the start of the file to the map item.
          The offset, which must be non-zero, should be to an offset into the data
          section, and the data should be in the format specified by "map_list" below.
      - id: string_ids_size
        type: u4
        doc: |
          count of strings in the string identifiers list
      - id: string_ids_off
        type: u4
        doc: |
          offset from the start of the file to the string identifiers list,
          or 0 if string_ids_size == 0 (admittedly a strange edge case).
          The offset, if non-zero, should be to the start of the string_ids section.
      - id: type_ids_size
        type: u4
        doc: |
          count of elements in the type identifiers list, at most 65535
      - id: type_ids_off
        type: u4
        doc: |
          offset from the start of the file to the type identifiers list,
          or 0 if type_ids_size == 0 (admittedly a strange edge case).
          The offset, if non-zero, should be to the start of the type_ids section.
      - id: proto_ids_size
        type: u4
        doc: |
          count of elements in the prototype identifiers list, at most 65535
      - id: proto_ids_off
        type: u4
        doc: |
          offset from the start of the file to the prototype identifiers list,
          or 0 if proto_ids_size == 0 (admittedly a strange edge case).
          The offset, if non-zero, should be to the start of the proto_ids section.
      - id: field_ids_size
        type: u4
        doc: |
          count of elements in the field identifiers list
      - id: field_ids_off
        type: u4
        doc: |
          offset from the start of the file to the field identifiers list,
          or 0 if field_ids_size == 0.
          The offset, if non-zero, should be to the start of the field_ids section.
      - id: method_ids_size
        type: u4
        doc: |
          count of elements in the method identifiers list
      - id: method_ids_off
        type: u4
        doc: |
          offset from the start of the file to the method identifiers list,
          or 0 if method_ids_size == 0.
          The offset, if non-zero, should be to the start of the method_ids section.
      - id: class_defs_size
        type: u4
        doc: |
          count of elements in the class definitions list
      - id: class_defs_off
        type: u4
        doc: |
          offset from the start of the file to the class definitions list,
          or 0 if class_defs_size == 0 (admittedly a strange edge case).
          The offset, if non-zero, should be to the start of the class_defs section.
      - id: data_size
        type: u4
        doc: |
          Size of data section in bytes. Must be an even multiple of sizeof(uint).
      - id: data_off
        type: u4
        doc: |
          offset from the start of the file to the start of the data section.
    enums:
      endian_constant:
        0x12345678: endian_constant
        0x78563412: reverse_endian_constant
  string_id_item:
    -webide-representation: "{value.data} (offs={string_data_off})"
    seq:
      - id: string_data_off
        type: u4
        doc: |
          offset from the start of the file to the string data for this item.
          The offset should be to a location in the data section, and the data
          should be in the format specified by "string_data_item" below.
          There is no alignment requirement for the offset.
    types:
      string_data_item:
        -webide-representation: "{data}"
        seq:
          - id: utf16_size
            type: vlq_base128_le
          - id: data
            size: utf16_size.value
            type: str
            encoding: ascii
    instances:
      value:
        pos: string_data_off
        type: string_data_item
        -webide-parse-mode: eager
  type_id_item:
    -webide-representation: "{type_name}"
    seq:
      - id: descriptor_idx
        type: u4
        doc: |
          index into the string_ids list for the descriptor string of this type.
          The string must conform to the syntax for TypeDescriptor, defined above.
    instances:
      type_name:
        value: _root.string_ids[descriptor_idx].value.data
        -webide-parse-mode: eager
  proto_id_item:
    -webide-representation: "shorty_idx={shorty_idx} return_type_idx={return_type_idx} parameters_off={parameters_off}"
    seq:
      - id: shorty_idx
        type: u4
        doc: |
          index into the string_ids list for the short-form descriptor string of this prototype.
          The string must conform to the syntax for ShortyDescriptor, defined above,
          and must correspond to the return type and parameters of this item.
      - id: return_type_idx
        type: u4
        doc: |
          index into the type_ids list for the return type of this prototype
      - id: parameters_off
        type: u4
        doc: |
          offset from the start of the file to the list of parameter types for this prototype,
          or 0 if this prototype has no parameters.
          This offset, if non-zero, should be in the data section, and the data
          there should be in the format specified by "type_list" below.
          Additionally, there should be no reference to the type void in the list.
    instances:
      shorty_desc:
        value: _root.string_ids[shorty_idx].value.data
        doc: short-form descriptor string of this prototype, as pointed to by shorty_idx
      params_types:
        io: _root._io
        pos: parameters_off
        type: type_list
        if: parameters_off != 0
        doc: list of parameter types for this prototype
      return_type:
        value: _root.type_ids[return_type_idx].type_name
        doc: return type of this prototype
  field_id_item:
    -webide-representation: "class_idx={class_idx} type_idx={type_idx} name_idx={name_idx}"
    seq:
      - id: class_idx
        type: u2
        doc: |
          index into the type_ids list for the definer of this field.
          This must be a class type, and not an array or primitive type.
      - id: type_idx
        type: u2
        doc: |
          index into the type_ids list for the type of this field
      - id: name_idx
        type: u4
        doc: |
          index into the string_ids list for the name of this field.
          The string must conform to the syntax for MemberName, defined above.
    instances:
      class_name:
        value: _root.type_ids[class_idx].type_name
        doc: the definer of this field
      type_name:
        value: _root.type_ids[type_idx].type_name
        doc: the type of this field
      field_name:
        value: _root.string_ids[name_idx].value.data
        doc: the name of this field
  method_id_item:
    -webide-representation: "class_idx={class_idx} proto_idx={proto_idx} name_idx={name_idx}"
    seq:
      - id: class_idx
        type: u2
        doc: |
          index into the type_ids list for the definer of this method.
          This must be a class or array type, and not a primitive type.
      - id: proto_idx
        type: u2
        doc: |
          index into the proto_ids list for the prototype of this method
      - id: name_idx
        type: u4
        doc: |
          index into the string_ids list for the name of this method.
          The string must conform to the syntax for MemberName, defined above.
    instances:
      class_name:
        value: _root.type_ids[class_idx].type_name
        doc: the definer of this method
      proto_desc:
        value: _root.proto_ids[proto_idx].shorty_desc
        doc: the short-form descriptor of the prototype of this method
      method_name:
        value: _root.string_ids[name_idx].value.data
        doc: the name of this method
  class_def_item:
    -webide-representation: "{access_flags} {type_name}"
    seq:
      - id: class_idx
        type: u4
        doc: |
          index into the type_ids list for this class.

          This must be a class type, and not an array or primitive type.
      - id: access_flags
        type: u4
        enum: class_access_flags
        doc: |
          access flags for the class (public, final, etc.).

          See "access_flags Definitions" for details.
      - id: superclass_idx
        type: u4
        doc: |
          index into the type_ids list for the superclass,
          or the constant value NO_INDEX if this class has no superclass
          (i.e., it is a root class such as Object).

          If present, this must be a class type, and not an array or primitive type.
      - id: interfaces_off
        type: u4
        doc: |
          offset from the start of the file to the list of interfaces, or 0 if there are none.

          This offset should be in the data section, and the data there should
          be in the format specified by "type_list" below. Each of the elements
          of the list must be a class type (not an array or primitive type),
          and there must not be any duplicates.
      - id: source_file_idx
        type: u4
        doc: |
          index into the string_ids list for the name of the file containing
          the original source for (at least most of) this class, or the
          special value NO_INDEX to represent a lack of this information.

          The debug_info_item of any given method may override this source file,
          but the expectation is that most classes will only come from one source file.
      - id: annotations_off
        type: u4
        doc: |
          offset from the start of the file to the annotations structure for
          this class, or 0 if there are no annotations on this class.

          This offset, if non-zero, should be in the data section, and the data
          there should be in the format specified by "annotations_directory_item"
          below,with all items referring to this class as the definer.
      - id: class_data_off
        type: u4
        doc: |
          offset from the start of the file to the associated class data for this
          item, or 0 if there is no class data for this class.

          (This may be the case, for example, if this class is a marker interface.)

          The offset, if non-zero, should be in the data section, and the data
          there should be in the format specified by "class_data_item" below,
          with all items referring to this class as the definer.
      - id: static_values_off
        type: u4
        doc: |
          offset from the start of the file to the list of initial values for
          static fields, or 0 if there are none (and all static fields are to be
          initialized with 0 or null).

          This offset should be in the data section, and the data there should
          be in the format specified by "encoded_array_item" below.

          The size of the array must be no larger than the number of static fields
          declared by this class, and the elements correspond to the static fields
          in the same order as declared in the corresponding field_list.

          The type of each array element must match the declared type of its
          corresponding field.

          If there are fewer elements in the array than there are static fields,
          then the leftover fields are initialized with a type-appropriate 0 or null.
    instances:
      type_name:
        value: _root.type_ids[class_idx].type_name
        -webide-parse-mode: eager
      class_data:
        pos: class_data_off
        type: class_data_item
        if: class_data_off != 0
      static_values:
        pos: static_values_off
        type: encoded_array_item
        if: static_values_off != 0
  encoded_array_item:
    seq:
      - id: value
        type: encoded_array
  annotation_element:
    seq:
      - id: name_idx
        type: vlq_base128_le
        doc: |
          element name, represented as an index into the string_ids section.

          The string must conform to the syntax for MemberName, defined above.
      - id: value
        type: encoded_value
        doc: |
          element value
  encoded_annotation:
    seq:
      - id: type_idx
        type: vlq_base128_le
        doc: |
          type of the annotation.

          This must be a class (not array or primitive) type.
      - id: size
        type: vlq_base128_le
        doc: |
          number of name-value mappings in this annotation
      - id: elements
        type: annotation_element
        repeat: expr
        repeat-expr: size.value
        doc: |
          elements of the annotation, represented directly in-line (not as offsets).

          Elements must be sorted in increasing order by string_id index.
  encoded_value:
    -webide-representation: "{value_type}: {value} (arg={value_arg})"
    seq:
      - id: value_arg
        type: b3
      - id: value_type
        type: b5
        enum: value_type_enum
      - id: value
        type:
          switch-on: value_type
          cases:
            # TODO: dynamic sizes
            value_type_enum::byte:          s1
            value_type_enum::short:         s2
            value_type_enum::char:          u2
            value_type_enum::int:           s4
            value_type_enum::long:          s8
            value_type_enum::float:         f4
            value_type_enum::double:        f8
            value_type_enum::method_type:   u4
            value_type_enum::method_handle: u4
            value_type_enum::string:        u4
            value_type_enum::type:          u4
            value_type_enum::field:         u4
            value_type_enum::method:        u4
            value_type_enum::enum:          u4
            value_type_enum::array:         encoded_array
            value_type_enum::annotation:    encoded_annotation
    enums:
      value_type_enum:
        0x00: byte
        0x02: short
        0x03: char
        0x04: int
        0x06: long
        0x10: float
        0x11: double
        0x15: method_type
        0x16: method_handle
        0x17: string
        0x18: type
        0x19: field
        0x1a: method
        0x1b: enum
        0x1c: array
        0x1d: annotation
        0x1e: "null"
        0x1f: boolean
  encoded_array:
    seq:
      - id: size
        type: vlq_base128_le
      - id: values
        type: encoded_value
        repeat: expr
        repeat-expr: size.value
  call_site_id_item:
    seq:
      - id: call_site_off
        type: u4
        doc: |
          offset from the start of the file to call site definition.

          The offset should be in the data section, and the data there should
          be in the format specified by "call_site_item" below.
  encoded_field:
    seq:
      - id: field_idx_diff
        type: vlq_base128_le
        doc: |
          index into the field_ids list for the identity of this field
          (includes the name and descriptor), represented as a difference
          from the index of previous element in the list.

          The index of the first element in a list is represented directly.
      - id: access_flags
        type: vlq_base128_le
        doc: |
          access flags for the field (public, final, etc.).

          See "access_flags Definitions" for details.
  encoded_method:
    seq:
      - id: method_idx_diff
        type: vlq_base128_le
        doc: |
          index into the method_ids list for the identity of this method
          (includes the name and descriptor), represented as a difference
          from the index of previous element in the list.

          The index of the first element in a list is represented directly.
      - id: access_flags
        type: vlq_base128_le
        doc: |
          access flags for the field (public, final, etc.).

          See "access_flags Definitions" for details.
      - id: code_off
        type: vlq_base128_le
        doc: |
          offset from the start of the file to the code structure for this method,
          or 0 if this method is either abstract or native.

          The offset should be to a location in the data section.

          The format of the data is specified by "code_item" below.
  class_data_item:
    seq:
      - id: static_fields_size
        type: vlq_base128_le
        doc: |
          the number of static fields defined in this item
      - id: instance_fields_size
        type: vlq_base128_le
        doc: |
          the number of instance fields defined in this item
      - id: direct_methods_size
        type: vlq_base128_le
        doc: |
          the number of direct methods defined in this item
      - id: virtual_methods_size
        type: vlq_base128_le
        doc: |
          the number of virtual methods defined in this item
      - id: static_fields
        type: encoded_field
        repeat: expr
        repeat-expr: static_fields_size.value
        doc: |
          the defined static fields, represented as a sequence of encoded elements.

          The fields must be sorted by field_idx in increasing order.
      - id: instance_fields
        type: encoded_field
        repeat: expr
        repeat-expr: instance_fields_size.value
        doc: |
          the defined instance fields, represented as a sequence of encoded elements.

          The fields must be sorted by field_idx in increasing order.
      - id: direct_methods
        type: encoded_method
        repeat: expr
        repeat-expr: direct_methods_size.value
        doc: |
          the defined direct (any of static, private, or constructor) methods,
          represented as a sequence of encoded elements.

          The methods must be sorted by method_idx in increasing order.
      - id: virtual_methods
        type: encoded_method
        repeat: expr
        repeat-expr: virtual_methods_size.value
        doc: |
          the defined virtual (none of static, private, or constructor) methods,
          represented as a sequence of encoded elements.

          This list should not include inherited methods unless overridden by
          the class that this item represents.

          The methods must be sorted by method_idx in increasing order.

          The method_idx of a virtual method must not be the same as any direct method.
  map_item:
    -webide-representation: "{type}: offs={offset}, size={size}"
    seq:
      - id: type
        type: u2
        enum: map_item_type
        doc: |
          type of the items; see table below
      - id: unused
        type: u2
        doc: |
          (unused)
      - id: size
        type: u4
        doc: |
          count of the number of items to be found at the indicated offset
      - id: offset
        type: u4
        doc: |
          offset from the start of the file to the items in question
    enums:
      map_item_type:
        0x0000: header_item
        0x0001: string_id_item
        0x0002: type_id_item
        0x0003: proto_id_item
        0x0004: field_id_item
        0x0005: method_id_item
        0x0006: class_def_item
        0x0007: call_site_id_item
        0x0008: method_handle_item
        0x1000: map_list
        0x1001: type_list
        0x1002: annotation_set_ref_list
        0x1003: annotation_set_item
        0x2000: class_data_item
        0x2001: code_item
        0x2002: string_data_item
        0x2003: debug_info_item
        0x2004: annotation_item
        0x2005: encoded_array_item
        0x2006: annotations_directory_item
  map_list:
    seq:
      - id: size
        type: u4
      - id: list
        type: map_item
        repeat: expr
        repeat-expr: size
  type_item:
    seq:
      - id: type_idx
        type: u2
    instances:
      value:
        value: _root.type_ids[type_idx].type_name
  type_list:
    seq:
      - id: size
        type: u4
      - id: list
        type: type_item
        repeat: expr
        repeat-expr: size
enums:
  class_access_flags:
    0x0001: public     # public: visible everywhere
    0x0002: private    # * private: only visible to defining class
    0x0004: protected  # * protected: visible to package and subclasses
    0x0008: static     # * static: is not constructed with an outer this reference
    0x0010: final      # final: not subclassable
    0x0200: interface  # interface: multiply-implementable abstract class
    0x0400: abstract   # abstract: not directly instantiable
    0x1000: synthetic  # not directly defined in source code
    0x2000: annotation # declared as an annotation class
    0x4000: enum       # declared as an enumerated type
