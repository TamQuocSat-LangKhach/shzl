local jiuchi = fk.CreateSkill {
  name = "jiuchi",
}

Fk:loadTranslationTable{
  ["jiuchi"] = "酒池",
  [":jiuchi"] = "你可以将一张♠手牌当【酒】使用。",

  ["#jiuchi"] = "酒池：你可以将一张♠手牌当【酒】使用",

  ["$jiuchi1"] = "呃……再来……一壶……",
  ["$jiuchi2"] = "好酒！好酒！",
}

jiuchi:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "analeptic",
  prompt = "#jiuchi",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Spade and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("analeptic")
    c.skillName = jiuchi.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

return jiuchi
