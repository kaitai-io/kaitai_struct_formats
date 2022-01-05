meta:
  id: bmp
  file-extension: bmp
  xref:
    forensicswiki: BMP
    justsolve: BMP
    loc: fdd000189
    mime: image/bmp
    pronom:
      - fmt/114 # Windows Bitmap 1.0
      - fmt/115 # Windows Bitmap 2.0
      - fmt/116 # Windows Bitmap 3.0
      - fmt/117 # Windows Bitmap 3.0 NT
      - fmt/118 # Windows Bitmap 4.0
      - fmt/119 # Windows Bitmap 5.0
      - x-fmt/25 # OS/2 Bitmap 1.0
      - x-fmt/270 # OS/2 Bitmap 2.0
    wikidata: Q192869
  tags:
    - windows
  license: CC0-1.0
  ks-version: 0.9
  endian: le
  # ks-opaque-types: true # uncomment this line and comment `/types/bitmap`,
                          # if you provide an opaque type `bitmap` for bitmap data
doc: |
  The **BMP file format**, also known as **bitmap image file** or **device independent
  bitmap (DIB) file format** or simply a **bitmap**, is a raster graphics image file
  format used to store bitmap digital images, independently of the display
  device (such as a graphics adapter), especially on Microsoft Windows
  and OS/2 operating systems.

  ## Samples

  Great collection of various BMP sample files:
  [**BMP Suite Image List**](
    http://entropymine.com/jason/bmpsuite/bmpsuite/html/bmpsuite.html
  ) (by Jason Summers)

  If only there was such a comprehensive sample suite for every file format! It's like
  a dream for every developer of any binary file format parser. It contains a lot of
  different types and variations of BMP files, even the tricky ones, where it's not clear
  from the specification how to deal with them (marked there as "**q**uestionable").

  If you make a program which will be able to read all the "**g**ood" and "**q**uestionable"
  BMP files and won't crash on the "**b**ad" ones, it will definitely have one of the most
  extensive support of BMP files in the universe!

  ## BITMAPV2INFOHEADER and BITMAPV3INFOHEADER

  A beneficial discussion on Adobe forum (archived):
  [**Invalid BMP Format with Alpha channel**](
    https://web.archive.org/web/20150127132443/https://forums.adobe.com/message/3272950
  )

  In 2010, someone noticed that Photoshop generated BMP with an odd type of header. There wasn't
  any documentation available for this header at the time (and still isn't).
  However, Chris Cox (former Adobe employee) claimed that they hadn't invented any type
  of proprietary header and everything they were writing was taken directly
  from the Microsoft documentation.

  It showed up that the unknown header was called BITMAPV3INFOHEADER.
  Although Microsoft has apparently requested and verified the use of the header,
  the documentation on MSDN has probably got lost and they have probably
  forgotten about this type of header.

  This is the only source I could find about these structures, so we could't rely
  on it so much, but I think supporting them as a read-only format won't harm anything.
  Due to the fact that it isn't documented anywhere else, most applications don't support it.

  All Windows headers at once (including mentioned BITMAPV2INFOHEADER and BITMAPV3INFOHEADER):

  ![Bitmap headers overview](
    https://web.archive.org/web/20190527043845/https://forums.adobe.com/servlet/JiveServlet/showImage/2-3273299-47801/BMP_Headers.png
  )

  ## Specs
   * [Bitmap Storage (Windows Dev Center)](
       https://docs.microsoft.com/en-us/windows/win32/gdi/bitmap-storage
     )
      * BITMAPFILEHEADER
      * BITMAPINFOHEADER
      * BITMAPV4HEADER
      * BITMAPV5HEADER
   * [OS/2 Bitmap File Format](
        https://www.fileformat.info/format/os2bmp/egff.htm
     )
      * BITMAPFILEHEADER (OS2BMPFILEHEADER)
      * BITMAPCOREHEADER (OS21XBITMAPHEADER)
      * OS22XBITMAPHEADER
   * [Microsoft Windows Bitmap](
        http://netghost.narod.ru/gff/graphics/summary/micbmp.htm
     )
      * BITMAPFILEHEADER (WINBMPFILEHEADER)
      * BITMAPCOREHEADER (WIN2XBITMAPHEADER)
      * BITMAPINFOHEADER (WINNTBITMAPHEADER)
      * BITMAPV4HEADER (WIN4XBITMAPHEADER)

seq:
  - id: file_hdr
    type: file_header
  - id: dib_info
    size: file_hdr.ofs_bitmap - file_hdr._sizeof
    type: bitmap_info
  - id: bitmap
    type: bitmap
    size-eos: true
types:
  bitmap:
    doc: |
      Replace with an opaque type if you care about the pixels.
      You can look at an example of a JavaScript implementation: https://github.com/generalmimon/bmptool/blob/master/src/Bitmap.js

      There is a proposal for adding bitmap data type to Kaitai Struct: https://github.com/kaitai-io/kaitai_struct/issues/188
  file_header:
    -orig-id: BITMAPFILEHEADER
    doc-ref: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapfileheader
    seq:
      - id: file_type
        -orig-id: bfType
        contents: "BM"
      - id: len_file
        -orig-id: bfSize
        type: u4
        doc: not reliable, mostly ignored by BMP decoders
      - id: reserved1
        -orig-id: bfReserved1
        type: u2
      - id: reserved2
        -orig-id: bfReserved2
        type: u2
      - id: ofs_bitmap
        -orig-id: bfOffBits
        type: s4
        doc: Offset to actual raw pixel data of the image
  bitmap_info:
    -orig-id: BITMAPINFO
    doc-ref: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfo
    seq:
      - id: len_header
        type: u4
      - id: header
        -orig-id: bmciHeader
        size: len_header - len_header._sizeof
        type: bitmap_header(len_header)
      - id: color_mask
        type: color_mask(header.bitmap_info_ext.compression == compressions::alpha_bitfields)
        if: is_color_mask_here
        doc: Valid only for BITMAPINFOHEADER, in all headers extending it the masks are contained in the header itself.
      - id: color_table
        -orig-id: bmciColors
        size-eos: true
        type: 'color_table(not header.is_core_header, header.extends_bitmap_info ? header.bitmap_info_ext.num_colors_used : 0)'
        if: not _io.eof
    instances:
      is_color_mask_here:
        value: >-
          not _io.eof
          and header.len_header == header_type::bitmap_info_header.to_i
          and (header.bitmap_info_ext.compression == compressions::bitfields or header.bitmap_info_ext.compression == compressions::alpha_bitfields)
      is_color_mask_given:
        value: >-
          header.extends_bitmap_info
          and (header.bitmap_info_ext.compression == compressions::bitfields or header.bitmap_info_ext.compression == compressions::alpha_bitfields)
          and (is_color_mask_here or header.is_color_mask_here)
      color_mask_given:
        value: >-
          is_color_mask_here
            ? color_mask
            : header.color_mask
        if: is_color_mask_given
      color_mask_red:
        value: >-
          is_color_mask_given
            ? color_mask_given.red_mask
            : header.bits_per_pixel == 16
              ? 0b11111_00000_00000
              : header.bits_per_pixel == 24 or header.bits_per_pixel == 32
                ? 0xff_00_00
                : 0
        #         ^ uses fixed color palette, so color mask is N/A
      color_mask_green:
        value: >-
          is_color_mask_given
            ? color_mask_given.green_mask
            : header.bits_per_pixel == 16
              ? 0b00000_11111_00000
              : header.bits_per_pixel == 24 or header.bits_per_pixel == 32
                ? 0x00_ff_00
                : 0
      color_mask_blue:
        value: >-
          is_color_mask_given
            ? color_mask_given.blue_mask
            : header.bits_per_pixel == 16
              ? 0b00000_00000_11111
              : header.bits_per_pixel == 24 or header.bits_per_pixel == 32
                ? 0x00_00_ff
                : 0
      color_mask_alpha:
        value: >-
          is_color_mask_given and color_mask_given.has_alpha_mask
            ? color_mask_given.alpha_mask
            : 0

  bitmap_header:
    -orig-id:
      - BITMAPCOREHEADER
      - OS21XBITMAPHEADER
    doc-ref:
      - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapcoreheader
      - https://www.fileformat.info/format/os2bmp/egff.htm#OS2BMP-DMYID.3.1
    params:
      - id: len_header
        type: u4
    seq:
      - id: image_width
        -orig-id: biWidth
        type:
          switch-on: is_core_header
          cases:
            true: u2
            false: u4
        doc: Image width, px
      - id: image_height_raw
        -orig-id: biHeight
        type:
          switch-on: is_core_header
          cases:
            true: s2
            false: s4
        doc: Image height, px (positive => bottom-up image, negative => top-down image)
      - id: num_planes
        -orig-id: biPlanes
        type: u2
        # valid: 1
        doc: Number of planes for target device, must be 1
      - id: bits_per_pixel
        -orig-id: biBitCount
        type: u2
        doc: Number of bits per pixel that image buffer uses (1, 4, 8, 16, 24 or 32)
      - id: bitmap_info_ext
        type: bitmap_info_extension
        if: extends_bitmap_info
      - id: color_mask
        type: color_mask(len_header != header_type::bitmap_v2_info_header.to_i)
        if: is_color_mask_here
      - id: os2_2x_bitmap_ext
        type: os2_2x_bitmap_extension
        if: extends_os2_2x_bitmap
      - id: bitmap_v4_ext
        type: bitmap_v4_extension
        if: extends_bitmap_v4
      - id: bitmap_v5_ext
        type: bitmap_v5_extension
        if: extends_bitmap_v5
    instances:
      is_core_header:
        value: len_header == header_type::bitmap_core_header.to_i
      extends_bitmap_info:
        value: len_header >= header_type::bitmap_info_header.to_i
      extends_os2_2x_bitmap:
        value: len_header == header_type::os2_2x_bitmap_header.to_i
      extends_bitmap_v4:
        value: len_header >= header_type::bitmap_v4_header.to_i
      extends_bitmap_v5:
        value: len_header >= header_type::bitmap_v5_header.to_i
      image_height:
        value: 'image_height_raw < 0 ? -image_height_raw : image_height_raw'
      bottom_up:
        value: image_height_raw > 0
      is_color_mask_here:
        value: len_header == header_type::bitmap_v2_info_header.to_i
          or len_header == header_type::bitmap_v3_info_header.to_i
          or extends_bitmap_v4
      uses_fixed_palette:
        value: not (bits_per_pixel == 16 or bits_per_pixel == 24 or bits_per_pixel == 32)
          and not (extends_bitmap_info and not extends_os2_2x_bitmap and (bitmap_info_ext.compression == compressions::jpeg or bitmap_info_ext.compression == compressions::png))
  bitmap_info_extension:
    -orig-id: BITMAPINFOHEADER
    doc-ref: https://docs.microsoft.com/en-us/previous-versions/dd183376(v=vs.85)
    seq:
      - id: compression
        -orig-id: biCompression
        type: u4
        enum: compressions
        if: not _parent.extends_os2_2x_bitmap
      - id: os2_compression
        -orig-id: Compression
        type: u4
        enum: os2_compressions
        if: _parent.extends_os2_2x_bitmap
      - id: len_image
        -orig-id: biSizeImage
        type: u4
        doc: |
          If biCompression is BI_JPEG or BI_PNG, indicates the size of the JPEG or PNG image buffer.
          This may be set to zero for BI_RGB bitmaps.
      - id: x_resolution
        -orig-id: biXPelsPerMeter
        type: u4
      - id: y_resolution
        -orig-id: biYPelsPerMeter
        type: u4
      - id: num_colors_used
        -orig-id: biClrUsed
        type: u4
      - id: num_colors_important
        -orig-id: biClrImportant
        type: u4
  os2_2x_bitmap_extension:
    -orig-id: OS22XBITMAPHEADER
    doc-ref: https://www.fileformat.info/format/os2bmp/egff.htm#OS2BMP-DMYID.3.2
    seq:
      - id: units
        type: u2
      - id: reserved
        type: u2
      - id: recording
        type: u2
        # valid: 0
        doc: |
          Specifies how the bitmap scan lines are stored.
          The only valid value for this field is 0, indicating that the bitmap is
          stored from left to right and from the bottom up.
      - id: rendering
        type: u2
        enum: os2_rendering
        doc: Specifies the halftoning algorithm used on the bitmap data.
      - id: size1
        type: u4
        doc: |
          rendering == os2_rendering::error_diffusion
            => error damping as a percentage in the range 0 through 100
          rendering == os2_rendering::panda or rendering == os2_rendering::super_circle
            => X dimension of the pattern used in pixels
      - id: size2
        type: u4
        doc: |
          rendering == os2_rendering::error_diffusion
            => not used
          rendering == os2_rendering::panda or rendering == os2_rendering::super_circle
            => Y dimension of the pattern used in pixels
      - id: color_encoding
        type: u4
        doc: |
          Specifies the color model used to describe the bitmap data.
          The only valid value is 0, indicating the RGB encoding scheme.
      - id: identifier
        type: u4
        doc: Application-specific value

  bitmap_v4_extension:
    -orig-id: BITMAPV4HEADER
    doc-ref: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapv4header
    seq:
      - id: color_space_type
        -orig-id: bV4CSType
        type: u4
        enum: color_space
      - id: endpoint_red
        type: cie_xyz
      - id: endpoint_green
        type: cie_xyz
      - id: endpoint_blue
        type: cie_xyz
      - id: gamma_red
        -orig-id: bV4GammaRed
        type: fixed_point_16_dot_16
      - id: gamma_blue
        -orig-id: bV4GammaGreen
        type: fixed_point_16_dot_16
      - id: gamma_green
        -orig-id: bV4GammaBlue
        type: fixed_point_16_dot_16

  cie_xyz:
    -orig-id: CIEXYZ
    doc-ref: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-ciexyz
    seq:
      - id: x
        type: fixed_point_2_dot_30
      - id: y
        type: fixed_point_2_dot_30
      - id: z
        type: fixed_point_2_dot_30

  bitmap_v5_extension:
    meta:
      encoding: windows-1252 # for the file name of linked profile (see profile_data below)
    -orig-id: BITMAPV5HEADER
    doc-ref: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapv5header
    seq:
      - id: intent
        -orig-id: bV5Intent
        type: u4
        enum: intent
      - id: ofs_profile
        -orig-id: bV5ProfileData
        doc: The offset, in bytes, from the beginning of the BITMAPV5HEADER structure to the start of the profile data.
        type: u4
      - id: len_profile
        -orig-id: bV5ProfileSize
        type: u4
      - id: reserved
        -orig-id: bV5Reserved
        type: u4
    instances:
      has_profile:
        value: >-
          _parent.bitmap_v4_ext.color_space_type == color_space::profile_linked
          or _parent.bitmap_v4_ext.color_space_type == color_space::profile_embedded
      profile_data:
        io: _root._io
        pos: _root.file_hdr._sizeof + ofs_profile
        size: len_profile
        type:
          switch-on: _parent.bitmap_v4_ext.color_space_type == color_space::profile_linked
          cases:
            true: strz
        if: has_profile
        doc-ref: https://docs.microsoft.com/en-us/windows/win32/wcs/using-structures-in-wcs-1-0 "If the profile is embedded,
          profile data is the actual profile, and if it is linked, the profile data is the
          null-terminated file name of the profile. This cannot be a Unicode string. It must be composed exclusively
          of characters from the Windows character set (code page 1252)."

  color_table:
    params:
      - id: has_reserved_field
        type: bool
      - id: num_colors
        doc: |
          If equal to 0, the pallete should contain as many colors as can fit into the pixel value
          according to the `bits_per_pixel` field (if `bits_per_pixel` = 8, then the pixel can
          represent 2 ** 8 = 256 values, so exactly 256 colors should be present). For more flexibility,
          it reads as many colors as it can until EOS is reached (and the image data begin).
        type: u4
    seq:
      - id: colors
        type: rgb_record(has_reserved_field)
        repeat: expr
        repeat-expr: 'num_colors > 0 and num_colors < num_colors_present ? num_colors : num_colors_present'
    instances:
      num_colors_present:
        value: '_io.size / (has_reserved_field ? 4 : 3)'
  color_mask:
    params:
      - id: has_alpha_mask
        type: bool
    seq:
      - id: red_mask
        type: u4
      - id: green_mask
        type: u4
      - id: blue_mask
        type: u4
      - id: alpha_mask
        type: u4
        if: has_alpha_mask
  rgb_record:
    -orig-id:
      - RGB_TRIPLE
      - RGB_QUAD
    params:
      - id: has_reserved_field
        type: bool
    seq:
      - id: blue
        type: u1
      - id: green
        type: u1
      - id: red
        type: u1
      - id: reserved
        type: u1
        if: has_reserved_field
    -webide-representation: "rgb({red:dec}, {green:dec}, {blue:dec})"
# Common types
  fixed_point_2_dot_30:
    -orig-id: FXPT2DOT30
    seq:
      - id: raw
        type: u4
    instances:
      value:
        value: (raw + 0.0) / (1 << 30)
    -webide-representation: "{value}"
  fixed_point_16_dot_16:
    seq:
      - id: raw
        type: u4
    instances:
      value:
        value: (raw + 0.0) / (1 << 16)
    -webide-representation: "{value}"
enums:
  compressions:
    # https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapv5header (search for bV5Compression)
    0:
      id: rgb
      -orig-id: BI_RGB
      doc: Uncompressed RGB format
    1:
      id: rle8
      -orig-id: BI_RLE8
      doc: RLE compression, 8 bits per pixel
    2:
      id: rle4
      -orig-id: BI_RLE4
      doc: RLE compression, 4 bits per pixel
    3:
      id: bitfields
      -orig-id: BI_BITFIELDS
    4:
      id: jpeg
      -orig-id: BI_JPEG
      doc: BMP file includes whole JPEG file in image buffer
    5:
      id: png
      -orig-id: BI_PNG
      doc: BMP file includes whole PNG file in image buffer
    6:
      id: alpha_bitfields
      -orig-id: BI_ALPHABITFIELDS
      doc: only Windows CE 5.0 with .NET 4.0 or later
      doc-ref:
        - https://en.wikipedia.org/wiki/BMP_file_format#DIB_header_(bitmap_information_header) table of compression methods
        - http://entropymine.com/jason/bmpsuite/bmpsuite/html/bmpsuite.html q/rgba32abf.bmp
  os2_compressions:
    # https://www.fileformat.info/format/os2bmp/egff.htm#OS2BMP-DMYID.3.2
    0:
      id: rgb
    1:
      id: rle8
    2:
      id: rle4
    3:
      id: huffman_1d
      doc: Huffman 1D compression (also known as CCITT Group 3 One-Dimensional (G31D))
    4:
      id: rle24
      doc: RLE compression, 24 bits per pixel
  os2_rendering:
    0:
      id: no_halftoning
    1:
      id: error_diffusion
    2:
      id: panda
      doc: Processing Algorithm for Noncoded Document Acquisition (PANDA)
    3:
      id: super_circle

  color_space:
    # https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapv5header#members
  # For BITMAPV4HEADER:
    0:
      id: calibrated_rgb
      -orig-id: LCS_CALIBRATED_RGB
      doc: This value implies that endpoints and gamma values are given in the appropriate fields.
    0x73524742: # 'sRGB'
      id: s_rgb
      -orig-id: LCS_sRGB
      doc: Specifies that the bitmap is in sRGB color space.
    0x57696e20: # 'Win '
      id: windows
      -orig-id: LCS_WINDOWS_COLOR_SPACE
      doc: This value indicates that the bitmap is in the system default color space, sRGB.
  # For BITMAPV5HEADER:
    0x4c494e4b: # 'LINK'
      id: profile_linked
      -orig-id: PROFILE_LINKED
      doc: |
        This value indicates that bV5ProfileData points to the file name of the profile
        to use (gamma and endpoints values are ignored).

        If a profile is linked, the path of the profile can be any fully qualified name
        (including a network path) that can be opened using the Win32 CreateFile function.
    0x4d424544: # 'MBED'
      id: profile_embedded
      -orig-id: PROFILE_EMBEDDED
      doc: |
        This value indicates that bV5ProfileData points to a memory buffer that contains
        the profile to be used (gamma and endpoints values are ignored).
  intent:
    # https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapv5header#members
    8:
      id: abs_colorimetric
      -orig-id: LCS_GM_ABS_COLORIMETRIC
      doc: Maintains the white point. Matches the colors to their nearest color in the destination gamut.
    1:
      id: business
      -orig-id: LCS_GM_BUSINESS
      doc: Maintains saturation. Used for business charts and other situations in which undithered colors are required.
    2:
      id: graphics
      -orig-id: LCS_GM_GRAPHICS
      doc: Maintains colorimetric match. Used for graphic designs and named colors.
    4:
      id: images
      -orig-id: LCS_GM_IMAGES
      doc: Maintains contrast. Used for photographs and natural images.

  header_type:
    # https://web.archive.org/web/20190527043845/https://forums.adobe.com/servlet/JiveServlet/showImage/2-3273299-47801/BMP_Headers.png
    12: bitmap_core_header
    40: bitmap_info_header
    52: bitmap_v2_info_header
    56: bitmap_v3_info_header
    64: os2_2x_bitmap_header
    108: bitmap_v4_header
    124: bitmap_v5_header
