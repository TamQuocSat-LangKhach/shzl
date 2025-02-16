local xingshang = fk.CreateSkill {
  name = "xingshang",
}

Fk:loadTranslationTable{
  ["xingshang"] = "行殇",
  [":xingshang"] = "当其他角色死亡时，你可以获得其所有牌。",

  ["$xingshang1"] = "我的是我的，你的还是我的。",
  ["$xingshang2"] = "来，管杀还管埋！",
}

xingshang:addEffect(fk.Death, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xingshang.name) and not target:isNude()
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, target:getCardIds("he"), false, fk.ReasonPrey, player, xingshang.name)
  end,
})

return xingshang
