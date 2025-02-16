local kuanggu = fk.CreateSkill({
  name = "kuanggu",
  frequency = Skill.Compulsory,
})

Fk:loadTranslationTable{
  ["kuanggu"] = "狂骨",
  [":kuanggu"] = "锁定技，当你对距离1以内的一名角色造成1点伤害后，你回复1点体力。",

  ["$kuanggu1"] = "我会怕你吗！",
  ["$kuanggu2"] = "真是美味啊！",
}

kuanggu:addEffect(fk.Damage, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kuanggu.name) and (data.extra_data or {}).kuanggucheck and player:isWounded()
  end,
  on_trigger = function(self, event, target, player, data)
    for i = 1, data.damage do
      if not (player:isWounded() and player:hasSkill(kuanggu.name)) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = kuanggu.name,
    }
  end,
})
kuanggu:addEffect(fk.BeforeHpChanged, {
  can_refresh = function(self, event, target, player, data)
    return data.damageEvent and player == data.damageEvent.from and player:compareDistance(target, 2, "<")
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.kuanggucheck = true
  end,
})

return kuanggu
