meta:
  id: asterix_message
  file-extension: ast
  endian: be
  license: GPL-3.0-only
  imports:
    - asterix_data_block

  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  "The all-purpose structured EUROCONTROL surveillance information exchange (ASTERIX)
  is a set of documents defining the low level ('down to the bit') implementation
  of a data format used for exchanging surveillance-related information and other ATM applications.
  ASTERIX is designed for communication media with limited bandwidth. This is why it follows rules
  that enable it to transmit all the information needed, with the smallest data load possible.

  The ASTERIX library consists of several parts, each of them describing the encoding of information
  related to a specific application.

  The 'Part 1' document contains the basic principles and rules to be followed when implementing
  ASTERIX. For everyone new to ASTERIX, Part 1 is a good starting point.

  Parts 2 and higher describe how to encode data for a specific application. These parts are
  commonly referred to as 'ASTERIX Categories.' They are available for applications in these areas:

  000 - 127: Standard Civil and Military Applications
  128 - 240: Special Civil and Military Applications
  241 - 255: Civil and Military Non-Standard Applications"

  Asterix DATA Messages are tranmited in UDP payload, and an Asterix File, is a concatenation of
  Asterix messages UDP Payloads. Also, an asterix message, when captured from network could be a
  concatenation of Asterix data blocks. For this reason, an Asterix file could be read with this KSY
  or directly with the Asterix Message KSY file specification.

doc-ref: |
  https://www.eurocontrol.int/publication/eurocontrol-specification-surveillance-data-exchange-part-i

seq:
  - id: data_blocks
    type: asterix_data_block
    repeat: eos
