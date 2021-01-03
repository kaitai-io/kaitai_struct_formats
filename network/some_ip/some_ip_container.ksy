meta:
  id: some_ip_container
  title: AUTOSAR SOME/IP container
  license: CC0-1.0
  ks-version: 0.9
  endian: be
  imports:
    - /network/some_ip/some_ip

seq:
  - id: some_ip_packages
    type: some_ip
    repeat: eos
