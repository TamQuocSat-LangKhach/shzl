local extension = Package:new("mountain")
extension.extensionName = "shzl"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["mountain"] = "神话再临·山",
}

local zhanghe = General(extension, "zhanghe", "wei", 4)
local qiaobian = fk.CreateTriggerSkill{
  name = "qiaobian",
  anim_type = "offensive",
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isKongcheng() and
    data.to > Player.Start and data.to < Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local phase_name_table = {
      [3] = "phase_judge",
      [4] = "phase_draw",
      [5] = "phase_play",
      [6] = "phase_discard",
    }
    local card = player.room:askForDiscard(player, 1, 1, false, self.name, true, ".", "#qiaobian-invoke:::" .. phase_name_table[data.to], true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    player:skip(data.to)
    if data.to == Player.Draw then
      local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
        return not p:isKongcheng() end), Util.IdMapper)
      if #targets > 0 then
        local n = math.min(2, #targets)
        local tos = room:askForChoosePlayers(player, targets, 1, n, "#qiaobian-choose:::"..n, self.name, true)
        if #tos > 0 then
          room:sortPlayersByAction(tos)
          for _, id in ipairs(tos) do
            local p = room:getPlayerById(id)
            if not p:isKongcheng() then
              local card_id = room:askForCardChosen(player, p, "h", self.name)
              room:obtainCard(player, card_id, false, fk.ReasonPrey)
            end
          end
        end
      end
    elseif data.to == Player.Play then
      local targets = room:askForChooseToMoveCardInBoard(player, "#qiaobian-move", self.name, true, nil)
      if #targets ~= 0 then
        targets = table.map(targets, function(id) return room:getPlayerById(id) end)
        room:askForMoveCardInBoard(player, targets[1], targets[2], self.name)
      end
    end
    return true
  end,
}
zhanghe:addSkill(qiaobian)
Fk:loadTranslationTable{
  ["zhanghe"] = "张郃",
  ["#zhanghe"] = "料敌机先",
  ["illustrator:zhanghe"] = "张帅",
  ["qiaobian"] = "巧变",
  [":qiaobian"] = "你的阶段开始前（准备阶段和结束阶段除外），你可以弃置一张手牌跳过该阶段。若以此法跳过摸牌阶段，"..
  "你可以获得至多两名其他角色的各一张手牌；若以此法跳过出牌阶段，你可以将场上的一张牌移动至另一名角色相应的区域内。",
  ["#qiaobian-invoke"] = "巧变：你可以弃一张手牌，跳过 %arg",
  ["#qiaobian-choose"] = "巧变：你可以依次获得%arg名角色的各一张手牌",
  ["#qiaobian-move"] = "巧变：请选择两名角色，移动场上的一张牌",

  ["$qiaobian1"] = "兵无常势，水无常形。",
  ["$qiaobian2"] = "用兵之道，变化万千。",
  ["~zhanghe"] = "啊……膝盖……中箭了……",
}

local dengai = General(extension, "dengai", "wei", 4)
local tuntian = fk.CreateTriggerSkill{
  name = "tuntian",
  anim_type = "special",
  derived_piles = "dengai_field",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase == Player.NotActive then
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
    return player:hasSkill(self) and data.reason == self.name
  end,
  on_refresh = function(self, event, target, player, data)
    if data.card.suit ~= Card.Heart and player.room:getCardArea(data.card) == Card.Processing then
      player:addToPile("dengai_field", data.card, true, self.name)
    end
  end,
}
local tuntian_distance = fk.CreateDistanceSkill{
  name = "#tuntian_distance",
  correct_func = function(self, from, to)
    if from:hasSkill(self) then
      return -#from:getPile("dengai_field")
    end
  end,
}
local zaoxian = fk.CreateTriggerSkill{
  name = "zaoxian",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      player.phase == Player.Start
  end,
  can_wake = function(self, event, target, player, data)
    return #player:getPile("dengai_field") > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, "jixi", nil, true, false)
  end,
}
local jixi = fk.CreateViewAsSkill{  --FIXME: 用来急袭的那张田不应产生-1距离
  name = "jixi",
  anim_type = "control",
  pattern = "snatch",
  expand_pile = "dengai_field",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "dengai_field"
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
dengai:addRelatedSkill(jixi)
Fk:loadTranslationTable{
  ["dengai"] = "邓艾",
  ["#dengai"] = "矫然的壮士",
  ["illustrator:dengai"] = "KayaK",
  ["tuntian"] = "屯田",
  [":tuntian"] = "当你于回合外失去牌后，你可以进行判定：若结果不为<font color='red'>♥</font>，你将生效后的判定牌置于你的武将牌上，称为“田”；"..
  "你计算与其他角色的距离-X（X为“田”的数量）。",
  ["zaoxian"] = "凿险",
  [":zaoxian"] = "觉醒技，准备阶段，若“田”的数量不少于3张，你减1点体力上限，然后获得〖急袭〗。",
  ["jixi"] = "急袭",
  [":jixi"] = "你可以将一张“田”当【顺手牵羊】使用。",
  ["dengai_field"] = "田",

  ["$tuntian1"] = "休养生息，备战待敌。",
  ["$tuntian2"] = "锄禾日当午，汗滴禾下土。",
  ["$zaoxian1"] = "屯田日久，当建奇功！",
  ["$zaoxian2"] = "开辟险路，奇袭敌军！",
  ["$jixi1"] = "偷渡阴平，直取蜀汉！",
  ["$jixi2"] = "攻其无备，出其不意！",
  ["~dengai"] = "吾破蜀克敌，竟葬于奸贼之手！",
}

local jiangwei = General(extension, "jiangwei", "shu", 4)
local tiaoxin = fk.CreateActiveSkill{
  name = "tiaoxin",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getPlayerById(to_select):inMyAttackRange(Self)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local use = room:askForUseCard(target, "slash", "slash", "#tiaoxin-use", true, {exclusive_targets = {player.id}})
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
    return target == player and player:hasSkill(self) and
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
      player:drawCards(2, self.name)
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
    room:changeMaxHp(player, -1)  --yes, lose maxhp after choice
    room:handleAddLoseSkills(player, "guanxing", nil, true, false)
  end,
}
jiangwei:addSkill(tiaoxin)
jiangwei:addSkill(zhiji)
jiangwei:addRelatedSkill("guanxing")
Fk:loadTranslationTable{
  ["jiangwei"] = "姜维",
  ["#jiangwei"] = "龙的衣钵",
  ["cv:jiangwei"] = "彭尧", -- 冷泉? 汤旸?
  ["illustrator:jiangwei"] = "KayaK",

  ["tiaoxin"] = "挑衅",
  [":tiaoxin"] = "出牌阶段限一次，你可以指定一名你在其攻击范围内的角色，其需包括你在内的角色使用一张【杀】，否则你弃置其一张牌。",
  ["zhiji"] = "志继",
  [":zhiji"] = "觉醒技，准备阶段，若你没有手牌，你回复1点体力或摸两张牌，减1点体力上限，然后获得〖观星〗。",
  ["#tiaoxin-use"] = "挑衅：对其使用一张【杀】，否则其弃置你一张牌",
  ["draw1"] = "摸一张牌",
  ["draw2"] = "摸两张牌",
  ["recover"] = "回复1点体力",

  ["$tiaoxin1"] = "汝等小儿，可敢杀我？",
  ["$tiaoxin2"] = "贼将早降，可免一死。",
  ["$zhiji1"] = "先帝之志，丞相之托，不可忘也！",
  ["$zhiji2"] = "丞相厚恩，维万死不能相报。",
  ["$guanxing_jiangwei1"] = "继丞相之遗志，讨篡汉之逆贼！",
  ["$guanxing_jiangwei2"] = "克复中原，指日可待！",
  ["~jiangwei"] = "我计不成，乃天命也……",
}

local liushan = General(extension, "liushan", "shu", 3)
local xiangle = fk.CreateTriggerSkill{
  name = "xiangle",
  events = {fk.TargetConfirmed},
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #room:askForDiscard(room:getPlayerById(data.from), 1, 1, false, self.name, true, ".|.|.|.|.|basic", "#xiangle-discard:"..player.id) == 0 then
      table.insertIfNeed(data.nullifiedTargets, player.id)
    end
  end,
}

local fangquan = fk.CreateTriggerSkill{
  name = "fangquan",
  anim_type = "support",
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to == Player.Play
  end,
  on_use = Util.TrueFunc,
}

local fangquan_delay = fk.CreateTriggerSkill{
  name = "#fangquan_delay",
  events = {fk.TurnEnd},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(fangquan.name, Player.HistoryTurn) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, fangquan.name, "support")
    local tar, card =  room:askForChooseCardAndPlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1, ".|.|.|hand", "#fangquan-choose", fangquan.name, true)
    if #tar > 0 and card then
      room:throwCard(card, fangquan.name, player, player)
      room:getPlayerById(tar[1]):gainAnExtraTurn()
    end
  end,
}
fangquan:addRelatedSkill(fangquan_delay)

local ruoyu = fk.CreateTriggerSkill{
  name = "ruoyu$",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      player.phase == Player.Start
  end,
  can_wake = function(self, event, target, player, data)
    return table.every(player.room:getOtherPlayers(player), function(p) return p.hp >= player.hp end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if player:isWounded() and not player.dead then  --小心王衍
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
    room:handleAddLoseSkills(player, "jijiang", nil, true, false)
  end,
}
liushan:addSkill(xiangle)
liushan:addSkill(fangquan)
liushan:addSkill(ruoyu)
liushan:addRelatedSkill("jijiang")
Fk:loadTranslationTable{
  ["liushan"] = "刘禅",
  ["#liushan"] = "无为的真命主",
  ["cv:liushan"] = "绯川陵彦",
  ["illustrator:liushan"] = "LiuHeng",

  ["xiangle"] = "享乐",
  [":xiangle"] = "锁定技，当你成为【杀】的目标后，你令使用者选择：1. 弃置一张基本牌；2. 此【杀】对你无效。",
  ["#xiangle-discard"] = "享乐：你须弃置一张基本牌，否则此【杀】对 %src 无效",
  ["fangquan"] = "放权",
  [":fangquan"] = "你可以跳过你的出牌阶段，然后此回合结束时，你可以弃置一张手牌并选择一名其他角色，然后其获得一个额外回合。",
  ["ruoyu"] = "若愚",
  [":ruoyu"] = "主公技，觉醒技，准备阶段开始时，若你是体力值最小的角色，你加1点体力上限，然后回复1点体力，获得〖激将〗。",

  ["#fangquan_delay"] = "放权",
  ["#fangquan-choose"] = "放权：弃置一张手牌，令一名角色获得一个额外回合",

  ["$xiangle1"] = "打打杀杀，真没意思。",
  ["$xiangle2"] = "我爸爸是刘备！",
  ["$fangquan1"] = "唉，这可如何是好啊！",
  ["$fangquan2"] = "哎，你办事儿，我放心~",
  ["$ruoyu1"] = "不装疯卖傻，岂能安然无恙？",
  ["$ruoyu2"] = "世人皆错看我，唉！",
  ["$jijiang_liushan1"] = "我蜀汉岂无人乎！",
  ["$jijiang_liushan2"] = "匡扶汉室，谁敢出战！",
  ["~liushan"] = "哎，别打脸，我投降还不行吗？",
}

local sunce = General(extension, "sunce", "wu", 4)
local jiang = fk.CreateTriggerSkill{
  name = "jiang",
  anim_type = "drawcard",
  events ={fk.TargetSpecified, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and 
      ((data.card.trueName == "slash" and data.card.color == Card.Red) or data.card.name == "duel") and
      (event == fk.TargetConfirmed or data.firstTarget)
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
    return target == player and player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      player.phase == Player.Start
  end,
  can_wake = function(self, event, target, player, data)
    return player.hp == 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, "yingzi|yinghun", nil, true, false)
  end,
}

local zhiba = fk.CreateTriggerSkill{
  name = "zhiba$",
  mute = true,
  frequency = Skill.Compulsory,
  refresh_events = {fk.GameStart, fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed},
  can_refresh = function(self, event, target, player, data)
    if event == fk.GameStart then
      return player:hasSkill(self.name, true)
    elseif event == fk.EventAcquireSkill or event == fk.EventLoseSkill then
      return data == self and target == player
    else
      return target == player and player:hasSkill(self.name, true, true)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    --[[
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return p.kingdom == "wu"
    end)
    ]]
    local targets = room:getOtherPlayers(player)
    if event == fk.GameStart or event == fk.EventAcquireSkill then
      if player:hasSkill(self.name, true) then
        table.forEach(targets, function(p)
          room:handleAddLoseSkills(p, "zhiba_other&", nil, false, true)
        end)
      end
    elseif event == fk.EventLoseSkill or event == fk.Deathed then
      table.forEach(targets, function(p)
        room:handleAddLoseSkills(p, "-zhiba_other&", nil, false, true)
      end)
    end
  end,
}
local zhiba_other = fk.CreateActiveSkill{
  name = "zhiba_other&",
  anim_type = "special",
  mute = true,
  can_use = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) < 1 and player.kingdom == "wu" and not player:isKongcheng() then
      return table.find(Fk:currentRoom().alive_players, function(p) return p:hasSkill(zhiba) and p ~= player and player:canPindian(p) end)
    end
    return false
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 0,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.filter(room.alive_players, function(p) return p:hasSkill(zhiba) and p ~= player and player:canPindian(p) end)
    local target
    if #targets == 1 then
      target = targets[1]
    else
      target = room:getPlayerById(room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, nil, self.name, false)[1])
    end
    if not target then return false end
    room:notifySkillInvoked(player, "zhiba")
    player:broadcastSkillInvoke("zhiba")
    room:doIndicate(effect.from, { target.id })
    if target:usedSkillTimes("hunzi", Player.HistoryGame) > 0 and room:askForChoice(target, {"zhiba_yes", "zhiba_no"}, self.name, "#zhiba-ask:" .. player.id) == "zhiba_no" then
      return false
    end
    local pindian = player:pindian({target}, self.name)
    if not pindian.results[target.id].winner or pindian.results[target.id].winner ~= player then
      local to_get = {}
      local leftFromCardIds = room:getSubcardsByRule(pindian.fromCard, { Card.DiscardPile })
      if #leftFromCardIds > 0 then
        table.insertTableIfNeed(to_get, leftFromCardIds)
      end
      local leftToCardIds = room:getSubcardsByRule(pindian.results[target.id].toCard, { Card.DiscardPile })
      if #leftToCardIds > 0 then
        table.insertTableIfNeed(to_get, leftToCardIds)
      end
      if #to_get > 0 then
        room:obtainCard(target, to_get, true, fk.ReasonJustMove)
      end
    end
  end,
}

sunce:addSkill(jiang)
sunce:addSkill(hunzi)
sunce:addRelatedSkill("yingzi")
sunce:addRelatedSkill("yinghun")
sunce:addSkill(zhiba)
Fk:addSkill(zhiba_other)
Fk:loadTranslationTable{
  ["sunce"] = "孙策",
  ["#sunce"] = "江东的小霸王",
  ["cv:sunce"] = "彭尧",
  ["illustrator:sunce"] = "KayaK",
  ["designer:sunce"] = "KayaK",

  ["jiang"] = "激昂",
  [":jiang"] = "当你使用【决斗】或红色【杀】指定目标后，或成为【决斗】或红色【杀】的目标后，你可以摸一张牌。",
  ["hunzi"] = "魂姿",
  [":hunzi"] = "觉醒技，准备阶段，若你的体力值为1，你减1点体力上限，然后获得〖英姿〗和〖英魂〗。",
  ["zhiba"] = "制霸",
  [":zhiba"] = "主公技，其他吴势力角色的出牌阶段限一次，其可以与你拼点（若你发动过〖魂姿〗，你可以拒绝此拼点），若其没赢，你可以获得拼点的两张牌。",

  ["zhiba_other&"] = "制霸",
  [":zhiba_other&"] = "出牌阶段限一次，你可与孙策拼点（若其发动过〖魂姿〗，其可以拒绝此拼点），若你没赢，其可以获得拼点的两张牌。",

  ["#zhiba-ask"] = "%src发起“制霸”拼点，是否拒绝",
  ["zhiba_yes"] = "进行“制霸”拼点",
  ["zhiba_no"] = "拒绝“制霸”拼点",

  ["$jiang1"] = "吾乃江东小霸王孙伯符！",
  ["$jiang2"] = "江东子弟，何惧于天下！",
  ["$hunzi1"] = "父亲在上，魂佑江东；公瑾在旁，智定天下！",
  ["$hunzi2"] = "愿承父志，与公瑾共谋天下！",
  ["$zhiba1"] = "我若怕你，非孙伯符也！",
  ["$zhiba2"] = "是友是敌，一探便知。",
  ["$yingzi_sunce1"] = "公瑾，助我决一死战！",
  ["$yingzi_sunce2"] = "尔等看好了！",
  ["$yinghun_sunce1"] = "父亲，助我背水一战！",
  ["$yinghun_sunce2"] = "孙氏英烈，庇佑江东！",
  ["~sunce"] = "内事不决问张昭，外事不决问周瑜……",
}

local zhangzhaozhanghong = General(extension, "zhangzhaozhanghong", "wu", 3)
local zhijian = fk.CreateActiveSkill{
  name = "zhijian",
  anim_type = "support",
  prompt = "#zhijian-active",
  card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip and
      Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards == 1 and to_select ~= Self.id and
    Fk:currentRoom():getPlayerById(to_select):canMoveCardIntoEquip(selected_cards[1], false)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCardIntoEquip(target, effect.cards[1], self.name, true, player)
    if not player.dead then
      room:drawCards(player, 1, self.name)
    end
  end,
}

local guzheng = fk.CreateTriggerSkill{
  name = "guzheng",
  anim_type = "support",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target ~= player and player:hasSkill(self) and target.phase == Player.Discard then
      local room = player.room
      local guzheng_hand, guzheng_all, cards = {}, {}, {}
      local phase_event = room.logic:getCurrentEvent():findParent(GameEvent.Phase, true)
      if phase_event == nil then return false end
      local end_id = phase_event.id
      U.getEventsByRule(room, GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if not table.contains(cards, id) then
              table.insert(cards, id)
              if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard and
                room:getCardArea(id) == Card.DiscardPile then
                table.insert(guzheng_all, id)
                if move.from == target.id and info.fromArea == Card.PlayerHand then
                  table.insert(guzheng_hand, id)
                end
              end
            end
          end
        end
        return false
      end, end_id)
      if #guzheng_hand > 0 then
        self.cost_data = {guzheng_hand, guzheng_all}
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, nil, "#guzheng-invoke::"..target.id) then
      room:doIndicate(player.id, {target.id})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local guzheng_hand, guzheng_all = self.cost_data[1], self.cost_data[2]
    guzheng_all = table.reverse(guzheng_all)
    local to_return = {guzheng_hand[1]}
    local choice = "guzheng_no"
    if #guzheng_all > 1 then
      to_return, choice = U.askforChooseCardsAndChoice(player, guzheng_hand, {"guzheng_yes", "guzheng_no"},
      self.name, "#guzheng-title::" .. target.id, {}, 1, 1, guzheng_all)
    end
    local moveInfos = {}
    table.insert(moveInfos, {
      ids = to_return,
      to = target.id,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonGive,
      proposer = player.id,
      skillName = self.name,
    })
    table.removeOne(guzheng_all, to_return[1])
    if choice == "guzheng_yes" and #guzheng_all > 0 then
      table.insert(moveInfos, {
        ids = guzheng_all,
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonPrey,
        proposer = player.id,
        skillName = self.name,
      })
    end
    room:moveCards(table.unpack(moveInfos))
  end,
}
zhangzhaozhanghong:addSkill(zhijian)
zhangzhaozhanghong:addSkill(guzheng)
Fk:loadTranslationTable{
  ["zhangzhaozhanghong"] = "张昭张纮",
  ["#zhangzhaozhanghong"] = "经天纬地",
  ["illustrator:zhangzhaozhanghong"] = "废柴男",
  ["zhijian"] = "直谏",
  [":zhijian"] = "出牌阶段，你可以将手牌中的一张装备牌置于其他角色的装备区里，然后摸一张牌。",
  ["guzheng"] = "固政",
  [":guzheng"] = "其他角色的弃牌阶段结束时，你可以将此阶段中其弃置的一张手牌交给该角色，然后你可以获得其余此阶段内弃置的牌。",

  ["#zhijian-active"] = "发动直谏，选择一张装备牌置入其他角色的装备区",
  ["#guzheng-invoke"] = "你可以发动固政，令%dest获得其此次弃置的牌中的一张，然后你可获得剩余牌",
  ["#guzheng-title"] = "固政：选择一张牌还给 %dest",
  ["guzheng_yes"] = "确定，获得剩余牌",
  ["guzheng_no"] = "确定，不获得剩余牌",

  ["$zhijian1"] = "请恕老臣直言！",
  ["$zhijian2"] = "为臣者，当冒死以谏！",
  ["$guzheng1"] = "固国安邦，居当如是。",
  ["$guzheng2"] = "今当稳固内政，以御外患。",
  ["~zhangzhaozhanghong"] = "竭力尽智，死而无憾……",
}

local zuoci = General(extension, "zuoci", "qun", 3)
local function DoHuashen(player)
  local room = player.room
  local huashens = U.getPrivateMark(player, "&huanshen")
  if huashens == 0 or #huashens == 0 then return end
  local name = room:askForGeneral(player, huashens, 1)
  local general = Fk.generals[name]

  local kingdom = general.kingdom
  if general.kingdom == "god" or general.subkingdom then
    local allKingdoms = {}
    if general.kingdom == "god" then
      allKingdoms = {"wei", "shu", "wu", "qun", "jin"}
    elseif general.subkingdom then
      allKingdoms = { general.kingdom, general.subkingdom }
    end
    kingdom = room:askForChoice(player, allKingdoms, "AskForKingdom", "#ChooseInitialKingdom")
  end
  player.kingdom = kingdom
  room:broadcastProperty(player, "kingdom")
  player.gender = general.gender
  room:broadcastProperty(player, "gender")
  local original_general = player.general
  player.general = general.name
  room:broadcastProperty(player, "general")

  local skills = {}
  for _, skill_name in ipairs(general:getSkillNameList()) do
    local s = Fk.skills[skill_name]
    if not (s.lordSkill or s.switchSkillName or s.frequency > 3) then
      if #s.attachedKingdom == 0 or table.contains(s.attachedKingdom, player.kingdom) then
        table.insert(skills, s.name)
      end
    end
  end
  if #skills > 0 then
    local skill = room:askForChoice(player, skills, "huashen", "#huashen", true)
    local huanshen_skill = skill
    if player:getMark("@huanshen_skill") ~= 0 then huanshen_skill = "-"..player:getMark("@huanshen_skill").."|"..skill end
    room:setPlayerMark(player, "@huanshen_skill", skill)
    room:handleAddLoseSkills(player, huanshen_skill, nil, true, false)
  end
  player.general = original_general
  room:broadcastProperty(player, "general")
end
local huashen = fk.CreateTriggerSkill{
  name = "huashen",
  anim_type = "special",
  events = {fk.GamePrepared, fk.TurnStart, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.GamePrepared then
        return true
      else
        return target == player and #U.getPrivateMark(player, "&huanshen") > 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.GamePrepared then
      return true
    else
      return player.room:askForSkillInvoke(player, self.name)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GamePrepared then
      local generals = room:getNGenerals(2)
      U.setPrivateMark(player, "&huanshen", generals)
    end
    DoHuashen(player)
  end,
}
local xinsheng = fk.CreateTriggerSkill{
  name = "xinsheng",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and #player.room.general_pile > 0
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if self.cancel_cost or #player.room.general_pile == 0 then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, data) then
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local generals = U.getPrivateMark(player, "&huanshen")
    table.insert(generals, room:getNGenerals(1)[1])
    U.setPrivateMark(player, "&huanshen", generals)
  end,
}
zuoci:addSkill(huashen)
zuoci:addSkill(xinsheng)
Fk:loadTranslationTable{
  ["zuoci"] = "左慈",
  ["#zuoci"] = "迷之仙人",
  ["illustrator:zuoci"] = "废柴男",
  ["huashen"] = "化身",
  [":huashen"] = "游戏开始前，你获得两张未加入游戏的武将牌，称为“化身”，然后选择一张“化身”的一个技能（主公技、限定技、觉醒技除外）。"..
  "回合开始时和回合结束后，你可以重新选择一张“化身”的一个技能。你获得你以此法选择的技能且性别与势力改为与此“化身”相同。",
  ["xinsheng"] = "新生",
  [":xinsheng"] = "当你受到1点伤害后，你可以获得一张“化身”。",
  ["@[private]&huanshen"] = "化身",
  ["#huashen"] = "化身：请选择要化身的技能",
  ["@huanshen_skill"] = "化身",

  ["$huashen1"] = "哼，肉眼凡胎，岂能窥视仙人变幻？",
  ["$huashen2"] = "万物苍生，幻化由心。",
  ["$xinsheng1"] = "幻幻无穷，生生不息。",
  ["$xinsheng2"] = "吐故纳新，师法天地。",
  ["~zuoci"] = "腾云跨风，飞升太虚……",
}

local caiwenji = General(extension, "caiwenji", "qun", 3, 3, General.Female)
local beige = fk.CreateTriggerSkill{
  name = "beige",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card and data.card.trueName == "slash" and not data.to.dead and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#beige-invoke::"..target.id, true)
    if #card > 0 then
      room:doIndicate(player.id, {target.id})
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if target.dead then return false end
    local judge = {
      who = target,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if judge.card.suit == Card.Heart then
      if not target.dead and target:isWounded() then
        room:recover{
          who = target,
          num = 1,
          recoverBy = player,
          skillName = self.name
        }
      end
    elseif judge.card.suit == Card.Diamond then
      if not target.dead then
        target:drawCards(2, self.name)
      end
    elseif judge.card.suit == Card.Club then
      if data.from and not data.from.dead then
        room:askForDiscard(data.from, 2, 2, true, self.name, false)
      end
    elseif judge.card.suit == Card.Spade then
      if data.from and not data.from.dead then
        data.from:turnOver()
      end
    end
  end,
}
local duanchang = fk.CreateTriggerSkill{
  name = "duanchang",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, false, true) and data.damage and data.damage.from and not data.damage.from.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.damage.from
    local skills = {}
    for _, s in ipairs(to.player_skills) do
      if s:isPlayerSkill(to) then
        table.insertIfNeed(skills, s.name)
      end
    end
    if room.settings.gameMode == "m_1v2_mode" and to.role == "lord" then
      table.removeOne(skills, "m_feiyang")
      table.removeOne(skills, "m_bahu")
    end
    if #skills > 0 then
      room:handleAddLoseSkills(to, "-"..table.concat(skills, "|-"), nil, true, false)
    end
  end,
}
caiwenji:addSkill(beige)
caiwenji:addSkill(duanchang)
Fk:loadTranslationTable{
  ["caiwenji"] = "蔡文姬",
  ["#caiwenji"] = "异乡的孤女",
  ["illustrator:caiwenji"] = "SoniaTang",
  ["cv:caiwenji"] = "shourei小N",

  ["beige"] = "悲歌",
  [":beige"] = "当一名角色受到【杀】造成的伤害后，你可以弃置一张牌，然后令其进行判定，若结果为：<font color='red'>♥</font>，其回复1点体力；"..
  "<font color='red'>♦</font>，其摸两张牌；♣，伤害来源弃置两张牌；♠，伤害来源翻面。",
  ["duanchang"] = "断肠",
  [":duanchang"] = "锁定技，当你死亡时，杀死你的角色失去所有武将技能。",
  ["#beige-invoke"] = "悲歌：%dest 受到伤害，你可以弃置一张牌令其判定，根据花色执行效果",

  ["$beige1"] = "悲歌可以当泣，远望可以当归。",
  ["$beige2"] = "制兹八拍兮拟排忧，何知曲成兮心转愁。",
  ["$duanchang1"] = "流落异乡愁断肠。",
  ["$duanchang2"] = "日东月西兮徒相望，不得相随兮空断肠。",
  ["~caiwenji"] = "人生几何时，怀忧终年岁。",
}

return extension
