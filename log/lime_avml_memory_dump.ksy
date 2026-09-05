meta:
  id: lime_avml_memory_dump
  title: Memory dump in LiME/AVML format
  file-extension: lime
  application:
    - LiME
    - AVML
    - Volatility
  license: MIT

doc: |
  Just a file format for memory dumps. It may be better to use it instead of raw sparse files, when it is needed to transfer a dump.
  It is also damn simple, so third-party apps may also adopt it.

  LiME is a GPL-licensed Linux kernel module for acquiring memory dumps.
  AVLM is a MIT-licensed app by Microsoft, using its format and extending it.

  To acquire a dump of 2 records on Linux:
    sudo apt-get install -y lime-forensics-dkms
    sudo insmod /lib/modules/`uname -r`/updates/dkms/lime.ko "path=tcp:4444 format=lime dio=1 localhostonly=1"
    #in an another tab
    nc localhost 4444 | dd bs=1 count=647232 > ram.lime
    ^C
    #in the first tab
    sudo rmmod lime

doc-ref:
  - https://github.com/microsoft/avml/blob/4409f0048854e44d9b4d0f2c31261acb43174e92/src/image.rs#L22  # the primary source of the info
  - https://github.com/504ensicsLabs/LiME/tree/master/doc#Spec  # this spec is GPL-licensed, don't use it.

seq:
  - id: records
    type: record
    repeat: eos

types:
  record:
    meta:
      # switcheable endian is broken.
      #endian:
      #  switch-on: format_identifier.is_be
      #  cases:
      #    true: be
      #    false: le
      endian: le

    -orig-id:

    seq:
      - id: header
        type: header

      - id: payload
        size: header.range.size
        doc: |
          When the format is avml, then it is [snappy-compressed](https://github.com/google/snappy/blob/master/format_description.txt) memory. BTW, we need a spec for it.

    instances:
      format_identifier:
        pos: 0
        type: format_identifier

    types:
      range:
        seq:
          - id: start
            type: u8
          - id: end_closed
            type: u8
        instances:
          end:
            value: end_closed + 1
          size:
            value: end - start

      format_identifier:
        seq:
          - id: signature0
            -orig-id: magic
            type: str
            size: 1
            encoding: ascii
          - id: signature1
            -orig-id: magic
            type: str
            size: 3
            encoding: ascii
        instances:
          is_be:
            value: signature0 == "L"
          is_lime:
            value: (signature0 == "E" and signature1 == "MiL") or (is_be and signature1 == "iME")
          is_avlm:
            value: (signature0 == "A" and signature1 == "VML") or (is_be and signature1 == "MVA")
          format:
            value: "(is_lime ? format::lime : (is_avlm ? format::avml : format::unknown))"

          is_valid:
            value: "format != format::unknown"
            #valid:
            #  eq: true

        enums:
          format:
            0: unknown
            1: lime
            2: avml

      header:
        seq:
          - id: format_identifier
            size: sizeof<format_identifier>
          - id: version
            type: u4
          - id: range
            type: range
          - id: padding
            size: 8
        instances:
          valid_version_must_be:
            value: _parent.format_identifier.format.to_i
          is_valid:
            value: "_parent.format_identifier.is_valid and version == valid_version_must_be"
            #valid:
            #  eq: true
