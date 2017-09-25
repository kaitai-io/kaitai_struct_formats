meta:
  title: Logical Volume Manager version 2
  id: lvm2
  endian: le
  encoding: ascii
  application:
    - linux
    - grub2
    - lvm tools
    - libvslvm
  license: GFDL-1.3+
doc: |
  ### Building a test file

  ```
  dd if=/dev/zero of=image.img bs=512 count=$(( 4 * 1024 * 2 ))
  sudo losetup /dev/loop1 image.img
  sudo pvcreate /dev/loop1
  sudo vgcreate vg_test /dev/loop1
  sudo lvcreate --name lv_test1 vg_test
  sudo losetup -d /dev/loop1
  ```
doc-ref: https://github.com/libyal/libvslvm/blob/master/documentation/Logical%20Volume%20Manager%20(LVM)%20format.asciidoc
instances:
  sector_size:
    value: 512 # TODO: how about 4k sectors?
seq:
  - id: pv
    type: physical_volume
    doc: Physical volume
types:
  physical_volume:
    seq:
      - id: empty_sector
        size: _root.sector_size 
      - id: label
        type: label
    types:
      label:
        seq:
          - id: label_header
            type: label_header
          - id: volume_header
            type: volume_header
        types:
          label_header:
            seq:
              - id: signature
                contents: "LABELONE"
              - id: sector_number
                type: u8
                doc: "The sector number of the physical volume label header"
              - id: checksum
                type: u4
                doc: "CRC-32 for offset 20 to end of the physical volume label sector"
              - id: label_header_
                type: label_header_
            types:
              label_header_:
                seq:
                  - id: data_offset
                    type: u4
                    doc: "The offset, in bytes, relative from the start of the physical volume label header where data is stored"
                  - id: type_indicator
                    contents: "LVM2 001"
              
          volume_header:
            seq:
              - id: id
                type: str
                size: 32
                doc: >
                  Contains a UUID stored as an ASCII string.
                  The physical volume identifier can be used to uniquely identify a physical volume. The physical volume identifier is stored as: 9LBcEB7PQTGIlLI0KxrtzrynjuSL983W but is equivalent to its formatted variant: 9LBcEB-7PQT-GIlL-I0Kx-rtzr-ynju-SL983W, which is used in the metadata.
              - id: size
                type: u8
                doc: "Physical Volume size. Value in bytes"
              - id: data_area_descriptors
                type: data_area_descriptor
                repeat: until
                repeat-until: _.size != 0 and _.offset != 0
                doc: "The last descriptor in the list is terminator and consists of 0-byte values."
              - id: metadata_area_descriptors
                type: metadata_area_descriptor
                repeat: until
                repeat-until: _.size != 0 and _.offset != 0
            types:
              data_area_descriptor:
                seq:
                  - id: offset
                    type: u8
                    doc: The offset, in bytes, relative from the start of the physical volume
                  - id: size
                    type: u8
                    doc: >
                      Value in bytes.
                      Can be 0. [yellow-background]*Does this represent all remaining available space?*
                instances:
                  data:
                    pos: offset
                    size: size
                    type: str
                    if: size != 0
              metadata_area_descriptor:
                seq:
                  - id: offset
                    type: u8
                    doc: The offset, in bytes, relative from the start of the physical volume
                  - id: size
                    type: u8
                    doc: Value in bytes
                instances:
                  data:
                    pos: offset
                    size: size
                    type: metadata_area
                    if: size != 0
              metadata_area:
                doc: "According to `[REDHAT]` the metadata area is a circular buffer. New metadata is appended to the old metadata and then the pointer to the start of it is updated. The metadata area, therefore, can contain copies of older versions of the metadata."
                seq:
                  - id: header
                    type: metadata_area_header
                types:
                  metadata_area_header:
                    seq:
                      - id: checksum
                        type: metadata_area_header
                        doc: "CRC-32 for offset 4 to end of the metadata area header"
                      - id: signature
                        contents: " LVM2 x[5A%r0N*>"
                      - id: version
                        type: u4
                      - id: metadata_area_offset
                        type: u8
                        doc: "The offset, in bytes, of the metadata area relative from the start of the physical volume"
                      - id: metadata_area_size
                        type: u8
                      - id: raw_location_descriptors
                        type: raw_location_descriptor
                        doc: "The last descriptor in the list is terminator and consists of 0-byte values."
                        repeat: until
                        repeat-until: _.offset != 0 and _.size != 0 and _.checksum != 0 # and _.flags != 0
                    instances:
                      metadata:
                        pos: metadata_area_offset
                        size: metadata_area_size
                    types:
                      raw_location_descriptor:
                        -orig-id: "raw_locn"
                        doc: "The data area size can be 0. It is assumed it represents the remaining  available data."
                        seq:
                          - id: offset
                            type: u8
                            doc: "The data area offset, in bytes, relative from the start of the metadata area"
                          - id: size
                            type: u8
                            doc: "data area size in bytes"
                          - id: checksum
                            type: u4
                            doc: "CRC-32 of *TODO (metadata?)*"
                          - id: flags
                            type: u4
                            enum: raw_location_descriptor_flags
                        enums:
                          raw_location_descriptor_flags:
                            0x00000001: raw_location_ignored #The raw location descriptor should be ignored.
