meta:
  id: compressed_resource
  title: Compressed Macintosh resource
  application: Mac OS
  license: MIT
  ks-version: "0.9"
  imports:
    - /common/bytes_with_io
  endian: be
doc: |
  Compressed Macintosh resource data,
  as stored in resources with the "compressed" attribute.

  Resource decompression is not documented by Apple.
  It is mostly used internally in System 7,
  some of Apple's own applications (such as ResEdit),
  and also by some third-party applications.
  Later versions of Classic Mac OS make less use of resource compression,
  but still support it fully for backwards compatibility.
  Carbon in Mac OS X no longer supports resource compression in any way.

  The data of all compressed resources starts with a common header,
  followed by the compressed data.
  The data is decompressed using code in a `'dcmp'` resource.
  Some decompressors used by Apple are included in the System file,
  but applications can also include custom decompressors.
  The header of the compressed data indicates the ID of the `'dcmp'` resource used to decompress the data,
  along with some parameters for the decompressor.
doc-ref:
  - 'http://www.alysis.us/arctechnology.htm'
  - 'http://preserve.mactech.com/articles/mactech/Vol.09/09.01/ResCompression/index.html'
  - 'https://github.com/dgelessus/python-rsrcfork/tree/f891a6e/src/rsrcfork/compress'
seq:
  - id: header
    type: header
    doc: |
      The header of the compressed data.
  - id: compressed_data
    size-eos: true
    doc: |
      The compressed resource data.

      The format of this data is completely dependent on the decompressor and its parameters,
      as specified in the header.
      For details about the compressed data formats implemented by Apple's decompressors,
      see the specs in the resource_compression subdirectory.
types:
  header:
    doc: |
      Compressed resource data header,
      as stored at the start of all compressed resources.
    seq:
      - id: common_part
        type: common_part
        doc: |
          The common part of the header.
          Among other things,
          this part contains the header type,
          which determines the format of the data in the type-specific part of the header.
      - id: type_specific_part_raw_with_io
        type: bytes_with_io
        size: common_part.len_header - common_part._sizeof
        doc: |
          Use `type_specific_part_raw` instead,
          unless you need access to this field's `_io`.
    instances:
      type_specific_part_raw:
        value: type_specific_part_raw_with_io.data
        doc: |
          The type-specific part of the header,
          as a raw byte array.
      type_specific_part:
        io: type_specific_part_raw_with_io._io
        pos: 0
        type:
          switch-on: common_part.header_type
          cases:
            8: type_specific_part_type_8
            9: type_specific_part_type_9
        doc: |
          The type-specific part of the header,
          parsed according to the type from the common part.
    types:
      common_part:
        doc: |
          The common part of a compressed resource data header.
          The format of this part is the same for all compressed resources.
        seq:
          - id: magic
            contents: [0xa8, 0x9f, 0x65, 0x72]
            doc: |
              The signature of all compressed resource data.

              When interpreted as MacRoman, this byte sequence decodes to `®üer`.
          - id: len_header
            type: u2
            valid: 0x12
            doc: |
              The byte length of the entire header (common and type-specific parts).

              The meaning of this field is mostly a guess,
              as all known header types result in a total length of `0x12`.
          - id: header_type
            type: u1
            doc: |
              Type of the header.
              This determines the format of the data in the type-specific part of the header.

              The only known header type values are `8` and `9`.

              Every known decompressor is only compatible with one of the header types
              (but every header type is used by more than one decompressor).
              Apple's decompressors with IDs 0 and 1 use header type 8,
              and those with IDs 2 and 3 use header type 9.
          - id: unknown
            type: u1
            valid: 0x01
            doc: |
              The meaning of this field is not known.
              It has the value `0x01` in all known compressed resources.
          - id: len_decompressed
            type: u4
            doc: |
              The byte length of the data after decompression.
      type_specific_part_type_8:
        doc: |
          The type-specific part of a compressed resource header with header type `8`.
        seq:
          - id: working_buffer_fractional_size
            type: u1
            doc: |
              The ratio of the compressed data size to the uncompressed data size,
              times 256.

              This parameter affects the amount of memory allocated by the Resource Manager during decompression,
              but does not have a direct effect on the decompressor
              (except that it will misbehave if insufficient memory is provided).
              Alternative decompressors that decompress resources into a separate buffer rather than in-place can generally ignore this parameter.
          - id: expansion_buffer_size
            type: u1
            doc: |
              The maximum number of bytes that the compressed data might "grow" during decompression.

              This parameter affects the amount of memory allocated by the Resource Manager during decompression,
              but does not have a direct effect on the decompressor
              (except that it will misbehave if insufficient memory is provided).
              Alternative decompressors that decompress resources into a separate buffer rather than in-place can generally ignore this parameter.
          - id: decompressor_id
            type: s2
            doc: |
              The ID of the `'dcmp'` resource that should be used to decompress this resource.
          - id: reserved
            type: u2
            valid: 0
            doc: |
              The meaning of this field is not known.
              It has the value `0` in all known compressed resources,
              so it is most likely reserved.
      type_specific_part_type_9:
        doc: |
          The type-specific part of a compressed resource header with header type `9`.
        seq:
          - id: decompressor_id
            type: s2
            doc: |
              The ID of the `'dcmp'` resource that should be used to decompress this resource.
          - id: decompressor_specific_parameters_with_io
            type: bytes_with_io
            size: 4
            doc: |
              Use `decompressor_specific_parameters` instead,
              unless you need access to this field's `_io`.
        instances:
          decompressor_specific_parameters:
            value: decompressor_specific_parameters_with_io.data
            doc: |
              Decompressor-specific parameters.
              The exact structure and meaning of this field is different for each decompressor.

              This field always has the same length,
              but decompressors don't always use the entirety of the field,
              so depending on the decompressor some parts of this field may be meaningless.
