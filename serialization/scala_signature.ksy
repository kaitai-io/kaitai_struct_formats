meta:
  id: scala_signature
  endian: le
  license: Apache-2.0
  #imports:
  #  - /common/vlq_base128_be
  encoding: utf-8
  xref:
    wikidata: Q460584

doc: |
  Scala signatures are stored as "modified UTF" strings (see ByteCodecs.scala) in ScalaSignature.bytes (which is a string).
  To get the blob to be parsed with this KS spec, you
    1. Get annotation of a Scala class of type `ScalaSignature`
    2. get a Unicode string from its `bytes` property
    3. encode it as utf-8 into raw byte
    4. Apply `decode` from ByteCodecs.scala to the raw bytes

  Sample files can be downloaded at https://github.com/kaitai-io/kaitai_struct_formats/files/5103413/scalaSignatures.zip
  ... or generated with script https://gist.github.com/KOLANICH/f7e961d5bdf3f087567da6fdda43c4a1


doc-ref:
  - https://github.com/scala/scala/blob/2.13.x/src/reflect/scala/reflect/internal/pickling/ByteCodecs.scala
  - https://github.com/scala/scala/blob/2.13.x/src/reflect/scala/reflect/internal/pickling/PickleFormat.scala
  - https://github.com/scala/scala/blob/2.13.x/src/reflect/scala/reflect/internal/pickling/Translations.scala
  - https://github.com/scala/scala/blob/2.13.x/src/compiler/scala/tools/nsc/symtab/classfile/Pickler.scala
  - https://github.com/scala/scala/blob/2.13.x/src/reflect/scala/reflect/internal/pickling/UnPickler.scala
  - https://github.com/scala/scala/blob/2.13.x/src/reflect/scala/reflect/runtime/JavaMirrors.scala
  - https://github.com/scala/scala/blob/2.13.x/src/reflect/scala/reflect/internal/Symbols.scala
  - https://github.com/scala/scala/blob/2.13.x/src/scalap/scala/tools/scalap/scalax/rules/scalasig/Type.scala

seq:
  - id: version
    type: version
  - id: symbols_table
    type: symbols_table



types:
  vlq_base128_be:
    -webide-representation: "{value}"
    seq:
      - id: groups
        type: group
        repeat: until
        repeat-until: not _.has_next
    types:
      group:
        doc: |
          One byte group, clearly divided into 7-bit "value" chunk and 1-bit "continuation" flag.
        seq:
          - id: b
            type: u1
        instances:
          has_next:
            value: (b & 0b1000_0000) != 0
            doc: If true, then we have more bytes to read
          value:
            value: b & 0b0111_1111
            doc: The 7-bit (base128) numeric value chunk of this group
    instances:
      last:
        value: groups.size - 1
      value:
        value: >-
          groups[last].value
          + (last >= 1 ? (groups[last - 1].value << 7) : 0)
          + (last >= 2 ? (groups[last - 2].value << 14) : 0)
          + (last >= 3 ? (groups[last - 3].value << 21) : 0)
          + (last >= 4 ? (groups[last - 4].value << 28) : 0)
          + (last >= 5 ? (groups[last - 5].value << 35) : 0)
          + (last >= 6 ? (groups[last - 6].value << 42) : 0)
          + (last >= 7 ? (groups[last - 7].value << 49) : 0)
        doc: Resulting value as normal integer

  version:
    seq:
      - id: major
        -orig-id:
          - majorVersion_Nat
        type: vlq_base128_be
      - id: minor
        -orig-id:
          - minorVersion_Nat
        type: vlq_base128_be

  symbols_table:
    -orig-id:
      - Symtab
    seq:
      - id: count_vlq
        -orig-id:
          - nentries_Nat
          - nbEntries_Nat
        type: vlq_base128_be
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: count
    instances:
      count:
        value: count_vlq.value

  entry:
    -webide-representation: "{type}: {payload}"
    seq:
      - id: type_vlq
        -orig-id:
          - type_Nat
        type: vlq_base128_be
      - id: size_vlq
        -orig-id:
          - len_Nat
          - length_Nat
        type: vlq_base128_be
      - id: payload
        size: size_vlq.value
        type:
          switch-on: type
          cases:
            'type::term_name': strz
            'type::type_name': strz
            'type::none_sym': empty
            'type::type_sym': symbol_info
            'type::alias_sym': symbol_info
            'type::class_sym': symbol_info # [thistype_ref]
            'type::module_sym': symbol_info
            'type::val_sym': symbol_info
            'type::ext_ref': symbol
            'type::ext_mod_class_ref': symbol
            'type::this_type': symbol_ref
            'type::type_ref_type': type_ref_type
            'type::refined_type': compound_type
            'type::class_info_type': compound_type
            'type::method_type': method_type
            'type::implicit_method_type': method_type
            'type::poly_type': poly_type
            'type::existential_type': existential_type
            'type::annot_info': annotation
            'type::annotated_type': annotated_type
            'type::single_type': single_type
            'type::super_type': super_type
            'type::no_type': empty
            'type::no_prefix_type': empty
            'type::sym_annot': sym_annot
            'type::annot_arg_array': annot_arg_array
            'type::tree': tree
            # literals
            'type::literal_null': empty
            'type::literal_unit': empty
            'type::literal_boolean': vlq_base128_be
            'type::literal_byte': vlq_base128_be
            'type::literal_short': vlq_base128_be
            'type::literal_char': vlq_base128_be
            'type::literal_int': vlq_base128_be
            'type::literal_long': vlq_base128_be
            'type::literal_float': vlq_base128_be
            'type::literal_double': vlq_base128_be
            'type::literal_string': name_ref
            'type::literal_symbol': name_ref
            'type::literal_class': type_ref
            'type::literal_enum': symbol_ref

    instances:
      type:
        value: type_vlq.value
        enum: type

    types:
      empty:
        instances:
          valid:
            value: _io.size == 0

      ref:
        -webide-representation: "-> {value}"
        seq:
          - id: ref
            -orig-id:
              - type_Nat
            type: vlq_base128_be
        instances:
          value:
            value: "_root.symbols_table.entries[ref.value]"

      name_ref:
        -webide-representation: "-> {value}"
        seq:
          - id: ref
            type: ref
        instances:
          valid:
            value: "value.type == type::term_name or value.type == type::type_name"
            #valid: true
          value:
            value: ref.value

      symbol_ref:
        -webide-representation: "-> {value}"
        seq:
          - id: ref
            type: ref
        instances:
          valid:
            value: "type::none_sym.to_i <= value.type.to_i and value.type.to_i <= type::val_sym.to_i"
            #valid: true
          value:
            value: ref.value

      type_ref:
        -webide-representation: "-> {value}"
        seq:
          - id: ref
            type: ref
        instances:
          valid:
            value: "(value.type == type::no_type or value.type == type::no_prefix_type or value.type == type::this_type or value.type == type::single_type or value.type == type::super_type or value.type == type::constant_type or value.type == type::type_ref_type or value.type == type::type_bounds_type or value.type == type::refined_type or value.type == type::class_info_type or value.type == type::method_type or value.type == type::poly_type or value.type == type::existential_type or value.type == type::annotated_type)"
            #valid: true
          value:
            value: ref.value

      constant_ref:
        -webide-representation: "-> {value}"
        seq:
          - id: ref
            type: ref
        instances:
          valid:
            value: "(value.type == type::literal_boolean or value.type == type::literal_byte or value.type == type::literal_short or value.type == type::literal_char or value.type == type::literal_int or value.type == type::literal_long or value.type == type::literal_float or value.type == type::literal_double or value.type == type::literal_string or value.type == type::literal_unit or value.type == type::literal_class or value.type == type::literal_enum or value.type == type::literal_null or value.type == type::literal_symbol)"
            #valid: true
          value:
            value: ref.value

      class_info:
        seq:
          - id: symbol_info
            type: symbol_info
          - id: type_of_this
            type: ref
            if: _io.size > _io.pos

      symbol_info:
        -webide-representation: "{name_ref_vlq}, {owner_ref_vlq}, {flags}, {private_within_ref_vlq}, {info_ref_vlq}"
        -orig-id: SymbolInfo
        seq:
          - id: name_ref
            type: name_ref
          - id: owner_ref_vlq
            type: ref
          - id: flags
            type: flags
          - id: index
            type: vlq_base128_be
          - id: info_ref_vlq
            type: vlq_base128_be
            if: has_private_within
        instances:
          has_private_within:
            doc: |
              In Scala impl the parser is stateful.
              We don't have access to this state in KS. So we use the heuristic. The type has different length depending on his value.
            value: _io.pos < _io.size
          private_within:
            value: index.value
            if: has_private_within
          inforef:
            value: "has_private_within ? info_ref_vlq.value : index.value"
        types:
          flags:
            doc-ref: https://github.com/scala/scala/blob/2.13.x/src/reflect/scala/reflect/internal/Flags.scala
            -webide-representation: "{flags}"
            seq:
              - id: flags_vlq
                type: vlq_base128_be
            instances:
              flags:
                value: flags_vlq.value
                enum: flags_masks
              implicit:
                value: flags.to_i & flags_masks::implicit.to_i != 0
              final:
                value: flags.to_i & flags_masks::final.to_i != 0
              private:
                value: flags.to_i & flags_masks::private.to_i != 0
              protected:
                value: flags.to_i & flags_masks::protected.to_i != 0
              sealed:
                value: flags.to_i & flags_masks::sealed.to_i != 0
              override:
                value: flags.to_i & flags_masks::override.to_i != 0
              case_pkl:
                value: flags.to_i & flags_masks::case_pkl.to_i != 0
              abstract:
                value: flags.to_i & flags_masks::abstract.to_i != 0
              deferred:
                value: flags.to_i & flags_masks::deferred.to_i != 0
              method:
                value: flags.to_i & flags_masks::method.to_i != 0
              module:
                value: flags.to_i & flags_masks::module.to_i != 0
              interface:
                value: flags.to_i & flags_masks::interface.to_i != 0
            enums:
              flags_masks:
                1: implicit
                2: final
                4: private
                8: protected
                16: sealed
                32: override
                64: case_pkl
                128: abstract
                256: deferred
                512: method
                1024: module
                2048: interface

      symbol:
        seq:
          - id: name_ref
            type: name_ref
          - id: owner
            type: symbol_ref
            if: _io.size > _io.pos

      single_type:
        seq:
          - id: pre
            type: type_ref
            doc: The type of the qualifier
          - id: sym
            type: symbol_ref
            doc: The underlying symbol

      type_ref_type:
        seq:
          - id: single_type
            type: single_type
          - id: targets
            type: types

      types:
        seq:
          - id: types
            type: type_ref # readTypeRef
            repeat: eos

      symbols:
        seq:
          - id: symbols
            type: symbol_ref # readSymbolRef
            repeat: eos

      annotations:
        seq:
          - id: annotations
            type: annotation # readAnnotationRef
            repeat: eos

      super_type:
        doc: |
          See the example for [[scala.reflect.api.Trees#SuperExtractor]]
        seq:
          - id: this_type
            type: type_ref
            doc: |
              The type of the qualifier

          - id: super_type
            type: type_ref
            doc: |
              The type of the selector.

      compound_type:
        seq:
          - id: decls
            type: symbol_ref
            doc: The scope that holds the definitions comprising the type
          - id: parents
            type: types
            doc: The superclasses of the type

      poly_type:
        seq:
          - id: result_type
            type: type_ref
            doc: The underlying type
          - id: type_params
            type: types
            doc: The symbols corresponding to the type parameters

      method_type:
        seq:
          - id: result_type
            type: type_ref
            doc: The result type of the method
          - id: params
            type: symbols
            doc: The symbols that correspond to the parameters of the method

      existential_type:
        seq:
          - id: underlying
            type: type_ref
            doc: The underlying type of the existential type
          - id: quantified
            type: symbols
            doc: The symbols corresponding to the `forSome` clauses of the existential type

      annotated_type:
        seq:
          - id: underlying
            type: type_ref
            doc: The annotee
          - id: annotations
            type: annotations
            doc: The annotations

      annotation:
        -orig-id: AnnotInfoBody
        seq:
          - id: atp
            type: type_ref
          - id: args
            type: assoc
            repeat: eos
        types:
          assoc:
            seq:
              - id: name_ref
                type: name_ref
              - id: index
                type: vlq_base128_be

      sym_annot:
        seq:
          - id: symbol_ref
            type: symbol_ref
          - id: annotation
            type: annotation

      annot_arg_array:
        seq:
          - id: entries
            type: entry

      children:
        seq:
          - id: parent
            type: symbol_ref
          - id: children
            type: symbol_ref
            repeat: eos

      de_brujin_index:
        doc-ref: https://github.com/scala/scala/commit/2c6bd830b73e9907aa710360ad45a25b5a6d63a9
        seq:
          - id: level
            type: vlq_base128_be
          - id: index
            type: vlq_base128_be
          - id: args
            size-eos: true
            if: _io.size > _io.pos

      val_sym:
        seq:
          #- id: defaultGetter_Ref
          #  doc: no longer needed
          - id: symbol_info
            type: symbol_info
          - id: alias_ref
            type: vlq_base128_be
            if: _io.size > _io.pos

      modifiers:
        seq:
          - id: flags_hi
            type: vlq_base128_be
          - id: flags_lo
            type: vlq_base128_be
          - id: private_within
            type: name_ref
        instances:
          flags:
            value: (flags_hi.value << 32) + flags_lo.value

      tree:
        seq:
          - id: type
            type: u1
            enum: type
          - id: tree
            type:
              switch-on: type
              cases:
                "type::empty": empty
                "type::type": type_ref
                "type::package": package
                "type::class": class
                "type::type_def": class
                "type::module": module
                "type::val_def": val_def
                "type::label": node2
                "type::function": node2
                "type::apply_dynamic": node2
                "type::return": node2_header
                "type::super": node3
                "type::select": node3
                "type::bind": bind
                "type::this": node4
                "type::ident": node4

                "type::throw": node_5
                "type::new": node_5
                "type::singleton_type": node_5
                "type::compound_type": node_5

                "type::block": node_6
                "type::unapply": node_6
                "type::array_value": node_6
                "type::match": node_6
                "type::type_apply": node_6
                "type::apply": node_6
                "type::applied_type": node_6
                "type::existential_type": node_6

                "type::assign": node_8
                "type::typed": node_8
                "type::annotated": node_8
                "type::type_bounds": node_8

                "type::case": node_7
                "type::if": node_7

                "type::sequence": node_9
                "type::alternative": node_9
                "type::star": node_9

                "type::literal": literal
                "type::def_def": def_def
                "type::tre": tre
                "type::select_from_type": select_from_type
                "type::doc_def": doc_def
                "type::template": template
                "type::import": import

        types:
          tree_ref:
            seq:
              - id: tree_ref
                type: vlq_base128_be

          ref_tree_header:
            seq:
              - id: type_ref
                type: type_ref
              - id: symbol_ref
                type: symbol_ref
              - id: mods_ref
                type: vlq_base128_be
              - id: name_ref
                type: name_ref

          package:
            # PackageDef(refTreeRef, all(ref))
            seq:
              - id: common
                type: ref_tree_header
              - id: refs
                type: tree_ref
                repeat: eos

          class:
             # ClassDef(modsRef, typeNameRef, rep(tparamRef), implRef)
             # TypeDef(modsRef, typeNameRef, rep(tparamRef), ref)
            seq:
              - id: common
                type: ref_tree_header
              - id: ref
                type: tree_ref
              - id: refs
                type: tree_ref
                repeat: eos

          module:
            # ModuleDef(modsRef, termNameRef, implRef)
            seq:
              - id: common
                type: ref_tree_header
              - id: ref
                type: tree_ref

          val_def:
            # ValDef(modsRef, termNameRef, ref, ref)
            seq:
              - id: common
                type: ref_tree_header
              - id: ref1
                type: tree_ref
              - id: ref2
                type: tree_ref



          def_def:
            # DefDef(modsRef, termNameRef, rep(tparamRef), rep(rep(vparamRef)), ref, ref)
            seq:
              - id: common
                type: ref_tree_header
              - id: params_count_vlq
                -orig-id: numtparams_Nat
                type: vlq_base128_be
              - id: tree_refs
                type: param
                repeat: expr
                repeat-expr: params_count_vlq.value
              - id: tree_ref1
                type: tree_ref
              - id: tree_ref2
                type: tree_ref
            types:
              param:
                seq:
                  - id: params_count_vlq
                    -orig-id: numtparams_Nat
                    type: vlq_base128_be
                  - id: tree_ref
                    type: tree_ref
                    repeat: eos

          node1_header:
            seq:
              - id: type_ref
                type: type_ref
              - id: symbol_ref
                type: symbol_ref

          node2_header:
            # Return(ref)
            seq:
              - id: node1_header
                type: node1_header
              - id: tree_ref
                type: tree_ref

          node2:
            # LabelDef(termNameRef, rep(idRef), ref)
            # Function(rep(vparamRef), ref)
            # ApplyDynamic(ref, all(ref))
            seq:
              - id: node2_header
                type: node2_header
              - id: tree_refs
                type: tree_ref
                repeat: eos

          import:
            # Import(ref, selectorsRef)
            seq:
              - id: node2_header
                type: node2_header
              - id: imports
                type: import
                repeat: eos
            types:
              import:
                seq:
                  - id: first
                    type: vlq_base128_be
                  - id: second
                    type: vlq_base128_be

          node3:
            # Super(ref, typeNameRef)
            # Select(ref, nameRef)
            seq:
              - id: node2_header
                type: node2_header
              - id: name_ref
                type: name_ref

          doc_def:
            #case DOCDEFtree =>
            #  val comment = readConstantRef match {
            #    case Constant(com: String)  => com
            #    case other => errorBadSignature("Document comment not a string (" + other + ")")
            #  }
            #  val definition = readTreeRef()
            seq:
              - id: node1_header
                type: node1_header
              - id: string_ref
                type: vlq_base128_be
              - id: tree_ref
                type: tree_ref

          template:
            # Template(rep(ref), vparamRef, all(ref))
            seq:
              - id: node1_header
                type: node1_header
              - id: numparents_vlq
                type: vlq_base128_be
              - id: parents
                type: vlq_base128_be
                repeat: expr
                repeat-expr: numparents_vlq.value
              - id: tree_ref
                type: tree_ref
              - id: tree_refs
                type: tree_ref
                repeat: eos

          node4:
            # This(typeNameRef)
            # Ident(nameRef)
            seq:
              - id: node1_header
                type: node1_header
              - id: name_ref
                type: name_ref

          bind:
            # Bind(nameRef, ref)
            seq:
              - id: node4
                type: node4
              - id: tree_ref
                type: tree_ref

          node_5:
            # Throw(ref)
            # New(ref)
            # SingletonTypeTree(ref)
            # CompoundTypeTree(implRef)
            seq:
              - id: type_ref
                type: type_ref
              - id: tree_ref
                type: tree_ref

          node_6:
            # all(ref) match { case stats :+ expr => Block(stats, expr) }
            # UnApply(ref, all(ref))
            # ArrayValue(ref, all(ref))
            # Match(ref, all(caseRef))
            # TypeApply(ref, all(ref))
            # fixApply(Apply(ref, all(ref)), tpe)
            # AppliedTypeTree(ref, all(ref))
            # ExistentialTypeTree(ref, all(memberRef))
            seq:
              - id: node_5
                type: node_5
              - id: tree_refs
                type: tree_ref
                repeat: eos

          node_7:
            # CaseDef(ref, ref, ref)
            # If(ref, ref, ref)
            seq:
              - id: node_8
                type: node_8
              - id: tree_ref2
                type: tree_ref

          node_8:
            # Assign(ref, ref)
            # Typed(ref, ref)
            # Annotated(ref, ref)
            # TypeBoundsTree(ref, ref)
            seq:
              - id: node_5
                type: node_5
              - id: tree_ref
                type: tree_ref

          tre:
            # Try(ref, rep(caseRef), ref)
            seq:
              - id: node_8
                type: node_8
              - id: tree_refs
                type: tree_ref
                repeat: eos

          literal:
            # Literal(constRef)
            seq:
              - id: type_ref
                type: type_ref
              - id: constant_ref
                type: vlq_base128_be

          select_from_type:
            # SelectFromTypeTree(ref, typeNameRef)
            seq:
              - id: node_5
                type: node_5
              - id: name_ref
                type: name_ref

          node_9:
            # Alternative(all(ref))
            # Star(ref)
            seq:
              - id: type_ref
                type: type_ref
              - id: tree_refs
                type: tree_ref
                repeat: eos

        enums:
          type:
            1: empty
            2: package
            3: class
            4: module
            5: val_def
            6: def_def
            7: type_def
            8: label
            9: import
            11: doc_def
            12: template
            13: block
            14: case
            15:
              id: sequence
              doc: this node type has been removed
            16: alternative
            17: star
            18: bind
            19: unapply
            20: array_value
            21: function
            22: assign
            23: if
            24: match
            25: return
            26: tre
            27: throw
            28: new
            29: typed
            30: type_apply
            31: apply
            32: apply_dynamic
            33: super
            34: this
            35: select
            36: ident
            37: literal
            38: type
            39: annotated
            40: single_to_ntype
            41: select_from_type
            42: compound_type
            43: applied_type
            44: type_bounds
            45: existential_type


    enums:
      type:
        1:
          id: term_name #
          -orig-id: TERMNAME

        2: #
          id: type_name
          -orig-id: TYPENAME
        3: #
          id: none_sym
          -orig-id: NONEsym
        4: #
          id: type_sym
          -orig-id: TYPEsym
        5: #
          id: alias_sym
          -orig-id: ALIASsym
        6: #
          id: class_sym
          -orig-id: CLASSsym
        7: #
          id: module_sym
          -orig-id: MODULEsym
        8: #
          id: val_sym
          -orig-id: VALsym
        9: #
          id: ext_ref
          -orig-id: EXTref
        10: #
          id: ext_mod_class_ref
          -orig-id: EXTMODCLASSref
        11: #
          id: no_type
          -orig-id: NOtpe
        12: #
          id: no_prefix_type
          -orig-id: NOPREFIXtpe
        13: #
          id: this_type
          -orig-id: THIStpe
        14: #
          id: single_type
          -orig-id: SINGLEtpe
        15:
          id: constant_type
          -orig-id: CONSTANTtpe
        16: #
          id: type_ref_type
          -orig-id: TYPEREFtpe
        17: #
          id: type_bounds_type
          -orig-id: TYPEBOUNDStpe
        18: #
          id: refined_type
          -orig-id: REFINEDtpe
        19: #
          id: class_info_type
          -orig-id: CLASSINFOtpe
        20: #
          id: method_type
          -orig-id: METHODtpe
        21: #
          id: poly_type
          -orig-id: POLYTtpe
        22:
          id: implicit_method_type #
          -orig-id: IMPLICITMETHODtpe
          doc: no longer generated
        23:
          id: literal
          -orig-id: LITERAL
          doc: base line for literals

        24: literal_unit
        25: literal_boolean
        26: literal_byte
        27: literal_short
        28: literal_char
        29: literal_int
        30: literal_long
        31: literal_float
        32: literal_double
        33: literal_string
        34: literal_null
        35: literal_class
        36: literal_enum
        37:
          id: literal_symbol
          doc: "todo: Never pickled, to be dropped once we have a starr that does not emit it."

        # end literals

        40:
          id: sym_annot
          -orig-id: SYMANNOT
        41: #
          id: children
          -orig-id: CHILDREN
        42: #
          id: annotated_type
          -orig-id: ANNOTATEDtpe
        43: #
          id: annot_info
          -orig-id: ANNOTINFO
        44:
          id: annot_arg_array
          -orig-id: ANNOTARGARRAY

        46: #
          id: super_type
          -orig-id: SUPERtpe
        47: #
          id: de_bruijn_index_type
          -orig-id: DEBRUIJNINDEXtpe
          doc: no longer generated and used
        48: #
          id: existential_type
          -orig-id: EXISTENTIALtpe

        49: #
          id: tree
          -orig-id: TREE
          doc: prefix code that means a tree is coming
        50:
          id: modifiers
          -orig-id: MODIFIERS
