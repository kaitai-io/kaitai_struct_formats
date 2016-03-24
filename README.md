# Kaitai Struct: formats library

This repository constitutes a library of ready-made binary file format
descriptions using [Kaitai Struct] language (`.ksy`).

These formats can be useful for:

* exploring a certain file format internals: one can load `.ksy`
  format + target binary in a visualizer and learn what's inside;

* as a production-ready binary file parsing library: they can be
  compiled with a [Kaitai Struct compiler] into source code in any
  supported target programming language;

* as a starting point for learning applications of Kaitai Struct in
  real world;

## Layout of repository

To make it easier to navigate around multitude of formats, we sort
them by the general purpose and application:

* `archive` — container files used by general purpose archivers
  applications to pack multiple files into one (e.g. [zip], [tar])
* `executable` — files that contain executable machine code, runnable
  binaries, libraries, general purpose VM bytecode (e.g. [DOS MS],
  [elf], [Java class files])
* `filesystem` — file systems, disc partitioning labels, everything
  related to file storage at kernel level (e.g. [ISO 9660], [ext2])
* `game` — computer games / game engines
* `image` — image formats, digital imaging (e.g. [PNG], [GIF], [BMP])
* `network` — formats used in network communications (e.g.
  [Ethernet frame], [IPv4 packet])

Formats that won't fit into any of these categories just reside in the
root.

[Kaitai Struct]: https://github.com/kaitai-io/kaitai_struct
[Kaitai Struct compiler]: https://github.com/kaitai-io/kaitai_struct_compiler

[zip]: https://en.wikipedia.org/wiki/Zip_(file_format)
[tar]: https://en.wikipedia.org/wiki/Tar_(computing)
[DOS MZ]: https://en.wikipedia.org/wiki/DOS_MZ_executable
[elf]: https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
[Java class files]: https://en.wikipedia.org/wiki/Java_class_file
[ISO 9660]: https://en.wikipedia.org/wiki/ISO_9660
[ext2]: https://en.wikipedia.org/wiki/Ext2
[PNG]: https://en.wikipedia.org/wiki/Portable_Network_Graphics
[GIF]: https://en.wikipedia.org/wiki/GIF
[BMP]: https://en.wikipedia.org/wiki/BMP_file_format
[Ethernet frame]: https://en.wikipedia.org/wiki/Ethernet_frame
[IPv4 packet]: https://en.wikipedia.org/wiki/Internet_Protocol
