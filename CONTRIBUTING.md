# Kaitai Struct: format library

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
  * It SHOULD match [the style guide](http://doc.kaitai.io/ksy_style_guide.html).
* Fork this repository
* Choose a relevant folder and add your .ksy spec into it
* Create a "pull request" at GitHub to pull your specs into this repo
  * Please add some general information about the formats and some
    instructions on how could we test it (i.e. where can we find
    sample files in that format, etc)
