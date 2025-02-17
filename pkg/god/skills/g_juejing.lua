local juejing = fk.CreateSkill {
  name = "gundam__juejing",
  frequency = Skill.Compulsory,
}

Fk:loadTranslationTable{
  ["gundam__juejing"] = "绝境",
  [":gundam__juejing"] = "锁定技，你跳过摸牌阶段；当你的手牌数大于4/小于4时，你将手牌弃置至4/摸至4张。",

  ["$gundam__juejing1"] = "龙战于野，其血玄黄。",
}

juejing:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(juejing.name) and player:getHandcardNum() ~= 4
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local num = 4 - player:getHandcardNum()
    if num > 0 then
      player:drawCards(num, juejing.name)
    elseif num < 0 then
      room:askToDiscard(player, {
        min_num = -num,
        max_num = -num,
        include_equip = false,
        skill_name = juejing.name,
        cancelable = false,
      })
    end
  end,
})
juejing:addEffect(fk.EventPhaseChanging, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(juejing.name) and data.to == Player.Draw
  end,
  on_use = function (self, event, target, player, data)
    player:skip(Player.Draw)
  end,
})

return juejing
