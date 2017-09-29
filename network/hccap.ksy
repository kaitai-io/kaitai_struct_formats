meta:
  id: hccap
  title: Hashcat capture old format
  license: Unlicense
  application:
    - Hashcat
    - aircrack-ng
  endian: le
  encoding: utf-8
doc: |
  Native format of Hashcat password "recovery" utility
  A sample of file for testing can be downloaded from https://web.archive.org/web/20150220013635if_/http://hashcat.net:80/misc/example_hashes/hashcat.hccap
doc-ref: https://hashcat.net/wiki/doku.php?id=hccap
seq:
  - id: records
    type: hccap
    repeat: eos
types:
  hccap:
    seq:
      - id: essid
        type: strz
        size: 36
        
      - id: bssid
        type: mac
        doc: the bssid(MAC) of the access point 
      
      - id: stmac 
        type: mac
        doc: the MAC address of a client connecting to the access point 
        
      - id: snonce
        type: nonce
      
      - id: anonce
        type: nonce
        
      - id: eapol
        size: 256
        
      - id: eapol_size
        type: u4
        doc: size of eapol

      - id: keyver
        type: u4
        doc: the flag used to distinguish WPA from WPA2 ciphers. Value of 1 means WPA, other - WPA2
      
      - id: keymic
        size: 16
        doc: the final hash value. MD5 for WPA and SHA-1 for WPA2 (truncated to 128 bit) 
    types:
      mac:
        seq:
          - id: addr
            type: u1
            repeat: expr
            repeat-expr: 6
      nonce:
        doc: random salt used for handshake by both parties 
        seq:
          - id: data
            size: 32