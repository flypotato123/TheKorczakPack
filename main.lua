--- STEAMODDED HEADER
--- MOD_NAME: The Korczak Pack
--- MOD_ID: KorczakPack
--- MOD_AUTHOR: [Korczak & Flypotato]
--- LOADER_VERSION_GEQ: 1.0.0
--- VERSION: 1.1.0
--- MOD_DESCRIPTION: A collection of Jokers concocted by HyperKorczak and brought to life by Flypotato.
--- PREFIX: korczak
--- PRIORITY: 19974
--- BADGE_COLOUR: FD6435
----------------------------------------------
------------MOD CODE -------------------------

  SMODS.Atlas{
    key = 'korczak', --atlas key
    path = 'kp_jokers.png', --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
    px = 71, --width of one card
    py = 95, -- height of one card
  }

  SMODS.Atlas{
    key = 'modicon', --atlas key
    path = 'icon.png', --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
    px = 34, --width of one card
    py = 34 -- height of one card
  }
  


local korczakSkins = {
  {
    suit = "spades",
    file = "SD",
    name = "Space Dogs"
  },
  {
    suit = "hearts",
    file = "JR",
    name = "Jumpsuit Red"
  },
  {
    suit = "diamonds",
    file = "KorczakForHire",
    name = "Gearloose Pirates"
  },
  {
    suit = "clubs",
    file = "SB",
    name = "Space Bounty"
  }
}

local ranks = {'Jack', 'Queen', "King"} 

for _, skin in ipairs(korczakSkins) do

    SMODS.Atlas{  
      key = "korczak_" .. skin.suit ..'_lc',
      px = 71,
      py = 95,
      path = skin.file .. "_1.png",
      prefix_config = {key = false}, 
  }
    SMODS.Atlas{  
        key = "korczak_" .. skin.suit ..'_hc',
        px = 71,
        py = 95,
        path = skin.file .. "_2.png",
        prefix_config = {key = false}, 
    }

    SMODS.DeckSkin{
        key = skin.suit.."_skin",
        suit = skin.suit:gsub("^%l", string.upper),
        ranks = ranks,
        lc_atlas = "korczak_" .. skin.suit ..'_lc',
        hc_atlas = ("korczak_" .. skin.suit ..'_hc'),
        loc_txt = {
            ['en-us'] = skin.name
        },
        posStyle = 'collab'
    }
end




  
  local igo = Game.init_game_object
  function Game:init_game_object()

    -- arbitrary settings for all cards with specific suit/ranks for when you're not in the game itself

    local ret = igo(self)
    ret.current_round.duraksuit = 'Spades'
    ret.current_round.chairman_card =  {rank = 'Ace'}
    ret.current_round.xmarks_card =  {rank = 'Ace'}
    ret.current_round.chairman_mult = 10

    
    -- ret.current_round.comic_book_rank =  {rank = 2}

    ret.current_round.painter_asthetic1 =  'Spades' 
    ret.current_round.painter_asthetic2 =  'Hearts'
    ret.current_round.web_search_hand =  'Flush'

    
    ret.current_round.encounter_card =  {rank = '3', suit = "Spades"}

    
    ret.current_round.auys_card =  {rank = "King"}


    return ret
  end


  function SMODS.current_mod.reset_game_globals(run_start)


    if(run_start) then

      -- bans all non-vanilla cards in challenges
      if(G.GAME.challenge and string.len(G.GAME.challenge)>=10 and string.sub(G.GAME.challenge,1,10) == "c_korczak_") then
        
        for k,v in pairs(G.P_CENTERS) do

          if v.set == 'Voucher' then

            sendDebugMessage(tprint(v))

          end

          if v.mod and v.mod.id ~= "KorczakPack" then
            G.GAME.banned_keys[k] = true
          end
        end
        for k,v in pairs(G.P_BLINDS) do
          if v.mod and v.mod.id ~= "KorczakPack" then
            G.GAME.banned_keys[k] = true
          end
        end
        for k,v in pairs(G.P_TAGS) do
          if v.mod and v.mod.id ~= "KorczakPack" then
            G.GAME.banned_keys[k] = true
          end
        end
        
        G.from_boss_tag = true
        G.FUNCS.reroll_boss()
      end


      G.GAME.current_round.spent_on_rerolls = 0
      G.GAME.current_round.jokers_bought_then_sold = 0
      G.GAME.current_round.jokers_destroyed = 0
      G.GAME.current_round.wilds_destroyed = 0
      G.GAME.current_round.tarot_money = false
      
      if(G.GAME.modifiers.spectral_shop) then
        G.GAME.spectral_rate = 2
      end

      if(G.GAME.modifiers.cryptid_hungry) then
        G.GAME.spectral_rate = 1
      end


      G.GAME.current_round.glorious_modifiers = {}

      G.GAME.starting_params.boosters_in_shop = (G.GAME.modifiers.booster_slots or G.GAME.starting_params.boosters_in_shop or 2)
      
      if(G.GAME.modifiers.no_planets) then
      G.GAME.planet_rate = 0
      end
      
      -- auys_refresh()
      G.GAME.modifiers.scaling = G.GAME.modifiers.blind_scaling or G.GAME.modifiers.scaling

        G.E_MANAGER:add_event(Event({
          func = function()

        for i = 1, #G.jokers.cards do
          -- gives CEO and shopkeep ceo approval
          G.jokers.cards[i].ability.ceo_approved = true
        end

        return true end
      }))


    end
    

    


    --durak suits


    if(run_start or ( not(G.GAME.modifiers and G.GAME.modifiers.kozer_suit and not(G.GAME.blind.boss)))) then

  G.GAME.current_round.duraksuit =  'Spades'
  
  local valid_durak_cards = {}
  for _, v in ipairs(G.playing_cards) do
    if not SMODS.has_no_suit(v) then -- Abstracted enhancement check for jokers being able to give cards additional enhancements

      valid_durak_cards[#valid_durak_cards+1] = v

    end
  end
  if valid_durak_cards[1] then 
    local durak_chosen_card = pseudorandom_element(valid_durak_cards, pseudoseed('duraksuit'..G.GAME.round_resets.ante))
    G.GAME.current_round.duraksuit = durak_chosen_card.base.suit
  end
  
end


  
  G.GAME.current_round.chairman_mult = pseudorandom('chairman_mult', 5, 20)

  G.GAME.current_round.chairman_card = {rank = 'Ace'}
  local valid_chairman_cards = {}
  for k, v in ipairs(G.playing_cards) do
      if v.ability.effect ~= 'Stone Card' then
        if v.base.id > 0 then
          valid_chairman_cards[#valid_chairman_cards+1] = v
        end
      end
  end
  if valid_chairman_cards[1] then 
      local chairman_card = pseudorandom_element(valid_chairman_cards, pseudoseed('chairmanrank'..G.GAME.round_resets.ante))
      G.GAME.current_round.chairman_card.rank = chairman_card.base.value
      G.GAME.current_round.chairman_card.id = chairman_card.base.id
    end
    
    -- glorious whatever
    if G.GAME.modifiers.glorious_leader and G.GAME.blind and G.GAME.blind.boss then
    
      local effects = 
      {
        {key = "p_dollars", value = 3},
        {key = "x_mult", value = 1.5},
        {key = "chips", value = 50},
        {key = "debuff", value = true},
        {key = "reset_money", value = true},
        {key = "destroy_random_joker", value = true},
      }



      local try_glorious = 0

      while try_glorious < 100 do

    
        


    G.GAME.current_round.glorious_card = {rank = 'Ace'}
    local valid_glorious_cards = {}
    for k, v in ipairs(G.playing_cards) do
      if v.ability.effect ~= 'Stone Card' then
        if v.base.id > 0 then
        valid_glorious_cards[#valid_glorious_cards+1] = v
        end
      end
    end
    if valid_glorious_cards[1] then 
      local glorious_card = pseudorandom_element(valid_glorious_cards, pseudoseed('gloriousrank'..G.GAME.round_resets.ante))
      local effect = pseudorandom_element(effects, pseudoseed('gloriouseffect'..G.GAME.round_resets.ante))
      
      if(not G.GAME.current_round.glorious_modifiers[glorious_card.base.id]) then
        G.GAME.current_round.glorious_modifiers[glorious_card.base.id] = {}
      end

      
      if(G.GAME.current_round.glorious_modifiers[glorious_card.base.id][effect.key] ~= effect.value) then
      
        try_glorious = 100
        G.GAME.current_round.glorious_modifiers[glorious_card.base.id][effect.key] = effect.value

      else
        try_glorious = try_glorious + 1
      end

      -- card_eval_status_text(G.jokers.cards[1], 'extra', nil, nil, nil, {message = effect.key .. " " .. glorious_card.base.id, colour = G.C.GREEN})
    
  end
end
      
  end

  -- G.GAME.current_round.comic_book_rank = {rank = 'King'}
  -- local valid_comic_book_cards = {}
  -- for k, v in ipairs(G.playing_cards) do
  --     if v.ability.effect ~= 'Stone Card' then
  --         valid_comic_book_cards[#valid_comic_book_cards+1] = v
  --     end
  -- end
  -- if valid_comic_book_cards[1] then 
  --     local comic_book_card = pseudorandom_element(valid_comic_book_cards, pseudoseed('comic_boko'..G.GAME.round_resets.ante))
  --     G.GAME.current_round.comic_book_rank.rank = comic_book_card.base.value
  --     G.GAME.current_round.comic_book_rank.id = comic_book_card.base.id
  -- end



  
  G.GAME.current_round.encounter_card = {rank = '3', suit = 'Spades'}
  local valid_encounter_cards = {}
  for k, v in ipairs(G.playing_cards) do
      if v.ability.effect ~= 'Stone Card' and v.base.id > 0 then
          valid_encounter_cards[#valid_encounter_cards+1] = v
      end
  end
  if valid_encounter_cards[1] then 
      local encounter_card = pseudorandom_element(valid_encounter_cards, pseudoseed('encountering'..G.GAME.round_resets.ante))
      G.GAME.current_round.encounter_card.rank = encounter_card.base.value
      G.GAME.current_round.encounter_card.id = encounter_card.base.id
      G.GAME.current_round.encounter_card.suit = encounter_card.base.suit
  end




  if(not G.KorcLoaded) then
  
    G.GAME.current_round.painter_asthetic1 =  'Spades'
    G.GAME.current_round.painter_asthetic2 = 'Hearts'
    local valid_painter_cards = {}
    for _, v in ipairs(G.playing_cards) do
      if not SMODS.has_no_suit(v) then -- Abstracted enhancement check for jokers being able to give cards additional enhancements
        valid_painter_cards[#valid_painter_cards+1] = v
      end
    end
    if valid_painter_cards[1] then 
        local painter_chosen_card = pseudorandom_element(valid_painter_cards, pseudoseed('kpainter'..G.GAME.round_resets.ante))
        G.GAME.current_round.painter_asthetic1 = painter_chosen_card.base.suit
    end
    valid_painter_cards = {}
    for _, v in ipairs(G.playing_cards) do
      if not SMODS.has_no_suit(v) and v.base.suit ~= G.GAME.current_round.painter_asthetic1  then 
          valid_painter_cards[#valid_painter_cards+1] = v
      end
    end
    if valid_painter_cards[1] then 
        local painter_chosen_card = pseudorandom_element(valid_painter_cards, pseudoseed('kpainter'..G.GAME.round_resets.ante))
        G.GAME.current_round.painter_asthetic2 = painter_chosen_card.base.suit
    end

  else

    G.GAME.current_round.painter_asthetic1 =  G.GAME.current_round.mark_asthetic1
    G.GAME.current_round.painter_asthetic2 = G.GAME.current_round.mark_asthetic2

  end


  -- resets all d20s

  for _, v in ipairs(SMODS.find_card("j_korczak_d20", true)) do

    if(v.ability.extra.was_triggered and  v.ability.extra.reset_to < v.ability.extra.numerator) then
    v.ability.extra.was_triggered = false
    v.ability.extra.numerator = v.ability.extra.reset_to
    card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize('k_reset'), colour = G.C.GREEN})

    end

  end

  if run_start or G.GAME.blind.boss then

  
  G.GAME.current_round.xmarks_card = {rank = 'Ace'}
  local valid_xmarks_cards = {}
  for k, v in ipairs(G.playing_cards) do
      if v.ability.effect ~= 'Stone Card' then
        if v.base.id > 0 then
          valid_xmarks_cards[#valid_xmarks_cards+1] = v
        end
      end
  end
  if valid_xmarks_cards[1] then 
      local xmarks_card = pseudorandom_element(valid_xmarks_cards, pseudoseed('secret_rankx'..G.GAME.round_resets.ante))
      G.GAME.current_round.xmarks_card.rank = xmarks_card.base.value
      G.GAME.current_round.xmarks_card.id = xmarks_card.base.id
    end

  end


  -- kozer challange

  if run_start and G.GAME.modifiers and G.GAME.modifiers.kozer_debuff_card then

  G.GAME.round_resets.blind_choices.Boss = get_new_boss()

  end

  if(not run_start and G.GAME.modifiers.kozer_debuff_card and G.GAME.blind.boss) then



    for _, v in ipairs(G.playing_cards) do 
      SMODS.debuff_card(v,  false, "kozer")
    end

  end

  if(not run_start and ( (G.GAME.modifiers and G.GAME.modifiers.kozer_destroy_joker) and (G.GAME.blind.boss))) then
  
  local destructable_jokers = {}
  for i = 1, #G.jokers.cards do
        -- if not G.jokers.cards[i].ability.eternal then 
        if G.jokers.cards[i].ability.unsellable then 
      
          G.jokers.cards[i]:start_dissolve({G.C.SUITS[G.GAME.current_round.duraksuit]}, nil, 0.5)
      end
      end
  end

  if(not run_start and ( (G.GAME.modifiers and G.GAME.modifiers.kozer_create_joker) and (G.GAME.blind.boss))) then



    
    

    
    local magic_jokers = {
      
      Diamonds = {"j_rough_gem"},
      Hearts = {"j_bloodstone"},
      Spades = {"j_arrowhead"},
      Clubs = {"j_onyx_agate"}
      
    }
    
    for i = 1, #magic_jokers[G.GAME.current_round.duraksuit] do
      
      
      G.E_MANAGER:add_event(Event({
        func = function()
              if G.jokers then
                G.GAME.banned_keys[magic_jokers[G.GAME.current_round.duraksuit][i]] = false
                local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, magic_jokers[G.GAME.current_round.duraksuit][i], 'deck')
                new_joker:add_to_deck()
                G.jokers:emplace(new_joker)
                new_joker:set_edition("e_negative", true)
    					  new_joker:start_materialize({G.C.SUITS[G.GAME.current_round.duraksuit]})
                
                new_joker.ability.unsellable = true
                G.GAME.banned_keys[magic_jokers[G.GAME.current_round.duraksuit][i]] = true
          
                
              end
              return true; end})) 

  end


end



    web_search_refresh(true)
    
    
    

end





  SMODS.Joker {
    key = 'durak',
    loc_txt = {
      name = 'Durak',
      text=
      {
        "Each played {V:1}#1#{} card",
        "gives {C:mult}+#2#{} Mult when scored",
        "{C:inactive}(suit changes every round)"
    },
    },
    config = { extra = 6 },
    rarity = 1,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 12, y = 2},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      return { vars= {
        
        localize(G.GAME.current_round.duraksuit, 'suits_singular'),
        card.ability.extra, 

        colours = {G.C.SUITS[G.GAME.current_round.duraksuit]} -- sets the colour of the text affected by `{V:1}`
       

      } }
    end,
    calculate = function(self, card, context)
  
      
  if context.individual and context.cardarea == G.play then
    if ((not context.other_card.debuff) and context.other_card:is_suit(G.GAME.current_round.duraksuit, true)) then
                return {
                    mult = card.ability.extra,
                    card = card
                }
    end
    end


    end
  }

  
  SMODS.Joker {
    key = 'chairman',
    loc_txt = {
      name = 'Supreme Chairman',
      text=
      {
        "Every scoring {C:attention}#1#{} gives {C:mult}+#2#{} Mult",
        "{C:inactive}(rank and Mult change every round)"
    },
    },
    config = { extra = {} },
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 17, y = 1},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      return { vars= {
        localize(G.GAME.current_round.chairman_card.rank, 'ranks'),
        G.GAME.current_round.chairman_mult
      } }
    end,
    calculate = function(self, card, context)
  
      
    if context.individual and context.cardarea == G.play then
      if ((not context.other_card.debuff) and context.other_card:get_id() == G.GAME.current_round.chairman_card.id) then
                  return {
                      mult = G.GAME.current_round.chairman_mult,
                      card = card
                  }
      end
    end

  end
  }
  

  SMODS.Joker {
    key = 'treasure_hunter',
    loc_txt = {
      name = 'Treasure Hunter',
      text=
      {
        "Earn an extra {C:money}$#1#{} per",
        "{C:attention}remaining hand and discard{}",
        "at the end of round"
    },
    },
    config = { extra = 1 },
    rarity = 1,
    atlas = "korczak",
    blueprint_compat = false,
    pos = {x = 17, y = 2},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      return { vars= {card.ability.extra} }
    end,
    calc_dollar_bonus = function(self, card)
      if(G.GAME.current_round.discards_left+G.GAME.current_round.hands_left>0) then

        return(card.ability.extra*(G.GAME.current_round.discards_left+G.GAME.current_round.hands_left))
      end
    end
  }
  

  SMODS.Joker {
    key = 'game_piece',
    loc_txt = {
      name = 'Game Piece',
      text=
      {
        "Gains {C:mult}+#1#{} Mult per {C:attention}remaining hand{}",
        "at the end of round",
        "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)"
    },
    },
    config = { extra = {mult_mod = 1}, mult = 0 },
    rarity = 2,
    atlas = "korczak",
    pixel_size =  { w = 37, h = 95 },
    blueprint_compat = true,
    pos = {x = 15, y = 4},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      return { vars= {card.ability.extra.mult_mod,card.ability.mult} }
    end,
    calculate = function(self, card, context)
      if context.end_of_round and not context.blueprint and not context.repetition and context.game_over == false then
        if(G.GAME.current_round.hands_left>0) then
          card.ability.mult = card.ability.mult + card.ability.extra.mult_mod * G.GAME.current_round.hands_left
          return {
            message = localize('k_upgrade_ex'),
            card = card,
            colour = G.C.MULT
        }
        end
      end
      if context.joker_main then

        if(card.ability.mult>0) then
        return {
          mult = card.ability.mult,
          card = card
      }
        end

      end
    end
    -- set_ability = function(self, card, initial, delay_sprites)
    --   local X, Y, W, H = card.T.x, card.T.y, card.T.w, card.T.h
    --   W = W/2
    --   card.T.w = W
    -- end,
    -- set_sprites = function(self, card, front)
    --     card.children.center.scale.x = card.children.center.scale.x/2
    -- end,
    -- load = function(self, card, card_table, other_card)
    --   local W = G.CARD_W
    --   card.T.w = W*scale/2*scale
    -- end
  }

  
  SMODS.Joker {
    key = 'grease_monkey',
    loc_txt = {
      name = 'Grease Monkey',
      text=
      {
        -- "{C:green}#1# in #2#{} chance to give",
        -- "the {C:attention}Joker to the right",
        -- "{C:dark_edition}Foil{}, {C:dark_edition}Holographic{}, or",
        -- "{C:dark_edition}Polychrome{} edition",
        -- "when {C:attention}Blind{} is selected",
        "{C:green}#1# in #2#{} chance to upgrade the {C:dark_edition}Edition{}",
        "of the {C:attention}Joker to the right",
        "when {C:attention}Blind{} is selected",
        "{C:inactive}(Doesn't work on Negative Jokers)"
    },
    },
    in_pool = function(self, args)
      return(G.GAME and G.GAME.current_round and G.GAME.current_round.lets_go_gambling)
    end,
    config = { extra = {chance = 3} },
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 12, y = 3},
    cost = 7,
    loc_vars = function(self, info_queue, card)
      return { vars= {G.GAME.probabilities.normal, (G.GAME.modifiers and G.GAME.modifiers.grease_probabilities) or (card.ability.extra.chance)} }
    end,
    -- calculate = function(self, card, context)
    --   if context.setting_blind then

        
    --     local other_joker = nil
    --     for i = 1, #G.jokers.cards do
    --       if G.jokers.cards[i] == (context.blueprint_card or card) then other_joker = G.jokers.cards[i+1] end
    --     end

    --     if(other_joker and not other_joker.edition) then

    --     if(pseudorandom('grease_prob') <= G.GAME.probabilities.normal/ ((G.GAME.modifiers and G.GAME.modifiers.grease_probabilities) or card.ability.extra.chance)) then

    --       edition = poll_edition('grease_edition', nil, true, true)
    --       if context.blueprint_card then
    --       context.blueprint_card:juice_up(0.3,0.3)
    --       else
    --         card:juice_up(0.3,0.3)
    --       end

    --       other_joker:set_edition(edition, true)

    --       return(
    --         {
    --           message = (G.P_CENTERS[edition].name .. "!"),
    --           colour = G.C.SECONDARY_SET.Tarot
    --         }
    --       )

    --     else

    --       return(
    --         {
    --           message = localize('k_nope_ex'),
    --           colour = G.C.SECONDARY_SET.Tarot
    --         }
    --       )


    --     end



    --   end

    --   end
    -- end
    calculate = function(self, card, context)
      if context.setting_blind then

        
        local other_joker = nil
        for i = 1, #G.jokers.cards do
          if G.jokers.cards[i] == (context.blueprint_card or card) then other_joker = G.jokers.cards[i+1] end
        end

        if(other_joker and not (other_joker.edition and other_joker.edition.negative)) then

        if(pseudorandom('grease_prob') <= G.GAME.probabilities.normal/ ((G.GAME.modifiers and G.GAME.modifiers.grease_probabilities) or card.ability.extra.chance)) then

          if context.blueprint_card then
          context.blueprint_card:juice_up(0.3,0.3)
          else
            card:juice_up(0.3,0.3)
          end

          local didit = false

          if other_joker.edition == nil then
            other_joker:set_edition("e_foil", true)
            didit = true
          elseif other_joker.edition.foil then
            other_joker:set_edition("e_holo", true)
            didit = true
          elseif(other_joker.edition.holo) then
            other_joker:set_edition("e_polychrome", true)
            didit = true
          end


          if(didit) then
          return(
            {
              message = (G.P_CENTERS["e_" .. other_joker.edition.type].name .. "!"),
              colour = G.C.SECONDARY_SET.Tarot
            }
          )
        end

        else

          return(
            {
              message = localize('k_nope_ex'),
              colour = G.C.SECONDARY_SET.Tarot
            }
          )


        end



      end

      end
    end
  }

  
  SMODS.Joker {
    key = 'mecha_joker',
    loc_txt = {
      name = 'Mecha Joker',
      text=
      {
        "Gains {C:white,X:mult}X#1#{} Mult when a",
        "{C:attention}Steel{} card in hand is triggered",
      "{C:inactive}(Currently {C:white,X:mult}X#2#{C:inactive} Mult){}"
    },
    },
    config = { extra = 0.1 , x_mult = 1 },
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    enhancement_gate = "m_steel",
    perishable_compat = false,
    pos = {x = 13, y = 3},
    cost = 7,
    loc_vars = function(self, info_queue, card)
      return { vars= {card.ability.extra,card.ability.x_mult} }
    end,
    calculate = function(self, card, context)
      if not context.blueprint_card and context.individual and context.cardarea == G.hand and not context.end_of_round then

        if context.other_card.config.center == G.P_CENTERS.m_steel then
          if context.other_card.debuff then
              return {
                  message = localize('k_debuffed'),
                  colour = G.C.RED,
                  card = card,
              }
          else
              card.ability.x_mult = card.ability.x_mult + card.ability.extra
              return {
                message = localize('k_upgrade_ex'),
                card = card,
                colour = G.C.MULT
              }
          end
        end
      end
    end
  }
  
  SMODS.Joker {
    key = 'compass',
    loc_txt = {
      name = 'Compass',
      text=
      {
        "Tells the {C:attention}top 3 cards{} in your {C:attention}current deck",
        "{s:0.8}unless in Blind selection screen",
        -- "{}({V:1}#1#{} [1])",
        -- "{}({V:2}#2#{} [2])",
        -- "{}({V:3}#3#{} [3])"
        "({V:1}#1#{}, {V:2}#2#{}, {V:3}#3#{})",
    },
    },
    rarity = 1,
    atlas = "korczak",
    blueprint_compat = false,
    pos = {x = 15, y = 1},
    cost = 5,
    loc_vars = function(self, info_queue, card)

      local vars = {}
      local colours = {}

      for i = 1, 3 do
        vars[i] = "None"
        colours[i] = G.C.UI.TEXT_INACTIVE
      end


      if(G.deck and G.deck.cards and #SMODS.find_card("j_korczak_compass")>0 and not (G.STATE == G.STATES.BLIND_SELECT)) then
        for i = 1, 3 do
          
          local l = #G.deck.cards - i + 1
          if(G.deck.cards[l]) then


            if(G.deck.cards[l].config.center == G.P_CENTERS.m_stone) then
            vars[i] =  'Stone Card'
            colours[i] = G.C.UI.TEXT_DARK
            else
            
            vars[i] = localize(G.deck.cards[l].base.value, 'ranks') .. " of " .. localize(G.deck.cards[l].config.card.suit, 'suits_plural')
            colours[i] = G.C.SUITS[G.deck.cards[l].config.card.suit]
            end


          end

        end
      end

      vars.colours = colours

      return {vars = vars}
    end
  }



  
  SMODS.Joker {
    key = 'alley_warrior',
    loc_txt = {
      name = 'Alley Warrior',
      text=
      {
        "Gains {X:red,C:white}X#1#{} Mult when {C:attention}Small Blind",
        "{C:attention}or Big Blind {}is defeated",
        "XMult is {C:attention}doubled{} when facing a {C:attention}Boss Blind",
        "{C:inactive}(Currently {X:red,C:white} X#2# {C:inactive} Mult)"
    },
    },
    config = { extra = {xmult_mod = 0.25 , x_mult = 1} },
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    in_pool = function(self, args)
      return(G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante>1)
    end,
    pos = {x = 13, y = 0},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      return { vars= {card.ability.extra.xmult_mod,card.ability.extra.x_mult * ((G and G.GAME and G.GAME.blind and G.GAME.blind.boss and 2) or 1)} }
    end,
    calculate = function(self, card, context)
  
      if context.joker_main then
        if(G.GAME.blind.boss) then

        return {
          message = localize{type='variable',key='a_xmult',vars={2*card.ability.extra.x_mult}},
          Xmult_mod = 2* card.ability.extra.x_mult,
          colour = G.C.MULT,
        }
      else
        if(card.ability.extra.x_mult > 1) then
        return {
          message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
          Xmult_mod = card.ability.extra.x_mult,
          colour = G.C.MULT,
        }
      end
      end
    end
      if not context.blueprint_card and context.end_of_round and not context.repetition and context.game_over == false and not G.GAME.blind.boss then
        card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.xmult_mod
        return {
          message = localize('k_upgrade_ex'),
          card = card,
          colour = G.C.MULT
      }
      end
    end
  }

  
  SMODS.Joker {
    key = 'capricorn',
    loc_txt = {
      name = 'Capricorn',
      text=
      {
        "{C:green}#1# in #2#{} chance {C:planet}Planet{} card upgrades",
        "{C:attention}poker hand{} an additional time"
    },
    },
    config = { extra = {chance = 2} },
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 12, y = 1},
    cost = 7,
    loc_vars = function(self, info_queue, card)
      return { vars= {G.GAME.probabilities.normal, card.ability.extra.chance} }
    end,
    calculate = function(self, card, context)
      if context.using_consumeable and context.consumeable.ability.set == 'Planet' and context.consumeable.ability.consumeable.hand_type then

          if (pseudorandom('capricon') <= G.GAME.probabilities.normal/card.ability.extra.chance) then
          update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(context.consumeable.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].chips, mult = G.GAME.hands[context.consumeable.ability.consumeable.hand_type].mult, level=G.GAME.hands[context.consumeable.ability.consumeable.hand_type].level})
          level_up_hand(context.blueprint_card or card, context.consumeable.ability.consumeable.hand_type)
          update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})

              return({
                card = context.blueprint_card or card,
                message = localize('k_upgrade_ex'),
                colour = G.C.SECONDARY_SET.Planet
              })
          end
      end
    end
  }

  
  
  SMODS.Joker {
    key = 'comic_book',
    loc_txt = {
      name = 'Comic Book',
      text=
      {
        "Earn {C:money}$#1#{} when scoring a {C:attention}#2#{}",
        "Rank goes up when triggered"
      },
    },
    config = { extra = { rank_id = 2, money = 2} },
    rarity = 1,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 14, y = 1},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      local unique = 
      {
        [11] = "Jack",
        [12] = "Queen",
        [13] = "King",
        [14] = "Ace"
      }
      return { vars= {card.ability.extra.money,unique[card.ability.extra.rank_id] or card.ability.extra.rank_id} }
    end,
    calculate = function(self, card, context)

      if context.before or context.joker_main then
        card.ability.last_triggered = nil
        card.ability.retriggered = false
        card.ability.triggered_card = nil
      end

      if context.individual and context.cardarea == G.play then

        -- reset retrigger check when moving to the next card
        if card.ability.retriggered and (card.ability.last_triggered ~= context.other_card) then

          card.ability.retriggered = false
          card.ability.triggered_card = nil

        end

        -- check if card was retriggered
        if(card.ability.triggered_card == (context.blueprint_card or card) and (card.ability.last_triggered == context.other_card)) then
          card.ability.retriggered = true
        end
          
        -- ability
        if (not card.ability.retriggered) and (((not context.other_card.debuff) and context.other_card:get_id() == card.ability.extra.rank_id) or (card.ability.last_triggered == context.other_card)) then
                 
          if(card.ability.last_triggered ~= context.other_card) then
           
            card.ability.last_triggered = context.other_card
            card.ability.triggered_card = context.blueprint_card or card

            card.ability.extra.rank_id = card.ability.extra.rank_id + 1
            if(card.ability.extra.rank_id > 14) then
              card.ability.extra.rank_id = 2
            end


          end



                    return {
                        dollars = card.ability.extra.money,
                        colour = G.C.MONEY
                    }
        end
        end
    end
  }



  SMODS.Joker {
    key = 'calculus',
    loc_txt = {
      name = 'Calculus',
      text=
      {
        "Adds the {C:attention}sum{} of all scoring",
        "{C:attention}numbered cards' ranks{} to Mult"
    },
    },
    config = { extra = {result = 0}, mult = 0 },
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 16, y = 0},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      return { vars= {} }
    end,
    calculate = function(self, card, context)
  
      if context.before and not context.blueprint_card then

        card.ability.mult = 0

      end


      if context.individual and context.cardarea == G.play and not context.blueprint_card then

        if context.other_card.ability.effect ~= 'Stone Card' and not context.other_card.debuff then
          card.ability.mult = card.ability.mult + (localize(context.other_card.base.value, 'ranks') and tonumber(localize(context.other_card.base.value, 'ranks')) or 0)
        end
      end

      if context.joker_main and card.ability.mult > 0 then

        return({
          mult = card.ability.mult
        })

      end

    end
  }

  
  SMODS.Joker {
    key = 'pepperoni',
    loc_txt = {
      name = 'Pepperoni Pizza',
      text=
      {
        "{C:white,X:mult}X#2#{} Mult",
        "loses {C:white,X:mult}X#1#{} Mult",
        "per round played"
    },
    },
    config = { extra = 0.25 , x_mult = 3 },
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    eternal_compat = false,
    pos = {x = 16, y = 3},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      return { vars= {card.ability.extra,card.ability.x_mult} }
    end,
    calculate = function(self, card, context)
      if context.end_of_round and not context.blueprint and not context.repetition and context.game_over == false then
                if card.ability.x_mult - card.ability.extra <= 1 then 
                  G.E_MANAGER:add_event(Event({
                      func = function()
                          play_sound('tarot1')
                          card.T.r = -0.2
                          card:juice_up(0.3, 0.4)
                          card.states.drag.is = true
                          card.children.center.pinch.x = true
                          G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                              func = function()
                                      G.jokers:remove_card(card)
                                      card:remove()
                                      card = nil
                                  return true; end})) 
                          return true
                      end
                  })) 
                  return {
                      message = localize('k_eaten_ex'),
                      colour = G.C.FILTER
                  }
              else
                card.ability.x_mult = card.ability.x_mult - card.ability.extra
                return {
                  message = localize{type='variable',key='a_xmult_minus',vars={card.ability.extra}},
                  colour = G.C.MULT
                }
          end
      end
    end
  }

  
  
  SMODS.Joker {
    key = 'graffiti',
    loc_txt = {
      name = 'Graffiti',
      text=
      {
        "Adds a copy of a {C:attention}random",
        "{C:attention}affected card{} to your {C:attention}deck",
        "when using a {C:attention}Suit converting{} {C:tarot}Tarot{} card"
        -- "Once per round, adds a copy of the {C:attention}last chosen card",
        -- "you used a {C:tarot}suit converting card",
        -- "on to your {C:attention}deck{} at {C:attention}the end of the shop",
        -- "{C:inactive}(Currently {V:1}#1#{C:inactive}){}"
    },
    },
    config = { extra = {} },
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 16, y = 2},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      return { vars= {
        
      --   G.GAME.current_round.graffiti_drip and(
      --   G.GAME.current_round.graffiti_drip.ability.effect == 'Stone Card' and 'Stone Card'
        
      --   or localize(G.P_CARDS[G.GAME.current_round.graffiti_drip.save_fields.card].value, 'ranks') .. " of " .. localize(G.P_CARDS[G.GAME.current_round.graffiti_drip.save_fields.card].suit, 'suits_plural')
            
      -- )
      --   or "None",
      --   colours = {
      --     G.GAME.current_round.graffiti_drip and(
      --     G.GAME.current_round.graffiti_drip.ability.effect == 'Stone Card' and G.C.UI.TEXT_DARK
      --     or G.C.SUITS[G.P_CARDS[G.GAME.current_round.graffiti_drip.save_fields.card].suit]
      --   )
      --     or G.C.UI.TEXT_INACTIVE
      --   }      
      }
    }
    end,
    calculate = function(self, card, context)
  

      if (context.using_consumeable and context.consumeable.ability.consumeable.suit_conv) then

        -- local last_card = G.hand.highlighted[#G.hand.highlighted]

        local affected_cards = {}


        for k, v in pairs(G.hand.highlighted) do
          if v.base.suit ~= context.consumeable.ability.consumeable.suit_conv and v.config.center ~= G.P_CENTERS.m_stone then
            affected_cards[#affected_cards+1] = v
          end
        end

        if (affected_cards[1]) then

        local random_card = pseudorandom_element(affected_cards, pseudoseed('graffiti_cad'))

        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,
        func = function()
          -- G.GAME.current_round.graffiti_drip = last_card:save()

                      
            local _card = copy_card(random_card, nil, nil, G.playing_card)
            _card:add_to_deck()
            G.deck.config.card_limit = G.deck.config.card_limit + 1
            table.insert(G.playing_cards, _card)
            G.deck:emplace(_card)
            
            
            
            return true; end})) 
            
            return {
              message = localize('k_copied_ex'),
              colour = (
                G.C.SUITS[context.consumeable.ability.consumeable.suit_conv]
              ),
              card = random_card,
              playing_cards_created = {true}
            }
          end
      end

      
      -- if context.ending_shop then
      --   if G.GAME.current_round.graffiti_drip then
      --   G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        
      --   local temp_card = Card((context.blueprint_card or card).T.x, (context.blueprint_card or card).T.y, G.CARD_W, G.CARD_H, G.P_CENTERS.j_joker, G.P_CENTERS.c_base)
      --   temp_card:load(G.GAME.current_round.graffiti_drip)
        
        
      --   local _card = copy_card(temp_card, nil, nil, G.playing_card)
      --   _card:add_to_deck()
      --   G.deck.config.card_limit = G.deck.config.card_limit + 1
      --   table.insert(G.playing_cards, _card)
      --   G.deck:emplace(_card)
        
      --   temp_card:remove()
      --   temp_card = nil
        
      --   G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
      --     G.GAME.current_round.graffiti_drip = nil
      --     return true end }))
        
      --   return {
      --     message = localize('k_copied_ex'),
      --     colour = (
      --       G.GAME.current_round.graffiti_drip and(
      --       G.GAME.current_round.graffiti_drip.ability.effect == 'Stone Card' and G.C.UI.TEXT_DARK
      --       or G.C.SUITS[G.P_CARDS[G.GAME.current_round.graffiti_drip.save_fields.card].suit]
      --       )
      --       or G.C.UI.TEXT_INACTIVE
      --     ),
      --     card = context.blueprint_card or card,
      --     playing_cards_created = {true}
      --   }
      -- end
      -- end
      end
  }

  web_search_refresh = function(new_blind)

    local banned_hands = ({
      ["Flush Five"] = true,
      ["Flush House"] = true,
      ["Five of a Kind"] = true,
      ["Straight Flush"] = true,
      ["Four of a Kind"] = true,
    } )

    local _poker_hands = {}
    for k, v in pairs(G.GAME.hands) do
      
      if v.played > 0 or not (banned_hands[k] or not v.visible) then
      
        if G.GAME.modifiers.incognito then
        
          if(new_blind) then
            _poker_hands[#_poker_hands+1] = k
          else
            if(not(
              -- G.GAME.blind.hands[k]
              G.GAME.blind.hands[k]
            )) then
              _poker_hands[#_poker_hands+1] = k
            end
          end
        else
          _poker_hands[#_poker_hands+1] = k
        end

      end

    end
    local old_hand = G.GAME.current_round.web_search_hand
    G.GAME.current_round.web_search_hand = nil

    if(#_poker_hands > 1) then
    while not G.GAME.current_round.web_search_hand do
        G.GAME.current_round.web_search_hand = pseudorandom_element(_poker_hands, pseudoseed('web_search'))
        if G.GAME.current_round.web_search_hand == old_hand then G.GAME.current_round.web_search_hand = nil end
    end
  else
    G.GAME.current_round.web_search_hand = _poker_hands[1] or old_hand
  end

  end


  SMODS.Joker {
    key = 'web_search',
    loc_txt = {
      name = 'Web Search',
      text=
      {
        "Gains {C:white,X:mult}X#1#{} Mult when playing",
        "{C:attention}a #2#{} this round",
        "{s:0.8}Poker hand changes every round or when triggered",
        "{C:inactive}(Currently {C:white,X:mult}X#3#{}{C:inactive} Mult)"
    },
    },
    config = { extra = {step = 1}, xmult = 1 },
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 17, y = 3},
    cost = 7,
    loc_vars = function(self, info_queue, card)
      return { vars= {
        card.ability.extra.step,
        localize(G.GAME.current_round.web_search_hand,'poker_hands'),
        card.ability.xmult} }
    end,
    calculate = function(self, card, context)
      if context.end_of_round and not context.blueprint_card and not context.repetition and context.game_over == false then
        card.ability.xmult = 1
        return {
            message = localize('k_reset'),
            colour = G.C.RED
        }
      end
      if context.before and context.scoring_name == G.GAME.current_round.web_search_hand and not context.blueprint then

        card.ability.xmult = card.ability.xmult + card.ability.extra.step
        return {
          message = localize('k_upgrade_ex'),
          card = card,
          colour = G.C.MULT
      }
    end
      if context.joker_main and card.ability.xmult > 1 then
        if context.scoring_name == G.GAME.current_round.web_search_hand and not context.blueprint then
          web_search_refresh(false)
        end
        return {
          message = localize{type='variable',key='a_xmult',vars={card.ability.xmult}},
          Xmult_mod = card.ability.xmult,
          colour = G.C.MULT,
          
        }
      end
    end
  }

  
  SMODS.Joker {
    key = 'encounter',
    loc_txt = {
      name = 'Encounter of the Joking Kind',
      text=
      {
        "If {C:attention}discarded hand{} contains {C:attention}only #3# {}of {V:1}#4#{}",
        "destroys it and gains {C:white,X:mult}X#1#{} Mult for each",
        "{s:0.8}Card changes every round",
        "{C:inactive}(Currently {C:white,X:mult}X#2#{C:inactive} Mult)"
    },
    },
    config = { extra = {x_mult_mod = 0.2}, x_mult = 1 },
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    perishable_compat = false,
    pos = {x = 13, y = 2},
    cost = 7,
    loc_vars = function(self, info_queue, card)
      return { vars= {
        card.ability.extra.x_mult_mod,
        card.ability.x_mult,
        localize(G.GAME.current_round.encounter_card.rank, 'ranks'),
        localize(G.GAME.current_round.encounter_card.suit, 'suits_plural'),
      colours = {G.C.SUITS[G.GAME.current_round.encounter_card.suit]}
    } }
    end,
    calculate = function(self, card, context)

      
      if (context.discard or context.pre_discard) and not context.blueprint_card then
      
      
      local abduct = true

      for k, v in pairs(context.full_hand) do

        if(v:is_suit(G.GAME.current_round.encounter_card.suit, true)) and v:get_id() == G.GAME.current_round.encounter_card.id then



        else
          abduct = false
        end

      end
      if abduct then
      
        if context.pre_discard then
          return({
            message = localize('k_upgrade_ex'),
            colour = G.C.MULT
          })
        elseif context.discard then
        card.ability.x_mult = card.ability.x_mult + card.ability.extra.x_mult_mod
        return {
          card = card,
          delay = 0.45, 
          remove = true,
      }
      end
      end
      
    end

    end
  }


  SMODS.current_mod.optional_features = { post_trigger = true, retrigger_joker = true }
  
  SMODS.Joker {
    key = 'buffer',
    loc_txt = {
      name = 'Buffer',
      text=
      {
        "{C:green}#1# in #2#{} chance to copy the ability",
        "of any other triggered {C:attention}Joker"
    },
    unlock={
      "Have at least {E:1,C:attention}#1#",
      "{C:dark_edition}Negative{} Jokers",
    }
    },
    config = { extra = {chance = 3} },
    rarity = 3,
    atlas = "korczak",
    blueprint_compat = true,
    unlock_condition = {type = 'modify_jokers', extra = {count = 2}},
    unlocked = false,
    discovered = false,
    pos = {x = 0, y = 3},
    cost = 10,
    loc_vars = function(self, info_queue, card)
      return { vars= {G.GAME.probabilities.normal, card.ability.extra.chance} }
    end,
    locked_loc_vars = function(self, info_queue, card)
      return {vars = {self.unlock_condition.extra.count}}
    end,
    calculate = function(self, card, context)

        -- if(context.retrigger_joker_check and (not context.other_context.retrigger_joker_check)) then
        --   if (pseudorandom('korc_buffer!') <= G.GAME.probabilities.normal/card.ability.extra.chance) then
            
        --     return({
        --       repetitions = 1,
        --       message = "Again!"
        --     })
        --   end
        -- end

        if (context.post_trigger or context.post_trigger_repetition) and context.cardarea == G.jokers and (context.other_card.ability.name ~= "j_korczak_buffer") then
          
          if (pseudorandom('korc_buffer!') <= G.GAME.probabilities.normal/card.ability.extra.chance) then 
          context.other_context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
          context.other_context.blueprint_card = context.blueprint_card or card
          context.other_context.no_callback = true
          if context.other_context.blueprint > #G.jokers.cards + 1 then return end
          local other_joker_ret = (context.other_card):calculate_joker(context.other_context)
          if other_joker_ret then
            
            other_joker_ret.other_card = context.blueprint_card or card
            return other_joker_ret
          end
        end
      end
    end,
    check_for_unlock = function(self, args)
      if args.type == 'modify_jokers' and G.jokers then
        if self.unlock_condition.extra.count then
            local count = 0
            for _, v in pairs(G.jokers.cards) do
                if v.ability.set == 'Joker' and v.edition and v.edition.negative then count = count + 1 end
            end
            if count >= self.unlock_condition.extra.count then
                ret = true
                unlock_card(self)
            end
        end
    end
    end
  }


  
local updateRef = Game.update
buffer_animation_dt = 0
function Game:update(dt2)
    updateRef(self, dt2)
    buffer_animation_dt = buffer_animation_dt + dt2
    if G.P_CENTERS and G.P_CENTERS.j_korczak_buffer and buffer_animation_dt > 0.1 then
      buffer_animation_dt = 0
        local obj = G.P_CENTERS.j_korczak_buffer
            obj.pos.x = math.fmod(obj.pos.x+pseudorandom('buffr_', 1, 3),3)
    end
end

  
  
  SMODS.Joker {
    key = 'animation',
    loc_txt = {
      name = 'Animation',
      text=
      {
        "Retrigger the {C:attention}next card{} in",
        "scoring hand for every {C:money}$#1#",
        "{s:0.8}(from left to right, cycles when",
        "{s:0.8}retriggered all scoring cards)",
        "{s:0.8}(max of #2# retriggers per card)"
    },
    unlock = {
      "Retrigger a scoring card",
      "at least {E:1,C:attention}3{} consecutive times"
    }
    },
    config = { every_step = 20, max_retrigger = 5 },
    rarity = 3,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 0, y = 0},
    unlock_condition = {extra = {count = 3}},
    locked_loc_vars = function(self, info_queue, card)
      return {vars = {self.unlock_condition.extra.count}}
    end,
    unlocked = false,
    discovered = false,
    cost = 10,
    loc_vars = function(self, info_queue, card)
      return { vars= {card.ability.every_step, card.ability.max_retrigger} }
    end,
    calculate = function(self, card, context)
  
      
      if context.repetition then
        if context.cardarea == G.play then
          local frames = math.floor(G.GAME.dollars/card.ability.every_step)
          local my_frames = 0
          while(frames > 0) do
            for i = 1, #context.scoring_hand do
              if(frames > 0) then
              if context.other_card == context.scoring_hand[i] then my_frames = my_frames + 1 end
              end
              if not context.scoring_hand[i].debuff then
              frames = frames - 1
              end
            end
          end
              return {
                  message = localize('k_again_ex'),
                  repetitions = math.min(my_frames,card.ability.max_retrigger),
                  card = card
              }
          end
        end
    end,
    check_for_unlock = function(self, args)
      if args.type == 'repetitions_check' and args.amount > self.unlock_condition.extra.count then
                unlock_card(self)
      end
    end
  }

  
local updateRef = Game.update
animation_dt = 0
function Game:update(dt)
    updateRef(self, dt)
    animation_dt = animation_dt + dt
    if G.P_CENTERS and G.P_CENTERS.j_korczak_animation and animation_dt > 0.1 then
      animation_dt = 0
        local obj = G.P_CENTERS.j_korczak_animation
        if obj.pos.x == 3 then
            obj.pos.x = 0
            if obj.pos.y == 2 then
              obj.pos.y = 0
            elseif obj.pos.y < 2 then
                obj.pos.y = obj.pos.y + 1
            end
        elseif obj.pos.x < 3 then
            obj.pos.x = obj.pos.x + 1
        end
    end
end


G.localization.descriptions.Tarot.c_hermit.text[1] = "#2#"
  
  SMODS.Joker {
    key = 'exhibit',
    loc_txt = {
      name = 'Exhibit',
      text=
      {
        "Earn {C:money}double the money{} from",
        "{C:tarot}The Hermit{}, {C:tarot}Temperance{} and{C:spectral} Immolate{}"
      },
      unlock = {
        "Earn {E:1,C:money}$#1#{} from",
        "{C:tarot,E:1}Temperance",
        "in a single use"
      }
  },
  locked_loc_vars = function(self, info_queue, card)
    return {vars = {self.unlock_condition.extra}}
  end,

  in_pool = function(self, args)
    return(G.GAME and G.GAME.current_round and G.GAME.current_round.tarot_money)
  end,

  unlocked = false,
  discovered = false,
  unlock_condition = {extra = 50},
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = false,
    pos = {x = 14, y = 2},
    cost = 8,
    check_for_unlock = function(self, args)
      if args.type == 'tempererance' and args.amount >= self.unlock_condition.extra then
                unlock_card(self)
      end
    end
  }

  
  SMODS.Joker {
    key = 'x_marks_the_joke',
    loc_txt = {
      name = 'X Marks the Joke',
      text=
      {
        -- "Gains {C:white,X:mult}X#1#{} Mult when",
        -- "playing most played {C:attention}poker hand",
        -- "Loses {C:white,X:mult}X#2#{} Mult when",
        -- "not playing most played {C:attention}poker hand",
        -- "{C:inactive}(Currently {C:white,X:mult}X#3#{C:inactive} Mult)"

        "Earn {C:money}$#1#{} for each {C:attention}secret rank{}",
        "contained in scored hand",
        "earnings increase by {C:money}$#2#{} for each",
        "additional {C:attention}secret rank{} in hand",
        "{C:inactive}(secret rank changes every Ante)"
    },
    unlock = {
      "Discard {C:attention,E:1}#1# Gold cards",
      "in a single discard"
    }
    },
    
    -- config = { extra = {step_up = 0.2, step_down = 0.2}, x_mult = 1 },
    config = { extra = {earn_raise = 1, earn = 2}},
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    perishable_compat = false,
    unlocked = false,
    discovered = false,
    pos = {x = 12, y = 4},
    unlock_condition = {extra = 4},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      -- return { vars= {card.ability.extra.step_up,card.ability.extra.step_down,card.ability.x_mult} }
      return { vars= {card.ability.extra.earn,card.ability.extra.earn_raise} }
    end,
    locked_loc_vars = function(self, info_queue, card)
      return { vars= {self.unlock_condition.extra} }
    end,
    calculate = function(self, card, context)
      if context.before then

        local bonus = 0
        local gain = card.ability.extra.earn
        
        for i = 1, #context.scoring_hand do
          if context.scoring_hand[i]:get_id() == G.GAME.current_round.xmarks_card.id and (not context.other_card.debuff) then
            bonus = bonus + gain
            gain = gain + card.ability.extra.earn_raise
          end
      end

      if(bonus > 0) then
        return({
          dollars = bonus,
          card = context.blueprint_card or card,
          colour = G.C.MONEY
        })
      end

      end
      -- if context.before and not context.blueprint_card then


      --   local upgrading = true
      --   local play_more_than = (G.GAME.hands[context.scoring_name].played or 0)
      --   for k, v in pairs(G.GAME.hands) do
      --       if k ~= context.scoring_name and v.played >= play_more_than and v.visible then
      --           upgrading = false
      --       end
      --   end
      --   if upgrading then

      --     card.ability.x_mult = card.ability.x_mult + card.ability.extra.step_up
      --     return {
      --         card = card,
      --         colour = G.C.RED,
      --         message = localize{type='variable',key='a_xmult',vars={card.ability.extra.step_up}}
      --     }

      --   else
            
      --     local prev_mult = card.ability.x_mult
      --     card.ability.x_mult = math.max(1, card.ability.x_mult - card.ability.extra.step_down)
      --     if card.ability.x_mult ~= prev_mult then 
      --         return {
      --             card = card,
      --             message = localize{type='variable',key='a_xmult_minus',vars={card.ability.extra.step_down}},
      --             colour = G.C.RED
      --         }
      --     end

      --   end

      -- end
      
    end,
    check_for_unlock = function(self, args)
      if args.type == 'discard_custom' then
            local tally = 0
            for j = 1, #args.cards do
                if args.cards[j].ability.effect == 'Gold Card' then
                    tally = tally+1
                end
            end
            if tally >= self.unlock_condition.extra then 
                ret = true
                unlock_card(self)
            end
      end
    end
  }

  
  SMODS.Joker {
    key = 'paladin',
    loc_txt = {
      name = 'Paladin',
      text=
      {
        "{C:attention}+#1#{} consumable slot#2#",
        "gains {C:attention}#3#{} slot#4# when {C:attention}Boss Blind{} is defeated",
        "When Blind is selected, creates a {C:attention}random",
        "{C:attention}consumable{} for every {C:attention}#5#{} empty slots it provides"
    },
    unlock = {
      "Own a {C:tarot,E:1}Tarot{}, a {C:planet,E:1}Planet{}",
      "and a {C:spectral,E:1}Spectral{}",
      "card at the same time",
    }
  },
    unlocked = false,
    discovered = false,
    config = { extra = {slots = 0, step = 1, item_every_slot = 2, tarot_rate = 47.5, planet_rate = 47.5, spectral_rate = 5} },
    rarity = 3,
    atlas = "korczak",
    blueprint_compat = false,
    perishable_compat = false,
    pos = {x = 15, y = 3},
    cost = 8,
    loc_vars = function(self, info_queue, card)
      return { vars= {card.ability.extra.slots, (card.ability.extra.slots ~= 1) and "s" or "", card.ability.extra.step, (card.ability.extra.step ~= 1) and "s" or "", card.ability.extra.item_every_slot} }
    end,
    calculate = function(self, card, context)

      if context.setting_blind and not context.blueprint_card then

        

        for i = 1, (card.ability.extra.slots/card.ability.extra.item_every_slot) do
          
                        local total_rate = card.ability.extra.tarot_rate +card.ability.extra.planet_rate +card.ability.extra.spectral_rate
                        local polled_rate = pseudorandom(pseudoseed('peledin'..G.GAME.round_resets.ante))*total_rate
                        local check_rate = 0
                        local consumable_Types = ({
                          {type = 'Tarot', val = card.ability.extra.tarot_rate},
                          {type = 'Planet', val = card.ability.extra.planet_rate},
                          {type = 'Spectral', val = card.ability.extra.spectral_rate}
                        })
                        for iii = 1, #consumable_Types do
                          if polled_rate > check_rate and polled_rate <= check_rate + consumable_Types[iii].val then
                            card:juice_up(0.3,0.3)
                            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
            if G.consumeables.config.card_limit > #G.consumeables.cards then
              
          if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                              
          G.E_MANAGER:add_event(Event({
            func = function()

              
              
                  
                  
                  
                  local consumable = create_card(consumable_Types[iii].type, G.consumeables, nil, nil, nil, nil, nil, 'peledin')
                  consumable:add_to_deck()
                  G.consumeables:emplace(consumable)
                  -- consumable:start_materialize({G.C.SECONDARY_SET[consumable_Types[iii].type]})
                  G.GAME.consumeable_buffer = 0
                  return true
                end
              }))
              end
          end
          return true end }))
        end
        
        check_rate = check_rate + consumable_Types[iii].val
      end
      end
          return
        end

      if context.end_of_round and G.GAME.blind.boss and not context.blueprint and not context.repetition and context.game_over == false then


        G.E_MANAGER:add_event(Event({func = function()
          card.ability.extra.slots = card.ability.extra.slots + card.ability.extra.step
          G.consumeables.config.card_limit = G.consumeables.config.card_limit + card.ability.extra.step
          card_eval_status_text(card, 'extra', nil, nil, nil, {message = "+" .. card.ability.extra.step .. " Slot" .. ((card.ability.extra.step ~= 1) and "s" or "")})
          return true end }))
          
      end
    end,
    add_to_deck = function(self, card, from_debuff)
      G.E_MANAGER:add_event(Event({func = function()
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + card.ability.extra.slots
      return true end }))
    end,
    -- Inverse of above function.
    remove_from_deck = function(self, card, from_debuff)
      G.E_MANAGER:add_event(Event({func = function()
        G.consumeables.config.card_limit = G.consumeables.config.card_limit - card.ability.extra.slots
      return true end }))
    end,
    check_for_unlock = function(self, args)
      if args.type == 'add_consumable' then
        local found_planet = false
        local found_tarot = false
        local found_spectral = false
        
        for k, v in pairs(G.consumeables.cards) do
          if(v.ability.set == "Planet") then found_planet = true end
            if(v.ability.set == "Spectral") then found_spectral = true end
              if(v.ability.set == "Tarot") then found_tarot = true end
        end

        if(found_planet and found_spectral and found_tarot) then
          unlock_card(self)
        end
      end
  end
  }

  G.shop_keep_ucommon_and_rares_promotion_rate = 2.5
  
  SMODS.Joker {
    key = 'shopkeep',
    loc_txt = {
      name = 'Shopkeep',
      text=
      {
        "Every {C:attention}#1#th{V:1} Uncommon{C:attention} or{V:2} Rare{C:attention} Joker",
        "appearing in {C:attention}the shop{} is {C:attention}free",
        "{s:0.8}Uncommon and Rare Jokers are",
        "{s:0.8}more likely to appear in shop"
    },
    unlock = {
      "Buy and immideately sell",
      "{C:attention,E:1}#1# Jokers{} in the shop in a row"
    }
    },
    config = { extra = {every = 4, current = 0, reset_every_shop = false} },
    rarity = 3,
    atlas = "korczak",
    blueprint_compat = false,
    unlocked = false,
    discovered = false,
    unlock_condition = {extra = 3},
    pos = {x = 17, y = 0},
    cost = 7,
    loc_vars = function(self, info_queue, card)
      return { vars= {card.ability.extra.every,colours={G.C.RARITY[2],G.C.RARITY[3]}} }
    end,
    locked_loc_vars = function(self, info_queue, card)
      return { vars= {self.unlock_condition.extra} }
    end,
    calculate = function(self, card, context)
      if context.setting_shop and card.ability.extra.reset_every_shop then
        card.ability.extra.current = 0
      end
      if (context.reroll_shop or context.setting_shop) and not context.blueprint_card then
        for k, v in pairs(G.shop_jokers.cards) do
        if v.ability.set == "Joker" and (v.config.center.rarity == 3 or v.config.center.rarity == 2) then
          card.ability.extra.current = card.ability.extra.current + 1
          if(card.ability.extra.current >= card.ability.extra.every and not (v.ability.couponed)) then
              card.ability.extra.current = 0
              v:juice_up(0.3,0.3)
              card_eval_status_text(card, 'extra', nil, nil, nil,
              {
                message = 'Free!',
                card = card,
                colour = G.C.RARITY[v.config.center.rarity]
              })
              v.ability.couponed = true
              v.ability.ceo_approved = true
              v:set_cost()
          end
        end
        end        
      end
    end,
    check_for_unlock = function(self, args)
      if args.type == 'bought_then_sold_jokers' and G.GAME.current_round.jokers_bought_then_sold >= self.unlock_condition.extra  then
        unlock_card(self)
      end
  end
  }

  
  SMODS.Joker {
    key = 'ace_up_your_sleeve',
    loc_txt = {
      name = 'Ace up your Sleeve',
      text=
      {
        -- "Adds a random {C:attention}Ace{}",
        -- "with a random {C:attention}Enhancement{}",
        -- "{C:attention}or Edition{} to your {C:attention}deck{}",
        -- "when {C:attention}Blind{} is selected"

        -- "Adds a random {C:attention}Ace{}",
        -- "with a random {C:attention}Enhancement{}",
        -- "{C:attention}or Edition{} to your {C:attention}hand{}",
        -- "for every #2#th {C:attention}#3#{} you play",
        -- "(rank changes when triggered)",
        -- "{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2#)"

        -- "{C:green}#1# in #2#{} chance to add a random {C:attention}Ace{}",
        -- "with an {C:attention}Enhancement{} or {C:dark_edition}Edition{}",
        -- "to your deck when opening a {C:attention}Standard Pack"

        "Adds a random {C:attention}Ace{}",
        "with an {C:attention}Enhancement{} or {C:dark_edition}Edition{}",
        "to your deck when choosing",
        "a card from a {C:attention}Standard Pack"
    },
    unlock = {
    "Defeat the Ante #3# Boss Blind with",
    "a {C:attention,E:1}#1#{} of {C:attention,E:1}#2#s{}"
  }
  },
  unlock_condition = {extra = {hand = "Five of a Kind", rank = "Ace", ante = 8}},
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
    if args.type == 'hand' and args.handname == self.unlock_condition.extra.hand then
      G.GAME.ace_up_your_sleeve_flag = true
        for _, card in pairs(args.scoring_hand) do
            if card.base.value ~= self.unlock_condition.extra.rank then
                G.GAME.ace_up_your_sleeve_flag = false
            end
        end
    end
    if args.type == 'round_win' and G.GAME.ace_up_your_sleeve_flag and G.GAME.blind.boss and G.GAME.round_resets.ante == self.unlock_condition.extra.ante then
      unlock_card(self)
    end
  end,
  locked_loc_vars = function(self, info_queue, card)
  return { vars = {self.unlock_condition.extra.hand, self.unlock_condition.extra.rank, self.unlock_condition.extra.ante}}
  end,
    config = { extra = {edition_chance = 0.3, no_negative = true, chance = 2}, other_rank_count = 0, other_rank_need = 4},
    rarity = 3,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 12, y = 0},
    cost = 8,
    loc_vars = function(self, info_queue, card)
      -- return { vars= {math.min( card.ability.other_rank_count,card.ability.other_rank_need), card.ability.other_rank_need, G.GAME.current_round.auys_card.rank} }
      return { vars= {
        -- G.GAME.probabilities.normal, card.ability.extra.chance
      } }
    end,
    calculate = function(self, card, context)
  
      if
      context.booster_card_added
        -- and (pseudorandom('ace_up_yo_ASS') <= G.GAME.probabilities.normal/card.ability.extra.chance)
        and not (context.blueprint_card or card).getting_sliced  then

        local valid_aces = {}
        local cen_pool = {}
        
        for k, v in pairs(G.P_CARDS) do
          if v.value == "Ace" then
            valid_aces[#valid_aces+1] = v
          end
        end
        
        for k, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
          if v.key ~= 'm_stone' then 
              cen_pool[#cen_pool+1] = v
          end
        end

        local is_edition = pseudorandom('korc_buffer!') < card.ability.extra.edition_chance

        local front = pseudorandom_element(valid_aces, pseudoseed('ace_suit'))
        local enhancement = G.P_CENTERS.c_base
        local edition = 'e_base'

        if(is_edition) then
          edition = poll_edition('ace_edition', nil, card.ability.extra.no_negative, true)
        else
          enhancement = pseudorandom_element(cen_pool, pseudoseed('ace_enhancement'))
        end

        G.E_MANAGER:add_event(Event({
            func = function() 
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local new_ace = Card(G.play.T.x + G.play.T.w/2, G.play.T.y, G.CARD_W, G.CARD_H, front, enhancement, {playing_card = G.playing_card})
                
                new_ace:start_materialize({G.C.SECONDARY_SET.Enhanced})
                G.play:emplace(new_ace)
                table.insert(G.playing_cards, new_ace)
                
                if(is_edition) then
                  new_ace:set_edition(edition, true)
                end
                return true
            end}))
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = (is_edition and G.localization.descriptions.Edition[edition].name) or ((G.localization.descriptions.Enhanced[enhancement.name] or {name = enhancement.name}).name), colour = G.C.SECONDARY_SET.Enhanced})

        G.E_MANAGER:add_event(Event({
            func = function() 
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                return true
            end}))
            draw_card(G.play,G.deck, 90,'up', nil)  

        playing_card_joker_effects({true})
          

        return({})
          end
      end

    


    -- calculate = function(self, card, context)
  
    --   if context.final_scoring_step then

    --     local current = card.ability.other_rank_count
    --     for k, v in pairs(context.full_hand) do
    --       if v.base.id == G.GAME.current_round.auys_card.id and v.ability.effect ~= 'Stone Card' then
    --         current = current + 1
    --       end
    --     end
        
    --     if(not context.blueprint_card) then
    --     G.E_MANAGER:add_event(Event({
    --       func = function()

    --         card.ability.other_rank_count = current
                
    --         if(current >= card.ability.other_rank_need) then
            
    --           auys_refresh()
    --           card.ability.other_rank_count = 0

    --         end

            
    --         return true
    --       end}))
    --     end
    --   if current >= card.ability.other_rank_need and card.ability.other_rank_count < card.ability.other_rank_need then

    --     local valid_aces = {}
    --     local cen_pool = {}
        
    --     for k, v in pairs(G.P_CARDS) do
    --       if v.value == "Ace" then
    --         valid_aces[#valid_aces+1] = v
    --       end
    --     end
        
    --     for k, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
    --       if v.key ~= 'm_stone' then 
    --           cen_pool[#cen_pool+1] = v
    --       end
    --     end

    --     local is_edition = pseudorandom('korc_buffer!') < card.ability.extra.edition_chance

    --     local front = pseudorandom_element(valid_aces, pseudoseed('ace_suit'))
    --     local enhancement = G.P_CENTERS.c_base
    --     local edition = 'e_base'

    --     if(is_edition) then
    --       edition = poll_edition('ace_edition', nil, card.ability.extra.no_negative, true)
    --     else
    --       enhancement = pseudorandom_element(cen_pool, pseudoseed('ace_enhancement'))
    --     end

    --     G.E_MANAGER:add_event(Event({
    --         func = function()
    --             local new_ace = create_playing_card({
    --               front = front, 
    --               center = enhancement}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced})
              


    --             if(is_edition) then
    --               new_ace:set_edition(edition, true)
    --             end
                
    --             G.GAME.blind:debuff_card(new_ace)
    --             G.hand:sort()    
    --             return true
    --         end}))
    --         card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = (is_edition and G.P_CENTERS[edition].name) or (enhancement.label), colour = G.C.SECONDARY_SET.Enhanced})

    --     playing_card_joker_effects({true})
          

    --     return ({})
    --       end
    --     end
    --   end
  }

  -- auys_refresh = function()
  --   -- new auys rank
  --   G.GAME.current_round.auys_card = {rank = 'King'}
  --   local valid_auys_cards = {}
  --   for k, v in ipairs(G.playing_cards) do
  --       if v.ability.effect ~= 'Stone Card' and v.base.id ~= 14 then
  --         if v.base.id > 0 then
  --         valid_auys_cards[#valid_auys_cards+1] = v
  --         end
  --       end
  --   end
  --   if valid_auys_cards[1] then 
  --       local auys_card = pseudorandom_element(valid_auys_cards, pseudoseed('comic_boko'..G.GAME.round_resets.ante))
  --       G.GAME.current_round.auys_card.rank = auys_card.base.value
  --       G.GAME.current_round.auys_card.id = auys_card.base.id
  --   end
    
  -- end

  
  
  SMODS.Joker {
    key = 'blackjack',
    loc_txt = {
      name = 'Blackjack',
      text=
      {
        "Gains {C:chips}+#1#{} Chips if the {C:attention}sum of",
        "{C:attention}played hands' ranks{} is equal to {C:attention}#2#",
        "{C:inactive}(ex. {C:attention}Ace{C:inactive}, {C:attention}King{C:inactive} or {C:attention}8{C:inactive}, {C:attention}8{C:inactive}, {C:attention}5{C:inactive})",
        "{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips)"
      },
      unlock = {
      "Defeat a Blind by playing",
      "a {C:attention,E:1}#1#{} of {C:attention,E:1}#2#s{}"
    }
  },
  unlock_condition = {extra = {hand = "Three of a Kind", rank = 7}},
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
    if args.type == 'hand' and args.handname == self.unlock_condition.extra.hand then
      G.GAME.black_jack_unlock_flag = true
        for _, card in pairs(args.scoring_hand) do
            if card:get_id() ~= self.unlock_condition.extra.rank then
                G.GAME.black_jack_unlock_flag = false
            end
        end
    end
    if args.type == 'round_win' and G.GAME.black_jack_unlock_flag then
      unlock_card(self)
    end
end,
locked_loc_vars = function(self, info_queue, card)
  return { vars = {self.unlock_condition.extra.hand, self.unlock_condition.extra.rank}}
end,
  loc_vars = function(self, info_queue, card)
    return { vars= {card.ability.extra.chip_mod, card.ability.extra.result,card.ability.chips} }
  end,
    config = { extra = {chip_mod = 21, result = 21}, chips = 0 },
    rarity = 3,
    atlas = "korczak",
    blueprint_compat = true,
    perishable_compat = false,
    pos = {x = 14, y = 0},
    cost = 7,
    calculate = function(self, card, context)
  

      if context.joker_main and card.ability.chips > 0 then

        return {
          message = localize{type='variable',key='a_chips',vars={card.ability.chips}},
          chip_mod = card.ability.chips, 
          colour = G.C.CHIPS
      }

      end


      if context.before and context.full_hand and not context.blueprint_card then

        local result = 0

        for k, v in pairs(context.full_hand) do
        
          if v.ability.effect ~= 'Stone Card' and not v.debuff then
            result = result + v.base.nominal
          end
        end
        
        if(result==card.ability.extra.result) then

          card.ability.chips = card.ability.chips + card.ability.extra.chip_mod
          return {
              message = localize('k_upgrade_ex'),
              colour = G.C.CHIPS
          }
        end
      end
    end
  }

  
  SMODS.Joker {
    key = 'ceo',
    loc_txt = {
      name = 'CEO',
      text=
      {
        "All other {C:attention}Jokers{} give {X:red,C:white}X#1#{} Mult",
        "gains {X:red,C:white}X#2#{} Mult per {C:attention}#3# Jokers{} sold",
        "{C:inactive}(Currently {C:attention}#4#{C:inactive}/#3#)"
    },
    unlock = {
      "Destroy {E:1,C:attention}#1#{} Jokers",
      "in one run"
    }
  },
  locked_loc_vars = function(self, info_queue, card)
    return {vars = {self.unlock_condition.extra.destroy}}
  end,
  unlocked = false,
  discovered = false,
    config = { extra = {fire_cap = 3, fired = 0 , x_mult = 1, x_mult_step = 0.1, dollar = 0} },
    unlock_condition = {extra = {destroy = 3}},
    rarity = 3,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 13, y = 1},
    cost = 8,
    loc_vars = function(self, info_queue, card)
      return { vars= {card.ability.extra.x_mult,card.ability.extra.x_mult_step,card.ability.extra.fire_cap,card.ability.extra.fired} }
    end,
    calc_dollar_bonus = function(self, card)
      if(card.ability.extra.dollar > 0 and G.GAME.modifiers.ceo_earn) then

        return(card.ability.extra.dollar)
      end
    end,
    calculate = function(self, card, context)

    if context.buying_card and ( G.GAME.modifiers.shopkeep_negate and context.card.ability.ceo_approved ) then
      card_eval_status_text(card, 'extra', nil, nil, nil,
      {
        message = 'Hired!',
        card = card,
        colour = G.C.GREEN
      })

    end

    if context.other_joker then
      if card.ability.extra.x_mult > 1 and ((blueprint_card or card) ~= context.other_joker) then
          G.E_MANAGER:add_event(Event({
              func = function()
                  context.other_joker:juice_up(0.5, 0.5)
                  return true
              end
          })) 
          return {
              message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
              Xmult_mod = card.ability.extra.x_mult
          }
      end
    end


        if context.selling_card and not context.blueprint_card and context.card.ability.set == "Joker" then

          card.ability.extra.fired = card.ability.extra.fired + 1
          if(card.ability.extra.fired >= card.ability.extra.fire_cap) then
            if (G.GAME.modifiers.ceo_earn) then
              card.ability.extra.dollar = card.ability.extra.dollar + G.GAME.modifiers.ceo_earn
            end
            card.ability.extra.fired = 0
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_step
            card_eval_status_text(card, 'extra', nil, nil, nil,
          {
            message = 'Fired!',
            card = card,
            colour = G.C.MULT
          })
          end
          
        end
    end,
    check_for_unlock = function(self, args)
      
      if args.type == 'card_destroyed' and args.card.ability and args.card.ability.set == "Joker" then
        if(G.GAME.current_round.jokers_destroyed) then
          G.GAME.current_round.jokers_destroyed = G.GAME.current_round.jokers_destroyed + 1
      if G.GAME.current_round.jokers_destroyed >= self.unlock_condition.extra.destroy then
        unlock_card(self)
      end
    end
    end
  end
  }

  
  SMODS.Joker {
    key = 'd20',
    loc_txt = {
      name = 'D20 Die',
      text=
      {
        "{C:green}#1# in #2#{} chance for {C:white,X:mult}X#3#{} Mult when hand is played",
        "raises {C:green}probability{} by {C:green}#4#{} when {C:attention}rerolling{} in {C:attention}the shop",
        "If triggered resets when {C:attention}Blind{} is defeated"
    },
    unlock={
      "Spend {E:1,C:money}$#1#{} overall on",
      "rerolls in shop in one run",
    }
    },
    config = { extra = {reset_to = 1, chance_step = 1, numerator = 1, chance = 20, x_mult = 5, was_triggered = false} },
    rarity = 3,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 16, y = 1},
    unlocked = false,
    discovered = false,
    unlock_condition = {extra = {spent = 100}},
    cost = 8,
    loc_vars = function(self, info_queue, card)
      return { vars= {card.ability.extra.numerator * G.GAME.probabilities.normal, card.ability.extra.chance, card.ability.extra.x_mult, G.GAME.probabilities.normal * card.ability.extra.chance_step} }
    end,
    locked_loc_vars = function(self, info_queue, card)
      return { vars = {self.unlock_condition.extra.spent}}
    end,
    calculate = function(self, card, context)
  
      if context.reroll_shop and not context.blueprint_card then

        card.ability.extra.numerator = card.ability.extra.numerator + card.ability.extra.chance_step
        return({
          card = card,
          colour = G.C.GREEN,
          message = localize('k_upgrade_ex')
        })

      end

      if context.joker_main then

        
        if (pseudorandom('d20_dieee') <= (card.ability.extra.numerator * G.GAME.probabilities.normal)/card.ability.extra.chance) then 
        if not context.blueprint_card then
          card.ability.extra.was_triggered = true
        end
        return {
          Xmult_mod = card.ability.extra.x_mult,
          message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
          colour = G.C.MULT,
          card = card
        }
      end
    end
      end,
      
      check_for_unlock = function(self, args)
        
        
        if args.type == 'spend_on_reroll' and G.GAME.current_round.spent_on_rerolls >= self.unlock_condition.extra.spent then
        unlock_card(self)
        end
    end
  }

  
  SMODS.Joker {
    key = 'painter',
    loc_txt = {
      name = 'Painter',
      text=
      {
        "Creates a random {C:tarot}Tarot{} card if scoring hand",
        "contains a {V:1}#1#{} card and a {V:2}#2#{} card",
        "{C:inactive}(must have room, suits change every round)"
    },
    unlock = {
      "Destroy {E:1,C:attention}#1#{} Wild cards",
      "in one run"
    }
  },
  locked_loc_vars = function(self, info_queue, card)
    return {vars = {self.unlock_condition.extra.destroy}}
  end,
  unlocked = false,
  discovered = false,
  unlock_condition = {extra = {destroy = 4}},
    config = { extra = {} },
    rarity = 3,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 14, y = 3},
    cost = 8,
    loc_vars = function(self, info_queue, card)
      return { vars = {
      localize(G.GAME.current_round.painter_asthetic1, 'suits_singular'),
      localize(G.GAME.current_round.painter_asthetic2, 'suits_singular'),
      colours = {G.C.SUITS[G.GAME.current_round.painter_asthetic1],G.C.SUITS[G.GAME.current_round.painter_asthetic2]} -- sets the colour of the text affected by `{V:1}`
        } }
    end,
    calculate = function(self, card, context)
  
      if(context.joker_main)then
        local suit1 = G.GAME.current_round.painter_asthetic1
        local suit2 = G.GAME.current_round.painter_asthetic2
        local card1 = nil
        local card2 = nil
        local suits = {
          [suit1] = 0,
          [suit2] = 0
        }
      for i = 1, #context.scoring_hand do
          if context.scoring_hand[i].ability.name ~= 'Wild Card' then
              if context.scoring_hand[i]:is_suit(suit1, true) and suits[suit1] == 0 then suits[suit1] = suits[suit1] + 1; card1 = context.scoring_hand[i]
              elseif context.scoring_hand[i]:is_suit(suit2, true) and suits[suit2] == 0  then suits[suit2] = suits[suit2] + 1; card2 = context.scoring_hand[i] end
          end
      end
      for i = 1, #context.scoring_hand do
          if context.scoring_hand[i].ability.name == 'Wild Card' then
              if context.scoring_hand[i]:is_suit(suit1) and suits[suit1] == 0 then suits[suit1] = suits[suit1] + 1; card1 = context.scoring_hand[i]
              elseif context.scoring_hand[i]:is_suit(suit2) and suits[suit2] == 0  then suits[suit2] = suits[suit2] + 1; card2 = context.scoring_hand[i] end
          end
      end
      if suits[suit1] > 0 and
      suits[suit2] > 0 then
        card1:juice_up(0.5,0.5)
        card2:juice_up(0.5,0.5)
          
        if not (context.blueprint_card or card).getting_sliced and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
          G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
          G.E_MANAGER:add_event(Event({
              func = (function()
                
                          if(G.GAME.modifiers.moment_omori and (pseudorandom('momento_mori') * 3 < 1)) then
                            local specific = pseudorandom_element({"c_hermit", "c_temperance"}, pseudoseed('moment_omori'))
                            G.GAME.banned_keys[specific] = false
                            local _card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, specific, 'pain')
                            _card:add_to_deck()
                            G.consumeables:emplace(_card)
                            G.GAME.banned_keys[specific] = true
                          else
                            local _card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'pain')
                            _card:add_to_deck()
                            G.consumeables:emplace(_card)
                          end
                          G.GAME.consumeable_buffer = 0
                          
                      return true
                    end)}))
                  end
                  
                  
                  return({card = context.blueprint_card or card, message = localize('k_plus_tarot'), colour = G.C.PURPLE})
                               
                end
  end
  end,
  check_for_unlock = function(self, args)
      
    if args.type == 'card_destroyed' and args.card.ability and args.card.ability.name == "Wild Card" and G.GAME.current_round.wilds_destroyed then
    G.GAME.current_round.wilds_destroyed = G.GAME.current_round.wilds_destroyed + 1
    if G.GAME.current_round.wilds_destroyed >= self.unlock_condition.extra.destroy then
    unlock_card(self)
    end
  end
end
    }

  SMODS.Joker {
    key = 'space_dog',
    loc_txt = {
      name = 'Space Dog',
      text=
      {
        "Once per {C:attention}selected Blind{}",
        "creates a random {C:planet}Planet{} card",
        "when using a {C:planet}Planet{} card",
        "{C:inactive}(must have room)"
    },
    },
    in_pool = function(self, args)
      local planets_used = 0
      for k, v in pairs(G.GAME.consumeable_usage) do if v.set == 'Planet' then planets_used = planets_used + 1 end end
      return(planets_used>0)
    end,
    config = { extra = 1 },
    rarity = 1,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 10, y = 0},
    soul_pos = {x = 11, y = 0},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      return { vars= {card.ability.extra} }
    end,
    calculate = function(self, card, context)
      if context.setting_blind or (card.ability.spaceDogUsed == nil) then
        if not context.blueprint_card then
        card.ability.spaceDogUsed = false
        local spaceDogJuice = function(card) return (card.ability.spaceDogUsed ~= true) end
        juice_card_until(card, spaceDogJuice, true)
      end
      end
      if (context.using_consumeable and context.consumeable.ability.set == "Planet") then

        if (not card.ability.spaceDogUsed) then

          if not context.blueprint_card then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            card.ability.spaceDogUsed = true
              return true
            end
            }))
          end

          for i = 1, card.ability.extra do
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
          if G.consumeables.config.card_limit > #G.consumeables.cards then
            
        if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
          G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
          func = function()
            local _card = create_card('Planet',G.consumeables, nil, nil, nil, nil, nil, 'spaaaaaace_dog')
            _card:add_to_deck()
            G.consumeables:emplace(_card)
            G.GAME.consumeable_buffer = 0
            return true
          end
        }))
      end
      end
      return true end }))
    end
        
        return({
            colour = G.C.SECONDARY_SET.Planet,
            message = 'Yo!'
        })
      end
    end
    end
  }


  
  SMODS.Joker {
    key = 'jumpsuit_red',
    loc_txt = {
      name = 'Jumpsuit Red',
      text=
      {
        "Retriggers and then breaks",
        "all scoring {C:attention}Glass{} cards"
    },
    },
    config = { extra = {reps = 1}},
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    enhancement_gate = "m_glass",
    pos = {x = 8, y = 0},
    soul_pos = {x = 9, y = 0},
    cost = 6,
    loc_vars = function(self, info_queue, card)
      -- return { vars= {card.ability.extra.mult_mod,card.ability.mult} }
      return { vars= {card.ability.extra.reps} }
    end,
    calculate = function(self, card, context)
  
      
    if context.repetition then
      if context.cardarea == G.play and context.other_card.config.center == G.P_CENTERS.m_glass then
              return {
                  message = localize('k_again_ex'),
                  repetitions = card.ability.extra.reps,
                  card = card
              }
          end
        end


      if context.full_hand and context.destroying_card and not context.blueprint then

        if context.destroying_card.ability.effect == 'Glass Card' then return true end

      end

      
      if context.remove_playing_cards and not context.blueprint_card then
        local glass_cards = 0
        for k, val in ipairs(context.removed) do
            if val.shattered then glass_cards = glass_cards + 1 end
        end
        if glass_cards > 0 then 
            G.E_MANAGER:add_event(Event({
                func = function()
            
            card_eval_status_text(card, 'extra', nil, nil, nil, {colour=G.C.MULT, message = "Just as planned!"})
            return true
                end
            }))
        end
        return
    end


    end
  }

  
  SMODS.Joker {
    key = 'helen',
    loc_txt = {
      name = 'Helen',
      text=
      {
        "Each {C:attention}face{} card gives {C:mult}+#3#{} Mult when scored",
        "{C:green}#1# in #2#{} chance to destroy each and gain {C:mult}+#4#{} Mult"
    },
    },
    config = { extra = {chance = 4, mult_mod = 1}, mult = 5 },
    rarity = 2,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 6, y = 0},
    soul_pos = {x = 7, y = 0},
    cost = 7,
    loc_vars = function(self, info_queue, card)
      return { vars= {G.GAME.probabilities.normal, card.ability.extra.chance, card.ability.mult, card.ability.extra.mult_mod} }
    end,
    calculate = function(self, card, context)
  
      if context.full_hand and context.destroying_card and not context.blueprint then

        if(context.destroying_card:is_face() and (pseudorandom('helen_target') <= G.GAME.probabilities.normal/card.ability.extra.chance)) then
          card.ability.mult = card.ability.mult + card.ability.extra.mult_mod
          card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Got 'em!", colour = G.C.MULT})

          return true
        else
          return nil
        end

      end
      


      if context.individual and context.cardarea == G.play then

        if(context.other_card:is_face()) then
        
        return {
          mult = card.ability.mult,
          card = card,
          colour = G.C.MULT
        }
      end
      end

    end
  }

  SMODS.Joker {
    key = 'harlequin',
    loc_txt = {
      name = 'Harlequin',
      text=
      {
        "Each {C:attention}Gold{} card in hand",
        "gives {C:white,X:mult}X#3#{} Mult"
      },
      unlock={
        "Find this Joker",
        "from the {C:spectral}Soul{} card",
      }
    },
    config = { extra = {xmult = 2} },
    rarity = 4,
    atlas = "korczak",
    blueprint_compat = true,
    pos = {x = 4, y = 0},
    soul_pos = {x = 5, y = 0},
    unlocked = false,
    discovered = false,
    unlock_condition = {type = '', extra = '', hidden = true},
    cost = 10,
    loc_vars = function(self, info_queue, card)
      return { vars= {G.GAME.probabilities.normal, card.ability.extra.chance, card.ability.extra.xmult} }
    end,
    calculate = function(self, card, context)
  
      if context.individual and context.cardarea == G.hand and not context.end_of_round then

        if (context.other_card.ability.effect == 'Gold Card' and not context.other_card.debuff) then
          return {
            x_mult = card.ability.extra.xmult,
            card = context.other_card
        }
        end

      end
      end
  }


  G.localization.misc.v_text['ch_c_grease_probabilities'] = {"Grease Monkey's chances are {C:green}1 in #1#{}"}
  G.localization.misc.v_text['ch_c_glorious_leader'] = {"Every Ante, a random {C:attention}secret rank{}"}
  G.localization.misc.v_text['ch_c_glorious_leader2'] = {"gets a random{C:attention} scoring effect{}"}
  G.localization.misc.v_text['ch_c_kozer_debuff_card'] = {"Lowest and highest scoring cards every hand are {E:1,C:red,s:0.9}debuffed{}"}
  G.localization.misc.v_text['ch_c_kozer_text'] = {"until {C:attention}Boss Blind{} is defeated"}
  G.localization.misc.v_text['ch_c_kozer_destroy_joker'] = {"The Unsellable {C:attention}Joker{} is destroyed"}
  G.localization.misc.v_text['ch_c_kozer_text2'] = {"when {C:attention}Boss Blind{} is defeated"}
  G.localization.misc.v_text['ch_c_kozer_empty'] = {"   "}
  G.localization.misc.v_text['ch_c_kozer_suit'] = {"{C:attention}Durak{} changes suits only"}
  G.localization.misc.v_text['ch_c_kozer_create_joker'] = {"Creates a {C:dark_edition}Negative {}Unsellable {C:attention}Joker{} according to {C:attention}Durak{}'s suit"}
  G.localization.misc.v_text['ch_c_cryptid_hungry'] = {"{C:spectral}Cryptid{} can appear in shop"}
  G.localization.misc.v_text['ch_c_ceo_earn'] = {"Earn {C:money}$#1#{} at the end of round for every time you upgraded {C:attention}CEO"}
  G.localization.misc.v_text['ch_c_always_the_eye'] = {"{E:1}Can't play repeat hand types in any Blind{}"}
  G.localization.misc.v_text['ch_c_blind_scaling'] = {"Antes scale {C:red}#1#{} times as fast"}
  G.localization.misc.v_text['ch_c_incognito'] = {"{C:attention}Web Search{} can’t choose poker hands already played in Blind"}
  -- G.localization.misc.v_text['ch_c_clear_history'] = {"{C:attention}Web Search{} can’t choose certain poker hands"}
  G.localization.misc.v_text['ch_c_spectral_shop'] = {"{C:spectral}Spectral{} cards can appear in shop"}
  G.localization.misc.v_text['ch_c_booster_slots'] = {"Every shop has {C:attention}#1#{} Booster Packs"}
  G.localization.misc.v_text['ch_c_jimbo_debt'] = {"{C:red}Lose{} {C:money}$#1#{} when {C:attention}Boss Blind{} is defeated"}
  G.localization.misc.v_text['ch_c_no_planets'] = {"{C:planet}Planet{} cards no longer appear in shop"}
  G.localization.misc.v_text['ch_c_moment_omori'] = {"{C:attention}Painter{} has a high chance producing {C:tarot}The Hermit{} & {C:tarot}Temperance{}"}
  G.localization.misc.v_text['ch_c_ceo_rental'] = {"{C:attention}Common Jokers{} deduct {C:money}$1{} at the end of round"}
  G.localization.misc.v_text['ch_c_ceo_rental_text'] = {"{C:attention}All Other rarities{} deduct {C:money}$3{} at the end of round"}
  G.localization.misc.v_text['ch_c_shopkeep_negate'] = {"Jokers gained through {C:attention}Shopkeep{} don't deduct Cash"}

  
  

  
  -- SMODS.Challenge {

  --   key = "test_challenge",
  --   loc_txt = {name = 'TEST'},
  --   unlocked = function(self)
  --   return(true)
  --   end 
  --   ,
  --       rules = {
  --       custom = {
  --       },
  --       modifiers = {
  --       }
  --   },
  --   restrictions = {
  --     banned_cards =  {
  --       {id = 'p_buffoon_normal_1', ids =  {'j_four_fingers','j_mime','j_credit_card','j_ceremonial','j_banner','j_mystic_summit','j_loyalty_card','j_8_ball','j_dusk','j_raised_fist','j_fibonacci','j_scary_face','j_delayed_grat','j_hack','j_pareidolia','j_gros_michel','j_business','j_supernova','j_ride_the_bus','j_egg','j_ice_cream','j_dna','j_splash','j_superposition','j_todo_list','j_cavendish','j_red_card','j_seance','j_shortcut','j_cloud_9','j_rocket','j_obelisk','j_midas_mask','j_gift','j_turtle_bean','j_erosion','j_reserved_parking','j_mail','j_to_the_moon','j_juggler','j_drunkard','j_lucky_cat','j_baseball','j_bull','j_diet_cola','j_popcorn','j_trousers','j_ancient','j_ramen','j_walkie_talkie','j_selzer','j_castle','j_smiley','j_campfire','j_ticket','j_acrobat','j_sock_and_buskin','j_troubadour','j_certificate','j_hanging_chad','j_rough_gem','j_bloodstone','j_arrowhead','j_onyx_agate','j_flower_pot','j_oops','j_idol','j_seeing_double','j_hit_the_road','j_duo','j_trio','j_family','j_order','j_tribe','j_satellite','j_shoot_the_moon','j_drivers_license','j_bootstraps','j_joker','j_baron','j_greedy_joker','j_lusty_joker','j_wrathful_joker','j_gluttenous_joker','j_jolly','j_zany','j_mad','j_droll','j_crazy','j_sly','j_wily','j_clever','j_devious','j_crafty','j_half','j_stencil','j_marble','j_misprint','j_chaos','j_steel_joker','j_abstract','j_even_steven','j_odd_todd','j_scholar','j_space','j_burglar','j_blackboard','j_runner','j_blue_joker','j_sixth_sense','j_constellation','j_hiker','j_faceless','j_green_joker','j_card_sharp','j_madness','j_square','j_riff_raff','j_vampire','j_hologram','j_vagabond','j_luchador','j_photograph','j_hallucination','j_fortune_teller','j_stone','j_golden','j_trading','j_flash','j_mr_bones','j_swashbuckler','j_smeared','j_throwback','j_glass','j_ring_master','j_blueprint','j_wee','j_merry_andy','j_matador','j_stuntman','j_invisible','j_brainstorm','j_cartomancer','j_astronomer','j_burnt','j_caino','j_triboulet','j_yorick','j_chicot','j_perkeo','c_soul'},
  --       },
  --       {id="j_joker", ids = {
  --         'j_korczak_durak',
  --         'j_korczak_chairman',
  --         'j_korczak_treasure_hunter',
  --         'j_korczak_game_piece',
  --         -- 'j_korczak_grease_monkey',
  --         -- 'j_korczak_mecha_joker',
  --         'j_korczak_compass',
  --         -- 'j_korczak_alley_warrior',
  --         'j_korczak_capricorn',
  --         'j_korczak_comic_book',
  --         'j_korczak_calculus',
  --         'j_korczak_pepperoni',
  --         'j_korczak_graffiti',
  --         'j_korczak_web_search',
  --         'j_korczak_encounter',
  --         'j_korczak_buffer',
  --         'j_korczak_animation',
  --         -- 'j_korczak_exhibit',
  --         'j_korczak_x_marks_the_joke',
  --         'j_korczak_paladin',
  --         'j_korczak_shopkeep',
  --         'j_korczak_ace_up_your_sleeve',
  --         'j_korczak_blackjack',
  --         'j_korczak_ceo',
  --         'j_korczak_d20',
  --         'j_korczak_painter',
  --         -- 'j_korczak_space_dog',
  --         -- 'j_korczak_jumpsuit_red',
  --         'j_korczak_helen',
  --         'j_korczak_harlequin',
  --       }}
  --     }
  --   },
  --   jokers = {
  --   },
  --   vouchers = {
  --     {id = 'v_overstock_norm'},
  --     {id = 'v_overstock_plus'}
  --   },
  --   deck = {
  --       type = 'Challenge Deck'
  --   }
    
  -- }



  
  SMODS.Challenge {

    key = "grease_monkey",
    loc_txt = {name = "A Mechanic's Requiem"},
    unlocked = function(self)
    return(true)
    end 
    ,
        rules = {
        custom = {
          {id = 'grease_probabilities', value = 2},
        },
        modifiers = {
          {id = 'joker_slots', value = 6},
        }
    },
    restrictions = {
      banned_cards =  {
        {id = 'c_wheel_of_fortune'},
        {id = 'v_hone'},
        {id = 'v_glow_up'},
        {id = 'c_ectoplasm'},
        {id = 'c_ankh'},
        
        {id='j_joker'},
        {id='j_greedy_joker'},
        {id='j_lusty_joker'},
        {id='j_wrathful_joker'},
        {id='j_gluttenous_joker'},
        {id='j_jolly'},
        {id='j_zany'},
        {id='j_mad'},
        {id='j_crazy'},
        {id='j_droll'},
        {id='j_sly'},
        {id='j_wily'},
        {id='j_clever'},
        {id='j_devious'},
        {id='j_crafty'},
        {id='j_half'},
        {id='j_stencil'},
        {id='j_ceremonial'},
        {id='j_banner'},
        {id='j_mystic_summit'},
        {id='j_loyalty_card'},
        {id='j_misprint'},
        {id='j_raised_fist'},
        {id='j_fibonacci'},
        {id='j_steel_joker'},
        {id='j_scary_face'},
        {id='j_abstract'},
        {id='j_gros_michel'},
        {id='j_even_steven'},
        {id='j_odd_todd'},
        {id='j_scholar'},
        {id='j_supernova'},
        {id='j_ride_the_bus'},
        {id='j_blackboard'},
        {id='j_runner'},
        {id='j_ice_cream'},
        {id='j_blue_joker'},
        {id='j_constellation'},
        {id='j_green_joker'},
        {id='j_cavendish'},
        {id='j_card_sharp'},
        {id='j_red_card'},
        {id='j_madness'},
        {id='j_square'},
        {id='j_vampire'},
        {id='j_hologram'},
        {id='j_baron'},
        {id='j_obelisk'},
        {id='j_photograph'},
        {id='j_erosion'},
        {id='j_fortune_teller'},
        {id='j_stone'},
        {id='j_lucky_cat'},
        {id='j_baseball'},
        {id='j_bull'},
        {id='j_flash'},
        {id='j_popcorn'},
        {id='j_trousers'},
        {id='j_ancient'},
        {id='j_ramen'},
        {id='j_walkie_talkie'},
        {id='j_castle'},
        {id='j_smiley'},
        {id='j_campfire'},
        {id='j_acrobat'},
        {id='j_swashbuckler'},
        {id='j_throwback'},
        {id='j_bloodstone'},
        {id='j_arrowhead'},
        {id='j_onyx_agate'},
        {id='j_glass'},
        {id='j_flower_pot'},
        {id='j_blueprint'},
        {id='j_wee'},
        {id='j_idol'},
        {id='j_seeing_double'},
        {id='j_hit_the_road'},
        {id='j_duo'},
        {id='j_trio'},
        {id='j_family'},
        {id='j_order'},
        {id='j_tribe'},
        {id='j_stuntman'},
        {id='j_invisible'},
        {id='j_brainstorm'},
        {id='j_shoot_the_moon'},
        {id='j_drivers_license'},
        {id='j_bootstraps'},
        {id='j_caino'},
        {id='j_triboulet'},
        {id='j_yorick'},
        {id='j_korczak_durak'},
        {id='j_korczak_chairman'},
        {id='j_korczak_game_piece'},
        {id='j_korczak_mecha_joker'},
        {id='j_korczak_alley_warrior'},
        {id='j_korczak_calculus'},
        {id='j_korczak_pepperoni'},
        {id='j_korczak_web_search'},
        {id='j_korczak_encounter'},
        {id='j_korczak_buffer'},
        {id='j_korczak_x_marks_the_joke'},
        {id='j_korczak_blackjack'},
        {id='j_korczak_ceo'},
        {id='j_korczak_d20'},
        {id='j_korczak_helen'},
        {id='j_korczak_harlequin'},
      },
      banned_tags = {
        {id = "tag_foil"},
        {id = "tag_holo"},
        {id = "tag_polychrome"},
        {id = 'tag_negative'}
      },
      banned_other = {
        {id = 'bl_flint', type = 'blind'},
        {id = 'bl_wall', type = 'blind'},
        {id = 'bl_final_vessel', type = 'blind'},
        {id = 'bl_final_leaf', type = 'blind'}
      }
    },
    jokers = {
      {id = 'j_korczak_grease_monkey', eternal = true}
    },
    vouchers = {
    },
    deck = {
        type = 'Challenge Deck'
    }
    
  }


  
  SMODS.Challenge {

    key = "cryptid",
    loc_txt = {name = 'Cryptid Hunting'},
    unlocked = function(self)
    return(

    G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[('c_korczak_grease_monkey')]
    
    or(

    G.P_CENTERS['j_korczak_encounter'].discovered
    or
    G.P_CENTERS['j_korczak_compass'].discovered


    )

    )
    end 
    ,
        rules = {
        custom = {
          {id = 'cryptid_hungry'},
        },
        modifiers = {
          {id = 'discards', value = 5},
          {id = 'hands', value = 1},
        }
    },
    restrictions = {
      banned_cards =  {        
        {id = 'j_trading'},
        {id = 'j_merry_andy'},
        {id = 'j_drunkard'},
        {id = 'j_juggler'},
        {id = 'j_troubadour'},
        {id = 'j_sixth_sense'},
        {id = 'j_seance'},
        {id = 'j_korczak_game_piece'},
        {id = 'j_korczak_paladin'},
        {id = 'j_korczak_helen'},
        {id = 'c_hanged_man'},
        {id = 'v_hieroglyph'},
        {id = 'v_petroglyph'},
        {id = 'v_wasteful'},
        {id = 'v_recyclomancy'},
        {id = 'v_grabber'},
        {id = 'v_nacho_tong'},
        {id = 'v_palette'},
        {id = 'v_omen_globe'},
        {id = 'p_spectral_normal_1', ids = {'p_spectral_normal_1', 'p_spectral_normal_2', 'p_spectral_jumbo_1', 'p_spectral_mega_1',
        'c_familiar',
        'c_grim',
        'c_incantation',
        'c_talisman',
        'c_aura',
        'c_wraith',
        'c_sigil',
        'c_ouija',
        'c_ectoplasm',
        'c_immolate',
        'c_ankh',
        'c_deja_vu',
        'c_hex',
        'c_trance',
        'c_medium',
        'c_soul',
        'c_black_hole',
        }},
        

      },
      banned_tags = {
        {id = "tag_ethereal"}
      },
      banned_other = {
        {id = 'bl_needle', type = 'blind'},
        {id = 'bl_wall', type = 'blind'},
        {id = 'bl_psychic', type = 'blind'},
        {id = 'bl_water', type = 'blind'},
        {id = 'bl_flint', type = 'blind'},
        {id = 'bl_final_bell', type = 'blind'},
        {id = 'bl_final_vessel', type = 'blind'}
      }
    },
    jokers = {
      {id = 'j_korczak_encounter', eternal = true},
      {id = 'j_korczak_compass', eternal = true}
    },
    consumeables = {
      {id = 'c_black_hole'}
    },
    vouchers = {
      {id = 'v_paint_brush'}
    },
    deck = {
        type = 'Challenge Deck'
    }
    
  }




  function Card:glorious_modifier(context)

    local ret = G.GAME.current_round.glorious_modifiers[self:get_id()] or {}
    ------------------------------------
    if(ret.reset_money and G.GAME.dollars > 0) then
      G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
      ease_dollars(-G.GAME.dollars, true)
      self:juice_up(0.3, 0.5)
      return true
        end
    }))
    end

    ------------------------------------
    if(ret.debuff) then
      G.E_MANAGER:add_event(Event({func = function()
      SMODS.debuff_card(self, true, "glorious")
      return true end }))
    end

    ------------------------------------
    if(ret.destroy_random_joker) then

      
      local destructable_jokers = {}
      for i = 1, #G.jokers.cards do
          if not G.jokers.cards[i].ability.eternal and not G.jokers.cards[i].getting_sliced then destructable_jokers[#destructable_jokers+1] = G.jokers.cards[i] end
      end
      local joker_to_destroy = #destructable_jokers > 0 and pseudorandom_element(destructable_jokers, pseudoseed('glorious_execution')) or nil
      
      
      if joker_to_destroy then
        joker_to_destroy.getting_sliced = true
        joker_to_destroy.executed = true
        G.E_MANAGER:add_event(Event({func = function()
          self:juice_up(0.8, 0.8)
          joker_to_destroy:start_dissolve({G.C.RED}, nil, 0.5)
          return true end }))
      end


    end

    ------------------------------------

    -- koyzer scoring debuff (im sorry im using this for two things ;-;)

    if(G.GAME.modifiers.kozer_debuff_card and not SMODS.has_no_rank(self)) then

      local smallest = true
      local biggest = true


      for i=1, #context.scoring_hand do
        if self.base.id > context.scoring_hand[i].base.id and not SMODS.has_no_rank(context.scoring_hand[i]) then 
            smallest = false
        end
        if self.base.id < context.scoring_hand[i].base.id and not SMODS.has_no_rank(context.scoring_hand[i]) then 
            biggest = false
        end
      end


      if(smallest or biggest) then
        G.E_MANAGER:add_event(Event({func = function()
        SMODS.debuff_card(self, true, "kozer")
        return true end }))
      end

    end


    return(ret)
  end
  
  SMODS.Challenge {

    key = "supreme_chairman",
    loc_txt = {name = 'The Glorious Leader'},
    unlocked = function(self)
    return(

    G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[('c_korczak_cryptid')]

    
    or(

    G.P_CENTERS['j_korczak_chairman'].discovered


    )

    )
    end 
    ,
        rules = {
        custom = {
          {id = "glorious_leader"},
          {id = "glorious_leader2"}
        },
        modifiers = {
        }
    },
    restrictions = {
      banned_cards =  {
        {id = 'v_hieroglyph'},
        {id = 'v_petroglyph'},

      },
      banned_tags = {
      },
      banned_other = {
      }
    },
    jokers = {
      {id = 'j_korczak_chairman', eternal = true}
    },
    vouchers = {
    },
    deck = {
        type = 'Challenge Deck'
    }
    
  }




  

  
  SMODS.Challenge {

    key = "web_search",
    loc_txt = {name = 'Web Surfer'},
    unlocked = function(self)
    return(

    G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[('c_korczak_supreme_chairman')]

    or(

    G.P_CENTERS['j_korczak_web_search'].discovered


    )
    )
    end 
    ,
        rules = {
        custom = {
          {id = "always_the_eye"},
          {id = "incognito"},
          -- {id = "clear_history"}
        },
        modifiers = {
        }
    },
    restrictions = {
      banned_cards =  {
        {id = 'j_obelisk'},
      },
      banned_tags = {
      },
      banned_other = {
        {id = 'bl_mouth', type = 'blind'},
        {id = 'bl_eye', type = 'blind'},
        {id = 'bl_psychic', type = 'blind'},
        {id = 'bl_final_bell', type = 'blind'}
      }
    },
    jokers = {
      {id = 'j_korczak_web_search', eternal = true}
    },
    vouchers = {
    },
    deck = {
        type = 'Challenge Deck'
    }
    
  }

  -- -----------------------------------
  

  SMODS.Challenge {

    key = "reach_for_the_stars",
    loc_txt = {name = 'Reach for the Stars'},
    unlocked = function(self)
    return(

    G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[('c_korczak_web_search')]

    or(

    G.P_CENTERS['j_korczak_capricorn'].discovered


    )
    )
    end 
    ,
        rules = {
        custom = {
          {id = "blind_scaling", value = 2},
        },
        modifiers = {
        }
    },
    restrictions = {
      banned_cards =  {
        {id = 'j_oops'},
        {id = 'j_korczak_space_dog'},
        {id = 'c_high_priestess'},
        {id = 'j_certificate'},
        {id = 'c_trance'},
        {id = 'v_planet_merchant'},
        {id = 'v_planet_tycoon'},
        {id = 'p_celestial_normal_1', ids = {'p_celestial_normal_1', 'p_celestial_normal_2', 'p_celestial_normal_3', 'p_celestial_normal_4', 'p_celestial_mega_1', 'p_celestial_mega_2', 'p_celestial_jumbo_1', 'p_celestial_jumbo_2'}}
      },
      banned_tags = {
        {id = "tag_orbital"},
        {id = "tag_meteor"}
      },
      banned_other = {
      }
    },
    jokers = {
      {id = 'j_korczak_capricorn', eternal = true},
      {id = 'j_space', eternal = true, edition = 'negative'},
      {id = 'j_constellation', eternal = true}
    },
    vouchers = {
      {id = 'v_telescope'},
    },
    deck = {
        type = 'Challenge Deck'
    }
    
  }

  
  
  SMODS.Challenge {

    key = "durak",
    loc_txt = {name = 'Oh Kozyr, My Kozyr'},
    unlocked = function(self)
    return(

    G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[('c_korczak_reach_for_the_stars')]

    or(

    G.P_CENTERS['j_korczak_durak'].discovered


    )
    )
    end 
    ,
        rules = {
        custom = {
          {id = "kozer_suit"},
          {id = "kozer_text2"},
          {id = "kozer_empty"},
          {id = "kozer_debuff_card"},
          {id = "kozer_text"},
          {id = "kozer_empty"},
          {id = "kozer_create_joker"},
          {id = "kozer_text2"},
          {id = "kozer_empty"},
          {id = "kozer_destroy_joker"},
          {id = "kozer_text2"},
        },
        modifiers = {
          {id = 'joker_slots', value = 4},
        }
    },
    restrictions = {
      banned_cards =  {
        {id='j_ring_master'},
        {id='j_invisible'},
        {id='j_madness'},
        {id='j_ceremonial'},
        {id='j_smeared'},
        {id='j_hack'},
        {id='j_korczak_ace_up_your_sleeve'},
        {id='j_korczak_comic_book'},
        {id='c_lovers'},
        {id='v_illusion'},
        {id='c_familiar'},
        {id='c_grim'},
        {id='c_incantation'},
        {id='c_hex'},
        {id='c_ankh'},
        {id='c_ectoplasm'},
        {id='j_rough_gem'},
        {id='j_bloodstone'},
        {id='j_arrowhead'},
        {id='j_onyx_agate'},
        {id='j_hologram'},
        {id = 'p_standard_normal_1', ids = {'p_standard_normal_1', 'p_standard_normal_2', 'p_standard_normal_3', 'p_standard_normal_4', 'p_standard_jumbo_1', 'p_standard_mega_1', 'p_standard_jumbo_2', 'p_standard_mega_2'}},
        

      },
      banned_tags = {
        {id = "tag_standard"},
        {id = 'tag_negative'}
      },
      banned_other = {
        {id = 'bl_goad', type = 'blind'},
        {id = 'bl_club', type = 'blind'},
        {id = 'bl_window', type = 'blind'},
        {id = 'bl_head', type = 'blind'},
        {id = 'bl_pillar', type = 'blind'},
        {id = 'bl_plant', type = 'blind'},
        {id = 'bl_final_leaf', type = 'blind'}
      }
    },
    jokers = {
      {id = 'j_korczak_durak', eternal = true}
    },
    vouchers = {
    },
    deck = {
        type = 'Challenge Deck',
        cards = {{s='D',r='6'},{s='D',r='7'},{s='D',r='8'},{s='D',r='9'},{s='D',r='T'},{s='D',r='J'},{s='D',r='Q'},{s='D',r='K'},{s='D',r='A'},{s='C',r='6'},{s='C',r='7'},{s='C',r='8'},{s='C',r='9'},{s='C',r='T'},{s='C',r='J'},{s='C',r='Q'},{s='C',r='K'},{s='C',r='A'},{s='H',r='6'},{s='H',r='7'},{s='H',r='8'},{s='H',r='9'},{s='H',r='T'},{s='H',r='J'},{s='H',r='Q'},{s='H',r='K'},{s='H',r='A'},{s='S',r='6'},{s='S',r='7'},{s='S',r='8'},{s='S',r='9'},{s='S',r='T'},{s='S',r='J'},{s='S',r='Q'},{s='S',r='K'},{s='S',r='A'}},
    }
    
  }
  
  SMODS.Challenge {

    key = "paladin",
    loc_txt = {name = 'Steel Thy Blade'},
    unlocked = function(self)
    return(

    G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[('c_korczak_durak')]

    or(

    G.P_CENTERS['j_korczak_paladin'].discovered


    )
    )
    end 
    ,
        rules = {
        custom = {
          {id = "spectral_shop"},
          {id = "booster_slots", value = 0},
        },
        modifiers = {
          {id = 'consumable_slots', value = 0}
        }
    },
    restrictions = {
      banned_cards =  {
        {id = 'j_red_card'},
        {id = 'j_hallucination'},
        {id = 'j_perkeo'},
        {id = 'j_korczak_ace_up_your_sleeve'},
        {id = 'v_crystal_ball'},
        {id = 'v_omen_globe'},
        {id = 'v_overstock_norm'},
        {id = 'v_overstock_plus'},
        {id = 'v_illusion'},
        {id = 'v_telescope'},
      },
      banned_tags = {
        {id = "tag_meteor"},
        {id = "tag_buffoon"},
        {id = "tag_standard"},
        {id = "tag_charm"},
        {id = "tag_ethereal"}
      },
      banned_other = {
        {id = 'bl_final_heart', type = 'blind'}
      }
    },
    jokers = {
      {id = 'j_korczak_paladin', eternal = true}
    },
    vouchers = {
      {id = 'v_planet_merchant'},
      {id = 'v_planet_tycoon'},
      {id = 'v_tarot_merchant'},
      {id = 'v_tarot_tycoon'}
    },
    deck = {
        type = 'Challenge Deck'
    }
    
  }


  SMODS.Challenge {

    key = "moment_omori",
    loc_txt = {name = 'Memento Mori'},
    unlocked = function(self)
    return(

    G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[('c_korczak_paladin')]
    
    or(

    G.P_CENTERS['j_korczak_exhibit'].discovered
    and
    G.P_CENTERS['j_korczak_painter'].discovered


    )

    )
    end 
    ,
        rules = {
        custom = {
          {id = "moment_omori"},
          {id = "no_interest"},
          {id = "no_extra_hand_money"},
        },
        modifiers = {
        }
    },
    restrictions = {
      banned_cards =  {

        {id = 'p_standard_normal_1', ids = {'p_standard_normal_1', 'p_standard_normal_2', 'p_standard_normal_3', 'p_standard_normal_4', 'p_standard_jumbo_1', 'p_standard_mega_1', 'p_standard_jumbo_2', 'p_standard_mega_2'}},
        {id = 'v_illusion'},
        {id = 'v_seed_money'},
        {id = 'v_money_tree'},
        {id = 'c_lovers'},
        {id = 'c_hermit'},
        {id = 'c_temperance'},
        {id = 'c_fool'},

        
        {id = 'j_certificate'},
        {id = 'c_medium'},

        
        {id='c_familiar'},
        {id='c_grim'},
        {id='c_immolate'},
        {id='c_incantation'},
        {id='c_ankh'},

        {id='j_credit_card'},
        {id='j_8_ball'},
        {id='j_delayed_grat'},
        {id='j_business'},
        {id='j_egg'},
        {id='j_faceless'},
        {id='j_superposition'},
        {id='j_todo_list'},
        {id='j_hologram'},
        {id='j_vagabond'},
        {id='j_cloud_9'},
        {id='j_rocket'},
        {id='j_midas_mask'},
        {id='j_gift'},
        {id='j_reserved_parking'},
        {id='j_mail'},
        {id='j_to_the_moon'},
        {id='j_hallucination'},
        {id='j_golden'},
        {id='j_trading'},
        {id='j_ticket'},
        {id='j_smeared'},
        {id='j_rough_gem'},
        {id='j_ring_master'},
        {id='j_blueprint'},
        {id='j_matador'},
        {id='j_invisible'},
        {id='j_brainstorm'},
        {id='j_satellite'},
        {id='j_cartomancer'},
        {id='j_astronomer'},
        {id='j_korczak_treasure_hunter'},
        {id='j_korczak_comic_book'},
        {id='j_korczak_buffer'},
        {id='j_korczak_paladin'},
        {id='j_korczak_shopkeep'},
        {id='j_korczak_ace_up_your_sleeve'},
      },
      banned_tags = {
        {id = "tag_standard"},
        {id = "tag_economy"},
        {id = "tag_investment"},
        {id = "tag_skip"},
        {id = "tag_garbage"},
        {id = "tag_handy"}
      },
      banned_other = {
        {id = 'bl_ox', type = 'blind'},
        {id = 'bl_tooth', type = 'blind'},
      }
    },
    jokers = {
      {id = 'j_korczak_exhibit', eternal = true},
      {id = 'j_korczak_painter', eternal = true},
      {id = 'j_mr_bones'}
    },
    vouchers = {
    },
    deck = {
        type = 'Challenge Deck'
    }
    
  }

  
  
  get_animation_quip = function()

    local quips =
    {
      "Storyboarding",
      "Licensing",
      "Royalties",
      "Voice Acting",
      "Visual Effects",
      "Animating",
      "Sound Design",
      "Concept Art",
      "Character Design",
      "Inbetweening",
      "Post Production",
      "Visual Effects",
      "Cleanup",
      "Rendering",
      "Management",
      "Marketing",
      "Software",
      "CEO's Paycheck"
    }

    return(pseudorandom_element(quips, pseudoseed('animation_funny_haha')))


  end
  
  
  SMODS.Challenge {

    key = "animation",
    loc_txt = {name = 'The Hollywood Machine'},
    unlocked = function(self)
    return(

    G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[('c_korczak_moment_omori')]

    or(

    G.P_CENTERS['j_korczak_animation'].discovered

    )

    )
    end 
    ,
        rules = {
        custom = {
          {id = "jimbo_debt", value = 20},
          {id = "no_planets"},
        },
        modifiers = {
          {id = 'dollars', value = 25}
        }
    },
    restrictions = {
      banned_cards =  {
        {id = 'c_hermit'},
        {id = 'c_temperance'},
        {id = 'c_wheel_of_fortune'},
        {id = 'c_hex'},
        {id = 'c_immolate'},

        {id = 'c_deja_vu'},
        {id = 'c_high_priestess'},
        {id = 'c_trance'},
        {id = 'v_illusion'},
        {id = 'v_seed_money'},
        {id = 'v_money_tree'},
        {id = 'v_telescope'},
        {id = 'v_observatory'},
        {id='j_joker'},
        {id='j_jolly'},
        {id='j_zany'},
        {id='j_mad'},
        {id='j_crazy'},
        {id='j_droll'},
        {id='j_sly'},
        {id='j_wily'},
        {id='j_clever'},
        {id='j_devious'},
        {id='j_crafty'},
        {id='j_half'},
        {id='j_stencil'},
        {id='j_ceremonial'},
        {id='j_banner'},
        {id='j_mystic_summit'},
        {id='j_loyalty_card'},
        {id='j_misprint'},
        {id='j_raised_fist'},
        {id='j_steel_joker'},
        {id='j_abstract'},
        {id='j_hack'},
        {id='j_gros_michel'},
        {id='j_supernova'},
        {id='j_ride_the_bus'},
        {id='j_blackboard'},
        {id='j_runner'},
        {id='j_ice_cream'},
        {id='j_blue_joker'},
        {id='j_constellation'},
        {id='j_green_joker'},
        {id='j_cavendish'},
        {id='j_card_sharp'},
        {id='j_red_card'},
        {id='j_madness'},
        {id='j_square'},
        {id='j_vampire'},
        {id='j_hologram'},
        {id='j_baron'},
        {id='j_obelisk'},
        {id='j_erosion'},
        {id='j_fortune_teller'},
        {id='j_stone'},
        {id='j_lucky_cat'},
        {id='j_baseball'},
        {id='j_bull'},
        {id='j_flash'},
        {id='j_popcorn'},
        {id='j_trousers'},
        {id='j_ramen'},
        {id='j_selzer'},
        {id='j_castle'},
        {id='j_campfire'},
        {id='j_ticket'},
        {id='j_acrobat'},
        {id='j_sock_and_buskin'},
        {id='j_swashbuckler'},
        {id='j_certificate'},
        {id='j_throwback'},
        {id='j_hanging_chad'},
        {id='j_glass'},
        {id='j_flower_pot'},
        {id='j_wee'},
        {id='j_seeing_double'},
        {id='j_hit_the_road'},
        {id='j_duo'},
        {id='j_trio'},
        {id='j_family'},
        {id='j_order'},
        {id='j_tribe'},
        {id='j_stuntman'},
        {id='j_shoot_the_moon'},
        {id='j_drivers_license'},
        {id='j_bootstraps'},
        {id='j_caino'},
        {id='j_yorick'},
        {id='j_korczak_grease_monkey'},
        {id='j_korczak_exhibit'},
        {id='j_astronomer'},
        {id='j_korczak_game_piece'},
        {id='j_korczak_mecha_joker'},
        {id='j_korczak_alley_warrior'},
        {id='j_korczak_capricorn'},
        {id='j_korczak_pepperoni'},
        {id='j_korczak_web_search'},
        {id='j_korczak_encounter'},
        {id='j_korczak_x_marks_the_joke'},
        {id='j_korczak_blackjack'},
        {id='j_korczak_ceo'},
        {id='j_korczak_d20'},
        {id='j_korczak_space_dog'},
        {id='j_korczak_jumpsuit_red'},
        {id = 'p_celestial_normal_1', ids = {'p_celestial_normal_1', 'p_celestial_normal_2', 'p_celestial_normal_3', 'p_celestial_normal_4', 'p_celestial_mega_1', 'p_celestial_mega_2', 'p_celestial_jumbo_1', 'p_celestial_jumbo_2'}}
      },

      
      banned_tags = {
        {id = "tag_orbital"},
        {id = "tag_meteor"},
        {id = "tag_economy"},
        {id = "tag_investment"},
        {id = "tag_skip"},
        {id = "tag_foil"},
        {id = "tag_holo"},
        {id = "tag_polychrome"},
      },
      banned_other = {
        {id = 'bl_ox', type = 'blind'},
        {id = 'bl_arm', type = 'blind'},
        {id = 'bl_tooth', type = 'blind'},
      }
    },
    jokers = {
      {id = 'j_korczak_animation', eternal = true}
    },
    vouchers = {
    },
    deck = {
        type = 'Challenge Deck'
    }
    
  }

  
  SMODS.Challenge {

    key = "ceo",
    loc_txt = {name = 'A Fair Internship'},
    unlocked = function(self)
    return(

    G.PROFILES[G.SETTINGS.profile].challenge_progress.completed[('c_korczak_animation')]

    or(

    G.P_CENTERS['j_korczak_ceo'].discovered
    and
    G.P_CENTERS['j_korczak_shopkeep'].discovered


    )
    )
    end 
    ,
        rules = {
        custom = {
          {id = "ceo_rental"},
          {id = "ceo_rental_text"},
          {id = "shopkeep_negate"},
        },
        modifiers = {
          {id = 'joker_slots', value = 5}
        }
    },
    restrictions = {
      banned_cards =  {
        {id = 'j_madness'},
        {id = 'j_ceremonial'},
        {id = 'c_ectoplasm'},
        {id = 'c_ankh'},
        {id = 'v_blank'},
        {id = 'v_antimatter'},
      },
      banned_tags = {
        {id = "tag_uncommon"},
        {id = "tag_rare"},
        {id = "tag_foil"},
        {id = "tag_holo"},
        {id = "tag_polychrome"},
        {id = "tag_negative"},
      },
      banned_other = {
        {id = 'bl_final_leaf', type = 'blind'},
        {id = 'bl_tooth', type = 'blind'},
        {id = 'bl_ox', type = 'blind'}
      }
    },
    jokers = {
      {id = 'j_korczak_ceo', eternal = true},
      {id = 'j_korczak_shopkeep', eternal = true},
    },
    vouchers = {
    },
    deck = {
        type = 'Challenge Deck'
    }
    
  }


  
  



----------------------------------------------
------------MOD CODE END----------------------


  