meta:
  id: qsp
  title: Quest Soft Player (QSP) Game
  application: Quest Soft Player
  file-extension: qsp
  endian: le
  encoding: utf-16le   # in fact "ucs-2le"
  license: Unlicense
doc: |
  QSP is a player for text quests written in a QSP language.

doc-ref:
  - https://github.com/QSPFoundation/qsp/blob/master/help/gam_desc.txt

seq:
  - id: signature
    contents: [Q, 0, S, 0, P, 0, G, 0, A, 0, M, 0, E, 0, 0x0D, 0, 0x0A, 0]      #QSPGAME
    if: format_version >= 1
  - id: version
    type: usual_str
    if: format_version >= 1
  - id: password
    type: rot5_str
    if: format_version >= 1
  - id: locations_count_str
    type:
      switch-on: format_version >= 1
      cases:
        true: rot5_number_str
        false: number_str
  - id: locations
    type: loc
    repeat: expr
    repeat-expr: locations_count
instances:
  format_version:
    value: 1
    doc: |
      gam = 0
      qsp = 1

  locations_count:
    value: (format_version >= 1?locations_count_str.as<rot5_number_str>.number:locations_count_str.as<number_str>.number)
types:
  string_placeholder:
    doc: |
      Computes offset and size of the string terminated by \r\n
      WARNING: some so(u)rcery follows
    -affected-by: 538
    seq:
      - id: placeholder
        type: char
        if: pos > -1 # to trigger getting and caching it
      - size: 0
        if: size > -1 # to trigger computing and caching it
    instances:
      pos:
        value: _io.pos # populated in the beginning
      size_full:
        value: _io.pos - pos
      size:
        value: size_full - 4 # final \r\n are unneeded
    types:
      char:
        seq:
          - id: c
            type: u2le
            repeat: until
            repeat-until: _ == 0x0D
          - id: c2
            type: u2le
          - id: next
            type: char
            if: c2 != 0x0A
  usual_str:
    seq:
      - id: placeholder
        type: string_placeholder

    instances:
      val:
        size: placeholder.size
        pos: placeholder.pos
        type: str
  wrapped_str:
    doc: just a str wrapped in a type to overcome a bug in KSC
    -affected-by: 503
    seq:
      - id: val
        type: str
        size-eos: true
  rot5_str:
    -orig-id: $$кодированная строка   # "encoded string", in Russian
    doc: According to the official docs it allows to put multiple lines into a single line.
    seq:
      - id: placeholder
        type: string_placeholder
    instances:
      val:
        value: derot.val
      derot:
        size: placeholder.size
        pos: placeholder.pos
        type: wrapped_str
        process: rot(5, 2)
        doc: |
          import struct
          sizes = {1: "B", 2: "H", 4: "I", 8: "Q"}
          endiannesses = {"": "", "le": "<", "be": ">"}

          def isPowerOf2(x: int) -> bool:
              return bool((x - 1) & x)

          class GFOp:
              __slots__ = ("chunkSize", "s", "scaleFixer", "min")
              
              def __init__(self, chunkSize: int = 1, endianness: str = "", min: int = 0, scale: int = None):
                  self.chunkSize = chunkSize
                  self.s = struct.Struct("".join((endiannesses[endianness], sizes[chunkSize])))
                  if scale is None:
                      scale = 2 ** (8 * chunkSize) - min
                  
                  if isPowerOf2(scale):
                      mask = scale - 1
                      self.scaleFixer = lambda x: x & mask
                  else:
                      self.scaleFixer = lambda x: x % scale
                  
                  self.min = min
              
              def processFunc(self, val):
                  raise NotImplementedError()
              
              def decode(self, data):
                  l = len(data)
                  result = bytearray(l)
                  ptr = 0
                  while ptr < l:
                      nextPtr = ptr + self.chunkSize
                      result[ptr:nextPtr] = self.s.pack(self.processFunc(self.s.unpack(data[ptr:nextPtr])[0]))
                      ptr = nextPtr
                  return bytes(result)

          class Rot(GFOp):
              __slots__ = ("rotValue",)
              
              def __init__(self, rotValue: int = 13, chunkSize: int = 1, endianness: str = "", min: int = 0, scale: int = None):
                  super().__init__(chunkSize=chunkSize, endianness=endianness, min=min, scale=scale)
                  self.rotValue = rotValue
              
              def processFunc(self, val):
                  return self.min + self.scaleFixer(val - self.min + self.rotValue)

          r = Rot()
          r.decode(r.decode(b"abcd"))

  number_str:
    -orig-id: "#число" # 'number' in Russian
    seq:
      - id: str
        type: usual_str
    instances:
      number:
        value: str.val.to_i
  rot5_number_str:
    -orig-id: "##кодированное число" # 'encoded number' in Russian
    seq:
      - id: str
        type: rot5_str
    instances:
      number:
        value: str.val.to_i
  loc:
    seq:
      - id: name
        type: rot5_str
      - id: descr
        type: rot5_str
      - id: code
        type: rot5_str
      - id: actions_count_new
        type: rot5_number_str
        if: _root.format_version >= 1
      - id: actions
        type: act
        repeat: expr
        repeat-expr: actions_count
    instances:
      actions_count:
        value: (_root.format_version >= 1?actions_count_new.number:20)
    types:
      act:
        doc: Action for a user to choose
        seq:
          - id: image_path
            type: rot5_str
          - id: name
            type: rot5_str
          - id: code
            type: rot5_str
  game_state:
    meta:
      file-extension: sav
    doc: Save file format
    seq:
      - id: game_id
        type: usual_str
      - id: qsp_version
        type: usual_str
      - id: quest_crc
        type: rot5_number_str
      - id: time
        type: rot5_number_str

        #from here they are prefixed with qsp in source code
      - id: cur_sel_action
        type: rot5_number_str
      - id: cur_sel_object
        type: rot5_number_str
      - id: view_path
        type: rot5_str
      - id: cur_input
        type: rot5_str
      - id: cur_desc
        type: rot5_str
      - id: cur_vars
        type: rot5_str
      - id: loc_name
        type: rot5_str
      - id: cur_is_show_acts
        type: rot5_number_str
      - id: cur_is_show_objs
        type: rot5_number_str
      - id: cur_is_show_vars
        type: rot5_number_str
      - id: cur_is_show_input
        type: rot5_number_str
      - id: timer_interval
        type: rot5_number_str

      - id: pl_files_count
        type: rot5_number_str
      - id: pl_files
        type: rot5_str
        repeat: expr
        repeat-expr: pl_files_count.number

      - id: cur_inc_files_count
        type: rot5_number_str
      - id: cur_inc_files
        type: rot5_str
        repeat: expr
        repeat-expr: cur_inc_files_count.number

      - id: cur_actions_count_new
        type: rot5_number_str
        if: _root.format_version >= 1
      - id: cur_actions
        type: save_act
        repeat: expr
        repeat-expr: cur_actions_count

      - id: cur_objects_count
        type: rot5_number_str
      - id: cur_objects
        type: obj
        repeat: expr
        repeat-expr: cur_objects_count.number

      - id: get_vars_count
        type: rot5_number_str
      - id: vars
        type: var
        repeat: expr
        repeat-expr: get_vars_count.number
    instances:
      cur_actions_count:
        value: _root.format_version >= 1?cur_actions_count_new.number:20
    types:
      index:
        seq:
          - id: index
            type: rot5_number_str
          - id: str
            type: rot5_str
      var:
        seq:
          - id: index
            type: rot5_number_str
          - id: name
            type: rot5_str
          - id: vals_count
            type: rot5_number_str
          - id: values
            type: value
            repeat: expr
            repeat-expr: vals_count.number
          - id: inds_count
            type: rot5_number_str
          - id: indices
            type: index
            repeat: expr
            repeat-expr: inds_count.number
        types:
          value:
            seq:
              - id: num
                type: rot5_number_str
              - id: str
                type: rot5_str
      save_act:
        seq:
          - id: image_path
            type: rot5_str
          - id: name
            type: rot5_str

          - id: on_press_lines_count
            type: rot5_number_str
          - id: on_press_lines
            type: line
            repeat: expr
            repeat-expr: on_press_lines_count.number

          - id: location
            type: rot5_number_str
          - id: actindex
            type: rot5_number_str
          - id: start_line
            type: rot5_number_str
          - id: is_manage_lines
            type: rot5_number_str
        types:
          line:
            doc: Line of source code in QSP lang
            seq:
              - id: str
                type: rot5_str
              - id: line_num
                type: rot5_number_str
      obj:
        seq:
          - id: image_path
            type: rot5_str
          - id: descr
            type: rot5_str
