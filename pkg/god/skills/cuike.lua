local cuike = fk.CreateSkill {
  name = "cuike",
}

Fk:loadTranslationTable{
  ["cuike"] = "摧克",
  [":cuike"] = "出牌阶段开始时，若你的“军略”数为：奇数，你可以对一名角色造成1点伤害；偶数，你可以弃置一名角色区域里的一张牌，令其横置。"..
  "然后若“军略”数大于7，你可弃全部“军略”，对所有其他角色各造成1点伤害。",

  ["#cuike-damage"] = "摧克：你可以对一名角色造成1点伤害",
  ["#cuike-discard"] = "摧克：你可以弃置一名角色区域里的一张牌并横置之",
  ["#cuike-shenfen"] = "摧克：你可以弃置所有“军略”对所有其他角色各造成1点伤害",

  ["$cuike1"] = "克险摧难，军略当先。",
  ["$cuike2"] = "摧敌心神，克敌计谋。",
}

cuike:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(cuike.name) and player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("@junlue") % 2 == 1 then
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = room.alive_players,
        skill_name = cuike.name,
        prompt = "#cuike-damage",
        cancelable = true,
      })
      if #to > 0 then
        room:damage {
          from = player,
          to = to[1],
          damage = 1,
          skillName = cuike.name,
        }
      end
    else
      local targets = table.filter(room.alive_players, function (p)
        return not (p:isAllNude() and p.chained)
      end)
      if #targets > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = cuike.name,
          prompt = "#cuike-discard",
          cancelable = true,
        })
        if #to > 0 then
          to = to[1]
          if not to:isAllNude() then
            if to == player then
              room:askToDiscard(player, {
                min_num = 1,
                max_num = 1,
                include_equip = true,
                skill_name = cuike.name,
                cancelable = false,
              })
            end
            local card = room:askToChooseCard(player, {
              target = to,
              flag = "hej",
              skill_name = cuike.name,
            })
            room:throwCard(card, cuike.name, to, player)
          end
          if not (to.dead or to.chained) then
            to:setChainState(true)
          end
        end
      end
    end
    if player.dead then return end
    if player:getMark("@junlue") > 7 and
      room:askToSkillInvoke(player, {
        skill_name =  cuike.name,
        prompt = "#cuike-shenfen"
      }) then
      room:setPlayerMark(player, "@junlue", 0)
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not p.dead then
          room:damage {
            from = player,
            to = p,
            damage = 1,
            skillName = cuike.name,
          }
        end
      end
    end
  end,
})

return cuike
