# TODO: Support NES 2.0
meta:
  id: ines
  file-extension: nes
  license: WTFPL
  encoding: ASCII
doc-ref: https://wiki.nesdev.com/w/index.php/INES
seq:
  - id: header
    size: 16
    type: header
  - id: trainer
    size: 512
    if: header.f6.trainer
  - id: prg_rom
    size: header.len_prg_rom * 16384
  - id: chr_rom
    size: header.len_chr_rom * 8192
  - id: playchoice10
    type: playchoice10
    if: header.f7.playchoice10
  - id: title
    size-eos: true # Usually only 128/127 bytes
    type: str
    if: not _io.eof
types:
  header:
    seq:
      - id: magic
        contents: [NES, 0x1A]
      - id: len_prg_rom
        type: u1
        doc: Size of PRG ROM in 16 KB units
      - id: len_chr_rom
        type: u1
        doc: Size of CHR ROM in 8 KB units (Value 0 means the board uses CHR RAM)
      - id: f6
        size: 1
        type: f6
      - id: f7
        size: 1
        type: f7
      - id: len_prg_ram
        type: u1
        doc: Size of PRG RAM in 8 KB units (Value 0 infers 8 KB for compatibility; see PRG RAM circuit on nesdev.com)
      - id: f9
        size: 1
        type: f9
      - id: f10
        size: 1
        type: f10
        doc: this one is unofficial
      - id: reserved
        contents: [0, 0, 0, 0, 0]
    instances:
      # TODO: Add an enum for mapper. https://wiki.nesdev.com/w/index.php/List_of_mappers
      mapper:
        value: f6.lower_mapper | (f7.upper_mapper << 4)
        doc-ref: https://wiki.nesdev.com/w/index.php/Mapper
    types:
      f6:
        doc-ref: https://wiki.nesdev.com/w/index.php/INES#Flags_6
        seq:
          - id: lower_mapper
            type: b4
            doc: Lower nibble of mapper number
          - id: four_screen
            type: b1
            doc: Ignore mirroring control or above mirroring bit; instead provide four-screen VRAM
          - id: trainer
            type: b1
            doc: 512-byte trainer at $7000-$71FF (stored before PRG data)
          - id: has_battery_ram
            type: b1
            doc: If on the cartridge contains battery-backed PRG RAM ($6000-7FFF) or other persistent memory
          - id: mirroring
            type: b1
            enum: mirroring
            doc: if 0, horizontal arrangement. if 1, vertical arrangement
        enums:
          mirroring:
            0: horizontal
            1: vertical
      f7:
        doc-ref: https://wiki.nesdev.com/w/index.php/INES#Flags_7
        seq:
          - id: upper_mapper
            type: b4
            doc: Upper nibble of mapper number
          - id: format
            type: b2
            doc: If equal to 2, flags 8-15 are in NES 2.0 format
          - id: playchoice10
            type: b1
            doc: Determines if it made for a Nintendo PlayChoice-10 or not
          - id: vs_unisystem
            type: b1
            doc: Determines if it is made for a Nintendo VS Unisystem or not
      f9:
        doc-ref: https://wiki.nesdev.com/w/index.php/INES#Flags_9
        seq:
          # TODO: enforce zero (similarly to "contents", but on bit level)
          - id: reserved
            type: b7
          - id: tv_system
            type: b1
            enum: tv_system
            doc: if 0, NTSC. If 1, PAL.
        enums:
          tv_system:
            0: ntsc
            1: pal
      f10:
        doc-ref: https://wiki.nesdev.com/w/index.php/INES#Flags_10
        seq:
          # TODO: enforce zero (similarly to "contents", but on bit level)
          - id: reserved1
            type: b2
          - id: bus_conflict
            type: b1
            doc: If 0, no bus conflicts. If 1, bus conflicts.
          # TODO: 0 = true, 1 = false in this case
          - id: prg_ram
            type: b1
            doc: If 0, PRG ram is present. If 1, not present.
          # TODO: enforce zero (similarly to "contents", but on bit level)
          - id: reserved2
            type: b2
          - id: tv_system
            type: b2
            enum: tv_system
            doc: if 0, NTSC. If 2, PAL. If 1 or 3, dual compatible.
        enums:
          tv_system:
            0: ntsc
            1: dual1
            2: pal
            3: dual2
  playchoice10:
    doc-ref: http://wiki.nesdev.com/w/index.php/PC10_ROM-Images
    seq:
      - id: inst_rom
        size: 8192
      - id: prom
        type: prom
    types:
      prom:
        seq:
          - id: data
            size: 16
          - id: counter_out
            size: 16
