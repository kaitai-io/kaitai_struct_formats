meta:
  id: mp4
  file-extension: mp4
  endian: be
  license: CC0-1.0
  encoding: ascii
  
#
# The container is a tree-like structure of boxes.
# There are various types of boxes. Boxes of some types can contain nested boxes.
# You can find some interesting information in those boxes:
#
# -> moov -> mvhd -> duration / timescale    :: this is how you calculate media length in seconds
# -> moov -> trak                            :: those are tracks in the container (video/audio/etc.)
# trak -> tkhd -> @width x @height           :: resolution of the video track
# trak -> mdia -> minf -> stbl -> stsd.entries[0].type :: fourcc of codec used for the track
# trak -> mdia -> mdhd -> langCode           :: language code of the track
#
# trak -> mdia -> stb -> stts                :: table to get sample index for given time
# trak -> mdia -> stb -> stsc                :: table to get chunk index for given time
# trak -> mdia -> stb -> stco                :: table to get offset in file for given chunk index
#
# See also:
# * http://mp4parser.com/
# * https://archive.codeplex.com/?p=mp4explorer
# * https://github.com/axiomatic-systems/Bento4

seq:
  - id: boxes
    type: box
    repeat: eos

types:

  boxes:
    seq:
      - id: boxes
        type: box
        repeat: eos

  box:
    seq:
      - id: size
        type: u4
      - id: type
        type: str
        size: 4
      - id: largesize
        type: u8
        if: size == 1
      - id: body
        type:
          switch-on: type
          cases:
            '"moov"': boxes
            '"trak"': boxes
            '"edts"': boxes
            '"mdia"': boxes
            '"stbl"': boxes
            '"minf"': boxes
            '"dinf"': boxes
            '"ftyp"': box_body_ftyp
            '"hdlr"': box_body_hdlr
            '"mvhd"': box_body_mvhd
            '"vmhd"': box_body_vmhd
            '"mdhd"': box_body_mdhd
            '"tkhd"': box_body_tkhd
            '"elst"': box_body_elst
            '"stsc"': box_body_stsc
            '"stsd"': box_body_stsd
            '"stco"': box_body_stco
            '"stts"': box_body_stts
            '"co64"': box_body_co64
            _: box_body_other
        size: '(size == 1) ? size - 12 : size - 8'

  # -----------
  # -- FTYP  --
  # -----------
  box_body_ftyp:
    seq:
      - id: major_brand
        type: str
        size: 4
      - id: minor_version
        type: str
        size: 4
      - id: compatible_brands
        type: str
        size: 4
        repeat: eos
#        size-eos: true

  # -----------
  # -- MVHD  --
  # -----------
  box_body_mvhd:
    seq:
      - id: version
        type: u4

      - id: creation_time
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: modification_time
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: timescale
        doc: |
          Timescale is an integer that specifies the time-scale for the entire presentation; this is the number of time units that pass in one second.
          For example, a time coordinate system that measures timein sixtieths of a second has a time scale of 60.
        type: u4
      - id: duration
        doc: |
          duration is an integer that declares length of the presentation (in the indicated timescale).
          This property is derived from the presentation's tracks: the value of this field corresponds to the duration of the 
          longest track in the presentation. If the duration cannot be determined then duration is set to all 1s.
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: rate
        doc: Rate is a fixed point 16.16 number that indicates the preferred rate to play the presentation; 1.0 (0x00010000) is normal forward playback
        type: u4
      - id: volume
        doc: Volume is a fixed point 8.8 number that indicates the preferred playback volume; 1.0 (0x0100) is full volume
        type: u2
      - id: reserved
        type: u2
        repeat: expr
        repeat-expr: 5
      - id: matrix
        type: u4
        repeat: expr
        repeat-expr: 9
      - id: predefined
        type: u4
        repeat: expr
        repeat-expr: 6
      - id: next_track_id
        type: u4

# ------------
# --  TKHD  --
# ------------
  box_body_tkhd:
    seq:
      - id: version
        type: u4

      - id: creation_time
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: modification_time
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: track_id
        type: u4
      - id: reserved
        type: u4
      - id: duration
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: reserved1
        repeat: expr
        type: u4
        repeat-expr: 2
      - id: layer
        type: u2
      - id: alternate_group
        type: u2
      - id: volume
        type: u2
      - id: matrix
        type: u4
        repeat: expr
        repeat-expr: 9
      - id: width
        type: u4
      - id: height
        type: u4


# -----------
# -- ELST --
# -----------
  box_body_elst:
    seq:
      - id: version
        type: u4
      - id: entry_count
        type: u4
      - id: entries
        type: box_body_elst_entry
        repeat: expr
        repeat-expr: entry_count

  box_body_elst_entry:
    seq:
      - id: segment_duration
        type:
          switch-on: _parent.version
          cases:
            1: s8
            _: s4
      - id: media_time
        type:
          switch-on: _parent.version
          cases:
            1: s8
            _: s4
      - id: media_rate_integer
        type: u2
      - id: media_rate_fraction
        type: u2
        
# -----------
# -- MDHD --
# -----------
  box_body_mdhd:
    seq:
      - id: version
        type: u4

      - id: creation_time
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: modification_time
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: timescale
        type: u4
      - id: duration
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: lang_code #TODO: decode (or describe how to decode)
        type: u2
      - id: predefined
        type: u2

        
# -----------
# -- HDLR --
# -----------
  box_body_hdlr:
    seq:
      - id: predefined
        type: u4
      - id: reserved0
        type: u4
      - id: reserved1
        type: u4
      - id: reserved2
        type: u4

# -----------
# -- VMHD --
# -----------
  box_body_vmhd:
    seq:
      - id: unknown
        type: u4
      - id: graphics_mode
        type: u2
      - id: reserved0
        type: u2
      - id: reserved1
        type: u2
      - id: reserved2
        type: u2
        
# ----------
# -- STSC --
# ----------
  box_body_stsc:
    seq:
      - id: version
        type: u4
      - id: entry_count
        type: u4
      - id: entries
        type: box_body_stsc_entry
        repeat: expr
        repeat-expr: entry_count
        
  box_body_stsc_entry:
    seq:
      - id: first_chunk
        type: u4
      - id: samples_per_chunk
        type: u4
      - id: sample_description_index
        type: u4

        
# ----------
# -- STTS --
# ----------
  box_body_stts:
    seq:
      - id: version
        type: u4
      - id: entry_count
        type: u4
      - id: entries
        type: box_body_stts_entry
        repeat: expr
        repeat-expr: entry_count
        
  box_body_stts_entry:
    seq:
      - id: sample_count
        type: u4
      - id: sample_delta
        type: u4

# ----------
# -- STCO --
# ----------
  box_body_stco:
    seq:
      - id: version
        type: u4
      - id: entry_count
        type: u4
      - id: chunk_offsets
        type: u4
        repeat: expr
        repeat-expr: entry_count

# ----------
# -- CO64 --
# ----------
  box_body_co64:
    seq:
      - id: version
        type: u4
      - id: entry_count
        type: u4
      - id: chunk_offsets
        type: u8
        repeat: expr
        repeat-expr: entry_count

# -----------
# -- STSD --
# -----------
  box_body_stsd:
    seq:
      - id: version
        type: u4
      - id: entry_count
        type: u4
      - id: entries
        type: box_body_stsd_entry
        repeat: expr
        repeat-expr: entry_count
        
  box_body_stsd_entry:
    seq:
      - id: size
        type: u4
      - id: type
        type: str
        size: 4
      - id: reserved
        type: u1
        repeat: expr
        repeat-expr: 6
      - id: data_reference_index
        type: u2

# -------------
# -- (other) --
# -------------
  box_body_other:
    seq:
      - id: blob
        type: u1
        repeat: eos



