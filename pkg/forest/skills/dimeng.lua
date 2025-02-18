local dimeng = fk.CreateSkill {
  name = "dimeng",
}

Fk:loadTranslationTable{
  ["dimeng"] = "缔盟",
  [":dimeng"] = "出牌阶段限一次，你可以选择两名其他角色并弃置X张牌（X为这些角色手牌数差），令这两名角色交换手牌。",

  ["#dimeng"] = "缔盟：选择两名其他角色，点击“确定”后，选择与其手牌数之差等量的牌，这两名角色交换手牌",
  ["#dimeng-discard"] = "缔盟：弃置 %arg 张牌，交换%src和%dest的手牌",

  ["$dimeng1"] = "以和为贵，以和为贵。",
  ["$dimeng2"] = "合纵连横，方能以弱胜强。",
}

local U = require "packages/utility/utility"

dimeng:addEffect("active", {
  anim_type = "control",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 2,
  prompt = "#dimeng",
  can_use = function(self, player)
    return player:usedSkillTimes(dimeng.name) == 0 and #Fk:currentRoom().alive_players > 2
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if to_select == player.id or #selected > 1 then return false end
    if #selected == 0 then
      return true
    else
      local num, num2 = to_select:getHandcardNum(), selected[1]:getHandcardNum()
      if num == 0 and num2 == 0 then
        return false
      end
      local x = #table.filter(player:getCardIds("he"), function(id)
        return not player:prohibitDiscard(id)
      end)
      return math.abs( num - num2 ) <= x
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target1 = effect.tos[1]
    local target2 = effect.tos[2]
    local n = math.abs(target1:getHandcardNum() - target2:getHandcardNum())
    if n > 0 then
      room:askToDiscard(player, {
        skill_name = dimeng.name,
        cancelable = false,
        min_num = n,
        max_num = n,
        include_equip = true,
        prompt = "#dimeng-discard:"..effect.tos[1].id..":"..effect.tos[2].id..":"..n,
      })
    end
    U.swapHandCards(room, player, target1, target2, dimeng.name)
  end,
})

return dimeng
