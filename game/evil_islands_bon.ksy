meta:
  id: evil_islands_bon
  title: Evil Islands, BON file (bone position)
  application: Evil Islands
  file-extension: bon
  license: MIT
  endian: le
doc: Bone position
doc-ref: https://github.com/aspadm/EIrepack/wiki/bon
seq:
  - id: position
    type: vec3
    repeat: eos
types:
  vec3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
