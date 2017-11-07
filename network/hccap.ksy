meta:
  id: hccap
  title: Hashcat capture old format
  license: Unlicense
  file-extension: hccap
  application:
    - Hashcat
    - aircrack-ng
  endian: le
  encoding: utf-8
  imports:
    - /network/mac_address
    - /network/802.11/wpa2_nonce
doc: |
  Native format of Hashcat password "recovery" utility
  A sample of file for testing can be downloaded from https://web.archive.org/web/20150220013635if_/http://hashcat.net:80/misc/example_hashes/hashcat.hccap
doc-ref: https://hashcat.net/wiki/doku.php?id=hccap
seq:
  - id: records
    type: hccap_record
    repeat: eos
types:
  hccap_record:
    seq:
      - id: essid
        type: strz
        size: 36
        
      - id: ap_mac
        type: mac_address
        doc: the bssid(MAC) of the access point 
      
      - id: station_mac 
        type: mac_address
        doc: the MAC address of a client connecting to the access point 
        
      - id: station_nonce
        type: wpa2_nonce
      
      - id: ap_nonce
        type: wpa2_nonce
        
      - id: eapol_buffer
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
    instances:
      eapol:
        io: eapol_buffer._io
        pos: 0
        size: eapol_size
