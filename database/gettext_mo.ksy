meta:
  id: gettext_mo
  title: gettext binary database
  application:
    - GNU gettext
    - libintl
  file-extension: mo
  tags:
    - database
    - linux
  license: BSD-2-Clause
  ks-version: 0.9
  encoding: UTF-8

#  Copyright (c) 2000, 2001 Citrus Project,
#  All rights reserved.
#  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

doc: |
  [GNU gettext](https://www.gnu.org/software/gettext/) is a popular
  solution in free/open source software world to do i18n/l10n of
  software, by providing translated strings that will substitute
  strings in original language (typically, English).

  gettext .mo is a binary database format which stores these string
  translation pairs in an efficient binary format, ready to be used by
  gettext-enabled software. .mo format is a result of compilation of
  text-based .po files using
  [msgfmt](https://www.gnu.org/software/gettext/manual/html_node/msgfmt-Invocation.html#msgfmt-Invocation)
  utility. The reverse conversion (.mo -> .po) is also possible using
  [msgunfmt](https://www.gnu.org/software/gettext/manual/html_node/msgunfmt-Invocation.html#msgunfmt-Invocation)
  decompiler utility.
doc-ref: https://gitlab.com/worr/libintl
seq:
  - id: signature
    size: 4
  - id: mo
    type: mo
types:
  hash_lookup_iteration:
    params:
      - id: idx
        type: u4
      - id: collision_step
        type: u4
    instances:
      original:
        value: _root.mo.originals[idx].str
      translation:
        value: _root.mo.translations[idx].str
      next_idx:
        value: "idx + collision_step - (idx >= _root.mo.num_hashtable_items - collision_step ? _root.mo.num_hashtable_items : 0)"
      next:
        pos: 0
        type: hash_lookup_iteration(_root.mo.hashtable_items[next_idx].val, collision_step)
  lookup_iteration:
    params:
      - id: current
        type: hash_lookup_iteration
      - id: query
        type: str
    instances:
      found:
        value: query == current.original
      next:
        pos: 0
        type: lookup_iteration(current.next, query)
        if: not found

  hashtable_lookup:
    doc: |
      def lookup(s:str, t:gettext_mo.GettextMo):
        try:
          l=gettext_mo.GettextMo.HashtableLookup(s, string_hash(s), t._io, _parent=t, _root=t)
          e=l.entry
          while(not e.found):
            e=e.next
          return e.current
        except:
          raise Exception("Not found "+s+" in the hashtable!")

      lookup(t.mo.originals[145].str, t)
    doc-ref: https://gitlab.com/worr/libintl/raw/master/src/lib/libintl/gettext.c
    params:
      - id: query
        type: str
      - id: hash
        type: u4
        doc-ref: https://gitlab.com/worr/libintl/raw/master/src/lib/libintl/strhash.c
        doc: |
          def string_hash(s):
            s=s.encode("utf-8")
            h = 0
            for i in range(len(s)):
              h = h << 4
              h += s[i]
              tmp = h & 0xF0000000
              if tmp != 0:
                h ^= tmp
                h ^= tmp >> 24
            return h
    instances:
      collision_step:
        value: "hash % (_root.mo.num_hashtable_items - 2) + 1"
      idx:
        value: "hash % _root.mo.num_hashtable_items"
      hash_lookup_iteration:
        pos: 0
        type: "hash_lookup_iteration(_root.mo.hashtable_items[idx].val, collision_step)"
      entry:
        pos: 0
        type: "lookup_iteration(hash_lookup_iteration, query)"

  mo:
    meta:
      endian:
        switch-on: _root.signature
        cases:
          '[0xde, 0x12, 0x04, 0x95]': le
          '[0x95, 0x04, 0x12, 0xde]': be
    seq:
      - id: version
        type: version
      - id: num_translations
        type: u4
      - id: ofs_originals
        type: u4
      - id: ofs_translations
        type: u4
      - id: num_hashtable_items
        type: u4
      - id: ofs_hashtable_items
        type: u4
    instances:
      originals:
        io: _root._io
        pos: ofs_originals
        type: descriptor
        repeat: expr
        repeat-expr: num_translations
      translations:
        io: _root._io
        pos: ofs_translations
        type: descriptor
        repeat: expr
        repeat-expr: num_translations
      hashtable_items:
        io: _root._io
        pos: ofs_hashtable_items
        type: hashtable_item
        repeat: expr
        repeat-expr: num_hashtable_items
        if: ofs_hashtable_items != 0
    types:
      version:
        seq:
          - id: version_raw
            type: u4
        instances:
          major:
            value: version_raw >> 16
          minor:
            value: version_raw & 0xffff
      hashtable_item:
        seq:
          - id: raw_val
            type: u4
        instances:
          mask:
            value: 0x80000000
          val_1:
            value: raw_val - 1
            if: raw_val != 0
          is_system_dependent:
            value: val_1 & mask == 1
            if: raw_val != 0
          val:
            value: val_1 & ~mask
            if: raw_val != 0
      descriptor:
        seq:
          - id: len_str
            type: u4
          - id: ofs_str
            type: u4
        instances:
          str:
            io: _root._io
            pos: ofs_str
            size: len_str
            type: strz
