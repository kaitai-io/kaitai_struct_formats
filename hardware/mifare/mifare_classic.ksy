meta:
  id: mifare_classic
  title: Mifare Classic RFID tag dump
  file-extension: mfd
  license: BSD-2-Clause
  ks-version: 0.9
  endian: le
doc-ref: |
  https://github.com/nfc-tools/libnfc
  https://www.nxp.com/docs/en/data-sheet/MF1S70YYX_V1.pdf
doc: |
  You can get a dump for testing by the link: https://github.com/zhovner/mfdread/raw/master/dump.mfd
seq:
  - id: sectors
    size: ((_index >= 32)?4:1)*4*16 #sorry for this doubling of `block_size` (16), but we need `sector` be self-sufficient so we cannot use _root there
    type: sector(_index == 0)
    repeat: eos
types:
  key:
    seq:
      - id: key
        size: 6
  sector:
    params:
      - id: has_manufacturer
        type: bool
    seq:
      - id: manufacturer
        type: manufacturer
        if: has_manufacturer
      
      - id: data_filler
        -orig-id: abtData
        size: _io.size - _io.pos - 16 # sizeof(trailer)
        type: filler
      - id: trailer
        type: trailer
    instances:
      block_size:
        value: 16
      data:
        value: data_filler.data
      blocks:
        pos: 0
        io: data_filler._io
        size: block_size
        repeat: eos
      values:
        pos: 0
        io: data_filler._io
        type: values
    types:
      values:
        seq:
          - id: values
            type: value_block
            repeat: eos
        types:
          value_block:
            seq:
              - id: valuez
                type: u4
                repeat: expr
                repeat-expr: 3
              - id: addrz
                type: u1
                repeat: expr
                repeat-expr: 4
            instances:
              value_valid:
                value: 'valuez[0]==~valuez[1] and valuez[0]==valuez[2]'
              addr_valid:
                value: 'addrz[0]==~addrz[1] and addrz[0]==addrz[2] and addrz[1]==addrz[3]'
              valid:
                value: 'value_valid and addr_valid'
              addr:
                value: 'addrz[0]'
                if: valid
              value:
                value: valuez[0]
                if: valid
      filler:
        doc: "only to create _io"
        seq:
          - id: data
            size: _io.size
  manufacturer:
    seq:
      - id: nuid
        -orig-id: abtUID
        type: u4
        doc: beware for 7bytes UID it goes over next fields
      - id: bcc
        -orig-id: btBCC
        type: u1
      - id: sak # beware it's not always exactly SAK
        -orig-id: btSAK
        type: u1
      - id: atqa
        -orig-id: abtATQA
        type: u2
      - id: manufacturer
        -orig-id: abtManufacturer
        size: 8
        doc: may contain manufacture date as BCD
  trailer:
    seq:
      - id: key_a
        -orig-id: abtKeyA
        type: key
      - id: access_bits
        -orig-id: abtAccessBits
        size: 3
        type: access_conditions
      - id: user_byte
        -orig-id: abtAccessBits
        type: u1

      - id: key_b
        -orig-id: abtKeyB
        type: key
    instances:
      ac_bits:
        value: 3
      acs_in_sector:
        value: 4
      ac_count_of_chunks:
        value: ac_bits*2 #6
    
    types:
      access_conditions:
        seq:
          - id: raw_chunks
            type: b4 # _parent.acs_in_sector
            repeat: expr
            repeat-expr: _parent.ac_count_of_chunks
        instances:
          remaps:
            pos: 0
            repeat: expr
            repeat-expr: _parent.ac_bits
            type: chunk_bit_remap(_index)
          chunks:
            pos: 0
            type: valid_chunk(raw_chunks[remaps[_index].inv_chunk_no], raw_chunks[remaps[_index].chunk_no])
            repeat: expr
            repeat-expr: _parent.ac_bits
          acs_raw:
            pos: 0
            type: ac(_index)
            repeat: expr
            repeat-expr: _parent.acs_in_sector
          data_acs:
            pos: 0
            type: data_ac(acs_raw[_index])
            repeat: expr
            repeat-expr: _parent.acs_in_sector-1
          trailer_ac:
            pos: 0
            type: trailer_ac(acs_raw[_parent.acs_in_sector-1])
        types:
          chunk_bit_remap:
            params:
              - id: bit_no
                type: u1
            instances:
              shift_value:
                value: (bit_no==1?-1:1)
              chunk_no:
                value: '((inv_chunk_no+shift_value+_parent._parent.ac_count_of_chunks)%_parent._parent.ac_count_of_chunks)'
              inv_chunk_no:
                value: 'bit_no+shift_value'
          valid_chunk:
            params:
              - id: inv_chunk
                type: u1
              - id: chunk
                type: u1
                doc: "c3 c2 c1 c0"
            instances:
              valid:
                value: inv_chunk ^ chunk == 0b1111
          ac:
            params:
              - id: index
                type: u1
            instances:
              bits:
                pos: 0
                repeat: expr
                repeat-expr: _parent._parent.ac_bits
                type: ac_bit(index, _parent.chunks[_index].chunk)

              val:
                value: (bits[2].n << 2) | (bits[1].n << 1) | bits[0].n
                doc: "c3 c2 c1"
              inv_shift_val:
                value: (bits[0].n << 2) | (bits[1].n << 1) | bits[2].n
              
            types:
              ac_bit:
                params:
                  - id: i
                    type: u1
                  - id: chunk
                    type: u1
                instances:
                  n:
                    value: (chunk >> i) & 1
                  b:
                    value: n == 1
                    
          trailer_ac:
            params:
              - id: ac
                type: ac
            instances:
              can_read_key_b:
                value: ac.inv_shift_val <= 0b010
                doc: key A is required
              can_write_keys:
                value: "(ac.inv_shift_val+1)%3 != 0 and (ac.inv_shift_val<6)"
              can_write_access_bits:
                value: ac.bits[2].b
              key_b_controls_write:
                value: not can_read_key_b
          data_ac:
            params:
              - id: ac
                type: ac
            instances:
              read_key_a_required:
                value: ac.val <= 0b100
              read_key_b_required:
                value: ac.val <= 0b110
              write_key_a_required:
                value: ac.val == 0
              

              write_key_b_required:
                value: (not read_key_a_required or read_key_b_required) and not ac.bits[0].b
              increment_available:
                value: (not ac.bits[0].b and not read_key_a_required and not read_key_b_required) or (not ac.bits[0].b and read_key_a_required and read_key_b_required)
              decrement_available:
                value: (ac.bits[1].b or not ac.bits[0].b) and not ac.bits[2].b
