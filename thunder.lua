local extension = Package("thunder")
extension.extensionName = "shzl"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["thunder"] = "神话再临·雷",
}

local haozhao = General(extension, "haozhao", "wei", 4)
local zhengu = fk.CreateTriggerSkill{
  name = "zhengu",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper),
      1, 1, "#zhengu-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local mark = to:getMark("@@zhengu")
    if mark == 0 then mark = {} end
    table.insertIfNeed(mark, player.id)
    room:setPlayerMark(to, "@@zhengu", mark)
    local x, y, z = player:getHandcardNum(), to:getHandcardNum(), 0
    if x > y then
      z = math.min(5, x) - y
      if z > 0 then
        room:drawCards(to, z, self.name)
      end
    elseif x < y then
      z = y-x
      room:askForDiscard(to, z, z, false, self.name, false)
    end
  end,

  refresh_events = {fk.BuryVictim, fk.AfterTurnEnd},
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@zhengu") ~= 0 and (event == fk.BuryVictim or player == target)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.BuryVictim then
      local mark = player:getMark("@@zhengu")
      if type(mark) == "table" and table.removeOne(mark, target.id) then
        room:setPlayerMark(player, "@@zhengu", #mark > 0 and mark or 0)
      end
    elseif event == fk.AfterTurnEnd then
      room:setPlayerMark(player, "@@zhengu", 0)
    end
  end,
}
local zhengu_delay = fk.CreateTriggerSkill{
  name = "#zhengu_delay",
  events = {fk.TurnEnd},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target.dead or player.dead then return false end
    local mark = target:getMark("@@zhengu")
    if type(mark) == "table" and table.contains(mark, player.id) then
      local x, y = player:getHandcardNum(), target:getHandcardNum()
      return x < y or (x > y and y < 5)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, zhengu.name)
    player:broadcastSkillInvoke(zhengu.name)
    room:doIndicate(player.id, {target.id})
    local x, y, z = player:getHandcardNum(), target:getHandcardNum(), 0
    if x > y then
      z = math.min(5, x) - y
      if z > 0 then
        room:drawCards(target, z, self.name)
      end
    elseif x < y then
      z = y-x
      room:askForDiscard(target, z, z, false, self.name, false)
    end
  end,
}
zhengu:addRelatedSkill(zhengu_delay)
haozhao:addSkill(zhengu)
Fk:loadTranslationTable{
  ["haozhao"] = "郝昭",
  ["zhengu"] = "镇骨",
  [":zhengu"] = "结束阶段，你可以选择一名其他角色，本回合结束时和其下个回合结束时，其将手牌摸或弃至与你手牌数量相同（至多摸至五张）。",

  ["#zhengu_delay"] = "镇骨",
  ["@@zhengu"] = "镇骨",
  ["#zhengu-choose"] = "镇骨：选择一名其他角色，本回合结束时和其下个回合结束时其将手牌调整与你相同",

  ["$zhengu1"] = "镇守城池，必以骨相拼！",
  ["$zhengu2"] = "孔明计虽百算，却难敌吾镇骨千具！",
  ["~haozhao"] = "镇守陈仓，也有一失。",
}

local guanqiujian = General(extension, "guanqiujian", "wei", 4)
local zhengrong = fk.CreateTriggerSkill{
  name = "zhengrong",
  anim_type = "control",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not data.to.dead and data.to:getHandcardNum() > player:getHandcardNum()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#zhengrong-invoke::"..data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {data.to.id})
    local card = room:askForCardChosen(player, data.to, "he", self.name)
    player:addToPile("guanqiujian__glory", card, false, self.name)
  end,
}
local hongju = fk.CreateTriggerSkill{
  name = "hongju",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return #player:getPile("guanqiujian__glory") > 2 and table.find(player.room.players, function(p) return p.dead end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player:isKongcheng() then
      local results = U.askForExchange(player, "guanqiujian__glory", "$Hand",
        player:getPile("guanqiujian__glory"), player:getCardIds("h"), "#hongju-exchange", 999)
      local cards1, cards2 = {}, {}
      for _, id in ipairs(results) do
        if room:getCardArea(id) == Player.Hand then
          table.insert(cards1, id)
        else
          table.insert(cards2, id)
        end
      end
      local move1 = {
        ids = cards2,
        from = player.id,
        to = player.id,
        fromArea = Card.PlayerSpecial,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
        skillName = self.name,
      }
      local move2 = {
        ids = cards1,
        from = player.id,
        to = player.id,
        fromArea = Card.PlayerHand,
        toArea = Card.PlayerSpecial,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
        specialName = "guanqiujian__glory",
        skillName = self.name,
      }
      room:moveCards(move1, move2)
    end
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, "qingce", nil, true, false)
  end,
}
local qingce = fk.CreateActiveSkill{
  name = "qingce",
  anim_type = "control",
  target_num = 1,
  card_num = 1,
  prompt = "#qingce",
  expand_pile = "guanqiujian__glory",
  target_filter = function(self, to_select, selected)
    return #Fk:currentRoom():getPlayerById(to_select):getCardIds("ej") > 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "guanqiujian__glory"
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCardTo(effect.cards, Card.DiscardPile, player, fk.ReasonPutIntoDiscardPile, self.name, "guanqiujian__glory")
    if #target:getCardIds("ej") > 0 then
      local card = room:askForCardChosen(player, target, "ej", self.name)
      room:throwCard({card}, self.name, target, player)
    end
  end,
}
guanqiujian:addSkill(zhengrong)
guanqiujian:addSkill(hongju)
guanqiujian:addRelatedSkill(qingce)
Fk:loadTranslationTable{
  ["guanqiujian"] = "毌丘俭",
  ["zhengrong"] = "征荣",
  [":zhengrong"] = "当你对其他角色造成伤害后，若其手牌数大于你，你可以将其一张牌置于你的武将牌上，称为“荣”。",
  ["hongju"] = "鸿举",
  [":hongju"] = "觉醒技，准备阶段，若“荣”的数量不小于3且场上有角色死亡，你可以用任意张手牌替换等量的“荣”，减1点体力上限，获得〖清侧〗。",
  ["qingce"] = "清侧",
  [":qingce"] = "出牌阶段，你可以移去一张“荣”，然后弃置场上的一张牌。",
  ["guanqiujian__glory"] = "荣",
  ["#zhengrong-invoke"] = "征荣：是否将 %dest 一张牌置为“荣”？",
  ["#hongju-exchange"] = "鸿举：你可以用手牌交换“荣”",
  ["#qingce"] = "清侧：你可以移去一张“荣”，弃置场上的一张牌",

  ["$zhengrong1"] = "东征高句丽，保辽东安稳。",
  ["$zhengrong2"] = "跨海东征，家国俱荣。",
  ["$hongju1"] = "一举拿下，鸿途可得。",
  ["$hongju2"] = "鸿飞荣升，举重若轻。",
  ["$qingce1"] = "感明帝之恩，清君侧之贼。",
  ["$qingce2"] = "得太后手诏，清奸佞乱臣。",
  ["~guanqiujian"] = "峥嵘一生，然被平民所击射！",
}

local chendao = General(extension, "chendao", "shu", 4)
local wangliec = fk.CreateTriggerSkill{
  name = "wangliec",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:hasSkill(self) and
      (data.card:isCommonTrick() or data.card.trueName == "slash")
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#wangliec-invoke:::"..data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(player.room.alive_players) do
      table.insertIfNeed(data.disresponsiveList, p.id)
    end
    player.room:addPlayerMark(player, "@wangliec-phase", 1)
  end,

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "wanglie-phase", 1)
  end,
}
local wanglie_targetmod = fk.CreateTargetModSkill{
  name = "#wanglie_targetmod",
  bypass_distances =  function(self, player, skill, card, to)
    return card and player:hasSkill("wangliec") and player.phase == Player.Play and player:getMark("wanglie-phase") == 0
  end,
}
local wanglie_prohibit = fk.CreateProhibitSkill{
  name = "#wanglie_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@wangliec-phase") > 0
  end,
}
wangliec:addRelatedSkill(wanglie_targetmod)
wangliec:addRelatedSkill(wanglie_prohibit)
chendao:addSkill(wangliec)
Fk:loadTranslationTable{
  ["chendao"] = "陈到",
  ["wangliec"] = "往烈",
  [":wangliec"] = "出牌阶段，你使用的第一张牌无距离限制。你于出牌阶段使用【杀】或普通锦囊牌时，你可以令此牌无法响应，然后本阶段你不能再使用牌。",
  ["#wangliec-invoke"] = "往烈：你可以令%arg无法响应，然后你本阶段不能再使用牌",
  ["@wangliec-phase"] = "往烈",

  ["$wangliec1"] = "猛将之烈，统帅之所往。",
  ["$wangliec2"] = "与子龙忠勇相往，猛烈相合。",
  ["~chendao"] = "我的白毦兵，再也不能为先帝出力了。",
}

local zhugezhan = General(extension, "zhugezhan", "shu", 3)
local zuilun = fk.CreateTriggerSkill{
  name = "zuilun",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and target:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    local events = player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function(e)
      local damage = e.data[5]
      return damage and player == damage.from
    end, Player.HistoryTurn)
    if #events > 0 then
      n = n + 1
    end
    events = room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard and table.find(move.moveInfo, function (info)
          return info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip
        end) then
          return true
        end
      end
    end, Player.HistoryTurn)
    if #events == 0 then
      n = n + 1
    end
    if table.every(room.alive_players, function(p) return p:getHandcardNum() >= player:getHandcardNum() end) then
      n = n + 1
    end
    local cards = room:getNCards(3)
    local result = room:askForGuanxing(player, cards, {3 - n, 3 - n}, {n, n}, self.name, true, {"zuilun_top", "zuilun_get"})
    if #result.top > 0 then
      for i = #result.top, 1, -1 do
        table.insert(room.draw_pile, 1, result.top[i])
      end
      room:sendLog{
        type = "#GuanxingResult",
        from = player.id,
        arg = #result.top,
        arg2 = #result.bottom,
      }
    end
    if #result.bottom > 0 then
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(result.bottom)
      room:obtainCard(player.id, dummy, false, fk.ReasonJustMove)
    end
    if n == 0 and not player.dead then
      local targets = table.map(room:getOtherPlayers(player), Util.IdMapper)
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#zuilun-choose", self.name, false)
      if #to > 0 then
        to = room:getPlayerById(to[1])
      else
        to = room:getPlayerById(table.random(targets))
      end
      room:loseHp(player, 1, self.name)
      room:loseHp(to, 1, self.name)
    end
  end,
}
local fuyin = fk.CreateTriggerSkill{
  name = "fuyin",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and table.contains({"slash", "duel"}, data.card.trueName)
      and player:getMark("fuyin-turn") == 0
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("fuyin-turn") == 0 then
      room:setPlayerMark(player, "fuyin-turn", 1)
      local src = room:getPlayerById(data.from)
      if src and not src.dead and src:getHandcardNum() >= player:getHandcardNum() then
        self:doCost(event, target, player, data)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    table.insertIfNeed(data.nullifiedTargets, player.id)
  end,
}
zhugezhan:addSkill(zuilun)
zhugezhan:addSkill(fuyin)
Fk:loadTranslationTable{
  ["zhugezhan"] = "诸葛瞻",
  ["zuilun"] = "罪论",
  [":zuilun"] = "结束阶段，你可以观看牌堆顶三张牌，你每满足以下一项便获得其中的一张，然后以任意顺序放回其余的牌：1.你于此回合内造成过伤害；"..
  "2.你于此回合内未弃置过牌；3.手牌数为全场最少。若均不满足，你与一名其他角色失去1点体力。",
  ["fuyin"] = "父荫",
  [":fuyin"] = "锁定技，你每回合第一次成为【杀】或【决斗】的目标后，若你的手牌数不大于使用者，此牌对你无效。",
  ["zuilun_top"] = "置于牌堆顶",
  ["zuilun_get"] = "获得",
  ["#zuilun-choose"] = "罪论：选择一名其他角色，你与其各失去1点体力",

  ["$zuilun1"] = "吾有三罪，未能除黄皓、制伯约、守国土。",
  ["$zuilun2"] = "唉，数罪当论，吾愧对先帝恩惠。",
  ["$fuyin1"] = "得父荫庇，平步青云。",
  ["$fuyin2"] = "吾自幼心怀父诫，方不愧父亲荫庇。",
  ["~zhugezhan"] = "临难而死义，无愧先父。",
}

local zhoufei = General(extension, "zhoufei", "wu", 3, 3, General.Female)
local liangyin = fk.CreateTriggerSkill{
  name = "liangyin",
  mute = true,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerSpecial then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea ~= Card.PlayerSpecial then
              return table.find(player.room.alive_players, function(p)
                return p:getHandcardNum() > player:getHandcardNum() end)
            end
          end
        end
        if move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerSpecial then
              return table.find(player.room.alive_players, function(p)
                return p:getHandcardNum() < player:getHandcardNum() and not p:isNude() end)
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local dat = ""
    for _, move in ipairs(data) do
      if move.toArea == Card.PlayerSpecial then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea ~= Card.PlayerSpecial then
            dat = "drawcard"
          end
        end
      end
      if move.toArea ~= Card.PlayerSpecial then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerSpecial then
            dat = "discard"
          end
        end
      end
    end
    if dat ~= "" then
      self:doCost(event, target, player, dat)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets
    if data == "drawcard" then
      targets = table.map(table.filter(room.alive_players, function(p)
        return p:getHandcardNum() > player:getHandcardNum() end), Util.IdMapper)
    elseif data == "discard" then
      targets = table.map(table.filter(room.alive_players, function(p)
        return p:getHandcardNum() < player:getHandcardNum() and not p:isNude() end), Util.IdMapper)
    end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#liangyin-"..data, self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    if data == "drawcard" then
      room:notifySkillInvoked(player, self.name, "support")
      player:broadcastSkillInvoke(self.name)
      to:drawCards(1, self.name)
    elseif data == "discard" then
      room:notifySkillInvoked(player, self.name, "control")
      player:broadcastSkillInvoke(self.name)
      room:askForDiscard(to, 1, 1, true, self.name, false)
    end
  end,
}
local kongsheng = fk.CreateTriggerSkill{
  name = "kongsheng",
  anim_type = "special",
  events = {fk.EventPhaseStart},
  expand_pile = "zhoufei_harp",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and (player.phase == Player.Start or
      (player.phase == Player.Finish and #player:getPile("zhoufei_harp") > 0))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if player.phase == Player.Start then
      local cards = room:askForCard(player, 1, 999, true, self.name, true, ".", "#kongsheng-invoke")
      if #cards > 0 then
        self.cost_data = cards
        return true
      end
    elseif player.phase == Player.Finish then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if player.phase == Player.Start then
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(self.cost_data)
      player:addToPile("zhoufei_harp", self.cost_data, true, self.name)
    elseif player.phase == Player.Finish then
      local room = player.room
      while true do
        if player.dead then break end
        local ids = table.filter(player:getPile("zhoufei_harp"), function(id)
          local card = Fk:getCardById(id)
          return card.type == Card.TypeEquip and U.canUseCardTo(room, player, player, card, false, false)
        end)
        if #ids == 0 then break end
        local id = room:askForCard(player, 1, 1, false, self.name, true, -- FIXME：默认返回值bug
          ".|.|.|zhoufei_harp|.|.|"..table.concat(ids), "#kongsheng-use", "zhoufei_harp")
        if #id > 0 then
          id = id[1]
        else
          id = table.random(ids)
        end
        room:useCard({
          from = player.id,
          tos = {{player.id}},
          card = Fk:getCardById(id),
        })
      end
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(player:getPile("zhoufei_harp"))
      room:obtainCard(player.id, dummy, true, fk.ReasonJustMove)
    end
  end,
}
zhoufei:addSkill(liangyin)
zhoufei:addSkill(kongsheng)
Fk:loadTranslationTable{
  ["zhoufei"] = "周妃",
  ["liangyin"] = "良姻",
  [":liangyin"] = "当有牌移出游戏时，你可以令手牌数大于你的一名角色摸一张牌；当有牌从游戏外加入任意角色手牌时，你可以令手牌数小于你的一名角色弃置一张牌。",
  ["kongsheng"] = "箜声",
  [":kongsheng"] = "准备阶段，你可以将任意张牌置于武将牌上。结束阶段，你使用武将牌上的装备牌，并获得武将牌上的其他牌。",
  ["#liangyin-drawcard"] = "良姻：你可以令一名手牌数大于你的角色摸一张牌",
  ["#liangyin-discard"] = "良姻：你可以令一名手牌数小于你的角色弃置一张牌",
  ["#kongsheng-invoke"] = "箜声：你可以将任意张牌作为“箜”置于武将牌上",
  ["zhoufei_harp"] = "箜",
  ["#kongsheng-use"] = "箜声：请使用“箜”中的装备牌",

  ["$liangyin1"] = "结得良姻，固吴基业。",
  ["$liangyin2"] = "君恩之命，妾身良姻之福。",
  ["$kongsheng1"] = "窈窕淑女，箜篌有知。",
  ["$kongsheng2"] = "箜篌声声，琴瑟和鸣。",
  ["~zhoufei"] = "夫君，妾身再也不能陪你看这江南翠绿了。",
}

local lukang = General(extension, "lukang", "wu", 4)
local qianjie = fk.CreateTriggerSkill{
  name = "qianjie",
  events = {fk.BeforeChainStateChange},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player.chained
  end,
  on_use = Util.TrueFunc,
}
local qianjie_prohibit = fk.CreateProhibitSkill{
  name = "#qianjie_prohibit",
  frequency = Skill.Compulsory,
  is_prohibited = function(self, from, to, card)
    if to:hasSkill(self) then
      return card.sub_type == Card.SubtypeDelayedTrick
    end
  end,
  prohibit_pindian = function(self, from, to)
    return to:hasSkill(self)
  end
}
qianjie:addRelatedSkill(qianjie_prohibit)
lukang:addSkill(qianjie)
local jueyan = fk.CreateActiveSkill{
  name = "jueyan",
  can_use = function (self, player)
    return #player:getAvailableEquipSlots() > 0 and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  card_num = 0,
  target_num = 0,
  interaction = function()
    return UI.ComboBox {choices = Self:getAvailableEquipSlots()}
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local choice = self.interaction.data
    room:abortPlayerArea(player, choice)
    if player.dead then return end
    if choice == 'WeaponSlot' then
      room:addPlayerMark(player, "jueyan_residue-turn", 3)
    elseif choice == 'ArmorSlot' then
      room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 3)
      player:drawCards(3, self.name)
    elseif choice == 'TreasureSlot' then
      if not player:hasSkill("ex__jizhi",true) then
        room:handleAddLoseSkills(player, "ex__jizhi", nil, false)
        room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
          room:handleAddLoseSkills(player, "-ex__jizhi", nil, false)
        end)
      end
    else
      room:addPlayerMark(player, "jueyan_distance-turn")
    end
  end,
}
local jueyan_targetmod = fk.CreateTargetModSkill{
  name = "#jueyan_targetmod",
  residue_func = function(self, player, skill, scope, card)
    if skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return player:getMark("jueyan_residue-turn")
    end
  end,
  bypass_distances = function(self, player, skill, card, to)
    return player:getMark("jueyan_distance-turn") > 0
  end,
}
jueyan:addRelatedSkill(jueyan_targetmod)
lukang:addSkill(jueyan)
lukang:addRelatedSkill("ex__jizhi")
local poshi = fk.CreateTriggerSkill{
  name = "poshi",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and player:hasSkill(self) and target == player and player.phase == Player.Start
  end,
  can_wake = function(self, event, target, player, data)
    return #player:getAvailableEquipSlots() == 0 or player.hp == 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if player.dead then return end
    local x = player.maxHp - player:getHandcardNum()
    if x > 0 then
      player:drawCards(x, self.name)
    end
    room:handleAddLoseSkills(player, "-jueyan|huairou")
  end,
}
lukang:addSkill(poshi)
local huairou = fk.CreateActiveSkill{
  name = "huairou",
  anim_type = "drawcard",
  can_use = function(self, player)
    return not player:isNude()
  end,
  card_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected < 1 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_num = 0,
  on_use = function(self, room, effect)
    room:recastCard(effect.cards, room:getPlayerById(effect.from), self.name)
  end,
}
lukang:addRelatedSkill(huairou)
Fk:loadTranslationTable{
  ["lukang"] = "陆抗",
  ["qianjie"] = "谦节",
  [":qianjie"] = "锁定技，你被横置前防止之，且不能成为延时类锦囊牌或其他角色拼点的目标。",
  ["#qianjie_prohibit"] = "谦节",
  ["jueyan"] = "决堰",
  [":jueyan"] = "出牌阶段限一次，你可以废除你装备区里的一种装备栏，然后执行对应的一项：武器栏，你于此回合内可以多使用三张【杀】；防具栏，摸三张牌，本回合手牌上限+3；坐骑栏，本回合你使用牌无距离限制；宝物栏，本回合获得〖集智〗。",
  ["poshi"] = "破势",
  [":poshi"] = "觉醒技，准备阶段，若你所有装备栏均被废除或体力值为1，则你减1点体力上限，然后将手牌摸至体力上限，失去〖决堰〗，获得〖怀柔〗。",
  ["huairou"] = "怀柔",
  [":huairou"] = "出牌阶段，你可以重铸一张装备牌。",
  ["$qianjie1"] = "继父之节，谦逊恭毕。",
  ["$qianjie2"] = "谦谦清廉德，节节卓尔茂。",
  ["$jueyan1"] = "毁堰坝之计，实为阻晋粮道。",
  ["$jueyan2"] = "堰坝毁之，可令敌军自退。",
  ["$poshi1"] = "破羊祜之策，势在必行！",
  ["$poshi2"] = "破晋军分进合击之势，牵晋军主力之实！",
  ["$ex__jizhi_lukang"] = "智父安能有愚子乎？",
  ["$huairou1"] = "各保分界，无求细利。",
  ["$huairou2"] = "胸怀千万，彰其德，包其柔。",
  ["~lukang"] = "吾即亡矣，吴又能存几时？",
}

local yuanshu = General(extension, "thunder__yuanshu", "qun", 4)
local thunder__yongsi = fk.CreateTriggerSkill{
  name = "thunder__yongsi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards, fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.DrawNCards then
        return true
      else
        if player.phase == Player.Play then
          local n = 0
          player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 999, function(e)
            local damage = e.data[5]
            if damage and player == damage.from then
              n = n + damage.damage
            end
          end, Player.HistoryTurn)
          return (n == 0 and player:getHandcardNum() < player.hp) or n > 1
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.DrawNCards then
      local kingdoms = {}
      for _, p in ipairs(room.alive_players) do
        table.insertIfNeed(kingdoms, p.kingdom)
      end
      data.n = #kingdoms
    else
      local n = 0
      player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 999, function(e)
        local damage = e.data[5]
        if damage and player == damage.from then
          n = n + damage.damage
        end
      end, Player.HistoryTurn)
      if n == 0 and player:getHandcardNum() < player.hp then
        player:drawCards(player.hp - player:getHandcardNum(), self.name)
      elseif n > 1 then
        room:addPlayerMark(player, "yongsi-turn", 1)
      end
    end
  end,
}
local yongsi_maxcards = fk.CreateMaxCardsSkill{
  name = "#yongsi_maxcards",
  fixed_func = function (self, player)
    if player:getMark("yongsi-turn") ~= 0 then
      return player:getLostHp()
    end
  end,
}
thunder__yongsi:addRelatedSkill(yongsi_maxcards)
yuanshu:addSkill(thunder__yongsi)
Fk:loadTranslationTable{
  ["thunder__yuanshu"] = "袁术",
  ["thunder__yongsi"] = "庸肆",
  [":thunder__yongsi"] = "锁定技，摸牌阶段，你改为摸X张牌（X为场上现存势力数）。出牌阶段结束时，若你本回合没有造成过伤害，你将手牌补至当前体力值；"..
  "若造成过伤害且大于1点，你本回合手牌上限改为已损失体力值。",

  ["$thunder__yongsi1"] = "天下，即将尽归吾袁公路！",
  ["$thunder__yongsi2"] = "朕今日雄踞淮南，明日便可一匡天下。",
  ["~thunder__yuanshu"] = "仲朝国祚，本应千秋万代，薪传不息……",
}

local zhangxiu = General(extension, "zhangxiu", "qun", 4)
local xiongluan = fk.CreateActiveSkill{
  name = "xiongluan",
  anim_type = "offensive",
  target_num = 1,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
    (#player:getAvailableEquipSlots() > 0 or not table.contains(player.sealedSlots, Player.JudgeSlot))
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return Self.id ~= to_select
  end,
  on_use = function(self, room, effect)
    local to = room:getPlayerById(effect.tos[1])
    local player = room:getPlayerById(effect.from)
    local eqipSlots = player:getAvailableEquipSlots()
    if not table.contains(player.sealedSlots, Player.JudgeSlot) then
      table.insert(eqipSlots, Player.JudgeSlot)
    end
    room:abortPlayerArea(player, eqipSlots)
    room:addPlayerMark(to, "@@xiongluan-turn")
    local targetRecorded = type(player:getMark("xiongluan_target-turn")) == "table" and player:getMark("xiongluan_target-turn") or {}
    table.insertIfNeed(targetRecorded, to.id)
    room:setPlayerMark(player, "xiongluan_target-turn", targetRecorded)
  end,
}
local xiongluan_prohibit = fk.CreateProhibitSkill{
  name = "#xiongluan_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@@xiongluan-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds(Player.Hand), id)
      end)
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("@@xiongluan-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds(Player.Hand), id)
      end)
    end
  end,
}
local xiongluan_targetmod = fk.CreateTargetModSkill{
  name = "#xiongluan_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    if card and to then
      local targetRecorded = player:getMark("xiongluan_target-turn")
      return type(targetRecorded) == "table" and table.contains(targetRecorded, to.id)
    end
  end,
  bypass_distances = function(self, player, skill, card, to)
    if card and to then
      local targetRecorded = player:getMark("xiongluan_target-turn")
      return type(targetRecorded) == "table" and table.contains(targetRecorded, to.id)
    end
  end,
}
xiongluan:addRelatedSkill(xiongluan_targetmod)
xiongluan:addRelatedSkill(xiongluan_prohibit)
local congjian = fk.CreateTriggerSkill{
  name = "congjian",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.type == Card.TypeTrick and #AimGroup:getAllTargets(data.tos) > 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = AimGroup:getAllTargets(data.tos)
    table.removeOne(targets, player.id)
    local tos, cardId = room:askForChooseCardAndPlayers(player, targets, 1, 1, nil, "#congjian-give", self.name, true)
    if #tos > 0 then
      self.cost_data = {tos[1], cardId}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = Fk:getCardById(self.cost_data[2]).type == Card.TypeEquip and 2 or 1
    room:obtainCard(self.cost_data[1], self.cost_data[2], false, fk.ReasonGive)
    if not player.dead then
      player:drawCards(x, self.name)
    end
  end,
}
zhangxiu:addSkill(xiongluan)
zhangxiu:addSkill(congjian)
Fk:loadTranslationTable{
  ["zhangxiu"] = "张绣",
  ["xiongluan"] = "雄乱",
  [":xiongluan"] = "限定技，出牌阶段，你可以废除你的判定区和装备区，然后指定一名其他角色。直到回合结束，你对其使用牌无距离和次数限制，其不能使用和打出手牌。",
  ["congjian"] = "从谏",
  [":congjian"] = "当你成为锦囊牌的目标时，若此牌的目标数大于1，则你可以交给其中一名其他目标角色一张牌，然后摸一张牌，若你给出的是装备牌，改为摸两张牌。",
  ["@@xiongluan-turn"] = "雄乱",
  ["#congjian-give"] = "从谏：你可以选择一名为目标的其他角色，交给其一张牌，然后你摸一张牌。若你以此法交出的是装备牌，改为摸两张牌。",
  ["$xiongluan1"] = "北地枭雄，乱世不败！！",
  ["$xiongluan2"] = "雄据宛城，虽乱世可安！",
  ["$congjian1"] = "听君谏言，去危亡，保宗祀!",
  ["$congjian2"] = "从谏良计，可得自保！",
  ["~zhangxiu"] = "若失文和……吾将何归……",
}

return extension