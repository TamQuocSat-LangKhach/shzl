local shuangxiong = fk.CreateSkill {
  name = "shuangxiong",
}

Fk:loadTranslationTable{
  ["shuangxiong"] = "双雄",
  [":shuangxiong"] = "摸牌阶段，你可以选择放弃摸牌并进行一次判定：你获得此判定牌并且此回合可以将任意一张与该判定牌不同颜色的手牌当【决斗】使用。",

  ["@shuangxiong-turn"] = "双雄",
  ["#shuangxiong"] = "双雄：你可以将一张%arg手牌当【决斗】使用",

  ["$shuangxiong1"] = "吾乃河北上将颜良文丑是也！",
  ["$shuangxiong2"] = "快来与我等决一死战！",
}

shuangxiong:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "duel",
  prompt = function(self, player)
    local mark = player:getTableMark("@shuangxiong-turn")
    local color = ""
    if #mark == 1 then
      if mark[1] == "red" then
        color = "black"
      else
        color = "red"
      end
    end
    return "#shuangxiong:::"..color
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then return false end
    local color = Fk:getCardById(to_select):getColorString()
    if color == "red" then
      color = "black"
    elseif color == "black" then
      color = "red"
    else
      return false
    end
    return table.contains(player:getHandlyIds(true), to_select) and table.contains(player:getMark("@shuangxiong-turn"), color)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("duel")
    c:addSubcard(cards[1])
    c.skillName = shuangxiong.name
    return c
  end,
  enabled_at_play = function(self, player)
    return #player:getTableMark("@shuangxiong-turn") > 0
  end,
  enabled_at_response = function(self, player, response)
    return #player:getTableMark("@shuangxiong-turn") > 0 and not response
  end,
})
shuangxiong:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangxiong.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = "shuangxiong",
    }
    room:notifySkillInvoked(player, "shuangxiong", "offensive")
    player:broadcastSkillInvoke("shuangxiong")
    player:revealBySkillName("shuangxiong") -- 先这样
    room:judge(judge)
    local color = judge.card:getColorString()
    if color == "nocolor" then return end
    room:addTableMarkIfNeed(player, "@shuangxiong-turn", color)
    return true
  end,
})
shuangxiong:addEffect(fk.FinishJudge, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and data.reason == shuangxiong.name and
      player.room:getCardArea(data.card) == Card.Processing
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, data.card, true, fk.ReasonJustMove, player.id, shuangxiong.name)
  end,
})

return shuangxiong
