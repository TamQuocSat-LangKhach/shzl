local duanchang = fk.CreateSkill {
  name = "duanchang",
  frequency = Skill.Compulsory,
}

Fk:loadTranslationTable{
  ["duanchang"] = "断肠",
  [":duanchang"] = "锁定技，当你死亡时，杀死你的角色失去所有武将技能。",

  ["$duanchang1"] = "流落异乡愁断肠。",
  ["$duanchang2"] = "日东月西兮徒相望，不得相随兮空断肠。",
}

duanchang:addEffect(fk.Death, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duanchang.name, false, true) and
      data.damage and data.damage.from and not data.damage.from.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.damage.from
    if to == nil then return end
    room:doIndicate(player.id, {to.id})
    local skills = {}
    for _, s in ipairs(to.player_skills) do
      if s:isPlayerSkill(to) then
        table.insertIfNeed(skills, s.name)
      end
    end
    if room.settings.gameMode == "m_1v2_mode" and to.role == "lord" then
      table.removeOne(skills, "m_feiyang")
      table.removeOne(skills, "m_bahu")
    end
    if #skills > 0 then
      room:handleAddLoseSkills(to, "-"..table.concat(skills, "|-"), nil, true, false)
    end
  end,
})

return duanchang
