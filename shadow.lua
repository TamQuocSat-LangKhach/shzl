local extension = Package:new("shadow")
extension.extensionName = "shzl"
Fk:loadTranslationTable{
  ["shadow"] = "神话再临·阴",
}
local U = require "packages/utility/utility"
local wangji = General(extension, "wangji", "wei", 3)
local qizhi = fk.CreateTriggerSkill{
  name = "qizhi",
  anim_type = "control",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase ~= Player.NotActive and
      data.firstTarget and data.card.type ~= Card.TypeEquip
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p)
      return not p:isNude() and not table.contains(AimGroup:getAllTargets(data.tos), p.id) end), Util.IdMapper)
    if #targets == 0 then return end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#qizhi-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = tos[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@qizhi-turn", 1)
    local to = room:getPlayerById(self.cost_data)
    local id = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard({id}, self.name, to, player)
    if not to.dead then
      to:drawCards(1, self.name)
    end
  end,
}
local jinqu = fk.CreateTriggerSkill{
  name = "jinqu",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
    local n = #player:getCardIds("h") - player:usedSkillTimes("qizhi", Player.HistoryTurn)
    if n > 0 then
      player.room:askForDiscard(player, n, n, false, self.name, false)
    end
  end,
}
wangji:addSkill(qizhi)
wangji:addSkill(jinqu)
Fk:loadTranslationTable{
  ["wangji"] = "王基",
  ["#wangji"] = "经行合一",
  ["illustrator:wangji"] = "雪君S",
  ["designer:wangji"] = "韩旭",

  ["qizhi"] = "奇制",
  [":qizhi"] = "当你于回合内使用非装备牌指定目标后，你可以弃置一名不为目标的角色的一张牌，然后令其摸一张牌。",
  ["jinqu"] = "进趋",
  [":jinqu"] = "结束阶段，你可以摸两张牌，然后将手牌弃至X张（X为你本回合发动〖奇制〗的次数）。",
  ["@qizhi-turn"] = "奇制",
  ["#qizhi-choose"] = "奇制：你可以弃置一名角色一张牌，然后其摸一张牌",

  ["$qizhi1"] = "声东击西，敌寇一网成擒。",
  ["$qizhi2"] = "吾意不在此地，已遣别部出发。",
  ["$jinqu1"] = "建上昶水城，以逼夏口！",
  ["$jinqu2"] = "通川聚粮，伐吴之业，当步步为营。",
  ["~wangji"] = "天下之势，必归大魏，可恨，未能得见呐！",
}

local kuailiangkuaiyue = General(extension, "kuailiangkuaiyue", "wei", 3)
local jianxiang = fk.CreateTriggerSkill{
  name = "jianxiang",
  anim_type = "support",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and data.from ~= player.id
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return table.every(room.alive_players, function(p2)
        return p2:getHandcardNum() >= p:getHandcardNum() end) end)
    targets = table.map(targets, Util.IdMapper)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#jianxiang-invoke", self.name)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:getPlayerById(self.cost_data):drawCards(1, self.name)
  end,
}
local shenshi = fk.CreateActiveSkill{
  name = "shenshi",
  anim_type = "switch",
  switch_skill_name = "shenshi",
  card_num = 1,
  target_num = 1,
  prompt = "#shenshi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude() and
      player:getSwitchSkillState(self.name, false) == fk.SwitchYang
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 and to_select ~= Self.id then
      local n = 0
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= Self and p:getHandcardNum() > n then
          n = p:getHandcardNum()
        end
      end
      return Fk:currentRoom():getPlayerById(to_select):getHandcardNum() == n
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target.id, effect.cards[1], true, fk.ReasonGive)
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
    if target.dead and not player.dead and table.find(room.alive_players, function(p) return p:getHandcardNum() < 4 end) then
      local targets = table.map(table.filter(room.alive_players, function(p) return p:getHandcardNum() < 4 end), Util.IdMapper)
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#shenshi-choose", self.name, true)
      if #to > 0 then
        local p = room:getPlayerById(to[1])
        p:drawCards(4 - p:getHandcardNum(), self.name)
      end
    end
  end,
}
local shenshiYin = fk.CreateTriggerSkill{
  name = "#shenshiYin",
  main_skill = shenshi,
  switch_skill_name = "shenshi",
  mute = true,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill("shenshi") and player:getSwitchSkillState("shenshi", false) == fk.SwitchYin and
      data.from and data.from ~= player and not data.from.dead and not data.from:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "shenshi", nil, "#shenshi-invoke::"..data.from.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("shenshi")
    room:notifySkillInvoked(player, "shenshi", "switch")
    local from = data.from
    room:doIndicate(player.id, {from.id})
    if not from:isKongcheng() then
      U.viewCards (player, from:getCardIds(Player.Hand), "shenshi")
    end
    if player:isNude() then return end
    local card = room:askForCard(player, 1, 1, true, "shenshi", false, ".", "#shenshi-give::"..data.from.id)
    room:obtainCard(from.id, card[1], false, fk.ReasonGive)
    local mark = U.getMark(player, "shenshi-turn")
    table.insert(mark, {from.id, card[1]})
    room:setPlayerMark(player, "shenshi-turn", mark)
  end,
}
local shenshi_trigger = fk.CreateTriggerSkill{
  name = "#shenshi_trigger",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target.phase == Player.Finish and player:getMark("shenshi-turn") ~= 0 and player:getHandcardNum() < 4 then
      for _, t in ipairs(player:getMark("shenshi-turn")) do
        local p = player.room:getPlayerById(t[1])
        if p and table.contains(p:getCardIds("he"), t[2]) then
          return true
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("shenshi")
    room:notifySkillInvoked(player, "shenshi", "drawcard")
    player:drawCards(4 - player:getHandcardNum(), "shenshi")
  end,
}
shenshi:addRelatedSkill(shenshiYin)
shenshi:addRelatedSkill(shenshi_trigger)
kuailiangkuaiyue:addSkill(jianxiang)
kuailiangkuaiyue:addSkill(shenshi)
Fk:loadTranslationTable{
  ["kuailiangkuaiyue"] = "蒯良蒯越",
  ["#kuailiangkuaiyue"] = "雍论臼谋",
  ["cv:kuailiangkuaiyue"] = "曹真",
  ["illustrator:kuailiangkuaiyue"] = "北辰菌",
  ["jianxiang"] = "荐降",
  [":jianxiang"] = "当你成为其他角色使用牌的目标后，你可以令手牌数最少的一名角色摸一张牌。",
  ["shenshi"] = "审时",
  [":shenshi"] = "转换技，阳：出牌阶段限一次，你可以交给手牌数最多的其他角色一张牌，并对其造成1点伤害。然后若其死亡，你可以令一名角色将手牌摸至四张。"..
  "阴：当有手牌的其他角色对你造成伤害后，你可以观看其手牌，并交给其一张牌；当前回合结束阶段，若此牌仍在其手牌或装备区，你将手牌摸至四张。",
  ["#jianxiang-invoke"] = "荐降：你可以令手牌数最少的一名角色摸一张牌",
  ["#shenshi"] = "审时：交给手牌数最多的其他角色一张牌，并对其造成1点伤害",
  ["#shenshi-choose"] = "审时：你可以令一名角色将手牌摸至四张",
  ["#shenshi-invoke"] = "审时：你可以观看 %dest 的手牌并交给其一张牌",
  ["#shenshi-give"] = "审时：交给 %dest 一张牌，若本回合结束阶段仍属于其，你将手牌摸至四张",
  ["#shenshiYin"] = "审时",

  ["$jianxiang1"] = "曹公得荆不喜，喜得吾二人足矣。",
  ["$jianxiang2"] = "得遇曹公，吾之幸也。",
  ["$shenshi1"] = "深中足智，鉴时审情。",
  ["$shenshi2"] = "数语之言，审时度势。",
  ["~kuailiangkuaiyue"] = "表不能善用，所憾也……",
}

local yanyan = General(extension, "yanyan", "shu", 4)
local juzhan = fk.CreateTriggerSkill{
  name = "juzhan",
  switch_skill_name = "juzhan",
  anim_type = "switch",
  events = { fk.TargetSpecified, fk.TargetConfirmed },
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and
      data.card.trueName == 'slash') then return end

    local isYang = player:getSwitchSkillState(self.name) == fk.SwitchYang
    if event == fk.TargetConfirmed and isYang then
      return player.id ~= data.from
    elseif event == fk.TargetSpecified and not isYang then
      return not player.room:getPlayerById(data.to):isNude()
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local isYang = player:getSwitchSkillState(self.name, true) == fk.SwitchYang
    local aim = data ---@type AimStruct

    if isYang then
      local from = room:getPlayerById(aim.from)
      player:drawCards(1, self.name)
      from:drawCards(1, self.name)
      local x = from:getMark("@@juzhan-turn")
      if x == 0 then x = {} end
      table.insert(x, player.id)
      room:setPlayerMark(from, "@@juzhan-turn", x)
    else
      local to = room:getPlayerById(aim.to)
      local from = player
      local c = room:askForCardChosen(from, to, "he", self.name)
      room:obtainCard(from, c, false)
      local x = from:getMark("@@juzhan-turn")
      if x == 0 then x = {} end
      table.insert(x, to.id)
      room:setPlayerMark(from, "@@juzhan-turn", x)
    end
  end,
}
local juzhan_prohibit = fk.CreateProhibitSkill{
  name = "#juzhan_prohibit",
  is_prohibited = function(self, from, to)
    local x = from:getMark("@@juzhan-turn")
    if x == 0 then return false end
    return table.contains(x, to.id)
  end,
}
juzhan:addRelatedSkill(juzhan_prohibit)
yanyan:addSkill(juzhan)
Fk:loadTranslationTable{
  ["yanyan"] = "严颜",
  ["#yanyan"] = "断头将军",
  ["illustrator:yanyan"] = "Town",
  ["juzhan"] = "拒战",
  [":juzhan"] = "转换技，阳：当你成为其他角色使用【杀】的目标后，你可以与其各摸一张牌，然后其本回合不能再对你使用牌。"..
  "阴：当你使用【杀】指定一名角色为目标后，你可以获得其一张牌，然后你本回合不能再对其使用牌。",
  ["@@juzhan-turn"] = "拒战",

  ["~yanyan"] = "宁可断头死，安能屈膝降！",
  ["$juzhan1"] = "砍头便砍头，何为怒耶！",
  ["$juzhan2"] = "我州但有断头将军，无降将军也！",
}

local wangping = General(extension, "wangping", "shu", 4)
local feijun = fk.CreateActiveSkill{
  name = "feijun",
  anim_type = "control",
  card_num = 1,
  target_num = 0,
  prompt = "#feijun",
  can_use = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    if player.dead then return end
    local targets = table.map(table.filter(room.alive_players, function(p)
      return p:getHandcardNum() > player:getHandcardNum() end), Util.IdMapper)
    table.insertTableIfNeed(targets, table.map(table.filter(room.alive_players, function(p)
      return #p:getCardIds("e") > #player:getCardIds("e") end), Util.IdMapper))
    if #targets == 0 then return end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#feijun-choose", self.name, false)
    if #to > 0 then
      to = room:getPlayerById(to[1])
    else
      to = room:getPlayerById(table.random(targets))
    end
    local choices = {}
    if to:getHandcardNum() > player:getHandcardNum() then
      table.insert(choices, "feijun1")
    end
    if #to:getCardIds("e") > #player:getCardIds("e") then
      table.insert(choices, "feijun2")
    end
    local choice = room:askForChoice(player, choices, self.name, "#feijun-choice::"..to.id)
    if choice == "feijun1" then
      local card = room:askForCard(to, 1, 1, true, self.name, false, ".", "#feijun-give:"..player.id)
      room:obtainCard(player, card[1], false, fk.ReasonGive)
    else
      room:askForDiscard(to, 1, 1, true, self.name, false, ".|.|.|equip", "#feijun-discard")
    end
  end,
}
local binglue = fk.CreateTriggerSkill{
  name = "binglue",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
      if e and e.data[2] == player and e.data[3] == feijun then
        local mark = U.getMark(player, "binglue")
        for _, move in ipairs(data) do
          if move.from ~= player.id and not table.contains(mark, move.from) then
            self.cost_data = move.from
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = U.getMark(player, "binglue")
    table.insert(mark, self.cost_data)
    room:setPlayerMark(player, "binglue", mark)
    player:drawCards(2, self.name)
  end,
}
wangping:addSkill(feijun)
wangping:addSkill(binglue)
Fk:loadTranslationTable{
  ["wangping"] = "王平",
  ["#wangping"] = "兵谋以致用",
  ["illustrator:wangping"] = "Yanbai",
  ["feijun"] = "飞军",
  [":feijun"] = "出牌阶段限一次，你可以弃置一张牌，然后选择一项：1.令一名手牌数大于你的角色交给你一张牌；2.令一名装备区里牌数大于你的角色"..
  "弃置一张装备区里的牌。",
  ["binglue"] = "兵略",
  [":binglue"] = "锁定技，当你首次对一名角色发动〖飞军〗结算后，你摸两张牌。",
  ["#feijun"] = "飞军：弃置一张牌，令一名手牌数/装备数大于你的角色交给你一张牌/弃置一张装备",
  ["#feijun-choose"] = "飞军：选择一名手牌数或装备数大于你的角色执行效果",
  ["feijun1"] = "交给你一张牌",
  ["feijun2"] = "弃置一张装备区的牌",
  ["#feijun-choice"] = "飞军：选择令 %dest 执行的一项",
  ["#feijun-discard"] = "飞军：弃置一张装备区里的牌",
  ["#feijun-give"] = "飞军：你需交给 %src 一张牌",

  ["$feijun1"] = "无当飞军，伐叛乱，镇蛮夷！",
  ["$feijun2"] = "山地崎岖，也挡不住飞军破势！",
  ["$binglue1"] = "奇略兵速，敌未能料之。",
  ["$binglue2"] = "兵略者，明战胜攻取之数，形机之势，诈谲之变。",
  ["~wangping"] = "无当飞军，也有困于深林之时……",
}

local luji = General(extension, "luji", "wu", 3)
local huaiju = fk.CreateTriggerSkill{
  name = "huaiju",
  events = {fk.GameStart, fk.DrawNCards, fk.DamageInflicted},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.GameStart then
      return true
    else
      return target:getMark("@orange") > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.DamageInflicted then
      player.room:removePlayerMark(target, "@orange")
      return true
    elseif event == fk.DrawNCards then
      data.n = data.n + 1
    elseif event == fk.GameStart then
      player.room:addPlayerMark(player, "@orange", 3)
    end
  end,
}
local yili = fk.CreateTriggerSkill{
  name = "yili",
  anim_type = "support",
  events = { fk.EventPhaseStart },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper)
    local result = room:askForChoosePlayers(player, targets, 1, 1, "#yili-choose", self.name)
    if #result > 0 then
      local tgt = result[1]
      if player:getMark("@orange") == 0 then
        self.cost_data = { tgt, "loseHp" }
        return true
      end
      local choice = room:askForChoice(player, { "loseHp", "yili_lose_orange" }, self.name)
      self.cost_data = { tgt, choice }
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local t, c = table.unpack(self.cost_data)
    if c == 'loseHp' then
      room:loseHp(player, 1, self.name)
    elseif c == 'yili_lose_orange' then
      room:removePlayerMark(player, "@orange")
    end
    room:addPlayerMark(room:getPlayerById(t), "@orange")
  end,
}
local zhenglun = fk.CreateTriggerSkill{
  name = "zhenglun",
  events = { fk.EventPhaseChanging },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to == Player.Draw and player:getMark("@orange") == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@orange")
    return true
  end,
}
luji:addSkill(huaiju)
luji:addSkill(yili)
luji:addSkill(zhenglun)
Fk:loadTranslationTable{
  ["luji"] = "陆绩",
  ["#luji"] = "瑚琏之器",
  ["cv:luji"] = "曹真",
  ["illustrator:luji"] = "秋呆呆",
  ["huaiju"] = "怀橘",
  [":huaiju"] = "锁定技，游戏开始时，你获得3枚“橘”标记。当有“橘”的角色受到伤害时，防止此伤害并移除1枚“橘”。有“橘”的角色摸牌阶段多摸一张牌。",
  ["yili"] = "遗礼",
  [":yili"] = "出牌阶段开始时，你可以失去1点体力或移除1枚“橘”，然后令一名其他角色获得1枚“橘”。",
  ["#yili-choose"] = "遗礼: 你可以失去1点体力或者移除1枚“橘”，令一名其他角色获得1枚“橘”",
  ["yili_lose_orange"] = "移除1枚“橘”",
  ["zhenglun"] = "整论",
  [":zhenglun"] = "摸牌阶段开始前，若你没有“橘”，你可以跳过摸牌阶段并获得1枚“橘”。",

  ["#huaiju_effect"] = "怀橘",
  ["@orange"] = "橘",
  ["$huaiju1"] = "情深舐犊，怀擢藏橘。",
  ["$huaiju2"] = "袖中怀绿桔，遗母报乳哺。",
  ["$yili2"] = "行遗礼之举，于不敬王者。",
  ["$yili1"] = "遗失礼仪，则俱非议。",
  ["$zhenglun1"] = "整论四海未泰，修文德以平。",
  ["$zhenglun2"] = "今论者不务道德怀取之术，而惟尚武，窃所未安。",
  ["~luji"] = "恨不能见，车同轨，书同文……",
}

local sunliang = General(extension, "sunliang", "wu", 3)
local kuizhu_active = fk.CreateActiveSkill{
  name = "kuizhu_active",
  interaction = function()
    return UI.ComboBox {choices = {"kuizhu_choice1", "kuizhu_choice2"}}
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  min_target_num = 1,
  target_filter = function(self, to_select, selected)
    if self.interaction.data == "kuizhu_choice1" then
      return #selected < Self:getMark("kuizhu")
    elseif self.interaction.data == "kuizhu_choice2" then
      local n = Fk:currentRoom():getPlayerById(to_select).hp
      for _, p in ipairs(selected) do
        n = n + Fk:currentRoom():getPlayerById(p).hp
      end
      return n <= Self:getMark("kuizhu")
    end
    return false
  end,
  feasible = function(self, selected, selected_cards)
    if #selected_cards ~= 0 or #selected == 0 or not self.interaction.data then return false end
    if self.interaction.data == "kuizhu_choice1" then
      return #selected <= Self:getMark("kuizhu")
    else
      local n = 0
      for _, p in ipairs(selected) do
        n = n + Fk:currentRoom():getPlayerById(p).hp
      end
      return n == Self:getMark("kuizhu")
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if self.interaction.data == "kuizhu_choice1" then
      room:setPlayerMark(player, "kuizhu_choice", 1)
    else
      room:setPlayerMark(player, "kuizhu_choice", 2)
    end
  end,
}
Fk:addSkill(kuizhu_active)
local kuizhu = fk.CreateTriggerSkill{
  name = "kuizhu",
  events = {fk.EventPhaseEnd},
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Discard and #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile and move.from == player.id and move.moveReason == fk.ReasonDiscard then
          return true
        end
      end
      return false
    end, Player.HistoryPhase) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile and move.from == player.id and move.moveReason == fk.ReasonDiscard then
          n = n + #move.moveInfo
        end
      end
      return false
    end, Player.HistoryPhase)
    if n == 0 then return false end
    room:setPlayerMark(player, self.name, n)
    local success, dat = room:askForUseActiveSkill(player, "kuizhu_active", "#kuizhu-use:::"..n, true)
    local choice = player:getMark("kuizhu_choice")
    if success then
      self.cost_data = {dat.targets, choice}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    local tos = table.map(self.cost_data[1], Util.Id2PlayerMapper)
    local choice = self.cost_data[2]
    if choice == 1 then
      room:notifySkillInvoked(player, self.name, "support")
      for _, p in ipairs(tos) do
        if not p.dead then
          p:drawCards(1, self.name)
        end
      end
    else
      room:notifySkillInvoked(player, self.name, "offensive")
      for _, p in ipairs(tos) do
        if not p.dead then
          room:damage { from = player, to = p, damage = 1, skillName = self.name }
        end
      end
      if not player.dead and #tos >= 2 then
        room:loseHp(player, 1, self.name)
      end
    end
  end,
}
sunliang:addSkill(kuizhu)
local chezheng = fk.CreateTriggerSkill{
  name = "chezheng",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Play then
      local targets = table.filter(player.room:getOtherPlayers(player), function(p) return not p:inMyAttackRange(player) end)
      local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
        local use = e.data[1]
        return use and use.from == target.id
      end, Player.HistoryPhase)
      return #events < #targets
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function(p) return not p:inMyAttackRange(player) and not p:isNude() end)
    if #targets > 0 then
      local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#chezheng-throw", self.name, false)
      if #tos > 0 then
        local to = room:getPlayerById(tos[1])
        local cid = room:askForCardChosen(player, to, "he", self.name)
        room:throwCard({cid}, self.name, to, player)
      end
    end
  end,
}
local chezheng_prohibit = fk.CreateProhibitSkill{
  name = "#chezheng_prohibit",
  frequency = Skill.Compulsory,
  is_prohibited = function (self, from, to, card)
    return from:hasSkill(self) and from.phase == Player.Play and from ~= to and not to:inMyAttackRange(from)
  end,
}
chezheng:addRelatedSkill(chezheng_prohibit)
sunliang:addSkill(chezheng)
local lijun = fk.CreateTriggerSkill{
  name = "lijun$",
  events = { fk.CardUseFinished },
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and target.kingdom == "wu" and data.card.trueName == "slash" and target.phase == Player.Play then
      local cardList = data.card:isVirtual() and data.card.subcards or {data.card.id}
      return table.find(cardList, function(id) return not player.room:getCardOwner(id) end)
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name, data, "#lijun-invoke:"..player.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cardList = data.card:isVirtual() and data.card.subcards or {data.card.id}
    local cards = table.filter(cardList, function(id) return not room:getCardOwner(id) end)
    if #cards == 0 then return end
    room:obtainCard(player, cards, true, fk.ReasonJustMove)
    if not player.dead and not target.dead and room:askForSkillInvoke(player, self.name, data, "#lijun-draw:"..target.id) then
      target:drawCards(1, self.name)
    end
  end,
}
sunliang:addSkill(lijun)
Fk:loadTranslationTable{
  ["sunliang"] = "孙亮",
  ["#sunliang"] = "寒江枯水",
  ["cv:sunliang"] = "徐刚",
  ["illustrator:sunliang"] = "眉毛子",
  ["designer:sunliang"] = "荼蘼",

  ["kuizhu"] = "溃诛",
  [":kuizhu"] = "弃牌阶段结束时，你可以选择一项：1. 令至多X名角色各摸一张牌；2. 对任意名体力值之和为X的角色造成1点伤害，若不少于2名角色，你失去1点体力（X为你此阶段弃置的牌数）。",
  ["kuizhu_active"] = "溃诛",
  ["#kuizhu-use"] = "你可发动“溃诛”，X为%arg",
  ["kuizhu_choice1"] = "令至多X名角色各摸一张牌",
  ["kuizhu_choice2"] = "对任意名体力值之和为X的角色造成1点伤害",
  ["chezheng"] = "掣政",
  [":chezheng"] = "锁定技，你的出牌阶段内，攻击范围内不包含你的其他角色不能成为你使用牌的目标。出牌阶段结束时，若你本阶段使用的牌数小于这些角色数，你弃置其中一名角色一张牌。",
  ["#chezheng-throw"] = "掣政：选择攻击范围内不包含你的一名角色，弃置其一张牌",
  ["#chezheng_prohibit"] = "掣政",
  ["lijun"] = "立军",
  [":lijun"] = "主公技，其他吴势力角色于其出牌阶段使用【杀】结算结束后，其可以将此【杀】交给你，然后你可以令其摸一张牌。",
  ["#lijun-invoke"] = "立军：你可以将此【杀】交给 %src，然后 %src 可令你摸一张牌",
  ["#lijun-draw"] = "立军：你可以令 %src 摸一张牌",

  ["$kuizhu1"] = "子通专恣，必谋而诛之！",
  ["$kuizhu2"] = "孙綝久专，不可久忍，必溃诛！",
  ["$chezheng1"] = "风驰电掣，政权不怠！",
  ["$chezheng2"] = "廉平掣政，实为艰事。",
  ["$lijun1"] = "立于朝堂，定于军心。",
  ["$lijun2"] = "君立于朝堂，军侧于四方！",
  ["~sunliang"] = "今日欲诛逆臣而不得，方知机事不密则害成…",
}

local xuyou = General(extension, "xuyou", "qun", 3)
local chenglue = fk.CreateActiveSkill{
  name = "chenglue",
  anim_type = "switch",
  switch_skill_name = "chenglue",
  prompt = function ()
    return Self:getSwitchSkillState("quanmou", false) == fk.SwitchYang and "#chenglue-active:::1:2" or "#chenglue-active:::2:1"
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local isYang = from:getSwitchSkillState(self.name, true) == fk.SwitchYang

    from:drawCards(isYang and 1 or 2, self.name)
    if from.dead then return end

    local discardNum = isYang and 2 or 1
    local toDiscard = room:askForDiscard(from, discardNum, discardNum, false, self.name, false, ".",
    "#chenglue-discard:::" .. tostring(discardNum), true)
    if #toDiscard == 0 then return end

    local suitsToRecord = {}
    for _, id in ipairs(toDiscard) do
      local suit = Fk:getCardById(id).suit
      if suit ~= Card.NoSuit then
        table.insert(suitsToRecord, suit)
      end
    end
    room:throwCard(toDiscard, self.name, from, from)
    if from.dead then return end

    local suitsRecorded = U.getMark(from, "@[suits]chenglue-phase")
    table.insertTableIfNeed(suitsRecorded, suitsToRecord)
    room:setPlayerMark(from, "@[suits]chenglue-phase", suitsRecorded)
  end,
}
local chenglue_refresh = fk.CreateTriggerSkill{
  name = "#chenglue_refresh",

  refresh_events = {fk.PreCardUse},
  can_refresh = function(self, event, target, player, data)
    return player == target and table.contains(U.getMark(player, "@[suits]chenglue-phase"), data.card.suit)
  end,
  on_refresh = function(self, event, target, player, data)
    data.extraUse = true
  end,
}
local chenglue_targetmod = fk.CreateTargetModSkill{
  name = "#chenglue_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return card and table.contains(U.getMark(player, "@[suits]chenglue-phase"), card.suit)
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and table.contains(U.getMark(player, "@[suits]chenglue-phase"), card.suit)
  end,
}
local shicai = fk.CreateTriggerSkill{
  name = "shicai",
  events = {fk.CardUseFinished},
  anim_type = "drawCard",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self) then return false end
    local card_type = data.card.type
    local room = player.room
    if card_type == Card.TypeEquip then
      if not table.contains(player:getCardIds(Player.Equip), data.card:getEffectiveId()) then return false end
    else
      if room:getCardArea(data.card) ~= Card.Processing then return false end
    end
    local logic = room.logic
    local use_event = logic:getCurrentEvent()
    local mark_name = "shicai_" .. data.card:getTypeString() .. "-turn"
    local mark = player:getMark(mark_name)
    if mark == 0 then
      logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local last_use = e.data[1]
        if last_use.from == player.id and last_use.card.type == card_type then
          mark = e.id
          room:setPlayerMark(player, mark_name, mark)
          return true
        end
        return false
      end, Player.HistoryTurn)
    end
    return mark == use_event.id
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local toPut = data.card:isVirtual() and data.card.subcards or { data.card.id }

    if #toPut > 1 then
      toPut = U.askForGuanxing(player, toPut, { #toPut, #toPut }, { 0, 0 }, self.name, nil, true).top
      toPut = table.reverse(toPut)
    end

    room:moveCardTo(toPut, Card.DrawPile, nil, fk.ReasonPut, self.name, nil, true)
    player:drawCards(1, self.name)
  end,

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill(self, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local typesRecorded = U.getMark(player, "@[cardtypes]shicai-turn")
    table.insertIfNeed(typesRecorded, data.card.type)
    player.room:setPlayerMark(player, "@[cardtypes]shicai-turn", typesRecorded)
  end,
}
local cunmu = fk.CreateTriggerSkill{
  name = "cunmu",
  events = {fk.BeforeDrawCard},
  anim_type = "negative",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    data.fromPlace = "bottom"
  end,
}
chenglue:addRelatedSkill(chenglue_refresh)
chenglue:addRelatedSkill(chenglue_targetmod)
xuyou:addSkill(chenglue)
xuyou:addSkill(shicai)
xuyou:addSkill(cunmu)
Fk:loadTranslationTable{
  ["xuyou"] = "许攸",
  ["#xuyou"] = "朝秦暮楚",
  ["cv:xuyou"] = "曹毅",
  ["illustrator:xuyou"] = "兴游",
  ["chenglue"] = "成略",
  [":chenglue"] = "转换技，出牌阶段限一次，阳：你可以摸一张牌，然后弃置两张手牌；阴：你可以摸两张牌，然后弃置一张手牌。"..
  "若如此做，你于此阶段内使用与你以此法弃置的牌花色相同的牌无距离和次数限制。",
  ["shicai"] = "恃才",
  [":shicai"] = "当你每回合首次使用一种类别的牌结算结束后，你可以将之置于牌堆顶，然后摸一张牌。",
  ["cunmu"] = "寸目",
  [":cunmu"] = "锁定技，当你摸牌时，改为从牌堆底摸牌。",

  ["#chenglue-active"] = "发动 成略，摸%arg张牌，弃置%arg2张手牌，本阶段使用这些花色的牌无距离和次数限制",
  ["#chenglue-discard"] = "成略：弃置%arg张手牌，本阶段使用这些花色的牌无距离和次数限制",
  ["@[suits]chenglue-phase"] = "成略",
  ["@[cardtypes]shicai-turn"] = "恃才",

  ["$chenglue1"] = "成略在胸，良计速出。",
  ["$chenglue2"] = "吾有良略在怀，必为阿瞒所需。",
  ["$shicai1"] = "吾才满腹，袁本初竟不从之。",
  ["$shicai2"] = "阿瞒有我良计，取冀州便是易如反掌。",
  ["$cunmu_xuyou1"] = "哼！目光所及，短寸之间。",
  ["$cunmu_xuyou2"] = "狭目之见，只能窥底。",
  ["~xuyou"] = "阿瞒，没有我你得不到冀州啊！",
}

Fk:loadTranslationTable{
  ["luzhi"] = "卢植",
  ["#luzhi"] = "国之桢干",
  ["cv:luzhi"] = "袁国庆",
  ["illustrator:luzhi"] = "biou09",
  ["mingren"] = "明任",
  [":mingren"] = "游戏开始时，你摸两张牌，然后将一张手牌置于你的武将牌上，称为“任”。结束阶段，你可以用手牌替换“任”。",
  ["zhenliang"] = "贞良",
  [":zhenliang"] = "转换技，阳：出牌阶段限一次，你可以选择攻击范围内的一名其他角色，后弃置一张与“任”颜色相同的牌对其造成1点伤害。"..
  "阴：当你于回合外使用或打出的牌置入弃牌堆时，若此牌与“任”颜色相同，你可以令一名角色摸一张牌。",
}

return extension
