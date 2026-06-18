meta:
  id: png
  title: PNG (Portable Network Graphics) file
  file-extension:
    - png
    - apng
  xref:
    forensicswiki: portable_network_graphics_(png)
    iso: 15948:2004
    justsolve:
      - PNG
      - APNG
      - Fireworks_PNG
    loc: fdd000153
    mime:
      - image/png
      - image/apng
      - image/vnd.mozilla.apng
    pronom:
      - fmt/11 # PNG 1.0
      - fmt/12 # PNG 1.1
      - fmt/13 # PNG 1.2
      - fmt/935 # APNG
    rfc: 2083
    wikidata:
      - Q178051 # PNG
      - Q433224 # APNG
  license: CC0-1.0
  ks-version: 0.11
  endian: be
doc: |
  Test files for APNG can be found at the following locations:

    * <https://philip.html5.org/tests/apng/tests.html>
    * <http://littlesvr.ca/apng/>
seq:
  # https://www.w3.org/TR/png/#5PNG-file-signature
  - id: magic
    contents: [137, 80, 78, 71, 13, 10, 26, 10]
  # https://www.w3.org/TR/png/#11IHDR
  # Always appears first, stores values referenced by other chunks
  - id: ihdr_len
    type: u4
    valid: 13
  - id: ihdr_type
    contents: "IHDR"
  - id: ihdr
    type: ihdr_chunk
  - id: ihdr_crc
    type: u4
  # The rest of the chunks
  - id: chunks
    type: chunk
    repeat: until
    repeat-until: _.type == "IEND" or _io.eof
types:
  chunk:
    -webide-representation: "{type}"
    seq:
      - id: len
        type: u4
      - id: type_raw
        size: 4
        valid:
          expr: |
            (
              (_[0] >= 0x41 and _[0] <= 0x5a) or
              (_[0] >= 0x61 and _[0] <= 0x7a)
            ) and (
              (_[1] >= 0x41 and _[1] <= 0x5a) or
              (_[1] >= 0x61 and _[1] <= 0x7a)
            ) and (
              (_[2] >= 0x41 and _[2] <= 0x5a) or
              (_[2] >= 0x61 and _[2] <= 0x7a)
            ) and (
              (_[3] >= 0x41 and _[3] <= 0x5a) or
              (_[3] >= 0x61 and _[3] <= 0x7a)
            )
        doc: |
          Each byte of a chunk type is restricted to the hexadecimal values
          0x41..0x5a and 0x61..0x7a, i.e. uppercase and lowercase ASCII letters
          (`A-Z` and `a-z`).
        doc-ref: https://www.w3.org/TR/2025/REC-png-3-20250624/#table51
      - id: body
        size: len
        type:
          switch-on: type
          cases:
            # Critical chunks
            # '"IHDR"': ihdr_chunk
            '"PLTE"': plte_chunk
            # IDAT = raw
            # IEND = empty, thus raw

            # Ancillary chunks
            '"cHRM"': chrm_chunk
            '"cICP"': cicp_chunk
            '"cLLI"': clli_chunk
            '"gAMA"': gama_chunk
            # iCCP
            '"mDCV"': mdcv_chunk
            # sBIT
            '"sRGB"': srgb_chunk
            '"bKGD"': bkgd_chunk
            # hIST
            # tRNS
            '"pHYs"': phys_chunk
            # sPLT
            '"tIME"': time_chunk
            '"iTXt"': international_text_chunk
            '"tEXt"': text_chunk
            '"zTXt"': compressed_text_chunk

            # animated PNG chunks
            '"acTL"': animation_control_chunk
            '"fcTL"': frame_control_chunk
            '"fdAT"': frame_data_chunk

            # Adobe Fireworks chunks
            '"mkBS"': adobe_fireworks_chunk
            '"mkTS"': adobe_fireworks_chunk
            '"prVW"': adobe_fireworks_chunk

            # Evernote/Skitch chunks
            '"skMf"': evernote_skmf_chunk
            '"skRf"': evernote_skrf_chunk

            # pngattach
            '"atCh"': atch_chunk

            # https://exiftool.org/TagNames/XMP.html#SEAL
            # https://github.com/hackerfactor/SEAL/blob/master/FORMATS.md#png
            # seAl
      - id: crc
        type: u4
    instances:
      type:
        value: type_raw.to_s('ASCII')
      is_ancillary:
        value: type_raw[0] & 0x20 != 0
        doc: |
          false = critical chunk, true = ancillary chunk
      is_private:
        value: type_raw[1] & 0x20 != 0
        doc: |
          false = public chunk (defined by the W3C), true = private chunk (can
          be defined by anyone)
      reserved_bit:
        value: type_raw[2] & 0x20 != 0
        doc: |
          Should be `false`, i.e. all chunk types should have uppercase third
          letters (the lowercase third letter is reserved for possible future
          extensions to the PNG standard)
      is_safe_to_copy:
        value: type_raw[3] & 0x20 != 0
        doc: |
          Defines whether the chunk may be copied if the image data (i.e.
          pixels) is modified. This tells PNG editors how to handle unknown
          chunks - see section [14.2 Behavior of PNG
          editors](https://www.w3.org/TR/2025/REC-png-3-20250624/#14Ordering) in
          the official specification.
  ihdr_chunk:
    doc-ref: https://www.w3.org/TR/png/#11IHDR
    seq:
      - id: width
        type: u4
        valid:
          min: 1
      - id: height
        type: u4
        valid:
          min: 1
      - id: bit_depth
        type: u1
        valid:
          any-of: [1, 2, 4, 8, 16]
      - id: color_type
        type: u1
        enum: color_type
      - id: compression_method
        type: u1
      - id: filter_method
        type: u1
      - id: interlace_method
        type: u1
  plte_chunk:
    doc-ref: https://www.w3.org/TR/png/#11PLTE
    seq:
      - id: entries
        type: rgb
        repeat: eos
  rgb:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
  cicp_chunk:
    doc-ref:
      - https://www.w3.org/TR/png/#cICP-chunk
      - https://w3c.github.io/png/Implementation_Report_3e/#cicp
    seq:
      - id: color_primaries
        type: u1
        doc: |
          values above 22 are reserved, see
          <https://github.com/pnggroup/pngcheck/blob/bd33ad6490269df07cac81e5305f4ebf56c2b637/pngcheck.c#L3322-L3325>
      - id: transfer_function
        type: u1
        doc: |
          values above 18 are reserved, see
          <https://github.com/pnggroup/pngcheck/blob/bd33ad6490269df07cac81e5305f4ebf56c2b637/pngcheck.c#L3326-L3329>
      - id: matrix_coefficients
        type: u1
        valid: 0 # https://github.com/pnggroup/pngcheck/blob/bd33ad6490269df07cac81e5305f4ebf56c2b637/pngcheck.c#L3314-L3317
        doc: |
          From the [official
          specification](https://www.w3.org/TR/2025/REC-png-3-20250624/#cICP-chunk):

          > RGB is currently the only supported color model in PNG, and as such
          > `Matrix Coefficients` shall be set to `0`.
      - id: video_full_range_flag
        type: u1
        valid:
          any-of: [0, 1] # https://github.com/pnggroup/pngcheck/blob/bd33ad6490269df07cac81e5305f4ebf56c2b637/pngcheck.c#L3318-L3321
        doc: |
          From the [official
          specification](https://www.w3.org/TR/2025/REC-png-3-20250624/#cICP-chunk):

          > If `Video Full Range Flag` value is `1`, then the image is a
          > full-range image. Typically, images in the RGB color representation
          > are stored in the full-range signal quantization, therefore the vast
          > majority of computer graphics and web images, including those used
          > in traditional PNG workflows, are full-range images.

          > If `Video Full Range Flag` value is `0`, then the image is a
          > narrow-range image.
  clli_chunk:
    -webide-representation: 'MaxCLL = {max_content_light_level:dec} cd/m^2, MaxFALL = {max_frame_average_light_level:dec} cd/m^2'
    doc-ref:
      - https://www.w3.org/TR/png/#cLLI-chunk
      - https://w3c.github.io/png/Implementation_Report_3e/#light
    seq:
      - id: max_content_light_level_int
        type: u4
      - id: max_frame_average_light_level_int
        type: u4
    instances:
      max_content_light_level:
        value: max_content_light_level_int * 0.0001
        -orig-id: MaxCLL
        doc: Maximum Content Light Level (MaxCLL), in cd/m^2
      max_frame_average_light_level:
        value: max_frame_average_light_level_int * 0.0001
        -orig-id: MaxFALL
        doc: Maximum Frame Average Light Level (MaxFALL), in cd/m^2
  chrm_chunk:
    doc-ref: https://www.w3.org/TR/png/#11cHRM
    seq:
      - id: white_point
        type: chrm_chromaticity
      - id: red
        type: chrm_chromaticity
      - id: green
        type: chrm_chromaticity
      - id: blue
        type: chrm_chromaticity
  chrm_chromaticity:
    -webide-representation: '({x:dec}, {y:dec})'
    seq:
      - id: x_int
        type: u4
      - id: y_int
        type: u4
    instances:
      x:
        value: x_int / 100000.0
      y:
        value: y_int / 100000.0
  gama_chunk:
    -webide-representation: '{gamma:dec} (= 1/{inv_gamma:dec})'
    doc-ref: https://www.w3.org/TR/png/#11gAMA
    seq:
      - id: gamma_int
        type: u4
        valid:
          expr: _ != 0
        doc: |
          Image gamma multiplied by 100000 (a gamma value of 1/2.2 is stored as
          45455)
    instances:
      gamma:
        value: gamma_int / 100000.0
        doc: Image gamma, typically 0.45455 = 1/2.2
      inv_gamma:
        value: 100000.0 / gamma_int
        doc: |
          Inverse of the image gamma (1 / gamma), typically 2.2 (not considering
          rounding)
  mdcv_chunk:
    doc-ref:
      - https://www.w3.org/TR/png/#mDCV-chunk
      - https://w3c.github.io/png/Implementation_Report_3e/#mastering
    seq:
      - id: red
        type: mdcv_chromaticity
      - id: green
        type: mdcv_chromaticity
      - id: blue
        type: mdcv_chromaticity
      - id: white_point
        type: mdcv_chromaticity
      - id: max_luminance_int
        type: u4
      - id: min_luminance_int
        type: u4
    instances:
      max_luminance:
        value: max_luminance_int * 0.0001
        doc: Maximum luminance in cd/m^2
      min_luminance:
        value: min_luminance_int * 0.0001
        doc: Minimum luminance in cd/m^2
  mdcv_chromaticity:
    -webide-representation: '({x:dec}, {y:dec})'
    seq:
      - id: x_int
        type: u2
      - id: y_int
        type: u2
    instances:
      x:
        value: x_int * 0.00002
      y:
        value: y_int * 0.00002
  srgb_chunk:
    doc-ref: https://www.w3.org/TR/png/#11sRGB
    seq:
      - id: render_intent
        type: u1
        enum: intent
    enums:
      intent:
        0: perceptual
        1: relative_colorimetric
        2: saturation
        3: absolute_colorimetric
  bkgd_chunk:
    doc: |
      Background chunk stores default background color to display this
      image against. Contents depend on `color_type` of the image.
    doc-ref: https://www.w3.org/TR/png/#11bKGD
    seq:
      - id: bkgd
        type:
          switch-on: _root.ihdr.color_type
          cases:
            color_type::greyscale: bkgd_greyscale
            color_type::greyscale_alpha: bkgd_greyscale
            color_type::truecolor: bkgd_truecolor
            color_type::truecolor_alpha: bkgd_truecolor
            color_type::indexed: bkgd_indexed
  bkgd_greyscale:
    doc: Background chunk for greyscale images.
    seq:
      - id: value
        type: u2
  bkgd_truecolor:
    doc: Background chunk for truecolor images.
    seq:
      - id: red
        type: u2
      - id: green
        type: u2
      - id: blue
        type: u2
  bkgd_indexed:
    doc: Background chunk for images with indexed palette.
    seq:
      - id: palette_index
        type: u1
  phys_chunk:
    doc: |
      "Physical size" chunk stores data that allows to translate
      logical pixels into physical units (meters, etc) and vice-versa.
    doc-ref: https://www.w3.org/TR/png/#11pHYs
    seq:
      - id: pixels_per_unit_x
        type: u4
        doc: |
          Number of pixels per physical unit (typically, 1 meter) by X
          axis.
      - id: pixels_per_unit_y
        type: u4
        doc: |
          Number of pixels per physical unit (typically, 1 meter) by Y
          axis.
      - id: unit
        type: u1
        enum: phys_unit
  time_chunk:
    doc: |
      Time chunk stores time stamp of last modification of this image,
      up to 1 second precision in UTC timezone.
    doc-ref: https://www.w3.org/TR/png/#11tIME
    seq:
      - id: year
        type: u2
      - id: month
        type: u1
      - id: day
        type: u1
      - id: hour
        type: u1
      - id: minute
        type: u1
      - id: second
        type: u1
  international_text_chunk:
    -webide-representation: '{keyword}'
    doc: |
      International textual data (`iTXt`) chunk effectively allows you to store
      key-value string pairs in the PNG container.

      The "key" part (`keyword`) is restricted to printable ISO-8859-1 (Latin-1)
      characters and spaces. The translated keyword and the "value" part
      (`text`) are stored in UTF-8 and thus can store text in any language -
      this language can be indicated via the language tag (`language_tag`).
    doc-ref: https://www.w3.org/TR/png/#11iTXt
    seq:
      - id: keyword
        type: strz
        encoding: ISO-8859-1
        doc: |
          Indicates the type of information represented by the text string.

          Keywords must consist exclusively of printable ISO-8859-1 (Latin-1)
          characters and spaces; that is, only code points 0x20-0x7E and
          0xA1-0xFF are allowed. To reduce the chances for human misreading of a
          keyword, leading spaces, trailing spaces, and consecutive spaces are
          not permitted.
        doc-ref: https://www.w3.org/TR/2025/REC-png-3-20250624/#11keywords
      - id: compression_flag
        type: u1
        valid:
          any-of: [0, 1]
        doc: |
          0 = text is uncompressed, 1 = text is compressed with a
          method specified in `compression_method`.
      - id: compression_method
        type: u1
        enum: compression_methods
      - id: language_tag
        type: strz
        encoding: ASCII
        doc: |
          Human language used in the `translated_keyword` and `text` fields.

          From the [official
          specification](https://www.w3.org/TR/2025/REC-png-3-20250624/#11iTXt):

          > The language tag is a well-formed language tag defined by [RFC 5646:
          > BCP 47: Tags for Identifying
          > Languages](https://www.rfc-editor.org/info/rfc5646/). Unlike the
          > keyword, the language tag is case-insensitive. Subtags must appear
          > in the [IANA language subtag
          > registry](https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry).
          > If the language tag is empty, the language is unspecified. Examples
          > of language tags include: `en`, `en-GB`, `es-419`, `zh-Hans`,
          > `zh-Hans-CN`, `tlh-Cyrl-AQ`, `ar-AE-u-nu-latn`, and `x-private`.
      - id: translated_keyword
        type: strz
        encoding: UTF-8
        doc: |
          The keyword (`keyword`) translated into the language specified in
          `language_tag`.

          It must not contain a zero byte (U+0000 NULL character). Line breaks
          should not appear. The remaining control characters (U+0001..U+0009,
          U+000B..0+001F, U+007F..U+009F) are discouraged.
      - id: text_plain
        size-eos: true
        type: international_text
        if: compression_flag == 0
      - id: text_zlib
        size-eos: true
        process: zlib
        type: international_text
        if: compression_flag == 1
        -affected-by:
          - 374 # `process/switch-on` would help here
          - 706 # `process` does not work with `type: str`
    instances:
      text:
        value: '(compression_flag == 0 ? text_plain : text_zlib).value'
        doc: |
          Text string (the "value" of this key-value pair), written in language
          specified in `language_tag`.

          Although it is not null-terminated (unlike other textual data in the
          `iTXt` chunk), it must not contain a zero byte
          (U+0000 NULL character). A newline should be represented by a single
          U+000A LINE FEED (LF) character (aka `\n`). The remaining control
          characters (U+0001..U+0009, U+000B..0+001F, U+007F..U+009F) are
          discouraged.
  international_text:
    seq:
      - id: value
        type: str
        encoding: UTF-8
        size-eos: true
        doc: |
          Text string (the "value" of this key-value pair), written in language
          specified in `_parent.language_tag`.

          Although it is not null-terminated (unlike other textual data in the
          `iTXt` chunk), it must not contain a zero byte
          (U+0000 NULL character). A newline should be represented by a single
          U+000A LINE FEED (LF) character (aka `\n`). The remaining control
          characters (U+0001..U+0009, U+000B..0+001F, U+007F..U+009F) are
          discouraged.
  text_chunk:
    -webide-representation: '{keyword}'
    doc: |
      Textual data (`tEXt`) chunk effectively allows you to store key-value
      string pairs in the PNG container.

      Both the "key" (`keyword`) and "value" (`text`) parts are restricted to
      printable ISO-8859-1 (Latin-1) characters and ASCII spaces, with the
      exception that `text` can also contain newlines (U+000A LINE FEED (LF)
      characters) and U+00A0 NON-BREAKING SPACE characters.
    doc-ref: https://www.w3.org/TR/png/#11tEXt
    seq:
      - id: keyword
        type: strz
        encoding: ISO-8859-1
        doc: |
          Indicates the type of information represented by the text string.

          Keywords must consist exclusively of printable ISO-8859-1 (Latin-1)
          characters and spaces; that is, only code points 0x20-0x7E and
          0xA1-0xFF are allowed. To reduce the chances for human misreading of a
          keyword, leading spaces, trailing spaces, and consecutive spaces are
          not permitted.
        doc-ref: https://www.w3.org/TR/2025/REC-png-3-20250624/#11keywords
      - id: text
        type: str
        size-eos: true
        encoding: ISO-8859-1
        doc: |
          Text string (the "value" of this key-value pair).

          Although it is not null-terminated (unlike the keyword), it must not
          contain a zero byte (U+0000 NULL character). A newline should be
          represented by a single U+000A LINE FEED (LF) character (aka `\n`).
          The remaining control characters (U+0001..U+0009, U+000B..0+001F,
          U+007F..U+009F) are discouraged.
  compressed_text_chunk:
    -webide-representation: '{keyword}'
    doc: |
      Compressed textual data (`zTXt`) chunk effectively allows you to store
      key-value string pairs in the PNG container, compressing the "value" part
      (which can be quite lengthy) with zlib compression.

      The `zTXt` and `tEXt` chunks are semantically equivalent, but the `zTXt`
      chunk is recommended for storing large blocks of text.
    doc-ref: https://www.w3.org/TR/png/#11zTXt
    seq:
      - id: keyword
        type: strz
        encoding: ISO-8859-1
        doc: |
          Indicates the type of information represented by the text string.

          Keywords must consist exclusively of printable ISO-8859-1 (Latin-1)
          characters and spaces; that is, only code points 0x20-0x7E and
          0xA1-0xFF are allowed. To reduce the chances for human misreading of a
          keyword, leading spaces, trailing spaces, and consecutive spaces are
          not permitted.
        doc-ref: https://www.w3.org/TR/2025/REC-png-3-20250624/#11keywords
      - id: compression_method
        type: u1
        enum: compression_methods
      - id: text
        size-eos: true
        process: zlib
        type: compressed_text
        -affected-by: 706 # `process` does not work with `type: str`
  compressed_text:
    seq:
      - id: value
        type: str
        encoding: ISO-8859-1
        size-eos: true
        doc: |
          Text string (the "value" of this key-value pair).

          Although it is not null-terminated (unlike the keyword), it must not
          contain a zero byte (U+0000 NULL character). A newline should be
          represented by a single U+000A LINE FEED (LF) character (aka `\n`).
          The remaining control characters (U+0001..U+0009, U+000B..0+001F,
          U+007F..U+009F) are discouraged.
  animation_control_chunk:
    doc-ref: https://wiki.mozilla.org/APNG_Specification#.60acTL.60:_The_Animation_Control_Chunk
    seq:
      - id: num_frames
        type: u4
        doc: Number of frames, must be equal to the number of `frame_control_chunk`s
      - id: num_plays
        type: u4
        doc: Number of times to loop, 0 indicates infinite looping.
  frame_control_chunk:
    doc-ref: https://wiki.mozilla.org/APNG_Specification#.60fcTL.60:_The_Frame_Control_Chunk
    seq:
      - id: sequence_number
        type: u4
        doc: Sequence number of the animation chunk
      - id: width
        type: u4
        valid:
          min: 1
          max: _root.ihdr.width
        doc: Width of the following frame
      - id: height
        type: u4
        valid:
          min: 1
          max: _root.ihdr.height
        doc: Height of the following frame
      - id: x_offset
        type: u4
        valid:
          max: _root.ihdr.width - width
        doc: X position at which to render the following frame
      - id: y_offset
        type: u4
        valid:
          max: _root.ihdr.height - height
        doc: Y position at which to render the following frame
      - id: delay_num
        type: u2
        doc: Frame delay fraction numerator
      - id: delay_den
        type: u2
        doc: Frame delay fraction denominator
      - id: dispose_op
        type: u1
        enum: dispose_op_values
        doc: Type of frame area disposal to be done after rendering this frame
      - id: blend_op
        type: u1
        enum: blend_op_values
        doc: Type of frame area rendering for this frame
    instances:
      delay:
        value: 'delay_num / (delay_den == 0 ? 100.0 : delay_den)'
        doc: Time to display this frame, in seconds
  frame_data_chunk:
    doc-ref: https://wiki.mozilla.org/APNG_Specification#.60fdAT.60:_The_Frame_Data_Chunk
    seq:
      - id: sequence_number
        type: u4
        doc: |
          Sequence number of the animation chunk. The fcTL and fdAT chunks
          have a 4 byte sequence number. Both chunk types share the sequence.
          The first fcTL chunk must contain sequence number 0, and the sequence
          numbers in the remaining fcTL and fdAT chunks must be in order, with
          no gaps or duplicates.
      - id: frame_data
        size-eos: true
        doc: |
          Frame data for the frame. At least one fdAT chunk is required for
          each frame. The compressed datastream is the concatenation of the
          contents of the data fields of all the fdAT chunks within a frame.
  adobe_fireworks_chunk:
    doc-ref: https://stackoverflow.com/questions/4242402/the-fireworks-png-format-any-insight-any-libs/51683285#51683285
    seq:
      - id: preview_data
        process: zlib
        size-eos: true
  evernote_skmf_chunk:
    doc-ref: https://web.archive.org/web/20210302212148/https://discussion.evernote.com/forums/topic/88532-how-to-extract-annotation-information-from-annotated-evernoteskitch-images/#comment-451501
    seq:
      - id: json
        type: str
        encoding: UTF-8
        size-eos: true
        doc: |
          JSON document with information about editable annotations (text,
          lines, paths, etc.) in Evernote/Skitch.

          It refers to the original image stored in the `skRf` chunk (which
          usually follows immediately after `skMf`) via the
          `.children[0].children[0].uri` JSON property. This has the format
          `"skitch+uuid:///$UUID"`, where `$UUID` is a random UUIDv4 value that
          matches the `uuid` field in `evernote_skrf_chunk` (i.e. in the first
          16 bytes of the `skRf` chunk).
  evernote_skrf_chunk:
    doc-ref: https://web.archive.org/web/20210302212148/https://discussion.evernote.com/forums/topic/88532-how-to-extract-annotation-information-from-annotated-evernoteskitch-images/#comment-451501
    -webide-representation: '{uuid:uuid}'
    seq:
      - id: uuid
        size: 16
        doc: |
          Random UUIDv4 value used to identify the image. It is referenced by
          the `skMf` chunk - see the documentation for the `json` field in
          `evernote_skmf_chunk`.
      - id: orig_img
        size-eos: true
        doc: |
          The original source image without annotations. It's usually a PNG
          image as well, but it can also be a JPEG or possibly other formats.
  atch_chunk:
    doc-ref:
      - https://github.com/skeeto/scratch/tree/58470254f4a95cdf7a53888e405c851c21eb2cae/pngattach
      - https://nullprogram.com/blog/2021/12/31/ A new protocol and tool for PNG file attachments
    seq:
      - id: file_name
        type: strz
        encoding: UTF-8
        valid:
          # See https://github.com/skeeto/scratch/blob/58470254f4a95cdf7a53888e405c851c21eb2cae/pngattach/pngattach.c#L466-L468
          expr: _.length != 0 and _.substring(0, 1) != "."
        doc: |
          From the [official
          specification](https://github.com/skeeto/scratch/tree/58470254f4a95cdf7a53888e405c851c21eb2cae/pngattach#atch-chunk-specification):

          > The name can be any length that fits in the chunk, and should be
          > encoded with UTF-8. It's up to each implementation to determine how
          > to appropriately interpret the bytestring for the local system.

          > The name must be at least one byte long, not counting the null
          > terminator. It cannot begin with a period (`0x2e`), nor contain
          > control bytes (anything less than `0x20`), nor slash (`0x2f`), nor
          > backslash (`0x5c`), i.e. no directory hierarchies.

          As of Kaitai Struct 0.11, we cannot easily check whether a string
          contains certain characters, so we only enforce that the file name is
          not empty and that it doesn't start with a period.
      - id: compression
        type: u1
        enum: compression_attach_methods
        valid:
          in-enum: true
      - id: data_plain
        size-eos: true
        if: compression == compression_attach_methods::none
      - id: data_zlib
        size-eos: true
        process: zlib
        if: compression == compression_attach_methods::zlib
    instances:
      data:
        value: 'compression == compression_attach_methods::none ? data_plain : data_zlib'
    enums:
      compression_attach_methods:
        0: none
        1: zlib
enums:
  color_type:
    0: greyscale
    2: truecolor
    3: indexed
    4: greyscale_alpha
    6: truecolor_alpha
  phys_unit:
    0: unknown
    1: meter
  compression_methods:
    0: zlib
  dispose_op_values:
    0:
      id: none
      doc: |
        No disposal is done on this frame before rendering the next;
        the contents of the output buffer are left as is.
      doc-ref: https://wiki.mozilla.org/APNG_Specification#.60fcTL.60:_The_Frame_Control_Chunk
    1:
      id: background
      doc: |
        The frame's region of the output buffer is to be cleared to
        fully transparent black before rendering the next frame.
      doc-ref: https://wiki.mozilla.org/APNG_Specification#.60fcTL.60:_The_Frame_Control_Chunk
    2:
      id: previous
      doc: |
        The frame's region of the output buffer is to be reverted
        to the previous contents before rendering the next frame.
      doc-ref: https://wiki.mozilla.org/APNG_Specification#.60fcTL.60:_The_Frame_Control_Chunk
  blend_op_values:
    0:
      id: source
      doc: |
        All color components of the frame, including alpha,
        overwrite the current contents of the frame's output buffer region.
    1:
      id: over
      doc: |
        The frame is composited onto the output buffer based on its alpha
