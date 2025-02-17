local kuizhu_active = fk.CreateSkill {
  name = "kuizhu_active",
}

Fk:loadTranslationTable{
  ["kuizhu_active"] = "溃诛",
}

kuizhu_active:addEffect("active", {
  interaction = function()
    return UI.ComboBox {choices = {"kuizhu_choice1", "kuizhu_choice2"}}
  end,
  card_num = 0,
  min_target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if self.interaction.data == "kuizhu_choice1" then
      return #selected < player:getMark("kuizhu")
    elseif self.interaction.data == "kuizhu_choice2" then
      local n = to_select.hp
      for _, p in ipairs(selected) do
        n = n + p.hp
      end
      return n <= player:getMark("kuizhu")
    end
    return false
  end,
  feasible = function(self, player, selected, selected_cards)
    if #selected_cards ~= 0 or #selected == 0 or not self.interaction.data then return false end
    if self.interaction.data == "kuizhu_choice1" then
      return #selected <= player:getMark("kuizhu")
    else
      local n = 0
      for _, p in ipairs(selected) do
        n = n + p.hp
      end
      return n == player:getMark("kuizhu")
    end
  end,
})

return kuizhu_active
