local extension = Package:new("god")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["god"] = "神",
  ["gundam"] = "高达",
}

local godguanyu = General(extension, "godguanyu", "god", 5)
local wushen = fk.CreateFilterSkill{
  name = "wushen",
  card_filter = function(self, to_select, player)
    return player:hasSkill(self.name) and to_select.suit == Card.Heart and table.contains(player.player_cards[Player.Hand], to_select.id)
  end,
  view_as = function(self, to_select)
    local card = Fk:cloneCard("slash", Card.Heart, to_select.number)
    card.skillName = self.name
    return card
  end,
}
local wushen_targetmod = fk.CreateTargetModSkill{
  name = "#wushen_targetmod",
  anim_type = "offensive",
  distance_limit_func =  function(self, player, skill, card)
    if player:hasSkill("wushen") and skill.trueName == "slash_skill" and card.suit == Card.Heart then
      return 999
    end
    return 0
  end,
}
local wuhun = fk.CreateTriggerSkill{
  name = "wuhun",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.Damaged, fk.Death},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name, false, true) then
      if event == fk.Damaged then
        return data.from and not data.from.dead and not player.dead
      else
        local availableTargets = {}
        local n = 0
        for _, p in ipairs(player.room:getOtherPlayers(player)) do
          if p:getMark("@nightmare") > n then
            availableTargets = {}
            table.insert(availableTargets,p.id)
            n = p:getMark("@nightmare")
          elseif p:getMark("@nightmare") == n and n ~= 0 then
            table.insert(availableTargets,p.id)
          end
        end
        if #availableTargets > 0 then
          self.availableTargets = availableTargets
          return true
        end
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      room:addPlayerMark(data.from, "@nightmare", data.damage)
    else
      local p_id
      if #self.availableTargets > 1 then
        p_id = room:askForChoosePlayers(player, self.availableTargets, 1, 1, "#wuhun-choose", self.name, false)[1]
      else
        p_id = self.availableTargets[1]
      end
      local judge = {
        who = room:getPlayerById(p_id),
        reason = self.name,
        pattern = "peach,god_salvation|.",
      }
      room:judge(judge)
      if judge.card.name == "peach" or judge.card.name == "god_salvation" then return false end
      room:killPlayer({who = p_id})
    end
  end,
}
wushen:addRelatedSkill(wushen_targetmod)
godguanyu:addSkill(wushen)
godguanyu:addSkill(wuhun)
Fk:loadTranslationTable {
  ["godguanyu"] = "神关羽",
  ["wushen"] = "武神",
  [":wushen"] = "锁定技，你的<font color='red'>♥</font>手牌视为【杀】；你使用<font color='red'>♥</font>【杀】无距离限制。",
  ["wuhun"] = "武魂",
  [":wuhun"] = "锁定技，当你受到1点伤害后，伤害来源获得1枚“梦魇”；你死亡时，令“梦魇”最多的一名其他角色判定，若不为【桃】或【桃园结义】，其死亡。",
  ["@nightmare"] = "梦魇",
  ["#wuhun-choose"] = "武魂：选择一名“梦魇”最多的其他角色",

  ["$wushen1"] = "取汝狗头，犹如探囊取物！",
  ["$wushen2"] = "还不速速领死！",
  ["$wuhun1"] = "拿命来！",
  ["$wuhun2"] = "谁来与我同去？",
  ["~godguanyu"] = "",
}

local godlvmeng = General(extension, "godlvmeng", "god", 3)
local shelie = fk.CreateTriggerSkill{
  name = "shelie",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_ids = room:getNCards(5)
    local get, throw = {}, {}
    room:moveCards({
      ids = card_ids,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
    })
    table.forEach(room.players, function(p)
      room:fillAG(p, card_ids)
    end)
    while true do
      local card_suits = {}
      table.forEach(get, function(id)
        table.insert(card_suits, Fk:getCardById(id).suit)
      end)
      for i = #card_ids, 1, -1 do
        local id = card_ids[i]
        if table.contains(card_suits, Fk:getCardById(id).suit) then
          room:takeAG(player, id)
          table.insert(throw, id)
          table.removeOne(card_ids, id)
        end
      end
      if #card_ids == 0 then break end
      local card_id = room:askForAG(player, card_ids, false, self.name)
      room:takeAG(player, card_id)
      table.insert(get, card_id)
      table.removeOne(card_ids, card_id)
      if #card_ids == 0 then break end
    end
    room:closeAG()
    if #get > 0 then
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(get)
      room:obtainCard(player.id, dummy, true, fk.ReasonPrey)
    end
    if #throw > 0 then
      room:moveCards({
        ids = throw,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
      })
    end
    return true
  end,
}
local gongxin = fk.CreateActiveSkill{
  name = "gongxin",
  anim_type = "control",
  target_num = 1,
  card_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function()
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = target.player_cards[Player.Hand]
    local hearts = table.filter(cards, function (id) return Fk:getCardById(id).suit == Card.Heart end)
    room:fillAG(player, cards)
    for i = #cards, 1, -1 do
      if Fk:getCardById(cards[i]).suit ~= Card.Heart then
          room:takeAG(player, cards[i], room.players)
      end
    end
    if #hearts == 0 then
      room:delay(3000)
      room:closeAG(player)
      return
    end
    local id = room:askForAG(player, hearts, true, self.name)
    room:closeAG(player)
    if id then
      local choice = room:askForChoice(player, {"gongxin_discard", "gongxin_put", "Cancel"}, self.name)
      if choice == "gongxin_discard" then
        room:throwCard({id}, self.name, target, player)
      elseif choice == "gongxin_put" then
        room:moveCardTo({id}, Card.DrawPile, nil, fk.ReasonPut, self.name, nil, false)
      end
    end
  end,
}
godlvmeng:addSkill(gongxin)
godlvmeng:addSkill(shelie)
Fk:loadTranslationTable{
  ["godlvmeng"] = "神吕蒙",
  ["shelie"] = "涉猎",
  [":shelie"] = "摸牌阶段，你可以改为亮出牌堆顶五张牌，获得不同花色的牌各一张。",
  ["gongxin"] = "攻心",
  [":gongxin"] = "出牌阶段限一次，你可以观看一名其他角色的手牌并可以展示其中的一张♥牌，选择：1. 弃置此牌；2. 将此牌置于牌堆顶。",
  ["gongxin_discard"] = "弃置此牌",
  ["gongxin_put"] = "将此牌置于牌堆顶",

  ["$shelie1"] = "什么都略懂一点，生活更多彩一些。",
  ["$shelie2"] = "略懂，略懂。",
  ["$gongxin1"] = "攻城为下，攻心为上。",
  ["$gongxin2"] = "我替施主把把脉。",
  ["~godlvmeng"] = "劫数难逃，我们别无选择……",
}

local godzhouyu = General(extension, "godzhouyu", "god", 4)
local qinyin = fk.CreateTriggerSkill{
  name = "qinyin",
  anim_type = "control",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Discard and player:getMark("qinyin-phase") > 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"loseHp"}
    if not table.every(room.alive_players, function (p) return not p:isWounded() end) then
      table.insert(choices, 1, "recover")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "recover" then
      for _, p in ipairs(room:getAlivePlayers()) do
        if p:isWounded() then
          room:recover{
            who = p,
            num = 1,
            recoverBy = player,
            skillName = self.name
          }
        end
      end
    else
      for _, p in ipairs(room:getAlivePlayers()) do
        if not p.dead then room:loseHp(p, 1, self.name) end
      end
    end
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player.phase == Player.Discard
  end,
  on_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            player.room:addPlayerMark(player, "qinyin-phase", 1)
          end
        end
      end
    end
  end,
}
local yeyan = fk.CreateActiveSkill{
  name = "yeyan",
  anim_type = "offensive",
  min_target_num = 1,
  max_target_num = 3,
  min_card_num = 0,
  max_card_num = 4,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = function(self, to_select, selected)
    if Fk:currentRoom():getCardArea(to_select) == Player.Equip then return end
    if #selected == 0 then
      return true
    else
      return table.every(selected, function (id) return Fk:getCardById(to_select).suit ~= Fk:getCardById(id).suit end)
    end
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected_cards == 4 then
      return #selected < 2
    elseif #selected_cards == 0 then
      return #selected < 3
    else
      return false
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if #effect.cards == 0 then
      for _, id in ipairs(effect.tos) do
        room:damage{
          from = player,
          to = room:getPlayerById(id),
          damage = 1,
          damageType = fk.FireDamage,
          skillName = self.name,
        }
      end
    else
      room:throwCard(effect.cards, self.name, player, player)
      if #effect.tos == 1 then
        local choice = room:askForChoice(player, {"3", "2"}, self.name)
        room:loseHp(player, 3, self.name)
        room:damage{
          from = player,
          to = room:getPlayerById(effect.tos[1]),
          damage = tonumber(choice),
          damageType = fk.FireDamage,
          skillName = self.name,
        }
      else
        local target1 = room:getPlayerById(effect.tos[1])
        local target2 = room:getPlayerById(effect.tos[2])
        local to = room:askForChoosePlayers(player, effect.tos, 1, 1, "#yeyan-choose:::".."1", self.name, false)
        room:addPlayerMark(room:getPlayerById(to[1]), self.name, 1)
        to = room:askForChoosePlayers(player, effect.tos, 1, 1, "#yeyan-choose:::".."2", self.name, false)
        room:addPlayerMark(room:getPlayerById(to[1]), self.name, 1)
        if target1:getMark(self.name) > 0 and target2:getMark(self.name) > 0 then
          to = room:askForChoosePlayers(player, effect.tos, 1, 1, "#yeyan-choose:::".."3", self.name, false)
          room:addPlayerMark(room:getPlayerById(to[1]), self.name, 1)
        end
        for _, p in ipairs({target1, target2}) do
          if p:getMark(self.name) == 0 then
            room:addPlayerMark(p, self.name, 1)
          end
        end
        room:loseHp(player, 3, self.name)
        for _, p in ipairs({target1, target2}) do
          room:damage{
            from = player,
            to = p,
            damage = p:getMark(self.name),
            damageType = fk.FireDamage,
            skillName = self.name,
          }
          room:setPlayerMark(p, self.name, 0)
        end
      end
    end
  end,
}
godzhouyu:addSkill(qinyin)
godzhouyu:addSkill(yeyan)
Fk:loadTranslationTable{
  ["godzhouyu"] = "神周瑜",
  ["qinyin"] = "琴音",
  [":qinyin"] = "弃牌阶段结束时，若你此阶段弃置过至少两张手牌，你可以选择：1. 令所有角色各回复1点体力；2. 令所有角色各失去1点体力。",
  ["yeyan"] = "业炎",
  [":yeyan"] = "限定技，出牌阶段，你可以指定一至三名角色，你分别对这些角色造成至多共计3点火焰伤害；若你对一名角色分配2点或更多的火焰伤害，你须先弃置四张不同花色的手牌并失去3点体力。",
  ["#yeyan-choose"] = "业炎：选择第%arg点伤害的目标",

  ["$qinyin1"] = "（急促的琴声、燃烧声）",
  ["$qinyin2"] = "（舒缓的琴声）",
  ["$yeyan1"] = "（燃烧声）聆听吧，这献给你的镇魂曲！",
  ["$yeyan2"] = "（燃烧声）让这熊熊业火，焚尽你的罪恶！",
  ["~godzhouyu"] = "逝者不死，浴火重生。",
}

local godzhugeliang = General(extension, "godzhugeliang", "god", 3)
local qixing = fk.CreateTriggerSkill{
  name = "qixing",
  events = {fk.GameStart, fk.EventPhaseEnd},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    return event == fk.GameStart or (target == player and player.phase == Player.Draw and #player:getPile("star") > 0)
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.GameStart then return true 
    else return player.room:askForSkillInvoke(player, self.name, data) end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(room:getNCards(7))
      player:addToPile("star", dummy, false, self.name)
    end
    local cids = room:askForExchange(player, {player:getPile("star"), player:getCardIds(Player.Hand)}, {"star", "$Hand"}, self.name)
    room:moveCards(
      {
      ids = cids[2],
        from = player.id,
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
        skillName = self.name,
      },
      {
      ids = cids[1],
        from = player.id,
        to = player.id,
        toArea = Card.PlayerSpecial,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
        specialName = "star",
        skillName = self.name,
      }
    )
  end,
}
local kuangfeng = fk.CreateTriggerSkill{
  name = "kuangfeng",
  events = {fk.EventPhaseStart, fk.DamageInflicted},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if event == fk.EventPhaseStart then
      return target == player and player.phase == Player.Finish and #player:getPile("star") > 0
    else
      return target:getMark("@@kuangfeng") > 0 and data.damageType == fk.FireDamage and player:getMark("_kuangfeng") ~= 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      local room = player.room
      local cids = room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|star", "#kuangfeng-card", "star")
      if #cids > 0 then
        local targets = room:askForChoosePlayers(player, table.map(room.alive_players, function(p) return p.id end), 1, 1, "#kuangfeng-target", self.name, false)
        self.cost_data = {targets[1], cids}
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      local room = player.room
      room:moveCardTo(self.cost_data[2], Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, "star")
      room:addPlayerMark(room:getPlayerById(self.cost_data[1]), "@@kuangfeng")
      room:setPlayerMark(player, "_kuangfeng", self.cost_data[1])
    else
      data.damage = data.damage + 1
    end
  end,

  refresh_events = {fk.EventPhaseChanging, fk.Death},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventPhaseChanging then
      return target == player and player:hasSkill(self.name, true) and data.from == Player.NotActive and player:getMark("_kuangfeng") ~= 0
    else
      return player:hasSkill(self.name, true, true)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(room:getPlayerById(player:getMark("_kuangfeng")), "@@kuangfeng")
    room:setPlayerMark(player, "_kuangfeng", 0)
  end,
}
local dawu = fk.CreateTriggerSkill{
  name = "dawu",
  anim_type = "defensive",
  events = {fk.EventPhaseStart, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if event == fk.EventPhaseStart then
      return target == player and player.phase == Player.Finish and #player:getPile("star") > 0
    else
      return target:getMark("@@dawu") > 0 and data.damageType ~= fk.ThunderDamage and player:getMark("_dawu") ~= 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      local room = player.room
      local cids = room:askForCard(player, 1, #room.alive_players, false, self.name, true, ".|.|.|star", "#dawu-card", "star")
      if #cids > 0 then
        local targets = room:askForChoosePlayers(player, table.map(room.alive_players, function(p) return p.id end), #cids, #cids, "#dawu-target:::" .. #cids, self.name, false)
        self.cost_data = {targets, cids}
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      local room = player.room
      room:moveCardTo(self.cost_data[2], Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, "star")
      table.forEach(self.cost_data[1], function(pid) 
        room:addPlayerMark(room:getPlayerById(pid), "@@dawu")
      end)
      room:setPlayerMark(player, "_dawu", self.cost_data[1])
    else
      return true
    end
  end,

  refresh_events = {fk.EventPhaseChanging, fk.Death},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventPhaseChanging then
      return target == player and player:hasSkill(self.name, true) and data.from == Player.NotActive and player:getMark("_dawu") ~= 0
    else
      return player:hasSkill(self.name, true, true)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    table.forEach(player:getMark("_dawu"), function(pid)
      room:removePlayerMark(room:getPlayerById(pid), "@@dawu")
    end)
    room:setPlayerMark(player, "_dawu", 0)
  end,
}
godzhugeliang:addSkill(qixing)
godzhugeliang:addSkill(kuangfeng)
godzhugeliang:addSkill(dawu)
Fk:loadTranslationTable{
  ["godzhugeliang"] = "神诸葛亮",
  ["qixing"] = "七星",
  [":qixing"] = "游戏开始时，你将牌堆顶的七张牌扣置于武将牌上，称为“星”，然后你可以用任意张手牌替换等量的“星”；摸牌阶段结束时，你可以用任意张手牌替换等量的“星”。",
  ["kuangfeng"] = "狂风",
  [":kuangfeng"] = "结束阶段开始时，你可以将一张“星”置入弃牌堆并选择一名角色，当其于你的下回合开始之前受到火焰伤害时，你令伤害值+1。",
  ["dawu"] = "大雾",
  [":dawu"] = "结束阶段开始时，你可以将至少一张“星”置入弃牌堆并选择等量的角色，当其于你的下回合开始之前受到不为雷电伤害的伤害时，防止此伤害。",

  ["star"] = "星",
  ["@@kuangfeng"] = "狂风",
  ["#kuangfeng-card"] = "狂风：你可以将一张“星”置入弃牌堆，点击“确认”后选择一名角色",
  ["#kuangfeng-target"] = "狂风：请选择一名角色，当其于你的下回合开始之前受到火焰伤害时，你令伤害值+1",
  ["@@dawu"] = "大雾",
  ["#dawu-card"] = "大雾：你可以将至少一张“星”置入弃牌堆，点击“确认”后选择等量的角色",
  ["#dawu-target"] = "大雾：请选择%arg名角色，当其于你的下回合开始之前受到不为雷电伤害的伤害时，防止此伤害",

  ["$qixing1"] = "祈星辰之力，佑我蜀汉！	",
  ["$qixing2"] = "伏望天恩，誓讨汉贼！",
  ["$kuangfeng1"] = "风~~起~~",
  ["$kuangfeng2"] = "万事俱备，只欠业火。",
  ["$dawu1"] = "此计可保你一时平安。",
  ["$dawu2"] = "此非万全之策，唯惧天雷。",
  ["~godzhugeliang"] = "今当远离，临表涕零，不知所言……",
}

local godlvbu = General(extension, "godlvbu", "god", 5)
local kuangbao = fk.CreateTriggerSkill{
  name = "kuangbao",
  events = {fk.GameStart, fk.Damage, fk.Damaged},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return (event == fk.GameStart or target == player) and player:hasSkill(self.name) and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@baonu", event == fk.GameStart and 2 or data.damage)
  end,
}
local wumou = fk.CreateTriggerSkill{
  name = "wumou",
  anim_type = "negative",
  events = {fk.CardUsing},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card:isCommonTrick()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"loseHp"}
    if player:getMark("@baonu") > 0 then table.insert(choices, "wumouBaonu") end
    if room:askForChoice(player, choices, self.name) == "loseHp" then
      room:loseHp(player, 1, self.name)
    else
      room:removePlayerMark(player, "@baonu", 1)
    end
  end,
}
local wuqian = fk.CreateActiveSkill{
  name = "wuqian",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:getMark("@baonu") > 1
  end,
  card_num = 0,
  target_num = 1,
  target_filter = function(self, to_select, selected)
    return #selected < 1 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):getMark("@@wuqian-turn") == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:removePlayerMark(player, "@baonu", 2)
    room:addPlayerMark(target, "@@wuqian-turn")
    room:handleAddLoseSkills(player, "wushuang", nil, true, false)
    room:addPlayerMark(target, fk.MarkArmorNullified)
  end
}
local wuqianCleaner = fk.CreateTriggerSkill{
  name = "#wuqianCleaner",
  mute = true,
  refresh_events = {fk.TurnEnd},
  can_refresh = function(_, _, target, player)
    return target == player and target:usedSkillTimes("wuqian") > 0
  end,
  on_refresh = function(_, _, target)
    local room = target.room
    room:handleAddLoseSkills(target, "-wushuang", nil, true, false)
    table.forEach(room.alive_players, function(p)
      if p:getMark("@@wuqian-turn") > 0 then room:removePlayerMark(p, fk.MarkArmorNullified) end
    end)
  end,
}
wuqian:addRelatedSkill(wuqianCleaner)
local shenfen = fk.CreateActiveSkill{
  name = "shenfen",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player:getMark("@baonu") > 5
  end,
  card_num = 0,
  target_num = 0,
  card_filter = function(self, to_select, selected)
    return false
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:removePlayerMark(player, "@baonu", 6)
    local targets = room:getOtherPlayers(player, true)
    table.forEach(targets, function(p)
      if not p.dead then room:damage{ from = player, to = p, damage = 1, skillName = self.name } end
    end)
    table.forEach(targets, function(p)
      if not p.dead then p:throwAllCards("e") end
    end)
    table.forEach(targets, function(p)
      if not p.dead then
        local canDiscards = table.filter(
          p:getCardIds{ Player.Hand }, function(id)
            local card = Fk:getCardById(id)
            local status_skills = room.status_skills[ProhibitSkill] or {}
            for _, skill in ipairs(status_skills) do
              if skill:prohibitDiscard(p, card) then
                return false
              end
            end
            return true
          end
        )
        if #canDiscards <= 4 then
          room:throwCard(canDiscards, self.name, p, p)
        else
          room:askForDiscard(p, 4, 4, false, self.name, false)
        end
      end
    end)
    if not player.dead then player:turnOver() end
  end
}
godlvbu:addSkill(kuangbao)
godlvbu:addSkill(wumou)
godlvbu:addSkill(wuqian)
godlvbu:addSkill(shenfen)
godlvbu:addRelatedSkill("wushuang")
Fk:loadTranslationTable{
  ["godlvbu"] = "神吕布",
  ["kuangbao"] = "狂暴",
  [":kuangbao"] = "锁定技，游戏开始时，你获得2枚“暴怒”；当你造成或受到1点伤害后，你获得1枚“暴怒”。",
  ["wumou"] = "无谋",
  [":wumou"] = "锁定技，当你使用普通锦囊牌时，你选择：1.弃1枚“暴怒”；2.失去1点体力。",
  ["wuqian"] = "无前",
  [":wuqian"] = "出牌阶段，你可以弃2枚“暴怒”并选择一名此回合内未以此法选择过的其他角色，你于此回合内拥有〖无双〗且其防具技能于此回合内无效。",
  ["shenfen"] = "神愤",
  [":shenfen"] = "出牌阶段限一次，你可以弃6枚“暴怒”并选择所有其他角色，对这些角色各造成1点伤害，然后这些角色各弃置其装备区里的所有牌，各弃置四张手牌，最后你翻面。",

  ["@baonu"] = "暴怒",
  ["wumouBaonu"] = "弃1枚“暴怒”",
  ["@@wuqian-turn"] = "无前",
  ["#wuqianCleaner"] = "无前",

  ["$kuangbao1"] = "嗯→↗↑↑↑↓……",
  ["$kuangbao2"] = "哼！",
  ["$wumou1"] = "哪个说我有勇无谋？!",
  ["$wumou2"] = "不管这些了！",
  ["$wuqian1"] = "看我神威，无坚不摧！",
  ["$wuqian2"] = "天王老子也保不住你！",
  ["$shenfen1"] = "凡人们，颤抖吧！这是神之怒火！	",
  ["$shenfen2"] = "这，才是活生生的地狱！",
  ["~godlvbu"] = "我在修罗炼狱，等着你们，呃哈哈哈哈哈~",
}

local godcaocao = General(extension, "godcaocao", "god", 3)
local guixin = fk.CreateTriggerSkill{
  name = "guixin",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if self.cancel_cost or table.every(player.room:getOtherPlayers(player), function (p) return p:isAllNude() end) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, data) then
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, true)) do
      if not p:isAllNude() then
        local id = room:askForCardChosen(player, p, "hej", self.name)
        room:obtainCard(player, id, false, fk.ReasonPrey)
      end
    end
    player:turnOver()
  end,
}
local feiying = fk.CreateDistanceSkill{
  name = "feiying",
  correct_func = function(self, from, to)
    if to:hasSkill(self.name) then
      return 1
    end
    return 0
  end,
}
godcaocao:addSkill(guixin)
godcaocao:addSkill(feiying)
Fk:loadTranslationTable{
  ["godcaocao"] = "神曹操",
  ["guixin"] = "归心",
  [":guixin"] = "当你受到1点伤害后，你可获得所有其他角色区域中的一张牌，然后你翻面。",
  ["feiying"] = "飞影",
  [":feiying"] = "锁定技，其他角色至你距离+1。",

  ["$guixin1"] = "周公吐哺，天下归心！",
  ["$guixin2"] = "山不厌高，海不厌深！",
  ["~godcaocao"] = "腾蛇乘雾，终为土灰。",
}

local godzhaoyun = General(extension, "godzhaoyun", "god", 2)
local juejing = fk.CreateTriggerSkill{
  name = "juejing",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + player:getLostHp()
  end,
}
local juejing_maxcards = fk.CreateMaxCardsSkill{
  name = "#juejing_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(juejing.name) then
      return 2
    end
  end
}
local juejing_maxcards_audio = fk.CreateTriggerSkill{
  name = "#juejing_maxcards_audio",
  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill(juejing.name) and player.phase == Player.Discard
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:broadcastSkillInvoke(juejing.name)
    player.room:notifySkillInvoked(player, juejing.name, "special")
  end,
}
juejing:addRelatedSkill(juejing_maxcards)
juejing:addRelatedSkill(juejing_maxcards_audio)

local longhun = fk.CreateViewAsSkill{
  name = "longhun",
  pattern = "peach,slash,jink,nullification",
  card_filter = function(self, to_select, selected)
    if #selected == 2 then
      return false
    elseif #selected == 1 then
      if math.max(Self.hp, 1) == 1 then return false end
      return Fk:getCardById(to_select):compareSuitWith(Fk:getCardById(selected[1]))
    else
      local suit = Fk:getCardById(to_select).suit
      local c
      if suit == Card.Heart then
        c = Fk:cloneCard("peach")
      elseif suit == Card.Diamond then
        c = Fk:cloneCard("fire__slash")
      elseif suit == Card.Club then
        c = Fk:cloneCard("jink")
      elseif suit == Card.Spade then
        c = Fk:cloneCard("nullification")
      else
        return false
      end
      return (Fk.currentResponsePattern == nil and c.skill:canUse(Self)) or (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
    end
  end,
  view_as = function(self, cards)
    if #cards ~= math.max(Self.hp, 1) then
      return nil
    end
    local suit = Fk:getCardById(cards[1]).suit
    local c
    if suit == Card.Heart then
      c = Fk:cloneCard("peach")
    elseif suit == Card.Diamond then
      c = Fk:cloneCard("fire__slash")
    elseif suit == Card.Club then
      c = Fk:cloneCard("jink")
    elseif suit == Card.Spade then
      c = Fk:cloneCard("nullification")
    else
      return nil
    end
    c.skillName = self.name
    c:addSubcards(cards)
    return c
  end,
}

godzhaoyun:addSkill(juejing)
godzhaoyun:addSkill(longhun)

Fk:loadTranslationTable{
  ["godzhaoyun"] = "神赵云",
  ["juejing"] = "绝境",
  [":juejing"] = "锁定技，摸牌阶段，你令额定摸牌数+X（X为你已损失的体力值）；你的手牌上限+2。",
  ["longhun"] = "龙魂",
  [":longhun"] = "你可以将X张你的花色相同的牌按以下规则使用或打出：红桃当【桃】，方块当火【杀】，梅花当【闪】，黑桃当【无懈可击】（X为你的体力值且至少为1）。",

  ["$juejing1"] = "背水一战，不胜便死！",
  ["$juejing2"] = "置于死地，方能后生！",
  ["$longhun1"] = "常山赵子龙在此！",
  ["$longhun2"] = "能屈能伸，才是大丈夫！",
  ["~godzhaoyun"] = "龙身虽死，魂魄不灭！",
}

local gundam = General(extension, "gundam__godzhaoyun", "god", 1)
gundam.total_hidden = true
Fk:loadTranslationTable{
  ["gundam__godzhaoyun"] = "高达一号",
  ["gundam__juejing"] = "绝境",
  [":gundam__juejing"] = "锁定技，你跳过摸牌阶段；当你的手牌数大于4/小于4时，你将手牌弃置至4/摸至4张。",
  ["gundam__longhun"] = "龙魂",
  [":gundam__longhun"] = "你可以将你的牌按以下规则使用或打出：红桃当【桃】，方块当火【杀】，梅花当【闪】，黑桃当【无懈可击】。",
  ["gundam__zhanjiang"] = "斩将",
  [":gundam__zhanjiang"] = "准备阶段开始时，如果场上有【青釭剑】，你可以获得之。",
}

local goddiaochan = General(extension, "goddiaochan", "god", 3, 3, General.Female)
local meihun = fk.CreateTriggerSkill{
  name = "meihun",
  anim_type = "control",
  mute = true,
  events = {fk.EventPhaseStart, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name)) then return end
    if event == fk.EventPhaseStart then
      return player.phase == Player.Finish
    elseif event == fk.TargetConfirmed then
      return data.card.trueName == "slash"
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p:isNude() then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end

    local p = room:askForChoosePlayers(player, targets, 1, 1,
      "#meihun-choose", self.name, true)

    if p[1] then
      self.cost_data = p[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name)
    if event == fk.TargetConfirmed then
      room:broadcastSkillInvoke(self.name, math.random(1, 2))
    else
      room:broadcastSkillInvoke(self.name, math.random(3, 4))
    end

    local choice = room:askForChoice(player,
      {"spade", "heart", "club", "diamond"}, self.name)

    local to = room:getPlayerById(self.cost_data)
    local c = table.find(to:getCardIds{ Player.Hand, Player.Equip }, function(id)
      return Fk:getCardById(id):getSuitString() == choice
    end)

    if c then
      local card = room:askForCard(to, 1, 1, true, self.name, false,
        ".|.|" .. choice, "#meihun-give:" .. player.id .. "::" .. choice)

      room:obtainCard(player, card[1], false, fk.ReasonGive)
    else
      local cids = to:getCardIds(Player.Hand)
      if #cids == 0 then return end
      room:fillAG(player, cids)

      local id = room:askForAG(player, cids, false, self.name)
      room:closeAG(player)

      if not id then return false end
      room:throwCard(id, self.name, to, player)
    end
  end,
}
local huoxinTrig = fk.CreateTriggerSkill{
  name = "#huoxin_trig",
  mute = true,
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and
      target:getMark("@huoxin-meihuo") >= 2 and target.faceup
  end,
  on_cost = function() return true end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:broadcastSkillInvoke("huoxin")
    room:notifySkillInvoked(player, "huoxin")

    room:setPlayerMark(target, "@huoxin-meihuo", 0)
    room:addPlayerMark(target, "huoxincontrolled", 1)

    player:control(target)
  end,

  refresh_events = {fk.TurnEnd},
  can_refresh = function(_, _, target, player)
    return target == player and target:getMark("huoxincontrolled") > 0
  end,
  on_refresh = function(_, _, target)
    local room = target.room
    room:setPlayerMark(target, "huoxincontrolled", 0)
    target:control(target)
  end,
}
local huoxin = fk.CreateActiveSkill{
  name = "huoxin",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_num = 2,
  target_num = 2,
  target_filter = function(self, to_select, selected)
    return #selected < 2 and to_select ~= Self.id
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 1 then 
      return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and
        Fk:getCardById(to_select).suit == Fk:getCardById(selected[1]).suit

    elseif #selected == 2 then
      return false
    end

    return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local tos = effect.tos
    local target1 = room:getPlayerById(tos[1])
    local target2 = room:getPlayerById(tos[2])
    local cards = effect.cards
    local cpattern = ".|.|.|.|.|.|" .. table.concat(cards, ",")

    from:showCards(cards)

    local p, cid = room:askForChooseCardAndPlayers(from, tos, 1, 1, cpattern,
      "#huoxin-choose", self.name, false)

    table.removeOne(cards, cid)

    if p[1] == target1.id then
      room:obtainCard(target1, cid, true, fk.ReasonGive)
      room:obtainCard(target2, cards[1], true, fk.ReasonGive)
    else
      room:obtainCard(target2, cid, true, fk.ReasonGive)
      room:obtainCard(target1, cards[1], true, fk.ReasonGive)
    end

    local pindianData = target1:pindian({ target2 }, self.name)
    local winner = pindianData.results[target2.id].winner
    if winner ~= target1 then
      room:addPlayerMark(target1, "@huoxin-meihuo", 1)
    end
    if winner ~= target2 then
      room:addPlayerMark(target2, "@huoxin-meihuo", 1)
    end
  end
}
huoxin:addRelatedSkill(huoxinTrig)
goddiaochan:addSkill(meihun)
goddiaochan:addSkill(huoxin)
Fk:loadTranslationTable{
  ["goddiaochan"] = "神貂蝉",
  ["meihun"] = "魅魂",
  [":meihun"] = "结束阶段或当你成为【杀】目标后，你可以令一名其他角色" ..
    "交给你一张你声明的花色的牌，若其没有则你观看其手牌然后弃置其中一张。",
  ["#meihun-choose"] = "魅魂：你可以对一名其他角色发动“魅魂”",
  ["#meihun-give"] = "魅魂：请交给 %src 一张 %arg 牌",

  ["huoxin"] = "惑心",
  [":huoxin"] = "出牌阶段限一次，你可以展示两张花色相同的手牌并分别交给两名" ..
    "其他角色，然后令这两名角色拼点，没赢的角色获得1个“魅惑”标记。拥有2个或" ..
    "更多“魅惑”的角色回合即将开始时，该角色移去其所有“魅惑”，" ..
    "此回合改为由你操控。",
  ["@huoxin-meihuo"] = "魅惑",
  ["#huoxin-choose"] = "惑心：请将一张牌交给其中一名角色，另一张牌自动交给另一名",
  ["#huoxin-pindian"] = "惑心：请选择拼点牌，拼点没赢会获得1枚魅惑标记",
  ["#huoxin_trig"] = "惑心",

  -- CV: 桃妮儿
  ["cv:goddiaochan"] = "桃妮儿",
  ["~goddiaochan"] = "也许，你们日后的所闻所望，都是我某天的所叹所想…",
  ["$meihun1"] = "将军还记得那晚的话么？弄疼人家，要赔不是哦~",
  ["$meihun2"] = "让我看看，将军这次会为我心软，还是耳根子软~",
  ["$meihun3"] = "眼前皆是身外物，将军所在，即吾心归处…",
  ["$meihun4"] = "既然你说我是魔鬼中的天使，那我就再任性一次~",
  ["$huoxin1"] = "今天下大乱，就不能摒弃儿女私情，挺身而出吗！",
  ["$huoxin2"] = "谁怜九州难救天下人，我有一心只付将军身…",
}

return extension
