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
local yuanshao = General:new(extension, "yuanshao", "qun", 4)
yuanshao:addSkill(luanji)
Fk:loadTranslationTable{
  ["yuanshao"] = "袁绍",
  ["luanji"] = "乱击",
  [":luanji"] = "出牌阶段，你可以将任意两张相同花色的手牌当【万箭齐发】使用。",
}

return extension
