local extension = Package:new("shadow")
extension.extensionName = "shzl"
Fk:loadTranslationTable{
  ["shadow"] = "阴",
}

local xuyou = General(extension, "xuyou", "qun", 3)
Fk:loadTranslationTable{
  ["xuyou"] = "许攸",
  ["~xuyou"] = "阿瞒，没有我你得不到冀州啊！",
}

local chenglve = fk.CreateActiveSkill{
  name = "chenglve",
  anim_type = "switch",
  switch_skill_name = "chenglve",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return false
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local isYang = from:getSwitchSkillState(self.name, true) == fk.SwitchYang

    from:drawCards(isYang and 1 or 2, self.name)
    local discardNum = isYang and 2 or 1
    local cardsDiscarded = table.filter(room:askForDiscard(from, discardNum, discardNum, false, self.name, true), function(id)
      return Fk:getCardById(id).suit < Card.NoSuit
    end)

    if #cardsDiscarded > 0 then
      local suitsToRecord = table.map(cardsDiscarded, function(id)
        return "log_" .. Fk:getCardById(id):getSuitString()
      end)

      local suitsRecorded = type(from:getMark("@chenglve")) == "table" and from:getMark("@chenglve") or {}
      for _, suit in ipairs(suitsToRecord) do
        table.insertIfNeed(suitsRecorded, suit)
      end
      room:setPlayerMark(from, "@chenglve", suitsRecorded)
    end
  end,
}
Fk:loadTranslationTable{
  ["chenglve"] = "成略",
  [":chenglve"] = "转换技，出牌阶段限一次，阳：你可以摸一张牌，然后弃置两张手牌；阴：你可以摸两张牌，然后弃置一张手牌。若如此做，你于此阶段内使用与你以此法弃置的牌花色相同的牌无距离和次数限制。",
  ["@chenglve"] = "成略",
  ["$chenglve1"] = "成略在胸，良计速出。",
  ["$chenglve1"] = "吾有良略在怀，必为阿瞒所需。",
}

local chenglveBuff = fk.CreateTargetModSkill{
  name = "#chenglve-buff",
  residue_func = function(self, player, skill, scope, card)
    return
      (card and table.contains(type(player:getMark("@chenglve")) == "table" and player:getMark("@chenglve") or {}, "log_" .. card:getSuitString())) and
      999 or
      0
  end,
  distance_limit_func = function(self, player, skill, card)
    return
      (card and table.contains(type(player:getMark("@chenglve")) == "table" and player:getMark("@chenglve") or {}, "log_" .. card:getSuitString())) and
      999 or
      0
  end,
}
chenglve:addRelatedSkill(chenglveBuff)

local shicaiClear = fk.CreateTriggerSkill{
  name = "#shicai-clear",
  refresh_events = {fk.EventPhaseChanging},
  can_refresh = function(self, event, target, player, data)
    return target == player and data.from == Player.Play and type(player:getMark("@chenglve")) == "table"
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@chenglve", 0)
  end,
}
chenglve:addRelatedSkill(shicaiClear)

xuyou:addSkill(chenglve)

local shicai = fk.CreateTriggerSkill{
  name = "shicai",
  events = {fk.CardUseFinished, fk.TargetConfirmed},
  anim_type = "drawCard",
  can_trigger = function(self, event, target, player, data)
    if
      not (
        target == player and
        player:hasSkill(self.name) and
        (data.extra_data or {}).firstCardTypeUsed and
        player.room:getCardArea(data.card) == Card.Processing
      )
    then
      return false
    end

    if event == fk.CardUseFinished then
      return data.card:isCommonTrick() or data.card.type == Card.TypeBasic
    else
      return data.from == player.id and data.card.type == Card.TypeEquip
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local toPut = room:getSubcardsByRule(data.card, { Card.Processing })

    if #toPut > 1 then
      toPut = room:askForGuanxing(player, toPut, { #toPut, #toPut }, { 0, 0 }, "ShiCaiPut", true).top
    end

    room:moveCardTo(table.reverse(toPut), Card.DrawPile, nil, fk.ReasonPut, self.name, nil, true)
    player:drawCards(1, self.name)
  end,

  refresh_events = {fk.EventPhaseStart, fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    if target ~= player then
      return false
    end

    if event == fk.EventPhaseStart then
      return
        player.phase == Player.NotActive and
        table.find(player.room.alive_players, function(p)
          return type(p:getMark("@shicai")) == "table"
        end)
    else
      return
        player:hasSkill(self.name, true) and
        (type(player:getMark("@shicai")) ~= "table" or
        not table.contains(player:getMark("@shicai"), data.card:getTypeString() .. "_char"))
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      for _, p in ipairs(room.alive_players) do
        if type(p:getMark("@shicai")) == "table" then
          room:setPlayerMark(p, "@shicai", 0)
        end
      end
    else
      local typesRecorded = type(player:getMark("@shicai")) == "table" and player:getMark("@shicai") or {}
      table.insert(typesRecorded, data.card:getTypeString() .. "_char")
      room:setPlayerMark(player, "@shicai", typesRecorded)

      data.extra_data = data.extra_data or {}
      data.extra_data.firstCardTypeUsed = true
    end
  end,
}
Fk:loadTranslationTable{
  ["shicai"] = "恃才",
  [":shicai"] = "当你每回合首次使用一种类别的牌结算结束后，你可以将之置于牌堆顶，然后摸一张牌。",
  ["@shicai"] = "恃才",
  ["$shicai1"] = "吾才满腹，袁本初竟不从之。",
  ["$shicai1"] = "阿瞒有我良计，取冀州便是易如反掌。",
}

xuyou:addSkill(shicai)

local cunmu = fk.CreateTriggerSkill{
  name = "cunmu",
  events = {fk.BeforeDrawCard},
  anim_type = "negative",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    data.fromPlace = "bottom"
  end,
}
Fk:loadTranslationTable{
  ["cunmu"] = "寸目",
  [":cunmu"] = "锁定技，当你摸牌时，改为从牌堆底摸牌。",
  ["$cunmu1"] = "哼！目光所及，短寸之间。",
  ["$cunmu2"] = "狭目之见，只能窥底。",
}

xuyou:addSkill(cunmu)

return extension
