local extension = Package("thunder")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["thunder"] = "雷",
}
local yuanshu = General(extension, "thunder__yuanshu", "qun", 4)
local thunder__yongsi = fk.CreateTriggerSkill{
  name = "thunder__yongsi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards, fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
      local num = #player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 99, function (e)
          local damage = e.data[5]
         if damage and player == damage.from and player ~= damage.to then
           return true
         end
      end, Player.HistoryTurn)
    if target == player and player:hasSkill(self.name) then
      if event == fk.EventPhaseEnd then
                   return player.phase == Player.Play and (num == 0 and player:getHandcardNum() < player.hp) or num > 1
      end
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local kingdoms = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    if event == fk.DrawNCards then
      data.n = #kingdoms
    else
       local num = #player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 99, function (e)
          local damage = e.data[5]
         if damage and player == damage.from and player ~= damage.to then
           return true
         end
       end, Player.HistoryTurn)
      if num == 0 and player:getHandcardNum() < player.hp then
        player:drawCards(player.hp - player:getHandcardNum(), self.name)
      elseif num > 1 then
        player.room:addMark(player, "yongsi-turn", 1)
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
  [":thunder__yongsi"] = "锁定技，摸牌阶段，你改为摸X张牌（X为场上现存势力数）。出牌阶段结束时，若你没有造成过伤害，你将手牌补至当前体力值，"..
  "若造成过伤害且大于1点，你本回合手牌上限改为已损失的体力值。",
}
local chendao = General(extension, "chendao", "shu", 4)
local cd_wanglie = fk.CreateTriggerSkill{
  name = "cd_wanglie",
  frequency = Skill.Compulsory,
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:hasSkill(self.name) and (data.card:isCommonTrick() or data.card.trueName == "slash")and player:getMark("@wanglie__debuff-phase") == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#wanglie-invoke:::"..data.card:toLogString())
  end, 
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(player.room:getOtherPlayers(player)) do
      table.insertIfNeed(data.disresponsiveList, p.id)
    end
    player.room:addPlayerMark(player, "@wanglie__debuff-phase", 1)
  end,
  
  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, true) and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "wanglie-phase", 1)
  end,
}
local wanglie_targetmod = fk.CreateTargetModSkill{
  name = "#wanglie_targetmod",
  distance_limit_func =  function(self, player, skill, card)
    if card and player:hasSkill("cd_wanglie") and player.phase == Player.Play and player:getMark("wanglie-phase") == 0 then
      return 999
    end
  end,
}
local wanglie_prohibit = fk.CreateProhibitSkill{
  name = "#wanglie_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@wanglie__debuff-phase") > 0
  end,
}
cd_wanglie:addRelatedSkill(wanglie_targetmod)
cd_wanglie:addRelatedSkill(wanglie_prohibit)
chendao:addSkill(cd_wanglie)
Fk:loadTranslationTable{
  ["chendao"] = "陈到",
  ["cd_wanglie"] = "往烈",
  [":cd_wanglie"] = "锁定技，你于出牌阶段使用的第一张牌无距离限制。你于出牌阶段使用【杀】或普通锦囊牌时，你可以令此牌无法响应，然后本阶段你不能再使用牌。",
  ["#wanglie-invoke"] = "往烈：你可以令%arg无法响应，然后你本阶段无法再使用牌",
  ["@wanglie__debuff-phase"] = "往烈",
}
local haozhao = General(extension, "haozhao", "wei", 4)
local zhengu = fk.CreateTriggerSkill{
  name = "zhengu",
  anim_type = "masochism",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and player.phase == Player.Finish then
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
     if target == player then
       local to = room:askForChoosePlayers(player,  table.map(room:getOtherPlayers(player, true), function(p) return p.id end), 1, 1, "#zhengu-choose", self.name, true)
       if #to > 0 then
         self.cost_data = to[1]
         return true
       end
     end
  end,
  on_use = function(self, event, target, player, data)
    local to = player.room:getPlayerById(self.cost_data)
    local mark = player:getMark("zhengupy")
    if to:getMark("@@zhengu") == 0 then
      player.room:addPlayerMark(to, "@@zhengu")
      if mark == 0 then mark = {} end
       table.insert(mark, to.id)
       player.room:setPlayerMark(player, "zhengupy", mark)
    end
    local num1 = math.abs(#player.player_cards[Player.Hand] - #to.player_cards[Player.Hand])
    if #player.player_cards[Player.Hand] >#to.player_cards[Player.Hand] then
       to:drawCards(math.min(num1, 5)- to:getHandcardNum())
    else
       player.room:askForDiscard(to, num1, num1, false, self.name, false)
    end
  end,
  
  refresh_events = {fk.Death, fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
     local mark = player:getMark("zhengupy")
    if mark ~= 0 then
      if event == fk.Death then
        return target == player
      else
        if target:getMark("@@zhengu") > 0 and target.phase == Player.Finish  and table.contains(mark, target.id) then
           self.cost_data = target.id
          return  true
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Death then
      room:setPlayerMark(player, "zhengupy", 0)
      local targets = room:getOtherPlayers(player, true)
      table.forEach(targets, function(p)
         if target:getMark("@@zhengu") > 0 then  
           room:setPlayerMark(p, "@@zhengu", 0) 
         end
      end)
    else
       local to = player.room:getPlayerById(self.cost_data) 
       local mark = player:getMark("zhengupy")
        room:setPlayerMark(to, "@@zhengu", 0)
       table.removeOne(mark, to.id)
        room:setPlayerMark(player, "zhengupy", mark)
       local num1 = math.abs(#player.player_cards[Player.Hand] - #to.player_cards[Player.Hand])
      if #player.player_cards[Player.Hand] >#to.player_cards[Player.Hand] then
        to:drawCards(math.min(num1, 5)- to:getHandcardNum())
      else
         player.room:askForDiscard(to, num1, num1, false, self.name, false)
      end
    end
  end,
}
haozhao:addSkill(zhengu)
Fk:loadTranslationTable{
  ["haozhao"] = "郝昭",
  ["@@zhengu"] = "镇骨",
  ["zhengu"] = "镇骨",
  [":zhengu"] = "结束阶段，你可以选择一名其他角色，你的回合结束后和该角色的下个回合结束时，其将手牌摸至或弃至与你手牌数量相同。（至多摸至五张）",
  ["#zhengu-choose"] = "镇骨：选择一名其他角色，你和其下个回合结束时其将手牌调整与你数量相同。",
}

return extension