meta:
  id: vp8_ivf
  title: VP8 raw file
  file-extension: ivf
  xref:
    wikidata: Q61774549
  license: CC0-1.0
  ks-version: 0.9
  endian: le
  bit-endian: le
doc: |
  IVF is a simple container format for raw VP8 data, which is an open
  and royalty-free video compression format, currently developed by
  Google.

  Test .ivf files are available at https://chromium.googlesource.com/webm/vp8-test-vectors
doc-ref: https://wiki.multimedia.cx/index.php/IVF
seq:
## header start
  - id: magic1
    contents: DKIF
    doc: Magic Number of IVF Files
  - id: version
    type: u2
    doc: This should be 0
  - id: len_header
    type: u2
    doc: Normally the header length is 32 byte
  - id: codec
    contents: VP80
    doc: Name of the codec e.g. 'VP80' for VP8
  - id: width
    type: u2
    doc: The (initial) width of the video, every keyframe may change the resolution
  - id: height
    type: u2
    doc: The (initial) height of the video, every keyframe may change the resolution
  - id: framerate
    type: u4
    doc: the (framerate * timescale) e.g. for 30 fps -> 30000
  - id: timescale
    type: u4
    doc: the timescale is a divider of the seconds (VPX is integer math only) mostly 1000
  - id: num_frames
    type: u4
    doc: the number of frames (if not a camera stream)
  - id: unused
    type: u4
## header end

## payload start
  - id: image_data
    type: frames
    repeat: expr
    repeat-expr: num_frames
## payload end

## type definitions
types:
  frames:
    seq:
      - id: entries
        type: frame
  frame:
    seq:
      - id: len_frame
        doc: size of the frame data
        type: u4
      - id: timestamp
        type: u8
      - id: is_interframe
        doc: A 1-bit frame type (0 for key frames, 1 for interframes).
        type: b1 
      - id: version_number
        doc: >
          A 3-bit version number (0 - 3 are defined as four different 
          profiles with different decoding complexity; other values may be 
          defined for future variants of the VP8 data format).
        type: b3
      - id: flag_show_frame
        doc: >
          A 1-bit show_frame flag (0 when current frame is not for display,
          1 when current frame is for display).
        type: b1
      - id: first_data_partition_size
        doc: >
          A 19-bit field containing the size of the first data partition in
          bytes.
        type: b19
      - id: keyframe_hdr
        type: keyframe_tag
        if: not is_interframe
      - id: compressed_keyframe
        size: len_frame - 10
        if: not is_interframe
      - id: compressed_interframe
        size: len_frame - 3
        if: is_interframe
  keyframe_tag:
    seq:
      - id: start_code
        type: b24
      - id: width
        type: b14
      - id: horizontal_scale
        type: b2
      - id: height
        type: b14
      - id: vertical_scale
        type: b2
        
