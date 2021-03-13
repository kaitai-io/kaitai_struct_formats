meta:
  id: mmd_vmd
  title: MMD (MikuMikuDance) motion data
  application: MikuMikuDance
  file-extension: vmd
  encoding: Shift_JIS
  endian: le
  license: MIT

doc: |
  VMD is the format used by MikuMikuDance (MMD) for storing animation data.
  A VMD file can contain data for character motion and cameras, but VMD
  files tend to contain either one or the other, not both.

seq:
  - id: header
    type: header
  - id: motion_count
    type: u4
  - id: motions
    type: motion
    repeat: expr
    repeat-expr: motion_count
  - id: morph_count
    type: u4
  - id: morphs
    type: morph
    repeat: expr
    repeat-expr: morph_count
  - id: camera_count
    type: u4
  - id: cameras
    type: camera
    repeat: expr
    repeat-expr: camera_count
  - id: reserved
    contents: "\0\0\0\0\0\0\0\0"

types:

  header:
    seq:
      - id: magic
        contents: "Vocaloid Motion Data 0002\0\0\0\0\0"
      - id: name
        type: strz
        size: 20

  motion:
    seq:
      - id: bone_name
        type: strz
        size: 15
      - id: frame_number
        type: u4
      - id: position
        type: f4_3
      - id: rotation
        type: f4_4
      - id: interpolation
        type: u1
        repeat: expr
        repeat-expr: 64

  morph:
    seq:
      - id: morph_name
        type: strz
        size: 15
      - id: frame_number
        type: u4
      - id: weight
        type: f4

  camera:
    seq:
      - id: frame_number
        type: u4
      - id: distance
        type: f4
      - id: position
        type: f4_3
      - id: rotation
        type: f4_3
      - id: interpolation
        type: u1
        repeat: expr
        repeat-expr: 24
      - id: fov
        type: u4
      - id: perspective
        type: u1

  f4_3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4

  f4_4:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: w
        type: f4
