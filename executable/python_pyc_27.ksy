# http://demoseen.com/blog/2010-02-20_Python_Marshal_Format.html
# https://github.com/python/cpython/blob/master/Lib/dis.py
# https://github.com/python/cpython/blob/master/Lib/opcode.py
# https://github.com/python/cpython/blob/2.7/Lib/dis.py
# https://github.com/python/cpython/blob/2.7/Lib/opcode.py
meta:
  id: python_pyc_27
  application: Python
  file-extension: pyc
  license: CC0-1.0
  endian: le
doc: |
  Python interpreter runs .py files in 2 step process: first, it
  produces bytecode, which it then executes. Translation of .py source
  into bytecode is time-consuming, so Python dumps compiled bytecode
  into .pyc files, to be reused from cache at later time if possible.

  .pyc file is essentially a raw dump of `py_object` (see `body`) with
  a simple header prepended.
seq:
  - id: version_magic
    type: u2
    enum: version
  - id: crlf
    type: u2
  - id: modification_timestamp
    type: u4
  - id: body
    type: py_object
types:
  assembly:
    seq:
      - id: string_magic
        contents: "s"
      - id: length
        type: u4
      - id: items
        size: length
        type: op_args
  op_args:
    seq:
      - id: items
        type: op_arg
        repeat: eos
  op_arg:
    seq:
      - id: op_code
        type: u1
        enum: op_code_enum
      - id: arg
        type: u2
        if: "op_code.to_i >= op_code_enum::store_name.to_i" # store_name == have_arguments
    -webide-representation: "{op_code} {arg}"
    enums:
      op_code_enum:
        0  : stop_code
        1  : pop_top
        2  : rot_two
        3  : rot_three
        4  : dup_top
        5  : rot_four
        9  : nop
        10 : unary_positive
        11 : unary_negative
        12 : unary_not
        13 : unary_convert
        15 : unary_invert
        19 : binary_power
        20 : binary_multiply
        21 : binary_divide
        22 : binary_modulo
        23 : binary_add
        24 : binary_subtract
        25 : binary_subscr
        26 : binary_floor_divide
        27 : binary_true_divide
        28 : inplace_floor_divide
        29 : inplace_true_divide
        30 : slice_0
        31 : slice_1
        32 : slice_2
        33 : slice_3
        40 : store_slice_0
        41 : store_slice_1
        42 : store_slice_2
        43 : store_slice_3
        50 : delete_slice_0
        51 : delete_slice_1
        52 : delete_slice_2
        53 : delete_slice_3
        54 : store_map
        55 : inplace_add
        56 : inplace_subtract
        57 : inplace_multiply
        58 : inplace_divide
        59 : inplace_modulo
        60 : store_subscr
        61 : delete_subscr
        62 : binary_lshift
        63 : binary_rshift
        64 : binary_and
        65 : binary_xor
        66 : binary_or
        67 : inplace_power
        68 : get_iter
        70 : print_expr
        71 : print_item
        72 : print_newline
        73 : print_item_to
        74 : print_newline_to
        75 : inplace_lshift
        76 : inplace_rshift
        77 : inplace_and
        78 : inplace_xor
        79 : inplace_or
        80 : break_loop
        81 : with_cleanup
        82 : load_locals
        83 : return_value
        84 : import_star
        85 : exec_stmt
        86 : yield_value
        87 : pop_block
        88 : end_finally
        89 : build_class
        90 : store_name           # Index in name list
        91 : delete_name          # ""
        92 : unpack_sequence      # Number of tuple items
        93 : for_iter
        94 : list_append
        95 : store_attr           # Index in name list
        96 : delete_attr          # ""
        97 : store_global         # ""
        98 : delete_global        # ""
        99 : dup_topx             # number of items to duplicate
        100: load_const           # Index in const list
        101: load_name            # Index in name list
        102: build_tuple          # Number of tuple items
        103: build_list           # Number of list items
        104: build_set            # Number of set items
        105: build_map            # Number of dict entries (upto 255)
        106: load_attr            # Index in name list
        107: compare_op           # Comparison operator
        108: import_name          # Index in name list
        109: import_from          # Index in name list
        110: jump_forward         # Number of bytes to skip
        111: jump_if_false_or_pop # Target byte offset from beginning of code
        112: jump_if_true_or_pop  # ""
        113: jump_absolute        # ""
        114: pop_jump_if_false    # ""
        115: pop_jump_if_true     # ""
        116: load_global          # Index in name list
        119: continue_loop        # Target address
        120: setup_loop           # Distance to target address
        121: setup_except         # ""
        122: setup_finally        # ""
        124: load_fast            # Local variable number
        125: store_fast           # Local variable number
        126: delete_fast          # Local variable number
        130: raise_varargs        # Number of raise arguments (1, 2, or 3)
        131: call_function        # #args + (#kwargs << 8)
        132: make_function        # Number of args with default values
        133: build_slice          # Number of items
        134: make_closure
        135: load_closure
        136: load_deref
        137: store_deref
        140: call_function_var    # #args + (#kwargs << 8)
        141: call_function_kw     # #args + (#kwargs << 8)
        142: call_function_var_kw # #args + (#kwargs << 8)
        143: setup_with
        145: extended_arg
        146: set_add
        147: map_add
  code_object:
    seq:
      - id: arg_count   # argcount
        type: u4
      - id: local_count # nlocals
        type: u4
      - id: stack_size
        type: u4
      - id: flags
        type: u4
        enum: flags_enum
      - id: code
        type: assembly
      - id: consts
        type: py_object
      - id: names
        type: py_object
      - id: var_names
        type: py_object
      - id: free_vars
        type: py_object
      - id: cell_vars
        type: py_object
      - id: filename
        type: py_object
      - id: name
        type: py_object
      - id: first_line_no
        type: u4
      - id: lnotab
        type: py_object
    -webide-representation: "{name.value}"
    enums:
      flags_enum:
        0x04: has_args
        0x08: has_kwargs
        0x20: generator
  py_object:
    seq:
      - id: type
        type: u1
        enum: object_type
      - id: value
        type:
          switch-on: type
          cases:
            "object_type::code_object": code_object
            "object_type::string":      py_string
            "object_type::string_ref":  string_ref
            "object_type::interned":    interned_string
            "object_type::tuple":       tuple
            "object_type::int":         u4
            "object_type::py_false":    py_false
            "object_type::py_true":     py_true
            "object_type::none":        py_none
    -webide-representation: "{type}: {value}"
    types:
      py_string:
        seq:
          - id: length
            type: u4
          - id: data
            size: length
        -webide-representation: "{data}"
      interned_string:
        seq:
          - id: length
            type: u4
          - id: data
            type: str
            size: length
            encoding: utf-8
        -webide-representation: "{data}"
      string_ref:
        seq:
          - id: interned_list_index
            type: u4
        -webide-representation: "#{interned_list_index:dec}"
      unicode_string:
        seq:
          - id: length
            type: u4
          - id: data
            size: length
            type: str
            encoding: utf-8
        -webide-representation: "{data}"
      tuple:
        seq:
          - id: count
            type: u4
          - id: items
            type: py_object
            repeat: expr
            repeat-expr: count
        -webide-representation: "{count:dec} items"
      py_none:
        -webide-representation: "None"
      py_true:
        -webide-representation: "true"
      py_false:
        -webide-representation: "false"
    enums:
      object_type:
        40: tuple             # (
        70: py_false          # F
        78: none              # N
        82: string_ref        # R
        84: py_true           # T
        99: code_object       # c
        105: int              # i
        115: string           # s
        116: interned         # t
        117: unicode_string   # u
enums:
  # http://svn.python.org/view/python/trunk/Python/import.c?view=markup
  version:
    20121: v15
    50428: v16
    50823: v20
    60202: v21
    60717: v22
    62011: v23_a0
    62021: v23_a0b
    62041: v24_a0
    62051: v24_a3
    62061: v24_b1
    62071: v25_a0
    62081: v25_a0b
    62091: v25_a0c
    62092: v25_a0d
    62101: v25_b3
    62111: v25_b3b
    62121: v25_c1
    62131: v25_c2
    62151: v26_a0
    62161: v26_a1
    62171: v27_a0
    62181: v27_a0b
    62191: v27_a0c
    62201: v27_a0d
    62211: v27_a0e
