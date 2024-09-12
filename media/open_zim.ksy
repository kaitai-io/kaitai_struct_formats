meta:
  id: open_zim
  title: (Open) Zeno IMproved
  application:
    - Kiwix
    - libzim
    - zimlib
  file-extension: zim
  xref:
    wikidata: Q784695
  license: CC-BY-SA-3.0
  encoding: utf-8
  endian: le
  -requires-optional:
    - https://github.com/kaitai-io/kaitai_compress

doc: |
  A file format to store encyclopaedias of articles written in MediaWiki markup language.
  Files for test: https://dumps.wikimedia.org/other/kiwix/zim/wikipedia/ , but they now use ZStd.
  Here is an old one: https://web.archive.org/web/20190830024935if_/https://dumps.wikimedia.org/other/kiwix/zim/wikipedia/wikipedia_ay_all_nopic_2019-05.zim .
  Also: https://raw.githubusercontent.com/openzim/libzim/master/test/data/small.zim

doc-ref:
  - https://www.openzim.org/wiki/ZIM_file_format
  - https://wiki.openzim.org/wiki/OpenZIM

seq:
  - id: signature
    -orig-id: magicNumber
    contents: [ZIM, 0x04]
    doc: Magic number to recognise the file format, must be
  - id: version
    type: version
    doc: Version of the ZIM file format
  - id: uuid
    type: uuid
    doc: unique id of this zim file
  - id: article_count
    type: u4
    doc: total number of articles
  - id: cluster_count
    type: u4
    doc: total number of clusters
  - id: url_pointer_list_ptr
    -orig-id: urlPtrPos
    type: u8
    doc: position of the directory pointerlist ordered by URL
  - id: title_pointer_list_ptr
    -orig-id: titlePtrPos
    type: u8
    doc: position of the directory pointerlist ordered by Title
  - id: cluster_pointer_list_ptr
    -orig-id: clusterPtrPos
    type: u8
    doc: position of the cluster pointer list
  - id: mime_list_ptr
    -orig-id: mimeListPos
    type: u8
    doc: |
      position of the MIME type list (also header size)
      The MIME type list always follows directly after the header, so the mimeListPos also defines the end and size of the ZIM file header.
      The MIME types in this list are zero terminated strings.
  - id: main_page_idx
    -orig-id: mainPage
    type: u4
  - id: layout_page_idx
    -orig-id: layoutPage
    type: u4
  - id: md5_ptr
    -orig-id: checksumPos
    type: u8
    doc: pointer to the md5 checksum of this file without the checksum itself. This points always 16 bytes before the end of the file.
instances:
  mime_list:
    pos: mime_list_ptr
    type: str_list
  url_pointer_list:
    doc: |
      The URL pointer list is a list of 8 byte offsets to the directory entries.
      The directory entries are always ordered by URL. Ordering is simply done by comparing the URL strings.
      Since directory entries have variable sizes this is needed for random access.
      Zimlib caches directory entries and references the cached entries via the URL pointers.
    pos: url_pointer_list_ptr
    type: directory_entry_ptr
    repeat: expr
    repeat-expr: article_count
  title_pointer_list:
    doc: |
      The title pointer list is a list of article indices ordered by title. The title pointer list actually points to entries in the URL pointer list. Note that the title pointers are only 4 bytes. They are not offsets in the file but article numbers. To get the offset of an article from the title pointer list, you have to look it up in the URL pointer list.
      The indirection from titles via URLs to directory entries has two reasons: the pointer list is only half in size as 4 bytes are enough for each entry accessing directory entries by title also makes use of cached directory entries which are referenced by the URL pointers, as implemented in zimlib.
    pos: title_pointer_list_ptr
    type: title_index
    repeat: expr
    repeat-expr: article_count
  cluster_pointer_list:
    pos: cluster_pointer_list_ptr
    type: cluster_ptr
    repeat: expr
    repeat-expr: cluster_count
  main_page:
    value: url_pointer_list[main_page_idx]
    if: main_page_idx != 0xffff_ffff
  layout_page:
    value: url_pointer_list[layout_page_idx]
    if: layout_page_idx != 0xffff_ffff
  md5:
    pos: md5_ptr
    type: md5
  minimal_xz_lzma_size:
    value: 32
  minimal_zstd_size:
    value: 9
types:
  md5:
    seq:
      - id: data
        size: 16
  uuid:
    -webide-representation: "{data:uuid=be}"
    seq:
      - id: data
        size: 16

  version:
    seq:
      - id: major
        -orig-id: majorVersion
        type: u2
        doc: |
          Major version of the ZIM file format (5 or 6)
          Major version is updated when an incompatible change is integrated in the format (a lib made for a version N will probably not be able to read a version N+1)
          There are currently 2 major versions:
            The version 5
            The version 6 (the same that version 5 + potential extended cluster)
      - id: minor
        -orig-id: minorVersion
        type: u2
        doc: |
          Minor version of the ZIM file format
          Minor version is updated when an compatible change is integrated (a lib made for a minor version n will be able to read a version n+1)
  title_index:
    seq:
      - id: index
        type: u8
    instances:
      entry:
        value: _parent.url_pointer_list[index].entry
  str_list:
    seq:
      - id: items
        type: strz
        repeat: until
        repeat-until: _ == ""
  directory_entry_ptr:
    seq:
      - id: ptr
        type: u8
    instances:
      entry:
        pos: ptr
        type: directory_entry
    types:
      directory_entry:
        seq:
          - id: mime_idx
            -orig-id: mimetype
            type: u2
            doc: MIME type number as defined in the MIME type list
          - id: parameter_size
            -orig-id: parameter_len
            type: u1
            doc: (not used) length of extra paramters
          - id: namespace
            type: s1
            enum: namespace
            doc: defines to which namespace this directory entry belongs
          - id: revision
            type: u4
            doc: (optional) identifies a revision of the contents of this directory entry, needed to identify updates or revisions in the original history
          - id: body
            type:
              switch-on: mime_idx == 0xffff
              cases:
                true: redirect
                _: article
          - id: url
            type: strz
            doc: string with the URL as refered in the URL pointer list
          - id: title
            type: strz
            doc: string with an title as refered in the Title pointer list or empty; in case it is empty, the URL is used as title
          - id: parameter
            size: parameter_size
            doc: (not used) extra parameters
        instances:
          mime:
            value: _root.mime_list.items[mime_idx]
            if: mime_idx != 0xffff

        types:
          article:
            seq:
              - id: cluster_index
                -orig-id: cluster_number
                type: u4
                doc: cluster number in which the data of this directory entry is stored
              - id: blob_index
                -orig-id: blob_number
                type: u4
                doc: blob number inside the compressed cluster where the contents are stored
            instances:
              cluster:
                value: _root.cluster_pointer_list[cluster_index].cluster
              data:
                value: cluster.blobs[blob_index]
          redirect:
            seq:
              - id: redirect_index
                -orig-id: redirect_index
                type: u4
                doc: pointer to the directory entry of the redirect target
        enums:
          namespace:
            0x2D: # "-"
              id: layout
              doc: eg. the LayoutPage, CSS, favicon.png (48x48), JavaScript and images not related to the articles
            0x41: # "A"
              id: article
              doc: articles - see Article Format
            0x42: # "B"
              id: article_meta_data
              doc: article meta data - see Article Format
            0x43: # "C"
              id: user_content
              doc: User content entries - see Article Format
            0x48: # "H"
              id: unkn_h
              doc: Unknown
            0x49: # "I"
              id: image_file
              doc: images, files - see Image Handling
            0x4A: # "J"
              id: image_text
              doc: images, text - see Image Handling
            0x4D: # "M"
              id: meta_data
              doc: ZIM metadata - see Metadata
            0x55: # "U"
              id: category_text
              doc: categories, text - see Category Handling
            0x56: # "V"
              id: category_article_list
              doc: categories, article list - see Category Handling
            0x57: # "W"
              id: category_list_per_article
              doc: categories per article, category list - see Category Handling
            0x58: # "X"
              id: fulltext_index
              doc: fulltext index - see ZIM Index Format
            0x5A: # "Z"
              id: fulltext_index_z
              doc-ref: https://github.com/openzim/libzim/blob/e4fe0d2854bfd4a7f6699d8c2a6fd9a00ed51588/src/search.cpp#L267
  cluster_ptr:
    seq:
      - id: ptr
        type: u8
    instances:
      cluster:
        pos: ptr
        type: cluster(ptr)
    types:
      cluster:
        -affected-by:
          - 374
          - 863
        params:
          - id: ptr
            type: u8
        seq:
          - id: info
            type: info_t
          - id: blobs_ptrs_compressed_lzma2
            process: kaitai.compress.lzma(2)
            size: info.ptr_size * blob_count_plus_one
            type: blobs_ptrs(blob_count)
            if: info.compression == compression::lzma2
          - id: blobs_ptrs_compressed_zstd
            process: kaitai.compress.zstd
            size: info.ptr_size * blob_count_plus_one
            type: blobs_ptrs(blob_count)
            if: info.compression == compression::lzma2
          - id: blobs_ptrs_uncompressed
            type: blobs_ptrs(blob_count)
            if: info.compression == compression::none or info.compression == compression::default
        instances:
          first_blob_offset:
            value: ptr + 1 # info_t.size
          blobs:
            type: blob(_index)
            repeat: expr
            repeat-expr: blob_count
          first_blob_ptr_compressed_lzma:
            io: _root._io
            pos: first_blob_offset
            process: kaitai.compress.lzma(2)
            size: info.ptr_size + _root.minimal_xz_lzma_size # max(8, 4) + minimal_xz_lzma_size
            type: blob_ptr_u
            if: info.compression == compression::lzma2
          first_blob_ptr_compressed_zstd:
            io: _root._io
            pos: first_blob_offset
            process: kaitai.compress.zstd
            size: info.ptr_size + _root.minimal_zstd_size # max(8, 4) + minimal_zstd_size
            type: blob_ptr_u
            if: info.compression == compression::zstd
          first_blob_ptr_uncompressed:
            pos: first_blob_offset
            type: blob_ptr_u
            if: info.compression == compression::none or info.compression == compression::default
          first_blob_ptr_u_v:
            value: |
              (
                info.compression == compression::lzma2
                ?
                first_blob_ptr_compressed_lzma
                :
                (
                  info.compression == compression::zstd
                  ?
                  first_blob_ptr_compressed_zstd
                  :
                  first_blob_ptr_uncompressed
                )
              ).as<blob_ptr_u>.value
          blob_count_plus_one:
            value: first_blob_ptr_u_v / info.ptr_size
          blob_count:
            value: blob_count_plus_one - 1
          blobs_ptrs:
            value: |
              (
                info.compression == compression::lzma2
              ?
                blobs_ptrs_compressed_lzma2
              :
                (
                  info.compression == compression::zstd
                ?
                  blobs_ptrs_compressed_zstd
                :
                  blobs_ptrs_uncompressed
                )
              ).ptrs
            if: |
              info.compression == compression::lzma2
              or info.compression == compression::zstd
              or info.compression == compression::none
              or info.compression == compression::default
        types:
          blobs_ptrs:
            params:
              - id: count
                type: u8
            seq:
              - id: ptrs
                type: blob_ptr_u
                repeat: eos
            instances:
              info:
                value: _parent.info
          blob:
            params:
              - id: idx
                type: u8
            instances:
              data:
                pos: _parent.ptr + _parent.blobs_ptrs[idx].as<blob_ptr_u>.value
                size: _parent.blobs_ptrs[idx + 1].as<blob_ptr_u>.value - _parent.blobs_ptrs[idx].as<blob_ptr_u>.value
          info_t:
            seq:
              - id: reserved
                type: b3
                valid: 0
              - id: is_ptr_u8
                -orig-id: extended
                type: b1
              - id: compression
                type: b4
                enum: compression
                valid:
                  expr: _ != compression::lzma2 and _ != compression::zstd and _ != compression::bzip2 and _ != compression::zlib
                doc: LZMA and ZStd are not supported because of behavior of lack of support of streaming processors in KS. bzip2 and zlib are not supported because they are not supported in the official lib (though in principle they probably can be supported).
            instances:
              ptr_size:
                value: "is_ptr_u8 ? 8 : 4"
          blob_ptr_u:
            seq:
              - id: value
                type:
                  -affected-by: 561
                  switch-on: _parent.as<cluster>.info.is_ptr_u8 # bug in KSC, as is mandatory
                  cases:
                    true: u8
                    _: u4
        enums:
          compression:
            0:
              id: default
              -orig-id: default
              doc: no compression
            1: none
            2: zlib # removed
            3: bzip2 # removed
            4: lzma2
            5: zstd
