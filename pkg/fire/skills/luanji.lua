local luanji = fk.CreateSkill {
  name = "luanji",
}

Fk:loadTranslationTable{
  ["luanji"] = "乱击",
  [":luanji"] = "出牌阶段，你可以将任意两张相同花色的手牌当【万箭齐发】使用。",

  ["#luanji"] = "乱击：你可以将两张相同花色的手牌当【万箭齐发】使用",

  ["$luanji1"] = "弓箭手，准备放箭！",
  ["$luanji2"] = "全都去死吧！",
}

luanji:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "archery_attack",
  prompt = "#luanji",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected < 2 and table.contains(player:getHandlyIds(), to_select) then
      if #selected == 0 then
        return Fk:getCardById(to_select).suit ~= Card.NoSuit
      else
        return Fk:getCardById(to_select):compareSuitWith(Fk:getCardById(selected[1]))
      end
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("archery_attack")
    card.skillName = luanji.name
    card:addSubcards(cards)
    return card
  end,
})

return luanji
