meta:
  id: spider_sav
  title: Windows XP Spider Solitaire save file
  application:
    - Windows Spider Solitaire
  file-extension: sav
  xref:
    wikidata: Q2512977
  license: Unlicense
  endian: le
  imports:
    - ../common/prg/prg_lcg

doc-ref: http://www.genialitaet.de/fw/Spider.sav
doc: |
  from spider_sav import SpiderSav
  import numpy as np
  import unicodedata
  
  s = SpiderSav.from_file("./spider.sav")
  
  prgState = s.initial_prg_state
  def prng():
    global prgState
    res = prgState.value
    prgState = prgState.next
    return res
  
  suits = [unicodedata.lookup("BLACK " + s.Suit(i).name.upper() + " SUIT") for i in range(4)]
  
  ranks = ["A"]
  ranks.extend(range(2, 9+2))
  ranks.extend(["J", "Q", "K"])
  
  initialDeck = []
  for i in range(len(suits)*len(ranks)):
    crd = s.Card(i, None, s, s)
    initialDeck.append((ranks[crd.rank.value], suits[crd.suit.value]))
  
  nDecs = np.vstack([initialDeck] * s.deck_count)
  
  
  def makePermutation(total):
    permutation = [None] * total
    for i in range(total):
      slot = prng() % total;
      while permutation[slot] is not None:
        slot = prng() % total;
      permutation[slot]=i
    return permutation
  
  prgState = s.initial_prg_state
  perm = makePermutation(nDecs.shape[0])
  permuted = nDecs[perm]
  
  rNo = 0
  dealtInDecks = 0
  while(True):
    row = []
    cardDealt = False
    for c in s.columns:
      if rNo < c.total:
        cr = c.card_data[rNo]
        cardStr = "".join(permuted[cr.ptr])
        if cr.is_open:
          cardStr = "".join((" ", cardStr, " "))
        else:
          cardStr = "".join(("[", cardStr, "]"))
        
        row.append(cardStr)
        cardDealt = True
        dealtInDecks += 1
      else:
        row.append("     "*4)
    if not cardDealt:
      break
    print("\t".join(row))
    rNo += 1

seq:
  - id: suits_used_count
    type: u4
    doc: internally it uses 4 suits, but transforms the suits of cards into the needed suit
  - id: prg_seed
    type: u4
  - id: card_count_without_undealt_rows
    type: u4
  - id: card_count_without_undealt_rows_and_completed_runs
    type: u4
  - id: moves
    type: u4
  - id: dealt_rows
    type: u4
  - id: complete_runs_of_suits
    type: u4
    repeat: expr
    repeat-expr: 4
  - id: suit_of_complete_run
    type: u4
    repeat: expr
    repeat-expr: 8
  - id: columns
    type: column
    repeat: expr
    repeat-expr: column_count
enums:
  suit:
    0: club
    1: diamond
    2: heart
    3: spade
  rank:
    0: ace
    1: two
    2: three
    3: four
    4: five
    5: six
    6: seven
    7: eight
    8: nine
    9: ten
    10: jack
    11: queen
    12: king
instances:
  column_count:
    value: 10
  deck_count:
    value: 2
  ranks_count:
    value: 13
  cards_in_a_deck:
    value: 52
  total:
    value: deck_count * cards_in_a_deck
  initial_prg_state:
    pos: 0
    type: prg_lcg(0x343fd, 0x269ec3, 15, prg_seed)
  #decks:
  #  type: card(_index)
  #  repeat: expr
  #  repeat-expr: total
  
types:
  column:
    seq:
      - id: total
        type: u4
      - id: closed
        type: u4
      - id: card_data
        type: card_ptr(_index)
        repeat: expr
        repeat-expr: total
  card_ptr:
    params:
      - id: idx
        type: u1
    seq:
      - id: ptr
        type: u4
    instances:
      is_open:
        value: idx >= _parent.closed
    #  decoded:
    #    value: _root.decks[ptr]
  card:
    params:
      - id: idx
        type: u4
    instances:
  #    prg_state:
  #      value: "idx==0?_root.initial_prg_state:_root.decks[idx-1]"
      num_in_deck:
        value: idx % _root.cards_in_a_deck
      suit:
        value: num_in_deck / _root.ranks_count
        enum: suit
      rank:
        value: num_in_deck % _root.ranks_count
        enum: rank
  
