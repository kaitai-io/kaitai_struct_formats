meta:
  id: rtpdump
  title: Rtpdump (rtptools)
  file-extension:
    - rtp
    - rtpdump
  license: Unlicense
  imports:
    - /network/rtp_packet
  endian: be
doc: |
  rtpdump is a format used by rtptools to record and replay
  rtp data from network capture.
doc-ref: https://chromium.googlesource.com/external/webrtc/stable/talk/+/master/media/base/rtpdump.h
seq:
  - id: file_header
    type: header_t
  - id: packets
    type: packet_t
    repeat: eos
types:
  header_t:
    seq:
      - id: shebang
        contents: '#!rtpplay1.0'
      - id: space
        contents: ' '
      - id: ip
        type: str
        encoding: ascii
        terminator: 0x2f # '/'
      - id: port
        type: str
        encoding: ascii
        terminator: 0x0a # '\n'
      - id: start_sec
        type: u4
        doc: |
          start of recording, the seconds part.
      - id: start_usec
        type: u4
        doc: |
          start of recording, the microseconds part.
      - id: ip2
        type: u4
        doc: |
          network source.
      - id: port2
        type: u2
        doc: |
          port.
      - id: padding
        type: u2
        doc: |
          2 bytes padding.
  packet_t:
    seq:
      - id: length
        type: u2
        doc: |
          packet length (including this header).
      - id: len_body
        type: u2
        doc: |
          payload length.
      - id: packet_usec
        type: u4
        doc: |
          timestamp of packet since the start.
      - id: body
        size: len_body
        type: rtp_packet
