meta:
  id: gps_destinator
  title: Destinator mixed stuff format
  application: Destinator
  file-extension:
    - rte
    - dat
  license: GPL-2.0-or-later
  encoding: utf-16le
  -affected-by: 187
  endian: le
  tags:
    - geospatial

doc: |
  Destinator formats

doc-ref:
  - https://web.archive.org/web/20160310115940/http://mozoft.com/d3log.html
  - https://web.archive.org/web/20071011022251/http://www.destinatortechnologies.net/uk/products/products/bundles/
  - https://www.gpsbabel.org/htmldoc-development/fmt_destinator_itn.html
  - https://www.gpsbabel.org/htmldoc-development/fmt_destinator_poi.html
  - https://github.com/gpsbabel/gpsbabel/blob/e1e195beca8e0f24ca0e41c02d1986af13865cd0/destinator.cc#L215


seq:
  - id: records
    type: record
    repeat: eos

types:
  point:
    seq:
      - id: lon
        type: f8
      - id: lat
        type: f8
      - id: lon_repeat
        type: f8
        valid: lon
      - id: lat_repeat
        type: f8
        valid: lat

  record:
    seq:
      - id: tag
        type: strz
      - id: short_name
        type: strz
      - id: notes
        type: strz
      - id: payload
        type:
          switch-on: tag
          cases:
            '"Dynamic POI"': favorite
            '"City->Street"': itinerary


  itinerary:
    seq:
      - id: unknown0
        type: u4
      - id: unknown1
        type: f8
      - id: unknown2
        type: f8
      - id: point
        type: point

      - id: unknown3
        type: f8
      - id: unknown4
        type: f8

  favorite:
    seq:
      - id: house_no
        type: strz
      - id: street
        type: strz
      - id: city
        type: strz
      - id: unkn
        type: strz
      - id: post_code
        type: strz
      - id: unknown1
        type: strz
      - id: unknown2
        type: f8
      - id: point
        type: point
