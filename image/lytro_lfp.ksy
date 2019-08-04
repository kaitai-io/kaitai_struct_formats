meta:
  id: lytro_lfp
  title: Lytro Light Field Picture
  application:
    - Lytro Cameras
    - Lytro Desktop
  file-extension: lfp
  xref:
    wikidata: Q2984629
  license: GPL-3.0+ # I'm sorry, but the main sources of info for this format (lfp-reader and plenopticam) are GPLed.
  endian: be
  encoding: utf-8
  ks-opaque-types: true
  ks-version: 0.9

doc: |
  Native file format of Lytro light field cameras.
  Sample files can be downloaded from:
    https://github.com/behnam/python-lfp-reader/tree/master/samples
    https://www.irisa.fr/temics/demos/IllumDatasetLF/index_files/LytroIllum_Dataset_INRIA_SIROCCO.zip

doc-ref:
  - https://github.com/behnam/python-lfp-reader
  - https://github.com/hahnec/plenopticam
  - https://github.com/nrpatel/lfptools
  - https://eclecti.cc/computervision/reverse-engineering-the-lytro-lfp-file-format
  - http://optics.miloush.net/lytro/TheFileFormat.aspx

seq:
  - id: sections
    type: section
    repeat: eos

instances:
  index:
    pos: 0
    type: lytro_lfp_sections_index(sections)
    doc: |
      # put to lytro_lfp_sections_index.py
      from kaitaistruct import KaitaiStruct
      
      class LytroLfpSectionsIndex(KaitaiStruct):
        __slots__ = ("index",)
        def __init__(self, sections, _io, _parent=None, _root=None):
          self.index = {}
          for s in sections:
            if s.is_section:
              c = s.contents
              if c.size:
                self.index[c.identifier] = c

types:
  alignment:
    params:
      - id: align_by
        type: u2
    seq:
      - id: alignment
        size: size_to_read
    instances:
      size_available:
        value: _io.size - _io.pos
      size_to_read:
        value: "size_to_read_computed < size_available ? size_to_read_computed : size_available"
      size_to_read_computed:
        value: "((_io.pos + align_by_m1) & ~align_by_m1) - _io.pos"
      align_by_m1:
        value: align_by - 1
  section:
    seq:
      - id: marker
        type: u1
      - id: contents
        type: section_contents
        if: is_section
      - id: alignment
        type: alignment(16)
    instances:
      is_section:
        value: marker == 0x89
    types:
      section_contents:
        seq:
          - id: type
            type: str
            size: 3
          - id: crlf
            contents: [0x0d, 0x0a]
          - id: unkn1
            type: u2
          - id: unkn0
            type: u4
          - id: size
            type: u4
          - id: identifier
            size: 80
            type: strz
            doc: "Usually contains SHA-1 checksum"
            if: size != 0
          - id: data
            size: size
            type:
              switch-on: type
              cases:
                #"'LFP'": header # usually empty?
                "'LFM'": json_metadata
                #"'LFC'": chunk # cannot process it yet
        types:
          json_metadata:
            seq:
              - id: json_str
                size: _io.size
                type: strz
            instances:
              parsed_metadata:
                pos: 0
                type: lytro_lfp_json_parsed_metadata(json_str, _root)
                doc: |
                  # put to lytro_lfp_json_parsed_metadata.py
                  import json
                  from kaitaistruct import KaitaiStruct
                  from enum import IntEnum
                  
                  class ChunkType(IntEnum):
                    metadata = 0
                    private_metadata = 1
                    image = 2
                  
                  class Frame:
                    __slots__ = ("image", "metadata", "private_metadata")
                    def __init__(self, jsonObj, index):
                      self.metadata = index[jsonObj["metadataRef"]]
                      
                      self.private_metadata = index[jsonObj["privateMetadataRef"]]
                      self.image = index[jsonObj["imageRef"]]
                      
                  
                  class SectionLink:
                    __slots__ = ("type", "frame_no")
                    def __init__(self, type, frame_no):
                      self.type = type
                      self.frame_no = frame_no
                  
                  class LytroLfpJsonParsedMetadata(KaitaiStruct):
                    __slots__ = ("json", "frames", "version", "metadata_index")
                    def __init__(self, json_str: str, root, _io, _parent=None, _root=None):
                      self.json = json.loads(json_str)
                      index = root.index
                      pic = self.json["picture"]
                      self.frames = []
                      self.metadata_index = {}
                      
                      for i, f in enumerate(pic["frameArray"]):
                        fDescr = Frame(f["frame"], index)
                        self.frames.append(fDescr)
                        self.metadata_index[fDescr.metadata] = SectionLink(i, ChunkType.metadata)
                        self.metadata_index[fDescr.private_metadata] = SectionLink(i, ChunkType.private_metadata)
                        self.metadata_index[fDescr.image] = SectionLink(i, ChunkType.image)
                    
