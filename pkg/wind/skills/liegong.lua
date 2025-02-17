local liegong = fk.CreateSkill({
  name = "liegong",
})

Fk:loadTranslationTable{
  ["liegong"] = "烈弓",
  [":liegong"] = "当你于出牌阶段内使用【杀】指定一个目标后，若其手牌数不小于你的体力值或不大于你的攻击范围，则你可以令其不能使用【闪】响应此【杀】。",

  ["$liegong1"] = "百步穿杨！",
  ["$liegong2"] = "中！",
}

liegong:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(liegong.name) and
      data.card.trueName == "slash" and player.phase == Player.Play and
      (data.to:getHandcardNum() <= player:getAttackRange() or data.to:getHandcardNum() >= player.hp)
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    table.insert(data.disresponsiveList, data.to)
  end,
})

liegong:addTest(function (room, me)
  local comp2 = room.players[2]

  -- test1: 出牌阶段外出杀，可以闪避
  FkTest.setNextReplies(me, { "1" })
  FkTest.setNextReplies(comp2, { "1" })
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, liegong.name)
    room:obtainCard(me, { 1, 2, 3, 4 }) -- 摸4个杀
    room:loseHp(me, 3)
    comp2:drawCards(2)
    room:useCard({
      from = comp2, tos = {},
      card = room:printCard("eight_diagram"),
    })
    room:moveCardTo(room:printCard("jink", Card.Heart, 3), Card.DrawPile)
    room:useCard{
      from = me, tos = { comp2 }, card = Fk:cloneCard("slash")
    }
  end)

  lu.assertEquals(comp2.hp, 4)

  -- test2: 出牌阶段内可烈弓（只测手牌数比血多的那段吧）
  FkTest.setNextReplies(me, { json.encode {
    card = 1, targets = { comp2.id },
  }, "1", "" })
  FkTest.setNextReplies(comp2, { "1" })
  FkTest.runInRoom(function()
    room:moveCardTo(room:printCard("jink", Card.Heart, 3), Card.DrawPile)
    me:gainAnExtraPhase(Player.Play)
  end)

  lu.assertEquals(comp2.hp, 3)
end)

return liegong
