meta:
  id: hccapx
  title: Hashcat capture format
  license: Unlicense
  application:
    - Hashcat
    - aircrack-ng
  endian: le
  encoding: utf-8
  file-extension: hccapx
  imports:
    - /network/mac_address
    - /network/802.11/wpa2_nonce
doc: |
  Native format of Hashcat password "recovery" utility
doc-ref: https://hashcat.net/wiki/doku.php?id=hccapx
seq:
  - id: records
    type: hccapx_record
    repeat: eos
types:
  hccapx_record:
    seq:
      - id: signature
        contents: "HCPX"
      - id: version
        type: u4
        doc: the version number of the .hccapx file format

      - id: ignore_replay_counter
        type: b1
        doc: |
          Indicates if the message pair matching was done based on replay counter or not.
          Whenever it was set to 1 it means that the replay counter was ignored (i.e. it was not considered at all by the matching algorithm).
          Hashcat currently does not perform any particular action based on this bit, but nonetheless this information could be crucial for some 3th party tools and for analysis/statistics. There could be some opportunity to implement some further logic based on this particular information also within hashcat (in the future).
      - id: message_pair_number
        type: b7
        doc: |
          The message_pair value describes which messages of the 4-way handshake were combined to form the .hccapx structure. It is always a pair of 2 messages: 1 from the AP (access point) and 1 from the STA (client).
          Furthermore, the message_pair value also gives a hint from which of the 2 messages the EAPOL origins. This is interesting data, but not necessarily needed for hashcat to be able to crack the hash.
          On the other hand, it could be very important to know if “only” message 1 and message 2 were captured or if for instance message 3 and/or message 4 were captured too. If message 3 and/or message 4 were captured it should be a hard evidence that the connection was established and that the password the client used was the correct one.
          
          In the table below the braced message is the source of eapol
          No  AP1  STA1   AP2 STA2
          000  M1  (M2)
          001  M1             (M4)
          010      (M2)   M3
          011       M2   (M3)
          100	           (M3)  M4
          101	            M3  (M4)
      - id: essid_len
        type: u1
      - id: essid
        type: str
        size: 32
        
      - id: keyver
        type: u4
        doc: the flag used to distinguish WPA from WPA2 ciphers. Value of 1 means WPA, other - WPA2
      - id: keymic
        size: 16
        doc: the final hash value. MD5 for WPA and SHA-1 for WPA2 (truncated to 128 bit) 
      
      - id: ap
        type: mac_nonce_pair
        doc: the data of the access point 
        
      - id: station
        type: mac_nonce_pair
        doc: data of client connecting to the access point

      - id: eapol_len
        type: u1
        doc: the length of the EAPOL

      - id: eapol
        size: eapol_len
      - id: eapol_padding
        size: 256 - eapol_len
    types:
      mac_nonce_pair:
        seq:
          - id: mac
            type: mac_address
            doc: the mac address
          - id: nonce
            type: wpa2_nonce
            doc: nonce (random salt)
