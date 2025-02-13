local extension = Package:new("fire")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["fire"] = "神话再临·火",
}

local U = require "packages/utility/utility"

local dianwei = General(extension, "dianwei", "wei", 4)
local qiangxi = fk.CreateActiveSkill{
  name = "qiangxi",
  anim_type = "offensive",
  max_card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return Fk:getCardById(to_select).sub_type == Card.SubtypeWeapon and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected == 0 and to_select ~= Self.id then
      if #selected_cards == 0 or Fk:currentRoom():getCardArea(selected_cards[1]) ~= Player.Equip then
        return Self:inMyAttackRange(Fk:currentRoom():getPlayerById(to_select))
      else
        return Self:distanceTo(Fk:currentRoom():getPlayerById(to_select)) == 1  --FIXME: some skills(eg.gongqi, meibu) add attackrange directly!
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if #effect.cards > 0 then
      room:throwCard(effect.cards, self.name, player)
    else
      room:loseHp(player, 1, self.name)
    end
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
  end,
}
dianwei:addSkill(qiangxi)
Fk:loadTranslationTable{
  ["dianwei"] = "典韦",
  ["#dianwei"] = "古之恶来",
  ["cv:dianwei"] = "冷泉月夜",
  ["illustrator:dianwei"] = "小冷",
  ["qiangxi"] = "强袭",
  [":qiangxi"] = "出牌阶段限一次，你可以失去1点体力或弃置一张武器牌，并选择你攻击范围内的一名其他角色，对其造成1点伤害。",

  ["$qiangxi1"] = "吃我一戟！",
  ["$qiangxi2"] = "看我三步之内取你小命！",
  ["~dianwei"] = "主公，快走……！",
}

local xunyu = General(extension, "xunyu", "wei", 3)
local quhu = fk.CreateActiveSkill{
  name = "quhu",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and Self:canPindian(target) and target.hp > Self.hp
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(target)) do
        if target:inMyAttackRange(p) then
          table.insert(targets, p.id)
        end
      end
      if #targets == 0 then return end
      local tos = room:askForChoosePlayers(player, targets, 1, 1, "#quhu-choose", self.name)
      room:damage{
        from = target,
        to = room:getPlayerById(tos[1]),
        damage = 1,
        skillName = self.name,
      }
    else
      room:damage{
        from = target,
        to = player,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
local jieming = fk.CreateTriggerSkill{
  name = "jieming",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if self.cancel_cost or player.dead then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1, "#jieming-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local to = player.room:getPlayerById(self.cost_data.tos[1])
    local num = math.min(to.maxHp, 5) - to:getHandcardNum()
    if num > 0 then
      to:drawCards(num, self.name)
    end
  end,
}
xunyu:addSkill(quhu)
xunyu:addSkill(jieming)
Fk:loadTranslationTable{
  ["xunyu"] = "荀彧",
  ["#xunyu"] = "王佐之才",
  ["illustrator:xunyu"] = "LiuHeng",
  ["designer:xunyu"] = "韩旭",

  ["quhu"] = "驱虎",
  [":quhu"] = "出牌阶段限一次，你可以与一名体力值大于你的角色拼点。若你赢，该角色对其攻击范围内你指定的另一名角色造成1点伤害；若你没赢，其对你造成1点伤害。",
  ["jieming"] = "节命",
  [":jieming"] = "当你受到1点伤害后，你可令一名角色将手牌补至X张（X为其体力上限且最多为5）。",
  ["#quhu-choose"] = "驱虎：选择其攻击范围内的一名角色，其对此角色造成1点伤害",
  ["#jieming-choose"] = "节命：令一名角色将手牌补至X张（X为其体力上限且最多为5）",

  ["$quhu1"] = "此乃驱虎吞狼之计。",
  ["$quhu2"] = "借你之手，与他一搏吧。",
  ["$jieming1"] = "秉忠贞之志，守谦退之节。",
  ["$jieming2"] = "我，永不背弃。",
  ["~xunyu"] = "主公要臣死，臣不得不死。",
}

local wolong = General(extension, "wolong", "shu", 3)
local bazhen = fk.CreateTriggerSkill{
  name = "bazhen",
  events = {fk.AskForCardUse, fk.AskForCardResponse},
  frequency = Skill.Compulsory,
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isFakeSkill(self) and
      (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none"))) and
      not player:getEquipment(Card.SubtypeArmor)
      and Fk.skills["#eight_diagram_skill"] ~= nil and Fk.skills["#eight_diagram_skill"]:isEffectable(player)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judgeData = {
      who = player,
      reason = "eight_diagram",
      pattern = ".|.|heart,diamond",
    }
    room:judge(judgeData)

    if judgeData.card.color == Card.Red then
      local card = Fk:cloneCard("jink")
      card.skillName = "eight_diagram"
      card.skillName = "bazhen"
      if event == fk.AskForCardUse then
        if player:prohibitUse(card) then return false end
        data.result = {
          from = player.id,
          card = card,
        }
        if data.eventData then
          data.result.toCard = data.eventData.toCard
          data.result.responseToEvent = data.eventData.responseToEvent
        end
      else
        if player:prohibitResponse(card) then return false end
        data.result = card
      end
      return true
    end
  end
}
local huoji = fk.CreateViewAsSkill{
  name = "huoji",
  anim_type = "offensive",
  pattern = "fire_attack",
  prompt = "#huoji",
  handly_pile = true,
  card_filter = function(self, to_select, selected, player)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("fire_attack")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}
local kanpo = fk.CreateViewAsSkill{
  name = "kanpo",
  anim_type = "control",
  pattern = "nullification",
  prompt = "#kanpo",
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black and table.contains(Self:getHandlyIds(), to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response and #player:getHandlyIds() > 0
  end,
}
wolong:addSkill(bazhen)
wolong:addSkill(huoji)
wolong:addSkill(kanpo)
Fk:loadTranslationTable{
  ["wolong"] = "卧龙诸葛亮",
  ["#wolong"] = "卧龙",
  ["cv:wolong"] = "彭尧",
  ["illustrator:wolong"] = "北",
  ["bazhen"] = "八阵",
  [":bazhen"] = "锁定技，若你没有装备防具，视为你装备着【八卦阵】。",
  ["huoji"] = "火计",
  [":huoji"] = "你可以将一张红色手牌当【火攻】使用。",
  ["kanpo"] = "看破",
  [":kanpo"] = "你可以将一张黑色手牌当【无懈可击】使用。",
  ["#huoji"] = "火计：你可以将一张红色手牌当【火攻】使用",
  ["#kanpo"] = "看破：你可以将一张黑色手牌当【无懈可击】使用",

  ["$bazhen1"] = "你可识得此阵？",
  ["$bazhen2"] = "太极生两仪，两仪生四象，四象生八卦。",
  ["$huoji1"] = "此火可助我军大获全胜。",
  ["$huoji2"] = "燃烧吧！",
  ["$kanpo1"] = "雕虫小技。",
  ["$kanpo2"] = "你的计谋被识破了。",
  ["~wolong"] = "我的计谋竟被……",
}

local pangtong = General(extension, "pangtong", "shu", 3)
local lianhuan = fk.CreateActiveSkill{
  name = "lianhuan",
  mute = true,
  card_num = 1,
  min_target_num = 0,
  prompt = "#lianhuan",
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected, player)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Club and table.contains(player:getHandlyIds(true), to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards, _, _, player)
    if #selected_cards == 1 then
      local card = Fk:cloneCard("iron_chain")
      card:addSubcard(selected_cards[1])
      card.skillName = self.name
      return player:canUse(card) and card.skill:targetFilter(to_select, selected, selected_cards, card, nil, player) and
      not player:prohibitUse(card) and not player:isProhibited(Fk:currentRoom():getPlayerById(to_select), card)
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke(self.name)
    if #effect.tos == 0 then
      room:notifySkillInvoked(player, self.name, "drawcard")
      room:recastCard(effect.cards, player, self.name)
    else
      room:notifySkillInvoked(player, self.name, "control")
      room:sortPlayersByAction(effect.tos)
      room:useVirtualCard("iron_chain", effect.cards, player, table.map(effect.tos, function(id)
        return room:getPlayerById(id) end), self.name)
    end
  end,
}
local niepan = fk.CreateTriggerSkill{
  name = "niepan",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.dying and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:throwAllCards("hej")
    if player.dead then return end
    player:reset()
    player:drawCards(3, self.name)
    if player.dead or not player:isWounded() then return end
    room:recover({
      who = player,
      num = math.min(3, player.maxHp) - player.hp,
      recoverBy = player,
      skillName = self.name,
    })
  end,
}
pangtong:addSkill(lianhuan)
pangtong:addSkill(niepan)
Fk:loadTranslationTable{
  ["pangtong"] = "庞统",
  ["#pangtong"] = "凤雏",
  ["illustrator:pangtong"] = "KayaK",
  ["lianhuan"] = "连环",
  [":lianhuan"] = "你可以将一张♣手牌当【铁索连环】使用或重铸。",
  ["niepan"] = "涅槃",
  [":niepan"] = "限定技，当你处于濒死状态时，你可以弃置区域里的所有牌，复原你的武将牌，然后摸三张牌并将体力回复至3点。",
  ["#lianhuan"] = "连环：你可以将一张♣手牌当【铁索连环】使用或重铸",

  ["$lianhuan1"] = "伤一敌可连其百！",
  ["$lianhuan2"] = "通通连起来吧！",
  ["$niepan1"] = "凤雏岂能消亡？",
  ["$niepan2"] = "浴火重生！",
  ["~pangtong"] = "看来我命中注定将丧命于此……",
}

local taishici = General(extension, "taishici", "wu", 4)
local tianyi = fk.CreateActiveSkill{
  name = "tianyi",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and Self:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      room:addPlayerMark(player, "tianyi_win-turn", 1)
    else
      room:addPlayerMark(player, "tianyi_lose-turn", 1)
    end
  end,
}
local tianyi_targetmod = fk.CreateTargetModSkill{
  name = "#tianyi_targetmod",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("tianyi_win-turn") > 0 and scope == Player.HistoryPhase then
      return 1
    end
  end,
  bypass_distances =  function(self, player, skill)
    return skill.trueName == "slash_skill" and player:getMark("tianyi_win-turn") > 0
  end,
  extra_target_func = function(self, player, skill)
    if skill.trueName == "slash_skill" and player:getMark("tianyi_win-turn") > 0 then
      return 1
    end
  end,
}
local tianyi_prohibit = fk.CreateProhibitSkill{
  name = "#tianyi_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("tianyi_lose-turn") > 0 and card.trueName == "slash"
  end,
}
tianyi:addRelatedSkill(tianyi_targetmod)
tianyi:addRelatedSkill(tianyi_prohibit)
taishici:addSkill(tianyi)
Fk:loadTranslationTable{
  ["taishici"] = "太史慈",
  ["#taishici"] = "笃烈之士",
  ["illustrator:taishici"] = "Tuu.",
  ["tianyi"] = "天义",
  [":tianyi"] = "出牌阶段限一次，你可以与一名角色拼点：若你赢，在本回合结束之前，你可以多使用一张【杀】、使用【杀】无距离限制且可以多选择一个目标；"..
  "若你没赢，本回合你不能使用【杀】。",

  ["$tianyi1"] = "请助我一臂之力！",
  ["$tianyi2"] = "我当要替天行道！",
  ["~taishici"] = "大丈夫，当带三尺之剑，立不世之功！",
}

local pangde = General(extension, "pangde", "qun", 4)
local mengjin = fk.CreateTriggerSkill{
  name = "mengjin",
  anim_type = "offensive",
  events = {fk.CardEffectCancelledOut},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and
      not player.room:getPlayerById(data.to):isNude()
  end,
  on_cost = function (self, event, target, player, data)
    self.cost_data = {tos = {data.to}}
    return player.room:askForSkillInvoke(player, self.name, nil, "#mengjin-invoke:"..data.to)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local cid = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard(cid, self.name, to)
  end,
}
pangde:addSkill("mashu")
pangde:addSkill(mengjin)
Fk:loadTranslationTable{
  ["pangde"] = "庞德",
  ["#pangde"] = "人马一体",
  ["illustrator:pangde"] = "LiuHeng",
  ["mengjin"] = "猛进",
  [":mengjin"] = "每当你使用的【杀】被目标角色使用的【闪】抵消时，你可以弃置其一张牌。",
  ["#mengjin-invoke"] = "猛进：你可以弃置 %src 一张牌 ",

  ["$mengjin1"] = "我要杀你们个片甲不留！",
  ["$mengjin2"] = "你，可敢挡我？",
  ["~pangde"] = "四面都是水，我命休矣……",
}

local shuangxiong = fk.CreateViewAsSkill{
  name = "shuangxiong",
  anim_type = "offensive",
  pattern = "duel",
  prompt = function()
    local mark = Self:getMark("@shuangxiong-turn")
    local color = ""
    if #mark == 1 then
      if mark[1] == "red" then
        color = "black"
      else
        color = "red"
      end
    end
    return "#shuangxiong:::"..color
  end,
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    local color = Fk:getCardById(to_select):getColorString()
    if color == "red" then
      color = "black"
    elseif color == "black" then
      color = "red"
    else
      return false
    end
    return table.contains(Self:getHandlyIds(true), to_select) and table.contains(Self:getMark("@shuangxiong-turn"), color)
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("duel")
    c:addSubcard(cards[1])
    c.skillName = self.name
    return c
  end,
  enabled_at_play = function(self, player)
    return type(player:getMark("@shuangxiong-turn")) == "table"
  end,
  enabled_at_response = function(self, player, resp)
    return type(player:getMark("@shuangxiong-turn")) == "table" and not resp
  end,
}
local shuangxiongJudge = fk.CreateTriggerSkill{
  name = "#shuangxiongJudge",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  mute = true,
  main_skill = shuangxiong,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangxiong) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = "shuangxiong",
    }
    room:notifySkillInvoked(player, "shuangxiong", "offensive")
    player:broadcastSkillInvoke("shuangxiong")
    player:revealBySkillName("shuangxiong") -- 先这样
    room:judge(judge)
    local color = judge.card:getColorString()
    if color == "nocolor" then return end
    room:addTableMarkIfNeed(player, "@shuangxiong-turn", color)
    return true
  end,
}
local shuangxiongGet = fk.CreateTriggerSkill{
  name = "#shuangxiong_get",
  mute = true,
  events = {fk.FinishJudge},
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and data.reason == "shuangxiong" and
    player.room:getCardArea(data.card) == Card.Processing
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player.id, data.card, true, fk.ReasonJustMove, player.id, "shuangxiong")
  end,
}
shuangxiong:addRelatedSkill(shuangxiongJudge)
shuangxiong:addRelatedSkill(shuangxiongGet)
local yanliangwenchou = General:new(extension, "yanliangwenchou", "qun", 4)
yanliangwenchou:addSkill(shuangxiong)
Fk:loadTranslationTable{
  ["yanliangwenchou"] = "颜良文丑",
  ["#yanliangwenchou"] = "虎狼兄弟",
  ["cv:yanliangwenchou"] = "彭尧",
  ["illustrator:yanliangwenchou"] = "KayaK",
  ["shuangxiong"] = "双雄",
  [":shuangxiong"] = "摸牌阶段，你可以选择放弃摸牌并进行一次判定：你获得此判定牌并且此回合可以将任意一张与该判定牌不同颜色的手牌当【决斗】使用。",
  ["@shuangxiong-turn"] = "双雄",
  ["#shuangxiongJudge"] = "双雄",
  ["#shuangxiong_get"] = "双雄",
  ["#shuangxiong"] = "双雄：你可以将一张%arg手牌当【决斗】使用",

  ["$shuangxiong1"] = "吾乃河北上将颜良文丑是也！",
  ["$shuangxiong2"] = "快来与我等决一死战！",
  ["~yanliangwenchou"] = "这红脸长须大将是……",
}

local luanji = fk.CreateViewAsSkill{
  name = "luanji",
  anim_type = "offensive",
  pattern = "archery_attack",
  prompt = "#luanji",
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    if #selected == 1 then
      return table.contains(Self:getHandlyIds(), to_select) and Fk:getCardById(to_select).suit == Fk:getCardById(selected[1]).suit
    elseif #selected == 2 then
      return false
    end
    return table.contains(Self:getHandlyIds(), to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then
      return nil
    end
    local c = Fk:cloneCard("archery_attack")
    c.skillName = self.name
    c:addSubcards(cards)
    return c
  end,
}
local xueyi = fk.CreateMaxCardsSkill{
  name = "xueyi$",
  correct_func = function(self, player)
    if player:hasSkill(self) then
      local hmax = 0
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= player and p.kingdom == "qun" then
          hmax = hmax + 1
        end
      end
      return hmax *2
    else
      return 0
    end
  end,
}
local yuanshao = General:new(extension, "yuanshao", "qun", 4)
yuanshao:addSkill(luanji)
yuanshao:addSkill(xueyi)
Fk:loadTranslationTable{
  ["yuanshao"] = "袁绍",
  ["#yuanshao"] = "高贵的名门",
  ["cv:yuanshao"] = "彭尧", -- 北村?
  ["illustrator:yuanshao"] = "SoniaTang",
  ["luanji"] = "乱击",
  [":luanji"] = "出牌阶段，你可以将任意两张相同花色的手牌当【万箭齐发】使用。",
  ["#luanji"] = "乱击:你可以将两张相同花色的手牌当【万箭齐发】使用",
  ["xueyi"] = "血裔",
  [":xueyi"] = "主公技，锁定技，你的手牌上限+2X(X为场上其他群势力角色数)。",

  ["$luanji1"] = "弓箭手，准备放箭！",
  ["$luanji2"] = "全都去死吧！",
  ["~yuanshao"] = "老天不助我袁家啊！……",
}

return extension
