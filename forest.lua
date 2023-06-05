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

  ["$xingshang1"] = "我的是我的，你的还是我的。",
  ["$xingshang2"] = "来，管杀还管埋！",
  ["$fangzhu1"] = "死罪可免，活罪难赦！",
  ["$fangzhu2"] = "给我翻过来！",
  ["~caopi"] = "子建，子建……",
}

local zhurong = General(extension, "zhurong", "shu", 4, 4, General.Female)
local juxiang = fk.CreateTriggerSkill{
  name = "juxiang",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect, fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and data.card.trueName == "savage_assault" then
      if event == fk.PreCardEffect then
        return data.to == player.id
      else
        return target ~= player and player.room:getCardArea(data.card) == Card.Processing
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.PreCardEffect then
      return true
    else
      player.room:obtainCard(player, data.card, true, fk.ReasonJustMove)
    end
  end,
}
local lieren = fk.CreateTriggerSkill{
  name = "lieren",
  anim_type = "offensive",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card and data.card.trueName == "slash" and
      not data.to.dead and not data.to:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pindian = player:pindian({data.to}, self.name)
    if pindian.results[data.to.id].winner == player and not data.to:isNude() then
      local card = room:askForCardChosen(player, data.to, "he", self.name)
      room:obtainCard(player, card, false, fk.ReasonPrey)
    end
  end,
}
zhurong:addSkill(juxiang)
zhurong:addSkill(lieren)
Fk:loadTranslationTable{
  ["zhurong"] = "祝融",
  ["juxiang"] = "巨象",
  [":juxiang"] = "锁定技，【南蛮入侵】对你无效；其他角色使用的【南蛮入侵】结算结束后，你获得之。",
  ["lieren"] = "烈刃",
  [":lieren"] = "当你使用【杀】对一个目标造成伤害后，你可以与其拼点，若你赢，你获得其一张牌。",

  ["$juxiang1"] = "大王，看我的。",
  ["$juxiang2"] = "小小把戏~",
  ["$lieren1"] = "亮兵器吧。",
  ["$lieren2"] = "尝尝我飞刀的厉害！",
  ["~zhurong"] = "大王，我……先走一步了……",
}

local yinghun = fk.CreateTriggerSkill{
  name = "yinghun",
  anim_type = "drawcard",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start and player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), function (p)
      return p.id end), 1, 1, "#yinghun-choose:::"..player:getLostHp()..":"..player:getLostHp(), self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local n = player:getLostHp()
    local choice = room:askForChoice(player, {"#yinghun-draw",  "#yinghun-discard"}, self.name)
    if choice == "#yinghun-draw" then
      room:broadcastSkillInvoke(self.name, 1)
      room:notifySkillInvoked(player, self.name, "support")
      to:drawCards(n, self.name)
      room:askForDiscard(to, 1, 1, true, self.name, false)
    else
      room:broadcastSkillInvoke(self.name, 2)
      room:notifySkillInvoked(player, self.name, "control")
      to:drawCards(1, self.name)
      room:askForDiscard(to, n, n, true, self.name, false)
    end
  end,
}
local sunjian = General:new(extension, "sunjian", "wu", 4)
sunjian:addSkill(yinghun)
Fk:loadTranslationTable{
  ["sunjian"] = "孙坚",
  ["yinghun"] = "英魂",
  [":yinghun"] = "准备阶段，若你已受伤，你可以选择一名其他角色并选择一项：1.令其摸X张牌，然后弃置一张牌；2.令其摸一张牌，然后弃置X张牌（X为你已损失的体力值）。",
  ["#yinghun-choose"] = "英魂：你可以令一名其他角色：摸%arg张牌然后弃一张牌，或摸一张牌然后弃%arg2张牌",
  ["#yinghun-draw"] = "摸X弃一",
  ["#yinghun-discard"] = "摸一弃X",

  ["$yinghun1"] = "以吾魂魄，保佑吾儿之基业",
  ["$yinghun2"] = "不诛此贼三族，则吾死不瞑目！",
  ["~sunjian"] = "有埋伏，啊……",
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
  target_filter = function(self, to_select, selected, selected_cards)
    local num = 999
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if p ~= Self and #p.player_cards[Player.Hand] < num then
        num = #p.player_cards[Player.Hand]
      end
    end
    return #selected_cards == Self:getMark("haoshi") and #selected == 0 and
      #Fk:currentRoom():getPlayerById(to_select).player_cards[Player.Hand] == num
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
    room:addPlayerMark(player, self.name, #player.player_cards[Player.Hand] // 2)
    room:askForUseActiveSkill(player, "#haoshi_active", "#haoshi-give:::"..#player.player_cards[Player.Hand] // 2, false)  --FIXME: 当烧条结束时不可cancelable的技能也无默认触发！
    room:setPlayerMark(player, self.name, 0)
  end
}
local dimeng = fk.CreateActiveSkill{
  name = "dimeng",
  anim_type = "control",
  min_card_num = 0,
  target_num = 2,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and #Fk:currentRoom().alive_players > 2
  end,
  card_filter = function(self, to_select, selected, selected_targets)
    return true
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if to_select == Self.id or #selected > 1 then return false end
    if #selected == 0 then
      return true
    else
      local target1 = Fk:currentRoom():getPlayerById(to_select)
      local target2 = Fk:currentRoom():getPlayerById(selected[1])
      if target1:isKongcheng() and #target2:isKongcheng() then
        return false
      end
      return math.abs(#target1.player_cards[Player.Hand] - #target2.player_cards[Player.Hand]) <= #selected_cards
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
  ["#haoshi-give"] = "好施：将%arg张手牌交给手牌最少的一名其他角色",

  ["$haoshi1"] = "拿去拿去，莫跟哥哥客气！",
  ["$haoshi2"] = "来来来，见面分一半。",
  ["$dimeng1"] = "以和为贵，以和为贵。",
  ["$dimeng2"] = "合纵连横，方能以弱胜强。",
  ["~lusu"] = "此联盟已破，吴蜀休矣……",
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
local baonve = fk.CreateTriggerSkill{
  name = "baonve$",
  anim_type = "support",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target ~= player and target.kingdom == "qun"
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name, nil, "#baonve-invoke:"..player.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = target,
      reason = self.name,
      pattern = ".|.|spade",
    }
    room:judge(judge)
    if judge.card.suit == Card.Spade and player:isWounded() then
      room:recover({
        who = player,
        num = 1,
        recoverBy = target,
        skillName = self.name
      })
    end
  end
}
dongzhuo:addSkill(jiuchi)
dongzhuo:addSkill(roulin)
dongzhuo:addSkill(benghuai)
dongzhuo:addSkill(baonve)
Fk:loadTranslationTable{
  ["dongzhuo"] = "董卓",
  ["jiuchi"] = "酒池",
  [":jiuchi"] = "你可以将一张♠手牌当【酒】使用。",
  ["roulin"] = "肉林",
  [":roulin"] = "锁定技，你对女性角色使用【杀】，或女性角色对你使用【杀】均需两张【闪】才能抵消。",
  ["benghuai"] = "崩坏",
  [":benghuai"] = "锁定技，结束阶段，若你不是体力值最小的角色，你选择减1点体力上限或失去1点体力。",
  ["baonve"] = "暴虐",
  [":baonve"] = "主公技，其他群雄武将造成伤害后，其可以进行一次判定，若判定结果为♠，你回复1点体力。",
  ["loseMaxHp"] = "减1点体力上限",
  ["loseHp"] = "失去1点体力",
  ["#baonve-invoke"] = "暴虐：你可以判定，若为♠，%src 回复1点体力",

  ["$jiuchi1"] = "呃……再来……一壶……",
  ["$jiuchi2"] = "好酒！好酒！",
  ["$roulin1"] = "美人儿，来，香一个~~",
  ["$roulin2"] = "食色，性也~~",
  ["$benghuai1"] = "我是不是该减肥了？",
  ["$benghuai2"] = "呃……",
  ["$baonve1"] = "顺我者昌，逆我者亡！",
  ["$baonve2"] = "哈哈哈哈！",
  ["~dongzhuo"] = "汉室衰弱，非我一人之罪。",
}

--local jiaxu = General(extension, "jiaxu", "qun", 3)
local wansha = fk.CreateTriggerSkill{
  name = "wansha",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player.phase ~= Player.NotActive
  end,
  on_use = function(self, event, target, player, data)
  end,
}
local weimu = fk.CreateProhibitSkill{
  name = "weimu",
  is_prohibited = function(self, from, to, card)
    return to:hasSkill(self.name) and card.type == Card.TypeTrick and card.color == Card.Black
  end,
}
--jiaxu:addSkill(wansha)
--jiaxu:addSkill(weimu)
Fk:loadTranslationTable{
  ["jiaxu"] = "贾诩",
  ["wansha"] = "完杀",
  [":wansha"] = "锁定技，你的回合内，只有你和处于濒死状态的角色才能使用【桃】。",
  ["luanwu"] = "乱武",
  [":luanwu"] = "限定技，出牌阶段，你可以令所有其他角色依次选择一项：1.对距离最近的另一名角色使用【杀】；2.失去1点体力。",
  ["weimu"] = "帷幕",
  [":weimu"] = "锁定技，你不能成为黑色锦囊牌的目标。",

  ["$wansha1"] = "我要你三更死，谁敢留你到五更！",
  ["$wansha2"] = "神仙难救，神仙难救啊",
  ["$luanwu1"] = "哭喊吧，哀求吧，挣扎吧，然后，死吧！",
  ["$luanwu2"] = "哼哼哼……坐山观虎斗！",
  ["$weimu1"] = "你奈我何？",
  ["$weimu2"] = "此计伤不到我。",
  ["~jiaxu"] = "我的时辰……也到了……",
}

return extension