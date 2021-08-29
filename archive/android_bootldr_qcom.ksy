meta:
  id: android_bootldr_qcom
  title: Qualcomm Snapdragon (MSM) bootloader.img format
  file-extension: img
  tags:
    - archive
    - android
  license: CC0-1.0
  endian: le
doc: |
  A bootloader for Android used on various devices powered by Qualcomm
  Snapdragon chips:

  <https://en.wikipedia.org/wiki/Devices_using_Qualcomm_Snapdragon_processors>

  Although not all of the Snapdragon based Android devices use this particular
  bootloader format, it is known that devices with the following chips have
  used it (example devices are given for each chip):

  * APQ8064 ([devices](https://en.wikipedia.org/wiki/Devices_using_Qualcomm_Snapdragon_processors#Snapdragon_S4_Pro))
    - Nexus 4 "mako": [sample][sample-mako] ([other samples][others-mako]),
      [releasetools.py](https://android.googlesource.com/device/lge/mako/+/33f0114/releasetools.py#98)

  * MSM8974AA ([devices](https://en.wikipedia.org/wiki/Devices_using_Qualcomm_Snapdragon_processors#Snapdragon_800,_801_and_805_(2013/14)))
    - Nexus 5 "hammerhead": [sample][sample-hammerhead] ([other samples][others-hammerhead]),
      [releasetools.py](https://android.googlesource.com/device/lge/hammerhead/+/7618a7d/releasetools.py#116)

  * MSM8992 ([devices](https://en.wikipedia.org/wiki/Devices_using_Qualcomm_Snapdragon_processors#Snapdragon_808_and_810_(2015)))
    - Nexus 5X "bullhead": [sample][sample-bullhead] ([other samples][others-bullhead]),
      [releasetools.py](https://android.googlesource.com/device/lge/bullhead/+/2994b6b/releasetools.py#126)

  * APQ8064-1AA ([devices](https://en.wikipedia.org/wiki/Devices_using_Qualcomm_Snapdragon_processors#Snapdragon_600_(2013)))
    - Nexus 7 \[2013] (Mobile) "deb": [sample][sample-deb] ([other samples][others-deb]),
      [releasetools.py](https://android.googlesource.com/device/asus/deb/+/14c1638/releasetools.py#105)
    - Nexus 7 \[2013] (Wi-Fi) "flo": [sample][sample-flo] ([other samples][others-flo]),
      [releasetools.py](https://android.googlesource.com/device/asus/flo/+/9d9fee9/releasetools.py#130)

  * MSM8996 Pro-AB ([devices](https://en.wikipedia.org/wiki/Devices_using_Qualcomm_Snapdragon_processors#Snapdragon_820_and_821_(2016)))
    - Pixel "sailfish": [sample][sample-sailfish] ([other samples][others-sailfish])
    - Pixel XL "marlin": [sample][sample-marlin] ([other samples][others-marlin])

  * MSM8998 ([devices](https://en.wikipedia.org/wiki/Devices_using_Qualcomm_Snapdragon_processors#Snapdragon_835_(2017)))
    - Pixel 2 "walleye": [sample][sample-walleye] ([other samples][others-walleye])
    - Pixel 2 XL "taimen": [sample][sample-taimen] ([other samples][others-taimen])

  On the other hand, devices with these chips **do not** use this format:

  * <del>APQ8084</del> ([devices](https://en.wikipedia.org/wiki/Devices_using_Qualcomm_Snapdragon_processors#Snapdragon_800,_801_and_805_(2013/14)))
    - Nexus 6 "shamu": [sample][foreign-sample-shamu] ([other samples][foreign-others-shamu]),
      [releasetools.py](https://android.googlesource.com/device/moto/shamu/+/df9354d/releasetools.py#12) -
      uses "Motoboot packed image format" instead

  * <del>MSM8994</del> ([devices](https://en.wikipedia.org/wiki/Devices_using_Qualcomm_Snapdragon_processors#Snapdragon_808_and_810_(2015)))
    - Nexus 6P "angler": [sample][foreign-sample-angler] ([other samples][foreign-others-angler]),
      [releasetools.py](https://android.googlesource.com/device/huawei/angler/+/cf92cd8/releasetools.py#29) -
      uses "Huawei Bootloader packed image format" instead

  [sample-mako]: https://androidfilehost.com/?fid=96039337900113996 "bootloader-mako-makoz30f.img"
  [others-mako]: https://androidfilehost.com/?w=search&s=bootloader-mako&type=files

  [sample-hammerhead]: https://androidfilehost.com/?fid=385035244224410247 "bootloader-hammerhead-hhz20h.img"
  [others-hammerhead]: https://androidfilehost.com/?w=search&s=bootloader-hammerhead&type=files

  [sample-bullhead]: https://androidfilehost.com/?fid=11410963190603870177 "bootloader-bullhead-bhz32c.img"
  [others-bullhead]: https://androidfilehost.com/?w=search&s=bootloader-bullhead&type=files

  [sample-deb]: https://androidfilehost.com/?fid=23501681358552487 "bootloader-deb-flo-04.02.img"
  [others-deb]: https://androidfilehost.com/?w=search&s=bootloader-deb-flo&type=files

  [sample-flo]: https://androidfilehost.com/?fid=23991606952593542 "bootloader-flo-flo-04.05.img"
  [others-flo]: https://androidfilehost.com/?w=search&s=bootloader-flo-flo&type=files

  [sample-sailfish]: https://androidfilehost.com/?fid=6006931924117907154 "bootloader-sailfish-8996-012001-1904111134.img"
  [others-sailfish]: https://androidfilehost.com/?w=search&s=bootloader-sailfish&type=files

  [sample-marlin]: https://androidfilehost.com/?fid=6006931924117907131 "bootloader-marlin-8996-012001-1904111134.img"
  [others-marlin]: https://androidfilehost.com/?w=search&s=bootloader-marlin&type=files

  [sample-walleye]: https://androidfilehost.com/?fid=14943124697586348540 "bootloader-walleye-mw8998-003.0085.00.img"
  [others-walleye]: https://androidfilehost.com/?w=search&s=bootloader-walleye&type=files

  [sample-taimen]: https://androidfilehost.com/?fid=14943124697586348536 "bootloader-taimen-tmz30m.img"
  [others-taimen]: https://androidfilehost.com/?w=search&s=bootloader-taimen&type=files

  [foreign-sample-shamu]: https://androidfilehost.com/?fid=745849072291678307 "bootloader-shamu-moto-apq8084-72.04.img"
  [foreign-others-shamu]: https://androidfilehost.com/?w=search&s=bootloader-shamu&type=files

  [foreign-sample-angler]: https://androidfilehost.com/?fid=11410963190603870158 "bootloader-angler-angler-03.84.img"
  [foreign-others-angler]: https://androidfilehost.com/?w=search&s=bootloader-angler&type=files

  ---

  The `bootloader-*.img` samples referenced above originally come from factory
  images packed in ZIP archives that can be found on the page
  [Factory Images for Nexus and Pixel Devices](https://developers.google.com/android/images)
  on the Google Developers site. Note that the codenames on that page may be
  different than the ones that are written in the list above. That's because
  the Google page indicates **ROM codenames** in headings (e.g. "occam" for Nexus 4)
  but the above list uses **model codenames** (e.g. "mako" for Nexus 4)
  because that is how the original `bootloader-*.img` files are identified.
  For most devices, however, these code names are the same.

doc-ref: https://android.googlesource.com/device/lge/hammerhead/+/7618a7d/releasetools.py
seq:
  - id: magic
    contents: BOOTLDR!
  - id: num_images
    type: u4
  - id: ofs_img_bodies
    -orig-id: start_offset
    type: u4
  - id: len_img_bodies
    -orig-id: bootldr_size
    type: u4
  - id: img_info_headers
    type: img_info_header
    repeat: expr
    repeat-expr: num_images
types:
  img_info_header:
    -webide-representation: '{name}'
    seq:
      - id: name
        size: 64
        type: strz
        encoding: UTF-8
      - id: len_body
        type: u4
