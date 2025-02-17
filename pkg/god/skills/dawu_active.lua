local dawu_active = fk.CreateSkill {
  name = "dawu_active",
}

Fk:loadTranslationTable{
  ["dawu_active"] = "大雾",
}

dawu_active:addEffect("active", {
  expand_pile = "$star",
  card_filter = function (self, player, to_select, selected)
    return table.contains(player:getPile("$star"), to_select)
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected < #selected_cards
  end,
  feasible = function (self, player, selected, selected_cards)
    return #selected == #selected_cards and #selected > 0
  end,
})

return dawu_active
