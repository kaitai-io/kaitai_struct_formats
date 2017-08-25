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

If you've developed a format specification using Kaitai Struct and
would like to make the world a little better by sharing your
knowledge, so other fellow developers don't have to redo the same
parsing task again and again from scratch — that's great, your
contribution would be most welcome!

Please follow these steps:

* Choose open source license for your .ksy
  * We recommend either
    [CC0-1.0](https://spdx.org/licenses/CC0-1.0.html) if it's a
    trivial transcription of some specification into formal .ksy, or
    [MIT](https://spdx.org/licenses/MIT.html) license if your .ksy is
    non-trivial and creative approach to a format, but you can choose
    any OSI-approved open source license that you want.
* Ensure that your .ksy file passes basic checklist:
  * It MUST compile without errors with ksc
  * It MUST have licensing information (`meta/license` tag with
    [valid SPDX open source license expression](https://spdx.org/licenses/)
    is mandatory, licensing comment is optional)
  * It SHOULD have some general information about the format and some
    documentation (`meta/title`, `meta/file-extension`,
    `meta/application`, `doc`, `doc-ref` tags).
* Fork this repository
* Choose a relevant folder and add your .ksy spec into it
* Create a "pull request" at GitHub to pull your specs into this repo
  * Please add some general information about the formats and some
    instructions on how could we test it (i.e. where can we find
    sample files in that format, etc)

## Licensing

This repository contains work of many individuals. Each .ksy is
licensed separately: please see `meta/license` tag and comments in
every .ksy file for permissions. Kaitai team claims no copyright over
other people's contributions.
