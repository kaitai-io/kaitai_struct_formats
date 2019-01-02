meta:
  id: openpgp_message
  title: OpenPGP message
  license: MIT
  file-extension: 
    - gpg
    - pub
    - pgp
  xref:
    justsolve: PGP
    rfc: 4880
    wikidata: Q2141493
  endian: be
  encoding: UTF-8
doc: The OpenPGP Message Format is a format to store encryption and signature keys for emails.
doc-ref: https://tools.ietf.org/html/rfc4880
seq:
 - id: packets
   type: packet
   repeat: eos
types:
  packet:
    -webide-representation: '{packet_type_old}'
    seq:
      - id: one
        type: b1
      - id: new_packet_format
        type: b1
      - id: packet_type_new
        type: b6
        if: new_packet_format
        enum: packet_tags
      - id: packet_type_old
        type: b4
        if: not new_packet_format
        enum: packet_tags
      - id: len_type
        type: b2
        if: not new_packet_format
      - id: body
        type: 
          switch-on: new_packet_format
          cases:
            #true: new_packet
            false: old_packet
            
  old_packet:
    seq:
      - id: len
        type: 
          switch-on: _parent.len_type
          cases:
            0: u1
            1: u2
            2: u4
      - id: body
        size: len
        type:
          switch-on: _parent.packet_type_old
          cases:
            packet_tags::user_id_packet: user_id_packet
            packet_tags::signature_packet: signature_packet
            packet_tags::public_key_packet: public_key_packet
            packet_tags::public_subkey_packet: public_key_packet
            packet_tags::secret_key_packet: secret_key_packet
            packet_tags::secret_subkey_packet: public_key_packet
  
  public_key_packet:
    seq:
      - id: version
        type: u1
      - id: timestamp
        type: u4
      - id: public_key_algorithm
        type: u1
        enum: public_key_algorithms
      - id: len_alg
        type: u2
      - id: rsa_n
        size: len_alg / 8
      - id: padding
        type: u2
      - id: rsa_e
        size: 3
      
  user_id_packet:
    seq:
      - id: user_id
        size-eos: true
        type: str

  signature_packet:
    seq: 
      - id: version
        type: u1
        # enum: TODO switch?
      - id: signature_type
        type: u1
        # enum: TODO 5.2.1
      - id: public_key_algorithm
        type: u1
        enum: public_key_algorithms
      - id: hash_algorithm
        type: u1
        enum: hash_algorithms
      - id: len_hashed_subpacket
        type: u2
      - id: hashed_subpackets
        type: subpackets
        size: len_hashed_subpacket
      - id: len_unhashed_subpacket
        type: u2
      - id: unhashed_subpackets
        type: subpackets
        size: len_unhashed_subpacket
      - id: left_signed_hash
        type: u2
      - id: rsa_n
        type: u2
      - id: signature
        size-eos: true
    
  secret_key_packet:
    seq:
      - id: public_key
        type: public_key_packet
      - id: string_to_key
        type: u1
      - id: symmetric_encryption_algorithm
        type: u1
        enum: symmetric_key_algorithm
        if: string_to_key >= 254
      - id: secret_key
        size-eos: true
        
  subpackets:
    seq:
      - id: subpacketss
        type: subpacket
        repeat: eos
  
  subpacket:
    seq:
      - id: len
        type: len_subpacket
      - id: subpacket_type
        type: u1
        enum: subpacket_types
      - id: content
        size: len.len - 1
        type: 
          switch-on: subpacket_type
          cases:
            subpacket_types::signature_creation_time: signature_creation_time
            subpacket_types::issuer: issuer
            subpacket_types::key_expiration_time: key_expiration_time
            subpacket_types::preferred_hash_algorithms: preferred_hash_algorithms
            subpacket_types::preferred_compression_algorithms: preferred_compression_algorithms
            subpacket_types::signature_expiration_time: signature_expiration_time
            subpacket_types::exportable_certification: exportable_certification
            subpacket_types::revocable: revocable
            subpacket_types::trust_signature: trust_signature
            subpacket_types::regular_expression: regular_expression
            subpacket_types::revocation_key: revocation_key
            subpacket_types::notation_data: notation_data
            subpacket_types::key_server_preferences: key_server_preferences
            subpacket_types::preferred_key_server: preferred_key_server
            subpacket_types::primary_user_id: primary_user_id
            subpacket_types::policy_uri: policy_uri
            subpacket_types::key_flags: key_flags
            subpacket_types::signers_user_id: signers_user_id
            subpacket_types::reason_for_revocation: reason_for_revocation
            subpacket_types::features: features
            subpacket_types::signature_target: signature_target
            subpacket_types::embedded_signature: embedded_signature
      
  len_subpacket:
    -webide-representation: '{len}'
    seq:
      - id: first_octet
        type: u1
      - id: second_octet
        type: u1
        if: first_octet >= 192 and first_octet < 255
      - id: scalar
        type: u4
        if: first_octet == 255
    instances:
      len:
        value: 'first_octet < 192 ? first_octet : ((first_octet >= 192 and first_octet < 255) ? (((first_octet - 192) << 8) + second_octet + 192) : scalar)'
      
  signature_creation_time:
    seq:
      - id: time
        type: u4
        
  issuer:
    seq:
      - id: keyid
        type: u8
  
  key_expiration_time:
    seq:
      - id: time
        type: u4
  
  preferred_hash_algorithms:
    seq:
      - id: algorithm
        type: u1
        enum: hash_algorithms
        repeat: eos
  
  preferred_compression_algorithms:
    seq:
      - id: algorithm
        type: u1
        enum: compression_algorithms
        repeat: eos
        
  signature_expiration_time:
    seq:
      - id: time
        type: u4
        
  exportable_certification:
    seq:
      - id: exportable
        type: u1
        
  revocable:
    seq:
      - id: revocable
        type: u1
  
  trust_signature:
    seq:
      - id: level
        type: u1
      - id: amount
        type: u1
        
  regular_expression:
    seq:
      - id: regex
        type: strz
        
  revocation_key:
    seq:
      - id: class
        type: u1
      - id: public_key_algorithm
        enum: public_key_algorithms
        type: u1
      - id: fingerprint
        size: 20
        
  notation_data:
    seq:
      - id: flags
        size: 4
      - id: len_name
        type: u2
      - id: len_value
        type: u2 
      - id: name
        size: len_name
      - id: value
        size: len_value

  key_server_preferences:
    seq:
      - id: flag
        type: u1
        enum: server_flags
        repeat: eos
    
  preferred_key_server:
    seq:
      - id: uri
        type: str
        size-eos: true
        
  primary_user_id:
    seq:
      - id: user_id
        type: u1

  policy_uri:
    seq:
      - id: uri
        type: str
        size-eos: true
    
  key_flags:
    seq:
      - id: flag
        type: u1
        enum: key_flags
        repeat: eos
      
  signers_user_id:
    seq:
      - id: user_id
        type: str
        size-eos: true
        
  reason_for_revocation:
    seq:
      - id: revocation_code
        type: u1
        enum: revocation_codes
      - id: reason
        type: str
        size-eos: true
  
  features:
    seq:
      - id: flags
        size-eos: true
        
  signature_target:
    seq:
      - id: public_key_algorithm
        type: u1
        enum: public_key_algorithms
      - id: hash_algorithm
        type: u1
        enum: hash_algorithms
      - id: hash
        size-eos: true
        
  embedded_signature:
    seq:
      - id: signature_packet
        type: signature_packet
        
enums:
  packet_tags:
    0: reserved_a_packet_tag_must_not_have_this_value
    1: public_key_encrypted_session_key_packet
    2: signature_packet
    3: symmetric_key_encrypted_session_key_packet
    4: one_pass_signature_packet
    5: secret_key_packet
    6: public_key_packet
    7: secret_subkey_packet
    8: compressed_data_packet
    9: symmetrically_encrypted_data_packet
    10: marker_packet
    11: literal_data_packet
    12: trust_packet
    13: user_id_packet
    14: public_subkey_packet
    17: user_attribute_packet
    18: sym_encrypted_and_integrity_protected_data_packet
    19: modification_detection_code_packet
    60: private_or_experimental_values_0
    61: private_or_experimental_values_1
    62: private_or_experimental_values_2
    63: private_or_experimental_values_3

  public_key_algorithms:
    1: rsa_encrypt_or_sign_hac
    2: rsa_encrypt_only_hac
    3: rsa_sign_only_hac
    16: elgamal_encrypt_only_elgamal_hac
    17: dsa_digital_signature_algorithm_fips_hac
    18: reserved_for_elliptic_curve
    19: reserved_for_ecdsa
    20: reserved_formerly_elgamal_encrypt_or_sign_
    21: reserved_for_diffie_hellman_x_as_defined_for_ietf_s_mime
    100: private_experimental_algorithm_00
    101: private_experimental_algorithm_01
    102: private_experimental_algorithm_02
    103: private_experimental_algorithm_03
    104: private_experimental_algorithm_04
    105: private_experimental_algorithm_05
    106: private_experimental_algorithm_06
    107: private_experimental_algorithm_07
    108: private_experimental_algorithm_08
    109: private_experimental_algorithm_09
    110: private_experimental_algorithm_10

  symmetric_key_algorithm:
    0: plain
    1: idea
    2: triple_des
    3: cast5
    4: blowfisch
    5: reserved_5
    6: reserved_6
    7: aes_128
    8: aes_192
    9: aes_256
    10: twofish_256
    100: private_experimental_algorithm_00
    101: private_experimental_algorithm_01
    102: private_experimental_algorithm_02
    103: private_experimental_algorithm_03
    104: private_experimental_algorithm_04
    105: private_experimental_algorithm_05
    106: private_experimental_algorithm_06
    107: private_experimental_algorithm_07
    108: private_experimental_algorithm_08
    109: private_experimental_algorithm_09
    110: private_experimental_algorithm_10

  hash_algorithms:
    1: md5
    2: sha1
    3: ripemd160
    4: reserved_4
    5: reserved_5
    6: reserved_6
    7: reserved_7
    8: sha256
    9: sha384
    10: sha512
    11: sha224
    100: private_experimental_algorithm_00
    101: private_experimental_algorithm_01
    102: private_experimental_algorithm_02
    103: private_experimental_algorithm_03
    104: private_experimental_algorithm_04
    105: private_experimental_algorithm_05
    106: private_experimental_algorithm_06
    107: private_experimental_algorithm_07
    108: private_experimental_algorithm_08
    109: private_experimental_algorithm_09
    110: private_experimental_algorithm_10

  compression_algorithms:
    0: uncompressed
    1: zib
    2: zlib
    3: bzip
    100: private_experimental_algorithm_00
    101: private_experimental_algorithm_01
    102: private_experimental_algorithm_02
    103: private_experimental_algorithm_03
    104: private_experimental_algorithm_04
    105: private_experimental_algorithm_05
    106: private_experimental_algorithm_06
    107: private_experimental_algorithm_07
    108: private_experimental_algorithm_08
    109: private_experimental_algorithm_09
    110: private_experimental_algorithm_10
    
  subpacket_types:
    0: reserved
    1: reserved
    2: signature_creation_time
    3: signature_expiration_time
    4: exportable_certification
    5: trust_signature
    6: regular_expression
    7: revocable
    8: reserved
    9: key_expiration_time
    10: placeholder_for_backward_compatibility
    11: preferred_symmetric_algorithms
    12: revocation_key
    13: reserved
    14: reserved
    15: reserved
    16: issuer
    17: reserved
    18: reserved
    19: reserved
    20: notation_data
    21: preferred_hash_algorithms
    22: preferred_compression_algorithms
    23: key_server_preferences
    24: preferred_key_server
    25: primary_user_id
    26: policy_uri
    27: key_flags
    28: signers_user_id
    29: reason_for_revocation
    30: features
    31: signature_target
    32: embedded_signature
    
  server_flags:
    0x80: no_modify
    
  key_flags:
    0x01: this_key_may_be_used_to_certify_other_keys
    0x02: this_key_may_be_used_to_sign_data
    0x04: this_key_may_be_used_to_encrypt_communications
    0x08: this_key_may_be_used_to_encrypt_storage
    0x10: the_private_component_of_this_key_may_have_been_split_by_a_secret_sharing_mechanism
    0x20: this_key_may_be_used_for_authentication
    0x80: the_private_component_of_this_key_may_be_in_the_possession_of_more_than_one_person

  revocation_codes:
    0: no_reason_specified_key_revocations_or_cert_revocations
    1: key_is_superseded_key_revocations
    2: key_material_has_been_compromised_key_revocations
    3: key_is_retired_and_no_longer_used_key_revocations
    32: user_id_information_is_no_longer_valid_cert_revocations
    100: private_use_1
    101: private_use_2
    102: private_use_3
    103: private_use_4
    110: private_use_11
   
