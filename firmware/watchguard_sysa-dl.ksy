meta:
   id: wfsysadl
   endian: be
   title: Watchguard Fireware web update (Sysa-dl) file format
   license: MIT


seq:
  - id: fwheader
    type: fwheader
    size: 24

  - id: sections
    type: sections
    size: fwheader.file_size


types:
  fwheader:
     seq:
         - id: md5sum
           size: 0x10

         - id: file_size
           type: u4

         - id: magic_sign
           type: u4
           enum: magic

  sections:
      seq:
         - id: section
           type: section
           repeat: eos

  section:
      seq:
         - id: head
           type: head

         - id: data
           type:
              switch-on: head.name.content
              cases:
                '"REBOOT"': rebootdata
                '"info"': infodata
                '"HMAC"': hmacdata
                '"WGPKG"': wgpkgdata
           size: head.data_size

  name:
      seq:
        - id: type2_magic
          type: u1
          if: is_type2

        - id: content
          type: strz
          size: 'is_type2 ? 0xf : 0x10'
          encoding: ASCII

      instances:
        type2:
          pos: 0
          type: u1

        is_type2:
          value: type2 == 0x7f

  head:
      seq:
        - id: name
          type: name
          size: 0x10

        - id: unk
          size: 24
          if: name.is_type2

        - id: data_size
          type: u4

        - id: data_md5
          size: 0x10
          if: name.is_type2


  rebootdata:
     seq:
       - id: perm
         type: encoded_perm
         size: 0x8

  encoded_perm:
     seq:
       - id: dw0
         type: u4
       - id: dw1
         type: u4

  infodata:
     seq:
       - id: info
         type: strz
         encoding: ASCII
         size-eos: true

  hmacdata:
     seq:
       - id: sha1_sign #key: etaonrishdlcupfm
         size: 20

  wgpkgdata:
     seq:
       - id: meta_info
         type: strz
         encoding: ASCII
         terminator: 0

       - id: magic
         contents: "WGPKG\0"

       - id: unk
         size: 2

       - id: unkdw1
         type: u4
       - id: data_size
         type: u4

       - id: compressed_wpkg #bz2
         #size-eos: true
         size: data_size

enums:
    magic:
        0x1261_1920: type1
        0x1561_1928: type2
