meta:
  id: swbf_ucfb
  title: Star Wars Battlefront munged data (ucfb chunk tree)
  application:
    - 'Star Wars: Battlefront (2004)'
    - 'Star Wars: Battlefront II (2005)'
  file-extension:
    - lvl
    - mvs
    - bnk
  license: CC0-1.0
  endian: le
doc: |
  Munged game data of Pandemic Studios' Zero engine, as used by the PC versions
  of Star Wars: Battlefront (2004) and Star Wars: Battlefront II (2005): the
  `.lvl` archives, the `.mvs` movie archives and the `common.bnk` sound bank.

  A file is one `ucfb` chunk holding a tree of chunks. A chunk is a four-byte
  tag, a little-endian size and a body; the next chunk starts at the next
  4-byte boundary, and zero words may sit between chunks. Most tags are four
  ASCII characters. In the sound and movie archives most tags are 32-bit
  FNV-1a hashes of names instead, with each byte ORed with 0x20 before it is
  hashed (so "Info" becomes 0x0fb40705).

  This spec splits the tree into chunks, descends into the tags known to hold
  chunks, and leaves every other body as raw bytes. Which tags hold chunks was
  measured on every `.lvl` file of the 2004 game's PC release: `INFO` holds
  chunks only under `BARR`, `inst`, `Hint` and `regn`, and `DATA` only under
  `CSHD`. A `lvl_` sub-level starts with its name hash and the size of the
  chunks that follow.

  Sample files: any `.lvl` under `GameData/Data/_LVL_PC` in the Steam or GOG
  release of Star Wars: Battlefront (2004), plus `Movies/shell.mvs` and
  `Sound/common.bnk`.
doc-ref:
  - https://github.com/centrevilletech/battlefront-eternal/blob/19ea2b38c9943ee93309a500cc1024e094374853/docs/formats.md
  - https://github.com/PrismaticFlower/swbf-unmunge
seq:
  - id: magic
    contents: ucfb
  - id: len_body
    type: u4
  - id: body
    type: chunk_list(tag::ucfb.to_i)
    size: len_body
types:
  chunk_list:
    params:
      - id: parent_tag
        type: u4
        doc: Raw tag of the chunk holding this list.
    seq:
      - id: chunks
        type: chunk(parent_tag)
        repeat: eos
  chunk:
    params:
      - id: parent_tag
        type: u4
    seq:
      - id: tag
        type: u4
        enum: tag
      - id: len_body
        type: u4
        if: tag != tag::zero_word
      - id: body
        size: len_body
        if: tag != tag::zero_word
        type:
          switch-on: body_kind
          cases:
            1: chunk_list(tag.to_i)
            2: sub_level
      - id: padding
        size: len_padding
        if: tag != tag::zero_word
    instances:
      len_padding:
        value: '(4 - len_body % 4) % 4 > _io.size - _io.pos ? _io.size - _io.pos : (4 - len_body % 4) % 4'
      body_kind:
        value: 'tag == tag::lvl ? 2 : (is_container ? 1 : 0)'
      is_container:
        value: >-
          tag == tag::ucfb
          or tag == tag::lvl_upper
          or tag == tag::fmt
          or tag == tag::face
          or tag == tag::tex
          or tag == tag::modl
          or tag == tag::segm
          or tag == tag::skel
          or tag == tag::gmod
          or tag == tag::shdw
          or tag == tag::gshd
          or tag == tag::cshd
          or tag == tag::zaa
          or tag == tag::zaf
          or tag == tag::ffaz
          or tag == tag::sltm
          or tag == tag::stsj
          or tag == tag::snks
          or tag == tag::leks
          or tag == tag::entc
          or tag == tag::wpnc
          or tag == tag::ordc
          or tag == tag::expc
          or tag == tag::fx
          or tag == tag::coll
          or tag == tag::tree
          or tag == tag::prim
          or tag == tag::tern
          or tag == tag::pchs
          or tag == tag::ptch
          or tag == tag::lptc
          or tag == tag::watr
          or tag == tag::cuts
          or tag == tag::cutr
          or tag == tag::prp
          or tag == tag::wrld
          or tag == tag::inst
          or tag == tag::regn
          or tag == tag::barr
          or tag == tag::hint
          or tag == tag::path_upper
          or tag == tag::path
          or tag == tag::plan
          or tag == tag::lowr
          or tag == tag::comn
          or tag == tag::stat
          or tag == tag::pass
          or tag == tag::shdr
          or tag == tag::pipe
          or tag == tag::vsp
          or tag == tag::psp
          or tag == tag::sky
          or tag == tag::bnd
          or tag == tag::load
          or tag == tag::mcfg
          or tag == tag::snd
          or tag == tag::mus
          or tag == tag::ffx
          or tag == tag::scop
          or tag == tag::scr
          or tag == tag::locl
          or tag == tag::font
          or tag == tag::ftex
          or tag == tag::stream_list
          or tag == tag::stream
          or tag == tag::sound_bank_list
          or tag == tag::sample_bank
          or (tag == tag::info and (parent_tag == tag::barr.to_i or parent_tag == tag::inst.to_i or parent_tag == tag::hint.to_i or parent_tag == tag::regn.to_i))
          or (tag == tag::data and parent_tag == tag::cshd.to_i)
  sub_level:
    seq:
      - id: name_hash
        type: u4
        doc: FNV-1a hash of the sub-level's name.
      - id: len_chunks
        type: u4
      - id: chunks
        type: chunk_list(tag::lvl.to_i)
        size-eos: true
enums:
  tag:
    0:
      id: zero_word
      doc: A zero word between chunks.
    0x0fb40705:
      id: hashed_info
      doc: 'Info (FNV-1a hash tag): (name hash, u32) pairs.'
    0x30444f4c:
      id: lod0
      doc: "'LOD0'."
    0x41544144:
      id: data
      doc: "'DATA'. A config value: a name hash and its values. Holds chunks under CSHD."
    0x4354504c:
      id: lptc
      doc: "'LPTC'."
    0x44485343:
      id: cshd
      doc: "'CSHD'."
    0x44485347:
      id: gshd
      doc: "'GSHD'."
    0x45434146:
      id: face
      doc: "'FACE'. One face of a texture format."
    0x45444f4e:
      id: node
      doc: "'NODE'."
    0x45455254:
      id: tree
      doc: "'TREE'."
    0x454d414e:
      id: name
      doc: "'NAME'. Name, a C string."
    0x45504950:
      id: pipe
      doc: "'PIPE'."
    0x45505954:
      id: type
      doc: "'TYPE'."
    0x45534142:
      id: base
      doc: "'BASE'."
    0x455a4953:
      id: size
      doc: "'SIZE'."
    0x4641454c:
      id: leaf
      doc: "'LEAF'."
    0x46554249:
      id: ibuf
      doc: "'IBUF'. Index buffer."
    0x46554256:
      id: vbuf
      doc: "'VBUF'. Vertex buffer."
    0x47414c46:
      id: flag
      doc: "'FLAG'."
    0x48435450:
      id: ptch
      doc: "'PTCH'."
    0x48544150:
      id: path_upper
      doc: "'PATH'. A world's paths."
    0x4a535453:
      id: stsj
      doc: "'STSJ'."
    0x4c52544d:
      id: mtrl
      doc: "'MTRL'. Material."
    0x4d414e42:
      id: bnam
      doc: "'BNAM'. Bone name."
    0x4d414e54:
      id: tnam
      doc: "'TNAM'. Texture name."
    0x4d524658:
      id: xfrm
      doc: "'XFRM'. Transform."
    0x4d544c53:
      id: sltm
      doc: "'SLTM'."
    0x4e4d4f43:
      id: comn
      doc: "'COMN'."
    0x4f464e49:
      id: info
      doc: "'INFO'. Header fields. Holds chunks under BARR, inst, Hint and regn."
    0x504f4353:
      id: scop
      doc: "'SCOP'. Scope in a config tree: holds DATA and SCOP chunks."
    0x504f5250:
      id: prop
      doc: "'PROP'."
    0x50595452:
      id: rtyp
      doc: "'RTYP'."
    0x52444853:
      id: shdr
      doc: "'SHDR'."
    0x52485053:
      id: sphr
      doc: "'SPHR'."
    0x52524142:
      id: barr
      doc: "'BARR'."
    0x52544157:
      id: watr
      doc: "'WATR'. Terrain water."
    0x52545543:
      id: cutr
      doc: "'CUTR'."
    0x52574f4c:
      id: lowr
      doc: "'LOWR'."
    0x53484350:
      id: pchs
      doc: "'PCHS'."
    0x534b454c:
      id: leks
      doc: "'LEKS'."
    0x534b4e53:
      id: snks
      doc: "'SNKS'."
    0x53534150:
      id: pass
      doc: "'PASS'."
    0x53545543:
      id: cuts
      doc: "'CUTS'."
    0x54415043:
      id: cpat
      doc: "'CPAT'."
    0x54415453:
      id: stat
      doc: "'STAT'."
    0x544e5250:
      id: prnt
      doc: "'PRNT'. Parent names."
    0x58455446:
      id: ftex
      doc: "'FTEX'."
    0x59444f42:
      id: body
      doc: "'BODY'."
    0x5a414646:
      id: ffaz
      doc: "'FFAZ'."
    0x5bb97f21:
      id: stream_list
      doc: 'StreamList (FNV-1a hash tag): one sound stream.'
    0x5e262256:
      id: sound_bank_list
      doc: 'SoundBankList (FNV-1a hash tag).'
    0x5f4c564c:
      id: lvl_upper
      doc: "'LVL_'. One mip level of a texture face."
    0x5f4e4942:
      id: bin
      doc: "'BIN_'."
    0x5f505350:
      id: psp
      doc: "'PSP_'."
    0x5f505356:
      id: vsp
      doc: "'VSP_'."
    0x5f544d46:
      id: fmt
      doc: "'FMT_'. One format of a texture."
    0x5f5f7866:
      id: fx
      doc: "'fx__'. Effect (config tree)."
    0x5f61617a:
      id: zaa
      doc: "'zaa_'. Animation bank."
    0x5f646e62:
      id: bnd
      doc: "'bnd_'. Boundary (config tree)."
    0x5f646e73:
      id: snd
      doc: "'snd_'. Sound config (config tree)."
    0x5f66617a:
      id: zaf
      doc: "'zaf_'. Animation skeleton for a bank."
    0x5f6c766c:
      id: lvl
      doc: "'lvl_'. Sub-level: a name hash, a size, then its chunks."
    0x5f6f6d65:
      id: stream
      doc: 'Stream (FNV-1a hash tag): Info and Data of a sound stream.'
    0x5f707270:
      id: prp
      doc: "'prp_'. Foliage props (config tree)."
    0x5f726373:
      id: scr
      doc: "'scr_'. Script: NAME, INFO and BODY (Lua 4.0 bytecode)."
    0x5f73756d:
      id: mus
      doc: "'mus_'. Music config (config tree)."
    0x5f786574:
      id: tex
      doc: "'tex_'. Texture."
    0x5f786666:
      id: ffx
      doc: "'ffx_'. Foley config (config tree)."
    0x5f796b73:
      id: sky
      doc: "'sky_'. Sky settings (config tree)."
    0x62666375:
      id: ucfb
      doc: "'ucfb'. Root of every file, and of some nested trees."
    0x6364726f:
      id: ordc
      doc: "'ordc'. Ordnance class."
    0x636e7077:
      id: wpnc
      doc: "'wpnc'. Weapon class."
    0x63707865:
      id: expc
      doc: "'expc'. Explosion class."
    0x63746e65:
      id: entc
      doc: "'entc'. Entity class."
    0x64616f6c:
      id: load
      doc: "'load'. Config tree."
    0x6461705f:
      id: pad
      doc: "'_pad'. Padding."
    0x646c7277:
      id: wrld
      doc: "'wrld'. World."
    0x646f6d67:
      id: gmod
      doc: "'gmod'."
    0x6766636d:
      id: mcfg
      doc: "'mcfg'. Movie config (config tree)."
    0x68746170:
      id: path
      doc: "'path'. One path."
    0x6c636f4c:
      id: locl
      doc: "'Locl'. Localization."
    0x6c646f6d:
      id: modl
      doc: "'modl'. Model."
    0x6c656b73:
      id: skel
      doc: "'skel'. Model skeleton."
    0x6c6c6f63:
      id: coll
      doc: "'coll'. Collision mesh."
    0x6d676573:
      id: segm
      doc: "'segm'. Model segment."
    0x6d697270:
      id: prim
      doc: "'prim'. Collision primitives."
    0x6e616c70:
      id: plan
      doc: "'plan'."
    0x6e676572:
      id: regn
      doc: "'regn'. Region."
    0x6e726574:
      id: tern
      doc: "'tern'. Terrain."
    0x746e6948:
      id: hint
      doc: "'Hint'."
    0x746e6f66:
      id: font
      doc: "'font'. Font."
    0x74736e69:
      id: inst
      doc: "'inst'. Placed instance."
    0x77646873:
      id: shdw
      doc: "'shdw'."
    0x9a644d15:
      id: sample_bank
      doc: 'SampleBank (FNV-1a hash tag): Info and, in common.bnk, Data.'
    0xd872e2a5:
      id: hashed_data
      doc: 'Data (FNV-1a hash tag): samples or movies back to back.'
