meta:
  id: u_image
  endian: be
seq:
  - id: header
    type: u_header
  - id: data
    size: header.image_size
types:
  u_header:
    seq:
      - id: magic
        contents: [0x27, 0x05, 0x19, 0x56]
      - id: header_crc
        type: u4
      - id: timestamp
        type: u4
      - id: image_size
        type: u4
      - id: load_address
        type: u4
      - id: entry_address
        type: u4
      - id: data_crc
        type: u4
      - id: os_type
        type: u1
        enum: os
      - id: architecture
        type: u1
        enum: arch
      - id: image_type
        type: u1
        enum: t
      - id: compression_type
        type: u1
        enum: comp
      - id: name
        size: 32
        encoding: UTF-8
        type: strz
enums:
  os:
    0:  invalid   # Invalid OS 
    1:  openbsd   # OpenBSD  
    2:  netbsd    # NetBSD 
    3:  freebsd   # FreeBSD  
    4:  bsd4_4    # 4.4BSD 
    5:  linux     # Linux  
    6:  svr4      # SVR4   
    7:  esix      # Esix   
    8:  solaris   # Solaris  
    9:  irix      # Irix   
    10: sco       # SCO    
    11: dell      # Dell   
    12: ncr       # NCR    
    13: lynxos    # LynxOS 
    14: vxworks   # VxWorks  
    15: psos      # pSOS   
    16: qnx       # QNX    
    17: u_boot    # Firmware 
    18: rtems     # RTEMS  
    19: artos     # ARTOS  
    20: unity     # Unity OS 
    21: integrity # INTEGRITY  
  arch:
    0:  invalid    # Invalid CPU 
    1:  alpha      # Alpha 
    2:  arm        # ARM   
    3:  i386       # Intel x86 
    4:  ia64       # IA64  
    5:  mips       # MIPS  
    6:  mips64     # MIPS  64 Bit
    7:  ppc        # PowerPC 
    8:  s390       # IBM S390
    9:  sh         # SuperH
    10: sparc      # Sparc 
    11: sparc64    # Sparc 64 Bit
    12: m68k       # M68K  
    13: nios       # Nios-32 
    14: microblaze # MicroBlaze  
    15: nios2      # Nios-II 
    16: blackfin   # Blackfin
    17: avr32      # AVR32 
    18: st200      # STMicroelectronics ST200 
  comp:
    0: none   # No   Compression Used
    1: gzip   # gzip  Compression Used
    2: bzip2  # bzip2 Compression Used
    3: lzma   # lzma  Compression Used
    4: lzo    # lzo   Compression Used
  t:
    0:  invalid    # Invalid Image       
    1:  standalone # Standalone Program      
    2:  kernel     # OS Kernel Image     
    3:  ramdisk    # RAMDisk Image       
    4:  multi      # Multi-File Image    
    5:  firmware   # Firmware Image      
    6:  script     # Script file         
    7:  filesystem # Filesystem Image (any type) 
    8:  flatdt     # Binary Flat Device Tree Blob
    9:  kwbimage   # Kirkwood Boot Image     
    10: imximage   # Freescale IMXBoot Image 