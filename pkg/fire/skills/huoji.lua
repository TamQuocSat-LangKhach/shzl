local huoji = fk.CreateSkill {
  name = "huoji",
}

Fk:loadTranslationTable{
  ["huoji"] = "火计",
  [":huoji"] = "你可以将一张红色手牌当【火攻】使用。",

  ["#huoji"] = "火计：你可以将一张红色手牌当【火攻】使用",

  ["$huoji1"] = "此火可助我军大获全胜。",
  ["$huoji2"] = "燃烧吧！",
}

huoji:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "fire_attack",
  prompt = "#huoji",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("fire_attack")
    card.skillName = huoji.name
    card:addSubcard(cards[1])
    return card
  end,
})

return huoji
