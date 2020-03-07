meta:
  id: mp4
  file-extension: mp4
  endian: be
  license: CC0-1.0
  encoding: ascii
  
# MP4 file format is based on ISO/IEC 14496-12:2015 (just like QuickTime MOV).
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
# trak -> mdia -> stb -> stsc                :: table to get chunk index for given sample index
# trak -> mdia -> stb -> stco                :: table to get offset in file for given chunk index
#
# See also:
# * https://standards.iso.org/ittf/PubliclyAvailableStandards/c068960_ISO_IEC_14496-12_2015.zip
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
          cases: # box types in alphabetical order
            '"co64"': box_body_co64
            '"dinf"': boxes
            '"dref"': box_body_dref   # Data Reference Box
            '"edts"': boxes
            '"elst"': box_body_elst
            '"ftyp"': box_body_ftyp
            '"hdlr"': box_body_hdlr
            '"mdia"': boxes
            '"mdhd"': box_body_mdhd
            '"minf"': boxes
            '"moov"': boxes
            '"mvhd"': box_body_mvhd
            '"smhd"': box_body_smhd   # Sound Media Header
            '"stbl"': boxes
            '"stco"': box_body_stco
            '"stsc"': box_body_stsc
            '"stsd"': box_body_stsd
            '"stts"': box_body_stts
            '"stss"': box_body_stss   # Sync Sample Box
            '"stsz"': box_body_stsz   # Sample Size Box
            '"stz2"': box_body_stz2   # Compact Sample Size Box
            '"tkhd"': box_body_tkhd
            '"trak"': boxes
            #'"udta"': box_body_udta   # User Data Box <-- not standardized
            '"vmhd"': box_body_vmhd
        size: 'size == 0 ? (_io.size - 8) : (size == 1 ? largesize - 16 : size - 8)'

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
          Number of time units in one second; specifies in which units the time is measured.
        type: u4
      - id: duration
        doc: |
          Number of time units in the entire media.
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: rate
        doc: |
          Two numbers specifying playbeck speed; normal speed (1.0) is [1, 0]
        type: u2
        repeat: expr
        repeat-expr: 2
      - id: volume
        doc: |
          Two numbers specifying playbeck volume; normal volume (1.0) is [1, 0]
        type: u1
        repeat: expr
        repeat-expr: 2
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
        type: entry
        repeat: expr
        repeat-expr: entry_count
        
    types:
      entry:
        seq:
          - id: size
            type: u4
          - id: type
            type: str
            size: 4
          - id: body
            type: entry_body
            size: 'size - 8'
      entry_body:
        seq:
          - id: reserved
            type: u1
            repeat: expr
            repeat-expr: 6
          - id: data_reference_index
            type: u2

# ----------
# -- STSS --
# ----------
  box_body_stss:
    seq:
      - id: version
        type: u4
      - id: entry_count
        type: u4
      - id: sample_numbers
        type: s4
        repeat: expr
        repeat-expr: entry_count

# ----------
# -- STSZ --
# ----------
  box_body_stsz:
    seq:
      - id: version
        type: u4
      - id: sample_size
        type: u4
      - id: sample_count
        type: u4
      - id: entry_sizes
        if: (sample_size==0)
        repeat: expr
        repeat-expr: sample_count
        type: u4

# ----------
# -- STZ2 --
# ----------
  box_body_stz2:  # <----- NOT TESTED!
    seq:
      - id: version
        type: u4
      - id: reserved
        type: u1
        repeat: expr
        repeat-expr: 3
      - id: field_size
        type: u1
      - id: sample_count
        type: u4
      - id: entry_sizes
        repeat: expr
        repeat-expr: '(field_size == 4) ? (sample_count/2) : sample_count'
        type:
          switch-on: field_size
          cases:
            4:  u1   # 4 bits
            8:  u1   # 8 bits
            16: u2   # 16 bits

# ----------
# -- SMHD --
# ----------
  box_body_smhd:
    seq:
      - id: version
        type: u4
      - id: balance
        type: s2
      - id: reserved
        type: u2

# ----------
# -- DREF --
# ----------
  box_body_dref:
    seq:
      - id: version
        type: u4
      - id: entry_count
        type: u4
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: entry_count
        
    types:
      entry:
        seq:
          - id: size
            type: u4
          - id: type
            type: str
            size: 4
          - id: data_entry
            type: entry_body
            size: 'size - 8'
      entry_body:
        seq:
          - id: flags
            type: u1
            repeat: expr
            repeat-expr: 3
          - id: name
            type: str
            terminator: 0
            if: _parent.type == 'urn '
          - id: location
            type: str
            doc: |
              This field is probably incorrect sometimes (GDCL muxer seems to have a bug here)
            terminator: 0
            eos-error: false            
            
            
        





