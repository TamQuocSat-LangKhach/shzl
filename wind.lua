local extension = Package:new("wind")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["wind"] = "风",
}

local xiahouyuan = General(extension, "xiahouyuan", "wei", 4)
local shensu = fk.CreateTriggerSkill{
  name = "shensu",
  anim_type = "offensive",
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) then
      if data.to == Player.Judge then
        return true
      elseif data.to == Player.Play then
        return not player:isNude()
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do  --TODO: target filter
      table.insert(targets, p.id)
    end
    if #targets == 0 then return end
    if data.to == Player.Judge then
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#shensu1-choose", self.name, true)
      if #to > 0 then
        self.cost_data = to[1]
        player:skip(Player.Judge)
        player:skip(Player.Draw)
        return true
      end
    elseif data.to == Player.Play then
      --FIXME: this will divulge handcard !
      local tos, id = room:askForChooseCardAndPlayers(player, targets, 1, 1, ".|.|.|.|.|equip", "#shensu2-choose", self.name, true)
      if #tos > 0 then
        self.cost_data = tos[1]
        player:skip(Player.Play)
        room:throwCard({id}, self.name, player, player)
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local slash = Fk:cloneCard("slash")
    player.room:useCard({
      card = slash,
      from = player.id,
      tos = {{self.cost_data}},
      skillName = self.name,
      extraUse = true,
    })
    return true
  end,
}
xiahouyuan:addSkill(shensu)
Fk:loadTranslationTable{
  ["xiahouyuan"] = "夏侯渊",
  ["shensu"] = "神速",
  [":shensu"] = "你可以做出如下选择：1.跳过判定阶段和摸牌阶段；2.跳过出牌阶段并弃置一张装备牌。你每选择一项，便视为你使用一张无距离限制的【杀】。",
  ["#shensu1-choose"] = "神速：你可以跳过判定阶段和摸牌阶段，视为你使用一张无距离限制的【杀】",
  ["#shensu2-choose"] = "神速：你可以跳过出牌阶段并弃置一张装备牌，视为你使用一张无距离限制的【杀】",
}

local jushou = fk.CreateTriggerSkill{
  name = "jushou",
  anim_type = "offensive",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:drawCards(player, 3, self.name)
    player:turnOver()
  end,
}
local caoren = General:new(extension, "caoren", "wei", 4)
caoren:addSkill(jushou)
Fk:loadTranslationTable{
  ["caoren"] = "曹仁",
  ["jushou"] = "据守",
  [":jushou"] = "结束阶段，你可以摸三张牌，然后翻面。",
}

local liegong = fk.CreateTriggerSkill{
  name = "liegong",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name)) then return end
    local room = player.room
    local to = room:getPlayerById(data.to)
    local num = #to:getCardIds(Player.Hand)
    local filter = num <= player:getAttackRange() or num >= player.hp
    return data.card.trueName == "slash" and filter and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsive = true -- FIXME: use disreponseList. this is FK's bug
  end,
}
local huangzhong = General:new(extension, "huangzhong", "shu", 4)   
huangzhong:addSkill(liegong)
Fk:loadTranslationTable{
  ["huangzhong"] = "黄忠",
  ["liegong"] = "烈弓",
  [":liegong"] = "当你于出牌阶段内使用【杀】指定一个目标后，若该角色的手牌数不小于你的体力值或不大于你的攻击范围，则你可以令其不能使用【闪】响应此【杀】。",
}

local kuanggu = fk.CreateTriggerSkill{
  name = "kuanggu",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target == player and player:distanceTo(data.to) <= 1 and player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover({
      who = player,
      num = 1,
      recoverBy = player,
      skillName = self.name
    })
  end,
}
local weiyan = General:new(extension, "weiyan", "shu", 4)   
weiyan:addSkill(kuanggu)
Fk:loadTranslationTable{
  ["weiyan"] = "魏延",
  ["kuanggu"] = "狂骨",
  [":kuanggu"] = "锁定技，当你对距离1以内的一名角色造成1点伤害后，你回复1点体力。",
}

local leiji = fk.CreateTriggerSkill{
  name = "leiji",
  anim_type = "offensive",
  events = {fk.AfterCardUseDeclared, fk.CardResponding},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target == player and data.card.name == "jink"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local other = room:getOtherPlayers(player)
    local prompt = "#leiji-target"
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
    local judge = {
      who = tar,
      reason = self.name,
      pattern = ".|.|spade",
    }

    room:judge(judge)
    if judge.card.suit == Card.Spade then
      room:damage{
        from = player,
        to = tar,
        damage = 2,
        damageType = fk.ThunderDamage,
        skillName = self.name,
      }
    end
end,
}
local guidao = fk.CreateTriggerSkill{
  name = "guidao",
  anim_type = "control",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local prompt = "#guidao-ask::" .. target.id

    local card = room:askForResponse(player, self.name, ".|.|spade,club|hand,equip", prompt, true)
    if card ~= nil then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:retrial(self.cost_data, player, data, self.name, true)
  end,
}
local zhangjiao = General:new(extension, "zhangjiao", "qun", 3)   
zhangjiao:addSkill(leiji)
zhangjiao:addSkill(guidao)
Fk:loadTranslationTable{
  ["zhangjiao"] = "张角",
  ["leiji"] = "雷击",
  [":leiji"] = "当你使用或打出【闪】时，你可以令一名角色进行判定，若结果为黑桃，你对其造成2点雷电伤害。",
  ["#leiji-target"] = "雷击：当你使用或打出【闪】时，你可以令一名角色进行判定，若结果为黑桃，你对其造成2点雷电伤害。",
  ["guidao"] = "鬼道",
  [":guidao"] = "当一名角色的判定牌生效前，你可以打出一张黑色牌替换之。",
  ["#guidao-ask"] = "是否发动“鬼道”，打出一张牌替换 %dest 的判定？",
}

local tianxiang = fk.CreateTriggerSkill{
  name = "tianxiang",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target == player
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local other = room:getOtherPlayers(player)
    local prompt = "#tianxaing-target" 
    local targets = {}

    for _, p in ipairs(other) do
      table.insert(targets, p.id)
    end

    local tar, card = room:askForChooseCardAndPlayers(player, targets, 1, 1, ".|.|heart|hand", prompt, self.name)

    if #tar > 0 and card then
      self.cost_data = tar[1]
      self.cost_data2 = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    room:throwCard(self.cost_data2, self.name, player, player)
    room:damage{
      from = data.from,
      to = to,
      damage = data.damage,
      damageType = data.type,
      skillName = self.name,
    }
    if not to.dead then
      to:drawCards(to:getLostHp(), self.name)
    end
    return true
  end,
}
local hongyan = fk.CreateFilterSkill{
  name = "hongyan",
  card_filter = function(self, to_select, player)
    return to_select.suit == Card.Spade and player:hasSkill(self.name)
  end,
  view_as = function(self, to_select)
    return Fk:cloneCard(to_select.name, Card.Heart, to_select.number)
  end,
}
local xiaoqiao = General:new(extension, "xiaoqiao", "wu", 3, 3, General.Female)
xiaoqiao:addSkill(tianxiang)
xiaoqiao:addSkill(hongyan)
Fk:loadTranslationTable{
  ["xiaoqiao"] = "小乔",
  ["tianxiang"] = "天香",
  [":tianxiang"] = "当你受到伤害时，你可以弃置一张红桃手牌并选择一名其他角色。若如此做，你将此伤害转移给该角色，然后其摸X张牌（X为其已损失体力值）。",
  ["#tianxaing-target" ] = "天香：当你受到伤害时，你可以弃置一张红桃手牌并选择一名其他角色。若如此做，你将此伤害转移给该角色，然后其摸X张牌（X为其已损失体力值）。",
  ["hongyan"] = "红颜",
  [":hongyan"] = "锁定技，你的黑桃牌视为红桃牌。",
}

-- local buqu = fk.CreateTriggerSkill{
--   name = "buqu",
-- }
-- local zhoutai = General:new(extension, "zhoutai", "wu", 4)   
-- zhoutai:addSkill(buqu)

Fk:loadTranslationTable{
  ["zhoutai"] = "周泰",
  ["buqu"] = "不屈",
  [":buqu"] = "当你扣减体力时，若你的体力值不大于X，你可以将牌堆顶的X张牌置于武将牌上，称为“创”，若没有与此“创”点数相同的其他“创”，你于此次扣减体力后之后不进行濒死流程（X为你此次扣减的体力点数）。当你回复1点体力后，若“创”数与你的体力之和大于1，你将一张“创”置入弃牌堆。",
}

return extension
