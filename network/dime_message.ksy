meta:
  id: dime_message
  title: DIME (Direct Internet Message Encapsulation) Message
  license: CC0-1.0
  endian: be
doc: |
  Direct Internet Message Encapsulation (DIME)
  is an old Microsoft specification for sending and receiving
  SOAP messages along with additional attachments,
  like binary files, XML fragments, and even other
  SOAP messages, using standard transport protocols like HTTP.
doc-ref: 
  - http://xml.coverpages.org/draft-nielsen-dime-02.txt
  - https://docs.microsoft.com/en-us/archive/msdn-magazine/2002/december/sending-files-attachments-and-soap-messages-via-dime
seq:
  - id: dime
    type: message
types:
  message:
    seq:
    - id: message
      type: record
      repeat: eos
  record:
    seq:
    - id: version
      type: b5
    - id: first_record
      type: b1
    - id: last_record
      type: b1
    - id: chunck_record
      type: b1
    - id: type_format
      type: b4
    - id: reserved
      type: b4
    - id: options_length
      type: u2
    - id: id_length
      type: u2
    - id: type_length
      type: u2
    - id: data_length
      type: u4
    - id: options
      size: options_length
    - id: options_padding
      size: (4 - _io.pos) % 4
    - id: id
      size: id_length
    - id: id_padding
      size: (4 - _io.pos) % 4
    - id: type
      size: type_length
    - id: type_padding
      size: (4 - _io.pos) % 4
    - id: data
      size: data_length
    - id: data_padding
      size: (4 - _io.pos) % 4
