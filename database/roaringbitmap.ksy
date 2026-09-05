doc: |
  Roaring bitmaps are compressed bitmaps which tend to outperform
  conventional compressed bitmaps such as WAH, EWAH or Concise.

  They are used by several important systems:

  * Apache Lucene and derivative systems such as Solr and Elastic
  * Metamarkets' Druid
  * Apache Spark
  * Apache Hive
  * Apache Tez
  * Netflix Atlas
  * LinkedIn Pinot
  * and many others

  Roaring bitmaps are designed to store sets of 32-bit unsigned integers efficiently.
  They use a two-level structure: the 32-bit integers are split into
  16-bit "chunks" (most significant bits + least significant bits).
  Each chunk is stored in a container, of which there are three types:
  array, bitset, and run containers.

meta:
  id: roaringbitmap
  title: Roaring Bitmap Portable Format
  license: Apache-2.0
  endian: le

seq:
  - id: magic
    type: u2
    enum: cookie
    doc: |
      Magic cookie value that identifies the type of Roaring Bitmap format.
      12346 (SERIAL_COOKIE_NO_RUNCONTAINER) means no run containers are used.
      12347 (SERIAL_COOKIE) means run containers may be present.

  - id: header
    type:
      switch-on: magic
      cases:
        'cookie::no_runs': header_no_runs
        'cookie::with_runs': header_with_runs
    doc: |
      Header structure that follows the magic cookie value.
      The structure differs depending on whether run containers are used or not.

  - id: container_meta
    type: container_meta
    repeat: expr
    repeat-expr: num_containers
    doc: |
      Descriptive header containing the key (16 most significant bits) and
      cardinality of each container.

  - id: offset_header
    if: (not has_runs) or (num_containers >= 4)
    type: u4
    repeat: expr
    repeat-expr: num_containers
    doc: |
      Offset header containing the byte offsets of each container from the beginning
      of the stream. This is included if either:
      1. No run containers are present, or
      2. There are at least NO_OFFSET_THRESHOLD (4) containers

  - id: containers
    type:
      switch-on: >
        (
          has_runs
          ? (
            header.as<header_with_runs>.run_bitset[_index / 8] & (1 << (_index % 8))
          ) != 0
          : false
        )
        ? 1
        : container_meta[_index].cardinality_minus_1 + 1 <= 4096 ? 2 : 3
      cases:
        1: run_container
        2: array_container(container_meta[_index].cardinality_minus_1 + 1)
        3: bitset_container
    repeat: expr
    repeat-expr: num_containers
    doc: |
      The actual container data. The type is determined by:
      - If run containers are allowed and the run_bitset indicates this container is a run container, use run_container (type 1)
      - Otherwise, if the container's cardinality is <= 4096, use array_container (type 2)
      - Otherwise, use bitset_container (type 3)

instances:
  has_runs:
    value: magic == cookie::with_runs
    doc: |
      Computed field that indicates whether this Roaring bitmap may contain run containers.

  num_containers:
    value: >
      has_runs ? (header.as<header_with_runs>.num_containers_minus_1 + 1) : header.as<header_no_runs>.num_containers
    doc: |
      Computed field that returns the number of containers in the bitmap.
      For backwards compatibility, the encoding differs depending on whether run containers are present.

types:
  header_no_runs:
    doc: |
      Header format for bitmaps that don't use run containers.
      This contains a 32-bit value (SERIAL_COOKIE_NO_RUNCONTAINER)
      followed by 32 bits for the number of containers.
    seq:
      - contents: [0, 0]
        doc: Two zeros to complete the 32-bit cookie (after the initial 16-bit magic)
      - id: num_containers
        type: u4
        doc: Number of containers in this bitmap

  header_with_runs:
    doc: |
      Header format for bitmaps that may use run containers.
      The 16-bit cookie's most significant bits store the number of containers minus 1.
      A run container bitset follows, with a 1 bit indicating the container is a run container.
    seq:
      - id: num_containers_minus_1
        type: u2
        doc: Number of containers minus 1 (to allow encoding 65536 containers)
      - id: run_bitset
        size: (num_containers_minus_1 + 1 + 7) / 8
        doc: |
          Bitset indicating which containers are run containers (1 bit) vs array/bitset (0 bit).
          The least significant bit of the first byte corresponds to the first container.

  container_meta:
    doc: |
      Metadata for a single container, consisting of its key (16 most significant bits)
      and its cardinality minus 1 (to allow encoding full 65536 cardinality).
    seq:
      - id: key
        type: u2
        doc: Container key (16 most significant bits of the integers in this container)
      - id: cardinality_minus_1
        type: u2
        doc: |
          Container cardinality minus 1. This is used to determine whether a
          container is an array container (cardinality <= 4096) or a bitset container.

  run_container:
    doc: |
      Run container format, storing sorted runs of consecutive integers.
      More space-efficient for data with long consecutive runs of values.
      Runs are non-overlapping and sorted.
    seq:
      - id: num_runs
        type: u2
        doc: Number of runs in this container
      - id: runs
        type: run
        repeat: expr
        repeat-expr: num_runs
        doc: Array of runs (start value and length pairs)

  run:
    doc: |
      A run of consecutive integers, represented by a starting value and a length.
    seq:
      - id: start_idx
        type: u2
        doc: Starting value of the run
      - id: count_minus_1
        type: u2
        doc: |
          Length of the run minus 1. For example, a run of [11,12,13,14,15]
          would be encoded as start_idx=11, count_minus_1=4.

  array_container:
    doc: |
      Array container storing a sorted array of 16-bit integers.
      Used when the container has relatively few values (cardinality <= 4096).
    params:
      - id: num_values
        type: u2
        doc: Number of values in this array container
    seq:
      - id: values
        type: u2
        repeat: expr
        repeat-expr: num_values
        doc: Sorted array of 16-bit values in this container

  bitset_container:
    doc: |
      Bitset container using a 65536-bit bitset (8KB) to represent which
      values are present. Used when the container has many values (cardinality > 4096).
    seq:
      - id: bitset
        size: 8 * 1024
        doc: |
          A dense 8KB bitset (2^16 bits).

enums:
  cookie:
    12346: no_runs
    12347: with_runs
