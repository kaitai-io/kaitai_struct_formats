meta:
  id: r_data
  title: R data files
  application: R
  file-extension: 
    - rda
    - rds
    - RData
  license: GPL-3.0+
  encoding: utf-8
doc: |
  A set of file formats used for serialization of objects of [R language](https://www.r-project.org/about.html) for statistical computing.
  Datasets are often distributed in these formats.
  RDA files are usually compressed, you need to detect compression and decompress them before applying the code generated from this spec.
  There are 2 different formats, "old" and "new", the version is set up via is_new parameter.
doc-ref:
  - "https://github.com/wch/r-source/blob/master/src/main/saveload.c"
  - "https://github.com/wch/r-source/blob/master/src/include/Rinternals.h"
  - "https://github.com/wch/r-source/blob/master/src/main/serialize.c"
  - "https://cran.r-project.org/doc/manuals/r-release/R-ints.html#Serialization-Formats"
seq:
  - id: signature
    contents: ["RDX2\n"]
  - id: signature_type
    size: 1
  - id: lf
    contents: ["\n"]
  - id: body
    type: body
instances:
  is_new:
    value: 0
  max_elt_size:
    -orig-id: MAXELTSIZE
    value: 8192
types:
  body:
    meta:
      endian:
        switch-on: _root.signature_type
        cases:
          '[66]': le # "B"
          '[88]': be # "X"
    seq:
      - id: version
        type: version
      - id: writer_version
        type: version
        if: _root.is_new == 0
      - id: release_version
        type: version
        if: _root.is_new == 0
      
      - id: sym_count
        type: s4
        if: _root.is_new == 1
      - id: env_count
        type: s4
        if: _root.is_new == 1
      
      - id: ref_table
        type: item
      
      - id: symbols
        type: pas_str
        repeat: expr
        repeat-expr: sym_count
        if: _root.is_new == 1
      
      - id: env
        type: env_item
        repeat: expr
        repeat-expr: env_count
        if: _root.is_new == 1
      
      - id: obj
        type: item
        if: _root.is_new == 1
    types:
      env_item:
        seq:
          - id: enclos
            type: item
          - id: frame
            type: item
          - id: tag
            type: item
      pas_str:
        seq:
          - id: len
            type: s4
          - id: str
            type: str
            size: len
      item:
        seq:
          - id: flags
            type: flags
          - id: contents
            type:
              switch-on: flags.type
              cases:
                'type::envsxp': envsxp
                'type::listsxp': dotted_pair(flags)
                'type::langsxp': dotted_pair(flags)
                'type::closxp': dotted_pair(flags)
                'type::promsxp': dotted_pair(flags)
                'type::dotsxp': dotted_pair(flags)
                'type::persistsxp': string_vec
                'type::packagesxp': string_vec
                'type::namespacesxp': string_vec
                'type::symsxp': symsxp
                'type::refsxp': ref_index(flags.ref_idx)
                'type::extptrsxp': extptrsxp
                #'type::weakrefsxp': 
                'type::specialsxp': specialsxp
                'type::builtinsxp': specialsxp
                
                'type::charsxp': char_vec
                'type::lglsxp': int_vec
                'type::intsxp': int_vec
                'type::realsxp': real_vec
                'type::cplxsxp': complex_vec
                'type::strsxp': items_vec
                'type::vecsxp': items_vec
                'type::exprsxp': items_vec
                
                'type::bcodesxp': bytecode
                'type::rawsxp': raw
                
                'type::altrep_sxp': altrep_sxp
        types:
          flags:
            seq:
              # FUCK, called attribute 'levels' on generic struct expression 'Name(identifier(flagz))', have to perverse
              - id: flagz_old
                type: old
                if: _root.is_new == 0
              - id: flagz_new
                type: new
                if: _root.is_new == 1
            instances:
              levels:
                value: "_root.is_new == 1? flagz_new.levels : flagz_old.levels"
              type:
                value: "_root.is_new == 1? flagz_new.type : flagz_old.type"
                enum: type
              is_object:
                value: "_root.is_new == 1? flagz_new.is_object != 0 : flagz_old.is_object"
              has_attr:
                value: "_root.is_new == 1? false : flagz_old.has_attr"
              has_tag:
                value: "_root.is_new == 1? true : flagz_old.has_tag"
              ref_idx:
                value: "_root.is_new == 1? 0 : flagz_old.ref_idx"
            types:
              old:
                seq:
                  - id: flags
                    type: u4
                instances:
                  has_tag:
                    value: "(flags & (1 << 10)) != 0"
                  has_attr:
                    value: "(flags & (1 << 9)) != 0"
                  is_object:
                    value: "(flags & (1 << 8)) != 0"
                  levels:
                    value: "flags >> 12"
                  type:
                    value: "flags & 0xff"
                  ref_idx:
                    value: "flags >> 8"
              new:
                seq:
                  - id: type
                    type: u4
                  - id: levels
                    type: u4
                  - id: is_object
                    type: u4
          symsxp:
            seq:
              - id: symsxp_old
                type: item
                if: _root.is_new == 0
              - id: pos
                type: u4
                if: _root.is_new == 1
            instances:
              contents_new:
                value: symsxp_old
                if: false # not implemented yet
              contents:
                value: '_root.is_new == 1 ? contents_new : symsxp_old.contents'
              #value:
              #  value: contents.vec
          envsxp:
            seq:
              - id: envsxp
                type:
                  switch-on: _root.is_new
                  cases:
                    0: old
                    1: new
            types:
              old:
                seq:
                  - id: locked
                    type: s4
                  - id: enclos
                    type: item
                  - id: frame
                    type: item
                  - id: hash_table
                    type: item
                  - id: attrib
                    type: item
              
              new:
                seq:
                  - id: pos
                    type: u4
          dotted_pair:
            params:
              - id: flagz
                type: flags
            seq:
              - id: attrib
                type: item
                if: flagz.has_attr
              - id: tag
                type: item
                if: flagz.has_tag
              - id: car
                doc-ref: https://en.wikipedia.org/wiki/CAR_and_CDR
                type: item
              - id: cdr
                type: item
          string_vec:
            seq:
              - id: name_len
                type: s4
              - id: name
                type: str
                size: name_len
              - id: len
                type: s4
              - id: items
                type: item
          ref_index:
            params:
              - id: index
                type: u1
            seq:
              - id: ref_index_stored
                type: s4
                if: index != 0
            instances:
              ref_index:
                value: "(index != 0 ? ref_index_stored : index)"
          extptrsxp:
            seq:
              - id: ptr
                type: item
              - id: tag
                type: item
          v_size_len:
            seq:
              - id: len1
                type: s4
              - id: len2
                type: s8
                if: len1 == -1
            instances:
              value:
                value: "(len1 != -1) ? len1 : ((len1 << 32) + len2)"
          int_vec:
            seq:
              - id: len
                type: v_size_len
              - id: vec
                type: s4
                repeat: expr
                repeat-expr: len.value
          real_vec:
            seq:
              - id: len
                type: v_size_len
              - id: vec
                type: f8
                repeat: expr
                repeat-expr: len.value
          char_vec:
            seq:
              - id: len
                type: s4
              - id: vec
                type: str
                size: len
          
          complex:
            seq:
              - id: r
                type: f8
              - id: i
                type: f8

          complex_vec:
            seq:
              - id: len
                type: v_size_len
              - id: vec
                type: complex
                repeat: expr
                repeat-expr: len.value
          
          items_vec:
            seq:
              - id: len
                type: v_size_len
              - id: vec
                type: item
                repeat: expr
                repeat-expr: len.value
            
          bytecode:
            seq:
              - id: car
                type: item
              - id: consts
                type: consts
            types:
              consts:
                seq:
                  - id: count
                    type: s4
                  - id: consts
                    type: constant
                types:
                  constant:
                    seq:
                      - id: type
                        type: s4
                        enum: type
                      - id: value
                        type:
                          switch-on: type
                          cases:
                            "type::bcodesxp": bytecode
                            "type::langsxp": bc_lang(0)
                            "type::listsxp": bc_lang(0)
                            "type::attrlangsxp": bc_lang(1)
                            "type::attrlistsxp": bc_lang(1)
                            "type::bcrepdef": bcrep_ef
                            "type::bcrepref": bcrep_ef
                    types:
                      bcrep_ef:
                        seq:
                          - id: pos
                            type: s4
                          - id: type
                            type: s4
                          - id: lang
                            type: bc_lang(0)
                      bc_lang:
                        params:
                          - id: has_attr
                            type: u1
                        seq:
                          - id: attr
                            type: item
                            if: has_attr != 0
                          - id: tag
                            type: item
                          - id: car
                            type: constant
                            doc-ref: https://en.wikipedia.org/wiki/CAR_and_CDR
                          - id: cdr
                            type: constant
          raw:
            seq:
              - id: len
                type: v_size_len
              - id: vec
                size: len.value
          altrep_sxp:
            seq:
              - id: info
                type: item
              - id: state
                type: item
              - id: attr
                type: item
          specialsxp:
            seq:
              - id: index
                type:
                  switch-on: _root.is_new
                  cases:
                    0: pas_str
                    1: maxeltsize_str
            types:
              maxeltsize_str:
                seq:
                  - id: value
                    type: str
                    size: _root.max_elt_size - 1
        enums:
          type:
            0:
              id: nilsxp
            1:
              id: symsxp
              doc: "symbols"
            2:
              id: listsxp
              doc: "lists of dotted pairs"
            3:
              id: closxp
              doc: "closures"
            4:
              id: envsxp
              doc: "environments"
            5:
              id: promsxp
              doc: "promises: [un]evaluated closure arguments"
            6:
              id: langsxp
              doc: "language constructs (special lists)"
            7:
              id: specialsxp
              doc: "special forms"
            8:
              id: builtinsxp
              doc: "builtin non-special forms"
            9:
              id: charsxp
              doc: "scalar string type (internal only)"
            10:
              id: lglsxp
              doc: "logical vectors"
            13:
              id: intsxp
              doc: "integer vectors"
            14:
              id: realsxp
              doc: "real variables"
            15:
              id: cplxsxp
              doc: "complex variables"
            16:
              id: strsxp
              doc: "string vectors"
            17:
              id: dotsxp
              doc: "dot-dot-dot object"
            18:
              id: anysxp
              doc: "make any args work"
            19:
              id: vecsxp
              doc: "generic vectors"
            20:
              id: exprsxp
              doc: "expressions vectors"
            21:
              id: bcodesxp
              doc: "byte code"
            22:
              id: extptrsxp
              doc: "external pointer"
            23:
              id: weakrefsxp
              doc: "weak reference"
            24:
              id: rawsxp
              doc: "raw bytes"
            25:
              id: s4sxp
              doc: "s4 non-vector"
            30:
              id: newsxp
              doc: "fresh node creaed in new page"
            31:
              id: freesxp
              doc: "node released by gc"
            99:
              id: funsxp
              doc: "closure or builtin"
            243:
              id: bcrepref
            244:
              id: bcrepdef
            240:
              id: attrlangsxp
            239:
              id: attrlistsxp
            238:
              id: altrep_sxp
            254: nilvalue_sxp
            242: emptyenv_sxp
            241: baseenv_sxp
            253: globalenv_sxp
            252: unboundvalue_sxp
            251: missingarg_sxp
            250: basenamespace_sxp
            255: refsxp
            249: namespacesxp
            248: packagesxp
            247: persistsxp
      # version:
        # seq:
          # - id: v
            # type: u2
          # - id: p
            # type: u1
          # - id: s
            # type: u1
      version:
        seq:
          - id: packed
            type: s4
        instances:
          v:
            value: packed >> 16
          p:
            value: (packed & 0xFFFF) >> 8
          s:
            value: packed & 0xFF
