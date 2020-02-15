---
title: 'Contribute around a new format specification (newbie edition)'
labels: spec-request
---
<!--
Wanna 
* ... find collaborators to work on the format?
* ... inform the world that you have started working on the spec for a format to avoid your effort being wasted?
* ... discuss implementation details?
* ... just dump info useful for implementing the spec?

Then this template is for you.

Since for every format we deal with the same info and since it is beneficial for both human and bot (one is planned!) readers to have the info encoded into a messages with the same schema, we have designed the format for this kind of issues. Please, follow it.

A request for a format specification consists of some YAML blocks followed by a free-form text description. Each YAML block has own purpose, its purpose is described in the comment within that block. 

We expect you to:
* fill in all the fields you can and want to fill in;
* delete all the unfilled fields;
* delete all the comments (both YAML and HTML) from this template (including this one!).
* make sure that YAML blocks contain well-formed YAML;
* make sure that blocks contents do not violate their schemas;
* make sure that all the fields marked as MANDATORY are filled in.

-->
```yaml
# The purposes of this block are:
# * storing the info uniquily identifying the format to make it searcheable;
# * storing useful information about the format in a convenient structured way;
# * providing an implementer with a boilerplate which can be just copied into a KSY file;
# The content of this block must be a part of a valid KSY.
# This block must be present.

meta: # see https://doc.kaitai.io/ksy_reference.html#meta for more info
  id: # insert an ID (matches the regexp [a-z][\da-z_]*[\da-z]) you feel right to assign to the format here. KS currently has no namespaces, so the id MUST be unique within all the repo and you should be sure there will be no collisions. If in doubt, add a prefix of an app name. MANDATORY.
  title: # insert a human-readable name of the format here. MANDATORY.
  application: # insert a human-readable name of the application for which this format is native here. If it is native for several applications, choose the ones you feel the most affiliated with the format. If the format is a widespread one, like PNG or WAV, just remove this field.
  file-extension:
    # insert here a YAML list of file extensions
  xref: # check if the following sources contain info about the format you request. See https://doc.kaitai.io/user_guide.html#meta-xref for more info
    din:
      id: # DIN standard identifier
    forensicswiki: # Page name on https://forensicswiki.org/
    fileformat: # Link to https://www.fileformat.info
    iso: # ISO standard identifier
    justsolve: # ID on http://fileformats.archiveteam.org/wiki/
    loc: # ID in https://www.loc.gov/preservation/digital/formats/
    mime: # MIME type
    pronom: # IDs on https://www.nationalarchives.gov.uk/pronom/fmt/
     - x-fmt/
    rfc: # Link to RFC
    wikidata: Q # ID on WikiData

doc: |
  # * Describe your format briefly. MANDATORY
  # * add links to the sources of sample files in the Web
  # * instructions on how to create the files yourself using the software typical to the platform (s. a. LVM2 for Linux for lvm2 header or explorer.exe for Windows for *.bfc files)

doc-ref:  # A YAML array of URIs to information sources and/or their names goes here. MANDATORY. See https://doc.kaitai.io/ksy_reference.html#doc-ref for more info on sources which are not just an URI
  - ref 1
  - ref 2
  - ref 3
  # There are at least 3 kinds of sources complementing each other.
  # * Official specs.
  #    * Pros:
  #      * they usually conduct the meaning the authors of the format wanted to conduct. This can contain insights and details that cannot be reverse-engineered.
  #    * Cons:
  #      * often they don't document extensions by third-parties, even de-facto standards, met in the wild
  #      * often they don't document vendor's own proprietary extensions
  #      * they are often licensed under a proprietary license, so it may be illegal to quote (and modify the quotes) them extensively into `doc` (which is desireable).
  #    * How to find:
  #      * check the official website.
  #      * they are usually in PDF, HTML and RTF formats
  #      * often the spec is missing from the vendor website because the format is no longer relevant and/or is deprecated. Google dork filetype:pdf with a quote from the spec may be useful to find copies on websites of third-parties. web.archive.org is also extremily useful.
  # * Third-party specs. They are often either reverse-engineered or combined from info of other people specs.
  #    * Pros:
  #      * they are often more complete and up-to-date
  #      * they are often available under a license permitting reuse
  #      * they conduct the vision of an independent party
  #    * Cons:
  #      * they usually don't conduct the vision of format authors
  #      * reverse-engineered specs can contain fields which meaning is either unknown or misunderstood
  #    * How to find:
  #      * Usually reside in GitHub, Gist.GitHub and different MediaWiki websites.
  #      * Usually in txt, MarkDown, asciidoc, ReStucturedText and MediaWiki formats.
  # * Open source
  #    * Pros:
  #      * gives insight into poorly documented and/or unofficial details.
  #    * Cons:
  #      * implementer has to reverse-engineer meaning from the code yourself
  #      * the license is often viral, like GPL. you may want to find an impl withna permissive license.
  #    * How to find:
  #      * Search for popular open-source apps or plugins reading and writing this format.
  #      * find their source code
  #      * do fulltext search on the stuff like signature bytes, functions reading files and enums names.
```

```yaml
# This block carries some machine-readable and machine-editable information which is not meant to be a part of the spec itself, but should be definitely useful, especially if it is precessed by a bot automatically. None of this is mandatory, you can delete this block entirely, if you have nothing to put into it.

WiP:
  - # put a link to the dir or the file in your WiP branch here, if you have started working on the format.
issues:
  # add here the ids of issues in https://github.com/kaitai-io/kaitai_struct which are ...
  block:
    # ... required to be solved in order to be able to implement this format;
  affect:
    # ... not strictly prerequisities for this format, but causing us to use nasty workarounds
```

<!--
Insert your free-form description if you feel it is necessary here.
-->
