local extension = Package:new("fire")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["fire"] = "火",
}

local dianwei = General(extension, "dianwei", "wei", 4)
local qiangxi = fk.CreateActiveSkill{
  name = "qiangxi",
  anim_type = "offensive",
  max_card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    return Fk:getCardById(to_select).sub_type == Card.SubtypeWeapon
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
  ["qiangxi"] = "强袭",
  [":qiangxi"] = "出牌阶段限一次，你可以失去1点体力或弃置一张武器牌，并选择你攻击范围内的一名其他角色，对其造成1点伤害。",
}

local xunyu = General(extension, "xunyu", "wei", 3)
local quhu = fk.CreateActiveSkill{
  name = "quhu",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and not target:isKongcheng() and target.hp > Self.hp
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
      local to
      if #tos > 0 then
        to = tos[1]
      else
        to = table.random(targets)
      end
      room:damage{
        from = target,
        to = room:getPlayerById(to),
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
      if self.cancel_cost then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getAlivePlayers()) do
      if #p.player_cards[Player.Hand] < math.min(p.maxHp, 5) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#jieming-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local to = player.room:getPlayerById(self.cost_data)
    to:drawCards(math.min(to.maxHp, 5) - #to.player_cards[Player.Hand])
  end,
}
xunyu:addSkill(quhu)
xunyu:addSkill(jieming)
Fk:loadTranslationTable{
  ["xunyu"] = "荀彧",
  ["quhu"] = "驱虎",
  [":quhu"] = "出牌阶段限一次，你可以与一名体力值大于你的角色拼点。若你赢，则该角色对其攻击范围内你指定的另一名角色造成1点伤害；若你没赢，则其对你造成1点伤害。",
  ["jieming"] = "节命",
  [":jieming"] = "当你受到1点伤害后，你可令一名角色将手牌补至X张（X为其体力上限且最多为5）。",
  ["#quhu-choose"] = "驱虎：选择其攻击范围内的一名角色，其对此角色造成1点伤害",
  ["#jieming-choose"] = "节命：令一名角色将手牌补至X张（X为其体力上限且最多为5）",
}

local taishici = General(extension, "taishici", "wu", 4)
local tianyi = fk.CreateActiveSkill{
  name = "tianyi",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
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
  distance_limit_func =  function(self, player, skill)
    if skill.trueName == "slash_skill" and player:getMark("tianyi_win-turn") > 0 then
      return 999
    end
  end,
  extra_target_func = function(self, player, skill)
    if skill.trueName == "slash_skill" and player:getMark("tianyi_win-turn") > 0 then
      return 1
    end
  end,
}
local tianyi_prohibit = fk.CreateProhibitSkill{
  name = "#tianyi_prohibit",
  is_prohibited = function()
  end,
  prohibit_use = function(self, player, card)
    return player:getMark("tianyi_lose-turn") > 0 and card.trueName == "slash"
  end,
}
tianyi:addRelatedSkill(tianyi_targetmod)
tianyi:addRelatedSkill(tianyi_prohibit)
taishici:addSkill(tianyi)
Fk:loadTranslationTable{
  ["taishici"] = "太史慈",
  ["tianyi"] = "天义",
  [":tianyi"] = "出牌阶段限一次，你可以与一名角色拼点：若你赢，在本回合结束之前，你可以多使用一张【杀】、使用【杀】无距离限制且可以多选择一个目标；若你没赢，本回合你不能使用【杀】。",
}

local pangde = General(extension, "pangde", "qun", 4)
local mengjin = fk.CreateTriggerSkill{
  name = "mengjin",
  anim_type = "offensive",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and
      data.card.name == "jink" and data.toCard and data.toCard.trueName == "slash" and
      data.responseToEvent and data.responseToEvent.from == player.id and
      not target:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cid = room:askForCardChosen(player, target, "he", self.name)
    room:throwCard(cid, self.name, target)
  end,
}
pangde:addSkill("mashu")
pangde:addSkill(mengjin)
Fk:loadTranslationTable{
  ["pangde"] = "庞德",
  ["mengjin"] = "猛进",
  [":mengjin"] = "每当你使用的【杀】被目标角色使用的【闪】抵消时，你可以弃置其一张牌。",
}

local shuangxiongJudge = fk.CreateTriggerSkill{
  name = "#shuangxiongJude",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
    }

    room:broadcastSkillInvoke("shuangxiong")
    room:judge(judge)

    if judge.card then
      local color = judge.card:getColorString() == "black" and "red" or "black";

      room:setPlayerMark(player, "shuangxiong", color)
      room:setPlayerMark(player, "@shuangxiong", color)
      room:obtainCard(player.id, judge.card)
    end

    return true
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name)) then return end
    if event == fk.EventPhaseStart then
      return player.phase == Player.NotActive
    else
      return player.phase < Player.NotActive -- FIXME: this is a bug of FK 0.0.2!!
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "shuangxiong", 0)
    room:setPlayerMark(player, "@shuangxiong", 0)
  end,
}
local shuangxiong = fk.CreateViewAsSkill{
  name = "shuangxiong",
  anim_type = "offensive",
  pattern = "duel",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end

    return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and Fk:getCardById(to_select):getColorString() == Self:getMark("shuangxiong")
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end

    local c = Fk:cloneCard("duel")
    c:addSubcard(cards[1])
    return c
  end,
}
shuangxiong:addRelatedSkill(shuangxiongJudge)
local yanliangwenchou = General:new(extension, "yanliangwenchou", "qun", 4)
yanliangwenchou:addSkill(shuangxiong)
Fk:loadTranslationTable{
  ["yanliangwenchou"] = "颜良文丑",
  ["shuangxiong"] = "双雄",
  [":shuangxiong"] = "摸牌阶段，你可以选择放弃摸牌并进行一次判定：你获得此判定牌并且此回合可以将任意一张与该判定牌不同颜色的手牌当【决斗】使用。",
  ["@shuangxiong"] = "双雄",
  ["#shuangxiongJude"] = "双雄",
}

local luanji = fk.CreateViewAsSkill{
  name = "luanji",
  anim_type = "offensive",
  pattern = "archery_attack",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then 
      return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and Fk:getCardById(to_select).suit == Fk:getCardById(selected[1]).suit
    elseif #selected == 2 then
      return false
    end

    return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then
      return nil
    end

    local c = Fk:cloneCard("archery_attack")
    c:addSubcards(cards)
    return c
  end,
}
local xueyi = fk.CreateMaxCardsSkill{
  name = "xueyi$",
  correct_func = function(self, player)
    if player:hasSkill(self.name) then
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
  ["luanji"] = "乱击",
  [":luanji"] = "出牌阶段，你可以将任意两张相同花色的手牌当【万箭齐发】使用。",
  ["xueyi"] = "血裔",
  [":xueyi"] = "主公技，锁定技，你的手牌上限+2X(X为场上其他群势力角色数)。",
}

return extension
