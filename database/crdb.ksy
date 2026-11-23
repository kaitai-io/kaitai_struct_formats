meta:
  id: crdb
  title: GNU/Linux wireless regulation database
  license: copyleft-next-0.3.0 AND ISC
  endian: be
  encoding: ASCII

-license-URIs:
  - https://github.com/copyleft-next/copyleft-next/blob/master/Releases/copyleft-next-0.3.0

-license-header: |
  Copyright (c) 2013, Luis R. Rodriguez <mcgrof@do-not-panic.com>

  CRDA is licensed under copyleft-next 0.3.0

  Refer to copyleft-next-0.3.0 for license details, you can also always get the latest updates of copyleft-next from:

  https://gitorious.org/copyleft-next/

  This file incorporates work covered by the following copyright and permission notice:

  Copyright (c) 2008, Luis R. Rodriguez <mcgrof@do-not-panic.com>
  Copyright (c) 2008, Johannes Berg <johannes@sipsolutions.net>
  Copyright (c) 2008, Michael Green <Michael.Green@Atheros.com>

  Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

doc: |
  the test file: https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/plain/regulatory.bin
doc-ref:
  - "https://wireless.wiki.kernel.org/en/developers/Regulatory/wireless-regdb"
  - "https://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/crda.git/tree/regdb.h"
  - "https://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/crda.git/tree/reglib.c"
  - "https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/tree/db2bin.py"
seq:
  - id: signature
    contents: ["RGDB"]
  - id: version
    type: u4
  - id: states_ptr
    -orig-id: countries_ptr
    type: u4
    doc: The list is sorted alphabetically to allow binary searching (should it become really huge).
  - id: states_count
    -orig-id: countries_count
    type: u4
  - id: authentication_size
    -orig-id: signature_len
    type: u4
    doc: length (in bytes) of the signature at the end of the file
instances:
  states:
    pos: states_ptr
    type: state
    repeat: expr
    repeat-expr: states_count
  authentication:
    pos: _io.size - signature_size
    size: authentication_size
    doc: digital signature
types:
  freq_range:
    doc: |
      everything is in in kHz
      Values of zero mean "not applicable", i.e. the regulatory does not limit a certain value.
    seq:
     - id: start
       type: u4
     - id: end
       type: u4
     - id: max_bandwidth
       type: u4
  power_rule:
    seq:
      - id: max_antenna_gain
        type: u4
        doc: in mBi (100 * dBi)
      - id: max_eirp
        type: u4
        doc: in mBi (100 * dBi)
  rule:
    seq:
      - id: freq_range_ptr
        type: u4
      - id: power_rule_ptr
        type: u4
      - id: flags
        type: flags
    instances:
      power_rule:
        pos: power_rule_ptr
        type: power_rule
      freq_range:
        pos: freq_range_ptr
        type: freq_range
  rule_ptr:
    seq:
      - id: ptr
        type: u4
    instances:
      rule:
        pos: ptr
        type: rule
  flags:
    seq:
        - id: reserved1
          type: b20
        - id: auto_bw
          -orig-id: RRF_AUTO_BW
          type: b1
          doc: Auto BW calculations
        - id: reserved0
          type: b2
        - id: no_ibss
          -orig-id: __RRF_NO_IBSS
          type: b1
          doc: old no-IBSS rule, maps to no-ir
        - id: do_not_initiate_radiation
          -orig-id: RRF_NO_IR
          type: b1
        - id: ptmp_only
          -orig-id: RRF_PTMP_ONLY
          type: b1
          doc: this is only for Point To MultiPoint links
        - id: ptp_only
          -orig-id: RRF_PTP_ONLY
          type: b1
          doc: this is only for Point To Point links
        - id: dfs_required
          -orig-id: RRF_DFS
          type: b1
          doc: DFS support is required to be used
        - id: no_outdoor
          -orig-id: RRF_NO_OUTDOOR
          type: b1
          doc: outdoor operation not allowed
        - id: no_indoor
          -orig-id: RRF_NO_INDOOR
          type: b1
          doc: indoor operation not allowed
        - id: no_cck
          -orig-id: RRF_NO_CCK
          type: b1
          doc: CCK modulation not allowed
        - id: no_ofdm
          -orig-id: RRF_NO_OFDM
          type: b1
          doc: OFDM modulation not allowed

  rules_collection:
    seq:
      - id: count
        -orig-id: reg_rule_num
        type: u4
      - id: ptrs
        type: rule_ptr
        repeat: expr
        repeat-expr: count

  state:
    -orig-id: regdb_file_reg_country
    seq:
      - id: two_letter_code
        -orig-id: alpha2
        type: str
        size: 2
      - id: pad
        type: u1
      - id: creqs
        type: b6
      - id: dfs_region
        type: b2
        enum: dfs_region
      - id: reg_collection_ptr
        type: u4 # regdb_file_reg_rules_collection
    instances:
      rules:
        pos: reg_collection_ptr
        type: rules_collection
enums:
  dfs_region:
    0: unset # no DFS master region specified
    1: fcc # follows DFS master rules from FCC
    2: etsi # follows DFS master rules from ETSI
    3: jp # follows DFS master rules from JP/MKK/Telec
