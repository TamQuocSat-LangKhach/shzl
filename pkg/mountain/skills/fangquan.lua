local fangquan = fk.CreateSkill {
  name = "fangquan",
}

Fk:loadTranslationTable{
  ["fangquan"] = "放权",
  [":fangquan"] = "你可以跳过你的出牌阶段，然后此回合结束时，你可以弃置一张手牌并选择一名其他角色，然后其获得一个额外回合。",

  ["#fangquan-choose"] = "放权：弃置一张手牌，令一名角色获得一个额外回合",

  ["$fangquan1"] = "唉，这可如何是好啊！",
  ["$fangquan2"] = "哎，你办事儿，我放心~",
}

fangquan:addEffect(fk.EventPhaseChanging, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fangquan.name) and data.to == Player.Play
  end,
  on_use = function (self, event, target, player, data)
    player:skip(Player.Play)
  end,
})
fangquan:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(fangquan.name, Player.HistoryTurn) > 0 and
      not player.dead and not player:isKongcheng() and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("h"), function (id)
      return not player:prohibitDiscard(id)
    end)
    local tos, id = room:askToChooseCardAndPlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      pattern = tostring(Exppattern{ id = cards }),
      skill_name = fangquan.name,
      prompt = "#fangquan-choose",
      cancelable = true,
    })
    if #tos > 0 and id then
      event:setCostData(self, {tos = tos, cards = {id}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, fangquan.name, "support")
    room:throwCard(event:getCostData(self).cards, fangquan.name, player, player)
    local to = event:getCostData(self).tos[1]
    if not to.dead then
      to:gainAnExtraTurn(true, fangquan.name)
    end
  end,
})

return fangquan
