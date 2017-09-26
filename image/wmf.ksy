meta:
  id: wmf
  title: Windows Metafile (WMF) vector image
  file-extension: wmf
  xref:
    justsolve: Windows Metafile
    mime: image/wmf
    pronom: x-fmt/119
    wikidata: Q1072083
  license: CC0-1.0
  endian: le
doc: |
  WMF (Windows Metafile) is a relatively early vector image format
  introduced for Microsoft Windows in 1990.

  Inside, it provides a serialized list of Windows GDI (Graphics
  Device Interface) function calls, which, if played back, result in
  an image being drawn on a given surface (display, off-screen buffer,
  printer, etc).
doc-ref: http://www.digitalpreservation.gov/formats/digformatspecs/WindowsMetafileFormat(wmf)Specification.pdf
seq:
  - id: special_header
    type: special_header
  - id: header
    type: header
  - id: records
    type: record
    repeat: until
    repeat-until: _.function == func::eof
types:
  special_header:
    seq:
      - id: magic
        contents: [0xd7, 0xcd, 0xc6, 0x9a]
      - id: handle
        contents: [0, 0]
      - id: left
        type: s2
      - id: top
        type: s2
      - id: right
        type: s2
      - id: bottom
        type: s2
      - id: inch
        type: u2
      - id: reserved
        contents: [0, 0, 0, 0]
      - id: checksum
        type: u2
  header:
    seq:
      - id: metafile_type
        type: u2
        enum: metafile_type
      - id: header_size
        type: u2
      - id: version
        type: u2
      - id: size
        type: u4
      - id: number_of_objects
        type: u2
      - id: max_record
        type: u4
      - id: number_of_members
        type: u2
    enums:
      metafile_type:
        # section 2.1.20
        1: memory_metafile
        2: disk_metafile
  record:
    seq:
      - id: size
        type: u4
      - id: function
        type: u2
        enum: func
      - id: params
        size: (size - 3) * 2
        type:
          switch-on: function
          cases:
            'func::polyline': params_polyline
            'func::polygon': params_polygon
            'func::setbkcolor': color_ref
            'func::setbkmode': params_setbkmode
            'func::setpolyfillmode': params_setpolyfillmode
            #'func::params_setrelabs': reserved
            'func::setrop2': params_setrop2
            'func::setwindowext': params_setwindowext
            'func::setwindoworg': params_setwindoworg
  # section 2.3.3.14
  params_polyline:
    seq:
      - id: num_points
        type: s2
      - id: points
        repeat: expr
        repeat-expr: num_points
        type: point_s
  # section 2.3.3.15 = params_polyline
  params_polygon:
    seq:
      - id: num_points
        type: s2
      - id: points
        repeat: expr
        repeat-expr: num_points
        type: point_s
  # section 2.3.5.14
  #params_setbkcolor:
  #  seq:
  #    - id: color_ref
  #      type: color_ref
  # section 2.3.5.15
  params_setbkmode:
    seq:
      - id: bk_mode
        type: u2
        enum: mix_mode
        doc: Defines current graphic context background mix mode.
  # section 2.3.5.20
  params_setpolyfillmode:
    seq:
      - id: poly_fill_mode
        type: u2
        enum: poly_fill_mode
        doc: Defines current polygon fill mode.
  # section 2.3.5.22
  params_setrop2:
    seq:
      - id: draw_mode
        type: u2
        enum: bin_raster_op
        doc: Defines current foreground binary raster operation mixing mode.
  # section 2.3.5.30
  params_setwindowext:
    seq:
      - id: y
        type: s2
        doc: Vertical extent of the window in logical units.
      - id: x
        type: s2
        doc: Horizontal extent of the window in logical units.
  # section 2.3.5.31
  params_setwindoworg:
    seq:
      - id: y
        type: s2
        doc: Y coordinate of the window origin, in logical units.
      - id: x
        type: s2
        doc: X coordinate of the window origin, in logical units.
  # section 2.2.1.7
  color_ref:
    seq:
      - id: red
        type: u1
      - id: green
        type: u1
      - id: blue
        type: u1
      - id: reserved
        type: u1
  # section 2.2.1.12
  point_s:
    seq:
      - id: x
        type: s2
        doc: X coordinate of the point, in logical units.
      - id: y
        type: s2
        doc: Y coordinate of the point, in logical units.
enums:
  func:
    0x0000: eof
    0x0035: realizepalette
    0x0037: setpalentries
    0x0102: setbkmode
    0x0103: setmapmode
    0x0104: setrop2
    0x0105: setrelabs
    0x0106: setpolyfillmode
    0x0107: setstretchbltmode
    0x0108: settextcharextra
    0x0127: restoredc
    0x0139: resizepalette
    0x0142: dibcreatepatternbrush
    0x0149: setlayout
    0x0201: setbkcolor
    0x0209: settextcolor
    0x0211: offsetviewportorg
    0x0213: lineto
    0x0214: moveto
    0x0220: offsetcliprgn
    0x0228: fillregion
    0x0231: setmapperflags
    0x0234: selectpalette
    0x0324: polygon
    0x0325: polyline
    0x020a: settextjustification
    0x020b: setwindoworg
    0x020c: setwindowext
    0x020d: setviewportorg
    0x020e: setviewportext
    0x020f: offsetwindoworg
    0x0410: scalewindowext
    0x0412: scaleviewportext
    0x0415: excludecliprect
    0x0416: intersectcliprect
    0x0418: ellipse
    0x0419: floodfill
    0x0429: frameregion
    0x0436: animatepalette
    0x0521: textout
    0x0538: polypolygon
    0x0548: extfloodfill
    0x041b: rectangle
    0x041f: setpixel
    0x061c: roundrect
    0x061d: patblt
    0x001e: savedc
    0x081a: pie
    0x0b23: stretchblt
    0x0626: escape
    0x012a: invertregion
    0x012b: paintregion
    0x012c: selectclipregion
    0x012d: selectobject
    0x012e: settextalign
    0x0817: arc
    0x0830: chord
    0x0922: bitblt
    0x0a32: exttextout
    0x0d33: setdibtodev
    0x0940: dibbitblt
    0x0b41: dibstretchblt
    0x0f43: stretchdib
    0x01f0: deleteobject
    0x00f7: createpalette
    0x01f9: createpatternbrush
    0x02fa: createpenindirect
    0x02fb: createfontindirect
    0x02fc: createbrushindirect
    0x06ff: createregion
  # section 2.1.2
  bin_raster_op:
    0x0001: black
    0x0002: notmergepen
    0x0003: masknotpen
    0x0004: notcopypen
    0x0005: maskpennot
    0x0006: not
    0x0007: xorpen
    0x0008: notmaskpen
    0x0009: maskpen
    0x000a: notxorpen
    0x000b: nop
    0x000c: mergenotpen
    0x000d: copypen
    0x000e: mergepennot
    0x000f: mergepen
    0x0010: white
  # section 2.1.22
  mix_mode:
    0x0001: transparent
    0x0002: opaque
  # section 2.1.27
  poly_fill_mode:
    0x0001: alternate
    0x0002: winding
