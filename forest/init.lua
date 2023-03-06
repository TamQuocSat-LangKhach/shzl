local extension = Package:new("forest")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["forest"] = "林",
}

local xingshang = fk.CreateTriggerSkill{
  name = "xingshang",
  anim_type = "drawcard",
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and not target:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards_id = target:getCardIds{Player.Hand, Player.Equip}
    local dummy = Fk:cloneCard'slash'
    dummy:addSubcards(cards_id)
    room:obtainCard(player.id, dummy, false, fk.Discard)
  end,
}
local fangzhu = fk.CreateTriggerSkill{
  name = "fangzhu",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local other = room:getOtherPlayers(player)
    local prompt = "#fangzhu-target"
    local targets = {}

    for _, p in ipairs(other) do
      table.insert(targets, p.id)
    end

    local p = room:askForChoosePlayers(player, targets, 1, 1, prompt, self.name)
    if #p > 0 then
      self.cost_data = room:getPlayerById(p[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    self.cost_data:drawCards((player.maxHp - player.hp), self.name)
    self.cost_data:turnOver()
  end,
}
local caopi = General:new(extension, "caopi", "wei", 3)
caopi:addSkill(xingshang)
caopi:addSkill(fangzhu)
Fk:loadTranslationTable{
  ["caopi"] = "曹丕",
  ["xingshang"] = "行殇",
  [":xingshang"] = "当其他角色死亡时，你可以获得其所有牌。",
  ["fangzhu"] = "放逐",
  [":fangzhu"] = "当你受到伤害后，你可以令一名其他角色翻面，然后该角色摸X张牌（X为你已损失的体力值）。",
  ["#fangzhu-target"] = "放逐：当你受到伤害后，你可以令一名其他角色翻面，然后该角色摸X张牌（X为你已损失的体力值）。",
}

local yinghun = fk.CreateTriggerSkill{
  name = "yinghun",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start and player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local other = room:getOtherPlayers(player)
    local prompt = "#yinghun-target"
    local targets = {}

    for _, p in ipairs(other) do
      table.insert(targets, p.id)
    end

    local p = room:askForChoosePlayers(player, targets, 1, 1, prompt, self.name)
    if #p > 0 then
      self.cost_data = p[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tar = room:getPlayerById(self.cost_data)
    local num = player.maxHp - player.hp
    local draw = "#yinghun-draw"
    local discard = "#yinghun-discard"
    local choice = room:askForChoice(player, {draw,  discard}, self.name)

    if choice == draw then
      tar:drawCards(num, self.name)
      room:askForDiscard(tar, 1, 1, true, self.name, false)
    else
      tar:drawCards(1, self.name)
      room:askForDiscard(tar, num, num, true, self.name, false)
    end
  end,
}
local sunjian = General:new(extension, "sunjian", "wu", 4)
sunjian:addSkill(yinghun)
Fk:loadTranslationTable{
  ["sunjian"] = "孙坚",
  ["yinghun"] = "英魂",
  [":yinghun"] = "准备阶段，若你已受伤，你可以选择一名其他角色并选择一项：1.令其摸X张牌，然后弃置一张牌；2.令其摸一张牌，然后弃置X张牌（X为你已损失的体力值）。",
  ["#yinghun-target"] = "英魂：准备阶段，若你已受伤，你可以选择一名其他角色并选择一项：1.令其摸X张牌，然后弃置一张牌；2.令其摸一张牌，然后弃置X张牌（X为你已损失的体力值）。",
  ["#yinghun-draw"] = "摸X弃一",
  ["#yinghun-discard"] = "摸一弃X"
}

return extension