meta:
  id: python_pickle
  title: Python pickle serialization format
  application: Python
  file-extension:
    - pickle
    - pkl
  xref:
    justsolve: Pickle
    wikidata: Q7190889
  license: CC0-1.0
  endian: le
doc: |
  Python Pickle format serializes Python objects to a byte stream, as a sequence
  of operations to run on the Pickle Virtual Machine.

  The format is mostly implementation defined, there is no formal specification.
  Pickle data types are closely coupled to the Python object model.
  Python singletons, and most builtin types (e.g. `None`, `int`,`dict`, `list`)
  are serialised using dedicated Pickle opcodes.
  Other builtin types, and all classes  (e.g. `set`, `datetime.datetime`) are
  serialised by encoding the name of a constructor callable.
  They are deserialised by importing that constructor, and calling it.
  So, unpickling an arbitrary pickle, using the Python's stdlib pickle module
  can cause arbitrary code execution.

  Pickle format has evolved with Python, later protocols add opcodes & types.
  Later Python releases can pickle to or unpickle from any earlier protocol.

  * Protocol 0: ASCII clean, no explicit version, fields are '\n' terminated.
  * Protocol 1: Binary, no explicit version, first length prefixed types.
  * Protocol 2: Python 2.3+. Explicit versioning, more length prefixed types.
    https://www.python.org/dev/peps/pep-0307/
  * Protocol 3: Python 3.0+. Dedicated opcodes for `bytes` objects.
  * Protocol 4: Python 3.4+. Opcodes for 64 bit strings, framing, `set`.
    https://www.python.org/dev/peps/pep-3154/
  * Protocol 5: Python 3.8+: Opcodes for `bytearray` and out of band data
    https://www.python.org/dev/peps/pep-0574/
doc-ref: https://github.com/python/cpython/blob/v3.8.1/Lib/pickletools.py
seq:
  # TODO is there a way to declare PROTO is optional, but only valid at position 0?
  - id: ops
    type: op
    repeat: until
    repeat-until: _.code == opcode::stop
types:
  op:
    seq:
      - id: code
        type: u1
        enum: opcode
        doc: |
          Operation code that determines which action should be
          performed next by the Pickle Virtual Machine. Some opcodes
          are only available in later versions of the Pickle protocol.
      - id: arg
        type:
          switch-on: code
          cases:
            'opcode::int': decimalnl_short
            'opcode::binint': s4
            'opcode::binint1': u1
            'opcode::binint2': u2
            'opcode::long': decimalnl_long
            'opcode::long1': long1
            'opcode::long4': long4
            'opcode::string': stringnl
            'opcode::binstring': string4
            'opcode::short_binstring': string1
            'opcode::binbytes': bytes4
            'opcode::short_binbytes': bytes1
            'opcode::binbytes8': bytes8
            'opcode::none': no_arg
            'opcode::newtrue': no_arg
            'opcode::newfalse': no_arg
            'opcode::unicode': unicodestringnl
            'opcode::short_binunicode': unicodestring1
            'opcode::binunicode': unicodestring4
            'opcode::binunicode8': unicodestring8
            'opcode::float': floatnl
            'opcode::binfloat': f8be
            'opcode::empty_list': no_arg
            'opcode::append': no_arg
            'opcode::appends': no_arg
            'opcode::list': no_arg
            'opcode::empty_tuple': no_arg
            'opcode::tuple': no_arg
            'opcode::tuple1': no_arg
            'opcode::tuple2': no_arg
            'opcode::tuple3': no_arg
            'opcode::empty_dict': no_arg
            'opcode::dict': no_arg
            'opcode::setitem': no_arg
            'opcode::setitems': no_arg
            'opcode::empty_set': no_arg
            'opcode::additems': no_arg
            'opcode::frozenset': no_arg
            'opcode::pop': no_arg
            'opcode::dup': no_arg
            'opcode::mark': no_arg
            'opcode::pop_mark': no_arg
            'opcode::get': decimalnl_short
            'opcode::binget': u1
            'opcode::long_binget': u4
            'opcode::put': decimalnl_short
            'opcode::binput': u1
            'opcode::long_binput': u4
            'opcode::memoize': no_arg
            'opcode::ext1': u1
            'opcode::ext2': u2
            'opcode::ext4': u4
            'opcode::global_opcode':  stringnl_noescape_pair
            'opcode::stack_global': no_arg
            'opcode::reduce': no_arg
            'opcode::build': no_arg
            'opcode::inst': stringnl_noescape_pair
            'opcode::obj': no_arg
            'opcode::newobj': no_arg
            'opcode::newobj_ex': no_arg
            'opcode::proto': u1
            'opcode::stop': no_arg
            'opcode::frame': u8
            'opcode::persid': stringnl_noescape
            'opcode::binpersid': no_arg
            'opcode::bytearray8': bytearray8
            'opcode::next_buffer': no_arg
            'opcode::readonly_buffer': no_arg
        doc: |
          Optional argument for the operation. Data type and length
          are determined by the value of the opcode.

  decimalnl_short:
    doc: |
      Integer or boolean, encoded with the ASCII characters [0-9-].

      The values '00' and '01' encode the Python values `False` and `True`.
      Normally a value would not contain leading '0' characters.
    seq:
      - id: val
        type: str
        encoding: ascii
        terminator: 0x0a # "\n"

  decimalnl_long:
    doc: Integer, encoded with the ASCII chracters [0-9-], followed by 'L'.
    seq:
      - id: val
        type: str
        encoding: ascii
        terminator: 0x0a # "\n"

  # TODO Can kaitai express constraint that these are quoted?
  stringnl:
    doc: Quoted string, possibly containing Python string escapes.
    seq:
      - id: val
        type: str
        encoding: ascii
        terminator: 0x0a # "\n"

  stringnl_noescape:
    doc: Unquoted string, does not contain string escapes.
    seq:
      - id: val
        type: str
        encoding: ascii
        terminator: 0x0a # "\n"

  stringnl_noescape_pair:
    doc: Pair of unquoted, unescaped strings.
    seq:
      - id: val1
        type: stringnl_noescape
      - id: val2
        type: stringnl_noescape

  unicodestringnl:
    doc: Unquoted string, containing Python Unicode escapes.
    seq:
      - id: val
        type: str
        encoding: ascii
        terminator: 0x0a # "\n"

  floatnl:
    doc: |
      Double float, encoded with the ASCII characters [0-9.e+-], '-inf', 'inf',
      or 'nan'.
    seq:
      - id: val
        type: str
        encoding: ascii
        terminator: 0x0a # "\n"

  long1:
    doc: |
      Large signed integer, in the range -2**(8*255-1) to 2**(8*255-1)-1,
      encoded as two's complement.
    seq:
      - id: len
        type: u1
      - id: val
        size: len

  long4:
    doc: |
      Large signed integer, in the range -2**(8*2**32-1) to 2**(8*2**32-1)-1,
      encoded as two's complement.
    seq:
      - id: len
        type: u4
      - id: val
        size: len

  string1:
    doc: |
      Length prefixed string, between 0 and 255 bytes long. Encoding is
      unspecified.

      The default Python 2.x string type (`str`) is a sequence of bytes.
      These are pickled as `string1` or `string4`, when protocol == 2.
      The bytes are written directly, no explicit encoding is performed.

      Python 3.x will not pickle an object as `string1` or `string4`.
      Instead, opcodes and types with a known encoding are used.
      When unpickling

      - `pickle.Unpickler` objects default to ASCII, which can be overriden
      - `pickletools.dis` uses latin1, and cannot be overriden
    doc-ref: https://github.com/python/cpython/blob/bb8071a4/Lib/pickle.py#L486-L495
    seq:
      - id: len
        type: u1
      - id: val
        size: len

  string4:
    doc: |
      Length prefixed string, between 0 and 2**31-1 bytes long. Encoding is
      unspecified.

      Although the len field is signed, any length < 0 will raise an exception
      during unpickling.

      See the documentation for `string1` for further detail about encodings.
    doc-ref: https://github.com/python/cpython/blob/bb8071a4/Lib/pickle.py#L486-L495
    seq:
      - id: len
        # Not a typo, the length really is a signed integer
        type: s4
      - id: val
        size: len

  bytes1:
    doc: Length prefixed byte string, between 0 and 255 bytes long.
    seq:
      - id: len
        type: u1
      - id: val
        size: len

  bytes4:
    doc: Length prefixed string, between 0 and 2**32-1 bytes long
    seq:
      - id: len
        type: u4
      - id: val
        size: len

  bytes8:
    doc: |
      Length prefixed string, between 0 and 2**64-1 bytes long.

      Only a 64-bit build of Python would produce a pickle containing strings
      large enough to need this type. Such a pickle could not be unpickled on
      a 32-bit build of Python, because the string would be larger than
      `sys.maxsize`.
    seq:
      - id: len
        type: u8
      - id: val
        size: len

  bytearray8:
    doc: |
      Length prefixed string, between 0 and 2**64-1 bytes long.

      The contents are deserilised into a `bytearray` object.
    seq:
      - id: len
        type: u8
      - id: val
        size: len

  unicodestring1:
    doc: Length prefixed string, between 0 and 255 bytes long
    seq:
      - id: len
        type: u1
      - id: val
        type: str
        encoding: utf8
        size: len

  unicodestring4:
    doc: Length prefixed string, between 0 and 2**32-1 bytes long
    seq:
      - id: len
        type: u4
      - id: val
        type: str
        encoding: utf8
        size: len

  unicodestring8:
    doc: |
      Length prefixed string, between 0 and 2**64-1 bytes long.

      Only a 64-bit build of Python would produce a pickle containing strings
      large enough to need this type. Such a pickle could not be unpickled on
      a 32-bit build of Python, because the string would be larger than
      `sys.maxsize`.
    seq:
      - id: len
        type: u8
      - id: val
        type: str
        encoding: utf8
        size: len

  no_arg:
    doc: Some opcodes take no argument, this empty type is used for them.

enums:
  opcode:
    0x28: # "("
      id: "mark"
      -orig-id: MARK
      doc: push special markobject on stack
    0x2e: # "."
      id: "stop"
      -orig-id: STOP
      doc: every pickle ends with STOP
    0x30: # "0"
      id: "pop"
      -orig-id: POP
      doc: discard topmost stack item
    0x31: # "1"
      id: "pop_mark"
      -orig-id: POP_MARK
      doc: discard stack top through topmost markobject
    0x32: # "2"
      id: "dup"
      -orig-id: DUP
      doc: duplicate top stack item
    0x46: # "F"
      id: "float"
      -orig-id: FLOAT
      doc: push float object; decimal string argument
    0x49: # "I"
      id: "int"
      -orig-id: INT
      doc: push integer or bool; decimal string argument
    0x4a: # "J"
      id: "binint"
      -orig-id: BININT
      doc: push four-byte signed int
    0x4b: # "K"
      id: "binint1"
      -orig-id: BININT1
      doc: push 1-byte unsigned int
    0x4c: # "L"
      id: "long"
      -orig-id: LONG
      doc: push long; decimal string argument
    0x4d: # "M"
      id: "binint2"
      -orig-id: BININT2
      doc: push 2-byte unsigned int
    0x4e: # "N"
      id: "none"
      -orig-id: NONE
      doc: push None
    0x50: # "P"
      id: "persid"
      -orig-id: PERSID
      doc: push persistent object; id is taken from string arg
    0x51: # "Q"
      id: "binpersid"
      -orig-id: BINPERSID
      doc: push persistent object; id is taken from stack
    0x52: # "R"
      id: "reduce"
      -orig-id: REDUCE
      doc: apply callable to argtuple, both on stack
    0x53: # "S"
      id: "string"
      -orig-id: STRING
      doc: push string; NL-terminated string argument
    0x54: # "T"
      id: "binstring"
      -orig-id: BINSTRING
      doc: push string; counted binary string argument
    0x55: # "U"
      id: "short_binstring"
      -orig-id: SHORT_BINSTRING
      doc: push string; counted binary string argument 256 bytes
    0x56: # "V"
      id: "unicode"
      -orig-id: UNICODE
      doc: push Unicode string; raw-unicode-escaped argument
    0x58: # "X"
      id: "binunicode"
      -orig-id: BINUNICODE
      doc: push Unicode string; counted UTF-8 string argument
    0x61: # "a"
      id: "append"
      -orig-id: APPEND
      doc: append stack top to list below it
    0x62: # "b"
      id: "build"
      -orig-id: BUILD
      doc: call __setstate__ or __dict__.update()
    0x63: # "c"
      id: "global_opcode"
      -orig-id: GLOBAL
      -affected-by: 90
      doc: |
        push self.find_class(modname, name); 2 string args

        As of KSC 0.9, this enum key can't be called `global` because it would
        cause a syntax error in Python (it is a keyword).
    0x64: # "d"
      id: "dict"
      -orig-id: DICT
      doc: build a dict from stack items
    0x7d: # "}"
      id: "empty_dict"
      -orig-id: EMPTY_DICT
      doc: push empty dict
    0x65: # "e"
      id: "appends"
      -orig-id: APPENDS
      doc: extend list on stack by topmost stack slice
    0x67: # "g"
      id: "get"
      -orig-id: GET
      doc: push item from memo on stack; index is string arg
    0x68: # "h"
      id: "binget"
      -orig-id: BINGET
      doc: push item from memo on stack; index is 1-byte arg
    0x69: # "i"
      id: "inst"
      -orig-id: INST
      doc: build & push class instance
    0x6a: # "j"
      id: "long_binget"
      -orig-id: LONG_BINGET
      doc: push item from memo on stack; index is 4-byte arg
    0x6c: # "l"
      id: "list"
      -orig-id: LIST
      doc: build list from topmost stack items
    0x5d: # "]"
      id: "empty_list"
      -orig-id: EMPTY_LIST
      doc: push empty list
    0x6f: # "o"
      id: "obj"
      -orig-id: OBJ
      doc: build & push class instance
    0x70: # "p"
      id: "put"
      -orig-id: PUT
      doc: store stack top in memo; index is string arg
    0x71: # "q"
      id: "binput"
      -orig-id: BINPUT
      doc: store stack top in memo; index is 1-byte arg
    0x72: # "r"
      id: "long_binput"
      -orig-id: LONG_BINPUT
      doc: store stack top in memo; index is 4-byte arg
    0x73: # "s"
      id: "setitem"
      -orig-id: SETITEM
      doc: add key+value pair to dict
    0x74: # "t"
      id: "tuple"
      -orig-id: TUPLE
      doc: build tuple from topmost stack items
    0x29: # ")"
      id: "empty_tuple"
      -orig-id: EMPTY_TUPLE
      doc: push empty tuple
    0x75: # "u"
      id: "setitems"
      -orig-id: SETITEMS
      doc: modify dict by adding topmost key+value pairs
    0x47: # "G"
      id: "binfloat"
      -orig-id: BINFLOAT
      doc: push float; arg is 8-byte float encoding

    # Protocol 2
    0x80:
      id: "proto"
      -orig-id: PROTO
      doc: identify pickle protocol
    0x81:
      id: "newobj"
      -orig-id: NEWOBJ
      doc: build object by applying cls.__new__ to argtuple
    0x82:
      id: "ext1"
      -orig-id: EXT1
      doc: push object from extension registry; 1-byte index
    0x83:
      id: "ext2"
      -orig-id: EXT2
      doc: ditto, but 2-byte index
    0x84:
      id: "ext4"
      -orig-id: EXT4
      doc: ditto, but 4-byte index
    0x85:
      id: "tuple1"
      -orig-id: TUPLE1
      doc: build 1-tuple from stack top
    0x86:
      id: "tuple2"
      -orig-id: TUPLE2
      doc: build 2-tuple from two topmost stack items
    0x87:
      id: "tuple3"
      -orig-id: TUPLE3
      doc: build 3-tuple from three topmost stack items
    0x88:
      id: "newtrue"
      -orig-id: NEWTRUE
      doc: push True
    0x89:
      id: "newfalse"
      -orig-id: NEWFALSE
      doc: push False
    0x8a:
      id: "long1"
      -orig-id: LONG1
      doc: push long from < 256 bytes
    0x8b:
      id: "long4"
      -orig-id: LONG4
      doc: push really big long

    # Protocol 3 (Python 3.x)
    0x42: # "B"
      id: "binbytes"
      -orig-id: BINBYTES
      doc: push bytes; counted binary string argument
    0x43: # "C"
      id: "short_binbytes"
      -orig-id: SHORT_BINBYTES
      doc: push bytes; counted binary string argument < 256 bytes

    # Protocol 4
    0x8c:
      id: "short_binunicode"
      -orig-id: SHORT_BINUNICODE
      doc: push short string; UTF-8 length < 256 bytes
    0x8d:
      id: "binunicode8"
      -orig-id: BINUNICODE8
      doc: push very long string
    0x8e:
      id: "binbytes8"
      -orig-id: BINBYTES8
      doc: push very long bytes string
    0x8f:
      id: "empty_set"
      -orig-id: EMPTY_SET
      doc: push empty set on the stack
    0x90:
      id: "additems"
      -orig-id: ADDITEMS
      doc: modify set by adding topmost stack items
    0x91:
      id: "frozenset"
      -orig-id: FROZENSET
      doc: build frozenset from topmost stack items
    0x92:
      id: "newobj_ex"
      -orig-id: NEWOBJ_EX
      doc: like NEWOBJ but work with keyword only arguments
    0x93:
      id: "stack_global"
      -orig-id: STACK_GLOBAL
      doc: same as GLOBAL but using names on the stacks
    0x94:
      id: "memoize"
      -orig-id: MEMOIZE
      doc: store top of the stack in memo
    0x95:
      id: "frame"
      -orig-id: FRAME
      doc: indicate the beginning of a new frame

    # Protocol 5
    0x96:
      id: "bytearray8"
      -orig-id: "BYTEARRAY8"
      doc: push bytearray
    0x97:
      id: "next_buffer"
      -orig-id: "NEXT_BUFFER"
      doc: push next out-of-band buffer
    0x98:
      id: "readonly_buffer"
      -orig-id: "READONLY_BUFFER"
      doc: make top of stack readonly
