local extension = Package:new("god")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["god"] = "神",
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
        room:moveCards({
          ids = {id},
          from = target.id,
          toArea = Card.DrawPile,
          moveReason = fk.ReasonPut,
          proposer = player.id,
          skillName = self.name,
        })
        table.insert(room.draw_pile, 1, id)
        table.remove(room.draw_pile, #room.draw_pile)  --FIXME
      end
    end
  end,
}
godlvmeng:addSkill(gongxin)
godlvmeng:addSkill(shelie)
Fk:loadTranslationTable{
  ["godlvmeng"] = "神吕蒙",
  ["shelie"] = "涉猎",
  [":shelie"] = "摸牌阶段，你可以放弃摸牌，改为从牌堆顶亮出五张牌，你获得不同花色的牌各一张，将其余的牌置入弃牌堆。",
  ["gongxin"] = "攻心",
  [":gongxin"] = "出牌阶段限一次，你可以观看一名其他角色的手牌，并可以展示其中的一张♥牌，将其弃置或置于牌堆顶。",
  ["gongxin_discard"] = "弃置此牌",
  ["gongxin_put"] = "将此牌置于牌堆顶",
}

local godzhouyu = General(extension, "godzhouyu", "god", 4)
local qinyin = fk.CreateTriggerSkill{
  name = "qinyin",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player.phase == Player.Discard then
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard then
          player.room:addPlayerMark(player, "qinyin-phase", #move.moveInfo)
        end
      end
      if player:getMark("qinyin-phase") > 1 then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"loseHp"}
    if not table.every(room:getAlivePlayers(), function (p) return not p:isWounded() end) then
      table.insert(choices, 1, "recover")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "recover" then
      for _, p in ipairs(room:getAlivePlayers(true)) do
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
      for _, p in ipairs(room:getAlivePlayers(true)) do
        room:loseHp(p, 1, self.name)
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
  [":qinyin"] = "弃牌阶段，当你弃置了两张或更多的手牌时，你可以令所有角色各回复1点体力或各失去1点体力。",
  ["yeyan"] = "业炎",
  [":yeyan"] = "限定技，出牌阶段，你可以指定一至三名角色，你分别对这些角色造成至多共计3点火焰伤害；若你对一名角色分配2点或更多的火焰伤害，你须先弃置四张不同花色的手牌并失去3点体力。",
  ["#yeyan-choose"] = "业炎：选择第%arg点伤害的目标",
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
  [":guixin"] = "每当你受到1点伤害后，可分别从每名其他角色的区域获得一张牌，然后将你的武将牌翻面。",
  ["feiying"] = "飞影",
  [":feiying"] = "锁定技，其他角色计算与你的距离时始终+1。",
}

return extension
