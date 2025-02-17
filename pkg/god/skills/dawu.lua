local dawu = fk.CreateSkill {
  name = "dawu",
}

Fk:loadTranslationTable{
  ["dawu"] = "大雾",
  [":dawu"] = "结束阶段开始时，你可以将至少一张“星”置入弃牌堆并选择等量的角色，当其于你的下回合开始之前受到不为雷电伤害的伤害时，防止此伤害。",

  ["@@dawu"] = "大雾",
  ["#dawu-invoke"] = "大雾：将任意张“星”置入弃牌堆，并选择等量角色，防止其受到的非雷电伤害直到你下回合开始",

  ["$dawu1"] = "此计可保你一时平安。",
  ["$dawu2"] = "此非万全之策，唯惧天雷。",
}

dawu:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  expand_pile = "$star",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(dawu.name) and player.phase == Player.Finish and #player:getPile("$star") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "dawu_active",
      prompt = "#dawu-invoke",
      cancelable = true,
    })
    if success and dat then
      event:setCostData(self, {tos = dat.targets, cards = dat.cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(event:getCostData(self).tos) do
      room:addPlayerMark(p, "@@dawu")
    end
    room:setPlayerMark(player, "_dawu", table.map(event:getCostData(self).tos, Util.IdMapper))
    room:moveCardTo(event:getCostData(self).cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, dawu.name)
  end,
})
dawu:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(dawu.name) and target:getMark("@@dawu") > 0 and
      data.damageType ~= fk.ThunderDamage and table.contains(player:getTableMark("_dawu"), target.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = Util.TrueFunc,
})

local clean_spec = {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("_dawu") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(player:getMark("_dawu")) do
      room:removePlayerMark(room:getPlayerById(id), "@@dawu")
    end
    room:setPlayerMark(player, "_dawu", 0)
  end,
}
dawu:addEffect(fk.TurnStart, clean_spec)
dawu:addEffect(fk.Death, clean_spec)

return dawu
