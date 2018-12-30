meta:
  id: evil_islands_cam
  title: Evil Islands, CAM file (cameras)
  application: Evil Islands
  file-extension: cam
  license: MIT
  endian: le
doc: Camera representation
doc-ref: https://github.com/aspadm/EIrepack/wiki/cam
seq:
  - id: cameras
    type: camera
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
  quat:
    doc: quaternion
    seq:
      - id: w
        type: f4
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  camera:
    doc: Camera parameters
    seq:
      - id: time
        type: f4
      - id: step
        type: f4
      - id: position
        type: vec3
      - id: rotation
        type: quat
