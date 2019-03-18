meta:
  id: uimage
  endian: be
  license: CC0-1.0
  title: U-Boot Image wrapper
doc: |
  The new uImage format allows more flexibility in handling images of various
  types (kernel, ramdisk, etc.), it also enhances integrity protection of images
  with sha1 and md5 checksums.
doc-ref: https://github.com/EmcraftSystems/u-boot/blob/master/include/image.h
seq:
  - id: header
    type: uheader
  - id: data
    size: header.len_image
types:
  uheader:
    seq:
      - id: magic
        contents: [0x27, 0x05, 0x19, 0x56]
      - id: header_crc
        type: u4
      - id: timestamp
        type: u4
      - id: len_image
        type: u4
      - id: load_address
        type: u4
      - id: entry_address
        type: u4
      - id: data_crc
        type: u4
      - id: os_type
        type: u1
        enum: uimage_os
      - id: architecture
        type: u1
        enum: uimage_arch
      - id: image_type
        type: u1
        enum: uimage_type
      - id: compression_type
        type: u1
        enum: uimage_comp
      - id: name
        size: 32
        encoding: UTF-8
        type: strz
enums:
  uimage_os:
    0:  
      id: invalid   
      doc: Invalid OS
    1:  
      id: openbsd   
      doc: OpenBSD
    2:  
      id: netbsd    
      doc: NetBSD
    3:  
      id: freebsd   
      doc: FreeBSD
    4:  
      id: bsd4_4    
      doc: 4.4BSD
    5:  
      id: linux     
      doc: Linux
    6:  
      id: svr4      
      doc: SVR4
    7:  
      id: esix      
      doc: Esix
    8:  
      id: solaris   
      doc: Solaris
    9:  
      id: irix      
      doc: Irix
    10: 
      id: sco       
      doc: SCO
    11: 
      id: dell      
      doc: Dell
    12: 
      id: ncr       
      doc: NCR
    13: 
      id: lynxos    
      doc: LynxOS
    14: 
      id: vxworks   
      doc: VxWorks
    15: 
      id: psos      
      doc: pSOS
    16: 
      id: qnx       
      doc: QNX
    17: 
      id: u_boot    
      doc: Firmware
    18: 
      id: rtems     
      doc: RTEMS
    19: 
      id: artos     
      doc: ARTOS
    20: 
      id: unity     
      doc: Unity OS
    21: 
      id: integrity 
      doc: INTEGRITY
  uimage_arch:
    0:  
      id: invalid    
      doc: Invalid CPU
    1:  
      id: alpha      
      doc: Alpha
    2:  
      id: arm        
      doc: ARM
    3:  
      id: i386       
      doc: Intel x86
    4:  
      id: ia64       
      doc: IA64
    5:  
      id: mips       
      doc: MIPS
    6:  
      id: mips64     
      doc: MIPS 64 Bit
    7:  
      id: ppc        
      doc: PowerPC
    8:  
      id: s390       
      doc: IBM S390
    9:  
      id: sh         
      doc: SuperH
    10: 
      id: sparc      
      doc: Sparc
    11: 
      id: sparc64    
      doc: Sparc 64 Bit
    12: 
      id: m68k       
      doc: M68K
    13: 
      id: nios       
      doc: Nios-32
    14: 
      id: microblaze 
      doc: MicroBlaze
    15: 
      id: nios2      
      doc: Nios-II
    16: 
      id: blackfin   
      doc: Blackfin
    17: 
      id: avr32      
      doc: AVR32
    18: 
      id: st200      
      doc: STMicroelectronics ST200
  uimage_comp:
    0: 
      id: none
      doc: No Compression Used
    1: 
      id: gzip 
      doc: gzip Compression Used
    2: 
      id: bzip2
      doc: bzip2 Compression Used
    3: 
      id: lzma 
      doc: lzma Compression Used
    4: 
      id: lzo  
      doc: lzo Compression Used
  uimage_type:
    0:  
      id: invalid    
      doc: Invalid Image
    1:  
      id: standalone 
      doc: Standalone Program
    2:  
      id: kernel     
      doc: OS Kernel Image
    3:  
      id: ramdisk    
      doc: RAMDisk Image
    4:  
      id: multi      
      doc: Multi-File Image
    5:  
      id: firmware   
      doc: Firmware Image
    6:  
      id: script     
      doc: Script file
    7:  
      id: filesystem 
      doc: Filesystem Image (any type)
    8:  
      id: flatdt     
      doc: Binary Flat Device Tree Blob
    9:  
      id: kwbimage   
      doc: Kirkwood Boot Image
    10: 
      id: imximage   
      doc: Freescale IMXBoot Image
