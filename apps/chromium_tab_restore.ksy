meta:
  id: chromium_tab_restore
  title: Chromium 81 Tab Restore File (Current Tabs / Last Tabs)
  application: Chromium 81
  file-extension: Tabs
  endian: le

seq:
  - id: magic
    # command_storage_backend.cc: kFileSignature
    contents: [83, 78, 83, 83]
  - id: version
    type: u4
    enum: file_version
  - id: commands
    type: command
    repeat: eos
    if: version == file_version::not_encrypted

types:
  command:
    seq:
      - id: size
        type: u2
      - id: command_id
        type: u1
        enum: command_type
      - id: body
        size: size-1
        type:
          switch-on: command_id
          cases:
            'command_type::update_tab_navigation': command_update_tab_navigation
            'command_type::restored_entry': command_restored_entry
            'command_type::selected_navigation_in_tab': command_selected_navigation_in_tab
            'command_type::pinned_state': command_pinned_state
            'command_type::set_extension_app_id': command_set_extension_app_id
            'command_type::set_window_app_name': command_set_window_app_name
            'command_type::window': command_window
            'command_type::group': command_group
            'command_type::set_tab_user_agent_override2': command_set_tab_user_agent_override2
    -webide-representation: '{command_id}'

  # This is necessary due to how PickleIterator::Advance()
  # tries to move read_index_ to an uint32_t-aligned value.
  pickle_padding:
    params:
      - id: advance_size
        type: u4
    instances:
      aligned_size:
        value: ((advance_size + 3) & ~(3))
    seq:
      - id: padding
        size: aligned_size - advance_size

  # PickleIterator::ReadString()
  cr_string:
    seq:
      - id: len
        type: u4
      - id: data
        size: len
        type: str
        encoding: UTF-8
      - id: padding
        type: pickle_padding(len)
    -webide-representation: '{data}'

  # PickleIterator::ReadString16()
  cr_string16:
    seq:
      - id: len
        type: u4
      - id: data
        size: len*2
        type: str
        encoding: UTF-16LE
      - id: padding
        type: pickle_padding(len*2)
    -webide-representation: '{data}'

  # page_state_serialization.cc: ReadMojoPageState()
  mojo_page_state:
    seq:
      - id: len
        type: u4
      # history::mojom::PageState::Deserialize()
      - id: data
        size: len

  page_state_inner:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: version
        type: u4

      - id: mojo_page_state
        type: mojo_page_state
        if: version >= 26

  # This is read as a normal Pickle String (cr_string)
  page_state_outer:
    seq:
      - id: len
        type: u4
      - id: data
        size: len
        type: page_state_inner
      - id: padding
        type: pickle_padding(len)

  extended_info_map_pair:
    seq:
      - id: key
        type: cr_string
      - id: value
        type: cr_string

  command_update_tab_navigation:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: tab_id
        type: u4
      - id: index
        type: u4
      - id: virtual_url_spec
        type: cr_string
      - id: title
        type: cr_string16
      - id: encoded_page_state
        type: page_state_outer
      - id: transition_type
        type: u4
      - id: type_mask
        type: u4
      - id: referrer_spec
        type: cr_string
      - id: ignored_referrer_policy
        type: u4
      - id: original_request_url_spec
        type: cr_string
      - id: is_overriding_user_agent
        type: u4
      - id: timestamp_internal_value
        type: u8
      - id: search_terms
        type: cr_string16
      - id: http_status_code
        type: u4
      - id: correct_referrer_policy
        type: u4
      - id: extended_info_map_size
        type: u4
      - id: extended_info_map
        type: extended_info_map_pair
        repeat: expr
        repeat-expr: extended_info_map_size
      - id: task_id
        type: u8
      - id: parent_task_id
        type: u8
      - id: root_task_id
        type: u8
      - id: children_task_ids_size
        type: u4
      - id: children_task_ids
        type: u8
        repeat: expr
        repeat-expr: children_task_ids_size

  command_restored_entry:
    seq:
      - id: session_id
        type: u4
  command_selected_navigation_in_tab:
    seq:
      - id: tab_id
        type: u4
      - id: index
        type: u4
      - id: timestamp
        type: u8
  # NOTE: payload doesn't matter. kCommandPinnedState is only written if
  # tab is pinned.
  command_pinned_state:
    seq:
      - id: dummy
        size: 0
  command_set_extension_app_id:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: tab_id
        type: u4
      - id: extension_app_id
        type: cr_string
  command_set_window_app_name:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: window_id
        type: u4
      - id: app_name
        type: cr_string
  command_window:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: window_id
        type: u4
      - id: selected_tab_index
        type: u4
      - id: num_tabs
        type: u4
      - id: timestamp
        type: u8
      - id: window_x
        type: u4
      - id: window_y
        type: u4
      - id: window_width
        type: u4
      - id: window_height
        type: u4
      - id: window_show_state
        type: u4
        enum: window_show_state
      - id: workspace
        type: cr_string
  command_group:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: token_high
        type: u8
      - id: token_low
        type: u8
      - id: title
        type: cr_string16
      - id: color
        type: u4
  command_set_tab_user_agent_override2:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: tab_id
        type: u4
      - id: user_agent_override
        type: cr_string
      - id: has_ua_metadata_override
        type: u4
      - id: ua_metadata_override
        type: cr_string
        if: has_ua_metadata_override != 0

enums:
  # tab_restore_service_impl.cc: SerializedWindowShowState
  window_show_state:
    0: default
    1: normal
    2: minimized
    3: maximized
    4: inactive
    5: fullscreen

  # command_storage_backend.cc:
  file_version:
    1: not_encrypted # kFileCurrentVersion
    2: encrypted     # kEncryptedFileCurrentVersion

  # session_service_commands.cc
  command_type:
    1: update_tab_navigation
    2: restored_entry
    3: deprecated_window
    4: selected_navigation_in_tab
    5: pinned_state
    6: set_extension_app_id
    7: set_window_app_name
    8: deprecated_set_tab_user_agent_override
    9: window
    10: group
    11: set_tab_user_agent_override2
