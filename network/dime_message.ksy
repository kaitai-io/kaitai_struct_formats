meta:
  id: dime_message
  title: DIME (Direct Internet Message Encapsulation) Message
  file-extension:
    - dim
    - dime
  xref:
    mime: application/dime
    wikidata: Q1227457
  license: CC0-1.0
  bit-endian: be
  endian: be
doc: |
  Direct Internet Message Encapsulation (DIME)
  is an old Microsoft specification for sending and receiving
  SOAP messages along with additional attachments,
  like binary files, XML fragments, and even other
  SOAP messages, using standard transport protocols like HTTP.
  
  Sample file: `curl -L
  https://github.com/kaitai-io/kaitai_struct_formats/files/5890499/scanner.dump.gz
  | gunzip -c > scanner.dump`
doc-ref: 
  - http://xml.coverpages.org/draft-nielsen-dime-02.txt
  - https://docs.microsoft.com/en-us/archive/msdn-magazine/2002/december/sending-files-attachments-and-soap-messages-via-dime
seq:
  - id: records
    type: record
    repeat: eos
types:
  padding:
    doc: padding to the next 4-byte boundary
    seq:
      - id: boundary_padding
        size: (- _io.pos) % 4
  record:
    doc: each individual fragment of the message
    seq:
      - id: version
        type: b5
      - id: is_first_record
        type: b1
      - id: is_last_record
        type: b1
      - id: is_chunk_record
        type: b1
      - id: type_format
        enum: type_formats
        type: b4
      - id: reserved
        type: b4
      - id: len_options
        type: u2
      - id: len_id
        type: u2
      - id: len_type
        type: u2
      - id: len_data
        type: u4
      - id: options
        size: len_options
      - id: options_padding
        type: padding
      - id: id
        size: len_id
      - id: id_padding
        type: padding
      - id: type
        size: len_type
      - id: type_padding
        type: padding
      - id: data
        size: len_data
      - id: data_padding
        type: padding
enums:
  type_formats:
    0: unchanged
    1: media_type
    2: absolute_uri
    3: unknown
    4: none
