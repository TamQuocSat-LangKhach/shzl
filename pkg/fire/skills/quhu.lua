local quhu = fk.CreateSkill({
  name = "quhu",
})

Fk:loadTranslationTable{
  ["quhu"] = "驱虎",
  [":quhu"] = "出牌阶段限一次，你可以与一名体力值大于你的角色拼点。若你赢，该角色对其攻击范围内你指定的另一名角色造成1点伤害；若你没赢，"..
  "其对你造成1点伤害。",

  ["#quhu"] = "驱虎：与一名角色拼点，若赢，其对你指定的角色造成伤害，若没赢，其对你造成伤害",
  ["#quhu-choose"] = "驱虎：选择其攻击范围内的一名角色，其对此角色造成1点伤害",

  ["$quhu1"] = "此乃驱虎吞狼之计。",
  ["$quhu2"] = "借你之手，与他一搏吧。",
}

quhu:addEffect("active", {
  anim_type = "offensive",
  prompt = "#quhu",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:canPindian(to_select) and to_select.hp > player.hp
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(target)) do
        if target:inMyAttackRange(p) then
          table.insert(targets, p.id)
        end
      end
      if #targets == 0 then return end
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = quhu.name,
        prompt = "#quhu-choose",
        cancelable = false,
      })
      room:damage{
        from = target,
        to = tos[1],
        damage = 1,
        skillName = self.name,
      }
    else
      room:damage{
        from = target,
        to = player,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
})

return quhu
