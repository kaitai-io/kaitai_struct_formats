meta:
  id: usbd_status_windows
  title: usbd_status
  endian: le
  bit-endian: le

doc-ref:
  - https://raw.githubusercontent.com/reactos/reactos/master/sdk/include/psdk/usb.h
  - https://docs.microsoft.com/en-us/previous-versions/windows/hardware/drivers/ff539136(v=vs.85)

seq:
  - id: error
    type: b1
  - id: pending
    type: b1
  - id: reserved
    type: b2
  - id: code
    type: b28
    enum: code
enums:
  code:
    0x0000001:
      id: crc
      -orig-id: USBD_STATUS_CRC
    0x0000002:
      id: btstuff
      -orig-id: USBD_STATUS_BTSTUFF
    0x0000003:
      id: data_toggle_mismatch
      -orig-id: USBD_STATUS_DATA_TOGGLE_MISMATCH
    0x0000004:
      id: stall_pid
      -orig-id: USBD_STATUS_STALL_PID
    0x0000005:
      id: dev_not_responding
      -orig-id: USBD_STATUS_DEV_NOT_RESPONDING
    0x0000006:
      id: pid_check_failure
      -orig-id: USBD_STATUS_PID_CHECK_FAILURE
    0x0000007:
      id: unexpected_pid
      -orig-id: USBD_STATUS_UNEXPECTED_PID
    0x0000008:
      id: data_overrun
      -orig-id: USBD_STATUS_DATA_OVERRUN
    0x0000009:
      id: data_underrun
      -orig-id: USBD_STATUS_DATA_UNDERRUN
    0x000000A:
      id: reserved1
      -orig-id: USBD_STATUS_RESERVED1
    0x000000B:
      id: reserved2
      -orig-id: USBD_STATUS_RESERVED2
    0x000000C:
      id: buffer_overrun
      -orig-id: USBD_STATUS_BUFFER_OVERRUN
    0x000000D:
      id: buffer_underrun
      -orig-id: USBD_STATUS_BUFFER_UNDERRUN
    0x000000F:
      id: not_accessed
      -orig-id: USBD_STATUS_NOT_ACCESSED
    0x0000010:
      id: fifo
      -orig-id: USBD_STATUS_FIFO
    0x0000011:
      id: xact_error
      -orig-id: USBD_STATUS_XACT_ERROR
    0x0000012:
      id: babble_detected
      -orig-id: USBD_STATUS_BABBLE_DETECTED
    0x0000013:
      id: data_buffer_error
      -orig-id: USBD_STATUS_DATA_BUFFER_ERROR
    0x0000030:
      id: endpoint_halted
      -orig-id: USBD_STATUS_ENDPOINT_HALTED

    0x0000200:
      id: invalid_urb_function
      -orig-id: USBD_STATUS_INVALID_URB_FUNCTION
    0x0000300:
      id: invalid_parameter
      -orig-id: USBD_STATUS_INVALID_PARAMETER
    0x0000400:
      id: error_busy
      -orig-id: USBD_STATUS_ERROR_BUSY
    0x0000600:
      id: invalid_pipe_handle
      -orig-id: USBD_STATUS_INVALID_PIPE_HANDLE
    0x0000700:
      id: no_bandwidth
      -orig-id: USBD_STATUS_NO_BANDWIDTH
    0x0000800:
      id: internal_hc_error
      -orig-id: USBD_STATUS_INTERNAL_HC_ERROR
    0x0000900:
      id: error_short_transfer
      -orig-id: USBD_STATUS_ERROR_SHORT_TRANSFER

    0x0000A00:
      id: bad_start_frame
      -orig-id: USBD_STATUS_BAD_START_FRAME
    0x0000B00:
      id: isoch_request_failed
      -orig-id: USBD_STATUS_ISOCH_REQUEST_FAILED
    0x0000C00:
      id: frame_control_owned
      -orig-id: USBD_STATUS_FRAME_CONTROL_OWNED
    0x0000D00:
      id: frame_control_not_owned
      -orig-id: USBD_STATUS_FRAME_CONTROL_NOT_OWNED
    0x0000E00:
      id: not_supported
      -orig-id: USBD_STATUS_NOT_SUPPORTED
    0x0000F00:
      id: invalid_configuration_descriptor
      -orig-id: USBD_STATUS_INVALID_CONFIGURATION_DESCRIPTOR
    0x0001000:
      id: insufficient_resources
      -orig-id: USBD_STATUS_INSUFFICIENT_RESOURCES
    0x0002000:
      id: set_config_failed
      -orig-id: USBD_STATUS_SET_CONFIG_FAILED
    0x0003000:
      id: buffer_too_small
      -orig-id: USBD_STATUS_BUFFER_TOO_SMALL
    0x0004000:
      id: interface_not_found
      -orig-id: USBD_STATUS_INTERFACE_NOT_FOUND
    0x0005000:
      id: invalid_pipe_flags
      -orig-id: USBD_STATUS_INVALID_PIPE_FLAGS
    0x0006000:
      id: timeout
      -orig-id: USBD_STATUS_TIMEOUT
    0x0007000:
      id: device_gone
      -orig-id: USBD_STATUS_DEVICE_GONE
    0x0008000:
      id: status_not_mapped
      -orig-id: USBD_STATUS_STATUS_NOT_MAPPED
    0x0009000:
      id: hub_internal_error
      -orig-id: USBD_STATUS_HUB_INTERNAL_ERROR
    0x0010000:
      id: canceled
      -orig-id: USBD_STATUS_CANCELED
    0x0020000:
      id: iso_not_accessed_by_hw
      -orig-id: USBD_STATUS_ISO_NOT_ACCESSED_BY_HW
    0x0030000:
      id: iso_td_error
      -orig-id: USBD_STATUS_ISO_TD_ERROR
    0x0040000:
      id: iso_na_late_usbport
      -orig-id: USBD_STATUS_ISO_NA_LATE_USBPORT
    0x0050000:
      id: iso_not_accessed_late
      -orig-id: USBD_STATUS_ISO_NOT_ACCESSED_LATE
    0x0100000:
      id: bad_descriptor
      -orig-id: USBD_STATUS_BAD_DESCRIPTOR
    0x0100001:
      id: bad_descriptor_blen
      -orig-id: USBD_STATUS_BAD_DESCRIPTOR_BLEN
    0x0100002:
      id: bad_descriptor_type
      -orig-id: USBD_STATUS_BAD_DESCRIPTOR_TYPE
    0x0100003:
      id: bad_interface_descriptor
      -orig-id: USBD_STATUS_BAD_INTERFACE_DESCRIPTOR
    0x0100004:
      id: bad_endpoint_descriptor
      -orig-id: USBD_STATUS_BAD_ENDPOINT_DESCRIPTOR
    0x0100005:
      id: bad_interface_assoc_descriptor
      -orig-id: USBD_STATUS_BAD_INTERFACE_ASSOC_DESCRIPTOR
    0x0100006:
      id: bad_config_desc_length
      -orig-id: USBD_STATUS_BAD_CONFIG_DESC_LENGTH
    0x0100007:
      id: bad_number_of_interfaces
      -orig-id: USBD_STATUS_BAD_NUMBER_OF_INTERFACES
    0x0100008:
      id: bad_number_of_endpoints
      -orig-id: USBD_STATUS_BAD_NUMBER_OF_ENDPOINTS
    0x0100009:
      id: bad_endpoint_address
      -orig-id: USBD_STATUS_BAD_ENDPOINT_ADDRESS
