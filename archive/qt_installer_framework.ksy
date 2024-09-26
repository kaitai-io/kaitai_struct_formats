meta:
  id: qt_installer_framework
  title: Qt Installer Framework archive
  application: Qt Installer Framework
  file-extension: exe
  endian: le
  encoding: utf-8
  license: GPL-3.0 WITH Qt-GPL-exception-1.0
  xref:
    wikidata: Q201904

doc: |
  Qt installer framework is a set of libs to make SFX installers. Installers usually contain 7zip-compressed archives. Obviously, Qt installer itself is built using this framework.
  
  Warning 1: KSC has a bug. It makes the computed values be int32_t. Of course their type should be either explicitly specified by a programmer or derived automatically. The workaroind is to just replace all int32_t to int64_t in sources.
  Warning 2: don't use this spec on Linux against Qt distribution with overcommit enabled unless you have lot of RAM (> 12 GiB). There is a severe memory leak somewhere (currently I have no idea where exactly). The leak is present in both C++ and python-compiled code. In python even if I have patched the generated source to explicitly free all the `bytes`, `BytesIO`s and `KaitaiStream` objects the leak is still present. At least it is neither in `bytes` nor in `BytesIO`. In C++ I have not patched anything but used move semantics to free the stuff since std::unique_ptr is used. The leak is still present. IDK where it is and how to fix it.

-license-header: |
  GNU General Public License Usage
  Alternatively, this file may be used under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with exceptions as appearing in the file LICENSE.GPL3-EXCEPT included in the packaging of this file. Please review the following information to ensure the GNU General Public License requirements will be met: https://www.gnu.org/licenses/gpl-3.0.html.
  

doc-ref:
  - https://wiki.qt.io/Qt-Installer-Framework
  - https://github.com/qtproject/installer-framework/blob/master/src/libs/installer/binaryformat.cpp
  - https://github.com/qtproject/installer-framework/blob/master/src/libs/installer/binarycontent.cpp
  - https://github.com/qtproject/installer-framework/blob/master/src/libs/installer/binarycontent.h

params:
  - id: magic_cookie_offset
    type: u8
    -orig-id: endOfBinaryContent - 8
    doc:  "In order to use this spec find the magic cookie [0xf8, 0x68, 0xd6, 0x99, 0x1c, 0x0a, 0x63, 0xc2] in the last MiB of file and set this param to its offset."
instances:
  end_of_binary_content:
    value: magic_cookie_offset + sizeof<header::cookie_identifier>
  header:
    pos: end_of_binary_content - sizeof<header>
    type: header
types:
  array:
    seq:
      - id: size
        type: u8
      - id: value
        size: size
  string:
    seq:
      - id: size
        type: u8
      - id: value
        size: size
        type: str
  header:
    seq:
      - id: meta_resources_count
        type: u8
        -orig-id: metaResourcesCount
      - id: unkn
        type: u8
        repeat: expr
        repeat-expr: 2
      - id: cookie
        type: cookie_identifier
        -orig-id: magicCookie

    instances:
      other_stuff_size:
        value: 4 * sizeof<u8>
        doc: "meta count, offset/length collection index, marker, cookie..."
      binary_descriptor_offset:
        value: _root.end_of_binary_content - other_stuff_size
        -orig-id: posOfResourceCollectionsSegment
      binary_descriptor:
        io: _root._io
        pos: binary_descriptor_offset
        size: sizeof<binary_descriptor>
        type: binary_descriptor

    types:
      marker_identifier:
        seq:
          - id: type
            type: u1
            enum: type
          - id: signature
            contents: [0x32, 0x02, 0x12]
        enums:
          type:
            0x33: installer
            0x34: uninstaller
            0x35: updater
            0x36: package_manager
      
      cookie_identifier:
        seq:
          - id: type
            type: u1
            enum: type
          - id: signature
            contents: [0x68, 0xd6, 0x99, 0x1c, 0x0a, 0x63, 0xc2]
        enums:
          type:
            0xf8: binary
            0xf9: data

      range:
        doc-ref: https://github.com/qtproject/installer-framework/blob/cf8d5b9a650cc413dde79cf7d72da407c8993ddc/src/libs/installer/fileio.cpp#L52
        seq:
          - id: start_read
            type: s8
          - id: size
            type: s8
        instances:
          start:
            value: _root.header.binary_descriptor.end_of_exectuable + start_read
      
      binary_descriptor:
        seq:
          - id: resources_count
            type: s8
            doc: read it, but deliberately not used
          
          - id: binary_content_size
            type: s8
            -orig-id: binaryContentSize
          
          - id: marker
            type: marker_identifier
            -orig-id: magicMarker
        instances:
          size_of_segment_descriptor:
            value: (_parent.meta_resources_count + 2) * sizeof<range>
          segments_descriptor:
            io: _root._io
            pos: _parent.binary_descriptor_offset - size_of_segment_descriptor
            size: size_of_segment_descriptor
            type: segments_descriptor
          end_of_exectuable:
            value: _parent._root.end_of_binary_content - binary_content_size
        
        types:
          segments_descriptor:
            seq:
              - id: resource_collections_segment
                type: range
              
              - id: meta_resource_segments
                type: range
                repeat: expr
                repeat-expr: _parent._parent.meta_resources_count
                -orig-id: metaResourceSegments
              
              - id: operations_segment
                type: range
                -orig-id: operationsSegment
            instances:
              collections:
                io: _root._io
                pos: resource_collections_segment.start
                size: resource_collections_segment.size
                type: collections
              operations:
                io: _root._io
                pos: operations_segment.start
                size: operations_segment.size
                type: operations
                
            types:
              operations:
                seq:
                  - id: count
                    type: u8
                  - id: operations
                    type: operation
                    repeat: expr
                    repeat-expr: count
                  - id: reserved
                    type: u8
                    doc: read it, but deliberately not used
                types:
                  operation:
                    seq:
                      - id: name
                        type: string
                      - id: xml
                        type: string
              collections:
                seq:
                  - id: count
                    type: s8
                    -orig-id: size
                  - id: collections
                    type: collection
                    repeat: expr
                    repeat-expr: count
                types:
                  collection:
                    seq:
                      - id: name
                        type: string
                      - id: segment_range
                        type: range
                    instances:
                      segment:
                        io: _root._io
                        pos: segment_range.start
                        size: segment_range.size
                        type: segment
                    types:
                      segment:
                        seq:
                          - id: count
                            type: u8
                          - id: resources
                            type: resource
                            repeat: expr
                            repeat-expr: count
                        types:
                          resource:
                            seq:
                              - id: name
                                type: string
                              - id: segment
                                type: range
