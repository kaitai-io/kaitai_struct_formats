meta:
  id: unix_pack
  title: Unix pack-compressed data
  application:
    - pack(1)
    - unpack(1)
    - pcat(1)
  # The extension is specifically lowercase.
  # Uppercase .Z is used for compress-compressed data.
  file-extension: z
  xref:
    justsolve: Pack
    wikidata: Q11239298
  license: CC0-1.0
  endian: be
doc: |
  The Unix pack compression format, a very basic compression format based on
  Huffman coding. The Unix `pack` utility could compress files into
  this format, and could be decompressed using the utilities `unpack`
  and `pcat`.
  
  The pack format is long obsolete - it was superseded in the 1980s
  by the LZW-based compression format of `compress` (which is itself
  almost never used anymore on modern Unix derivatives). Despite this,
  the `gzip` utility still supports decompressing (but not compressing)
  data in the pack compression format.
doc-ref:
  - 'https://www.vidarholen.net/contents/blog/?p=691'
  - 'https://github.com/koalaman/pack/blob/master/pack.hs'
  - 'https://git.savannah.gnu.org/cgit/gzip.git/tree/unpack.c'
  # The source code for the original Unix pack and unpack utilities
  # (as of Research Unix, Edition 8) can be found in the archive v8.tar.bz2
  # in the directory usr/src/cmd/pack.
  - 'https://www.tuhs.org/Archive/Distributions/Research/Dan_Cross_v8/'
seq:
  - id: magic
    contents: [0x1f, 0x1e]
  - id: len_uncompressed
    type: u4
    doc: The length of the data when uncompressed, in bytes.
  - id: tree
    type: tree
    doc: The Huffman tree used to compress the data.
  - id: data
    size-eos: true
    doc: |
      The compressed data. This is a sequence of Huffman codes (variable-length
      bit sequences) stored in most-significant bit first order without any
      padding/alignment between individual codes. If the coded data does not
      end on a byte boundary, it is padded with zeroes at the end (i. e. in the
      least significant bits).
types:
  tree_level:
    params:
      - id: level_number
        type: u1
        doc: This level's number.
    seq:
      - id: leaves
        type: u1
        repeat: expr
        # See doc of tree.level_leaf_counts for an explanation of
        # this calculation.
        repeat-expr: |
          _parent.level_leaf_counts[level_number]
          + (level_number == _parent.num_levels-1 ? 1 : 0)
        doc: |
          The byte values corresponding to each leaf on this level of the tree.
  tree:
    seq:
      - id: num_levels
        type: u1
        doc: |
          The depth (number of levels) of this tree. The root is not counted
          as part of this number.
      - id: level_leaf_counts
        type: u1
        repeat: expr
        repeat-expr: num_levels
        doc: |
          The number of leaves on each level of the tree.
          
          Note: the last leaf count is stored *minus two*. However, the last
          leaf always stands for EOF and does not have an associated
          byte value, so for the purposes of parsing this format, the last
          level's leaf count is considered *minus one*.
      - id: levels
        type: tree_level(_index)
        repeat: expr
        repeat-expr: num_levels
        doc: The individual levels of the tree.
    doc: |
      Serialized representation of a binary Huffman tree. The tree always
      follows these rules:
      
      * The tree is always left-aligned, i. e. on each level of the tree,
        all inner (non-leaf) nodes are on the left side of the tree,
        and all leaves are on the right side.
      * The total number of nodes on each tree level is two times the number
        of inner nodes on the previous level (since this is a binary tree,
        each inner node has exactly two children).
      * There is a single implicit root node.
      * The number of inner nodes on each tree level can be calculated from
        the total number of nodes and the number of leaf nodes.
      * The rightmost leaf on the last level of the tree always stands for EOF,
        and is not stored explicitly in the file (unlike all other
        leaf values).
