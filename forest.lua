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
  ["#yinghun-target"] = "英魂：你可以令一名其他角色：摸X张牌然后弃一张牌，或摸一张牌然后弃X张牌",
  ["#yinghun-draw"] = "摸X弃一",
  ["#yinghun-discard"] = "摸一弃X"
}

local dongzhuo = General(extension, "dongzhuo", "qun", 8)
local jiuchi = fk.CreateViewAsSkill{
  name = "jiuchi",
  anim_type = "offensive",
  pattern = "analeptic",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Spade and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("analeptic")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
local roulin = fk.CreateTriggerSkill{
  name = "roulin",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.TargetSpecified, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and data.card.trueName == "slash" then
      if event == fk.TargetSpecified then
        return player.room:getPlayerById(data.to).gender == General.Female
      else
        return player.room:getPlayerById(data.from).gender == General.Female
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    data.fixedResponseTimes = data.fixedResponseTimes or {}
    data.fixedResponseTimes["jink"] = 2
  end,
}
local benghuai = fk.CreateTriggerSkill{
  name = "benghuai",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and player.phase == Player.Finish then
      for _, p in ipairs(player.room:getOtherPlayers(player)) do
        if p.hp < player.hp then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, {"loseMaxHp", "loseHp"}, self.name)
    if choice == "loseMaxHp" then
      room:changeMaxHp(player, -1)
    else
      room:loseHp(player, 1, self.name)
    end
  end,
}
dongzhuo:addSkill(jiuchi)
dongzhuo:addSkill(roulin)
dongzhuo:addSkill(benghuai)
Fk:loadTranslationTable{
  ["dongzhuo"] = "董卓",
  ["jiuchi"] = "酒池",
  [":jiuchi"] = "你可以将一张♠手牌当【酒】使用。",
  ["roulin"] = "肉林",
  [":roulin"] = "锁定技，你对女性角色使用【杀】，或女性角色对你使用【杀】均需两张【闪】才能抵消。",
  ["benghuai"] = "崩坏",
  [":benghuai"] = "锁定技，结束阶段，若你不是体力值最小的角色，你选择减1点体力上限或失去1点体力。",
  ["baonve"] = "暴虐",
  [":baonve"] = "主公技，其他群雄武将造成伤害时，其可以进行一次判定，若判定结果为♠，你回复1点体力。",
}

return extension