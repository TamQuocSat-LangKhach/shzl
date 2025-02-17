local longhun = fk.CreateSkill {
  name = "nos__longhun",
}

Fk:loadTranslationTable{
  ["nos__longhun"] = "龙魂",
  [":nos__longhun"] = "你可以将X张你的同花色的牌按以下规则使用或打出：<font color='red'>♥</font>当【桃】，"..
  "<font color='red'>♦</font>当火【杀】，♣当【闪】，♠当【无懈可击】（X为你的体力值且至少为1）。",

  ["$nos__longhun1"] = "常山赵子龙在此！",
  ["$nos__longhun2"] = "能屈能伸，才是大丈夫！",
}

longhun:addEffect("viewas", {
  pattern = "peach,slash,jink,nullification",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected >= math.max(player.hp, 1) then
      return false
    elseif #selected > 0 then
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
    if #cards ~= math.max(player.hp, 1) then return end
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
})

return longhun
