meta:
  id: f12le
  title: numpy f12 (based on IEEE 754, effectively f10)
  license: Unlicense
  endian: be
  xref:
    iso: "60559:2011"
    wikidata: Q5421900
  imports:
    - ./f10le
doc: "see the doc for `ieee754_float`."
seq:
  - id: f10
    type: f10le
  - id: garbage
    type: u2
