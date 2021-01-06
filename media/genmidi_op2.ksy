meta:
  id: genmidi_op2
  title: GENMIDI.OP2 OPL2 sound bank
  file-extension: op2
  xref:
    wikidata: Q32098356
  license: CC0-1.0
  ks-version: 0.9
  encoding: ASCII
  endian: le
doc: |
  GENMIDI.OP2 is a sound bank file used by players based on DMX sound
  library to play MIDI files with General MIDI instruments using OPL2
  sound chip (which was commonly installed on popular AdLib and Sound
  Blaster sound cards).

  Major users of DMX sound library include:

  * Original Doom game engine (and games based on it: Heretic, Hexen, Strife, Chex Quest)
  * Raptor: Call of the Shadows
doc-ref:
  - http://www.fit.vutbr.cz/~arnost/muslib/op2_form.zip
  - http://doom.wikia.com/wiki/GENMIDI
  - http://www.shikadi.net/moddingwiki/OP2_Bank_Format
seq:
  - id: magic
    contents: "#OPL_II#"
  - id: instruments
    type: instrument_entry
    repeat: expr
    repeat-expr: 175
  - id: instrument_names
    type: str
    size: 32
    pad-right: 0
    terminator: 0
    repeat: expr
    repeat-expr: 175
types:
  instrument_entry:
    seq:
      - id: flags
        type: u2
      - id: finetune
        type: u1
      - id: note
        type: u1
        doc: MIDI note for fixed instruments, 0 otherwise
      - id: instruments
        repeat: expr
        repeat-expr: 2
        type: instrument
  instrument:
    seq:
      - id: op1
        type: op_settings
      - id: feedback
        type: u1
        doc: Feedback/AM-FM (both operators)
      - id: op2
        type: op_settings
      - id: unused
        type: u1
      - id: base_note
        type: s2
        doc: Base note offset
  op_settings:
    doc: |
      OPL2 settings for one operator (carrier or modulator)
    seq:
      - id: trem_vibr
        type: u1
        doc: Tremolo/vibrato/sustain/KSR/multi
      - id: att_dec
        type: u1
        doc: Attack rate/decay rate
      - id: sust_rel
        type: u1
        doc: Sustain level/release rate
      - id: wave
        type: u1
        doc: Waveform select
      - id: scale
        type: u1
        doc: Key scale level
      - id: level
        type: u1
        doc: Output level
