local extension = Package:new("forest")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["forest"] = "神话再临·林",
}

local U = require "packages/utility/utility"

local xuhuang = General(extension, "xuhuang", "wei", 4)
local duanliang = fk.CreateViewAsSkill{
  name = "duanliang",
  anim_type = "control",
  pattern = "supply_shortage",
  handly_pile = true,
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
    if player:hasSkill(self) and skill.name == "supply_shortage_skill" then
      return 1
    end
  end,
}
duanliang:addRelatedSkill(duanliang_targetmod)
xuhuang:addSkill(duanliang)
Fk:loadTranslationTable{
  ["xuhuang"] = "徐晃",
  ["#xuhuang"] = "周亚夫之风",
  ["illustrator:xuhuang"] = "Tuu.",
  ["duanliang"] = "断粮",
  [":duanliang"] = "你可以将一张黑色基本牌或黑色装备牌当【兵粮寸断】使用；你可以对距离为2的角色使用【兵粮寸断】。",

  ["$duanliang1"] = "截其源，断其粮，贼可擒也。",
  ["$duanliang2"] = "人是铁，饭是钢。",
  ["~xuhuang"] = "一顿不吃饿得慌。",
}

local caopi = General(extension, "caopi", "wei", 3)
local xingshang = fk.CreateTriggerSkill{
  name = "xingshang",
  anim_type = "drawcard",
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards_id = target:getCardIds{Player.Hand, Player.Equip}
    room:obtainCard(player.id, cards_id, false, fk.ReasonPrey)
  end,
}
local fangzhu = fk.CreateTriggerSkill{
  name = "fangzhu",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper)
    , 1, 1, "#fangzhu-choose:::"..player:getLostHp(), self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = player.room:getPlayerById(self.cost_data.tos[1])
    to:turnOver()
    if not to.dead and player:getLostHp() > 0 then
      to:drawCards(player:getLostHp(), self.name)
    end
  end,
}
local songwei = fk.CreateTriggerSkill{
  name = "songwei$",
  events = {fk.FinishJudge},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and target.kingdom == "wei" and data.card.color == Card.Black
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name, nil, "#songwei-invoke:"..player.id)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
caopi:addSkill(xingshang)
caopi:addSkill(fangzhu)
caopi:addSkill(songwei)
Fk:loadTranslationTable{
  ["caopi"] = "曹丕",
  ["#caopi"] = "霸业的继承者",
  ["cv:caopi"] = "曹真",
  ["illustrator:caopi"] = "SoniaTang",
  ["xingshang"] = "行殇",
  [":xingshang"] = "当其他角色死亡时，你可以获得其所有牌。",
  ["fangzhu"] = "放逐",
  [":fangzhu"] = "当你受到伤害后，你可以令一名其他角色翻面，然后其摸X张牌（X为你已损失的体力值）。",
  ["songwei"] = "颂威",
  [":songwei"] = "主公技，当其他魏势力角色的判定结果确定后，若为黑色，其可令你摸一张牌。",

  ["#fangzhu-choose"] = "放逐：你可以令一名其他角色翻面，然后其摸%arg张牌",
  ["#songwei-invoke"] = "颂威：你可以令 %src 摸一张牌",

  ["$xingshang1"] = "我的是我的，你的还是我的。",
  ["$xingshang2"] = "来，管杀还管埋！",
  ["$fangzhu1"] = "死罪可免，活罪难赦！",
  ["$fangzhu2"] = "给我翻过来！",
  ["$songwei1"] = "千秋万载，一统江山！",
  ["$songwei2"] = "仙福永享，寿与天齐！",
  ["~caopi"] = "子建，子建……",
}

local menghuo = General(extension, "menghuo", "shu", 4)
local huoshou = fk.CreateTriggerSkill{
  name = "huoshou",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect, fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card.trueName == "savage_assault" then
      if event == fk.PreCardEffect then
        return player.id == data.to
      else
        return target ~= player and data.firstTarget
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.PreCardEffect then
      return true
    else
      data.extra_data = data.extra_data or {}
      data.extra_data.huoshou = player.id
    end
  end,

  refresh_events = {fk.PreDamage},
  can_refresh = function(self, event, target, player, data)
    if data.card and data.card.trueName == "savage_assault" then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data[1]
        return use.extra_data and use.extra_data.huoshou
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if e then
      local use = e.data[1]
      data.from = room:getPlayerById(use.extra_data.huoshou)
    end
  end,
}
local zaiqi = fk.CreateTriggerSkill{
  name = "zaiqi",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw and player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getLostHp()
    local cards = room:getNCards(n)
    room:moveCards{
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
      proposer = player.id,
    }
    room:delay(2000)
    local hearts, to_get = {}, {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).suit == Card.Heart then
        table.insert(hearts, id)
      else
        table.insert(to_get, id)
      end
    end
    if #hearts > 0 then
      if player:isWounded() then
        room:recover({
          who = player,
          num = math.min(#hearts, player:getLostHp()),
          recoverBy = player,
          skillName = self.name,
        })
      end
      room:moveCards{
        ids = hearts,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
      }
    end
    if #to_get > 0 and not player.dead then
      room:obtainCard(player.id, to_get, true, fk.ReasonJustMove)
    end
    cards = table.filter(cards, function (id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonJustMove, self.name)
    end
    return true
  end,
}
menghuo:addSkill(huoshou)
menghuo:addSkill(zaiqi)
Fk:loadTranslationTable{
  ["menghuo"] = "孟获",
  ["#menghuo"] = "南蛮王",
  ["illustrator:menghuo"] = "废柴男",
  ["huoshou"] = "祸首",
  [":huoshou"] = "锁定技，【南蛮入侵】对你无效；当其他角色使用【南蛮入侵】指定目标后，你代替其成为此牌造成的伤害的来源。",
  ["zaiqi"] = "再起",
  [":zaiqi"] = "摸牌阶段，若你已受伤，你可以放弃摸牌，改为亮出牌堆顶X张牌（X为你已损失体力值），你将其中的<font color='red'>♥</font>牌置入弃牌堆"..
  "并回复等量体力，获得其余的牌。",

  ["$huoshou1"] = "背黑锅我来，送死？你去！",
  ["$huoshou2"] = "通通算我的！",
  ["$zaiqi1"] = "丞相助我！",
  ["$zaiqi2"] = "起！",
  ["~menghuo"] = "七纵之恩……来世……再报了……",
}

local zhurong = General(extension, "zhurong", "shu", 4, 4, General.Female)
local juxiang = fk.CreateTriggerSkill{
  name = "juxiang",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect, fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(self) and data.card and data.card.trueName == "savage_assault") then return end
    if event == fk.PreCardEffect then
      return data.to == player.id
    else
      return target ~= player and U.hasFullRealCard(player.room, data.card)
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
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and
      not data.to.dead and player:canPindian(data.to) and not data.chain
      and player.room.logic:damageByCardEffect()
  end,
  on_cost = function (self, event, target, player, data)
    self.cost_data = {tos = {data.to.id}}
    return player.room:askForSkillInvoke(player, self.name, nil, "#lieren-invoke:"..data.to.id)
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
  ["#zhurong"] = "野性的女王",
  ["cv:zhurong"] = "水原",
  ["illustrator:zhurong"] = "废柴男",
  ["juxiang"] = "巨象",
  [":juxiang"] = "锁定技，【南蛮入侵】对你无效；其他角色使用的【南蛮入侵】结算结束后，你获得之。",
  ["lieren"] = "烈刃",
  [":lieren"] = "当你使用【杀】对一个目标造成伤害后，你可以与其拼点，若你赢，你获得其一张牌。",
  ["#lieren-invoke"] = "烈刃：你可以与 %src 拼点，若你赢，你获得其一张牌。",

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
    return target == player and player:hasSkill(self) and player.phase == Player.Start and player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
    1, 1, "#yinghun-choose:::"..player:getLostHp(), self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local n = player:getLostHp()
    local choices = {"#yinghun-draw:::" .. n,  "#yinghun-discard:::" .. n}
    local choice = (n == 1) and choices[1] or room:askForChoice(player, choices, self.name)
    if choice:startsWith("#yinghun-draw") then
      player:broadcastSkillInvoke(self.name, 1)
      room:notifySkillInvoked(player, self.name, "support", {to.id})
      to:drawCards(n, self.name)
      room:askForDiscard(to, 1, 1, true, self.name, false)
    else
      player:broadcastSkillInvoke(self.name, 2)
      room:notifySkillInvoked(player, self.name, "control", {to.id})
      to:drawCards(1, self.name)
      room:askForDiscard(to, n, n, true, self.name, false)
    end
  end,
}
local sunjian = General:new(extension, "sunjian", "wu", 4)
sunjian:addSkill(yinghun)
Fk:loadTranslationTable{
  ["sunjian"] = "孙坚",
  ["#sunjian"] = "武烈帝",
  ["illustrator:sunjian"] = "LiuHeng",
  ["yinghun"] = "英魂",
  [":yinghun"] = "准备阶段，若你已受伤，你可以选择一名其他角色并选择一项：1.令其摸X张牌，然后弃置一张牌；2.令其摸一张牌，然后弃置X张牌（X为你已损失的体力值）。",
  ["#yinghun-choose"] = "英魂：你可以令一名其他角色：摸%arg张牌然后弃置一张牌，或摸一张牌然后弃置%arg张牌",
  ["#yinghun-draw"] = "摸%arg张牌，弃置1张牌",
  ["#yinghun-discard"] = "摸1张牌，弃置%arg张牌",

  ["$yinghun1"] = "以吾魂魄，保佑吾儿之基业。",
  ["$yinghun2"] = "不诛此贼三族，则吾死不瞑目！",
  ["~sunjian"] = "有埋伏，啊……",
}

local lusu = General(extension, "lusu", "wu", 3)
local haoshi = fk.CreateTriggerSkill{
  name = "haoshi",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
  end,
}
local haoshi_delay = fk.CreateTriggerSkill{
  name = "#haoshi_delay",
  events = {fk.AfterDrawNCards},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and player:usedSkillTimes(haoshi.name, Player.HistoryPhase) > 0 and
    #player.player_cards[Player.Hand] > 5 and #player.room.alive_players > 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = player:getHandcardNum() // 2
    local targets = {}
    local n = 0
    for _, p in ipairs(room.alive_players) do
      if p ~= player then
        if #targets == 0 then
          table.insert(targets, p.id)
          n = p:getHandcardNum()
        else
          if p:getHandcardNum() < n then
            targets = {p.id}
            n = p:getHandcardNum()
          elseif p:getHandcardNum() == n then
            table.insert(targets, p.id)
          end
        end
      end
    end
    local tos, cards = room:askForChooseCardsAndPlayers(player, x, x, targets, 1, 1,
    ".|.|.|hand", "#haoshi-give:::" .. x, "haoshi", false)
    room:moveCardTo(cards, Card.PlayerHand, room:getPlayerById(tos[1]), fk.ReasonGive, "haoshi", nil, false, player.id)
  end,
}
local dimeng = fk.CreateActiveSkill{
  name = "dimeng",
  anim_type = "control",
  card_num = 0,
  target_num = 2,
  prompt = "#dimeng",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and #Fk:currentRoom().alive_players > 2
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    if to_select == Self.id or #selected > 1 then return false end
    if #selected == 0 then
      return true
    else
      local target1 = Fk:currentRoom():getPlayerById(to_select)
      local target2 = Fk:currentRoom():getPlayerById(selected[1])
      local num, num2 = target1:getHandcardNum(), target2:getHandcardNum()
      if num == 0 and num2 == 0 then
        return false
      end
      local x = #table.filter(Self:getCardIds({Player.Hand, Player.Equip}), function(cid) return not Self:prohibitDiscard(Fk:getCardById(cid)) end)
      return math.abs( num - num2 ) <= x
    end
  end,
  --[[
  feasible = function (self, selected, selected_cards)
    return #selected == 2 and
      math.abs(Fk:currentRoom():getPlayerById(selected[1]):getHandcardNum() - Fk:currentRoom():getPlayerById(selected[2]):getHandcardNum()) == #selected_cards
  end,
  ]]
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target1 = room:getPlayerById(effect.tos[1])
    local target2 = room:getPlayerById(effect.tos[2])
    local num = math.abs(target1:getHandcardNum() - target2:getHandcardNum())
    if num > 0 then
      room:askForDiscard(player, num, num, true, self.name, false, nil, "#dimeng-discard:" .. effect.tos[1] .. ":" .. effect.tos[2] .. ":" .. num)
    end
    U.swapHandCards(room, player, target1, target2, self.name)
  end,
}
haoshi:addRelatedSkill(haoshi_delay)
lusu:addSkill(haoshi)
lusu:addSkill(dimeng)
Fk:loadTranslationTable{
  ["lusu"] = "鲁肃",
  ["#lusu"] = "独断的外交家",
  ["illustrator:lusu"] = "LiuHeng",
  ["haoshi"] = "好施",
  [":haoshi"] = "摸牌阶段，你可以多摸两张牌，然后若你的手牌数大于5，你将半数（向下取整）手牌交给手牌牌最少的一名其他角色。",
  ["dimeng"] = "缔盟",
  [":dimeng"] = "出牌阶段限一次，你可以选择两名其他角色并弃置X张牌（X为这些角色手牌数差），令这两名角色交换手牌。",
  ["#haoshi-give"] = "好施：将%arg张手牌交给手牌最少的一名其他角色",
  ["#haoshi_delay"] = "好施",
  ["#dimeng"] = "缔盟：选择两名其他角色，点击“确定”后，选择与其手牌数之差等量的牌，这两名角色交换手牌",
  ["#dimeng-discard"] = "缔盟：弃置 %arg 张牌，交换%src和%dest的手牌",

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
  handly_pile = true,
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
    if not (target == player and player:hasSkill(self) and data.card.trueName == "slash") then return end
    return player.room:getPlayerById(event == fk.TargetSpecified and data.to or data.from):isFemale()
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
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function(p) return p.hp < player.hp end)
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
local baonue = fk.CreateTriggerSkill{
  name = "baonue$",
  anim_type = "support",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target and player:hasSkill(self) and target ~= player and target.kingdom == "qun" and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name, nil, "#baonue-invoke:"..player.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = target,
      reason = self.name,
      pattern = ".|.|spade",
    }
    room:judge(judge)
    if judge.card.suit == Card.Spade and player:isWounded() and not player.dead then
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
dongzhuo:addSkill(baonue)
Fk:loadTranslationTable{
  ["dongzhuo"] = "董卓",
  ["#dongzhuo"] = "魔王",
  ["illustrator:dongzhuo"] = "小冷",
  ["cv:dongzhuo"] = "九命黑猫",

  ["jiuchi"] = "酒池",
  [":jiuchi"] = "你可以将一张♠手牌当【酒】使用。",
  ["roulin"] = "肉林",
  [":roulin"] = "锁定技，你对女性角色使用【杀】，或女性角色对你使用【杀】均需两张【闪】才能抵消。",
  ["benghuai"] = "崩坏",
  [":benghuai"] = "锁定技，结束阶段，若你不是体力值最小的角色，你选择：1.减1点体力上限；2.失去1点体力。",
  ["baonue"] = "暴虐",
  [":baonue"] = "主公技，其他群雄角色造成伤害后，其可以判定，若结果为♠，你回复1点体力。",
  ["#baonue-invoke"] = "暴虐：你可以判定，若为♠，%src 回复1点体力",

  ["$jiuchi1"] = "呃……再来……一壶……",
  ["$jiuchi2"] = "好酒！好酒！",
  ["$roulin1"] = "美人儿，来，香一个~~",
  ["$roulin2"] = "食色，性也~~",
  ["$benghuai1"] = "我是不是该减肥了？",
  ["$benghuai2"] = "呃……",
  ["$baonue1"] = "顺我者昌，逆我者亡！",
  ["$baonue2"] = "哈哈哈哈！",
  ["~dongzhuo"] = "汉室衰弱，非我一人之罪。",
}

local jiaxu = General(extension, "jiaxu", "qun", 3)
local wansha = fk.CreateTriggerSkill{
  name = "wansha",
  anim_type = "offensive",
  frequency = Skill.Compulsory,

  refresh_events = {fk.EnterDying},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and player.phase ~= Player.NotActive and table.contains(player.player_skills, self)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, self.name)
    player:broadcastSkillInvoke(self.name)
  end,
}
local wansha_prohibit = fk.CreateProhibitSkill{
  name = "#wansha_prohibit",
  prohibit_use = function(self, player, card)
    if card.name == "peach" and not player.dying then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p.phase ~= Player.NotActive and p:hasSkill(wansha) and p ~= player and table.contains(p.player_skills, wansha)
      end)
    end
  end,
}
wansha:addRelatedSkill(wansha_prohibit)
local luanwu = fk.CreateActiveSkill{
  name = "luanwu",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = room:getOtherPlayers(player)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    for _, target in ipairs(targets) do
      if not target.dead then
        local other_players = table.filter(room:getOtherPlayers(target, false), function(p) return not p:isRemoved() end)
        local luanwu_targets = table.map(table.filter(other_players, function(p2)
          return table.every(other_players, function(p1)
            return target:distanceTo(p1) >= target:distanceTo(p2)
          end)
        end), Util.IdMapper)
        local use = room:askForUseCard(target, "slash", "slash", "#luanwu-use", true, {exclusive_targets = luanwu_targets, bypass_times = true})
        if use then
          use.extraUse = true
          room:useCard(use)
        else
          room:loseHp(target, 1, self.name)
        end
      end
    end
  end,
}
local weimu = fk.CreateProhibitSkill{
  name = "weimu",
  frequency = Skill.Compulsory,
  is_prohibited = function(self, from, to, card)
    return to:hasSkill(self) and card.type == Card.TypeTrick and card.color == Card.Black
  end,
}

jiaxu:addSkill(wansha)
jiaxu:addSkill(luanwu)
jiaxu:addSkill(weimu)

Fk:loadTranslationTable{
  ["jiaxu"] = "贾诩",
  ["#jiaxu"] = "冷酷的毒士",
  ["illustrator:jiaxu"] = "KayaK",
  ["designer:jiaxu"] = "KayaK",

  ["wansha"] = "完杀",
  [":wansha"] = "锁定技，除进行濒死流程的角色以外的其他角色于你的回合内不能使用【桃】。",
  ["luanwu"] = "乱武",
  [":luanwu"] = "限定技，出牌阶段，你可选择所有其他角色，这些角色各需对包括距离最小的另一名角色在内的角色使用【杀】，否则失去1点体力。",
  ["weimu"] = "帷幕",
  [":weimu"] = "锁定技，你不是黑色锦囊牌的合法目标。",

  ["#luanwu-use"] = "乱武：你需要对距离最近的一名角色使用一张【杀】，否则失去1点体力",

  ["$wansha1"] = "神仙难救，神仙难救啊。",
  ["$wansha2"] = "我要你三更死，谁敢留你到五更！",
  ["$luanwu1"] = "哼哼哼……坐山观虎斗！",
  ["$luanwu2"] = "哭喊吧，哀求吧，挣扎吧，然后，死吧！",
  ["$weimu1"] = "此计伤不到我。",
  ["$weimu2"] = "你奈我何？",
  ["~jiaxu"] = "我的时辰……也到了……",
}

return extension
