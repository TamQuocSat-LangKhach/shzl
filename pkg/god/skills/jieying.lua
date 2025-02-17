local jieying = fk.CreateSkill {
  name = "jieying",
  frequency = Skill.Compulsory,

  on_acquire = function (self, player, is_start)
    if player:hasSkill(self) then
      player:setChainState(true)
    end
  end,
}

Fk:loadTranslationTable{
  ["jieying"] = "结营",
  [":jieying"] = "锁定技，你始终处于横置状态；处于连环状态的角色手牌上限+2；结束阶段开始时，你横置一名其他角色。",

  ["#jieying-choose"] = "结营：选择一名其他角色，令其横置",

  ["$jieying1"] = "桃园结义，营一世之交。",
  ["$jieying2"] = "结草衔环，报兄弟大恩。",
}

jieying:addEffect(fk.BeforeChainStateChange, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jieying.name) and player.chained
  end,
  on_use = Util.TrueFunc,
})
jieying:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jieying.name) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function(p)
        return p ~= player and not p.chained
      end)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and not p.chained
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = jieying.name,
      prompt = "#jieying-choose",
      cancelable = false,
    })[1]
    to:setChainState(true)
  end,
})
jieying:addEffect("maxcards", {
  correct_func = function(self, player)
    if player.chained then
      local num = #table.filter(Fk:currentRoom().alive_players, function(p)
        return p:hasSkill(jieying.name)
      end)
      return 2 * num
    end
  end,
})

return jieying
