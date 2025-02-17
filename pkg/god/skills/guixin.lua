local guixin = fk.CreateSkill {
  name = "guixin",
}

Fk:loadTranslationTable{
  ["guixin"] = "归心",
  [":guixin"] = "当你受到1点伤害后，你可获得所有其他角色区域中的一张牌，然后你翻面。",

  ["$guixin1"] = "周公吐哺，天下归心！",
  ["$guixin2"] = "山不厌高，海不厌深！",
}

guixin:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for _ = 1, data.damage do
      if self.cancel_cost or not player:hasSkill(guixin.name) or
        table.every(player.room:getOtherPlayers(player, false), function (p)
          return p:isAllNude()
        end) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = guixin.name,
    }) then
      event:setCostData(self, {tos = room:getOtherPlayers(player, false)})
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead and not p:isAllNude() then
        local id = room:askToChooseCard(player, {
          target = p,
          flag = "hej",
          skill_name = guixin.name,
        })
        room:obtainCard(player, id, false, fk.ReasonPrey, player, guixin.name)
        if player.dead then return end
      end
    end
    player:turnOver()
  end,
})

return guixin
