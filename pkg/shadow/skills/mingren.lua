local mingren = fk.CreateSkill {
  name = "mingren",
}

Fk:loadTranslationTable{
  ["mingren"] = "明任",
  [":mingren"] = "游戏开始时，你摸两张牌，然后将一张手牌置于你的武将牌上，称为“任”。结束阶段，你可以用手牌替换“任”。",
}

return mingren
