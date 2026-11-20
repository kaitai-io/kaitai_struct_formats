meta:
  id: rv565
  title: RV565 video for microcontroller displays
  application: RV565 (https://github.com/elixpo/rv565)
  file-extension: rv565
  xref:
    mime: video/x-rv565
  license: CC0-1.0
  ks-version: '0.11'
  endian: le
doc: |
  RV565 is a video container for microcontrollers that drive small
  displays. Frames are stored in the display's pixel format, so a player
  only decompresses and transfers them. There is no audio. The file ends
  exactly after the last frame record.

  Version 6: a 12-byte header, then one record per frame: a 32-bit length
  and a zlib stream (RFC 1950) that inflates to exactly width * height * 2
  bytes of big-endian RGB565 pixels. Every frame is a keyframe.

  Version 7: the header adds its own size, a pixel format, a codec (stored
  or zlib) and a keyframe interval K. Each record starts with a frame type:
  a keyframe (the frame), a delta (the frame XOR the previous frame), a
  repeat (no body, the previous frame again) or a partial delta (only the
  bands of lines that changed, each a residual against the previous frame's
  band shifted by a few bytes and lines). Bodies of keyframes and deltas,
  and the residuals of partial deltas, are the bytes as they are or a zlib
  stream of them. Every frame i with i mod K = 0 is a keyframe.
doc-ref:
  - https://github.com/elixpo/rv565/blob/main/docs/FORMAT.md
  - https://arxiv.org/abs/2610.35935
seq:
  - id: magic
    contents: RV5
  - id: version
    type: u1
    valid:
      any-of: [6, 7, 8]
  - id: width
    type: u2
    valid:
      min: 1
  - id: height
    type: u2
    valid:
      min: 1
  - id: fps
    type: u1
    valid:
      min: 1
      max: 60
    doc: Frames per second, 1-30 in version 6 and 1-60 in versions 7 and 8.
  - id: flags
    type: u1
    doc: None defined; writers write 0 and readers ignore unknown bits.
  - id: num_frames
    type: u2
    valid:
      min: 1
  - id: header_v7
    type: header_v7
    if: version >= 7
  - id: frames
    type: frame
    repeat: expr
    repeat-expr: num_frames
instances:
  pixel_format:
    value: 'version >= 7 ? header_v7.pixel_format : pixel_format::rgb565be'
  codec:
    value: 'version >= 7 ? header_v7.codec : codec::zlib'
  keyframe_interval:
    value: 'version >= 7 ? header_v7.keyframe_interval : 1'
  lines:
    value: 'pixel_format == pixel_format::mono_vpage ? (height + 7) / 8 : height'
    doc: |
      Lines of a frame, the unit of partial delta bands: pixel rows, or
      pages of 8 rows for mono_vpage.
types:
  header_v7:
    seq:
      - id: len_header
        type: u1
        valid:
          min: 16
        doc: Size of the whole header; writers of version 7 write 16.
      - id: pixel_format
        type: u1
        enum: pixel_format
        valid:
          in-enum: true
      - id: codec
        type: u1
        enum: codec
        valid:
          in-enum: true
      - id: keyframe_interval
        type: u1
        valid:
          min: 1
      - id: extension
        size: len_header - 16
        doc: Fields of later minor revisions; readers skip them.
  frame:
    seq:
      - id: len_record
        type: u4
        valid:
          min: 1
        doc: Bytes that follow, the frame type included in versions 7 and 8.
      - id: frame_type
        type: u1
        enum: frame_type
        valid:
          in-enum: true
        if: _root.version >= 7
      - id: body_zlib
        size: len_body
        process: zlib
        if: _root.codec == codec::zlib and kind != frame_type::partial and kind != frame_type::region and len_body > 0
        doc: |
          Inflated: exactly the frame size of the pixel format, the frame
          (keyframe) or its XOR with the previous frame (delta).
      - id: body_stored
        size: len_body
        if: _root.codec == codec::stored and kind != frame_type::partial and kind != frame_type::region
        doc: The frame, or its XOR with the previous frame; empty for a repeat.
      - id: body_partial
        size: len_body
        type: partial_delta
        if: kind == frame_type::partial
      - id: body_region
        size: len_body
        type: region_delta
        if: kind == frame_type::region
    instances:
      len_body:
        value: '_root.version >= 7 ? len_record - 1 : len_record'
      kind:
        value: '_root.version >= 7 ? frame_type : frame_type::key'
        doc: The frame type; every version 6 frame is a keyframe.
  partial_delta:
    doc: |
      The frame is _root.lines lines of R bytes, divided into bands of
      band_height lines (the last may be shorter). Byte j of line y of a
      changed band is predicted from byte j - dx of line y - dy of the
      previous frame when that line is in the same band and 0 <= j - dx < R,
      and is 0 otherwise; the band is its prediction XOR its residual. Bands
      not in the mask are unchanged.
    meta:
      bit-endian: le
    seq:
      - id: band_height
        type: u1
        valid:
          min: 1
      - id: mask
        type: b1
        repeat: expr
        repeat-expr: num_bands
        doc: |
          One bit per band, least significant bit first; at least one is
          set. The padding bits of the last byte are zero.
      - id: shifts
        type: band_shift(mask[_index], band_height)
        repeat: expr
        repeat-expr: num_bands
        doc: A shift for each changed band, in band order.
      - id: residuals_zlib
        size-eos: true
        process: zlib
        if: _root.codec == codec::zlib
        doc: Inflated, the residuals of the changed bands, concatenated.
      - id: residuals_stored
        size-eos: true
        if: _root.codec == codec::stored
        doc: The residuals of the changed bands, concatenated.
    instances:
      num_bands:
        value: (_root.lines + band_height - 1) / band_height
  region_delta:
    doc: |
      Version 8. Like a partial delta, but each changed band also gives the
      range of bytes along its lines that changed (x0 to x0 + xw - 1), and
      only that range has a residual: the prediction (as for a partial
      delta, from the whole line) XOR the residual. Outside the range, and
      in unchanged bands, the frame equals the previous one. A range starts
      and ends on whole pixels (a multiple of 2 bytes for rgb565*, 3 for
      rgb444, rgb666 and rgb888, 1 otherwise), or ends at the end of the line.
    meta:
      bit-endian: le
    seq:
      - id: band_height
        type: u1
        valid:
          min: 1
      - id: mask
        type: b1
        repeat: expr
        repeat-expr: num_bands
        doc: One bit per band, as in a partial delta.
      - id: entries
        type: band_region(mask[_index], band_height)
        repeat: expr
        repeat-expr: num_bands
        doc: A shift and a range for each changed band, in band order.
      - id: residuals_zlib
        size-eos: true
        process: zlib
        if: _root.codec == codec::zlib
        doc: Inflated, the residuals of the changed bands' ranges, line by line, concatenated.
      - id: residuals_stored
        size-eos: true
        if: _root.codec == codec::stored
        doc: The residuals of the changed bands' ranges, line by line, concatenated.
    instances:
      num_bands:
        value: (_root.lines + band_height - 1) / band_height
  band_region:
    params:
      - id: changed
        type: bool
      - id: band_height
        type: u1
    seq:
      - id: dx
        type: s1
        if: changed
        doc: Shift along the line, in bytes.
      - id: dy
        type: s1
        if: changed
        valid:
          expr: _ > -band_height and _ < band_height
        doc: Shift across lines, less than the band height either way.
      - id: x0
        type: u2le
        if: changed
        doc: First byte of the range along each line.
      - id: xw
        type: u2le
        if: changed
        valid:
          min: 1
        doc: Bytes in the range.
  band_shift:
    params:
      - id: changed
        type: bool
      - id: band_height
        type: u1
    seq:
      - id: dx
        type: s1
        if: changed
        doc: Shift along the line, in bytes.
      - id: dy
        type: s1
        if: changed
        valid:
          expr: _ > -band_height and _ < band_height
        doc: Shift across lines, less than the band height either way.
enums:
  pixel_format:
    0:
      id: rgb565be
      doc: 2 bytes per pixel, (r5 << 11) | (g6 << 5) | b5, high byte first.
    1:
      id: rgb565le
      doc: The same value, low byte first.
    2:
      id: rgb444
      doc: 12-bit pixels packed high nibble first, rows of ceil(3w / 2) bytes.
    3:
      id: rgb666
      doc: Bytes R, G, B, each channel in the high 6 bits.
    4:
      id: rgb888
      doc: Bytes R, G, B.
    5:
      id: gray8
      doc: One byte per pixel, 0 black, 255 white.
    6:
      id: gray4
      doc: Two pixels per byte, high nibble first, rows of ceil(w / 2) bytes.
    7:
      id: mono
      doc: One bit per pixel, most significant first, 1 lit; rows of ceil(w / 8) bytes.
    8:
      id: mono_vpage
      doc: |
        Pages of 8 rows, each w bytes left to right; bit k (least
        significant first) of a byte is row 8p + k.
  codec:
    0: stored
    1: zlib
  frame_type:
    0: key
    1: delta
    2: repeat
    3: partial
    4:
      id: region
      doc: Version 8 only.
