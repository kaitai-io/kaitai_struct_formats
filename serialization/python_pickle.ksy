meta:
  id: python_pickle
  title: Python pickle serialization format (protocol 3)
  application: Python
  file-extension:
    - pickle
    - pkl
  license: CC0-1.0
  endian: le
  xref:
    justsolve: Pickle
    wikidata: Q7190889
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
doc-ref:  https://github.com/python/cpython/blob/3.3/Lib/pickletools.py
seq:
  # TODO is there a way to declare PROTO is optional, but only valid at position 0?
  - id: ops
    type: op
    repeat: eos
  # TODO is there a way to declare a trailing STOP is required?
types:
  op:
    seq:
      - id: code
        type: u1
        enum: opcode
        doc: |
          Operation code that determines which action should be
          performed next by the Pickel Virtual Machine. Some opcodes
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
            'opcode::none': no_arg
            'opcode::newtrue': no_arg
            'opcode::newfalse': no_arg
            'opcode::unicode': unicodestringnl
            'opcode::binunicode': unicodestring4
            'opcode::float': floatnl
            'opcode::binfloat': f8
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
            'opcode::ext1': u1
            'opcode::ext2': u2
            'opcode::ext4': u4
            'opcode::global':  stringnl_noescape_pair
            'opcode::reduce': no_arg
            'opcode::build': no_arg
            'opcode::inst': stringnl_noescape_pair
            'opcode::obj': no_arg
            'opcode::newobj': no_arg
            'opcode::proto': u1
            'opcode::stop': no_arg
            'opcode::persid': stringnl_noescape
            'opcode::binpersid': no_arg
        doc: |
          Optional argument for the operation. Data type and length
          are determined by the value of the opcode.

  decimalnl_short:
    seq:
      - id: val
        type: str
        encoding: ASCII
        terminator: 0x0a # "\n"
    doc: Integer, encoded with the ASCII characters [0-9-].
  decimalnl_long:
    seq:
      - id: val
        type: str
        encoding: ASCII
        terminator: 0x0a # "\n"
    doc: Integer, encoded with the ASCII chracters [0-9-], followed by 'L'.
  # TODO Can kaitai express constraint that these are quoted?
  stringnl:
    seq:
      - id: val
        type: str
        encoding: ASCII
        terminator: 0x0a # "\n"
    doc: Quoted string, possibly containing Python string escapes.
  stringnl_noescape:
    seq:
      - id: val
        type: str
        encoding: ASCII
        terminator: 0x0a # "\n"
    doc: Unquoted string, does not contain string escapes.
  stringnl_noescape_pair:
    seq:
      - id: val1
        type: stringnl_noescape
      - id: val2
        type: stringnl_noescape
    doc: Pair of unquoted, unescaped strings.
  unicodestringnl:
    seq:
      - id: val
        type: str
        encoding: ASCII
        terminator: 0x0a # "\n"
    doc: Unquoted string, containing Python Unicode escapes.
  floatnl:
    seq:
      - id: val
        type: str
        encoding: ASCII
        terminator: 0x0a # "\n"
    doc: |
      Double float, encoded with the ASCII characters [0-9.e+-], '-inf', 'inf',
      or 'nan'.
  long1:
    seq:
      - id: len
        type: u1
      - id: val
        size: len
    doc: |
      Large signed integer, in the range -2**(8*255-1) to 2**(8*255-1)-1,
      encoded as two's complement.
  long4:
    seq:
      - id: len
        type: u4
      - id: val
        size: len
    doc: |
      Large signed integer, in the range -2**(8*2**32-1) to 2**(8*2**32-1)-1,
      encoded as two's complement.
  string1:
    seq:
      - id: len
        type: u1
      - id: val
        type: str
        encoding: latin1
        size: len
    doc: Length prefixed string, between 0 and 255 bytes long.
  string4:
    seq:
      - id: len
        # Not a typo, the length really is a signed integer
        type: s4
      - id: val
        type: str
        encoding: latin1
        size: len
    doc: Length prefixed string, between 0 and 2**31-1 bytes long
  bytes1:
    seq:
      - id: len
        type: u1
      - id: val
        size: len
    doc: Length prefixed byte string, between 0 and 255 bytes long.
  bytes4:
    seq:
      - id: len
        type: u4
      - id: val
        size: len
    doc: Length prefixed string, between 0 and 2**31-1 bytes long
  unicodestring4:
    seq:
      - id: len
        type: u4
      - id: val
        type: str
        encoding: utf8
        size: len
    doc: Length prefixed string, between 0 and 2**32-1 bytes long
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
        id: "global"
        -orig-id: GLOBAL
        doc: push self.find_class(modname, name); 2 string args
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

    #'I01\n':
    #    id: "true"
    #    doc: not an opcode; see INT docs in pickletools.py
    #'I00\n':
    #    id: "false"
    #    doc: not an opcode; see INT docs in pickletools.py

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
