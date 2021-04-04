# Kaitai Struct: formats library

This repository constitutes a library of ready-made binary file format
descriptions using [Kaitai Struct](http://kaitai.io/) language (`.ksy`).

These formats can be useful for:

* exploring a certain file format internals: one can load `.ksy`
  format + target binary in a [Web IDE](https://ide.kaitai.io) or
  [visualizer](https://github.com/kaitai-io/kaitai_struct_visualizer)
  and learn what's inside;

* as a production-ready binary file parsing library: they can be
  compiled with a
  [Kaitai Struct compiler](https://github.com/kaitai-io/kaitai_struct_compiler)
  into source code in any supported target programming language;

* as a starting point for learning applications of Kaitai Struct in
  real world;

## Exploring this repository

If you want to explore the repository, please visit
[Kaitai Struct format gallery](http://formats.kaitai.io/) — that's
HTML rendition of this repository, which block diagrams, all the code
compiled for all possible target languages, provided with usage
examples and instructions, etc, etc.

Alternatively, you can start with [Web IDE](https://ide.kaitai.io) —
this library of formats also comes pre-loaded with it.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## Licensing

This repository contains work of many individuals. Each .ksy is
licensed separately: please see `meta/license` tag and comments in
every .ksy file for permissions. Kaitai team claims no copyright over
other people's contributions.
