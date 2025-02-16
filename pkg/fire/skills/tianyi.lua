local tianyi = fk.CreateSkill({
  name = "tianyi",
})

Fk:loadTranslationTable{
  ["tianyi"] = "天义",
  [":tianyi"] = "出牌阶段限一次，你可以与一名角色拼点：若你赢，在本回合结束之前，你可以多使用一张【杀】、使用【杀】无距离限制且可以多选择一个目标；"..
  "若你没赢，本回合你不能使用【杀】。",

  ["#tianyi"] = "天义：与一名角色拼点，若赢，你使用【杀】获得增益，若没赢，本回合你不能使用【杀】",

  ["$tianyi1"] = "请助我一臂之力！",
  ["$tianyi2"] = "我当要替天行道！",
}

tianyi:addEffect("active", {
  anim_type = "offensive",
  prompt = "#tianyi",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, self.name)
    if player.dead then return end
    if pindian.results[target.id].winner == player then
      room:addPlayerMark(player, "tianyi_win-turn", 1)
    else
      room:addPlayerMark(player, "tianyi_lose-turn", 1)
    end
  end,
})
tianyi:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("tianyi_win-turn") > 0 and scope == Player.HistoryPhase then
      return 1
    end
  end,
  bypass_distances =  function(self, player, skill)
    return skill.trueName == "slash_skill" and player:getMark("tianyi_win-turn") > 0
  end,
  extra_target_func = function(self, player, skill)
    if skill.trueName == "slash_skill" and player:getMark("tianyi_win-turn") > 0 then
      return 1
    end
  end,
})
tianyi:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return player:getMark("tianyi_lose-turn") > 0 and card.trueName == "slash"
  end,
})

return tianyi
