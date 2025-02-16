local tianxiang = fk.CreateSkill({
  name = "tianxiang",
})

Fk:loadTranslationTable{
  ["tianxiang"] = "天香",
  [":tianxiang"] = "当你受到伤害时，你可以弃置一张<font color='red'>♥</font>手牌并选择一名其他角色。若如此做，你将此伤害转移给该角色，"..
  "然后其摸X张牌（X为其已损失体力值）。",

  ["#tianxiang-choose" ] = "天香：弃置一张<font color='red'>♥</font>手牌将伤害转移给一名角色，其摸已损失体力值张牌",

  ["$tianxiang2"] = "接着哦~",
  ["$tianxiang1"] = "替我挡着~",
}

tianxiang:addEffect(fk.EventPhaseChanging, {
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).suit == Card.Heart and not player:prohibitDiscard(Fk:getCardById(id))
    end)
    local tos, id = room:askToChooseCardAndPlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      pattern = tostring(Exppattern{ id = cards }),
      skill_name = tianxiang.name,
      prompt = "#tianxiang-choose",
      cancelable = true,
    })
    if #tos > 0 and id then
      self.cost_data = {tos = tos, cards = {id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = self.cost_data.tos[1]
    room:throwCard(self.cost_data.cards, tianxiang.name, player, player)
    room:damage{
      from = data.from,
      to = to,
      damage = data.damage,
      damageType = data.damageType,
      skillName = data.skillName,
      chain = data.chain,
      card = data.card,
    }
    if not to.dead then
      to:drawCards(to:getLostHp(), tianxiang.name)
    end
    return true
  end,
})

return tianxiang
