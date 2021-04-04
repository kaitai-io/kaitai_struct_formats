meta:
  id: monomakh_sapr_chg
  application: MONOMAKH-SAPR
  file-extension: chg
  license: CC0-1.0
  ks-version: 0.7
  endian: le
doc: |
  CHG is a container format file used by
  [MONOMAKH-SAPR](https://www.liraland.com/mono/index.php), a software
  package for analysis & design of reinforced concrete multi-storey
  buildings with arbitrary configuration in plan.

  CHG is a simple container, which bundles several project files
  together.

  Written and tested by Vladimir Shulzhitskiy, 2017
seq:
  - id: title
    type: str
    size: 10
    encoding: "ascii"
  - id: ent
    type: block
    repeat: eos
types:
  block:
    seq:
      - id: header
        type: str
        size: 13
        encoding: "ascii"
      - id: file_size
        type: u8
      - id: file
        size: file_size
