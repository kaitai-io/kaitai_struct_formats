meta:
  id: vp8_ivf
  title: VP8 raw file
  file-extension: ivf
  xref:
    wikidata: Q61774549
  license: CC0-1.0
  ks-version: 0.7
  endian: le
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
    type: blocks
    repeat: expr
    repeat-expr: num_frames
## payload end

## type definitions
types:
  blocks:
    seq:
      - id: entries
        type: block
  block:
    seq:
      - id: len_frame
        doc: size of the frame data
        type: u4
      - id: timestamp
        type: u8
      - id: framedata
        size: len_frame
