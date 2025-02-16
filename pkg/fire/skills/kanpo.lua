local kanpo = fk.CreateSkill {
  name = "kanpo",
}

Fk:loadTranslationTable{
  ["kanpo"] = "看破",
  [":kanpo"] = "你可以将一张黑色手牌当【无懈可击】使用。",

  ["#kanpo"] = "看破：你可以将一张黑色手牌当【无懈可击】使用",

  ["$kanpo1"] = "雕虫小技。",
  ["$kanpo2"] = "你的计谋被识破了。",
}

kanpo:addEffect("viewas", {
  anim_type = "control",
  pattern = "nullification",
  prompt = "#kanpo",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = kanpo.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response and #player:getHandlyIds() > 0
  end,
})

return kanpo
