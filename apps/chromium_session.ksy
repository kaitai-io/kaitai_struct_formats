meta:
  id: chromium_session
  title: Chromium 81 Session File (Current Session / Last Session)
  application: Chromium 81
  file-extension: Session
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
            'command_type::set_tab_window': command_set_tab_window
            'command_type::set_tab_index_in_window': command_set_tab_index_in_window
            'command_type::tab_navigation_path_pruned_from_back': command_tab_navigation_path_pruned_from_back
            'command_type::update_tab_navigation': command_update_tab_navigation
            'command_type::set_selected_navigation_index': command_set_selected_navigation_index
            'command_type::set_selected_tab_in_index': command_set_selected_tab_in_index
            'command_type::set_window_type': command_set_window_type
            'command_type::tab_navigation_path_pruned_from_front': command_tab_navigation_path_pruned_from_front
            'command_type::set_pinned_state': command_set_pinned_state
            'command_type::set_extension_app_id': command_set_extension_app_id
            'command_type::set_window_bounds3': command_set_window_bounds3
            'command_type::set_window_app_name': command_set_window_app_name
            'command_type::tab_closed': command_tab_closed
            'command_type::window_closed': command_window_closed
            'command_type::set_tab_user_agent_override': command_set_tab_user_agent_override
            'command_type::session_storage_associated': command_session_storage_associated
            'command_type::set_active_window': command_set_active_window
            'command_type::last_active_time': command_last_active_time
            'command_type::set_window_workspace2': command_set_window_workspace2
            'command_type::tab_navigation_path_pruned': command_tab_navigation_path_pruned
            'command_type::set_tab_group': command_set_tab_group
            'command_type::set_tab_group_metadata': command_set_tab_group_metadata
            'command_type::set_tab_group_metadata2': command_set_tab_group_metadata2
            'command_type::set_tab_guid': command_set_tab_guid
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

  command_set_tab_window:
    seq:
      - id: window_id
        type: u4
      - id: tab_id
        type: u4
  command_set_tab_index_in_window:
    seq:
      - id: tab_id
        type: u4
      - id: tab_visual_index
        type: u4
  command_tab_navigation_path_pruned_from_back:
    seq:
      - id: tab_id
        type: u4
      - id: navigation_index
        type: u4

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
      # - id: extended_info_map
      #   type: command_update_tab_navigation_extended_info_map
      #   repeat:
      #  should contain [string key, string value] pairs
      - id: task_id
        type: u8
      - id: parent_task_id
        type: u8
      - id: root_task_id
        type: u8
      - id: children_task_ids_size
        type: u4
      # should contain [u8 children_task_id] items

  command_set_selected_navigation_index:
    seq:
      - id: tab_id
        type: u4
      - id: current_navigation_index
        type: u4
  command_set_selected_tab_in_index:
    seq:
      - id: window_id
        type: u4
      - id: index
        type: u4
  command_set_window_type:
    seq:
      - id: window_id
        type: u4
      - id: window_type
        type: u4
  command_tab_navigation_path_pruned_from_front:
    seq:
      - id: tab_id
        type: u4
      - id: navigation_index
        type: u4
  command_set_pinned_state:
    seq:
      - id: tab_id
        type: u4
      - id: pinned_state
        type: u4
  command_set_extension_app_id:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: tab_id
        type: u4
      - id: extension_app_id
        type: cr_string
  command_set_window_bounds3:
    seq:
      - id: window_id
        type: u4
      - id: x
        type: u4
      - id: y
        type: u4
      - id: w
        type: u4
      - id: h
        type: u4
      - id: show_state
        type: u4
  command_set_window_app_name:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: window_id
        type: u4
      - id: app_name
        type: cr_string
  command_tab_closed:
    seq:
      - id: tab_id
        type: u8
      - id: close_time
        type: u8
      # FIXME: 4 bytes are left unused
  command_window_closed:
    seq:
      - id: window_id
        type: u8
      - id: close_time
        type: u8
      # FIXME: 4 bytes are left unused
  command_set_tab_user_agent_override:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: tab_id
        type: u4
      - id: user_agent_override
        type: cr_string
  command_session_storage_associated:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: command_tab_id
        type: u4
      - id: session_storage_persistent_id
        type: cr_string
  command_set_active_window:
    seq:
      - id: active_window_id
        type: u4
  command_last_active_time:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: tab_id
        type: u4
      - id: last_active_time
        type: u8
  command_set_window_workspace2:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: window_id
        type: u4
      - id: workspace
        type: cr_string
        doc: |
          On macOS contains a BASE64-encoded binary plist.
  command_tab_navigation_path_pruned:
    seq:
      - id: tab_id
        type: u4
      - id: index
        type: u4
        doc: |
          Index starting which |count| entries were removed.
      - id: count
        type: u4
        doc: |
          Number of entries removed.
  command_set_tab_group:
    seq:
      - id: tab_id
        type: u8
      - id: id_high
        type: u8
      - id: id_low
        type: u8
      - id: has_group
        type: u8
      # FIXME: some data is unused
  command_set_tab_group_metadata:
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
        doc: |
          Unused, tab_groups::TabGroupColorId::kGrey is used.
  command_set_tab_group_metadata2:
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
  command_set_tab_guid:
    seq:
      - id: pickle_payload_size
        type: u4
      - id: tab_id
        type: u4
      - id: guid
        type: cr_string
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
  # command_storage_backend.cc:
  file_version:
    1: not_encrypted # kFileCurrentVersion
    2: encrypted     # kEncryptedFileCurrentVersion

  # session_service_commands.cc
  command_type:
    0: set_tab_window

    # kCommandSetWindowBounds, Superseded by kCommandSetWindowBounds3
    1: obsolete_set_window_bounds

    2: set_tab_index_in_window

    3: na
    4: na

    # OBSOLETE: Preserved for backward compatibility. Using
    # kCommandTabNavigationPathPruned instead
    5: tab_navigation_path_pruned_from_back

    6: update_tab_navigation
    7: set_selected_navigation_index
    8: set_selected_tab_in_index
    9: set_window_type

    # kCommandSetWindowBounds2, Superseded by kCommandSetWindowBounds3.
    10: obsolete_set_window_bounds2

    11: tab_navigation_path_pruned_from_front
    12: set_pinned_state
    13: set_extension_app_id
    14: set_window_bounds3
    15: set_window_app_name
    16: tab_closed
    17: window_closed
    18: set_tab_user_agent_override
    19: session_storage_associated
    20: set_active_window
    21: last_active_time
    23: set_window_workspace2
    24: tab_navigation_path_pruned
    25: set_tab_group
    26: set_tab_group_metadata
    27: set_tab_group_metadata2
    28: set_tab_guid
    29: set_tab_user_agent_override2

