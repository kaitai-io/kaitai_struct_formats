meta:
  id: icc_4
  title: ICC profile, version 4
  license: CC0-1.0
  encoding: ASCII
  endian: be
seq:
  - id: header
    type: profile_header
  - id: tag_table
    type: tag_table
types:
  profile_header:
    seq:
      - id: size
        type: u4
      - id: preferred_cmm_type
        type: u4
        enum: cmm_signatures
      - id: version
        type: version_field
      - id: device_class
        type: u4
        enum: profile_classes
      - id: color_space
        type: u4
        enum: data_colour_spaces
      - id: pcs
        type: str
        size: 4
      - id: creation_date_time
        type: date_time_number
      - id: file_signature
        contents: [0x61, 0x63, 0x73, 0x70]
      - id: primary_platform
        type: u4
        enum: primary_platforms
      - id: profile_flags
        type: profile_flags
      - id: device_manufacturer
        type: device_manufacturer
      - id: device_model
        type: str
        size: 4
      - id: device_attributes
        type: device_attributes
      - id: rendering_intent
        type: u4
        enum: rendering_intents
      - id: nciexyz_values_of_illuminant_of_pcs
        type: xyz_number
      - id: creator
        type: device_manufacturer
      - id: identifier
        size: 16
      - id: reserved_data
        size: 28
    types:
      version_field:
        seq:
          - id: major
            contents: [0x04]
          - id: minor
            type: b4
          - id: bug_fix_level
            type: b4
          - id: reserved
            contents: [0x00, 0x00]
      profile_flags:
        seq:
          - id: embedded_profile
            type: b1
          - id: profile_can_be_used_independently_of_embedded_colour_data
            type: b1
          - id: other_flags
            type: b30
    enums:
      cmm_signatures:
        0x41444245: adobe_cmm #ADBE
        0x41434D53: agfa_cmm #ACMS
        0x6170706C: apple_cmm #appl
        0x43434D53: color_gear_cmm #CCMS
        0x5543434D: color_gear_cmm_lite #UCCM
        0x55434D53: color_gear_cmm_c #UCMS
        0x45464920: efi_cmm #EFI
        0x46462020: fuji_film_cmm #FF
        0x45584143: exact_scan_cmm #EXAC
        0x48434d4D: harlequin_rip_cmm #HCMM
        0x6172676C: argyll_cms_cmm #argl
        0x44676f53: logosync_cmm #LgoS
        0x48444d20: heidelberg_cmm #HDM
        0x6C636d73: little_cms_cmm #lcms
        0x4b434d53: kodak_cmm #kcms
        0x4d434d44: konica_minolta_cmm #MCML
        0x57435320: windows_color_system_cmm #WCS
        0x5349474E: mutoh_cmm #SIGN
        0x52474d53: device_link_cmm #RGMS
        0x53494343: sample_icc_cmm #SICC
        0x54434d4d: toshiba_cmm #TCMM
        0x33324254: the_imaging_factory_cmm #32BT
        0x57544720: ware_to_go_cmm #WTG
        0x7a633030: zoran_cmm #zc00
      profile_classes:
        0x73636E72: input_device_profile #scnr
        0x6D6E7472: display_device_profile #mntr
        0x70727472: output_device_profile #prtr
        0x6C696E6B: device_link_profile #link
        0x73706163: color_space_profile #spac
        0x61627374: abstract_profile #abst
        0x6E6D636C: named_color_profile #nmcl
      data_colour_spaces:
        0x58595A20: nciexyz_or_pcsxyz #XYZ
        0x4C616220: cielab_or_pcslab #Lab
        0x4C757620: cieluv #Luv
        0x59436272: ycbcr #Ycbr
        0x59787920: cieyxy #Yxy
        0x52474220: rgb #RGB
        0x47524159: gray #GRAY
        0x48535620: hsv #HSV
        0x484C5320: hls #HLS
        0x434D594B: cmyk #CMYK
        0x434D5920: cmy #CMY
        0x32434C52: two_colour #2CLR
        0x33434C52: three_colour #3CLR
        0x34434C52: four_colour #4CLR
        0x35434C52: five_colour #5CLR
        0x36434C52: six_colour #6CLR
        0x37434C52: seven_colour #7CLR
        0x38434C52: eight_colour #8CLR
        0x39434C52: nine_colour #9CLR
        0x41434C52: ten_colour #ACLR
        0x42434C52: eleven_colour #BCLR
        0x43434C52: twelve_colour #CCLR
        0x44434C52: thirteen_colour #DCLR
        0x45434C52: fourteen_colour #ECLR
        0x46434C52: fifteen_colour #FCLR
      primary_platforms:
        0x4150504C: apple_computer_inc #APPL
        0x4D534654: microsoft_corporation #MSFT
        0x53474920: silicon_graphics_inc #SGI
        0x53554E57: sun_microsystems #SUNW
      rendering_intents:
        0: perceptual
        1: media_relative_colorimetric
        2: saturation
        3: icc_absolute_colorimetric
  device_manufacturer:
    seq:
      - id: device_manufacturer
        type: u4
        enum: device_manufacturers
    enums:
      device_manufacturers:
        0x34643270: erdt_systems_gmbh_and_co_kg #4d2p
        0x41414D41: aamazing_technologies_inc #AAMA
        0x41434552: acer_peripherals #ACER
        0x41434C54: acolyte_color_research #ACLT
        0x41435449: actix_sytems_inc #ACTI
        0x41444152: adara_technology_inc #ADAR
        0x41444245: adobe_systems_incorporated #ADBE
        0x41444920: adi_systems_inc #ADI 
        0x41474641: agfa_graphics_nv #AGFA
        0x414C4D44: alps_electric_usa_inc #ALMD
        0x414C5053: alps_electric_usa_inc_2 #ALPS
        0x414C574E: alwan_color_expertise #ALWN
        0x414D5449: amiable_technologies_inc #AMTI
        0x414F4320: aoc_international_usa_ltd #AOC 
        0x41504147: apago #APAG
        0x4150504C: apple_computer_inc #APPL
        0x41535420: ast #AST 
        0x41542654: atandt_computer_systems #AT&T
        0x4241454C: barbieri_electronic #BAEL
        0x62657267: bergdesign_incorporated #berg
        0x62494343: basiccolor_gmbh #bICC
        0x4252434F: barco_nv #BRCO
        0x42524B50: breakpoint_pty_limited #BRKP
        0x42524F54: brother_industries_ltd #BROT
        0x42554C4C: bull #BULL
        0x42555320: bus_computer_systems #BUS 
        0x432D4954: c_itoh #C-IT
        0x43414D52: intel_corporation #CAMR
        0x43414E4F: canon_inc_canon_development_americas_inc #CANO
        0x43415252: carroll_touch #CARR
        0x43415349: casio_computer_co_ltd #CASI
        0x43425553: colorbus_pl #CBUS
        0x43454C20: crossfield #CEL 
        0x43454C78: crossfield_2 #CELx
        0x63657964: integrated_color_solutions_inc #ceyd
        0x43475320: cgs_publishing_technologies_international_gmbh #CGS 
        0x43484D20: rochester_robotics #CHM 
        0x4349474C: colour_imaging_group_london #CIGL
        0x43495449: citizen #CITI
        0x434C3030: candela_ltd #CL00
        0x434C4951: color_iq #CLIQ
        0x636C7370: macdermid_colorspan_inc #clsp
        0x434D434F: chromaco_inc #CMCO
        0x434D6958: chromix #CMiX
        0x434F4C4F: colorgraphic_communications_corporation #COLO
        0x434F4D50: compaq_computer_corporation #COMP
        0x434F4D70: compeq_usa_focus_technology #COMp
        0x434F4E52: conrac_display_products #CONR
        0x434F5244: cordata_technologies_inc #CORD
        0x43505120: compaq_computer_corporation_2 #CPQ 
        0x4350524F: colorpro #CPRO
        0x43524E20: cornerstone #CRN 
        0x43545820: ctx_international_inc #CTX 
        0x43564953: colorvision #CVIS
        0x43574320: fujitsu_laboratories_ltd #CWC 
        0x44415249: darius_technology_ltd #DARI
        0x44415441: dataproducts #DATA
        0x44435020: dry_creek_photo #DCP 
        0x44435243: digital_contents_resource_center_chung_ang_university #DCRC
        0x44454C4C: dell_computer_corporation #DELL
        0x44494320: dainippon_ink_and_chemicals #DIC 
        0x4449434F: diconix #DICO
        0x44494749: digital #DIGI
        0x444C2643: digital_light_and_color #DL&C
        0x44504C47: doppelganger_llc #DPLG
        0x44532020: dainippon_screen #DS  
        0x64732020: dainippon_screen_2 #ds  
        0x44534F4C: doosol #DSOL
        0x4455504E: dupont #DUPN
        0x6475706E: dupont_2 #dupn
        0x45697A6F: eizo_nanao_corporation #Eizo
        0x4550534F: epson #EPSO
        0x45534B4F: esko_graphics #ESKO
        0x45545249: electronics_and_telecommunications_research_institute #ETRI
        0x45564552: everex_systems_inc #EVER
        0x45584143: exactcode_gmbh #EXAC
        0x46414C43: falco_data_products_inc #FALC
        0x46462020: fuji_photo_film_coltd #FF  
        0x46464549: fujifilm_electronic_imaging_ltd #FFEI
        0x66666569: fujifilm_electronic_imaging_ltd_2 #ffei
        0x666C7578: fluxdata_corporation #flux
        0x464E5244: fnord_software #FNRD
        0x464F5241: fora_inc #FORA
        0x464F5245: forefront_technology_corporation #FORE
        0x46502A2A: fujitsu #FP  
        0x46504120: waytech_development_inc #FPA 
        0x46554A49: fujitsu_2 #FUJI
        0x46582020: fuji_xerox_co_ltd #FX  
        0x47434320: gcc_technologies_inc #GCC 
        0x4747534C: global_graphics_software_limited #GGSL
        0x474D4220: gretagmacbeth #GMB 
        0x474D4720: gmg_gmbh_and_co_kg #GMG 
        0x474F4C44: goldstar_technology_inc #GOLD
        0x47505254: giantprint_pty_ltd #GPRT
        0x47544D42: gretagmacbeth_2 #GTMB
        0x47564320: waytech_development_inc_2 #GVC 
        0x4757324B: sony_corporation #GW2K
        0x48434920: hci #HCI 
        0x48444D20: heidelberger_druckmaschinen_ag #HDM 
        0x4845524D: hermes #HERM
        0x48495441: hitachi_america_ltd #HITA
        0x48695469: hiti_digital_inc #HiTi
        0x48502020: hewlett_packard #HP  
        0x48544320: hitachi_ltd #HTC 
        0x49424D20: ibm_corporation #IBM 
        0x49444E54: scitex_corporation_ltd #IDNT
        0x49646E74: scitex_corporation_ltd_2 #Idnt
        0x49454320: hewlett_packard_2 #IEC 
        0x49495941: iiyama_north_america_inc #IIYA
        0x494B4547: ikegami_electronics_inc #IKEG
        0x494D4147: image_systems_corporation #IMAG
        0x494D4920: ingram_micro_inc #IMI 
        0x496E6361: inca_digital_printers_ltd #Inca
        0x494E5443: intel_corporation_2 #INTC
        0x494E544C: intl #INTL
        0x494E5452: intra_electronics_usa_inc #INTR
        0x494F434F: iocomm_international_technology_corporation #IOCO
        0x49505320: infoprint_solutions_company #IPS 
        0x49524953: scitex_corporation_ltd_3 #IRIS
        0x49726973: scitex_corporation_ltd_4 #Iris
        0x69726973: scitex_corporation_ltd_5 #iris
        0x49534C20: ichikawa_soft_laboratory #ISL 
        0x49544E4C: itnl #ITNL
        0x49564d20: ivm #IVM 
        0x49574154: iwatsu_electric_co_ltd #IWAT
        0x4A534654: jetsoft_development #JSFT
        0x4A564320: jvc_information_products_co #JVC 
        0x4B415254: scitex_corporation_ltd_6 #KART
        0x4B617274: scitex_corporation_ltd_7 #Kart
        0x6B617274: scitex_corporation_ltd_8 #kart
        0x4B464320: kfc_computek_components_corporation #KFC 
        0x4B4C4820: klh_computers #KLH 
        0x4B4D4844: konica_minolta_holdings_inc #KMHD
        0x4B4E4341: konica_corporation #KNCA
        0x4B4F4441: kodak #KODA
        0x4B594F43: kyocera #KYOC
        0x4C434147: leica_camera_ag #LCAG
        0x4C434344: leeds_colour #LCCD
        0x4C44414B: left_dakota #LDAK
        0x4C454144: leading_technology_inc #LEAD
        0x4C45584D: lexmark_international_inc #LEXM
        0x4C494E4B: link_computer_inc #LINK
        0x4C494E4F: linotronic #LINO
        0x4C495445: lite_on_inc #LITE
        0x4D414743: mag_computronic_usa_inc #MAGC
        0x4D414749: mag_innovision_inc #MAGI
        0x4D414E4E: mannesmann #MANN
        0x4D49434E: micron_technology_inc #MICN
        0x4D494352: microtek #MICR
        0x4D494356: microvitec_inc #MICV
        0x4D494E4F: minolta #MINO
        0x4D495453: mitsubishi_electronics_america_inc #MITS
        0x4D495473: mitsuba_corporation #MITs
        0x4D697473: mitsubishi_electric_corporation_kyoto_works #Mits
        0x4D4E4C54: minolta_2 #MNLT
        0x4D4F4447: modgraph_inc #MODG
        0x4D4F4E49: monitronix_inc #MONI
        0x4D4F4E53: monaco_systems_inc #MONS
        0x4D4F5253: morse_technology_inc #MORS
        0x4D4F5449: motive_systems #MOTI
        0x4D534654: microsoft_corporation #MSFT
        0x4D55544F: mutoh_industries_ltd #MUTO
        0x4E414E41: nanao_usa_corporation #NANA
        0x4E454320: nec_corporation #NEC 
        0x4E455850: nexpress_solutions_llc #NEXP
        0x4E495353: nissei_sangyo_america_ltd #NISS
        0x4E4B4F4E: nikon_corporation #NKON
        0x6F623464: erdt_systems_gmbh_and_co_kg_2 #ob4d
        0x6F626963: medigraph_gmbh #obic
        0x4F434520: oce_technologies_bv #OCE 
        0x4F434543: ocecolor #OCEC
        0x4F4B4920: oki #OKI 
        0x4F4B4944: okidata #OKID
        0x4F4B4950: okidata_2 #OKIP
        0x4F4C4956: olivetti #OLIV
        0x4F4C594D: olympus_optical_co_ltd #OLYM
        0x4F4E5958: onyx_graphics #ONYX
        0x4F505449: optiquest #OPTI
        0x5041434B: packard_bell #PACK
        0x50414E41: matsushita_electric_industrial_co_ltd #PANA
        0x50414E54: pantone_inc #PANT
        0x50424E20: packard_bell_2 #PBN 
        0x50465520: pfu_limited #PFU 
        0x5048494C: philips_consumer_electronics_co #PHIL
        0x504E5458: hoya_corporation_pentax_imaging_systems_division #PNTX
        0x504F6E65: phase_one_a_s #POne
        0x5052454D: premier_computer_innovations #PREM
        0x5052494E: princeton_graphic_systems #PRIN
        0x50524950: princeton_publishing_labs #PRIP
        0x514C5558: qlux #QLUX
        0x514D5320: qms_inc #QMS 
        0x51504344: qpcard_ab #QPCD
        0x51554144: quadlaser #QUAD
        0x71756279: qubyx_sarl #quby
        0x51554D45: qume_corporation #QUME
        0x52414449: radius_inc #RADI
        0x52444478: integrated_color_solutions_inc_2 #RDDx
        0x52444720: roland_dg_corporation #RDG 
        0x5245444D: redms_group_inc #REDM
        0x52454C49: relisys #RELI
        0x52474D53: rolf_gierling_multitools #RGMS
        0x5249434F: ricoh_corporation #RICO
        0x524E4C44: edmund_ronald #RNLD
        0x524F5941: royal #ROYA
        0x52504320: ricoh_printing_systemsltd #RPC 
        0x52544C20: royal_information_electronics_co_ltd #RTL 
        0x53414D50: sampo_corporation_of_america #SAMP
        0x53414D53: samsung_inc #SAMS
        0x53414E54: jaime_santana_pomares #SANT
        0x53434954: scitex_corporation_ltd_9 #SCIT
        0x53636974: scitex_corporation_ltd_10 #Scit
        0x73636974: scitex_corporation_ltd_11 #scit
        0x5343524E: dainippon_screen_3 #SCRN
        0x7363726E: dainippon_screen_4 #scrn
        0x53445020: scitex_corporation_ltd_12 #SDP 
        0x53647020: scitex_corporation_ltd_13 #Sdp 
        0x73647020: scitex_corporation_ltd_14 #sdp 
        0x53454320: samsung_electronics_coltd #SEC 
        0x5345494B: seiko_instruments_usa_inc #SEIK
        0x5345496B: seikosha #SEIk
        0x53475559: scanguycom #SGUY
        0x53484152: sharp_laboratories #SHAR
        0x53494343: international_color_consortium #SICC
        0x73697769: siwi_grafika_corporation #siwi
        0x534F4E59: sony_corporation_2 #SONY
        0x536F6E79: sony_corporation_3 #Sony
        0x5350434C: spectracal #SPCL
        0x53544152: star #STAR
        0x53544320: sampo_technology_corporation #STC 
        0x54414C4F: talon_technology_corporation #TALO
        0x54414E44: tandy #TAND
        0x54415455: tatung_co_of_america_inc #TATU
        0x54415841: taxan_america_inc #TAXA
        0x54445320: tokyo_denshi_sekei_kk #TDS 
        0x5445434F: teco_information_systems_inc #TECO
        0x54454752: tegra #TEGR
        0x54454B54: tektronix_inc #TEKT
        0x54492020: texas_instruments #TI  
        0x544D4B52: typemaker_ltd #TMKR
        0x544F5342: toshiba_corp #TOSB
        0x544F5348: toshiba_inc #TOSH
        0x544F544B: totoku_electric_co_ltd #TOTK
        0x54524955: triumph #TRIU
        0x54534254: toshiba_tec_corporation #TSBT
        0x54545820: ttx_computer_products_inc #TTX 
        0x54564D20: tvm_professional_monitor_corporation #TVM 
        0x54572020: tw_casper_corporation #TW  
        0x554C5358: ulead_systems #ULSX
        0x554E4953: unisys #UNIS
        0x55545A46: utz_fehlau_and_sohn #UTZF
        0x56415249: varityper #VARI
        0x56494557: viewsonic #VIEW
        0x5649534C: visual_communication #VISL
        0x57414E47: wang #WANG
        0x574C4252: wilbur_imaging #WLBR
        0x57544732: ware_to_go #WTG2
        0x57595345: wyse_technology #WYSE
        0x58455258: xerox_corporation #XERX
        0x58524954: x_rite #XRIT
        0x7978796D: yxymaster_gmbh #yxym
        0x5A313233: lavanyas_test_company #Z123
        0x5A656272: zebra_technologies_inc #Zebr
        0x5A52414E: zoran_corporation #ZRAN
  device_attributes:
    seq:
      - id: reflective_or_transparency
        type: b1
        enum: device_attributes_reflective_or_transparency
      - id: glossy_or_matte
        type: b1
        enum: device_attributes_glossy_or_matte
      - id: positive_or_negative_media_polarity
        type: b1
        enum: device_attributes_positive_or_negative_media_polarity
      - id: colour_or_black_and_white_media
        type: b1
        enum: device_attributes_colour_or_black_and_white_media
      - id: reserved
        type: b28
      - id: vendor_specific
        type: b32
    enums:
      device_attributes_reflective_or_transparency:
        0: reflective
        1: transparency
      device_attributes_glossy_or_matte:
        0: glossy
        1: matte
      device_attributes_positive_or_negative_media_polarity:
        0: positive_media_polarity
        1: negative_media_polarity
      device_attributes_colour_or_black_and_white_media:
        0: colour_media
        1: black_and_white_media
  date_time_number:
    seq:
      - id: year
        type: u2
      - id: month
        type: u2
      - id: day
        type: u2
      - id: hour
        type: u2
      - id: minute
        type: u2
      - id: second
        type: u2
  position_number:
    seq:
      - id: offset_to_data_element
        type: u4
      - id: size_of_data_element
        type: u4
  response_16_number:
    seq:
      - id: number
        type: u4
      - id: reserved
        contents: [0x00, 0x00]
      - id: measurement_value
        type: s_15_fixed_16_number
  s_15_fixed_16_number:
    seq:
      - id: number
        size: 4
  u_16_fixed_16_number:
    seq:
      - id: number
        size: 4
  u_1_fixed_15_number:
    seq:
      - id: number
        size: 2
  u_8_fixed_8_number:
    seq:
      - id: number
        size: 2
  xyz_number:
    seq:
      - id: x
        size: 4
      - id: y
        size: 4
      - id: z
        size: 4
  tag_table:
    seq:
      - id: tag_count
        type: u4
      - id: tags
        type: tag_definition
        repeat: expr
        repeat-expr: tag_count
    types:
      tag_definition:
        seq:
          - id: tag_signature
            type: u4
            enum: tag_signatures
          - id: offset_to_data_element
            type: u4
          - id: size_of_data_element
            type: u4
        instances:
          tag_data_element:
            pos: offset_to_data_element
            size: size_of_data_element
            type:
              switch-on: tag_signature
              cases:
                tag_signatures::a_to_b_0: a_to_b_0_tag
                tag_signatures::a_to_b_1: a_to_b_1_tag
                tag_signatures::a_to_b_2: a_to_b_2_tag
                tag_signatures::blue_matrix_column: blue_matrix_column_tag
                tag_signatures::blue_trc: blue_trc_tag
                tag_signatures::b_to_a_0: b_to_a_0_tag
                tag_signatures::b_to_a_1: b_to_a_1_tag
                tag_signatures::b_to_a_2: b_to_a_2_tag
                tag_signatures::b_to_d_0: b_to_d_0_tag
                tag_signatures::b_to_d_1: b_to_d_1_tag
                tag_signatures::b_to_d_2: b_to_d_2_tag
                tag_signatures::b_to_d_3: b_to_d_3_tag
                tag_signatures::calibration_date_time: calibration_date_time_tag
                tag_signatures::char_target: char_target_tag
                tag_signatures::chromatic_adaptation: chromatic_adaptation_tag
                tag_signatures::chromaticity: chromaticity_tag
                tag_signatures::colorant_order: colorant_order_tag
                tag_signatures::colorant_table: colorant_table_tag
                tag_signatures::colorant_table_out: colorant_table_out_tag
                tag_signatures::colorimetric_intent_image_state: colorimetric_intent_image_state_tag
                tag_signatures::copyright: copyright_tag
                tag_signatures::device_mfg_desc: device_mfg_desc_tag
                tag_signatures::device_model_desc: device_model_desc_tag
                tag_signatures::d_to_b_0: d_to_b_0_tag
                tag_signatures::d_to_b_1: d_to_b_1_tag
                tag_signatures::d_to_b_2: d_to_b_2_tag
                tag_signatures::d_to_b_3: d_to_b_3_tag
                tag_signatures::gamut: gamut_tag
                tag_signatures::gray_trc: gray_trc_tag
                tag_signatures::green_matrix_column: green_matrix_column_tag
                tag_signatures::green_trc: green_trc_tag
                tag_signatures::luminance: luminance_tag
                tag_signatures::measurement: measurement_tag
                tag_signatures::media_white_point: media_white_point_tag
                tag_signatures::named_color_2: named_color_2_tag
                tag_signatures::output_response: output_response_tag
                tag_signatures::perceptual_rendering_intent_gamut: perceptual_rendering_intent_gamut_tag
                tag_signatures::preview_0: preview_0_tag
                tag_signatures::preview_1: preview_1_tag
                tag_signatures::preview_2: preview_2_tag
                tag_signatures::profile_description: profile_description_tag
                tag_signatures::profile_sequence: profile_sequence_tag
                tag_signatures::profile_sequence_identifier: profile_sequence_identifier_tag
                tag_signatures::red_matrix_column: red_matrix_column_tag
                tag_signatures::red_trc: red_trc_tag
                tag_signatures::saturation_rendering_intent_gamut: saturation_rendering_intent_gamut_tag
                tag_signatures::technology: technology_tag
                tag_signatures::viewing_cond_desc: viewing_cond_desc_tag
                tag_signatures::viewing_conditions: viewing_conditions_tag
        types:
          a_to_b_0_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_function_table_with_one_byte_precision_type: lut_8_type
                    tag_type_signatures::multi_function_table_with_two_byte_precision_type: lut_16_type
                    tag_type_signatures::multi_function_a_to_b_table_type: lut_a_to_b_type
          a_to_b_1_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_function_table_with_one_byte_precision_type: lut_8_type
                    tag_type_signatures::multi_function_table_with_two_byte_precision_type: lut_16_type
                    tag_type_signatures::multi_function_a_to_b_table_type: lut_a_to_b_type
          a_to_b_2_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_function_table_with_one_byte_precision_type: lut_8_type
                    tag_type_signatures::multi_function_table_with_two_byte_precision_type: lut_16_type
                    tag_type_signatures::multi_function_a_to_b_table_type: lut_a_to_b_type
          blue_matrix_column_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::xyz_type: xyz_type
          blue_trc_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::curve_type: curve_type
                    tag_type_signatures::parametric_curve_type: parametric_curve_type
          b_to_a_0_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_function_table_with_one_byte_precision_type: lut_8_type
                    tag_type_signatures::multi_function_table_with_two_byte_precision_type: lut_16_type
                    tag_type_signatures::multi_function_b_to_a_table_type: lut_b_to_a_type
          b_to_a_1_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_function_table_with_one_byte_precision_type: lut_8_type
                    tag_type_signatures::multi_function_table_with_two_byte_precision_type: lut_16_type
                    tag_type_signatures::multi_function_b_to_a_table_type: lut_b_to_a_type
          b_to_a_2_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_function_table_with_one_byte_precision_type: lut_8_type
                    tag_type_signatures::multi_function_table_with_two_byte_precision_type: lut_16_type
                    tag_type_signatures::multi_function_b_to_a_table_type: lut_b_to_a_type
          b_to_d_0_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_process_elements_type: multi_process_elements_type
          b_to_d_1_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_process_elements_type: multi_process_elements_type
          b_to_d_2_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_process_elements_type: multi_process_elements_type
          b_to_d_3_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_process_elements_type: multi_process_elements_type
          calibration_date_time_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::date_time_type: date_time_type
          char_target_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::text_type: text_type
          chromatic_adaptation_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::s_15_fixed_16_array_type: s_15_fixed_16_array_type
          chromaticity_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::chromaticity_type: chromaticity_type
          colorant_order_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::colorant_order_type: colorant_order_type
          colorant_table_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::colorant_table_type: colorant_table_type
          colorant_table_out_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::colorant_table_type: colorant_table_type
          colorimetric_intent_image_state_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::signature_type: signature_type
          copyright_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_localized_unicode_type: multi_localized_unicode_type
          device_mfg_desc_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_localized_unicode_type: multi_localized_unicode_type
          device_model_desc_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_localized_unicode_type: multi_localized_unicode_type
          d_to_b_0_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_process_elements_type: multi_process_elements_type
          d_to_b_1_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_process_elements_type: multi_process_elements_type
          d_to_b_2_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_process_elements_type: multi_process_elements_type
          d_to_b_3_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_process_elements_type: multi_process_elements_type
          gamut_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_function_table_with_one_byte_precision_type: lut_8_type
                    tag_type_signatures::multi_function_table_with_two_byte_precision_type: lut_16_type
                    tag_type_signatures::multi_function_b_to_a_table_type: lut_b_to_a_type
          gray_trc_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::curve_type: curve_type
                    tag_type_signatures::parametric_curve_type: parametric_curve_type
          green_matrix_column_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::xyz_type: xyz_type
          green_trc_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::curve_type: curve_type
                    tag_type_signatures::parametric_curve_type: parametric_curve_type
          luminance_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::xyz_type: xyz_type
          measurement_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::measurement_type: measurement_type
          media_white_point_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::xyz_type: xyz_type
          named_color_2_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::named_color_2_type: named_color_2_type
          output_response_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::response_curve_set_16_type: response_curve_set_16_type
          perceptual_rendering_intent_gamut_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::signature_type: signature_type
          preview_0_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_function_table_with_one_byte_precision_type: lut_8_type
                    tag_type_signatures::multi_function_table_with_two_byte_precision_type: lut_16_type
                    tag_type_signatures::multi_function_a_to_b_table_type: lut_a_to_b_type
                    tag_type_signatures::multi_function_b_to_a_table_type: lut_b_to_a_type
          preview_1_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_function_table_with_one_byte_precision_type: lut_8_type
                    tag_type_signatures::multi_function_table_with_two_byte_precision_type: lut_16_type
                    tag_type_signatures::multi_function_b_to_a_table_type: lut_b_to_a_type
          preview_2_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_function_table_with_one_byte_precision_type: lut_8_type
                    tag_type_signatures::multi_function_table_with_two_byte_precision_type: lut_16_type
                    tag_type_signatures::multi_function_b_to_a_table_type: lut_b_to_a_type
          profile_description_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_localized_unicode_type: multi_localized_unicode_type
          profile_sequence_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::profile_sequence_desc_type: profile_sequence_desc_type
          profile_sequence_identifier_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::profile_sequence_identifier_type: profile_sequence_identifier_type
          red_matrix_column_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::xyz_type: xyz_type
          red_trc_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::curve_type: curve_type
                    tag_type_signatures::parametric_curve_type: parametric_curve_type
          saturation_rendering_intent_gamut_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::signature_type: signature_type
          technology_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::signature_type: signature_type
          viewing_cond_desc_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::multi_localized_unicode_type: multi_localized_unicode_type
          viewing_conditions_tag:
            seq:
              - id: tag_type
                type: u4
                enum: tag_type_signatures
              - id: tag_data
                type:
                  switch-on: tag_type
                  cases:
                    tag_type_signatures::viewing_conditions_type: viewing_conditions_type
          chromaticity_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: number_of_device_channels
                type: u2
              - id: colorant_and_phosphor_encoding
                type: u2
                enum: colorant_and_phosphor_encodings
              - id: ciexy_coordinates_per_channel
                type: ciexy_coordinate_values
                repeat: expr
                repeat-expr: number_of_device_channels
            types:
              ciexy_coordinate_values:
                seq:
                  - id: x_coordinate
                    type: u2
                  - id: y_coordinate
                    type: u2
            enums:
              colorant_and_phosphor_encodings:
                0x0000: unknown
                0x0001: itu_r_bt_709_2
                0x0002: smpte_rp145
                0x0003: ebu_tech_3213_e
                0x0004: p22
          colorant_order_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: count_of_colorants
                type: u4
              - id: numbers_of_colorants_in_order_of_printing
                type: u1
                repeat: expr
                repeat-expr: count_of_colorants
          colorant_table_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: count_of_colorants
                type: u4
              - id: colorants
                type: colorant
                repeat: expr
                repeat-expr: count_of_colorants
            types:
              colorant:
                seq:
                  - id: name
                    type: strz
                  - id: padding
                    contents: [0x00]
                    repeat: expr
                    repeat-expr: 32 - name.length
                  - id: pcs_values
                    size: 6
          curve_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: number_of_entries
                type: u4
              - id: curve_values
                type: u4
                repeat: expr
                repeat-expr: number_of_entries
                if: number_of_entries > 1
              - id: curve_value
                type: u1
                if: number_of_entries == 1
          data_type:
            seq:
              - id: data_flag
                type: u4
                enum: data_types
            enums:
              data_types:
                0x00000000: ascii_data
                0x00000001: binary_data
          date_time_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: date_and_time
                type: date_time_number
          lut_16_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: number_of_input_channels
                type: u1
              - id: number_of_output_channels
                type: u1
              - id: number_of_clut_grid_points
                type: u1
              - id: padding
                contents: [0x00]
              - id: encoded_e_parameters
                type: s4
                repeat: expr
                repeat-expr: 9
              - id: number_of_input_table_entries
                type: u4
              - id: number_of_output_table_entries
                type: u4
              - id: input_tables
                size: 2 * number_of_input_channels * number_of_input_table_entries
              - id: clut_values
                size: 2 * (number_of_clut_grid_points ^ number_of_input_channels) * number_of_output_channels
              - id: output_tables
                size: 2 * number_of_output_channels * number_of_output_table_entries
          lut_8_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: number_of_input_channels
                type: u1
              - id: number_of_output_channels
                type: u1
              - id: number_of_clut_grid_points
                type: u1
              - id: padding
                contents: [0x00]
              - id: encoded_e_parameters
                type: s4
                repeat: expr
                repeat-expr: 9
              - id: number_of_input_table_entries
                type: u4
              - id: number_of_output_table_entries
                type: u4
              - id: input_tables
                size: 256 * number_of_input_channels
              - id: clut_values
                size: (number_of_clut_grid_points ^ number_of_input_channels) * number_of_output_channels
              - id: output_tables
                size: 256 * number_of_output_channels
          lut_a_to_b_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: number_of_input_channels
                type: u1
              - id: number_of_output_channels
                type: u1
              - id: padding
                contents: [0x00, 0x00]
              - id: offset_to_first_b_curve
                type: u4
              - id: offset_to_matrix
                type: u4
              - id: offset_to_first_m_curve
                type: u4
              - id: offset_to_clut
                type: u4
              - id: offset_to_first_a_curve
                type: u4
              - id: data
                size-eos: true
          lut_b_to_a_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: number_of_input_channels
                type: u1
              - id: number_of_output_channels
                type: u1
              - id: padding
                contents: [0x00, 0x00]
              - id: offset_to_first_b_curve
                type: u4
              - id: offset_to_matrix
                type: u4
              - id: offset_to_first_m_curve
                type: u4
              - id: offset_to_clut
                type: u4
              - id: offset_to_first_a_curve
                type: u4
              - id: data
                size-eos: true
          measurement_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: standard_observer_encoding
                type: u4
                enum: standard_observer_encodings
              - id: nciexyz_tristimulus_values_for_measurement_backing
                type: xyz_number
              - id: measurement_geometry_encoding
                type: u4
                enum: measurement_geometry_encodings
              - id: measurement_flare_encoding
                type: u4
                enum: measurement_flare_encodings
              - id: standard_illuminant_encoding
                type: standard_illuminant_encoding
            enums:
              standard_observer_encodings:
                0x00000000: unknown
                0x00000001: cie_1931_standard_colorimetric_observer
                0x00000002: cie_1964_standard_colorimetric_observer
              measurement_geometry_encodings:
                0x00000000: unknown
                0x00000001: zero_degrees_to_45_degrees_or_45_degrees_to_zero_degrees
                0x00000002: zero_degrees_to_d_degrees_or_d_degrees_to_zero_degrees
              measurement_flare_encodings:
                0x00000000: zero_percent
                0x00010000: one_hundred_percent
          multi_localized_unicode_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: number_of_records
                type: u4
              - id: record_size
                type: u4
              - id: records
                type: record
                repeat: expr
                repeat-expr: number_of_records
            types:
              record:
                seq:
                  - id: language_code
                    type: u2
                  - id: country_code
                    type: u2
                  - id: string_length
                    type: u4
                  - id: string_offset
                    type: u4
                instances:
                  string_data:
                    pos: string_offset
                    size: string_length
                    type: str
                    encoding: UTF-16BE
          multi_process_elements_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: number_of_input_channels
                type: u2
              - id: number_of_output_channels
                type: u2
              - id: number_of_processing_elements
                type: u4
              - id: process_element_positions_table
                type: position_number
                repeat: expr
                repeat-expr: number_of_processing_elements
              - id: data
                size-eos: true
          named_color_2_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: vendor_specific_flag
                type: u4
              - id: count_of_named_colours
                type: u4
              - id: number_of_device_coordinates_for_each_named_colour
                type: u4
              - id: prefix_for_each_colour_name
                type: strz
              - id: prefix_for_each_colour_name_padding
                contents: [0x00]
                repeat: expr
                repeat-expr: 32 - prefix_for_each_colour_name.length
              - id: suffix_for_each_colour_name
                type: strz
              - id: suffix_for_each_colour_name_padding
                contents: [0x00]
                repeat: expr
                repeat-expr: 32 - suffix_for_each_colour_name.length
              - id: named_colour_definitions
                type: named_colour_definition
                repeat: expr
                repeat-expr: count_of_named_colours
            types:
              named_colour_definition:
                seq:
                  - id: root_name
                    type: strz
                  - id: root_name_padding
                    contents: [0x00]
                    repeat: expr
                    repeat-expr: 32 - root_name.length
                  - id: pcs_coordinates
                    size: 6
                  - id: device_coordinates
                    type: u2
                    repeat: expr
                    repeat-expr: _parent.count_of_named_colours
                    if: _parent.number_of_device_coordinates_for_each_named_colour > 0
          parametric_curve_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: function_type
                type: u2
                enum: parametric_curve_type_functions
              - id: reserved_2
                contents: [0x00, 0x00]
              - id: parameters
                type:
                  switch-on: function_type
                  cases:
                    parametric_curve_type_functions::y_equals_x_to_power_of_g: params_y_equals_x_to_power_of_g
                    parametric_curve_type_functions::cie_122_1996: params_cie_122_1996
                    parametric_curve_type_functions::iec_61966_3: params_iec_61966_3
                    parametric_curve_type_functions::iec_61966_2_1: params_iec_61966_2_1
                    parametric_curve_type_functions::y_equals_ob_ax_plus_b_cb_to_power_of_g_plus_c: params_y_equals_ob_ax_plus_b_cb_to_power_of_g_plus_c
            types:
              params_y_equals_x_to_power_of_g:
                seq:
                  - id: g
                    type: s4
              params_cie_122_1996:
                seq:
                  - id: g
                    type: s4
                  - id: a
                    type: s4
                  - id: b
                    type: s4
              params_iec_61966_3:
                seq:
                  - id: g
                    type: s4
                  - id: a
                    type: s4
                  - id: b
                    type: s4
                  - id: c
                    type: s4
              params_iec_61966_2_1:
                seq:
                  - id: g
                    type: s4
                  - id: a
                    type: s4
                  - id: b
                    type: s4
                  - id: c
                    type: s4
                  - id: d
                    type: s4
              params_y_equals_ob_ax_plus_b_cb_to_power_of_g_plus_c:
                seq:
                  - id: g
                    type: s4
                  - id: a
                    type: s4
                  - id: b
                    type: s4
                  - id: c
                    type: s4
                  - id: d
                    type: s4
                  - id: e
                    type: s4
                  - id: f
                    type: s4
            enums:
              parametric_curve_type_functions:
                0x0000: y_equals_x_to_power_of_g
                0x0001: cie_122_1996
                0x0002: iec_61966_3
                0x0003: iec_61966_2_1
                0x0004: y_equals_ob_ax_plus_b_cb_to_power_of_g_plus_c
          profile_sequence_desc_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: number_of_description_structures
                type: u4
              - id: profile_descriptions
                type: profile_description
                repeat: expr
                repeat-expr: number_of_description_structures
            types:
              profile_description:
                seq:
                  - id: device_manufacturer
                    type: device_manufacturer
                  - id: device_model
                    type: str
                    size: 4
                  - id: device_attributes
                    type: device_attributes
                  - id: device_technology
                    type: technology_tag
                  - id: description_of_device_manufacturer
                    type: device_mfg_desc_tag
                  - id: description_of_device_model
                    type: device_model_desc_tag
          profile_sequence_identifier_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: number_of_structures
                type: u4
              - id: positions_table
                type: position_number
                repeat: expr
                repeat-expr: number_of_structures
              - id: profile_identifiers
                type: profile_identifier
                repeat: expr
                repeat-expr: number_of_structures
            types:
              profile_identifier:
                seq:
                  - id: profile_id
                    size: 16
                  - id: profile_description
                    type: multi_localized_unicode_type
          response_curve_set_16_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: number_of_channels
                type: u2
              - id: count_of_measurement_types
                type: u2
              - id: response_curve_structure_offsets
                type: u4
                repeat: expr
                repeat-expr: count_of_measurement_types
              - id: response_curve_structures
                size-eos: true
          s_15_fixed_16_array_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: values
                type: s_15_fixed_16_number
                repeat: eos
          signature_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: signature
                type: str
                size: 4
          text_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: value
                type: strz
                size-eos: true
          u_16_fixed_16_array_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: values
                type: u_16_fixed_16_number
                repeat: eos
          u_int_16_array_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: values
                type: u2
                repeat: eos
          u_int_32_array_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: values
                type: u4
                repeat: eos
          u_int_64_array_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: values
                type: u8
                repeat: eos
          u_int_8_array_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: values
                type: u1
                repeat: eos
          viewing_conditions_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: un_normalized_ciexyz_values_for_illuminant
                type: xyz_number
              - id: un_normalized_ciexyz_values_for_surround
                type: xyz_number
              - id: illuminant_type
                type: standard_illuminant_encoding
          xyz_type:
            seq:
              - id: reserved
                contents: [0x00, 0x00, 0x00, 0x00]
              - id: values
                type: xyz_number
                repeat: eos
        enums:
          tag_signatures:
            0x41324230: a_to_b_0 #A2B0
            0x41324231: a_to_b_1 #A2B1
            0x41324232: a_to_b_2 #A2B2
            0x6258595A: blue_matrix_column #bXYZ
            0x62545243: blue_trc #bTRC
            0x42324130: b_to_a_0 #B2A0
            0x42324131: b_to_a_1 #B2A1
            0x42324132: b_to_a_2 #B2A2
            0x42324430: b_to_d_0 #B2D0
            0x42324431: b_to_d_1 #B2D1
            0x42324432: b_to_d_2 #B2D2
            0x42324433: b_to_d_3 #B2D3
            0x63616C74: calibration_date_time #calt
            0x74617267: char_target #targ
            0x63686164: chromatic_adaptation #chad
            0x6368726D: chromaticity #chrm
            0x636C726F: colorant_order #clro
            0x636C7274: colorant_table #clrt
            0x636C6F74: colorant_table_out #clot
            0x63696973: colorimetric_intent_image_state #ciis
            0x63707274: copyright #cprt
            0x646D6E64: device_mfg_desc #dmnd
            0x646D6464: device_model_desc #dmdd
            0x44324230: d_to_b_0 #D2B0
            0x44324231: d_to_b_1 #D2B1
            0x44324232: d_to_b_2 #D2B2
            0x44324233: d_to_b_3 #D2B3
            0x67616D74: gamut #gamt
            0x6B545243: gray_trc #kTRC
            0x6758595A: green_matrix_column #gXYZ
            0x67545243: green_trc #gTRC
            0x6C756D69: luminance #lumi
            0x6D656173: measurement #meas
            0x77747074: media_white_point #wtpt
            0x6E636C32: named_color_2 #ncl2
            0x72657370: output_response #resp
            0x72696730: perceptual_rendering_intent_gamut #rig0
            0x70726530: preview_0 #pre0
            0x70726531: preview_1 #pre1
            0x70726532: preview_2 #pre2
            0x64657363: profile_description #desc
            0x70736571: profile_sequence #pseq
            0x70736964: profile_sequence_identifier #psid
            0x7258595A: red_matrix_column #rXYZ
            0x72545243: red_trc #rTRC
            0x72696732: saturation_rendering_intent_gamut #rig2
            0x74656368: technology #tech
            0x76756564: viewing_cond_desc #vued
            0x76696577: viewing_conditions #view
          tag_type_signatures:
            0x636c7274: colorant_table_type #clrt
            0x63757276: curve_type #curv
            0x64617461: data_type #data
            0x6474696D: date_time_type #dtim
            0x6D667432: multi_function_table_with_two_byte_precision_type #mft2
            0x6D667431: multi_function_table_with_one_byte_precision_type #mft1
            0x6D414220: multi_function_a_to_b_table_type #mAB
            0x6D424120: multi_function_b_to_a_table_type #mBA
            0x6D656173: measurement_type #meas
            0x6D6C7563: multi_localized_unicode_type #mluc
            0x6D706574: multi_process_elements_type #mpet
            0x6E636C32: named_color_2_type #ncl2
            0x70617261: parametric_curve_type #para
            0x70736571: profile_sequence_desc_type #pseq
            0x70736964: profile_sequence_identifier_type #psid
            0x72637332: response_curve_set_16_type #rcs2
            0x73663332: s_15_fixed_16_array_type #sf32
            0x73696720: signature_type #sig
            0x74657874: text_type #text
            0x75663332: u_16_fixed_16_array_type #uf32
            0x75693136: u_int_16_array_type #ui16
            0x75693332: u_int_32_array_type #ui32
            0x75693634: u_int_64_array_type #ui64
            0x75693038: u_int_8_array_type #ui08
            0x76696577: viewing_conditions_type #view
            0x58595A20: xyz_type #XYZ
          multi_process_elements_types:
            0x6D666C74: curve_set_element_table_type #cvst
            0x63757266: one_dimensional_curves_type #curf
            0x70617266: formula_curve_segments_type #parf
            0x73616D66: sampled_curve_segment_type #samf
            0x6D617466: matrix_element_type #matf
            0x636C7574: clut_element_type #clut
            0x62414353: bacs_element_type #bACS
            0x65414353: eacs_element_type #eACS
  standard_illuminant_encoding:
    seq:
      - id: standard_illuminant_encoding
        type: u4
        enum: standard_illuminant_encodings
    enums:
      standard_illuminant_encodings:
        0x00000000: unknown
        0x00000001: d50
        0x00000002: d65
        0x00000003: d93
        0x00000004: f2
        0x00000005: d55
        0x00000006: a
        0x00000007: equi_power
        0x00000008: f8
