meta:
  id: psd
  title: Photoshop PSD
  file-extension: psd
  license: CC0-1.0
  ks-version: 0.9
  endian: be
doc-ref: https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/
seq:
  - id: header
    type: header
  - id: color_mode_data
    type: color_mode_data
  - id: image_resources
    type: image_resources_data
  - id: layer_and_mask_information
    type: layer_and_mask_information
  - id: image_data
    type: image_data
types:
  header:
    seq:
      - id: magic
        contents: "8BPS"
      - id: version
        type: u2
        valid: 1
      - id: reserved
        contents: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
      - id: num_channels
        type: u2
        valid:
          min: 1
          max: 56
      - id: height
        type: u4
        valid:
          min: 1
          max: 30000
      - id: width
        type: u4
        valid:
          min: 1
          max: 30000
      - id: depth
        type: u2
        valid:
          any-of: [1, 8, 16, 32]
      - id: color_mode
        type: u2
        enum: color_mode
        valid:
          any-of:
            - color_mode::bitmap
            - color_mode::grayscale
            - color_mode::indexed
            - color_mode::rgb
            - color_mode::cmyk
            - color_mode::multichannel
            - color_mode::duotone
            - color_mode::lab
  color_mode_data:
    seq:
      - id: len_color_mode
        type: u4
      - id: color_mode
        size: len_color_mode
  image_resources_data:
    seq:
      - id: len_resources
        type: u4
      - id: resources
        size: len_resources
        type: image_resources
  image_resources:
    seq:
      - id: image_resources
        type: image_resource
        repeat: eos
  image_resource:
    -webide-representation: '{resource_id}'
    seq:
      - id: magic
        contents: "8BIM"
      - id: resource_id
        type: u2
        enum: resource_ids
      - id: name
        type: pascal_string
      - id: padding1
        size: 1
        if: name.len_string % 2 == 0
      - id: len_resource
        type: u4
      - id: data
        size: len_resource
        type:
          switch-on: resource_id
          cases:
            resource_ids::xmp_metadata: xmp
      - id: padding2
        size: 1
        if: len_resource % 2 == 1
  layer_and_mask_information:
    seq:
      - id: len_layer_and_mask_information
        type: u4
      - id: layer_and_mask_information
        size: len_layer_and_mask_information
  image_data:
    seq:
      - id: compression
        type: u2
        enum: compression
        # only support raw and rle data for now
        valid:
          any-of:
            - compression::raw
            - compression::rle
      - id: data
        type:
          switch-on: compression
          cases:
            compression::raw: raw_data
            compression::rle: rle_data
  xmp:
    seq:
      - id: data
        type: str
        size-eos: true
        encoding: utf-8
  raw_data:
    seq:
      - id: data
        size: _root.header.height * _root.header.width * _root.header.num_channels
  rle_data:
    seq:
      - id: byte_counts
        type: u2
        repeat: expr
        repeat-expr: _root.header.height * _root.header.num_channels
      - id: rle
        size: byte_counts[_index]
        repeat: expr
        repeat-expr: _root.header.height * _root.header.num_channels
  pascal_string:
    seq:
      - id: len_string
        type: u1
      - id: string
        size: len_string
        #type: str
enums:
  color_mode:
    0: bitmap
    1: grayscale
    2: indexed
    3: rgb
    4: cmyk
    7: multichannel
    8: duotone
    9: lab
  compression:
    0: raw
    1: rle
    2: zip_without_prediction
    3: zip_with_prediction
  resource_ids:
    1000:
      id: photoshop_20_information
      doc: |
        (Obsolete--Photoshop 2.0 only ) Contains five 2-byte values: number
        of channels, rows, columns, depth, and mode
    1001:
      id: macintosh_print_manager_print_info
      doc: Macintosh print manager print info record
    1002:
      id: macintosh_page_format_information
      doc: |
        Macintosh page format information. No longer read by
        Photoshop. (Obsolete)
    1003:
      id: indexed_color_table
      doc: (Obsolete--Photoshop 2.0 only ) Indexed color table
    1005:
      id: resolution_info
      doc: ResolutionInfo structure. See Appendix A in Photoshop API Guide.pdf.
    1006:
      id: alpha_channel_names
      doc: |
        Names of the alpha channels as a series of Pascal strings.
    1007:
      id: display_info_structure
      doc: |
        (Obsolete) See ID 1077DisplayInfo structure. See Appendix A in
        Photoshop API Guide.pdf.
    1008:
      id: caption
      doc: The caption as a Pascal string.
    1009:
      id: border_information
      doc: |
        Border information. Contains a fixed number (2 bytes real, 2 bytes
        fraction) for the border width, and 2 bytes for border units
        (1 = inches, 2 = cm, 3 = points, 4 = picas, 5 = columns).
    1010:
      id: background_color
      doc: Background color. See See Color structure.
    1011:
      id: print_flags
      doc: |
        Print flags. A series of one-byte boolean values (see Page Setup
        dialog): labels, crop marks, color bars, registration marks, negative,
        flip, interpolate, caption, print flags.
    1012:
      id: grayscale_multichannel_halftoning
      doc: Grayscale and multichannel halftoning information
    1013:
      id: color_halftoning
      doc: Color halftoning information
    1014:
      id: duotone_halftoning
      doc: Duotone halftoning information
    1015:
      id: grayscale_multichannel_transfer_function
      doc: Grayscale and multichannel transfer function
    1016:
      id: color_transfer_function
      doc: Color transfer functions
    1017:
      id: duotone_transfer_function
      doc: Duotone transfer functions
    1018:
      id: duotone_image_information
      doc: Duotone image information
    1019:
      id: effective_black_white
      doc: Two bytes for the effective black and white values for the dot range
    1020:
      id: obsolete_1020
    1021:
      id: eps_options
      doc: EPS options
    1022:
      id: quick_mask_information
      doc: |
        Quick Mask information. 2 bytes containing Quick Mask channel ID;
        1- byte boolean indicating whether the mask was initially empty.
    1023:
      id: obsolete_1023
    1024:
      id: layer_state_information
      doc: |
        Layer state information. 2 bytes containing the index of target
        layer (0 = bottom layer).
    1025:
      id: working_path
      doc: Working path (not saved). See See Path resource format.
    1026:
      id: layers_group_information
      doc: |
        Layers group information. 2 bytes per layer containing a group ID for
        the dragging groups. Layers in a group have the same group ID.
    1027:
      id: obsolete_1027
      doc: Obsolete
    1028:
      id: iptc_naa_record
      doc: |
        IPTC-NAA record. Contains the File Info... information. See the
        documentation in the IPTC folder of the Documentation folder.
    1029:
      id: image_mode_raw
      doc: Image mode for raw format files
    1030:
      id: jpeg_quality
      doc: JPEG quality. Private.
    1032:
      id: grid_and_guides
      doc: |
        (Photoshop 4.0) Grid and guides information. See See Grid and
        guides resource format.
    1033:
      id: thumbnail_resource_photoshop_40
      doc: |
        (Photoshop 4.0) Thumbnail resource for Photoshop 4.0 only.
        See Thumbnail resource format.
    1034:
      id: copyright_flag
      doc: |
        (Photoshop 4.0) Copyright flag. Boolean indicating whether image is
        copyrighted. Can be set via Property suite or by user in File Info...
    1035:
      id: url
      doc: |
        (Photoshop 4.0) URL. Handle of a text string with uniform resource
        locator. Can be set via Property suite or by user in File Info...
    1036:
      id: thumbnail_resource
      doc: |
        (Photoshop 5.0) Thumbnail resource (supersedes resource 1033).
        See Thumbnail resource format.
    1037:
     id: global_angle
     doc: |
       (Photoshop 5.0) Global Angle. 4 bytes that contain an integer between
       0 and 359, which is the global lighting angle for effects layer. If not
       present, assumed to be 30.
    1038:
      id: color_samplers_resource_photoshop_50
      doc: |
        (Obsolete) See ID 1073 below. (Photoshop 5.0) Color samplers resource.
        See Color samplers resource format.
    1039:
      id: icc_profile
      doc: |
        (Photoshop 5.0) ICC Profile. The raw bytes of an ICC (International
        Color Consortium) format profile. See ICC1v42_2006-05.pdf in the
        Documentation folder and icProfileHeader.h in Sample Code\Common\Includes
    1040:
      id: watermark
      doc: (Photoshop 5.0) Watermark. One byte.
    1041:
      id: icc_untagged_profile
      doc: |
        (Photoshop 5.0) ICC Untagged Profile. 1 byte that disables any assumed
        profile handling when opening the file. 1 = intentionally untagged.
    1042:
      id: effects_visible
      doc: |
        (Photoshop 5.0) Effects visible. 1-byte global flag to show/hide all
        the effects layer. Only present when they are hidden.
    1043:
      id: spot_halftone
      doc: |
        (Photoshop 5.0) Spot Halftone. 4 bytes for version, 4 bytes for
        length, and the variable length data.
    1044:
      id: document_specific_ids_seed_number
      doc: |
        (Photoshop 5.0) Document-specific IDs seed number. 4 bytes: Base value,
        starting at which layer IDs will be generated (or a greater value if
        existing IDs already exceed it). Its purpose is to avoid the case where
        we add layers, flatten, save, open, and then add more layers that end
        up with the same IDs as the first set.
    1045:
      id: unicode_alpha_names
      doc: (Photoshop 5.0) Unicode Alpha Names. Unicode string
    1046:
      id: indexed_color_table_count
      doc: |
        (Photoshop 6.0) Indexed Color Table Count. 2 bytes for the number of
        colors in table that are actually defined
    1047:
      id: transparancy_index
      doc: |
        (Photoshop 6.0) Transparency Index. 2 bytes for the index
        of transparent color, if any.
    1049:
      id: global_altitude
      doc: (Photoshop 6.0) Global Altitude. 4 byte entry for altitude
    1050:
      id: slices
      doc: (Photoshop 6.0) Slices. See Slices resource format.
    1051:
      id: workflow_url
      doc: (Photoshop 6.0) Workflow URL. Unicode string
    1052:
      id: jump_to_xpep
      doc: |
        (Photoshop 6.0) Jump To XPEP. 2 bytes major version, 2 bytes minor
        version, 4 bytes count. Following is repeated for count: 4 bytes block
        size, 4 bytes key, if key = 'jtDd' , then next is a Boolean for the
        dirty flag; otherwise it's a 4 byte entry for the mod date.
    1053:
      id: alpha_identifiers
      doc: |
        (Photoshop 6.0) Alpha Identifiers. 4 bytes of length, followed by
        4 bytes each for every alpha identifier.
    1054:
      id: url_list
      doc: |
        (Photoshop 6.0) URL List. 4 byte count of URLs, followed by 4 byte
        long, 4 byte ID, and Unicode string for each count.
    1057:
      id: version_info
      doc: |
        (Photoshop 6.0) Version Info. 4 bytes version, 1 byte hasRealMergedData ,
        Unicode string: writer name, Unicode string: reader name, 4 bytes file version.
    1058:
      id: exif_data_1
      doc: |
        (Photoshop 7.0) EXIF data 1. See
        http://www.kodak.com/global/plugins/acrobat/en/service/digCam/exifStandard2.pdf
    1059:
      id: exif_data_3
      doc: |
        (Photoshop 7.0) EXIF data 3.
        See http://www.kodak.com/global/plugins/acrobat/en/service/digCam/exifStandard2.pdf
    1060:
      id: xmp_metadata
      doc: |
        (Photoshop 7.0) XMP metadata. File info as XML description.
        See http://www.adobe.com/devnet/xmp/
    1061:
      id: caption_digest
      doc: |
        (Photoshop 7.0) Caption digest. 16 bytes: RSA Data Security,
        MD5 message-digest algorithm
    1062:
      id: print_scale
      doc: |
        (Photoshop 7.0) Print scale. 2 bytes style (0 = centered,
        1 = size to fit, 2 = user defined). 4 bytes x location (floating point).
        4 bytes y location (floating point). 4 bytes scale (floating point)
    1064:
      id: pixel_aspect_ratio
      doc: |
        (Photoshop CS) Pixel Aspect Ratio. 4 bytes (version = 1 or 2),
        8 bytes double, x / y of a pixel. Version 2, attempting to correct
        values for NTSC and PAL, previously off by a factor of approx. 5%.
    1065:
      id: layer_comps
      doc: |
        (Photoshop CS) Layer Comps. 4 bytes (descriptor version = 16),
        Descriptor (see See Descriptor structure)
    1066:
      id: alternate_duotone_colors
      doc: |
        (Photoshop CS) Alternate Duotone Colors. 2 bytes (version = 1),
        2 bytes count, following is repeated for each count: [ Color: 2 bytes
        for space followed by 4 * 2 byte color component ], following this is
        another 2 byte count, usually 256, followed by Lab colors one byte each
        for L, a, b. This resource is not read or used by Photoshop.
    1067:
      id: alternate_spot_colors
      doc: |
        (Photoshop CS)Alternate Spot Colors. 2 bytes (version = 1), 2 bytes
        channel count, following is repeated for each count: 4 bytes channel ID,
        Color: 2 bytes for space followed by 4 * 2 byte color component. This
        resource is not read or used by Photoshop.
    1069:
      id: layer_selection_ids
      doc: |
        (Photoshop CS2) Layer Selection ID(s). 2 bytes count, following is
        repeated for each count: 4 bytes layer ID
    1070:
      id: hdr_toning_information
      doc: (Photoshop CS2) HDR Toning information
    1071:
      id: print_info
      doc: (Photoshop CS2) Print info
    1072:
      id: layer_groups_enabled_id
      doc: |
        (Photoshop CS2) Layer Group(s) Enabled ID. 1 byte for each layer in
        the document, repeated by length of the resource. NOTE: Layer groups
        have start and end markers
    1073:
      id: color_samplers_resource
      doc: |
        (Photoshop CS3) Color samplers resource. Also see ID 1038 for old format.
        See Color samplers resource format.
    1074:
      id: measurement_scale
      doc: |
        (Photoshop CS3) Measurement Scale. 4 bytes (descriptor version = 16),
        Descriptor (see See Descriptor structure)
    1075:
      id: timeline_information
      doc: |
        (Photoshop CS3) Timeline Information. 4 bytes (descriptor version = 16),
        Descriptor (see See Descriptor structure)
    1076:
      id: sheet_disclosure
      doc: |
        (Photoshop CS3) Sheet Disclosure. 4 bytes (descriptor version = 16),
        Descriptor (see See Descriptor structure)
    1077:
      id: displayinfo_structure
      doc: |
        (Photoshop CS3) DisplayInfo structure to support floating point clors.
        Also see ID 1007. See Appendix A in Photoshop API Guide.pdf .
    1078:
      id: onion_skins
      doc: |
        (Photoshop CS3) Onion Skins. 4 bytes (descriptor version = 16), Descriptor
        (see See Descriptor structure)
    1080:
      id: count_information
      doc: |
        (Photoshop CS4) Count Information. 4 bytes (descriptor version = 16),
        Descriptor (see See Descriptor structure) Information about the count
        in the document. See the Count Tool.
    1082:
      id: print_information
      doc: |
        (Photoshop CS5) Print Information. 4 bytes (descriptor version = 16),
        Descriptor (see See Descriptor structure) Information about the current
        print settings in the document. The color management options.
    1083:
      id: print_style
      doc: |
        (Photoshop CS5) Print Style. 4 bytes (descriptor version = 16),
        Descriptor (see See Descriptor structure) Information about the current
        print style in the document. The printing marks, labels, ornaments, etc.
    1084:
      id: macintosh_nsprintinfo
      doc: |
        (Photoshop CS5) Macintosh NSPrintInfo. Variable OS specific info for
        Macintosh. NSPrintInfo. It is recommended that you do not interpret or
        use this data.
    1085:
      id: windows_devmode
      doc: |
        (Photoshop CS5) Windows DEVMODE. Variable OS specific info for Windows.
        DEVMODE. It is recommended that you do not interpret or use this data.
    1086:
      id: auto_save_file_path
      doc: |
        (Photoshop CS6) Auto Save File Path. Unicode string. It is recommended
        that you do not interpret or use this data.
    1087:
      id: auto_save_format
      doc: |
        (Photoshop CS6) Auto Save Format. Unicode string. It is recommended
        that you do not interpret or use this data.
    1088:
      id: path_selection_state
      doc: |
        (Photoshop CC) Path Selection State. 4 bytes (descriptor version = 16),
        Descriptor (see See Descriptor structure) Information about the current
        path selection state.
    #2000-2997 Path Information (saved paths). See See Path resource format.
    2999:
      id: name_clipping_path
      doc: Name of clipping path. See Path resource format.
    3000:
      id: origin_path_info
      doc: |
        (Photoshop CC) Origin Path Info. 4 bytes (descriptor version = 16),
        Descriptor (see See Descriptor structure) Information about the origin path data.
    #4000-4999 Plug-In resource(s). Resources added by a plug-in. See the plug-in API found in the SDK documentation
    7000:
      id: image_ready_variables
      doc: Image Ready variables. XML representation of variables definition
    7001:
      id: image_ready_data_sets
      doc: Image Ready data sets
    7002:
      id: image_ready_default_selected_state
      doc: Image Ready default selected state
    7003:
      id: image_ready_7_rollover_expanded_state
      doc: Image Ready 7 rollover expanded state
    7004:
      id: image_ready_rollover_expanded_state
      doc: Image Ready rollover expanded state
    7005:
      id: image_ready_save_layer_settings
      doc: Image Ready save layer settings
    7006:
      id: image_ready_version
      doc: Image Ready version
    8000:
      id: lightroom_workflow
      doc: |
        (Photoshop CS3) Lightroom workflow, if present the document is
        in the middle of a Lightroom workflow.
    10000:
      id: print_flags_information
      doc: |
        Print flags information. 2 bytes version ( = 1), 1 byte center crop marks,
        1 byte ( = 0), 4 bytes bleed width value, 2 bytes bleed width scale.
