local longhun = fk.CreateSkill {
  name = "gundam__longhun",
}

Fk:loadTranslationTable{
  ["gundam__longhun"] = "龙魂",
  [":gundam__longhun"] = "你可以将你的牌按以下规则使用或打出：<font color='red'>♥</font>当【桃】，"..
  "<font color='red'>♦</font>当火【杀】，♣当【闪】，♠当【无懈可击】。准备阶段开始时，如果场上有【青釭剑】，你可以获得之。",

  ["#gundam__longhun_qinggang-invoke"] = "龙魂：你可夺走场上的【青釭剑】！",

  ["$gundam__longhun1"] = "金甲映日，驱邪祛秽。", --无懈
  ["$gundam__longhun2"] = "腾龙行云，首尾不见。", --闪
  ["$gundam__longhun3"] = "潜龙于渊，涉灵愈伤。", --桃
  ["$gundam__longhun4"] = "千里一怒，红莲灿世。", --火杀
}

longhun:addEffect("viewas", {
  mute = true,
  pattern = "peach,slash,jink,nullification",
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then
      return false
    else
      local suit = Fk:getCardById(to_select).suit
      local c
      if suit == Card.Heart then
        c = Fk:cloneCard("peach")
      elseif suit == Card.Diamond then
        c = Fk:cloneCard("fire__slash")
      elseif suit == Card.Club then
        c = Fk:cloneCard("jink")
      elseif suit == Card.Spade then
        c = Fk:cloneCard("nullification")
      else
        return false
      end
      return (Fk.currentResponsePattern == nil and c.skill:canUse(player, c)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local suit = Fk:getCardById(cards[1]).suit
    local c
    if suit == Card.Heart then
      c = Fk:cloneCard("peach")
    elseif suit == Card.Diamond then
      c = Fk:cloneCard("fire__slash")
    elseif suit == Card.Club then
      c = Fk:cloneCard("jink")
    elseif suit == Card.Spade then
      c = Fk:cloneCard("nullification")
    else
      return nil
    end
    c.skillName = longhun.name
    c:addSubcards(cards)
    return c
  end,
})
longhun:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(longhun.name) and player.phase == Player.Start and
      table.filter(player.room.alive_players, function (p)
        return table.find(p:getCardIds("ej"), function (id)
          return Fk:getCardById(id).name == "qinggang_sword"
        end) ~= nil
      end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = longhun.name,
      prompt = "#gundam__longhun_qinggang-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local moves = {}
    for _, p in ipairs(room:getAlivePlayers()) do
      local cards = table.filter(p:getCardIds("ej"), function (id)
        return Fk:getCardById(id).name == "qinggang_sword"
      end)
      if #cards > 0 then
        table.insert(moves, {
          ids = cards,
          from = p,
          to = player,
          toArea = Card.PlayerHand,
          moveReason = fk.ReasonPrey,
          moveVisible = true,
        })
      end
    end
    room:moveCards(table.unpack(moves))
  end,
})

local audio_spec = {
  can_refresh = function(self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, "gundam__longhun")
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if data.card.trueName == "nullification" then
      player:broadcastSkillInvoke("gundam__longhun", 1)
      room:notifySkillInvoked(player, "gundam__longhun", "control")
    elseif data.card.trueName == "jink" then
      player:broadcastSkillInvoke("gundam__longhun", 2)
      room:notifySkillInvoked(player, "gundam__longhun", "defensive")
    elseif data.card.trueName == "peach" then
      player:broadcastSkillInvoke("gundam__longhun", 3)
      room:notifySkillInvoked(player, "gundam__longhun", "support")
    elseif data.card.trueName == "slash" then
      player:broadcastSkillInvoke("gundam__longhun", 4)
      room:notifySkillInvoked(player, "gundam__longhun", "offensive")
    end
  end,
}

longhun:addEffect(fk.PreCardUse, audio_spec)
longhun:addEffect(fk.PreCardRespond, audio_spec)

return longhun
