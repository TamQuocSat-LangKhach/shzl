local guidao = fk.CreateSkill({
  name = "guidao",
})

Fk:loadTranslationTable{
  ["guidao"] = "鬼道",
  [":guidao"] = "当一名角色的判定牌生效前，你可以打出一张黑色牌替换之。",

  ["#guidao-ask"] = "鬼道：你可以打出一张黑色牌替换 %dest 的 “%arg” 判定",

  ["$guidao1"] = "天下大势，为我所控。",
  ["$guidao2"] = "哼哼哼哼~",
}

guidao:addEffect(fk.AskForRetrial, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(guidao.name) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToResponse(player, {
      skill_name = guidao.name,
      pattern = ".|.|spade,club|hand,equip",
      prompt = "#guidao-ask::"..target.id..":"..data.reason,
      cancelable = true,
    })
    if card then
      event:setCostData(self, {extra_data = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:retrial(event:getCostData(self).extra_data, player, data, guidao.name, true)
  end,
})

return guidao
