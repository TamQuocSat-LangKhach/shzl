local bazhen = fk.CreateSkill {
  name = "bazhen",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["bazhen"] = "八阵",
  [":bazhen"] = "锁定技，若你没有装备防具，视为你装备着【八卦阵】。",

  ["$bazhen1"] = "你可识得此阵？",
  ["$bazhen2"] = "太极生两仪，两仪生四象，四象生八卦。",
}

local bazhen_on_use = function (self, event, target, player, data)
  local room = player.room
  room:broadcastPlaySound("./packages/standard_cards/audio/card/eight_diagram")
  room:setEmotion(player, "./packages/standard_cards/image/anim/eight_diagram")
  local skill = Fk.skills["#eight_diagram_skill"]
  skill:use(event, target, player, data)
end
bazhen:addEffect(fk.AskForCardUse, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(bazhen.name) and not player:isFakeSkill(self) and
      (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none"))) and
      not player:getEquipment(Card.SubtypeArmor)
      and Fk.skills["#eight_diagram_skill"] ~= nil and Fk.skills["#eight_diagram_skill"]:isEffectable(player)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = bazhen.name,
    })
  end,
  on_use = bazhen_on_use,
})
bazhen:addEffect(fk.AskForCardResponse, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(bazhen.name) and not player:isFakeSkill(self) and
      (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none"))) and
      not player:getEquipment(Card.SubtypeArmor)
      and Fk.skills["#eight_diagram_skill"] ~= nil and Fk.skills["#eight_diagram_skill"]:isEffectable(player)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = bazhen.name,
    })
  end,
  on_use = bazhen_on_use,
})

bazhen:addTest(function(room, me)
  local comp2 = room.players[2]

  FkTest.setNextReplies(me, { "1" })
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, "bazhen")
    room:moveCardTo(room:printCard("slash", Card.Heart), Card.DrawPile)
    room:useCard {
      from = comp2,
      tos = { me },
      card = Fk:cloneCard("slash"),
    }
  end)
  lu.assertEquals(me.hp, 4)
  FkTest.setNextReplies(me, { "1", "1", "" })
  FkTest.runInRoom(function()
    room:moveCardTo(room:printCard("slash", Card.Diamond), Card.DrawPile)
    room:useCard {
      from = comp2,
      tos = { me },
      card = Fk:cloneCard("archery_attack"),
    }
    room:moveCardTo(room:printCard("slash", Card.Spade), Card.DrawPile)
    room:useCard {
      from = comp2,
      tos = { me },
      card = Fk:cloneCard("slash"),
    }
  end)
  lu.assertEquals(me.hp, 3)
end)

return bazhen
