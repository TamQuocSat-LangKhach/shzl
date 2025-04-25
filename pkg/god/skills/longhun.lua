local longhun = fk.CreateSkill {
  name = "longhun",
}

Fk:loadTranslationTable{
  ["longhun"] = "龙魂",
  [":longhun"] = "你可以将至多两张你的同花色的牌按以下规则使用或打出：<font color='red'>♥</font>当【桃】，"..
  "<font color='red'>♦</font>当火【杀】，♣当【闪】，♠当【无懈可击】。若你以此法使用或打出了两张：<font color='red'>♥</font>牌，"..
  "此牌回复基数+1；<font color='red'>♦</font>牌，此牌伤害基数+1；黑色牌，你弃置当前回合角色一张牌。",

  ["#longhun"] = "龙魂：将至多两张相同花色的牌当对应的牌使用或打出",

  ["$longhun1"] = "龙战于野，其血玄黄。",
  ["$longhun2"] = "潜龙勿用，藏锋守拙。",
}

longhun:addEffect("viewas", {
  pattern = "peach,slash,jink,nullification",
  prompt = "#longhun",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 2 then
      return false
    elseif #selected == 1 then
      return Fk:getCardById(to_select):compareSuitWith(Fk:getCardById(selected[1]))
    else
      local suit = Fk:getCardById(to_select).suit
      local c
      if suit == Card.Heart then
        c = Fk:cloneCard("peach")
      elseif suit == Card.Diamond then
        c = Fk:cloneCard("fire__slash")
      elseif suit == Card.Club then
        c = Fk:cloneCard("jink")
      elseif suit == Card.Spade then
        c = Fk:cloneCard("nullification")
      else
        return false
      end
      return (Fk.currentResponsePattern == nil and c.skill:canUse(player, c)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
    end
  end,
  view_as = function(self, player, cards)
    if #cards == 0 or #cards > 2 then return end
    local suit = Fk:getCardById(cards[1]).suit
    local c
    if suit == Card.Heart then
      c = Fk:cloneCard("peach")
    elseif suit == Card.Diamond then
      c = Fk:cloneCard("fire__slash")
    elseif suit == Card.Club then
      c = Fk:cloneCard("jink")
    elseif suit == Card.Spade then
      c = Fk:cloneCard("nullification")
    else
      return nil
    end
    c.skillName = longhun.name
    c:addSubcards(cards)
    return c
  end,
  before_use = function(self, player, use)
    local num = #use.card.subcards
    if num == 2 then
      local suit = Fk:getCardById(use.card.subcards[1]).suit
      if suit == Card.Diamond then
        use.additionalDamage = (use.additionalDamage or 0) + 1
      elseif suit == Card.Heart then
        use.additionalRecover = (use.additionalRecover or 0) + 1
      end
    end
  end,
  after_use = function (self, player, use)
    local room = player.room
    if #use.card.subcards == 2 and Fk:getCardById(use.card.subcards[1]).color == Card.Black and
      not player.dead and not room.current.dead and not room.current:isNude() then
      room:doIndicate(player, {room.current})
      if room.current == player then
        room:askToDiscard(player, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = longhun.name,
          cancelable = false,
        })
      else
        local card = room:askToChooseCard(player, {
          target = room.current,
          flag = "he",
          skill_name = longhun.name,
        })
        room:throwCard(card, longhun.name, room.current, player)
      end
    end
  end,
})

return longhun
