meta:
  id: asterix_record
  endian: be
  license: GPL-3.0-only
  imports:
    - cat_000
    - cat_001
    - cat_002
    - cat_008
    - cat_010
    - cat_020
    - cat_021
    - cat_034
    - cat_048
    - cat_062

  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Asterix records, is a concatenation of records pertaining to a data block.
  All records are the same category. This implementation is category agnostic.
  Adding new categories is a matter of defining a catalog KSY file, and a Category
  KSY file. If the category implements an unique UAP, then no additional logic is
  needed, otherwise some instance implementation should be implemented in the
  category file. Please see CAT001 implementation file.

  Currently an unique CAT catalog/definition version are implemented per category.
  In the future it is expected to also select by SIC/SAC, which will permit having
  some sort of config file, or definition which will permit selecting category and
  version.

doc-ref: |
  https://www.eurocontrol.int/publication/eurocontrol-specification-surveillance-data-exchange-part-i

params:
  - id: cat
    type: u1

seq:
  - id: records
    type:
      switch-on: cat
      cases:
        1:  cat_001
        2:  cat_002
        8:  cat_008
        10: cat_010
        20: cat_020
        21: cat_021
        34: cat_034
        48: cat_048
        62: cat_062
        _:  cat_000
    repeat: eos
