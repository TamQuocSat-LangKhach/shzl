local extension = Package("thunder")
extension.extensionName = "shzl"

Fk:loadTranslationTable{
  ["thunder"] = "雷",
}

--local haozhao = General(extension, "haozhao", "wei", 4)
Fk:loadTranslationTable{
  ["haozhao"] = "郝昭",
  ["zhengu"] = "镇骨",
  [":zhengu"] = "镇骨",
}

return extension