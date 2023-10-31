local extension = Package:new("shadow")
extension.extensionName = "shzl"
Fk:loadTranslationTable{
  ["shadow"] = "神话再临·阴",
}

local wangji = General(extension, "wangji", "wei", 3)
local qizhi = fk.CreateTriggerSkill{
  name = "qizhi",
  anim_type = "control",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase ~= Player.NotActive and
      data.firstTarget and data.card.type ~= Card.TypeEquip
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p)
      return not p:isNude() and not table.contains(AimGroup:getAllTargets(data.tos), p.id) end), Util.IdMapper)
    if #targets == 0 then return end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#qizhi-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = tos[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@qizhi-turn", 1)
    local to = room:getPlayerById(self.cost_data)
    local id = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard({id}, self.name, to, player)
    if not to.dead then
      to:drawCards(1, self.name)
    end
  end,
}
local jinqu = fk.CreateTriggerSkill{
  name = "jinqu",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
    local n = #player:getCardIds("h") - player:usedSkillTimes("qizhi", Player.HistoryTurn)
    if n > 0 then
      player.room:askForDiscard(player, n, n, false, self.name, false)
    end
  end,
}
wangji:addSkill(qizhi)
wangji:addSkill(jinqu)
Fk:loadTranslationTable{
  ["wangji"] = "王基",
  ["qizhi"] = "奇制",
  [":qizhi"] = "当你于回合内使用非装备牌指定目标后，你可以弃置一名不为目标的角色的一张牌，然后令其摸一张牌。",
  ["jinqu"] = "进趋",
  [":jinqu"] = "结束阶段，你可以摸两张牌，然后将手牌弃至X张（X为你本回合发动〖奇制〗的次数）。",
  ["@qizhi-turn"] = "奇制",
  ["#qizhi-choose"] = "奇制：你可以弃置一名角色一张牌，然后其摸一张牌",

  ["$qizhi1"] = "声东击西，敌寇一网成擒。",
  ["$qizhi2"] = "吾意不在此地，已遣别部出发。",
  ["$jinqu1"] = "建上昶水城，以逼夏口！",
  ["$jinqu2"] = "通川聚粮，伐吴之业，当步步为营。",
  ["~wangji"] = "天下之势，必归大魏，可恨，未能得见呐！",
}

Fk:loadTranslationTable{
  ["kuailiangkuaiyue"] = "蒯良蒯越",
  ["jianxiang"] = "荐降",
  [":jianxiang"] = "当你成为其他角色使用牌的目标后，你可以令手牌数最少的一名角色摸一张牌。",
  ["shenshi"] = "审时",
  [":shenshi"] = "转换技，阳：出牌阶段限一次，你可以交给手牌数最多的其他角色一张牌，并对其造成1点伤害。若其因此死亡，你可以令一名角色将手牌摸至四张。"..
  "阴：当其他角色对你造成伤害后，你可以观看其手牌，并交给其一张牌；当前回合结束阶段，若其未失去此牌，你将手牌摸至四张。",
}

local yanyan = General(extension, "yanyan", "shu", 4)
local juzhan = fk.CreateTriggerSkill{
  name = "juzhan",
  switch_skill_name = "juzhan",
  anim_type = "switch",
  events = { fk.TargetSpecified, fk.TargetConfirmed },
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name) and
      data.card.trueName == 'slash') then return end

    local isYang = player:getSwitchSkillState(self.name) == fk.SwitchYang
    if event == fk.TargetConfirmed and isYang then
      return player.id ~= data.from
    elseif event == fk.TargetSpecified and not isYang then
      return not player.room:getPlayerById(data.to):isNude()
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local isYang = player:getSwitchSkillState(self.name, true) == fk.SwitchYang
    local aim = data ---@type AimStruct

    if isYang then
      local from = room:getPlayerById(aim.from)
      player:drawCards(1, self.name)
      from:drawCards(1, self.name)
      local x = from:getMark("@@juzhan-turn")
      if x == 0 then x = {} end
      table.insert(x, player.id)
      room:setPlayerMark(from, "@@juzhan-turn", x)
    else
      local to = room:getPlayerById(aim.to)
      local from = player
      local c = room:askForCardChosen(from, to, "he", self.name)
      room:obtainCard(from, c, false)
      local x = from:getMark("@@juzhan-turn")
      if x == 0 then x = {} end
      table.insert(x, to.id)
      room:setPlayerMark(from, "@@juzhan-turn", x)
    end
  end,
}
local juzhan_prohibit = fk.CreateProhibitSkill{
  name = "#juzhan_prohibit",
  is_prohibited = function(self, from, to)
    local x = from:getMark("@@juzhan-turn")
    if x == 0 then return false end
    return table.contains(x, to.id)
  end,
}
juzhan:addRelatedSkill(juzhan_prohibit)
yanyan:addSkill(juzhan)
Fk:loadTranslationTable{
  ["yanyan"] = "严颜",
  ["juzhan"] = "拒战",
  [":juzhan"] = "转换技，阳：当你成为其他角色使用【杀】的目标后，你可以与其各摸一张牌，然后其本回合不能再对你使用牌。"..
  "阴：当你使用【杀】指定一名角色为目标后，你可以获得其一张牌，然后你本回合不能再对其使用牌。",

  ["@@juzhan-turn"] = "拒战",
  ["~yanyan"] = "宁可断头死，安能屈膝降！",
  ["$juzhan1"] = "砍头便砍头，何为怒耶！",
  ["$juzhan2"] = "我州但有断头将军，无降将军也！",
}

Fk:loadTranslationTable{
  ["wangping"] = "王平",
  ["feijun"] = "飞军",
  [":feijun"] = "出牌阶段限一次，你可以弃置一张牌，然后选择一项：1.令一名手牌数大于你的角色交给你一张牌；"..
  "2.令一名装备区里牌数大于你的角色弃置一张装备区里的牌。",
  ["binglve"] = "兵略",
  [":binglve"] = "锁定技，当你首次对一名角色发动〖飞军〗时，你摸两张牌。",
}

local luji = General(extension, "luji", "wu", 3)
local huaiju_effect = fk.CreateTriggerSkill{
  name = "#huaiju_effect",
  mute = true,
  events = {fk.DrawNCards, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@orange") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local _luji = table.find(room.alive_players, function(p)
      return p:hasSkill("huaiju")
    end)
    if _luji then
      _luji:broadcastSkillInvoke("huaiju")
      room:notifySkillInvoked(_luji, "huaiju", event == fk.DamageInflicted and "defensive" or "drawcard")
    end
    if event == fk.DamageInflicted then
      room:removePlayerMark(player, "@orange")
      return true
    elseif event == fk.DrawNCards then
      data.n = data.n + 1
    end
  end
}
local huaiju = fk.CreateTriggerSkill{
  name = "huaiju",
  events = {fk.GameStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@orange", 3)
  end,
}
huaiju:addRelatedSkill(huaiju_effect)
local yili = fk.CreateTriggerSkill{
  name = "yili",
  anim_type = "support",
  events = { fk.EventPhaseStart },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(room:getOtherPlayers(player), Util.IdMapper)

    local result = room:askForChoosePlayers(player, targets, 1, 1, "#yili-choose", self.name)
    if #result > 0 then
      local tgt = result[1]
      if player:getMark("@orange") == 0 then
        self.cost_data = { tgt, "loseHp" }
        return true
      end
      local choice = room:askForChoice(player, { "loseHp", "yili_lose_orange" }, self.name)
      self.cost_data = { tgt, choice }
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local t, c = table.unpack(self.cost_data)
    if c == 'loseHp' then
      room:loseHp(player, 1, self.name)
    elseif c == 'yili_lose_orange' then
      room:removePlayerMark(player, "@orange")
    end
    room:addPlayerMark(room:getPlayerById(t), "@orange")
  end,
}
local zhenglun = fk.CreateTriggerSkill{
  name = "zhenglun",
  events = { fk.EventPhaseStart },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw and
      player:getMark("@orange") == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@orange")
    return true
  end,
}
luji:addSkill(huaiju)
luji:addSkill(yili)
luji:addSkill(zhenglun)
Fk:loadTranslationTable{
  ["luji"] = "陆绩",
  ["huaiju"] = "怀橘",
  [":huaiju"] = "锁定技，游戏开始时，你获得3枚“橘”标记。当有“橘”的角色受到伤害时，防止此伤害并移除1枚“橘”。有“橘”的角色摸牌阶段多摸一张牌。",
  ["yili"] = "遗礼",
  [":yili"] = "出牌阶段开始时，你可以失去1点体力或移除1枚“橘”，然后令一名其他角色获得1枚“橘”。",
  ["#yili-choose"] = "遗礼: 你可以失去1点体力或者移除1枚“橘”，令一名其他角色获得1枚“橘”",
  ["yili_lose_orange"] = "移除1枚“橘”",
  ["zhenglun"] = "整论",
  [":zhenglun"] = "摸牌阶段开始前，若你没有“橘”，你可以跳过摸牌阶段并获得1枚“橘”。",

  ["#huaiju_effect"] = "怀橘",
  ["@orange"] = "橘",
  ["$huaiju1"] = "情深舐犊，怀擢藏橘。",
  ["$huaiju2"] = "袖中怀绿桔，遗母报乳哺。",
  ["$yili2"] = "行遗礼之举，于不敬王者。",
  ["$yili1"] = "遗失礼仪，则俱非议。",
  ["$zhenglun1"] = "整论四海未泰，修文德以平。",
  ["$zhenglun2"] = "今论者不务道德怀取之术，而惟尚武，窃所未安。",
  ["~luji"] = "恨不能见，车同轨，书同文……",
}

local sunliang = General(extension, "sunliang", "wu", 3)
local kuizhu_active = fk.CreateActiveSkill{
  name = "kuizhu_active",
  interaction = function()
    return UI.ComboBox {choices = {"kuizhu_choice1", "kuizhu_choice2"}}
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  min_target_num = 1,
  target_filter = function(self, to_select, selected)
    if self.interaction.data == "kuizhu_choice1" then
      return #selected < Self:getMark("kuizhu")
    elseif self.interaction.data == "kuizhu_choice2" then
      local n = Fk:currentRoom():getPlayerById(to_select).hp
      for _, p in ipairs(selected) do
        n = n + Fk:currentRoom():getPlayerById(p).hp
      end
      return n <= Self:getMark("kuizhu")
    end
    return false
  end,
  feasible = function(self, selected, selected_cards)
    if #selected_cards ~= 0 or #selected == 0 or not self.interaction.data then return false end
    if self.interaction.data == "kuizhu_choice1" then
      return #selected <= Self:getMark("kuizhu")
    else
      local n = 0
      for _, p in ipairs(selected) do
        n = n + Fk:currentRoom():getPlayerById(p).hp
      end
      return n == Self:getMark("kuizhu")
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if self.interaction.data == "kuizhu_choice1" then
      room:setPlayerMark(player, "kuizhu_choice", 1)
    else
      room:setPlayerMark(player, "kuizhu_choice", 2)
    end
  end,
}
Fk:addSkill(kuizhu_active)
local kuizhu = fk.CreateTriggerSkill{
  name = "kuizhu",
  events = {fk.EventPhaseEnd},
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Discard and #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile and move.from == player.id and move.moveReason == fk.ReasonDiscard then
          return true
        end
      end
      return false
    end, Player.HistoryPhase) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile and move.from == player.id and move.moveReason == fk.ReasonDiscard then
          n = n + #move.moveInfo
        end
      end
      return false
    end, Player.HistoryPhase)
    if n == 0 then return false end
    room:setPlayerMark(player, self.name, n)
    local success, dat = room:askForUseActiveSkill(player, "kuizhu_active", "#kuizhu-use:::"..n, true)
    local choice = player:getMark("kuizhu_choice")
    if success then
      self.cost_data = {dat.targets, choice}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    local tos = table.map(self.cost_data[1], Util.Id2PlayerMapper)
    local choice = self.cost_data[2]
    if choice == 1 then
      room:notifySkillInvoked(player, self.name, "support")
      for _, p in ipairs(tos) do
        if not p.dead then
          p:drawCards(1, self.name)
        end
      end
    else
      room:notifySkillInvoked(player, self.name, "offensive")
      for _, p in ipairs(tos) do
        if not p.dead then
          room:damage { from = player, to = p, damage = 1, skillName = self.name }
        end
      end
      if not player.dead and #tos >= 2 then
        room:loseHp(player, 1, self.name)
      end
    end
  end,
}
sunliang:addSkill(kuizhu)
local chezheng = fk.CreateTriggerSkill{
  name = "chezheng",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and player.phase == Player.Play then
      local targets = table.filter(player.room:getOtherPlayers(player), function(p) return not p:inMyAttackRange(player) end)
      local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
        local use = e.data[1]
        return use and use.from == target.id
      end, Player.HistoryPhase)
      return #events < #targets
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function(p) return not p:inMyAttackRange(player) and not p:isNude() end)
    if #targets > 0 then
      local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#chezheng-throw", self.name, false)
      if #tos > 0 then
        local to = room:getPlayerById(tos[1])
        local cid = room:askForCardChosen(player, to, "he", self.name)
        room:throwCard({cid}, self.name, to, player)
      end
    end
  end,
}
local chezheng_prohibit = fk.CreateProhibitSkill{
  name = "#chezheng_prohibit",
  frequency = Skill.Compulsory,
  is_prohibited = function (self, from, to, card)
    return from:hasSkill(self.name) and from.phase == Player.Play and from ~= to and not to:inMyAttackRange(from)
  end,
}
chezheng:addRelatedSkill(chezheng_prohibit)
sunliang:addSkill(chezheng)
local lijun = fk.CreateTriggerSkill{
  name = "lijun$",
  events = { fk.CardUseFinished },
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and target ~= player and target.kingdom == "wu" and data.card.trueName == "slash" and target.phase == Player.Play then
      local cardList = data.card:isVirtual() and data.card.subcards or {data.card.id}
      return table.find(cardList, function(id) return not player.room:getCardOwner(id) end)
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name, data, "#lijun-invoke:"..player.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cardList = data.card:isVirtual() and data.card.subcards or {data.card.id}
    local cards = table.filter(cardList, function(id) return not room:getCardOwner(id) end)
    if #cards == 0 then return end
    local dummy = Fk:cloneCard("slash")
    dummy:addSubcards(cards)
    room:obtainCard(player, dummy, true, fk.ReasonJustMove)
    if not player.dead and not target.dead and room:askForSkillInvoke(player, self.name, data, "#lijun-draw:"..target.id) then
      target:drawCards(1, self.name)
    end
  end,
}
sunliang:addSkill(lijun)
Fk:loadTranslationTable{
  ["sunliang"] = "孙亮",
  ["kuizhu"] = "溃诛",
  [":kuizhu"] = "弃牌阶段结束时，你可以选择一项：1. 令至多X名角色各摸一张牌；2. 对任意名体力值之和为X的角色造成1点伤害，若不少于2名角色，你失去1点体力（X为你此阶段弃置的牌数）。",
  ["kuizhu_active"] = "溃诛",
  ["#kuizhu-use"] = "你可发动“溃诛”，X为%arg",
  ["kuizhu_choice1"] = "令至多X名角色各摸一张牌",
  ["kuizhu_choice2"] = "对任意名体力值之和为X的角色造成1点伤害",
  ["chezheng"] = "掣政",
  [":chezheng"] = "锁定技，你的出牌阶段内，攻击范围内不包含你的其他角色不能成为你使用牌的目标。出牌阶段结束时，若你本阶段使用的牌数小于这些角色数，你弃置其中一名角色一张牌。",
  ["#chezheng-throw"] = "掣政：选择攻击范围内不包含你的一名角色，弃置其一张牌",
  ["#chezheng_prohibit"] = "掣政",
  ["lijun"] = "立军",
  [":lijun"] = "主公技，其他吴势力角色于其出牌阶段使用【杀】结算结束后，其可以将此【杀】交给你，然后你可以令其摸一张牌。",
  ["#lijun-invoke"] = "立军：你可以将此【杀】交给 %src，然后 %src 可令你摸一张牌",
  ["#lijun-draw"] = "立军：你可以令 %src 摸一张牌",

  ["$kuizhu1"] = "子通专恣，必谋而诛之！",
  ["$kuizhu2"] = "孙綝久专，不可久忍，必溃诛！",
  ["$chezheng1"] = "风驰电掣，政权不怠！",
  ["$chezheng2"] = "廉平掣政，实为艰事。",
  ["$lijun1"] = "立于朝堂，定于军心。",
  ["$lijun2"] = "君立于朝堂，军侧于四方！",
  ["~sunliang"] = "今日欲诛逆臣而不得，方知机事不密则害成…",
}

local xuyou = General(extension, "xuyou", "qun", 3)
local chenglve = fk.CreateActiveSkill{
  name = "chenglve",
  anim_type = "switch",
  switch_skill_name = "chenglve",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return false
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local isYang = from:getSwitchSkillState(self.name, true) == fk.SwitchYang

    from:drawCards(isYang and 1 or 2, self.name)
    local discardNum = isYang and 2 or 1
    local cardsDiscarded = table.filter(room:askForDiscard(from, discardNum, discardNum, false, self.name, false), function(id)
      return Fk:getCardById(id).suit < Card.NoSuit
    end)

    if #cardsDiscarded > 0 then
      local suitsToRecord = table.map(cardsDiscarded, function(id)
        return Fk:getCardById(id):getSuitString(true)
      end)

      local suitsRecorded = type(from:getMark("@chenglve-phase")) == "table" and from:getMark("@chenglve-phase") or {}
      for _, suit in ipairs(suitsToRecord) do
        table.insertIfNeed(suitsRecorded, suit)
      end
      room:setPlayerMark(from, "@chenglve-phase", suitsRecorded)
    end
  end,
}
local chenglve_targetmod = fk.CreateTargetModSkill{
  name = "#chenglve_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("@chenglve-phase") ~= 0 and table.contains(player:getMark("@chenglve-phase"), "log_"..card:getSuitString())
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and player:getMark("@chenglve-phase") ~= 0 and table.contains(player:getMark("@chenglve-phase"), "log_"..card:getSuitString())
  end,
}
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
chenglve:addRelatedSkill(chenglve_targetmod)
xuyou:addSkill(chenglve)
xuyou:addSkill(shicai)
xuyou:addSkill(cunmu)
Fk:loadTranslationTable{
  ["xuyou"] = "许攸",
  ["chenglve"] = "成略",
  [":chenglve"] = "转换技，出牌阶段限一次，阳：你可以摸一张牌，然后弃置两张手牌；阴：你可以摸两张牌，然后弃置一张手牌。"..
  "若如此做，你于此阶段内使用与你以此法弃置的牌花色相同的牌无距离和次数限制。",
  ["shicai"] = "恃才",
  [":shicai"] = "当你每回合首次使用一种类别的牌结算结束后，你可以将之置于牌堆顶，然后摸一张牌。",
  ["cunmu"] = "寸目",
  [":cunmu"] = "锁定技，当你摸牌时，改为从牌堆底摸牌。",
  ["@chenglve-phase"] = "成略",
  ["@shicai"] = "恃才",

  ["$chenglve1"] = "成略在胸，良计速出。",
  ["$chenglve2"] = "吾有良略在怀，必为阿瞒所需。",
  ["$shicai1"] = "吾才满腹，袁本初竟不从之。",
  ["$shicai2"] = "阿瞒有我良计，取冀州便是易如反掌。",
  ["$cunmu1"] = "哼！目光所及，短寸之间。",
  ["$cunmu2"] = "狭目之见，只能窥底。",
  ["~xuyou"] = "阿瞒，没有我你得不到冀州啊！",
}

Fk:loadTranslationTable{
  ["luzhi"] = "卢植",
  ["mingren"] = "明任",
  [":mingren"] = "游戏开始时，你摸两张牌，然后将一张手牌置于你的武将牌上，称为“任”。结束阶段，你可以用手牌替换“任”。",
  ["zhenliang"] = "贞良",
  [":zhenliang"] = "转换技，阳：出牌阶段限一次，你可以选择攻击范围内的一名其他角色，后弃置一张与“任”颜色相同的牌对其造成1点伤害。"..
  "阴：当你于回合外使用或打出的牌置入弃牌堆时，若此牌与“任”颜色相同，你可以令一名角色摸一张牌。",
}

return extension
