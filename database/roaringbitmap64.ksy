doc: |
  Some Roaring bitmap implementations may offer a 64-bit implementation. This section proposes a portable format,
  compatible with some (but not all) 64-bit implementations. This format is naturally compatible with implementations
  based on a conventional red-black-tree (as the serialization format is similar to the in-memory layout). The keys
  would be 32-bit integers representing the most significant 32~bits of elements whereas the values of the tree are
  32-bit Roaring bitmaps. The 32-bit Roaring bitmaps represent the least significant bits of a set of elements.

meta:
  id: roaringbitmap64
  title: Roaring Bitmap Portable 64 Bit Format
  license: Apache-2.0
  endian: le
  imports:
    - roaringbitmap


seq:
  - id: num_buckets
    type: u8
    doc: The number of sub-buckets (32 bit roaring bitmaps).
  - id: buckets
    type: bucket
    repeat: expr
    repeat-expr: num_buckets

types:
  bucket:
    doc: For each sub-bucket, the upper 32 bits of the bucket, and a 32 bit roaring bitmap.
    seq:
      - id: key
        type: u4
        doc: The upper 32 bits of the bucket.
      - id: bitmap
        type: roaringbitmap

