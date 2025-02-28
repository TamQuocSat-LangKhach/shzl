local leiji = fk.CreateSkill({
  name = "leiji",
})

Fk:loadTranslationTable{
  ["leiji"] = "雷击",
  [":leiji"] = "当你使用或打出【闪】时，你可以令一名角色进行判定，若结果为♠，你对其造成2点雷电伤害。",

  ["#leiji-choose"] = "雷击：你可以令一名角色进行判定，若为♠，你对其造成2点雷电伤害。",

  ["$leiji1"] = "以我之真气，合天地之造化！",
  ["$leiji2"] = "雷公助我！",
}

local leiji_spec = {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(leiji.name) and target == player and data.card.name == "jink"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = leiji.name,
      prompt = "#leiji-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local judge = {
      who = to,
      reason = leiji.name,
      pattern = ".|.|spade",
    }
    room:judge(judge)
    if judge.card.suit == Card.Spade and not to.dead then
      room:damage{
        from = player,
        to = to,
        damage = 2,
        damageType = fk.ThunderDamage,
        skillName = leiji.name,
      }
    end
  end,
}

leiji:addEffect(fk.CardUsing, leiji_spec)
leiji:addEffect(fk.CardResponding, leiji_spec)

leiji:addAI(
  --[[
  SmartAI:setSkillAI("leiji", {
    think = function(self, ai)
      local player = ai.player
      -- 选出界面上所有可选的目标
      local players = ai:getEnabledTargets()
      -- 对所有目标计算他们受到2点雷电伤害后对自己的收益
      local benefits = table.map(players, function(p)
        return { p, ai:getBenefitOfEvents(function(logic)
          logic:damage{
            from = player,
            to = p,
            damage = 2,
            damageType = fk.ThunderDamage,
            skillName = self.skill.name,
          }
        end)}
      end)
      local benefit = 0
      local targets = {}
      table.sort(benefits, function(a, b) return a[2] > b[2] end)
      for i, b in ipairs(benefits) do
        local p, val = table.unpack(b)
        if val < 0 then break end
        table.insert(targets, p)
        benefit = val
        break
      end
      if #targets == 0 or benefit <= 0 then return "" end
      return { targets = targets }, benefit
    end
  })
  --]]
)

return leiji
