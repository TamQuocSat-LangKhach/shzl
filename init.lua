local wind = require "packages/shzl/wind"
local fire = require "packages/shzl/fire"
local forest = require "packages/shzl/forest"
local mountain = require "packages/shzl/mountain"
local shadow = require "packages/shzl/shadow"
local thunder = require "packages/shzl/thunder"
local god = require "packages/shzl/god"

Fk:loadTranslationTable{ ["shzl"] = "神话再临" }
Fk:loadTranslationTable(require 'packages/shzl/i18n/en_US', 'en_US')

return {
  wind,
  fire,
  forest,
  mountain,
  shadow,
  thunder,
  god,
}
