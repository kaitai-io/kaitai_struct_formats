meta:
  id: qt_translation
  title: Qt Translation
  file-extension: qm
  license: LGPL-3.0-only
  encoding: UTF-8
  endian: be
doc-ref: https://code.qt.io/cgit/qt/qtbase.git/tree/src/corelib/kernel/qtranslator.cpp?h=dev
seq:
  - id: header
    type: header
  - id: tags
    type: tag
    repeat: eos
types:
  header:
    seq:
      - id: signature
        contents: [0x3c, 0xb8, 0x64, 0x18, 0xca, 0xef, 0x9c, 0x95, 0xcd, 0x21, 0x1c, 0xbf, 0x60, 0xa1, 0xbd, 0xdd]
  tag:
    seq:
      - id: tag
        type: u1
        enum: translator_tags
        valid:
          any-of:
            - translator_tags::contexts
            - translator_tags::hashes
            - translator_tags::messages
            - translator_tags::numerus_rules
            - translator_tags::dependencies
            - translator_tags::language
      - id: len_data
        type: u4
      - id: data
        size: len_data
        type:
          switch-on: tag
          cases:
            translator_tags::language: str
            translator_tags::messages: messages
  messages:
    seq:
      - id: messages
        type: message
        repeat: eos
  message:
    -webide-representation: '{tag}'
    seq:
      - id: tag
        type: u1
        enum: tag_types
      - id: payload
        type:
          switch-on: tag
          cases:
            tag_types::translation: translation
            tag_types::source_text: tag_text
            tag_types::context: tag_text
            tag_types::comment: tag_text
    types:
      tag_text:
        seq:
          - id: len_data
            type: u4
          - id: data
            size: len_data
            type: str
      translation:
        seq:
          - id: len_data
            type: u4
          - id: data
            size: len_data
enums:
  translator_tags:
    0x2f: contexts
    0x42: hashes
    0x69: messages
    0x88: numerus_rules
    0x96: dependencies
    0xa7: language
  tag_types:
    1: end
    2: source_text_16
    3: translation
    4: context_16
    5: obsolete_1
    6: source_text
    7: context
    8: comment
    9: obsolete_2
