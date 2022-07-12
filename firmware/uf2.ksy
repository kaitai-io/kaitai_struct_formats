meta:
  id: uf2
  title: UF2
  file-extension: uf2
  license: CC0-1.0
  endian: le
doc: |
  UF2 is a file format, developed by Microsoft for PXT (also known as
  Microsoft MakeCode), that is particularly suitable for flashing
  microcontrollers over MSC (Mass Storage Class; aka removable flash drive).

  The list of family-ids is stored in a separate JSON file:

  <https://github.com/microsoft/uf2/blob/master/utils/uf2families.json>

  This file is regularly updated and the family_id enum should be kept in
  sync with this JSON file.

  Test files can be found on the MicroPython website:

  <https://micropython.org/download/rp2-pico/>

doc-ref: https://github.com/microsoft/uf2/blob/b05acf5/README.md
seq:
  - id: uf2_block_start
    type: uf2_block
  - id: uf2_blocks
    type: uf2_block
    repeat: expr
    repeat-expr: uf2_block_start.num_blocks - 1
types:
  uf2_block:
    seq:
      - id: magic
        -orig-id: magicStart0
        contents: "UF2\n"
      - id: second_magic
        -orig-id: magicStart1
        contents: [0x57, 0x51, 0x5d, 0x9e]
      - id: flags
        type: u4
      - id: target_address
        -orig-id: targetAddr
        type: u4
      - id: len_payload
        -orig-id: payloadSize
        type: u4
      - id: block_number
        -orig-id: blockNo
        type: u4
      - id: num_blocks
        -orig-id: numBlocks
        type: u4
      - id: file_size
        type: u4
        if: flags & 0x00002000 == 0
      - id: family_id
        type: u4
        enum: family_id
        if: flags & 0x00002000 != 0
      - id: data
        size: 476
      - id: end_magic
        -orig-id: magicEnd
        contents: [0x30, 0x6f, 0xb1, 0x0a]
enums:
  family_id:
    0x16573617:
      id: atmega32
      doc: "Microchip (Atmel) ATmega32"
    0x1851780a:
      id: saml21
      doc: "Microchip (Atmel) SAML21"
    0x1b57745f:
      id: nrf52
      doc: "Nordic NRF52"
    0x1c5f21b0:
      id: esp32
      doc: "ESP32"
    0x1e1f432d:
      id: stm32l1
      doc: "ST STM32L1xx"
    0x202e3a91:
      id: stm32l0
      doc: "ST STM32L0xx"
    0x21460ff0:
      id: stm32wl
      doc: "ST STM32WLxx"
    0x2abc77ec:
      id: lpc55
      doc: "NXP LPC55xx"
    0x300f5633:
      id: stm32g0
      doc: "ST STM32G0xx"
    0x31d228c6:
      id: gd32f350
      doc: "GD32F350"
    0x04240bdf:
      id: stm32l5
      doc: "ST STM32L5xx"
    0x4c71240a:
      id: stm32g4
      doc: "ST STM32G4xx"
    0x4fb2d5bd:
      id: mimxrt10xx
      doc: "NXP i.MX RT10XX"
    0x53b80f00:
      id: stm32f7
      doc: "ST STM32F7xx"
    0x55114460:
      id: samd51
      doc: "Microchip (Atmel) SAMD51"
    0x57755a57:
      id: stm32f4
      doc: "ST STM32F401"
    0x5a18069b:
      id: fx2
      doc: "Cypress FX2"
    0x5d1a0a2e:
      id: stm32f2
      doc: "ST STM32F2xx"
    0x5ee21072:
      id: stm32f1
      doc: "ST STM32F103"
    0x621e937a:
      id: nrf52833
      doc: "Nordic NRF52833"
    0x647824b6:
      id: stm32f0
      doc: "ST STM32F0xx"
    0x68ed2b88:
      id: samd21
      doc: "Microchip (Atmel) SAMD21"
    0x6b846188:
      id: stm32f3
      doc: "ST STM32F3xx"
    0x6d0922fa:
      id: stm32f407
      doc: "ST STM32F407"
    0x6db66082:
      id: stm32h7
      doc: "ST STM32H7xx"
    0x70d16653:
      id: stm32wb
      doc: "ST STM32WBxx"
    0x7eab61ed:
      id: esp8266
      doc: "ESP8266"
    0x7f83e793:
      id: kl32l2
      doc: "NXP KL32L2x"
    0x8fb060fe:
      id: stm32f407vg
      doc: "ST STM32F407VG"
    0xada52840:
      id: nrf52840
      doc: "Nordic NRF52840"
    0xbfdd4eee:
      id: esp32s2
      doc: "ESP32-S2"
    0xc47e5767:
      id: esp32s3
      doc: "ESP32-S3"
    0xd42ba06c:
      id: esp32c3
      doc: "ESP32-C3"
    0x2b88d29c:
      id: esp32c2
      doc: "ESP32-C2"
    0x332726f6:
      id: esp32h2
      doc: "ESP32-H2"
    0xe48bff56:
      id: rp2040
      doc: "Raspberry Pi RP2040"
    0x00ff6919:
      id: stm32l4
      doc: "ST STM32L4xx"
    0x9af03e33:
      id: gd32vf103
      doc: "GigaDevice GD32VF103"
