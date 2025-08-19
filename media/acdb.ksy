meta:
  id: acdb
  title: Qualcomm audio calibration database
  license: CC0-1.0
  encoding: UTF-8
  endian: le
doc: |
  Label audio calibration database files from Qualcomm.
  This specification is based on a few samples found inside the
  firmware of several Android devices using a Qualcomm chipset and
  very incomplete as it is a proprietary format.
seq:
 - id: header
   type: header
   size: 32
 - id: data
   type: data
   size: header.filesize1
types:
  header:
    seq:
      - id: magic
        contents: "QCMSNDDB"
      - id: reserved1
        contents: [0, 0, 0, 0, 0, 0, 0, 0]
      - id: name
        type: str
        size: 4
        valid:
          any-of:
            - '"AMDB"'
            - '"AVDB"'
            - '"CCDB"'
            - '"GCDB"'
        # these are values that were found in .acdb files
      - id: reserved2
        contents: [0, 0, 0, 0]
      - id: filesize1
        type: u4
      - id: filesize2
        type: u4
  data:
    seq:
      - id: entries
        type: entry
        repeat: eos
  entry:
    seq:
      - id: name
        type: str
        size: 8
      - id: len_data
        type: u4
      - id: data
        size: len_data
