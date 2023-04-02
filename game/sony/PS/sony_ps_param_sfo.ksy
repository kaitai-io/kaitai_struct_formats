meta:
  id: sony_ps_param_sfo
  title: Sony PlayStation metadata file (PARAM.SFO)
  endian: le
  encoding: utf-8
  license: Unlicense
  file-extension: SFO
doc: |
  Sony PlayStation is a popular game console series. PlayStation Portable is a portable one which was popular in 200x. Currently this file describes only the subset of the files available on PSP used for games saves metadata, though the format is used on most of PS consoles. Despite applications can use any files in the flash, the system has only GUI for choosing of saves. Each save is a subfolder in ms0:/PSP/SAVEDATA/ containing a set of files. PARAM.SFO is a mandatory metadata file created by sceUtilitySavedataInitStart function (and the underlying syscall). You can get these files by saving a game on PSP and then connecting it to a PC. Or you can use an emulator like [PPSSPP](https://github.com/hrydgard/ppsspp).
seq:
  - id: header
    type: header
  - id: count
    type: u4
  - id: descriptors
    type: descriptor
    repeat: expr
    repeat-expr: count
  - id: names
    type: strz
    repeat: expr
    repeat-expr: count
  - id: unkn0
    type: u1
  - id: sections
    type: section(descriptors[_index].size, names[_index])
    repeat: expr
    repeat-expr: count
types:
  section:
    params:
      - id: size
        type: u4
      - id: name
        type: str
    seq:
      - id: section
        size: size
        type:
          switch-on: name
          cases:
            "'CATEGORY'": category
            "'PARENTAL_LEVEL'": u4 # I guess it is min allowed age
            "'SAVEDATA_DETAIL'": strz # the string displayed in save description
            "'SAVEDATA_DIRECTORY'": strz # the name of the directory where a save is saved
            "'SAVEDATA_FILE_LIST'": savedata_file_list
            "'SAVEDATA_PARAMS'": savedata_params # don't know what is it
            "'SAVEDATA_TITLE'": strz # arbitrary string, usually contains a name of a player or a anme of last played level
            "'TITLE'": strz # contains a name of a game
    types:
      savedata_file_list:
        doc: I guess list of files with their "crypto" keys
        seq:
          - id: file_descriptors
            type: file_descriptor
            repeat: eos
        types:
          file_descriptor:
            seq:
              - id: file_name
                size: 13
                type: strz
              - id: mac
                size: 16
                doc: "message authentication code"
              - id: unkn
                size: 3
                doc: a wild guess that there is no need to restrict the name with 13 bytes 

      savedata_params:
        seq:
          - id: unkn
            size-eos: true
      category:
        seq:
          - id: unkn
            size-eos: true
  header:
    seq:
      - id: signature
        contents: [0, "PSF"]
      - id: unkn0
        type: u4
      - id: unkn1
        type: u4
      - id: unkn2
        type: u4
  descriptor:
    seq:
      - id: num
        type: b4
      - id: unkn0
        type: b4
      - id: unkn1
        type: u1
      - id: flags
        type: u2
      - id: unkn3
        type: u4
      - id: size
        type: u4
      - id: unkn5
        type: u4
