local buqu = fk.CreateSkill({
  name = "buqu",
  derived_piles = "zhoutai_chuang",
})

Fk:loadTranslationTable{
  ["buqu"] = "不屈",
  [":buqu"] = "当你扣减1点体力时，若你的体力值为0，你可以将牌堆顶的一张牌置于你的武将牌上：若此牌的点数与你武将牌上的其他牌均不同，你不会死亡；"..
  "若你的武将牌上有点数相同的牌，你进入濒死状态。",

  ["#buqu_duplicate"] = "%from 发动“%arg2”失败，其“创”中有 %arg 组重复点数",
  ["#buqu_duplicate_group"] = "第 %arg 组重复点数为 %arg2",
  ["#buqu_duplicate_item"] = "重复“创”牌: %arg",
  ["#buqu_remove"] = "%from 移除了“创”牌：%arg",
  ["zhoutai_chuang"] = "创",

  ["$buqu2"] = "我绝不会倒下！",
  ["$buqu1"] = "还不够！",
}

buqu:addLoseEffect(function (self, player, is_death)
  if not is_death and player.hp <= 0 then
    player.room:enterDying({
      who = player,
    })
  end
end)
buqu:addEffect(fk.BeforeHpChanged, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(buqu.name) and
      data.num < 0 and player.hp <= math.abs(data.num) and (math.abs(data.num) - math.max(player.hp , 1) + 1) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:addToPile("zhoutai_chuang", room:getNCards(math.abs(data.num) - math.max(player.hp , 1) + 1), true, buqu.name)
    room:setPlayerMark(player, buqu.name, 1)--预备终止濒死结算
    local buqu_chuang = player:getPile("zhoutai_chuang")
    local duplicate_numbers = {}
    local numbers = {}
    for _, id in ipairs(buqu_chuang) do
      local number = Fk:getCardById(id).number
      if table.contains(numbers, number) then
        table.insert(duplicate_numbers, number)
      else
        table.insert(numbers, number)
      end
    end
    if #duplicate_numbers == 0 then--不进行濒死流程
      room:setPlayerMark(player, buqu.name, 0)
      data.preventDying = true
    end
  end,
})
buqu:addEffect(fk.HpRecover, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(buqu.name) and
      #player:getPile("zhoutai_chuang") > 0 and #player:getPile("zhoutai_chuang") + player.hp > 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.hp >= 1 then
      local buqu_chuang = player:getPile("zhoutai_chuang")
      for _, id in ipairs(buqu_chuang) do
        local buqu_card = Fk:getCardById(id)
        room:sendLog{
          type = "#buqu_remove",
          from = player.id,
          arg = buqu_card:toLogString()
        }
        room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, buqu.name)
      end
    else
      while #player:getPile("zhoutai_chuang") > 0 and #player:getPile("zhoutai_chuang") + player.hp > 1 do
        local buqu_chuang = player:getPile("zhoutai_chuang")
        local id = room:askToChooseCard(player, {
          target = player,
          skill_name = buqu.name,
          flag = { card_data = { { "zhoutai_chuang", buqu_chuang } } },
          prompt = "$ChooseCard",
        })
        local buqu_card = Fk:getCardById(id)
        room:sendLog{
          type = "#buqu_remove",
          from = player.id,
          arg = buqu_card:toLogString(),
        }
        room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, buqu.name)
      end
    end
  end,
})
buqu:addEffect(fk.AskForPeachesDone, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player.hp <= 0 and player.dying and player:getMark(buqu.name) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, buqu.name, 0)
    local buqu_chuang = player:getPile("zhoutai_chuang")
    local duplicate_numbers = {}
    local numbers = {}
    for _, id in ipairs(buqu_chuang) do
      local number = Fk:getCardById(id).number
      if table.contains(numbers, number) then
        table.insert(duplicate_numbers, number)
      else
        table.insert(numbers, number)
      end
    end
    if #duplicate_numbers == 0 then--终止濒死结算
      data.ignoreDeath = true
    else
      room:sendLog{
        type = "#buqu_duplicate",
        from = player.id,
        arg = #duplicate_numbers,
        arg2 = buqu.name
      }
      for i = 1, #duplicate_numbers, 1 do
        local number = duplicate_numbers[i]
        room:sendLog{
          type = "#buqu_duplicate_group",
          from = player.id,
          arg = i,
          arg2 = Card:getNumberStr(number),
        }
        for _, id in ipairs(buqu_chuang) do
          local buqu_card = Fk:getCardById(id)
          if buqu_card.number == number then
            room:sendLog{
              type = "#buqu_duplicate_item",
              from = player.id,
              arg = buqu_card:toLogString()
            }
          end
        end
      end
    end
  end,
})

buqu:addTest(function (room, me)
  FkTest.setNextReplies(me, {"1"})
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, buqu.name)
    room:damage{
      to = me,
      damage = 4,
    }
  end)
  lu.assertEquals(me.hp, 0)
  lu.assertEquals(#me:getPile("zhoutai_chuang"), 1)
  lu.assertIsTrue(me:isAlive())

  FkTest.runInRoom(function ()
    room:recover{
      who = me,
      num = 1,
    }
  end)
  lu.assertEquals(me.hp, 1)
  lu.assertEquals(#me:getPile("zhoutai_chuang"), 0)
  local jink1 = room:printCard("jink", Card.Club, 1)
  local jink2 = room:printCard("jink", Card.Club, 1)
  local cards = { jink1, jink2 }
  local peach1 = room:printCard("peach")
  FkTest.setNextReplies(me, {"1", json.encode {
    card = peach1.id,
  }, tostring(jink2.id) })
  FkTest.runInRoom(function ()
    room:moveCardTo(cards, Card.DrawPile)
    room:obtainCard(me, peach1)
    room:damage{
      to = me,
      damage = 2,
    }
  end)
  lu.assertEquals(me.hp, 0)
  lu.assertEquals(#me:getPile("zhoutai_chuang"), 1)

  -- 1组，但移出了一张不重复的牌
  local jink3 = room:printCard("jink", Card.Club, 2)
  cards = { jink2, jink3 }
  local peach2 = room:printCard("peach")
  FkTest.setNextReplies(me, {"1", json.encode {
    card = peach2.id,
  }, tostring(jink3.id), json.encode {
    card = peach1.id,
  }, tostring(jink2.id) })
  FkTest.runInRoom(function ()
    room:moveCardTo(cards, Card.DrawPile)
    room:obtainCard(me, peach1)
    room:obtainCard(me, peach2)
    room:damage{
      to = me,
      damage = 2,
    }
  end)
  lu.assertEquals(#me:getPile("zhoutai_chuang"), 1)

  local jink4 = room:printCard("jink", Card.Club, 2)
  cards = { jink2, jink3, jink4 }
  FkTest.setNextReplies(me, {"1", json.encode {
    card = peach2.id,
  }, tostring(jink3.id), json.encode {
    card = peach1.id,
  }, tostring(jink2.id) })
  FkTest.runInRoom(function ()
    room:moveCardTo(cards, Card.DrawPile)
    room:obtainCard(me, peach1)
    room:obtainCard(me, peach2)
    room:damage{
      to = me,
      damage = 3,
    }
  end)
  lu.assertIsTrue(me:isKongcheng())
  lu.assertIsTrue(me:isAlive())

  FkTest.setNextReplies(me, {json.encode {
    card = peach2.id,
  }, json.encode {
    card = peach1.id,
  } })
  FkTest.runInRoom(function ()
    room:obtainCard(me, peach1)
    room:obtainCard(me, peach2)
    room:handleAddLoseSkills(me, "-" .. buqu.name)
  end)
  lu.assertIsTrue(me:isKongcheng())
  lu.assertIsTrue(me:isAlive())
end)

return buqu
