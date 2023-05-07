local extension = Package:new("god")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["god"] = "神",
}

local godguanyu = General(extension, "godguanyu", "god", 5)
local wushen = fk.CreateFilterSkill{
  name = "wushen",
  card_filter = function(self, to_select, player)
    return player:hasSkill(self.name) and to_select.suit == Card.Heart
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
  [":wushen"] = "锁定技，你的<font color='red'>♥</font>手牌均视为【杀】；你使用<font color='red'>♥</font>【杀】无距离限制。",
  ["wuhun"] = "武魂",
  [":wuhun"] = "锁定技，你受到1点伤害后，来源获得1枚“梦魇”标记；你死亡时，你令“梦魇”最多的一名其他角色判定，若不为【桃】或【桃园结义】，其死亡。",
  ["@nightmare"] = "梦魇",
  ["#wuhun-choose"] = "武魂：选择一名有“梦魇”最多的其他角色",

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
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Discard and player:getMark("qinyin-phase") > 1
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
      for _, p in ipairs(room:getAlivePlayers()) do
        room:loseHp(p, 1, self.name)
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
