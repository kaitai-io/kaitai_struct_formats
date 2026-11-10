meta:
  id: exif
  title: Exchangeable image file format (Exif)
  xref:
    forensicswiki: exif
    justsolve: Exif
    loc:
      - fdd000618 # Exif family
      - fdd000146 # Exif 2.2
    pronom:
      - x-fmt/398 # Exif 2.0
      - x-fmt/390 # Exif 2.1
      - x-fmt/391 # Exif 2.2
      - fmt/645 # Exif 2.21
    wikidata:
      - Q26383099 # Exif image file
      - Q196465 # Exchangeable image file format
  license: CC0-1.0
  ks-version: '0.9'
doc: |
  Sample files (numbers in parentheses show how many files per extension contain
  Exif metadata out of the total):

  * <https://github.com/ianare/exif-py/tree/a69bf74770caf6b333221658f5092ed69f99faac/tests/resources/jpg> (84/93 .jpg, 1/1 .jpeg)
  * <https://github.com/exiftool/exiftool/tree/2200871d9cef988051d2a99d67df3bda6cbb30a8/t/images> (34/41 .jpg, 0/1 .png)
  * <https://github.com/Exiv2/exiv2/tree/648ada43dcb35ce6077f38183ace52d5e2071f64/test/data> (85/155 .jpg, 5/23 .png)
  * <https://github.com/python-pillow/Pillow/tree/807d689a83738027b6f6e0f219a6a6dd30e01c08/Tests/images> (36/55 .jpg, 3/420 .png)
  * <https://github.com/drewnoakes/metadata-extractor-images/tree/651ad0e67aa8d43d358ad05f9bc07b52d8b9ac6e/jpg> (335/430 .jpg)
  * <https://github.com/libexif/libexif-testsuite/tree/8c1f5bbc18d2cbc80b01b3f9b3eb29546310acf2> (15/18 .jpg)
doc-ref:
  - https://www.cipa.jp/std/documents/download_e.html?CIPA_DC-008-2026-E Exif Version 3.1
  - https://www.cipa.jp/std/documents/download_e.html?CIPA_DC-008-2024-E Exif Version 3.0
  - https://web.archive.org/web/20190624045241id_/https://www.cipa.jp/std/documents/e/DC-008-Translation-2019-E.pdf Exif Version 2.32
  - https://web.archive.org/web/20190712232333id_/https://www.cipa.jp/std/documents/e/DC-008-Translation-2016-E.pdf Exif Version 2.31
  - https://www.cipa.jp/std/documents/e/DC-008-2012_E_C.pdf Exif Version 2.3 (with Corrigendum at the end)
  - https://web.archive.org/web/20051228234707id_/https://tsc.jeita.or.jp/avs/data/cp3451_1.pdf Exif Version 2.21 (2003 draft)
  - https://web.archive.org/web/20131018091152id_/https://exif.org/Exif2-2.PDF Exif Version 2.2
  - https://web.archive.org/web/20131111073619id_/https://exif.org/Exif2-1.PDF Exif Version 2.1
seq:
  - id: endianness
    type: u2le
  - id: body
    type: exif_body
types:
  exif_body:
    meta:
      endian:
        switch-on: _root.endianness
        cases:
          0x4949: le
          0x4d4d: be
    seq:
      - id: magic
        type: u2
        valid: 42
      - id: ofs_ifd0
        type: u4
    instances:
      ifd0:
        pos: ofs_ifd0
        type: ifd(false)
    types:
      ifd:
        params:
          - id: is_gps_ifd
            type: bool
        seq:
          - id: num_fields
            type: u2
          - id: fields
            size: 12
            type: ifd_field
            repeat: expr
            repeat-expr: num_fields
          - id: ofs_next_ifd
            type: u4
        instances:
          next_ifd:
            pos: ofs_next_ifd
            type: ifd(is_gps_ifd)
            if: ofs_next_ifd != 0
      ifd_field:
        -webide-representation: '{tag} {gps_tag}'
        seq:
          - id: tag_raw
            type: u2
            doc: |
              Raw numeric tag. Don't read this field - access `tag` or `gps_tag`
              instead.
          - id: field_type
            type: u2
            enum: field_type
          - id: num_values
            type: u4
          - id: ofs_data
            type: u4
            if: not has_immediate_data
        instances:
          tag:
            value: tag_raw
            enum: tag
            if: not _parent.is_gps_ifd
          gps_tag:
            value: tag_raw
            enum: gps_tag
            if: _parent.is_gps_ifd
          bytes_per_value:
            value: |
              field_type == field_type::byte or
              field_type == field_type::ascii or
              field_type == field_type::sbyte or
              field_type == field_type::undefined or
              field_type == field_type::utf8
                ? 1 :
              field_type == field_type::short or
              field_type == field_type::sshort
                ? 2 :
              field_type == field_type::long or
              field_type == field_type::slong or
              field_type == field_type::float or
              field_type == field_type::ifd
                ? 4 :
              field_type == field_type::rational or
              field_type == field_type::srational or
              field_type == field_type::double
                ? 8
                : 0
            doc: |
              Size in bytes of a single value of type `field_type`, or 0 if
              `field_type` is not one of the known types (in which case the size
              cannot be determined and `data` will be empty).
            doc-ref: https://www.media.mit.edu/pia/Research/deepview/exif.html#DataForm
          len_data:
            value: bytes_per_value * num_values
          has_immediate_data:
            value: 'len_data <= 4'
          data:
            io: 'has_immediate_data ? _io : _root._io'
            pos: 'has_immediate_data ? 8 : ofs_data'
            size: len_data
            type:
              switch-on: field_type
              cases:
                field_type::ascii: ascii_string
                field_type::utf8: utf8_string
                field_type::sbyte: sbytes
                field_type::short: shorts
                field_type::sshort: sshorts
                field_type::long: longs
                field_type::slong: slongs
                field_type::rational: rationals
                field_type::srational: srationals
                field_type::float: floats
                field_type::double: doubles
                field_type::ifd: longs
            -webide-parse-mode: eager
          sub_ifd:
            io: _root._io
            pos: |
              field_type == field_type::slong
                ? data.as<slongs>.values.first.as<u4>
                : data.as<longs>.values.first
            type: ifd(tag == tag::gps_info)
            if: |
              num_values == 1 and
              (
                field_type == field_type::long or
                field_type == field_type::ifd or
                (field_type == field_type::slong and data.as<slongs>.values.first >= 0)
              ) and
              (
                tag == tag::exif_offset or
                tag == tag::interop_offset or
                tag == tag::gps_info
              )
            doc: |
              All the "IFD Pointer" tags (as the core Exif standard calls them),
              i.e. `ExifOffset`, `InteropOffset` and `GPSInfo` (using the
              [ExifTool's
              names](https://exiftool.sourceforge.net/TagNames/EXIF.html)),
              should be of type `LONG` (`field_type::long`). However, the type
              `SLONG` (`field_type::slong`) type has also been observed:
              <https://github.com/Exiv2/exiv2/blob/2cd987a731236037b6b78cbff897d08685a8ef49/test/data/FurnaceCreekInn.jpg>

              Both ExifTool and Exiv2 accept `LONG`, `SLONG` and also `IFD`.
              Exiv2 specifically supports only these three types - see
              <https://github.com/Exiv2/exiv2/blob/2cd987a731236037b6b78cbff897d08685a8ef49/src/tiffvisitor_int.cpp#L1141>
              (Git tag "v0.28.8"). ExifTool is more lenient - it even accepts
              any integer type. In practice, real files most likely only use one
              of the three types supported by Exiv2, so we stick with that.
      ascii_string:
        -webide-representation: '{value}'
        seq:
          - id: value
            terminator: 0
            eos-error: false
            doc: |
              According to the core Exif standard, this should be ASCII, but in
              practice, this is not always the case. From
              [ExifTool FAQ](https://exiftool.sourceforge.net/faq.html#Q10):

              > However, it is not uncommon for applications to write UTF-8 or
              other encodings where ASCII is expected.

              Therefore, this field is a byte array, not a string. This is to
              avoid non-ASCII characters being treated as errors in some target
              languages, such as Python. The only assumption is that a null byte
              terminates the value (although sometimes the null byte is missing,
              which we tolerate thanks to the `eos-error: false` setting).

              Here is a sample JPEG file with a `tag::image_description` IFD
              field of type `field_type::ascii` that actually contains UTF-8:
              <https://github.com/Exiv2/exiv2/blob/2cd987a731236037b6b78cbff897d08685a8ef49/test/data/exiv2-bug501.jpg>

              It seems that most modern applications (e.g. GIMP 3.0.6) always
              use UTF-8 when storing Exif metadata. However, there are also
              files with a non-UTF-8 encoding, for example
              <https://github.com/drewnoakes/metadata-extractor-images/blob/651ad0e67aa8d43d358ad05f9bc07b52d8b9ac6e/jpg/Ricoh%20DC-3Z%20(low%20res).jpg>
              has a `tag::copyright` IFD field with a value encoded in
              ISO-8859-1 (Latin-1).
      utf8_string:
        -webide-representation: '{value}'
        seq:
          - id: value
            type: strz
            encoding: UTF-8
            eos-error: false
      sbytes:
        seq:
          - id: values
            type: s1
            repeat: expr
            repeat-expr: _parent.num_values
      shorts:
        seq:
          - id: values
            type: u2
            repeat: expr
            repeat-expr: _parent.num_values
      sshorts:
        seq:
          - id: values
            type: s2
            repeat: expr
            repeat-expr: _parent.num_values
      longs:
        seq:
          - id: values
            type: u4
            repeat: expr
            repeat-expr: _parent.num_values
      slongs:
        seq:
          - id: values
            type: s4
            repeat: expr
            repeat-expr: _parent.num_values
      rationals:
        seq:
          - id: values
            type: rational
            repeat: expr
            repeat-expr: _parent.num_values
      rational:
        -webide-representation: '{value:dec} (= {value_num:dec}/{value_den:dec})'
        seq:
          - id: value_num
            type: u4
            doc: Numerator
          - id: value_den
            type: u4
            doc: Denominator
        instances:
          value:
            value: (value_num + 0.0) / value_den
            if: value_den != 0
            doc: |
              If denominator is zero, this instance is disabled to prevent
              `ZeroDivisionError` in Python.

              Here's a sample file with a zero denominator in the IFD fields
              `tag::x_resolution` and `tag::y_resolution` (both of which are of
              type `field_type::rational`):
              <https://github.com/python-pillow/Pillow/blob/807d689a83738027b6f6e0f219a6a6dd30e01c08/Tests/images/exif-dpi-zerodivision.jpg>
      srationals:
        seq:
          - id: values
            type: srational
            repeat: expr
            repeat-expr: _parent.num_values
      srational:
        -webide-representation: '{value:dec} (= {value_num:dec}/{value_den:dec})'
        seq:
          - id: value_num
            type: s4
            doc: Numerator
          - id: value_den
            type: s4
            doc: Denominator
        instances:
          value:
            value: (value_num + 0.0) / value_den
            if: value_den != 0
            doc: |
              If denominator is zero, this instance is disabled to prevent
              `ZeroDivisionError` in Python.

              Here's a sample file with a zero denominator in the IFD field
              `tag::exposure_compensation` of type `field_type::srational`:
              <https://github.com/drewnoakes/metadata-extractor-images/blob/651ad0e67aa8d43d358ad05f9bc07b52d8b9ac6e/jpg/Reconyx%20Hyperfire%20HP4K.jpg>
      floats:
        seq:
          - id: values
            type: f4
            repeat: expr
            repeat-expr: _parent.num_values
      doubles:
        seq:
          - id: values
            type: f8
            repeat: expr
            repeat-expr: _parent.num_values
enums:
  # https://github.com/exiftool/exiftool/blob/2200871d9cef988051d2a99d67df3bda6cbb30a8/lib/Image/ExifTool/Exif.pm#L94-L122 (Git tag "13.59")
  # https://www.media.mit.edu/pia/Research/deepview/exif.html#DataForm
  field_type:
    1: byte
    2: ascii
    3: short
    4: long
    5: rational
    6:
      id: sbyte
      -orig-id: SBYTE
      doc: |
        8-bit signed integer.

        This type is missing from the official Exif specification, but
        it's part of TIFF 6.0. There's no known Exif tag of this type in
        the [standard
        namespace](https://exiftool.sourceforge.net/TagNames/EXIF.html)
        (there's no occurrence of `int8s` on the page), but it's used by
        many vendor-specific tags in `MakerNote` sub-IFDs, for example
        [Nikon](https://exiftool.sourceforge.net/TagNames/Nikon.html)
        (search for `int8s`).

        Unfortunately, this implementation doesn't parse the contents of
        `MakerNote` tags (`tag::maker_note`) yet.
    7: undefined
    8:
      id: sshort
      -orig-id: SSHORT
      doc: |
        16-bit signed integer.

        This type is missing from the official Exif specification, but
        it's part of TIFF 6.0 and some tags use it, for example
        `TimeZoneOffset` (`tag::time_zone_offset`).
    9: slong
    10: srational
    11:
      id: float
      -orig-id: FLOAT
      doc: |
        Single precision (4-byte) IEEE 754 float.

        This type is missing from the official Exif specification, but
        it's part of TIFF 6.0 and some tags use it, for example
        `ProfileToneCurve` (`tag::profile_tone_curve`).
    12:
      id: double
      -orig-id: DOUBLE
      doc: |
        Double precision (8-byte) IEEE 754 float.

        This type is missing from the official Exif specification, but
        it's part of TIFF 6.0 and some tags use it, for example
        `NoiseProfile` (`tag::noise_profile`).
    13:
      id: ifd
      -orig-id: IFD
      doc: |
        Offset of an IFD (32-bit unsigned integer).

        This type is missing from the official Exif specification, but
        it was defined in the [TIFF Technical Note
        1](https://www.alternatiff.com/resources/TIFFPM6.pdf) (page 4).
        There's no known Exif tag of this type in the [standard
        namespace](https://exiftool.sourceforge.net/TagNames/EXIF.html)
        (there's no occurrence of `ifd` on the page), but there are some
        Olympus-specific tags in `MakerNote` sub-IFDs, e.g.
        `EquipmentIFD` or `CameraSettingsIFD`. See
        <https://github.com/exiftool/exiftool/blob/2200871d9cef988051d2a99d67df3bda6cbb30a8/lib/Image/ExifTool/Olympus.pm>
        (Git tag "13.59") - search for `'ifd'`. See also the sample file
        <https://github.com/exiftool/exiftool/blob/2200871d9cef988051d2a99d67df3bda6cbb30a8/t/images/Olympus2.jpg>,
        which contains these tags.
    129: utf8
  # https://exiftool.sourceforge.net/TagNames/GPS.html
  gps_tag:
    0x0000: gps_version_id
    0x0001: gps_latitude_ref
    0x0002: gps_latitude
    0x0003: gps_longitude_ref
    0x0004: gps_longitude
    0x0005: gps_altitude_ref
    0x0006: gps_altitude
    0x0007: gps_time_stamp
    0x0008: gps_satellites
    0x0009: gps_status
    0x000a: gps_measure_mode
    0x000b: gps_dop
    0x000c: gps_speed_ref
    0x000d: gps_speed
    0x000e: gps_track_ref
    0x000f: gps_track
    0x0010: gps_img_direction_ref
    0x0011: gps_img_direction
    0x0012: gps_map_datum
    0x0013: gps_dest_latitude_ref
    0x0014: gps_dest_latitude
    0x0015: gps_dest_longitude_ref
    0x0016: gps_dest_longitude
    0x0017: gps_dest_bearing_ref
    0x0018: gps_dest_bearing
    0x0019: gps_dest_distance_ref
    0x001a: gps_dest_distance
    0x001b: gps_processing_method
    0x001c: gps_area_information
    0x001d: gps_date_stamp
    0x001e: gps_differential
    0x001f: gps_h_positioning_error
  tag:
    0x0001: interop_index
    0x0002:
      id: interop_version
      doc: Interoperability Version (not in the Exif spec, but used in practice)
      doc-ref: https://github.com/exiftool/exiftool/blob/2200871d9cef988051d2a99d67df3bda6cbb30a8/lib/Image/ExifTool/Exif.pm#L429-L437 Git tag "13.59"
    0x0100: image_width
    0x0101: image_height
    0x0102: bits_per_sample
    0x0103: compression
    0x0106: photometric_interpretation
    0x0107: thresholding
    0x0108: cell_width
    0x0109: cell_length
    0x010a: fill_order
    0x010d: document_name
    0x010e: image_description
    0x010f: make
    0x0110: model
    0x0111: strip_offsets
    0x0112: orientation
    0x0115: samples_per_pixel
    0x0116: rows_per_strip
    0x0117: strip_byte_counts
    0x0118: min_sample_value
    0x0119: max_sample_value
    0x011a: x_resolution
    0x011b: y_resolution
    0x011c: planar_configuration
    0x011d: page_name
    0x011e: x_position
    0x011f: y_position
    0x0120: free_offsets
    0x0121: free_byte_counts
    0x0122: gray_response_unit
    0x0123: gray_response_curve
    0x0124: t4_options
    0x0125: t6_options
    0x0128: resolution_unit
    0x0129: page_number
    0x012c: color_response_unit
    0x012d: transfer_function
    0x0131: software
    0x0132: modify_date
    0x013b: artist
    0x013c: host_computer
    0x013d: predictor
    0x013e: white_point
    0x013f: primary_chromaticities
    0x0140: color_map
    0x0141: halftone_hints
    0x0142: tile_width
    0x0143: tile_length
    0x0144: tile_offsets
    0x0145: tile_byte_counts
    0x0146: bad_fax_lines
    0x0147: clean_fax_data
    0x0148: consecutive_bad_fax_lines
    0x014a: sub_ifd
    0x014c: ink_set
    0x014d: ink_names
    0x014e: numberof_inks
    0x0150: dot_range
    0x0151: target_printer
    0x0152: extra_samples
    0x0153: sample_format
    0x0154: s_min_sample_value
    0x0155: s_max_sample_value
    0x0156: transfer_range
    0x0157: clip_path
    0x0158: x_clip_path_units
    0x0159: y_clip_path_units
    0x015a: indexed
    0x015b: jpeg_tables
    0x015f: opi_proxy
    0x0190: global_parameters_ifd
    0x0191: profile_type
    0x0192: fax_profile
    0x0193: coding_methods
    0x0194: version_year
    0x0195: mode_number
    0x01b1: decode
    0x01b2: default_image_color
    0x01b3: t82_options
    0x01b5: jpeg_tables2
    0x0200: jpeg_proc
    0x0201: thumbnail_offset
    0x0202: thumbnail_length
    0x0203: jpeg_restart_interval
    0x0205: jpeg_lossless_predictors
    0x0206: jpeg_point_transforms
    0x0207: jpegq_tables
    0x0208: jpegdc_tables
    0x0209: jpegac_tables
    0x0211: y_cb_cr_coefficients
    0x0212: y_cb_cr_sub_sampling
    0x0213: y_cb_cr_positioning
    0x0214: reference_black_white
    0x022f: strip_row_counts
    0x02bc: application_notes
    0x03e7: uspto_miscellaneous
    0x1000: related_image_file_format
    0x1001: related_image_width
    0x1002: related_image_height
    0x4746: rating
    0x4747: xp_dip_xml
    0x4748: stitch_info
    0x4749: rating_percent
    0x7000: sony_raw_file_type
    0x7032: light_falloff_params
    0x7035: chromatic_aberration_corr_params
    0x7037: distortion_corr_params
    0x800d: image_id
    0x80a3: wang_tag1
    0x80a4: wang_annotation
    0x80a5: wang_tag3
    0x80a6: wang_tag4
    0x80b9: image_reference_points
    0x80ba: region_xform_tack_point
    0x80bb: warp_quadrilateral
    0x80bc: affine_transform_mat
    0x80e3: matteing
    0x80e4: data_type
    0x80e5: image_depth
    0x80e6: tile_depth
    0x8214: image_full_width
    0x8215: image_full_height
    0x8216: texture_format
    0x8217: wrap_modes
    0x8218: fov_cot
    0x8219: matrix_world_to_screen
    0x821a: matrix_world_to_camera
    0x827d: model2
    0x828d: cfa_repeat_pattern_dim
    0x828e: cfa_pattern2
    0x828f: battery_level
    0x8290: kodak_ifd
    0x8298: copyright
    0x829a: exposure_time
    0x829d: f_number
    0x82a5: md_file_tag
    0x82a6: md_scale_pixel
    0x82a7: md_color_table
    0x82a8: md_lab_name
    0x82a9: md_sample_info
    0x82aa: md_prep_date
    0x82ab: md_prep_time
    0x82ac: md_file_units
    0x830e: pixel_scale
    0x8335: advent_scale
    0x8336: advent_revision
    0x835c: uic1_tag
    0x835d: uic2_tag
    0x835e: uic3_tag
    0x835f: uic4_tag
    0x83bb: iptc_naa
    0x847e: intergraph_packet_data
    0x847f: intergraph_flag_registers
    0x8480: intergraph_matrix
    0x8481: ingr_reserved
    0x8482: model_tie_point
    0x84e0: site
    0x84e1: color_sequence
    0x84e2: it8_header
    0x84e3: raster_padding
    0x84e4: bits_per_run_length
    0x84e5: bits_per_extended_run_length
    0x84e6: color_table
    0x84e7: image_color_indicator
    0x84e8: background_color_indicator
    0x84e9: image_color_value
    0x84ea: background_color_value
    0x84eb: pixel_intensity_range
    0x84ec: transparency_indicator
    0x84ed: color_characterization
    0x84ee: hc_usage
    0x84ef: trap_indicator
    0x84f0: cmyk_equivalent
    0x8546: sem_info
    0x8568: afcp_iptc
    0x85b8: pixel_magic_jbig_options
    0x85d7: jpl_carto_ifd
    0x85d8: model_transform
    0x8602: wb_grgb_levels
    0x8606: leaf_data
    0x8649: photoshop_settings
    0x8769: exif_offset
    0x8773: icc_profile
    0x877f: tiff_fx_extensions
    0x8780: multi_profiles
    0x8781: shared_data
    0x8782: t88_options
    0x87ac: image_layer
    0x87af: geo_tiff_directory
    0x87b0: geo_tiff_double_params
    0x87b1: geo_tiff_ascii_params
    0x87be: jbig_options
    0x8822: exposure_program
    0x8824: spectral_sensitivity
    0x8825: gps_info
    0x8827: iso
    0x8828: opto_electric_conv_factor
    0x8829: interlace
    0x882a: time_zone_offset
    0x882b: self_timer_mode
    0x8830: sensitivity_type
    0x8831: standard_output_sensitivity
    0x8832: recommended_exposure_index
    0x8833: iso_speed
    0x8834: iso_speed_latitudeyyy
    0x8835: iso_speed_latitudezzz
    0x885c: fax_recv_params
    0x885d: fax_sub_address
    0x885e: fax_recv_time
    0x8871: fedex_edr
    0x888a: leaf_sub_ifd
    0x9000: exif_version
    0x9003: date_time_original
    0x9004: create_date
    0x9009: google_plus_upload_code
    0x9010: offset_time
    0x9011: offset_time_original
    0x9012: offset_time_digitized
    0x9101: components_configuration
    0x9102: compressed_bits_per_pixel
    0x9201: shutter_speed_value
    0x9202: aperture_value
    0x9203: brightness_value
    0x9204: exposure_compensation
    0x9205: max_aperture_value
    0x9206: subject_distance
    0x9207: metering_mode
    0x9208: light_source
    0x9209: flash
    0x920a: focal_length
    0x920b: flash_energy
    0x920c: spatial_frequency_response
    0x920d: noise
    0x920e: focal_plane_x_resolution
    0x920f: focal_plane_y_resolution
    0x9210: focal_plane_resolution_unit
    0x9211: image_number
    0x9212: security_classification
    0x9213: image_history
    0x9214: subject_area
    0x9215: exposure_index
    0x9216: tiff_ep_standard_id
    0x9217: sensing_method
    0x923a: cip3_data_file
    0x923b: cip3_sheet
    0x923c: cip3_side
    0x923f: sto_nits
    0x927c: maker_note
    0x9286: user_comment
    0x9290: sub_sec_time
    0x9291: sub_sec_time_original
    0x9292: sub_sec_time_digitized
    0x932f: ms_document_text
    0x9330: ms_property_set_storage
    0x9331: ms_document_text_position
    0x935c: image_source_data
    0x9400: ambient_temperature
    0x9401: humidity
    0x9402: pressure
    0x9403: water_depth
    0x9404: acceleration
    0x9405: camera_elevation_angle
    0x9c9b: xp_title
    0x9c9c: xp_comment
    0x9c9d: xp_author
    0x9c9e: xp_keywords
    0x9c9f: xp_subject
    0xa000: flashpix_version
    0xa001: color_space
    0xa002: exif_image_width
    0xa003: exif_image_height
    0xa004: related_sound_file
    0xa005: interop_offset
    0xa010: samsung_raw_pointers_offset
    0xa011: samsung_raw_pointers_length
    0xa101: samsung_raw_byte_order
    0xa102: samsung_raw_unknown
    0xa20b: flash_energy2
    0xa20c: spatial_frequency_response2
    0xa20d: noise2
    0xa20e: focal_plane_x_resolution2
    0xa20f: focal_plane_y_resolution2
    0xa210: focal_plane_resolution_unit2
    0xa211: image_number2
    0xa212: security_classification2
    0xa213: image_history2
    0xa214: subject_location
    0xa215: exposure_index2
    0xa216: tiff_ep_standard_id2
    0xa217: sensing_method2
    0xa300: file_source
    0xa301: scene_type
    0xa302: cfa_pattern
    0xa401: custom_rendered
    0xa402: exposure_mode
    0xa403: white_balance
    0xa404: digital_zoom_ratio
    0xa405: focal_length_in35mm_format
    0xa406: scene_capture_type
    0xa407: gain_control
    0xa408: contrast
    0xa409: saturation
    0xa40a: sharpness
    0xa40b: device_setting_description
    0xa40c: subject_distance_range
    0xa420: image_unique_id
    0xa430: owner_name
    0xa431: serial_number
    0xa432: lens_info
    0xa433: lens_make
    0xa434: lens_model
    0xa435: lens_serial_number
    0xa480: gdal_metadata
    0xa481: gdal_no_data
    0xa500: gamma
    0xafc0: expand_software
    0xafc1: expand_lens
    0xafc2: expand_film
    0xafc3: expand_filter_lens
    0xafc4: expand_scanner
    0xafc5: expand_flash_lamp
    0xbc01: pixel_format
    0xbc02: transformation
    0xbc03: uncompressed
    0xbc04: image_type
    0xbc80: image_width2
    0xbc81: image_height2
    0xbc82: width_resolution
    0xbc83: height_resolution
    0xbcc0: image_offset
    0xbcc1: image_byte_count
    0xbcc2: alpha_offset
    0xbcc3: alpha_byte_count
    0xbcc4: image_data_discard
    0xbcc5: alpha_data_discard
    0xc427: oce_scanjob_desc
    0xc428: oce_application_selector
    0xc429: oce_id_number
    0xc42a: oce_image_logic
    0xc44f: annotations
    0xc4a5: print_im
    0xc573: original_file_name
    0xc580: uspto_original_content_type
    0xc612: dng_version
    0xc613: dng_backward_version
    0xc614: unique_camera_model
    0xc615: localized_camera_model
    0xc616: cfa_plane_color
    0xc617: cfa_layout
    0xc618: linearization_table
    0xc619: black_level_repeat_dim
    0xc61a: black_level
    0xc61b: black_level_delta_h
    0xc61c: black_level_delta_v
    0xc61d: white_level
    0xc61e: default_scale
    0xc61f: default_crop_origin
    0xc620: default_crop_size
    0xc621: color_matrix1
    0xc622: color_matrix2
    0xc623: camera_calibration1
    0xc624: camera_calibration2
    0xc625: reduction_matrix1
    0xc626: reduction_matrix2
    0xc627: analog_balance
    0xc628: as_shot_neutral
    0xc629: as_shot_white_xy
    0xc62a: baseline_exposure
    0xc62b: baseline_noise
    0xc62c: baseline_sharpness
    0xc62d: bayer_green_split
    0xc62e: linear_response_limit
    0xc62f: camera_serial_number
    0xc630: dng_lens_info
    0xc631: chroma_blur_radius
    0xc632: anti_alias_strength
    0xc633: shadow_scale
    0xc634: sr2_private
    0xc635: maker_note_safety
    0xc640: raw_image_segmentation
    0xc65a: calibration_illuminant1
    0xc65b: calibration_illuminant2
    0xc65c: best_quality_scale
    0xc65d: raw_data_unique_id
    0xc660: alias_layer_metadata
    0xc68b: original_raw_file_name
    0xc68c: original_raw_file_data
    0xc68d: active_area
    0xc68e: masked_areas
    0xc68f: as_shot_icc_profile
    0xc690: as_shot_pre_profile_matrix
    0xc691: current_icc_profile
    0xc692: current_pre_profile_matrix
    0xc6bf: colorimetric_reference
    0xc6c5: s_raw_type
    0xc6d2: panasonic_title
    0xc6d3: panasonic_title2
    0xc6f3: camera_calibration_sig
    0xc6f4: profile_calibration_sig
    0xc6f5: profile_ifd
    0xc6f6: as_shot_profile_name
    0xc6f7: noise_reduction_applied
    0xc6f8: profile_name
    0xc6f9: profile_hue_sat_map_dims
    0xc6fa: profile_hue_sat_map_data1
    0xc6fb: profile_hue_sat_map_data2
    0xc6fc: profile_tone_curve
    0xc6fd: profile_embed_policy
    0xc6fe: profile_copyright
    0xc714: forward_matrix1
    0xc715: forward_matrix2
    0xc716: preview_application_name
    0xc717: preview_application_version
    0xc718: preview_settings_name
    0xc719: preview_settings_digest
    0xc71a: preview_color_space
    0xc71b: preview_date_time
    0xc71c: raw_image_digest
    0xc71d: original_raw_file_digest
    0xc71e: sub_tile_block_size
    0xc71f: row_interleave_factor
    0xc725: profile_look_table_dims
    0xc726: profile_look_table_data
    0xc740: opcode_list1
    0xc741: opcode_list2
    0xc74e: opcode_list3
    0xc761: noise_profile
    0xc763: time_codes
    0xc764: frame_rate
    0xc772: t_stop
    0xc789: reel_name
    0xc791: original_default_final_size
    0xc792: original_best_quality_size
    0xc793: original_default_crop_size
    0xc7a1: camera_label
    0xc7a3: profile_hue_sat_map_encoding
    0xc7a4: profile_look_table_encoding
    0xc7a5: baseline_exposure_offset
    0xc7a6: default_black_render
    0xc7a7: new_raw_image_digest
    0xc7a8: raw_to_preview_gain
    0xc7b5: default_user_crop
    0xea1c: padding
    0xea1d: offset_schema
    0xfde8: owner_name2
    0xfde9: serial_number2
    0xfdea: lens
    0xfe00: kdc_ifd
    0xfe4c: raw_file
    0xfe4d: converter
    0xfe4e: white_balance2
    0xfe51: exposure
    0xfe52: shadows
    0xfe53: brightness
    0xfe54: contrast2
    0xfe55: saturation2
    0xfe56: sharpness2
    0xfe57: smoothness
    0xfe58: moire_filter
