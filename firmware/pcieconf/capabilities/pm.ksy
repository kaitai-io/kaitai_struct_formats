meta:
  id: pm
  endian: le
  license: 0BSD

doc: Power management PCI capability

doc-ref: |
  PCI Bus Power Management Interface Specification Revision 1.0
  p20, 3.2 Power Management Register Block Definition

  PCI EXPRESS BASE SPECIFICATION, REV. 3.0
  p601, 7.6.  PCI Power Management Capability Structure

# TODO: update to v1.2
# TODO: re-check PCIe spec

seq:
  - id: pmc
    type: pmc
  - id: pmcsr
    type: pmscr
  - id: pmscr_bse
    type: pmscr_bse
  - id: data
    type: u1

types:
  pmc:
    seq:
      # bits 7:0
      - id: aux_current_lower
        type: b2
      - id: dsi
        type: b1
      - id: auxiliary_power_source
        # phased out in v1.1
        type: b1
      - id: pme_clock
        type: b1
      - id: version
        type: b3 # TODO encode as enum
      # bits 15:8
      - id: pme_support
        type: b5
      - id: d2_support
        type: b1
      - id: d1_support
        type: b1
      - id: aux_current_upper
        type: b1
    instances:
      aux_current:
        value: aux_current_lower | (aux_current_upper.to_i << 3)

  pmscr:
    seq:
      # bits 7:0
      - id: reserved0
        type: b6
      - id: power_state
        type: b2
        enum: power_state
      # bits: 15:8
      - id: pme_status
        type: b1
      - id: data_scale
        type: b2
      - id: data_select
        type: b4
      - id: pme_en
        type: b1

  pmscr_bse:
    seq:
      # bits 7:0
      - id: bpcc_en
        type: b1
      - id: b2_b3_support
        type: b1
      - id: reserved
        type: b6

enums:
  power_state:
    0: d0
    1: d1
    2: d2
    3: d3_hot
