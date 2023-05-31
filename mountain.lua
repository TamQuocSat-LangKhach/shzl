local extension = Package:new("mountain")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["mountain"] = "山",
}

local dengai = General(extension, "dengai", "wei", 4)
local tuntian = fk.CreateTriggerSkill{
  name = "tuntian",
  anim_type = "special",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player.phase == Player.NotActive then
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|spade,club,diamond",
    }
    room:judge(judge)
  end,

  refresh_events = {fk.FinishJudge},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.reason == self.name
  end,
  on_refresh = function(self, event, target, player, data)
    if data.card.suit ~= Card.Heart and player.room:getCardArea(data.card) == Card.Processing then
      player:addToPile("dengai_tian", data.card, true, self.name)
    end
  end,
}
local tuntian_distance = fk.CreateDistanceSkill{
  name = "#tuntian_distance",
  correct_func = function(self, from, to)
    if from:hasSkill(self.name) then
      return -#from:getPile("dengai_tian")
    end
  end,
}
local zaoxian = fk.CreateTriggerSkill{
  name = "zaoxian",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      player.phase == Player.Start
  end,
  can_wake = function(self, event, target, player, data)
    return #player:getPile("dengai_tian") > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, "jixi", nil)
  end,
}
local jixi = fk.CreateViewAsSkill{  --FIXME: 用来急袭的那张田不应产生-1距离
  name = "jixi",
  anim_type = "control",
  pattern = "snatch",
  expand_pile = "dengai_tian",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "dengai_tian"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("snatch")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
tuntian:addRelatedSkill(tuntian_distance)
dengai:addSkill(tuntian)
dengai:addSkill(zaoxian)
Fk:addSkill(jixi)
Fk:loadTranslationTable{
  ["dengai"] = "邓艾",
  ["tuntian"] = "屯田",
  [":tuntian"] = "当你于回合外失去牌后，你可以进行判定：若结果不为♥，你将生效后的判定牌置于你的武将牌上，称为“田”；你计算与其他角色的距离-X（X为“田”的数量）。",
  ["zaoxian"] = "凿险",
  [":zaoxian"] = "觉醒技，准备阶段，若“田”的数量不少于3张，你减1点体力上限，然后获得〖急袭〗。",
  ["jixi"] = "急袭",
  [":jixi"] = "你可以将一张“田”当【顺手牵羊】使用。",
  ["dengai_tian"] = "田",
}

local jiangwei = General(extension, "jiangwei", "shu", 4)
local tiaoxin = fk.CreateActiveSkill{
  name = "tiaoxin",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getPlayerById(to_select):inMyAttackRange(Self)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local use = room:askForUseCard(target, "slash", "slash", "#tiaoxin-use", true, {must_targets = {player.id}})
    if use then
      room:useCard(use)
    else
      if not target:isNude() then
        local card = room:askForCardChosen(player, target, "he", self.name)
        room:throwCard({card}, self.name, target, player)
      end
    end
  end
}
local zhiji = fk.CreateTriggerSkill{
  name = "zhiji",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      player.phase == Player.Start
  end,
  can_wake = function(self, event, target, player, data)
    return player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"draw2"}
    if player:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "draw2" then
      player:drawCards(2)
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
    room:changeMaxHp(player, -1)  --yes, lose maxhp after choice
    room:handleAddLoseSkills(player, "guanxing", nil)
    room.logic:trigger(fk.EventPhaseStart, player, data)  --FIXME: to trigger guanxing!
  end,
}
jiangwei:addSkill(tiaoxin)
jiangwei:addSkill(zhiji)
Fk:loadTranslationTable{
  ["jiangwei"] = "姜维",
  ["tiaoxin"] = "挑衅",
  [":tiaoxin"] = "出牌阶段限一次，你可以指定一名你在其攻击范围内的角色，其需包括你在内的角色使用一张【杀】，否则你弃置其一张牌。",
  ["zhiji"] = "志继",
  [":zhiji"] = "觉醒技，准备阶段，若你没有手牌，你回复1点体力或摸两张牌，减1点体力上限，然后获得〖观星〗。",
  ["#tiaoxin-use"] = "挑衅：对其使用一张【杀】，否则其弃置你一张牌",
  ["draw1"] = "摸一张牌",
  ["draw2"] = "摸两张牌",
  ["recover"] = "回复1点体力",
}

local sunce = General(extension, "sunce", "wu", 4)
local jiang = fk.CreateTriggerSkill{
  name = "jiang",
  anim_type = "drawcard",
  events ={fk.TargetSpecified, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      ((data.card.trueName == "slash" and data.card.color == Card.Red) or data.card.name == "duel")
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
local hunzi = fk.CreateTriggerSkill{
  name = "hunzi",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      player.phase == Player.Start
  end,
  can_wake = function(self, event, target, player, data)
    return player.hp == 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, "yingzi|yinghun", nil)
  end,
}
sunce:addSkill(jiang)
sunce:addSkill(hunzi)
Fk:loadTranslationTable{
  ["sunce"] = "孙策",
  ["jiang"] = "激昂",
  [":jiang"] = "当你使用【决斗】或红色【杀】指定目标后，或成为【决斗】或红色【杀】的目标后，你可以摸一张牌。",
  ["hunzi"] = "魂姿",
  [":hunzi"] = "觉醒技，准备阶段，若你的体力值为1，你减1点体力上限，然后获得〖英姿〗和〖英魂〗。",
  ["zhiba"] = "制霸",
  [":zhiba"] = "主公技，其他吴势力角色的出牌阶段限一次，该角色可以与你拼点（若你已觉醒，你可以拒绝此拼点），若其没赢，你可以获得拼点的两张牌。",
}

local zhangzhaozhanghong = General(extension, "zhangzhaozhanghong", "wu", 3)
local zhijian = fk.CreateActiveSkill{
  name = "zhijian",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and #cards == 1 and to_select ~= Self.id and
      Fk:currentRoom():getPlayerById(to_select):getEquipment(Fk:getCardById(cards[1]).sub_type) == nil
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:moveCards({
      ids = effect.cards,
      from = effect.from,
      to = effect.tos[1],
      toArea = Card.PlayerEquip,
      moveReason = fk.ReasonPut,
    })
    player:drawCards(1, self.name)
  end,
}

local guzheng = fk.CreateTriggerSkill{
  name = "guzheng",
  anim_type = "support",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self.name) and target.phase == Player.Discard and target:getMark("guzheng_hand-phase") ~= 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local hand_cards = {}
    local all_cards = {}
    local mark_hand = target:getMark("guzheng_hand-phase")
    local mark_all = target:getMark("guzheng_all-phase")
    for _, id in ipairs(mark_hand) do
      if room:getCardArea(id) == Card.DiscardPile then
        table.insertIfNeed(hand_cards, id)
      end
    end
    if #hand_cards > 0 and room:askForSkillInvoke(player, self.name, nil, "#guzheng-invoke::"..target.id) then
      for _, id in ipairs(mark_all) do
        if room:getCardArea(id) == Card.DiscardPile then
          table.insertIfNeed(all_cards, id)
        end
      end
      room:fillAG(player, all_cards)
      for i = #all_cards, 1, -1 do
        if not table.contains(hand_cards, all_cards[i]) then
          room:takeAG(player, all_cards[i], room.players)
        end
      end
      local id = room:askForAG(player, hand_cards, true, self.name)  --TODO: temporarily use AG. AG function need cancelable!
      room:closeAG(player)
      if id ~= nil then
        self.cost_data = id
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:obtainCard(target, self.cost_data, true, fk.ReasonJustMove)
    local dummy = Fk:cloneCard("dilu")
    local mark = target:getMark("guzheng_all-phase")
    for _, id in ipairs(mark) do
      if room:getCardArea(id) == Card.DiscardPile and id ~= self.cost_data then
        dummy:addSubcard(id)
      end
    end
    if #dummy.subcards > 0 then
      room:obtainCard(player, dummy, true, fk.ReasonJustMove)
    end
  end,
  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    return player.phase == Player.Discard
  end,
  on_refresh = function(self, event, target, player, data)
    local mark_hand = player:getMark("guzheng_hand-phase")
    local mark_all = player:getMark("guzheng_all-phase")
    if mark_hand == 0 then mark_hand = {} end
    if mark_all == 0 then mark_all = {} end
    for _, move in ipairs(data) do
      if move.moveReason == fk.ReasonDiscard then
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              table.insertIfNeed(mark_hand, info.cardId)
            end
          end
        end
        for _, info in ipairs(move.moveInfo) do
          table.insertIfNeed(mark_all, info.cardId)
        end
      end
    end
    if #mark_hand > 0 then
      player.room:setPlayerMark(player, "guzheng_hand-phase", mark_hand)
      player.room:setPlayerMark(player, "guzheng_all-phase", mark_all)
    elseif #mark_all > 0 then
      player.room:setPlayerMark(player, "guzheng_all-phase", mark_all)
    end
  end,
}
zhangzhaozhanghong:addSkill(zhijian)
zhangzhaozhanghong:addSkill(guzheng)
Fk:loadTranslationTable{
  ["zhangzhaozhanghong"] = "张昭＆张纮",
  ["zhijian"] = "直谏",
  [":zhijian"] = "出牌阶段，你可以将你手牌中的一张装备牌置于一名其他角色装备区内：若如此做，你摸一张牌。",
  ["guzheng"] = "固政",
  [":guzheng"] = "其他角色的弃牌阶段结束时，你可以令其获得一张弃牌堆中此阶段中因弃置而置入弃牌堆的该角色的手牌：若如此做，你获得弃牌堆中其余此阶段因弃置而置入弃牌堆的牌。",
  ["#guzheng-invoke"] = "固政：你可以令 %dest 获得其弃置的其中一张牌。" ,
}

return extension