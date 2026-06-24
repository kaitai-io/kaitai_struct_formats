meta:
  id: af
  endian: le
  license: 0BSD

doc: Advanced features capability for conventional PCI

doc-ref: |
  PCI-SIG ENGINEERING CHANGE NOTICE
  Advanced Capabilities for Conventional PCI

seq:
  - id: length
    type: u1
  - id: capabilities
    type: capabilities
  - id: control
    type: control
  - id: status
    type: status

types:
  capabilities:
    seq:
      - id: reserved
        type: b6
      - id: flr_cap
        type: b1
      - id: tp_cap
        type: b1

  control:
    seq:
      - id: reserved
        type: b7
      - id: initiate_flr
        type: b1

  status:
    seq:
      - id: reserved
        type: b7
      - id: tp
        type: b1
