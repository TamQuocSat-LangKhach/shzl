local extension = Package:new("forest")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["forest"] = "林",
}

local xuhuang = General(extension, "xuhuang", "wei", 4)
local duanliang = fk.CreateViewAsSkill{
  name = "duanliang",
  anim_type = "control",
  pattern = "supply_shortage",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black and Fk:getCardById(to_select).type ~= Card.TypeTrick
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("supply_shortage")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
local duanliang_targetmod = fk.CreateTargetModSkill{
  name = "#duanliang_targetmod",
  distance_limit_func =  function(self, player, skill)
    if player:hasSkill(self.name) and skill.name == "supply_shortage_skill" then
      return 1
    end
  end,
}
duanliang:addRelatedSkill(duanliang_targetmod)
xuhuang:addSkill(duanliang)
Fk:loadTranslationTable{
  ["xuhuang"] = "徐晃",
  ["duanliang"] = "断粮",
  [":duanliang"] = "你可以将一张黑色基本牌或黑色装备牌当【兵粮寸断】使用；你可以对距离为2的角色使用【兵粮寸断】。",
}

local caopi = General(extension, "caopi", "wei", 3)
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
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), function(p)
      return p.id end), 1, 1, "#fangzhu-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = player.room:getPlayerById(self.cost_data)
    to:drawCards(player:getLostHp(), self.name)
    to:turnOver()
  end,
}
caopi:addSkill(xingshang)
caopi:addSkill(fangzhu)
Fk:loadTranslationTable{
  ["caopi"] = "曹丕",
  ["xingshang"] = "行殇",
  [":xingshang"] = "当其他角色死亡时，你可以获得其所有牌。",
  ["fangzhu"] = "放逐",
  [":fangzhu"] = "当你受到伤害后，你可以令一名其他角色翻面，然后该角色摸X张牌（X为你已损失的体力值）。",
  ["#fangzhu-target"] = "放逐：你可以令一名其他角色翻面，然后该角色摸X张牌（X为你已损失的体力值）",
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

local lusu = General(extension, "lusu", "wu", 3)
local haoshi_active = fk.CreateActiveSkill{
  name = "#haoshi_active",
  anim_type = "support",
  target_num = 1,
  card_num = function ()
    return Self:getMark("haoshi")
  end,
  card_filter = function(self, to_select, selected)
    return #selected < Self:getMark("haoshi") and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected)
    local num = 999
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if p ~= Self and #p.player_cards[Player.Hand] < num then
        num = #p.player_cards[Player.Hand]
      end
    end
    return #selected == 0 and #Fk:currentRoom():getPlayerById(to_select).player_cards[Player.Hand] == num
  end,
  on_use = function(self, room, effect)
    room:setPlayerMark(room:getPlayerById(effect.from), "haoshi", 0)
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(effect.cards)
    room:obtainCard(effect.tos[1], dummy, false, fk.ReasonGive)
  end,
}
local haoshi = fk.CreateTriggerSkill{
  name = "haoshi",
  anim_type = "support",
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
  end,

  refresh_events = {fk.AfterDrawNCards},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player:usedSkillTimes(self.name) > 0 and #player.player_cards[Player.Hand] > 5
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, self.name, math.floor(#player.player_cards[Player.Hand]/2))
    room:askForUseActiveSkill(player, "#haoshi_active", "#haoshi-give", false)  --FIXME: cancelable is useless when time is out!
  end
}
local dimeng = fk.CreateActiveSkill{
  name = "dimeng",
  anim_type = "control",
  target_num = 2,
  min_card_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and #Fk:currentRoom().alive_players > 2
  end,
  card_filter = function(self, to_select, selected)
    return true
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected == 0 then
      return true
    elseif #selected == 1 then
      local target1 = Fk:currentRoom():getPlayerById(to_select)
      local target2 = Fk:currentRoom():getPlayerById(selected[1])
      if #target1.player_cards[Player.Hand] == 0 and #target2.player_cards[Player.Hand] == 0 then
        return false
      end
      return math.abs(#target1.player_cards[Player.Hand] - #target2.player_cards[Player.Hand]) == #selected_cards
    else
      return false
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, "haoshi", player, player)
    local move1 = {
      from = effect.tos[1],
      ids = room:getPlayerById(effect.tos[1]).player_cards[Player.Hand],
      to = effect.tos[2],
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonExchange,
      proposer = effect.from,
      skillName = "haoshi",
    }
    local move2 = {
      from = effect.tos[2],
      ids = room:getPlayerById(effect.tos[2]).player_cards[Player.Hand],
      to = effect.tos[1],
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonExchange,
      proposer = effect.from,
      skillName = "haoshi",
    }
    room:moveCards(move1, move2)
  end,
}
Fk:addSkill(haoshi_active)
lusu:addSkill(haoshi)
lusu:addSkill(dimeng)
Fk:loadTranslationTable{
  ["lusu"] = "鲁肃",
  ["haoshi"] = "好施",
  [":haoshi"] = "摸牌阶段，你可以多摸两张牌，然后若你的手牌数大于5，你将半数（向下取整）手牌交给手牌最少的一名其他角色。",
  ["dimeng"] = "缔盟",
  [":dimeng"] = "出牌阶段，你可以选择两名其他角色并弃置X张牌（X为这些角色手牌数差），令这两名角色交换手牌。",
  ["#haoshi-give"] = "好施：将半数（向下取整）手牌交给手牌最少的一名其他角色",
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
  ["loseMaxHp"] = "减1点体力上限",
  ["loseHp"] = "失去1点体力",
}

return extension