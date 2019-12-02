meta:
  id: vba
  title: Visual Basic exe structures
  application: Visual Basic
  file-extension: exe
  xref:
    wikidata: Q2378
  endian: le
  license: Apache-2.0
  encoding: ascii
  ks-opaque-types: true
doc: |
  Converted from https://github.com/williballenthin/python-vb/blob/master/vb/__init__.py with addition of some structures described in various reverse-engineered documentation
  
  # an external script converting raw virtual addresses to offsets in a file is needed, save it as resolve_offset.py
  from kaitaistruct import KaitaiStruct, KaitaiStream
  
  class ResolveOffset(KaitaiStruct):
    __slots__ = ("ofs",)
    def __init__(self, rawAddress: int, root, _io: KaitaiStream, _parent=None, _root=None):
      _root = root
      self._parent = _parent
      self.ofs = _root.pe.get_offset_from_rva(rawAddress - _root.pe.OPTIONAL_HEADER.ImageBase)

doc-ref:
  - https://github.com/williballenthin/python-vb/blob/master/vb/__init__.py
  - https://web.archive.org/web/20071020232030if_/http://www.alex-ionescu.com/vb.pdf
  - https://www.vb-decompiler.org/pcode_decompiling.htm
  - https://sysenter-eip.github.io/VBParser#visual-basic-5-6-file-format-information
params:
  - id: pe
  - id: offset
    type: u8
instances:
  header:
    pos: offset
    type: header

types:
  header:
    -orig-id:
      - EXEPROJECTINFO # First is the identifier from python-vb, they are the same as in Ionescu PDF, often with hungarian notation prefix removed
      - VBHeader # Second is from the docs from vb-decompiler.org, often with hungarian notation prefix removed
      # if it is not an array but just a string with hungarian prefix stripped it may mean that the naming is consistent in both sources.
    seq:
      - id: signature
        -orig-id:
          - VbMagic
          - Signature
        contents: VB5!
      - id: runtime_build
        -orig-id: RuntimeBuild
        type: u2
      - id: lang_dll # 0x6
        type: str
        size: 0xE
        -orig-id:
          - LangDll
          - LanguageDLL
      - id: sec_lang_dll # 0x14
        type: str
        size: 0xE
        -orig-id:
          - SecLangDll
          - BackupLanguageDLL
      - id: runtime_revision
        -orig-id:
          - RuntimeRevision
          - RuntimeDLLVersion
        type: u2
      - id: lcid
        -orig-id:
          - LCID
          - LanguageID
        type: u4
      - id: sec_lcid
        -orig-id:
          - SecLCID
          - BackupLanguageID
        type: u4
      - id: sub_main
        -orig-id: SubMain
        type: resolved_ptr
      - id: project_data_ptr
        -orig-id:
          - ProjectData
          - ProjectInfo
        type: resolved_ptr
      - id: mdl_int_ctls
        -orig-id:
          - fMdlIntCtls
          - fMDLIntObjs
        type: u4
      - id: mdl_int_ctls_2
        -orig-id:
          - fMdlIntCtls2
          - fMDLIntObjs2
        type: u4
      - id: thread_flags
        -orig-id: dwThreadFlags
        type: u4
      - id: thread_count
        -orig-id: dwThreadCount
        type: u4
      - id: form_count
        -orig-id: wFormCount
        type: u2
      - id: external_count
        -orig-id: wExternalCount
        type: u2
      - id: thunk_count
        -orig-id: dwThunkCount
        type: u4
      - id: gui_table_ptr
        -orig-id: GuiTable
        type: resolved_ptr
      - id: external_table_ptr
        -orig-id: ExternalTable
        type: resolved_ptr
      - id: com_register_data_ptr
        -orig-id: ComRegisterData
        type: resolved_ptr
      - id: project_description
        -orig-id:
          - bSZProjectDescription
          - oProjectExename
        type: "strz_ofs(_root.offset)"
      - id: project_exe_name
        -orig-id:
          - bSZProjectExeName
          - oProjectTitle
        type: "strz_ofs(_root.offset)"
      - id: project_help_file
        -orig-id:
          - bSZProjectHelpFile
          - oHelpFile
        type: "strz_ofs(_root.offset)"
      - id: project_name
        -orig-id:
          - bSZProjectName
          - oProjectName
        type: "strz_ofs(_root.offset)"

    instances:
      project_data:
        io: _root._io
        pos: project_data_ptr.ofs
        type: project_data
    types:
      project_data:
        -orig-id:
          - ProjectData
          - ProjectInfo
        seq:
          - id: version
            -orig-id:
              - Version
              - lTemplateVersion
            type: u4
          - id: object_table_ptr
            -orig-id: ObjectTable
            type: resolved_ptr
          - id: dw_null
            -orig-id:
              - dwNull
              - lNull1
            type: u4
          - id: code_start_ptr
            -orig-id:
              - CodeStart
              - StartOfCode
            type: resolved_ptr
          - id: code_end_ptr
            -orig-id:
              - CodeEnd
              - EndOfCode
            type: resolved_ptr
          - id: data_size
            -orig-id:
              - dwDataSize
              - lDataBufferSize
            type: u4
          - id: thread_space_ptr
            -orig-id: ThreadSpace
            type: resolved_ptr
          - id: vba_seh_ptr
            -orig-id:
              - VbaSeh
              - VBAExceptionhandler
            type: resolved_ptr
          - id: native_code_ptr
            -orig-id: NativeCode
            type: resolved_ptr
          - id: primitive_path
            -orig-id: wsPrimitivePath
            type: strz
            #encoding: utf-16le
            size: 6
            if: _root.header.runtime_build < 9782
          - id: path_information
            -orig-id: szPathInformation
            type: str # fucking incorrectly processes strz
            #pad-right: 0x00
            encoding: utf-16le
            size: "0x210 - (_root.header.runtime_build < 9782 ? 6 : 0)"
          - id: external_table
            -orig-id: lpExternalTable
            type: u4
          - id: external_count
            -orig-id: dwExternalCount
            type: u4

        instances:
          object_table:
            io: _root._io
            pos: object_table_ptr.ofs
            type: object_table

      project_data_2:
        -orig-id: ProjectData2
        seq:
          - id: heap_link_ptr
            -orig-id: lpHeapLink
            type: u4
          - id: object_table_ptr
            -orig-id: lpObjectTable
            type: resolved_ptr
          - id: reserved
            -orig-id: dwReserved
            type: u4
          - id: unused
            -orig-id: dwUnused
            type: u4

          # points to array of pointers to `PrivateObjectDescriptor`
          - id: object_list_ptr
            -orig-id: lpObjectList
            type: resolved_ptr
          - id: unused_2
            -orig-id: dwUnused2
            type: u4
          - id: sz_project_description
            -orig-id: szProjectDescription
            type: u4
          - id: sz_project_help_file
            -orig-id: szProjectHelpFile
            type: u4
          - id: reserved_2
            -orig-id: dwReserved2
            type: u4
          - id: help_context_id
            -orig-id: dwHelpContextId
            type: u4

        instances:
          object_table:
            io: _root._io
            pos: object_table_ptr.ofs
            type: object_table




  resolved_ptr:
    seq:
      - id: ptr
        type: u4
    instances:
      valid:
        value: ptr != 0
      resolved:
        pos: 0
        type: "resolve_offset(ptr, _root)" # otherwise it won't be passed
      ofs:
        value: resolved.ofs.as<u4>
        if: valid

  strz_ofs:
    params:
      - id: base
        type: u4
    seq:
      - id: ptr
        type: u4
    instances:
      value:
        io: _root._io
        pos: ptr + base
        type: strz
        if: ptr != 0

  strz_ptr:
    seq:
      - id: ptr
        type: resolved_ptr
    instances:
      value:
        pos: ptr.ofs
        type: strz
        if: ptr.valid


  uuid:
    seq:
      - id: uuid
        size: 0x10

  tag_reg_data:
    -orig-id: tagREGDATA
    seq:
      - id: reg_info_ptr
        -orig-id: bRegInfo
        type: u4
      - id: project_name_size
        -orig-id: bSZProjectName
        type: u4
      - id: help_directory_size
        -orig-id: bSZHelpDirectory
        type: u4
      - id: project_description_size
        -orig-id: bSZProjectDescription
        type: u4
      
      - id: project_clsid
        -orig-id: uuidProjectClsId
        type: uuid
      
      - id: tlb_lcid
        -orig-id: dwTlbLcid
        type: u4
      - id: unknown
        -orig-id: wUnknown
        type: u2
      - id: ver_major
        -orig-id: wTlbVerMajor
        type: u2
      - id: ver_minor
        -orig-id: wTlbVerMinor
        type: u2
    instances:
      reg_info:
        io: _root._io
        pos: reg_info_ptr
        type: tag_reg_info
        if: reg_info_ptr != 0

  tag_reg_info:
    -orig-id: tagRegInfo
    seq:
      - id: next_object
        -orig-id: bNextObject
        type: u4
      - id: object_name
        -orig-id: bObjectName
        type: u4
      - id: object_description
        -orig-id: bObjectDescription
        type: u4
      - id: instancing
        -orig-id: dwInstancing
        type: u4
      - id: object_id
        -orig-id: dwObjectId
        type: u4

      - id: object_uuid
        -orig-id: uuidObject
        type: uuid
      - id: is_interface
        -orig-id: fIsInterface
        type: u4
      - id: object_iface_uuid
        -orig-id: bUuidObjectIFace
        type: u4
      - id: events_iface_uuid
        -orig-id: bUuidEventsIFace
        type: u4
      - id: has_events
        -orig-id: fHasEvents
        type: u4
      - id: misc_status
        -orig-id: dwMiscStatus
        type: u4
      - id: class_type
        -orig-id: fClassType
        type: u1

      # see `OJBECT_*` constants
      - id: object_type
        -orig-id: fObjectType
        type: u1
      - id: toolbox_bitmap32
        -orig-id: wToolboxBitmap32
        type: u2
      - id: default_icon
        -orig-id: wDefaultIcon
        type: u2
      - id: is_designer
        -orig-id: fIsDesigner
        type: u2
      - id: designer_data_ptr
        -orig-id: bDesignerData
        type: u4


  designer_data:
    -orig-id: DesignerData
    seq:
      - id: uuid_designer
        -orig-id: uuidDesigner
        type: uuid
      - id: cb_struct_size
        -orig-id: cbStructSize
        type: u4
      - id: bstr_addin_reg_key
        -orig-id: bstrAddinRegKey
        type: u4

  private_object_descriptor:
    -orig-id: PrivateObjectDescriptor
    seq:
      - id: heap_link_ptr
        -orig-id: lpHeapLink
        type: u4
      - id: object_info_ptr
        -orig-id: lpObjectInfo
        type: resolved_ptr
      - id: reserved
        -orig-id: dwReserved
        type: u4
      - id: dw_ide_data # 0xC
        -orig-id: dwIdeData
        type: u4
        repeat: expr
        repeat-expr: 3
      - id: object_list_ptr
        -orig-id: lpObjectList
        type: resolved_ptr
      - id: ide_data_2
        -orig-id: dwIdeData2
        type: u4
      - id: object_list_2_ptr
        -orig-id: lpObjectList2
        type: resolved_ptr
        repeat: expr
        repeat-expr: 3
      - id: dw_ide_data_3
        -orig-id: dwIdeData3
        type: u4
        repeat: expr
        repeat-expr: 3
      - id: object_type
        -orig-id: dwObjectType
        type: u4
      - id: identifier
        -orig-id: dwIdentifier
        type: u4


  object_table:
    -orig-id: ObjectTable
    seq:
      - id: heap_link_ptr
        -orig-id: lpHeapLink
        type: u4
      - id: exec_proj_ptr
        -orig-id:
          - ExecProj
          - aExecProj
        type: u4
      - id: project_info_2_ptr
        -orig-id: ProjectInfo2
        type: resolved_ptr
      - id: reserved
        -orig-id:
          - dwReserved
          - lConst1
        type: u4
      - id: "null"
        -orig-id: dwNull
        type: u4
      - id: project_object_ptr
        -orig-id: lpProjectObject
        type: u4
      - id: uuid_object
        -orig-id:
          - uuidObject
          - uuidObjectTable
        type: uuid
      - id: f_compile_state
        -orig-id:
          - fCompileState
          - fCompileType
        type: u2
      - id: total_objects_count
        -orig-id:
          - TotalObjects
          - ObjectsCount
        type: u2
      - id: compiled_objects_count
        -orig-id: wCompiledObjects
        type: u2
      - id: count_of_objects_in_use
        -orig-id: wObjectsInUse
        type: u2
      - id: object_array_ptr
        -orig-id:
          - ObjectArray
          - ObjectsArray
        type: resolved_ptr
      - id: f_ide_flag
        -orig-id: fIdeFlag
        type: u4
      - id: ide_data_ptr
        -orig-id: lpIdeData
        type: resolved_ptr
      - id: ide_data_2_ptr
        -orig-id: lpIdeData2
        type: resolved_ptr
      - id: project_name
        -orig-id:
          - ProjectName
          - NTSProjectName
        type: strz_ptr
      - id: lcid
        -orig-id:
          - dwLcid
          - lLcID1
        type: u4
      - id: lcid_2
        -orig-id:
          - dwLcid2
          - lLcID2
        type: u4
      - id: ide_data_3_ptr
        -orig-id: lpIdeData3
        type: resolved_ptr
      - id: identifier
        -orig-id:
          - dwIdentifier
          - lTemplateVersion
        type: u4
    instances:
      public_object_descriptors:
        io: _root._io
        pos: object_array_ptr.ofs
        type: public_object_descriptor
        repeat: expr
        repeat-expr: compiled_objects_count
    types:
      public_object_descriptor:
        -orig-id:
          - PublicObjectDescriptor
          - TObject
        seq:
          - id: object_info_ptr
            -orig-id: ObjectInfo
            type: resolved_ptr
          - id: reserved
            -orig-id: Reserved
            type: u4
          - id: public_bytes_ptr
            -orig-id: lpPublicBytes
            type: resolved_ptr
          - id: static_bytes_ptr
            -orig-id: lpStaticBytes
            type: resolved_ptr
          - id: module_public_ptr
            -orig-id: lpModulePublic
            type: resolved_ptr
          - id: module_static_ptr
            -orig-id: lpModuleStatic
            type: resolved_ptr
          - id: object_name
            -orig-id:
              - ObjectName
              - NTSObjectName
            type: strz_ptr
          - id: method_count
            -orig-id: dwMethodCount
            type: u4
          - id: method_names_ptr
            -orig-id: MethodNames
            type: resolved_ptr
          - id: static_vars_offset
            -orig-id: bStaticVars
            type: u4
          - id: f_object_type
            -orig-id: fObjectType
            type: object_type_flags
          - id: "null"
            -orig-id: dwNull
            type: u4
        instances:
          object_infos:
            io: _root._io
            pos: object_info_ptr.ofs
            type: object_infos(f_object_type.has_optional_info)
        types:
          object_infos:
            params:
              - id: has_optional
                type: b1
            seq:
              - id: mandatory
                type: object_info
              - id: optional
                type: optional_object_info
                if: has_optional
            types:
              object_info:
                -orig-id:
                  - ObjectInfo
                  - TObjectInfo
                seq:
                  - id: w_ref_count
                    -orig-id:
                      - RefCount
                      - iConst1
                    type: u2
                  - id: w_object_index
                    -orig-id:
                      - ObjectIndex
                      - ObjectIndex
                    type: u2
                  - id: object_table_ptr
                    -orig-id: ObjectTable
                    type: resolved_ptr
                  - id: ide_data_ptr
                    -orig-id:
                      - IdeData
                      - Null1
                    type: resolved_ptr
                  - id: private_object_ptr
                    -orig-id:
                      - PrivateObject
                      - ObjectDescriptor
                    type: resolved_ptr
                  - id: reserved
                    -orig-id:
                      - dwReserved
                      - lConst2
                    type: u4
                  - id: "null"
                    -orig-id:
                      - dwNull
                      - lNull2
                    type: u4
                  - id: object_ptr
                    -orig-id:
                      - Object
                      - ObjectHeader
                    type: resolved_ptr
                  - id: project_data_ptr
                    -orig-id:
                      - ProjectData
                      - ObjectData
                    type: resolved_ptr
                  
                  # the following is only for pcode
                  - id: method_count
                    -orig-id: MethodCount
                    type: u2
                  - id: method_count_2
                    -orig-id:
                      - MethodCount2
                      - Null3
                    type: u2
                  - id: methods_ptr
                    -orig-id:
                      - Methods
                      - MethodTable
                    type: resolved_ptr
                  - id: count_of_constants
                    -orig-id:
                      - Constants
                      - ConstantsCount
                    type: u2
                  - id: w_max_constants
                    -orig-id: MaxConstants
                    type: u2
                  - id: ide_data_2_ptr
                    -orig-id: lpIdeData2
                    type: resolved_ptr
                  - id: ide_data_3_ptr
                    -orig-id: lpIdeData3
                    type: resolved_ptr
                  - id: constants_ptr
                    -orig-id: lpConstants
                    type: resolved_ptr
                instances:
                  methods:
                    pos: methods_ptr.ofs
                    type: method_ref
                    repeat: expr
                    repeat-expr: method_count
                    if: method_count != 0
                types:
                  method_ref:
                    seq:
                      - id: ptr
                        type: resolved_ptr
                    instances:
                      method:
                        pos: ptr.ofs
                        type: method
                        if: ptr.valid
                    types:
                      method:
                        doc-ref: the docs is from vb-decompiler.org
                        -orig-id:
                          - null
                          - ProcDscInfo
                        seq:
                          - id: table_ptr
                            -orig-id: ProcTable
                            type: resolved_ptr
                          - id: field_4
                            -orig-id: field_4
                            type: u4
                          - id: frame_size
                            -orig-id: FrameSize
                            type: u4
                          - id: proc_size
                            -orig-id: ProcSize
                            type: u4
                          # rest of structure is ommitted
                        instances:
                          table:
                            pos: table_ptr.ofs
                            type: table
                            if: table_ptr.valid
                          pcode:
                            pos: table.pcode_ptr.ofs
                            size: proc_size
                            if: table_ptr.valid and table.pcode_ptr.valid
                        types:
                          table:
                            seq:
                              - id: unkn0
                                -orig-id: SomeTemp
                                size: 52
                              - id: pcode_ptr
                                -orig-id: DataConst
                                type: resolved_ptr

              optional_object_info:
                -orig-id: OptionalObjectInfo
                seq:
                  - id: object_gui_guids
                    -orig-id: dwObjectGuiGuids
                    type: u4
                  - id: object_clsid_ptr
                    -orig-id: lpObjectCLSID
                    type: resolved_ptr
                  - id: "null"
                    -orig-id: dwNull
                    type: u4
                  - id: guid_object_gui_table_ptr
                    -orig-id: lpGuidObjectGUITable
                    type: u4
                  - id: object_default_iid_count
                    -orig-id: dwObjectDefaultIIDCount
                    type: u4
                  - id: object_events_iid_table_ptr
                    -orig-id: lpObjectEventsIIDTable
                    type: resolved_ptr
                  - id: object_events_iid_count
                    -orig-id: dwObjectEventsIIDCount
                    type: u4
                  - id: object_default_iid_table_ptr
                    -orig-id: lpObjectDefaultIIDTable
                    type: resolved_ptr
                  - id: control_count
                    -orig-id: dwControlCount
                    type: u4
                  - id: controls_ptr
                    -orig-id: lpControls
                    type: resolved_ptr
                  - id: w_method_link_count
                    -orig-id: wMethodLinkCount
                    type: u2
                  - id: w_p_code_count
                    -orig-id: wPCodeCount
                    type: u2
                  - id: w_initialize_event_ptr
                    -orig-id: bWInitializeEvent
                    type: u2
                  - id: w_terminate_event_ptr
                    -orig-id: bWTerminateEvent
                    type: u2
                  - id: method_link_table_ptr
                    -orig-id: lpMethodLinkTable
                    type: resolved_ptr
                  - id: basic_class_object_ptr
                    -orig-id: lpBasicClassObject
                    type: resolved_ptr
                  - id: null_3
                    -orig-id: dwNull3
                    type: u4
                  - id: ide_data_ptr
                    -orig-id: lpIdeData
                    type: resolved_ptr


  control_info:
    -orig-id: ControlInfo
    seq:
      - id: f_control_type
        -orig-id: fControlType
        type: u2
      - id: w_event_count
        -orig-id: wEventCount
        type: u2
      - id: w_unk_1
        -orig-id: wUnk1
        type: u2
      - id: bw_events_offset
        -orig-id: bWEventsOffset
        type: u2
      - id: lp_guid
        -orig-id: lpGuid
        type: u4
      - id: w_index
        -orig-id: wIndex
        type: u2
      - id: w_unk_2
        -orig-id: wUnk2
        type: u2
      - id: w_unnamed_events
        -orig-id: wUnnamedEvents
        type: u2
      - id: w_flags
        -orig-id: wFlags
        type: u2
      - id: "null"
        -orig-id: dwNull2
        type: u4
      - id: event_table_ptr
        -orig-id: lpEventTable
        type: resolved_ptr
      - id: ide_data_ptr
        -orig-id: lpIdeData
        type: resolved_ptr
      - id: name
        -orig-id: lpszName
        type: strz_ptr
      - id: index_copy
        -orig-id: dwIndexCopy
        type: u4


  external_table_entry:
    -orig-id: ExternalTableEntry
    seq:
      - id: entry_type
        -orig-id: dwEntryType
        type: u4
      - id: p_import_descriptor
        -orig-id: pImportDescriptor
        type: u4


  import_descriptor:
    -orig-id: ImportDescriptor
    seq:
      - id: p_dll_name
        -orig-id: pDllName
        type: u4
      - id: p_api_name
        -orig-id: pApiName
        type: u4


  event_handler_info:
    -orig-id: EventHandlerInfo
    seq:
      - id: "null"
        -orig-id: dwNull
        type: u4
      - id: p_controls
        -orig-id: pControls
        type: u4
      - id: p_object_info
        -orig-id: pObjectInfo
        type: u4
      - id: pevent_sink_query_interface
        -orig-id: pEVENT_SINK_QueryInterface
        type: u4
      - id: pevent_sink_add_ref
        -orig-id: pEVENT_SINK_AddRef
        type: u4
      - id: pevent_sink_release
        -orig-id: pEVENT_SINK_Release
        type: u4



  extended_event_handler_info:
    -orig-id: ExtendedEventHandlerInfo
    seq:
      - id: "null"
        -orig-id: dwNull
        type: u4
      - id: p_controls
        -orig-id: pControls
        type: u4
      - id: p_object_info
        -orig-id: pObjectInfo
        type: u4
      - id: pevent_sink_query_interface
        -orig-id: pEVENT_SINK_QueryInterface
        type: u4
      - id: pevent_sink_add_ref
        -orig-id: pEVENT_SINK_AddRef
        type: u4
      - id: pevent_sink_release
        -orig-id: pEVENT_SINK_Release
        type: u4
      - id: pidispatch_get_type_info_count
        -orig-id: pIDISPATCH_GetTypeInfoCount
        type: u4
      - id: pidispatch_get_type_info
        -orig-id: pIDISPATCH_GetTypeInfo
        type: u4
      - id: pidispatch_get_i_ds_of_names
        -orig-id: pIDISPATCH_GetIDsOfNames
        type: u4
      - id: pidispatch_invoke
        -orig-id: pIDISPATCH_Invoke
        type: u4

  event_table_entry:
    -orig-id: EventTableEntry
    seq:
      - id: f_flags
        -orig-id: fFlags
        type: u4
      - id: w_proc_type
        -orig-id: wProcType
        type: u4
      - id: link
        type: method_link
    types:
      method_link:
        -orig-id: MethodLink
        seq:
          - id: b_link_type
            -orig-id: bLinkType
            type: u1
          - id: p_method
            -orig-id: pMethod
            type: u4





  object_type_flags:
    seq:
      - id: unkn0
        type: b6
      - id: designer
        -orig-id: OBJECT_DESIGNER
        type: b1
      - id: has_optional_info
        -orig-id: OBJECT_HAS_OPTIONAL_INFO
        type: b1
      - id: user_document
        -orig-id: OBJECT_USER_DOCUMENT
        type: b1
      - id: unkn1
        type: b5
      - id: object_user_control
        -orig-id: OBJECT_USER_CONTROL
        type: b1
      - id: object_class_module
        type: b1
        -orig-id: OBJECT_CLASS_MODULE
      - id: unkn2
        type: u2
enums:
  thread:
    0x1:
      id: apartment_model
      -orig-id: THREAD_APARTMENTMODEL
    0x2:
      id: require_license
      -orig-id: THREAD_REQUIRELICENSE
    0x4:
      id: unattended
      -orig-id: THREAD_UNATTENDED
    0x8:
      id: single_threaded
      -orig-id: THREAD_SINGLETHREADED
    0x10:
      id: retained
      -orig-id: THREAD_RETAINED


  control_1:
    # first flag zone
    0x1:
      id: picture_box
      -orig-id: CONTROL_FLAG_PICTUREBOX
    0x2:
      id: label
      -orig-id: CONTROL_FLAG_LABEL
    0x4:
      id: textbox
      -orig-id: CONTROL_FLAG_TEXTBOX
    0x8:
      id: frame
      -orig-id: CONTROL_FLAG_FRAME
    0x10:
      id: command_button
      -orig-id: CONTROL_FLAG_COMMANDBUTTON
    0x20:
      id: checkbox
      -orig-id: CONTROL_FLAG_CHECKBOX
    0x40:
      id: option_button
      -orig-id: CONTROL_FLAG_OPTIONBUTTON
    0x80:
      id: combo_box
      -orig-id: CONTROL_FLAG_COMBOBOX
    0x100:
      id: list_box
      -orig-id: CONTROL_FLAG_LISTBOX
    0x200:
      id: hscrollbar
      -orig-id: CONTROL_FLAG_HSCROLLBAR
    0x400:
      id: vscrollbar
      -orig-id: CONTROL_FLAG_VSCROLLBAR
    0x800:
      id: timer
      -orig-id: CONTROL_FLAG_TIMER
    0x1000:
      id: print
      -orig-id: CONTROL_FLAG_PRINT
    0x2000:
      id: form
      -orig-id: CONTROL_FLAG_FORM
    0x4000:
      id: screen
      -orig-id: CONTROL_FLAG_SCREEN
    0x8000:
      id: clipboard
      -orig-id: CONTROL_FLAG_CLIPBOARD
    0x10000:
      id: drive
      -orig-id: CONTROL_FLAG_DRIVE
    0x20000:
      id: dir
      -orig-id: CONTROL_FLAG_DIR
    0x40000:
      id: file_list_box
      -orig-id: CONTROL_FLAG_FILELISTBOX
    0x80000:
      id: menu
      -orig-id: CONTROL_FLAG_MENU
    0x100000:
      id: mdiform
      -orig-id: CONTROL_FLAG_MDIFORM
    0x200000:
      id: app
      -orig-id: CONTROL_FLAG_APP
    0x400000:
      id: shape
      -orig-id: CONTROL_FLAG_SHAPE
    0x800000:
      id: line
      -orig-id: CONTROL_FLAG_LINE
    0x1000000:
      id: image
      -orig-id: CONTROL_FLAG_IMAGE
    0x2000000:
      id: unsupported0
      -orig-id: CONTROL_FLAG_UNSUPPORTED0
    0x4000000:
      id: unsupported1
      -orig-id: CONTROL_FLAG_UNSUPPORTED1
    0x8000000:
      id: unsupported2
      -orig-id: CONTROL_FLAG_UNSUPPORTED2
    0x10000000:
      id: unsupported3
      -orig-id: CONTROL_FLAG_UNSUPPORTED3
    0x20000000:
      id: unsupported4
      -orig-id: CONTROL_FLAG_UNSUPPORTED4
    0x40000000:
      id: unsupported5
      -orig-id: CONTROL_FLAG_UNSUPPORTED5
    0x80000000:
      id: unsupported6
      -orig-id: CONTROL_FLAG_UNSUPPORTED6

  control_2:
    # second flag zone
    0x1:
      id: flag_unsupported7
      -orig-id: CONTROL_FLAG_UNSUPPORTED7
    0x2:
      id: flag_unsupported8
      -orig-id: CONTROL_FLAG_UNSUPPORTED8
    0x4:
      id: flag_unsupported9
      -orig-id: CONTROL_FLAG_UNSUPPORTED9
    0x8:
      id: flag_unsupported10
      -orig-id: CONTROL_FLAG_UNSUPPORTED10
    0x10:
      id: flag_unsupported11
      -orig-id: CONTROL_FLAG_UNSUPPORTED11
    0x20:
      id: flag_dataquery
      -orig-id: CONTROL_FLAG_DATAQUERY
    0x40:
      id: flag_ole
      -orig-id: CONTROL_FLAG_OLE
    0x80:
      id: flag_unsupported12
      -orig-id: CONTROL_FLAG_UNSUPPORTED12
    0x100:
      id: user_control
      -orig-id: CONTROL_FLAG_USERCONTROL
    0x200:
      id: property_page
      -orig-id: CONTROL_FLAG_PROPERTYPAGE
    0x400:
      id: document
      -orig-id: CONTROL_FLAG_DOCUMENT
    0x800:
      id: flag_unsupported13
      -orig-id: CONTROL_FLAG_UNSUPPORTED13
  
  control3:
    # these are the first four bytes of the control GUID.
    # via: https://github.com/vic4key/VB-Exe-Parser/blob/master/VB-Parser.py
    0x33AD4EF2:
      id: button
      -orig-id: CONTROL_BUTTON
    0x33AD4EE2:
      id: text_box
      -orig-id: CONTROL_TEXTBOX
    0x33AD4F2A:
      id: timer
      -orig-id: CONTROL_TIMER
    0x33AD4F3A:
      id: form
      -orig-id: CONTROL_FORM
    0x33AD4F62:
      id: file
      -orig-id: CONTROL_FILE
    0x33AD4F02:
      id: option
      -orig-id: CONTROL_OPTION
    0x33AD4F03:
      id: combo_box
      -orig-id: CONTROL_COMBOBOX
    0x33AD4F0A:
      id: combo_box2
      -orig-id: CONTROL_COMBOBOX2
    0x33AD4F6A:
      id: menu
      -orig-id: CONTROL_MENU
    0x33AD4EDA:
      id: label
      -orig-id: CONTROL_LABEL
    0x33AD4F12:
      id: list_box
      -orig-id: CONTROL_LISTBOX

    # via: https://www.hex-rays.com/products/ida/support/freefiles/vb.idc
    0x33AD4F52:
      id: drive
      -orig-id: CONTROL_DRIVE
    0x33AD4F22:
      id: vscroll
      -orig-id: CONTROL_VSCROLL
    0x33AD4F1A:
      id: hscroll
      -orig-id: CONTROL_HSCROLL
    0x33AD4F5A:
      id: dir
      -orig-id: CONTROL_DIR
    0x33AD4FFA:
      id: data
      -orig-id: CONTROL_DATA
    0x33AD4F92:
      id: image
      -orig-id: CONTROL_IMAGE
    0x33AD4EEA:
      id: frame
      -orig-id: CONTROL_FRAME
    0x33AD5002:
      id: ole
      -orig-id: CONTROL_OLE
    0x33AD4EFA:
      id: checkbox
      -orig-id: CONTROL_CHECKBOX
    0x33AD4ED2:
      id: picture
      -orig-id: CONTROL_PICTURE
    0xFCFB3D21:
      id: clss
      -orig-id: CONTROL_CLASS
