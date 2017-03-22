meta:
  id: option_rom
  title: legacy BIOS Option ROM
  application: x86 architecture
  endian: le
  file-extension:
    - rom
    - bin
    - lom
  license: Unlicense
  imports:
    - /firmware/pci_expansion_rom_header
doc: >
  Optionrom is a legacy BIOS module. They are used for various purposes such as initializing devices, providing antibootkit features, boot managers, PXE boot, RAID managers, etc ... These modules are usually stored in PCI device's and motherboard onboard flash memory, retrieved and executed by BIOS when booting.
  There are several ways to obtain them:
    * You can get them online:
      * https://www.bios-mods.com/resources/index.php?dir=Option+Roms%2F
      * http://www.win-raid.com/f13-BIOS-modules-PCI-ROM-EFI-and-others.html
      * https://www.techpowerup.com/vgabios/
      * various vendors' FTPs. I only know:
        * [JMicron's](ftp://driver.jmicron.com.tw/SATA_Controller/Option_ROM/)
        * [Realtek's](http://www.realtek.com/downloads/downloadsView.aspx?Langid=1&PNid=13&PFid=5&Level=5&Conn=4&DownTypeID=3&GetDown=false)
    * You can obtain a BIOS for a motherboard
      * by downloading them from Internet
        * http://bios.rom.by/bios/catalog.htm
        * https://www.bios-mods.com/
        * http://www.win-raid.com/
        * https://forums.mydigitallife.info/
        * motherboard and notebook vendors' websites where they provide BIOS updates
      * by downloading from motherboard onboard flash
        * using universal [flashrom](https://www.flashrom.org) tool for Linux
        * using vendors' tools for DOS
      and then extracting modules from it using well-known tools:
        * cbrom and modbin for Award/Phoenix
        * mibcp and mmtool for AMI
        * binwalk
    * You can read them from boards in your PC through PCI configuration space. On Linux you can use [sysfs](https://www.kernel.org/doc/Documentation/filesystems/sysfs-pci.txt), on Windows - [rweverything (for now it's offline)](https://web.archive.org/http://rweverything.com/download/).
seq:
  - id: option_rom_header
    type: pci_expansion_rom_header
  #- id: option_rom_contents
  #  size: option_rom_header.optrom_len*512-19