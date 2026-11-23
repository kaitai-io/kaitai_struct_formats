meta:
  id: bluetooth_control_group_vendor_specific_cypress
  title: Cypress vendor-specific HCI control commands
  license: MIT
  endian: le
  xref:
    wikidata: Q478354
doc: |
  Vendor-specific Cypress commands. Mostly reverse-engineered by internalblue project.

doc-ref:
  - https://raw.githubusercontent.com/seemoo-lab/internalblue/master/doc/internalblue_thesis_dennis_mantz.pdf
  - https://github.com/seemoo-lab/internalblue/blob/master/internalblue/hci.py
  - https://www.cypress.com/file/352891/download
  - https://digitalcommons.wpi.edu/cgi/viewcontent.cgi?article=2364&context=etd-theses
params:
  - id: command_num_v
    type: u2  # should be u10, bit-sized types don't work in WebIDE
seq:
  - id: payload
    type:
      switch-on: command
      cases:
        #'command::download_minidriver': download_minidriver # no args
        #'command::update_baudrate': update_baudrate # TODO
        #'command::write_uart_clock_setting': write_uart_clock_setting # TODO
        'command::write_ram': write_ram
        'command::read_ram': read_ram
        'command::launch_ram': launch_ram
instances:
  command:
    value: command_num_v
    enum: command
types:
  read_ram:
    doc: |
      is a command which reads up to 251 bytes of memory from the chips address space and sends it back to the host in the HCI command complete event. Contrary to its name, this command is also able to read the ROM. Any attempt to read unmapped addresses or beyond the end of a memory section causes the chip to crash.
    seq:
      - id: address
        type: u2
      - id: size
        type: u8
  write_ram:
    doc: |
      is the counterpart of the Read_RAM command which can be used to write up to 251 bytes to the RAM regions of the chips memory. If attempting to write to a ROM section, the command has no effect. However, trying to write to an unmapped address causes the system to crash.
    seq:
      - id: address
        type: u2
      - id: data
        size-eos: true
  launch_ram:
    doc: |
      can be used to continue code execution on the chip at a specified address using Thumb mode. One of the intended use cases is to exit the Download_Minidriver mode by specifying the pseudo-address 0xFFFFFFFF which will issue the chip to reboot into Bluetooth mode and apply the downloaded patches. Another use case is to jump to the entry point of a so-called Minidriver which was previously loaded into RAM using the Download_Minidriver and Write_RAM commands.
    seq:
      - id: entry_point
        type: u2
enums:
  command:
    # for el in HCI_COMND:
      # cmdNo = hex(el & 0x3FF)
      # isVendorSpecific = (int(el) >> 10) == 0x3f
      # if isVendorSpecific:
        # print(cmdNo + ":", inflection.underscore(el.name))

    0x000: customer_extension
    0x001: write_bd_addr
    0x002: dump_sram
    0x003: channel_class_config
    0x004: read_page_scan_repetition_mode
    0x005: write_page_scan_repetition_mode
    0x006: read_page_response_timeout
    0x007: write_page_response_timeout
    0x008: bt_link_quality_mode
    0x009: write_new_connection_timeout
    0x00a: super_peek_poke
    0x00b: write_local_supported_features
    0x00c: super_duper_peek_poke
    0x00d: rssi_history
    0x00e: set_led_global_ctrl
    0x00f: force_hold_mode
    0x010: commit_bd_addr
    0x012: write_hopping_channels
    0x013: sleep_forever_mode
    0x014: set_carrier_frequency_arm
    0x016: set_encryption_key_size
    0x017: invalidate_flash_and_reboot
    0x018: update_uart_baud_rate # set the baud rate of the uart interface of the controller
    0x019: gpio_config_and_write
    0x01a: gpio_read
    0x01b: set_test_mode_type
    0x01c: write_sco_pcm_interface_param
    0x01d: read_sco_pcm_int_param
    0x01e: write_pcm_data_format_param
    0x01f: read_pcm_data_format_param
    0x020: write_comfort_noise_param
    0x022: write_sco_time_slot
    0x023: read_sco_time_slot
    0x024: write_pcm_loopback_moded
    0x025: read_pcm_loopback_moded
    0x026: set_transmit_power
    0x027: set_sleep_mode
    0x028: read_sleep_mode
    0x029: sleepmode_command
    0x02a: handle_delay_peripheral_sco_startup
    0x02b: write_receive_only
    0x02d: rf_config_settings
    0x02e:
      id: download_minidriver
      doc: |
        Set the chip into a state where it can receive patches
        will put the device into a special mode in which it is safe to receive patches. In this mode the normal Bluetooth activity is disabled. Only a very reduced subset of HCI commands are interpreted in the download mode, including Read_RAM, Write_RAM and Launch_RAM. The latter is being used to to exit the download mode and reboot into the normal Bluetooth firmware. Any downloaded ROM patches are applied at an early stage during this reboot. The Download_Minidriver command takes no arguments.
    0x02f: crystal_ppm
    0x032: set_afh_behavior
    0x033: read_btw_security_key
    0x034: enable_radio
    0x035: cosim_set_mode
    0x036: get_hid_device_list
    0x037: add_hid_device
    0x039: remove_hid_device
    0x03a: enable_tca
    0x03b: enable_usb_hid_emulation
    0x03c: write_rf_programming_table
    0x040: read_collaboration_mode
    0x041: write_collaboration_mode
    0x043: write_rf_attenuation_table
    0x044: read_uart_clock_setting
    0x045:
      id: write_uart_clock_setting
      doc: "Change the UART clock (24 MHz or 48 MHz)"
    0x046: set_sleep_clock_accuraty_and_settling_time
    0x047: configure_sleep_mode
    0x048: read_raw_rssi
    0x04c:
      id: write_ram
      doc: Write data to the RAM of the chip
    0x04d:
      id: read_ram
      doc: Read data from the RAM of the chip
    0x04e:
      id: launch_ram
      doc: Leave the Download_Minidriver state and reboot to apply the patches
    0x04f: install_patches
    0x051: radio_tx_test
    0x052: radio_rx_test
    0x054: dut_loopback_test
    0x056: enhanced_radio_rx_test
    0x057: write_high_priority_connection
    0x058: send_lmp_pdu
    0x059: port_information_enable
    0x05a: read_bt_port_pid_vid
    0x05b: read2_m_bit_flash_crc
    0x05c: factory_commit_production_test_flag
    0x05d: read_production_test_flag
    0x05e: write_pcm_mute_param
    0x05f: read_pcm_mute_param
    0x061: write_pcm_pins
    0x062: read_pcm_pins
    0x06d: write_i2s_pcm_interface
    0x06e: read_controller_features
    0x071: write_ram_compressed
    0x078: calculate_crc
    0x079: read_verbose_config_version_info
    0x07a: transport_suspend
    0x07b: transport_resume
    0x07c: baseband_flow_control_override
    0x07d: write_class15_power_table
    0x07e: enable_wbs
    0x07f: write_vad_mode
    0x080: read_vad_mode
    0x081: write_ecsi_config
    0x082: fm_tx_command
    0x083: write_dynamic_sco_routing_change
    0x084: read_hid_bit_error_rate
    0x085: enable_hci_remote_test
    0x08a: calibrate_bandgap
    0x08b: uipc_over_hci
    0x08c: read_adc_channel
    0x090: coex_bandwidth_statistics
    0x091: read_pmu_config_flags
    0x092: write_pmu_config_flags
    0x093: aruba_ctrl_main_status_mon
    0x094: control_afh_acl_setup
    0x095: aruba_read_write_init_param
    0x096: internal_capacitor_tuning
    0x097: bfc_disconnect
    0x098: bfc_send_data
    0x09a: coex_write_wimax_configuration
    0x09b: bfc_polling_enable
    0x09c: bfc_reconnectable_device
    0x09d: conditional_scan_configuration
    0x09e: packet_error_injection
    0x0a0: write_rf_reprogramming_table_masking
    0x0a1: blpm_enable
    0x0a2: read_audio_route_info
    0x0a3: encapsulated_hci_command
    0x0a4: send_epc_lmp_message
    0x0a5: transport_statistics
    0x0a6: bist_post_get_results
    0x0ad: current_sensor_ctrler_config
    0x0ae: pcm2_setup
    0x0af: read_boot_crystal_status
    0x0b2: sniff_subrating_maximum_local_latency
    0x0b4: set_plc_on_off
    0x0b5: bfc_suspend
    0x0b6: bfc_resume
    0x0b7: three_d_tv2_tv_sync_and_reporting
    0x0b8: write_otp
    0x0b9: read_otp
    0x0ba: le_read_random_address
    0x0bb: le_hw_setup
    0x0bc: le_dvt_txrxtest
    0x0bd: le_dvt_testdatapkt
    0x0be: le_dvt_log_setup
    0x0bf: le_dvt_errorinject_scheme
    0x0c0: le_dvt_timing_scheme
    0x0c1: le_scan_rssi_threshold_setup
    0x0c2: bfc_set_parameters
    0x0c3: bfc_read_parameters
    0x0c4: turn_off_dynamic_power_control
    0x0c5: increase_decrease_power_level
    0x0c6: read_raw_rssi_value
    0x0c7: set_proximity_table
    0x0c8: set_proximity_trigger
    0x0cd: set_sub_sniff_interval
    0x0ce: enable_repeater_functionality
    0x0cf: update_config_item
    0x0d0: bfc_create_connection
    0x0d1: wbs_bec_params
    0x0d2: read_golden_range
    0x0d3: initiate_multicast_beacon_lock
    0x0d4: terminate_multicast
    0x0d7: enable_h4_ibss
    0x0d8: bluebridge_spi_negotiation_request
    0x0d9: bluebridge_spi_sleepthreshold_request
    0x0da: accessory_protocol_command_group
    0x0db: handle_write_otp_aux_data
    0x0dc: init_mcast_ind_poll
    0x0dd: enter_mcast_ind_poll
    0x0de: disconnect_mcast_ind_poll
    0x0e0: extended_inquiry_handshake
    0x0e1: uartbridge_route_hci_cmd_to_uart_bridge
    0x0e2: olympic
    0x0e4: config_hid_lhl_gpio
    0x0e5: read_hid_lhl_gpio
    0x0e6: le_tx_test
    0x0e7: uartbridge_set_uart_bridge_parameter
    0x0e8: bist_ber
    0x0e9: handle_le_meta_vsc1
    0x0ea: bfc_set_priority
    0x0eb: bfc_read_priority
    0x0ec: ant_command
    0x0ed: link_quality_stats
    0x0ee: read_native_clock
    0x0ef: bfc_set_wakeup_flags
    0x0f2: start_dvt_tinydriver
    0x0f4: set_3_dtv_dual_mode_view
    0x0f5: bfc_read_remoe_bpcs_features
    0x0f7: ignore_usb_reset
    0x0f8: sniff_reconnect_train
    0x0f9: audio_ip_command
    0x0fa: bfc_write_scan_enable
    0x0fe: read_local_firmware_info
    0x0ff: rssi_measurements
    0x101: bfc_read_scan_enable
    0x102: enable_wbs_modified
    0x103: set_vs_event_mask
    0x104: bfc_is_connection_tbfc_suspended
    0x105: set_usb_auto_resume
    0x106: set_direction_finding_parameters
    0x108: change_lna_gain_coex_eci
    0x10c: lte_link_quality_mode
    0x10d: lte_trigger_wci2_message
    0x10e: lte_enable_wci2_messages
    0x10f: lte_enable_wci2_loopback_testing
    0x110: sco_diag_stat
    0x111: set_streaming_connectionless_broadcast
    0x112: receive_streaming_connectonless_broadcast
    0x113: write_connectionless_broadcast_streaming_data
    0x114: flush_streaming_connectionless_broadcast_data
    0x115: factory_cal_set_tx_power
    0x116: factory_cal_trim_tx_power
    0x117: factory_cal_read_temp_settings
    0x118: factory_cal_update_table_settings
    0x11a: write_a2_dp_connection
    0x11b: factory_cal_read_table_settings
    0x11c: dbfw
    0x11d: factory_calibration_rx_rssi_test
    0x11f: lte_coex_timing_advance
    0x123: handle_le_meta_vsc2
    0x128: write_local_supported_extended_features
    0x129: piconet_clock_adjustment
    0x12a: read_retransmission_status
    0x12f: set_transmit_power_range
    0x133: page_inquiry_tx_suppression
    0x135: randomize_native_clock
    0x136: store_factory_calibration_data
    0x13b: read_supported_vs_cs
    0x13c: le_write_local_supported_features
    0x13e: le_read_remote_supported_brcm_features
    0x140: bcs_timeline
    0x141: bcs_timeline_broadcast_receive
    0x142: read_dynamic_memory_pool_statistics
    0x143: handle_iop3dtv_tester_config
    0x145: handle_adc_capture
    0x147: le_extended_duplicate_filter
    0x148: le_create_extended_advertising_instance
    0x149: le_remove_extended_advertising_instance
    0x14a: le_set_extended_advertising_parameters
    0x14b: le_set_extended_advertising_data
    0x14c: le_set_extended_scan_response_data
    0x14d: le_set_extended_advertising_enable
    0x14e: le_update_extended_advertising_instance
    0x153: le_get_android_vendor_capabilities
    0x154: le_multi_advt_command
    0x155: le_rpa_offload
    0x156: le_batch_scan_command
    0x157: le_brcm_pcf
    0x159: get_controller_activity_energy_info
    0x15a: extended_set_scan_parameters
    0x15b: getdebuginfo
    0x15c: write_local_host_state
    0x16e: handle_configure_sleep_lines
    0x171: set_special_sniff_transition_enable
    0x173: enable_bt_sync
    0x179: hciulp_handle_btble_high_power_control
    0x17c: handle_customer_enable_ha_link_commands
    0x17d: dwp_test_commands
    0x17f: olympic_lte_settings
    0x182: write_le_remote_public_address
    0x186: one_second_timer_commands
    0x188: force_wlan_channel
    0x18b: svt_config_setup
    0x18f: handle_customer_read_ha_delta_commands
    0x19a: setup_rss_commands
    0x19c: setup_rss_local_commands
    0x1a1: audio_buffer_commands
    0x1a4: health_status_report
    0x1a8: change_connection_priority
    0x1aa: sam_setup_command
    0x1ab: bthci_cmd_ble_enhanced_transmitter_test_hopping
    0x1af: handle_coex_debug_counters
    0x1bb: read_inquiry_transmit_power
    0x1be: enable_padgc_override
    0x1cb: write_tx_power_afh_mode
    0x1cd: set_minimum_number_of_used_channels
    0x1ce: handle_br_edr_link_quality_stats
    0x35e: sector_erase
    0x3ce: chip_erase
    0x3ed: enter_download_mode
