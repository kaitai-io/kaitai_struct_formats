# TODO: Add an enum for mapper. https://wiki.nesdev.com/w/index.php/Mapper
meta:
  id: ines
  file-extension:
    - nes
    - ines
  endian: le
  license: WTFPL
seq:
  - id: header
    type: header
  - id: rom
    size-eos: true
types:
  header:
    seq:
      - id: magic
        contents: [NES, 0x1A]
      - id: prg_rom_size
        type: u1
        doc: Size of PRG ROM in 16 KB units
      - id: chr_rom_size
        type: u1
        doc: Size of CHR ROM in 8 KB units (Value 0 means the board uses CHR RAM)
      - id: f6
        type: f6
      - id: f7
        type: f7
      - id: prg_ram_size
        type: u1
        doc: Size of PRG RAM in 8 KB units (Value 0 infers 8 KB for compatibility; see PRG RAM circuit on nesdev.com)
      - id: f9
        type: f9
      - id: f10
        type: f10
        doc: this one is unofficial
      - id: zero_fill
        size: 4
  f6:
    seq:
      - id: lower_nibble
        type: b4
        doc: Lower nibble of mapper number (see https://wiki.nesdev.com/w/index.php/Mapper)
      - id: ignore_mirror
        type: b1
        doc: Ignore mirroring control or above mirroring bit; instead provide four-screen VRAM
      - id: trainer
        type: b1
        doc: 512-byte trainer at $7000-$71FF (stored before PRG data)
      - id: has_battery_ram
        type: b1
        doc: If on the cartridge contains battery-backed PRG RAM ($6000-7FFF) or other persistent memory
      - id: mirror
        type: b1
        doc: if 0, horizontal arrangement. if 1, vertical arrangement
  f7:
    seq:
      - id: upper_nibble
        type: b4
        doc: Upper nibble of mapper number (see https://wiki.nesdev.com/w/index.php/Mapper)
      - id: format
        type: b2
        doc: If equal to 2, flags 8-15 are in NES 2.0 format
      - id: arcade_2
        type: b1
        doc: Determines if it made for a Nintendo PlayChoice-10 or not
      - id: arcade_1
        type: b1
        doc: Determines if it is made for a Nintendo VS Unisystem or not
  f9:
    seq:
      - id: reserved
        type: b7
      - id: tv_system
        type: b1
        doc: if 0, NTSC. If 1, PAL.

  f10:
    seq:
      - id: nothing1
        type: b2
      - id: bus_conflict
        type: b1
        doc: If 0, no bus conflicts. If 1, bus conflicts.
      - id: prg_ram
        type: b1
        doc: If 0, PRG ram is present. If 1, not present.
      - id: nothing2
        type: b2
      - id: tv_system
        type: b2
        doc: if 0, NTSC. If 2, PAL. If 1 or 3, dual compatible.

instances:
  mapper:
    value: _root.header.f6.lower_nibble | (_root.header.f7.upper_nibble  << 4)
