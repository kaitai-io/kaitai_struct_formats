meta:
  id: space_rangers_qm
  title: Space Rangers Text Quest
  file-extension:
    - qm
    - qmm
  license: Unlicense
  endian: le
  encoding: utf-16le
  application:
    - TGE
    - Space Rangers
    - Space Rangers 2: Dominators
doc: |
  You can download quests from: 
    * the sites mentioned on https://ifwiki.ru/TGE
    * http://www.rilarhiv.ru/tge2.htm
doc-ref:
  - "http://www.abaduaber.narod.ru/lastqm.txt"
  - "https://github.com/roginvs/space-rangers-quest/blob/master/src/lib/qmreader.ts"
  - "https://github.com/ObKo/OpenSR/blob/rework/QM/QM.cpp https://github.com/ObKo/OpenSR/blob/rework/include/OpenSR/QM/QM.h"
  - "https://github.com/VirRus77/Space-Rangers-Quests/blob/master/SpaceRangersQuests.Model/FileQuest.cs"
instances:
  description_count:
    value: 10
  format_version:
    value: (format_version_num & 0xF)
  parameter_count_comp:
    value: (6 << format_version)
  parameter_count_comp_1:
    value: 'parameter_count_comp < 48 ? 48 : parameter_count_comp'
  parameter_count:
    value: ((format_version<6)?parameter_count_comp_1:parameter_count_num)
seq:
  - id: signature
    contents: [0xD3, 0x35, 0x3A]
  - id: format_version_num
    type: u1
  - id: version
    type: version
  - id: changelog
    type: sr_str
    if: format_version >= 7
    
  - id: giver_race
    type: race
  - id: success_condition
    type: u1
    enum: success_condition
  - id: planet_races
    type: race
    
  - id: unkn_sometimes0
    type: u4
    if: format_version < 6
  - id: player_status
    type: player_status
    
  - id: unkn_sometimes1
    type: u4
    if: format_version < 6
  - id: player_race
    type: race
    
  - id: unkn_sometimes2 # shouldn't be, QM.cpp
    type: u4
    if: format_version < 6
  - id: player_reputation
    type: u4
    
  - id: screen_size
    type: vec2_u1
    doc: pixels
  - id: grid_granularity
    type: vec2_u1
  - id: transition_limit
    type: u4
    doc: 0 is unlimited
  
  - id: difficulty
    type: u4
    doc: Сложность квеста в процентах

  - id: parameter_count_num
    type: u4
    if: format_version > 6
  - id: parameters
    type: parameter(_index)
    repeat: expr
    repeat-expr: parameter_count
  
  - id: to_star
    type: sr_str
  - id: parsec
    type: sr_str
  - id: artefact
    type: sr_str
  - id: to_planet
    type: sr_str
  - id: date
    type: sr_str
  - id: money
    type: sr_str
  - id: from_planet
    type: sr_str
  - id: from_star
    type: sr_str
  - id: ranger
    type: sr_str
  - id: loc_count
    type: u4
  - id: transition_count
    type: u4
  - id: congrat_message
    type: sr_str
  - id: description
    type: sr_str
  - id: unkn3
    type: u4
  - id: unkn4
    type: u4
  - id: locations
    type: location
    repeat: expr
    repeat-expr: loc_count
  - id: transitions
    type: transition
    repeat: expr
    repeat-expr: transition_count
enums:
  success_condition:
    00: arrival
    01: immediately
types:
  pas_str:
    seq:
      - id: size
        type: u4
      - id: value
        size: size * 2
        type: str
  sr_str:
    seq:
      - id: present
        type: u4
      - id: str
        type: pas_str
        if: present != 0
  version:
    seq:
      - id: major
        type: u2
      - id: minor
        type: u2

  vec2_u1:
    seq:
      - id: vec
        type: u1
        repeat: expr
        repeat-expr: 2
  vec2_u4:
    seq:
      - id: vec
        type: u4
        repeat: expr
        repeat-expr: 2
  
  player_status:
    seq:
      - id: reserved
        type: b5
      - id: warrior
        type: b1
      - id: pirate
        type: b1
      - id: merchant
        type: b1
  race:
    seq:
      - id: reserved0
        type: b1
      - id: unhabited
        type: b1
      - id: reserved1
        type: b1
      - id: gaal
        type: b1
      - id: faeyan
        type: b1
      - id: human
        type: b1
      - id: peleng
        type: b1
      - id: malloq
        type: b1

  parameter:
    params:
      - id: idx
        type: u4
    seq:
      - id: min
        type: u4
      - id: max #4
        type: u4

      - id: ave #8
        type: u4
        if: _root.format_version < 6
      
      - id: type #9
        type: u1
        enum: type
      
      - id: unkn1 #10
        type: u1
      - id: unkn2 #11
        type: u1
      - id: unkn3 #12
        type: u1
        
      - id: unkn4 #13
        type: u1
        if: _root.format_version < 6
      
      - id: unkn16
        size: 16
        if: idx ==0 and _root.format_version <= 2 #?
      
      - id: show_at_zero #14
        type: u1
      - id: critical_boundary #15
        type: u1
        enum: critical_boundary #16
      - id: is_active
        type: u1
      - id: grades_count
        type: u4
      
      - id: is_player_money
        type: u1
      
      - id: name #23
        type: sr_str
        
      - id: grades
        type: grade
        repeat: expr
        repeat-expr: grades_count
      - id: critical_message
        type: sr_str
      
      - id: picture
        type: sr_str
        if: _root.format_version >= 6
      - id: sound
        type: sr_str
        if: _root.format_version >= 6
      - id: track
        type: sr_str
        if: _root.format_version >= 6
      
      - id: start_value
        type: sr_str

    types:
      grade:
        seq:
          - id: range
            type: vec2_u4
          - id: label
            type: sr_str
    enums:
      type:
        00: normal
        01: fail
        02: success
        03: death
      critical_boundary:
        00: max
        01: min
  parameter_action:
    seq:
      - id: unkn
        type: u4
      - id: range
        type: vec2_u4
      - id: delta
        type: s4
      - id: show_
        type: u1
        enum: show_mode
      - id: unit
        type: s4
        enum: unit
      - id: percent_present
        type: u1
      - id: delta_present
        type: u1
      - id: expr_present
        type: u1
      - id: expr
        type: sr_str

      
      - id: includes
        type: includes
      - id: mods
        type: mods

      - id: threshold_message
        type: sr_str
      
      - id: picture
        type: sr_str
        if: _root.format_version >= 6
      - id: sound
        type: sr_str
        if: _root.format_version >= 6
      - id: track
        type: sr_str
        if: _root.format_version >= 6
    enums:
      show_mode:
        0: no_change
        1: show
        2: hide
      unit:
        0x00: value
        0x01: summ
        0x02: percentage
        0x03: expr
        0x1000000: unkn1000000
    types:
      includes:
        seq:
          - id: count
            type: u4
          - id: accept
            type: u1
          - id: values
            type: u4
            repeat: expr
            repeat-expr: count
      mods:
        seq:
          - id: count
            type: u4
          - id: type
            type: u1
          - id: values
            type: u4
            repeat: expr
            repeat-expr: count

  location:
    seq:
      - id: passes_days
        type: u4
      - id: coord
        type: vec2_u4
        doc: location coordinate
      - id: id
        type: u4
      
      - id: visit_limit
        type: u4
        if: _root.format_version >= 6
      
      - id: type
        type: type
      
      - id: parameter_action
        type: parameter_action
        repeat: expr
        repeat-expr: _root.parameter_count
      
      - id: description_count_num
        type: u4
        if: _root.format_version >= 6
        
      - id: descriptions
        type: description
        repeat: expr
        repeat-expr: _root.description_count
      
      - id: text_selection_method
        type: u1
        enum: text_selection_method
      - id: unkn1
        type: u4
      - id: name
        type: sr_str
      - id: unkn3
        type: sr_str
        doc: Длина еще одного текста (он повторяет первое описание локации, при изменении - ничего), назначение которого мне не ясно
      - id: text_selection_formula
        type: sr_str
    instances:
      description_count:
        value: "((_root.format_version >= 6)?description_count_num:_root.description_count)"
    types:
      type:
        seq:
          - id: is_initial_
            type: u1
            if: _root.format_version < 6
          - id: is_success_
            type: u1
            if: _root.format_version < 6
          - id: is_fail_
            type: u1
            if: _root.format_version < 6
          - id: is_death_
            type: u1
            if: _root.format_version < 6
          - id: is_empty_
            type: u1
            if: _root.format_version < 6
          
          - id: type_
            type: u1
            if: _root.format_version >= 6
            
      description:
        seq:
          - id: msg
            type: sr_str
          
          - id: picture
            type: sr_str
            if: _root.format_version >= 6
          - id: sound
            type: sr_str
            if: _root.format_version >= 6
          - id: track
            type: sr_str
            if: _root.format_version >= 6
    enums:
      show:
        0: no_change
        1: show
        2: hide

      text_selection_method:
        0: order
        1: formula
  transition:
    seq:
      - id: priority
        type: f8
      - id: passes_days
        type: u4
      - id: id
        type: u4
      - id: source_id
        type: u4
      - id: destination_id
        type: u4
      - id: color
        type: u1
        if: _root.format_version < 6
      - id: always_show
        type: u1
      - id: limit
        type: u4
      - id: show_order
        type: u4
      - id: actions
        type: parameter_action
        repeat: expr
        repeat-expr: _root.parameter_count
      - id: condition_expr
        type: sr_str
      - id: title
        type: sr_str
      - id: description
        type: sr_str
