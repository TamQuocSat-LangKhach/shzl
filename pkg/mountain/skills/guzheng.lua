local guzheng = fk.CreateSkill {
  name = "guzheng",
}

Fk:loadTranslationTable{
  ["guzheng"] = "固政",
  [":guzheng"] = "其他角色的弃牌阶段结束时，你可以将此阶段中其弃置的一张手牌交给该角色，然后你可以获得其余此阶段内弃置的牌。",

  ["#guzheng-invoke"] = "固政：你可以令 %dest 获得其此次弃置的牌中的一张，然后你可获得剩余牌",
  ["#guzheng-title"] = "固政：选择一张牌还给 %dest",
  ["guzheng_yes"] = "确定，获得剩余牌",
  ["guzheng_no"] = "确定，不获得剩余牌",

  ["$guzheng1"] = "固国安邦，居当如是。",
  ["$guzheng2"] = "今当稳固内政，以御外患。",
}

local U = require "packages/utility/utility"

guzheng:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target ~= player and player:hasSkill(guzheng.name) and target.phase == Player.Discard and not target.dead then
      local room = player.room
      local guzheng_hand, guzheng_all, cards = {}, {}, {}
      local phase_event = room.logic:getCurrentEvent():findParent(GameEvent.Phase, true)
      if phase_event == nil then return false end
      local end_id = phase_event.id
      room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if not table.contains(cards, id) then
              table.insert(cards, id)
              if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard and
                room:getCardArea(id) == Card.DiscardPile then
                table.insert(guzheng_all, id)
                if move.from == target and info.fromArea == Card.PlayerHand then
                  table.insert(guzheng_hand, id)
                end
              end
            end
          end
        end
        return false
      end, end_id)
      if #guzheng_hand > 0 then
        event:setCostData(self, {extra_data = {guzheng_hand, guzheng_all}})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = guzheng.name,
      prompt = "#guzheng-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local guzheng_hand, guzheng_all = event:getCostData(self).extra_data[1], event:getCostData(self).extra_data[2]
    guzheng_all = table.reverse(guzheng_all)
    local to_return = {guzheng_hand[1]}
    local choice = "guzheng_no"
    if #guzheng_all > 1 then
      to_return, choice = U.askforChooseCardsAndChoice(player, guzheng_hand, {"guzheng_yes", "guzheng_no"},
      guzheng.name, "#guzheng-title::" .. target.id, {}, 1, 1, guzheng_all)
    end
    local moveInfos = {}
    table.insert(moveInfos, {
      ids = to_return,
      to = target,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonGive,
      proposer = player,
      skillName = guzheng.name,
    })
    table.removeOne(guzheng_all, to_return[1])
    if choice == "guzheng_yes" and #guzheng_all > 0 then
      table.insert(moveInfos, {
        ids = guzheng_all,
        to = player,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonPrey,
        proposer = player,
        skillName = guzheng.name,
      })
    end
    room:moveCards(table.unpack(moveInfos))
  end,
})

return guzheng
