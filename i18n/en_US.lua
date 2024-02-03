return {
  -- Wind package
  ["wind"] = "Wind",
  ["xiahouyuan"] = "Xiahou Yuan",
  ["shensu"] = "Amazing Speed",
  [":shensu"] = "You can choose up to 2 options: 1. Skip your judge phase and draw phase; 2. Skip your action phase and discard 1 equip card. Any of the options is regarded as using Slash with no distance limit.",
  ["#shensu1-choose"] = "Amazing Speed: you may skip your judge phase and draw phase, regard as using Slash",
  ["#shensu2-choose"] = "Amazing Speed: you may skip your action phase and discard 1 equip card, regard as using Slash",

  ["caoren"] = "Cao ren",
  ["jushou"] = "Fortified",
  [":jushou"] = "At the start of your finish phase, you can draw 3 cards then turn over.",

  ["huangzhong"] = "Huang Zhong",
  ["liegong"] = "Fearsome Archer",
  [":liegong"] = "After you target with a Slash in you action phase, if the target's hand cards is not less than you HP or not more than you ATK range, you can make him can't use Dodge to respond this Slash.",

  ["weiyan"] = "Wei Yan",
  ["kuanggu"] = "Haughty Streak",
  [":kuanggu"] = "(forced) After you cause 1 DMG to a player at distance 1, you heal 1 HP.",

  ["xiaoqiao"] = "Xiao Qiao",
  ["tianxiang"] = "Heavenly Scent",
  [":tianxiang"] = "When you are about to take DMG, you can discard 1 heart hand card, transfer this DMG to another player, then he draws X cards (X=his lost HP).",
  ["#tianxaing-choose" ] = "Heavenly Scent: you may discard 1 heart hand card to transfer the DMG",
  ["hongyan"] = "Youthful Beauty",
  [":hongyan"] = "(forced) Your spade cards are regarded as heart cards.",

  ["zhoutai"] = "Zhou Tai",
  ["buqu"] = "Refusing Death",
  [":buqu"] = 'When you are dying, you can place a card at the top of draw pile to your character card, face-up ("Wound"). If its number is not same as all your other "Wounds", you quit dying so you won\'t die; otherwise, put it into discard pile. After you recover 1 HP, if you have "Wounds", you need to put 1 of them into discard pile.',
  ["#buqu-invoke"] = 'Refusing Death: you can place %arg card(s) at the top of draw pile to "Wound"',
  ["#buqu_duplicate"] = '"%arg2" of %from fails: %arg duplicate pairs in the "Wound"',
  ["#buqu_duplicate_group"] = "Duplicated numbers #%arg: %arg2",
  ["#buqu_duplicate_item"] = 'Duplicated "Wound" cards: %arg',
  ["#buqu_remove"] = '%from removes "Wound" cards: %arg',
  ["zhoutai_chuang"] = "Wound",

  ["zhangjiao"] = "Zhang Jiao",
  ["leiji"] = "Lighting Strike",
  [":leiji"] = "When you use/play Dodge, you can let a player to perform a judgement, if the result is spade, you deal 2 Thunder DMG to him.",
  ["guidao"] = "Dark Sorcery",
  [":guidao"] = "Before a player's judge card takes effect, you can play a black card to replace it.",
  ["huangtian"] = "Yellow Sky",
  [":huangtian"] = "(lord) Once per action phase of other Neutral characters, they can give you a Dodge or a Lightning.",

  ["#leiji-choose"] = "Lighting Strike: you can let a player to perform judgement now",
  ["#guidao-ask"] = 'Dark Sorcery: you can play a black card to replace %dest\'s judge card (reason is "%arg")',

  ["huangtian_other&"] = "Yellow Sky",
  [":huangtian_other&"] = "Once per action phase, you can give a Dodge or a Lightning to Zhang Jiao.",

  ["yuji"] = "Yu Ji",
  ["guhuo"] = "Demagogue",
  [":guhuo"] = "You can use/play a card face-down and declare it as any basic card or normal trick card; then all other players whose HP is above 0 are asked whether they believe you. This card takes effect unless someone doubts you, in this case flip the card immediately: if is was fake, all the disbelievers draw 1 card; if it was real, all the disbelievers lose 1 HP.<br>This card is useless and discarded as long as it has been flipped over, regardless whether is real or fake, UNLESS the card is both real and has a suit of heart, in which case the card is still effective.",
  ["guhuo_init"] = "<b><font color='#0598BC'>Demagogue</font></b> declares <b><font color='#0598BC'>",
  ["#guhuo-ask"] = "Demagogue: Question %src using/playing %arg",
  ["guhuo_question"] = "Question",
  ["guhuo_noquestion"] = "No Question",
  ["@guhuo"] = "",
  ["#guhuo_use"] = '%from invokes "%arg2" and declared this card as %arg, which target(s) are %to',
  ["#guhuo_no_target"] = '%from invokes "%arg2" and declared this card as %arg',
  ["#guhuo_query"] = "%from's attitude: %arg",

  -- Fire package
  ["fire"] = "Fire",
  ["dianwei"] = "Dian Wei",
  ["qiangxi"] = "Ferocious Assault",
  [":qiangxi"] = "One per action phase, you can lose 1 HP or discard 1 weapon, and deal 1 DMG to another player within you ATK range.",

  ["xunyu"] = "Xun Yu",
  ["quhu"] = "Rouse the Tiger",
  [":quhu"] = "Once per action phase, you can point fight another player whose HP is higher than yours, if you win, he deals 1 DMG to another player of your choice within his ATK range; if you lose, he deals 1 DMG to you.",
  ["jieming"] = "Eternal Loyalty",
  [":jieming"] = "After you take 1 DMG, you can let a player to replenish his hand card to X(X=his maximum HP, max. 5)",
  ["#quhu-choose"] = "Rouse the Tiger: Choose a player within his ATK range",
  ["#jieming-choose"] = "Eternal Loyalty: let a player to replenish his hand card to his max HP (max. 5)",

  ["wolong"] = "Young Zhuge.",
  ["bazhen"] = "Eight Diagram",
  [":bazhen"] = "(forced) If you don't have any armor equipped, you are regarded as having Eight Diagram equipped.",
  ["huoji"] = "Arson Tactic",
  [":huoji"] = "You can use red hand cards as Fire Attack.",
  ["kanpo"] = "See Through",
  [":kanpo"] = "You can use black hand cards as Nullification.",
  ["#huoji"] = "Arson Tactic: use red hand card as Fire Attack",
  ["#kanpo"] = "See Through: use black hand card as Nullification",

  ["pangtong"] = "Pang Tong",
  ["lianhuan"] = "Chaining",
  [":lianhuan"] = "You can use club hand card as Iron Chain or recast you club hand card.",
  ["niepan"] = "Nirvana",
  [":niepan"] = "(limited) When you are dying, you can discard all of your cards, reset your character card, then draw 3 cards and heal to 3 HP.",
  ["#lianhuan"] = "Chaining: use club hand card as Iron Chain or recast",

  ["taishici"] = "Taishi Ci",
  ["tianyi"] = "Justice of Heaven",
  [":tianyi"] = "Once per action phase, you can point fight with another player, if you win, until the end of the turn, your Slash have no distance limit, you can use +1 extra Slash, and your Slash can target to +1 extra player; if you lose, you can't use Slash for the rest of this turn.",

  ["pangde"] = "Pang De",
  ["mengjin"] = "Fearsome Advance",
  [":mengjin"] = "After you Slash is offseted by target's Dodge, you can discard him 1 card.",

  ["yanliangwenchou"] = "Yan L. & Wen C.",
  ["shuangxiong"] = "Dual Heroes",
  [":shuangxiong"] = "During you draw phase, you can change to perform a judgement; you get the judge result card, and in this turn you can use any card with a different color from the judge result as Duel.",
  ["@shuangxiong-turn"] = "Dual H.",
  ["#shuangxiongJude"] = "Dual Heroes",

  ["yuanshao"] = "Yuan Shao",
  ["luanji"] = "Chaos Archery",
  [":luanji"] = "You can use 2 hand cards with the same suit as Archery Attack.",
  ["xueyi"] = "Bloodline",
  [":xueyi"] = "(lord, forced) Your max card is increased by +2*X (X=the amount of other Neutral characters in the game)",

  -- Forest package
  ["forest"] = "Forest",
  ["xuhuang"] = "Xu Huang",
  ["duanliang"] = "Blockade",
  [":duanliang"] = "You can use a black basic card or black equip card as Supply Shortage; your Supply Shortage can target to players within the distance of 2.",

  ["caopi"] = "Cao Pi",
  ["xingshang"] = "Funeral Affair",
  [":xingshang"] = "When other player died, you can get all his cards.",
  ["fangzhu"] = "Banish into Exile",
  [":fangzhu"] = "After you take DMG, you can make another player turn over then draw X card(s). (X = your lost HP)",
  ["songwei"] = "Exalt the Powerful",
  [":songwei"] = "(lord) After another Wei character's black judge card takes effect, he can let you draw 1 card.",

  ["#fangzhu-choose"] = "Banish into Exile: you can make another turn over and draw cards",
  ["#songwei-invoke"] = "Exalt the Powerful: you can let %src draw 1 card",

  ["menghuo"] = "Meng Huo",
  ["huoshou"] = "The Smoking Gun",
  [":huoshou"] = "(forced) Savage Assault has no effect on you; when Savage Assault deals DMG, you become the DMG source.",
  ["zaiqi"] = "Great Again",
  [":zaiqi"] = "During you draw phase, if you are wounded, you can change to show X cards at the top of draw pile (X=your lost HP), you discard all heart cards of them and recover same amount of HP, then you get the rest of cards.",

  ["zhurong"] = "Zhu Rong",
  ["juxiang"] = "Giant Elephant",
  [":juxiang"] = "(forced) Savage Assault has no effect on you; after Savage Assault used by another player have finished all effects, you get that card.",
  ["lieren"] = "Fearsome Blade",
  [":lieren"] = "After you deal DMG with Slash, you can point fight to the target, if you win, you take 1 card from the target.",

  ["sunjian"] = "Sun Jian",
  ["yinghun"] = "Soul of Hero",
  [":yinghun"] = "At the start of your prepare phase, if you are wounded, you can choose another player and choose: 1. He draws 1 card, then discard X card(s); 2. He draws X card(s), then discard 1 card. (X = your lost HP)",
  ["#yinghun-choose"] = "Soul of Hero: you can use the skill to another player",
  ["#yinghun-draw"] = "He draws %arg card(s), then discard 1 card",
  ["#yinghun-discard"] = "He draws 1 card, then discard %arg card(s)",

  ["lusu"] = "Lu Su",
  ["haoshi"] = "Altruism",
  [":haoshi"] = "During your draw phase, you can draw +2 extra cards, then if your hand cards are more than 5, you must give half of them (rounded down) to another player with the lowest amount of hand cards.",
  ["dimeng"] = "Alliance",
  [":dimeng"] = "Once per action phase: you can select 2 other players and discard X cards, then they exchange their hand cards. (X = difference between their amount of hand cards)",
  ["#haoshi-give"] = "Altruism: give %arg hand cards to whom has fewest hand cards",
  ["#haoshi_active"] = "Altruism[give]",
  ["#haoshi_give"] = "Altruism[give]",
  ["#dimeng"] = "Alliance: first choose two players, then click 'OK' to discard your cards",
  ["#dimeng-discard"] = "Alliance: discard %arg cards, then exchange hand card of %src and %dest",

  ["dongzhuo"] = "Dong Zhuo",
  ["jiuchi"] = "Drown in Wine",
  [":jiuchi"] = "You can use a spade hand card as Alcohol.",
  ["roulin"] = "Garden of Lust",
  [":roulin"] = "(forced) When you use Slash target to a female character of when a famale character uses Slash target to you, the target needs to use 2 Dodge to evade it.",
  ["benghuai"] = "Disintegration",
  [":benghuai"] = "(forced) At the start of your finish phase, if you aren't the player with the lowest HP, you choose: 1. Lose 1 HP; 2. Lose 1 max HP.",
  ["baonve"] = "The Tyrant",
  [":baonve"] = "(lord) After other Neutral character deals 1 DMG, he can perform a judgement, if the result is spade, you heal 1 HP.",
  ["loseMaxHp"] = "Lose 1 max HP",
  ["loseHp"] = "Lose 1 HP",
  ["#baonve-invoke"] = "The Tyrant: you can perform judgement, if result is spade, %src heals 1 HP",

  ["jiaxu"] = "Jia Xu",
  ["wansha"] = "Unmitigated Murder",
  [":wansha"] = "(forced) During your turn, only you and the dying player can use Peach.",
  ["luanwu"] = "Descend into Chaos",
  [":luanwu"] = "(limited) During you action phase, you can make all other players choose: 1. Use a Slash to the player in their least distance; 2. Lose 1 HP.",
  ["weimu"] = "Behind the Curtain",
  [":weimu"] = "(forced) You can't be the target of black trick cards.",

  ["#luanwu-use"] = "Descend into Chaos: use Slash or lose 1 HP",

  -- Mountain package
  ["mountain"] = "Mountain",
  ["zhanghe"] = "Zhang He",
  ["qiaobian"] = "Flexibility",
  [":qiaobian"] = "You can discard 1 hand card and skip a phase. If you use this skill to skip: draw phase, you can take 1 hand card from up to 2 players; action phase, you can move a card on the board.",
  ["#qiaobian-invoke"] = "Flexibility: you can discard 1 hand card to skip %arg",
  ["#qiaobian-choose"] = "Flexibility: you can take 1 hand card from up to %arg players in order",
  ["#qiaobian-move"] = "Flexibility: choose 2 players and move 1 card on the board",

  ["dengai"] = "Deng Ai",
  ["tuntian"] = "Amassing Field",
  [":tuntian"] = 'After you lose card outside your turn, you can perform a judgement, if the result is NOT heart, you place the judge card on you character card, face-up ("Field"). The distance from you to other player is reduced by X. (X = the amount of "Fields")',
  ["zaoxian"] = "Conduit",
  [":zaoxian"] = '(awaken) At the start of prepare phase, if you have 3 or 3+ "Fields", you lose 1 max HP and acquire the skill Blitz.',
  ["jixi"] = "Blitz",
  [":jixi"] = 'You can use a "Field" as Snatch.',
  ["dengai_field"] = "Field",

  ["jiangwei"] = "Jiang Wei",
  ["tiaoxin"] = "Provoke",
  [":tiaoxin"] = "Once per action phase, you can select a player who has you within his attack range, then ask him to use a Slash to you. If he didn't use Slash, you discard him 1 card.",
  ["zhiji"] = "Carry out Behest",
  [":zhiji"] = "(awaken) At the start of you prepare phase, if you don't have hand cards, you choose: 1. Draw 2 cards; 2. Heal 1 HP. Then you lose 1 max HP and acquire the skill Stargaze.",
  ["#tiaoxin-use"] = "Provoke: please use a Slash to him, otherwise he discard you 1 card",
  ["draw1"] = "Draw 1 card",
  ["draw2"] = "Draw 2 cards",
  ["recover"] = "Heal 1 HP",

  ["liushan"] = "Liu Shan",
  ["xiangle"] = "Indulged",
  [":xiangle"] = "(forced) After a player uses Slash to target you, the user choose: 1. Discard 1 basic card; 2. This Slash has no effect on you.",
  ["#xiangle-discard"] = "Indulged: you must discard 1 basic card, otherwise this Slash has no effect on %src",
  ["fangquan"] = "Devolution",
  [":fangquan"] = "You can skip your action phase, and when this turn over, you discard 1 hand card and choose another player, he will play an extra turn.",
  ["#fangquan-give"] = "Devolution: you can discard 1 hand card to let another play an extra turn",
  ["ruoyu"] = "Like Fool",
  [":ruoyu"] = "(lord, awaken) At the start of you prepare phase, if you have the fewest HP, you heal 1 max HP and heal 1 HP, then acquire the skills Rouse.",

  ["sunce"] = "Sun Ce",
  ["jiang"] = "Heated",
  [":jiang"] = "After you target with/you are targeted by Duel or red Slash, you can draw 1 card.",
  ["hunzi"] = "Divine Aura",
  [":hunzi"] = "(awaken) At the start of prepare phase, if you HP is 1, you lose 1 max HP and acquire the skills Soul of Hero and Handsome.",
  ["zhiba"] = "Hegemony",
  [":zhiba"] = "(lord) Once per action phase of another Wu character, he can point fight you (if you have activated Divine Aura you can refuse him), if he doesn't win, you can take both cards.",

  ["zhiba_other&"] = "Hegemony",
  [":zhiba_other&"] = "Once per action phase, you can point fight Sun Ce, if you don't win, he can take both cards.",

  ["#zhiba-ask"] = '%src want to point fight to you with "Hegemony", do you want to refuse?',
  ["zhiba_yes"] = 'Proceed "Hegemony" point fight',
  ["zhiba_no"] = 'Refuse "Hegemony" point fight',

  ["zhangzhaozhanghong"] = "Zhang Zhao & Zhang Hong",
  ["zhijian"] = "Blunt Advice",
  [":zhijian"] = "During your action phase, you can place 1 on-hand equip card to another player's equip area, then draw 1 cards.",
  ["guzheng"] = "Stabilization",
  [":guzheng"] = "At the end of another player's discard phase, you can give him 1 card that was discarded in this phase, then you can get the rest of discards.",
  ["#guzheng-invoke"] = "Stabilization: you can let %dest get 1 of the discarded cards and get the rest" ,

  ["zuoci"] = "Zuo Ci",
  ["huashen"] = "Incarnation",
  [":huashen"] = 'At the start of the game, you pick 2 character cards randomly and place them on you character card, face-down ("Incarnation"), then you reveal 1 "Incarnation" and choose a skill on it to acquire (except Limited skill, Awaken skill, Lord skill, Duty skill and Lurk skill), then your gender and nationality are regarded as the same of this "Incarnation". At the start of your prepare phase or finish phase, you can change your "Incarnation" to change a new skill.',
  ["xinsheng"] = "Rebirth",
  [":xinsheng"] = 'After you take 1 DMG, you can get 1 new "Incarnation".',
  ["@[private]&huanshen"] = "Incarnation",
  ["#huashen"] = "Incarnation: choose the skill you want to acquire",
  ["@huanshen_skill"] = "Inca.",

  ["caiwenji"] = "Cai Wenji",
  ["beige"] = "Dirge",
  [":beige"] = "After a player takes DMG from Slash, you can discard 1 card and let him perform a judgement, if the result is: heart, he heals 1 HP; diamond, he draws 2 cards; club, the DMG source discard 2 cards; spade, the DMG source turns over.",
  ["duanchang"] = "Sorrow",
  [":duanchang"] = "(forced) When you died, the killer loses all of his skills.",
  ["#beige-invoke"] = "Dirge: %dest takes DMG, you can discard 1 card and let him perform judgement",

  -- Shadow package
  ["shadow"] = "Shadow",
  ["wangji"] = "Wang Ji",
  ["qizhi"] = "Surprisingly Subdue",
  [":qizhi"] = "When your used non-equip card targeted to some players in your turn, you can discard 1 card of a player who is not one of the targets of this card, then he draw 1 card.",
  ["jinqu"] = "Advance Army",
  [":jinqu"] = "At the start of you Finish Phase, you can draw 2 cards, then discard your hand cards to X (X = times you invoked Surprisingly Subdue in this turn).",
  ["@qizhi-turn"] = "Surp. Subdue",
  ["#qizhi-choose"] = "Surprisingly Subdue: you can discard 1 card of a player, then he draw 1 card",

  -- Not available
  ["kuailiangkuaiyue"] = "Kuai Liang & Kuai Yue",
  ["jianxiang"] = "荐降",
  [":jianxiang"] = "当你成为其他角色使用牌的目标后，你可以令手牌数最少的一名角色摸一张牌。",
  ["shenshi"] = "审时",
  [":shenshi"] = "转换技，阳：出牌阶段限一次，你可以交给手牌数最多的其他角色一张牌，并对其造成1点伤害。若其因此死亡，你可以令一名角色将手牌摸至四张。"..
  "阴：当其他角色对你造成伤害后，你可以观看其手牌，并交给其一张牌；当前回合结束阶段，若其未失去此牌，你将手牌摸至四张。",

  ["yanyan"] = "Yan Yan",
  ["juzhan"] = "Refusing Fight",
  [":juzhan"] = "(switch) Yang: when you are targeted with Slash by another player, you can both draw 1 card with him, then he can not use card to you at the rest of this turn; Yin: when your used Slash targets to a player, you can take him 1 card, then you can not use card to him at the rest of this turn.",

  -- Not available
  ["wangping"] = "Wang Ping",
  ["feijun"] = "飞军",
  [":feijun"] = "出牌阶段限一次，你可以弃置一张牌，然后选择一项：1.令一名手牌数大于你的角色交给你一张牌；"..
  "2.令一名装备区里牌数大于你的角色弃置一张装备区里的牌。",
  ["binglve"] = "兵略",
  [":binglve"] = "锁定技，当你首次对一名角色发动〖飞军〗时，你摸两张牌。",

  ["luji"] = "Lu Ji",
  ["huaiju"] = "Take Oranges",
  [":huaiju"] = '(forced) At the start of game, you get 3 tokens ("Orange"). When a player who has "Orange" is about to suffer DMG, prevent this DMG and remove 1 "Orange". The players that have "Orange" draw +1 extra card in their Draw Phase.',
  ["yili"] = "Present Gift",
  [":yili"] = 'At the start of your Action Phase, you can choose to lose 1 HP or to remove 1 "Orange", then let another player to get 1 "Orange".',
  ["#yili-choose"] = "Present Gift: you can lose 1 HP or Orange, then give another player an Orange",
  ["yili_lose_orange"] = "Remove an Orange",
  ["zhenglun"] = "Organizing Writings",
  [":zhenglun"] = 'At the start of your Draw Phase, if you don\'t have "Orange", you can skip Draw Phase to get 1 "Orange".',
  ["#huaiju_effect"] = "Take Oranges",
  ["@orange"] = "Orange",

  ["sunliang"] = "Sun Liang",
  ["kuizhu"] = "Failed Execution",
  [":kuizhu"] = "At the end of your Discard Phase, you can choose: 1. Choose up to X players, they each draw 1 card; 2. Choose any amount of players that sum of their HP equals to X, you deal 1 DMG to each of them, if you choose more than 1 player, you lose 1 HP (X = # of cards you have discarded in this phase).",
  ["kuizhu_active"] = "Failed Execution",
  ["#kuizhu-use"] = "You can use Failed Execution now (X = %arg)",
  ["kuizhu_choice1"] = "Let up to X players draw 1 card",
  ["kuizhu_choice2"] = "Deal 1 DMG to players that sum of their HP equals to X",
  ["chezheng"] = "Impeded Ruler",
  [":chezheng"] = "(forced) In your Action Phase, you can not use card to those who don't have you in their ATK range. At the end of your Action Phase, if # of your used cards in this phase is less than # of those players, you discard 1 card of one of them.",
  ["#chezheng-throw"] = "Impeded Ruler: please choose a player who doesn't have you in his ATK range then discard him 1 card",
  ["#chezheng_prohibit"] = "Impeded Ruler",
  ["lijun"] = "Found Troop",
  [":lijun"] = "(lord) After a Slash which is used by another Wu character in his Action Phase has finished all effects, he can give this Slash to you, then you can let him draw 1 card.",
  ["#lijun-invoke"] = "Found Troop: you can give this Slash to %src, then he can let you draw 1 card",
  ["#lijun-draw"] = "Found Troop: you can let %src draw 1 card",

  ["xuyou"] = "Xu You",
  ["chenglve"] = "Devise Ploy",
  [":chenglve"] = "(switch) Once per Action Phase, Yang: you can draw 1 then discard 2 hand cards; Yin: you can draw 2 then discard 1 handcard. After your discard cards by this way, you can use any # of cards which has the same suit with your discarded cards without distance limit in this phase.",
  ["shicai"] = "Rely on Ability",
  [":shicai"] = "After your used card has finished all effects, if its type (basic/trick/equip) is the first time you use in this turn, you can place it to the top of draw pile, then draw 1 card.",
  ["cunmu"] = "Short Sighted",
  [":cunmu"] = "(forced) You draw cards from the bottom of draw pile.",
  ["@chenglve-phase"] = "Devi. P.",
  ["@shicai"] = "Rely A.",

  -- Not available
  ["luzhi"] = "Lu Zhi",
  ["mingren"] = "明任",
  [":mingren"] = "游戏开始时，你摸两张牌，然后将一张手牌置于你的武将牌上，称为“任”。结束阶段，你可以用手牌替换“任”。",
  ["zhenliang"] = "贞良",
  [":zhenliang"] = "转换技，阳：出牌阶段限一次，你可以选择攻击范围内的一名其他角色，后弃置一张与“任”颜色相同的牌对其造成1点伤害。"..
  "阴：当你于回合外使用或打出的牌置入弃牌堆时，若此牌与“任”颜色相同，你可以令一名角色摸一张牌。",

  -- Thunder
  ["thunder"] = "Thunder",

  ["zhangxiu"] = "Zhang Xiu",
  ["xiongluan"] = "Grand Rebellion",
  [":xiongluan"] = "(limited) In your Action Phase, you can seal your judgement area and all of your equip slots, then choose another player. Until end of this turn, you can use any # of cards to him without distance limitation, and he can not use/play his hand cards.",
  ["congjian"] = "Accept Advice",
  [":congjian"] = "When you are targeted by trick card, if # of targets is more than 1, you can give 1 card to another target then draw 1 card (if you give out equip card, draw 2 cards instead).",
  ["@@xiongluan-turn"] = "Grand Rebellion",
  ["#congjian-give"] = "Accept Advice: you can give a card to another who is the target to, then draw 1 card (if give equip, change this to draw 2)",

  ["haozhao"] = "Hao Zhao",
  ["zhengu"] = "镇骨",
  [":zhengu"] = "结束阶段，你可以选择一名其他角色，本回合结束时和其下个回合结束时，其将手牌摸或弃至与你手牌数量相同（至多摸至五张）。",
  ["#zhengu_delay"] = "镇骨",
  ["@@zhengu"] = "镇骨",
  ["#zhengu-choose"] = "镇骨：选择一名其他角色，本回合结束时和其下个回合结束时其将手牌调整与你相同",

  ["chendao"] = "Chen Dao",
  ["wangliec"] = "往烈",
  [":wangliec"] = "出牌阶段，你使用的第一张牌无距离限制。你于出牌阶段使用【杀】或普通锦囊牌时，你可以令此牌无法响应，然后本阶段你不能再使用牌。",
  ["#wangliec-invoke"] = "往烈：你可以令%arg无法响应，然后你本阶段不能再使用牌",
  ["@wangliec-phase"] = "往烈",

  ["zhugezhan"] = "Zhuge Zhan",
  ["zuilun"] = "罪论",
  [":zuilun"] = "结束阶段，你可以观看牌堆顶三张牌，你每满足以下一项便获得其中的一张，然后以任意顺序放回其余的牌：1.你于此回合内造成过伤害；"..
  "2.你于此回合内未弃置过牌；3.手牌数为全场最少。若均不满足，你与一名其他角色失去1点体力。",
  ["fuyin"] = "父荫",
  [":fuyin"] = "锁定技，你每回合第一次成为【杀】或【决斗】的目标后，若你的手牌数不大于使用者，此牌对你无效。",
  ["zuilun_top"] = "置于牌堆顶",
  ["zuilun_get"] = "获得",
  ["#zuilun-choose"] = "罪论：选择一名其他角色，你与其各失去1点体力",

  ["thunder__yuanshu"] = "Yuan Shu",
  ["thunder__yongsi"] = "庸肆",
  [":thunder__yongsi"] = "锁定技，摸牌阶段，你改为摸X张牌（X为场上现存势力数）。出牌阶段结束时，若你本回合没有造成过伤害，你将手牌补至当前体力值；"..
  "若造成过伤害且大于1点，你本回合手牌上限改为已损失体力值。",

  ["lukang"] = "Lu Kang",
  ["qianjie"] = "谦节",
  [":qianjie"] = "锁定技，你被横置前防止之，且不能成为延时类锦囊牌或其他角色拼点的目标（禁止拼点暂时无法实现）。",
  ["#qianjie_prohibit"] = "谦节",
  ["jueyan"] = "决堰",
  [":jueyan"] = "出牌阶段限一次，你可以废除你装备区里的一种装备栏，然后执行对应的一项：武器栏，你于此回合内可以多使用三张【杀】；防具栏，摸三张牌，本回合手牌上限+3；坐骑栏，本回合你使用牌无距离限制；宝物栏，本回合获得〖集智〗。",
  ["poshi"] = "破势",
  [":poshi"] = "觉醒技，准备阶段，若你所有装备栏均被废除或体力值为1，则你减1点体力上限，然后将手牌摸至体力上限，失去〖决堰〗，获得〖怀柔〗。",
  ["huairou"] = "怀柔",
  [":huairou"] = "出牌阶段，你可以重铸一张装备牌。",

  -- God
  ["god"] = "Demi God",
  ["nos"] = "Nostalgia",

  ["godguanyu"] = "Guan Yu",
  ["wushen"] = "God of War",
  [":wushen"] = "(forced) Your <font color='red'>♥</font> hand cards are regarded as Slash; your <font color='red'>♥</font> Slash has no distance limitation.",
  ["wuhun"] = "Warrior Spirit",
  [":wuhun"] = '(forced) After you suffer 1 DMG, the DMG source gets 1 "Nightmare" token; when you die, you choose a player with the most "Nightmares", he performs a judgement, if the result is not Peach or God Salvation, he dies.',
  ["@nightmare"] = "Nightmare",
  ["#wuhun-choose"] = "Warrior Spirit: please choose a player with the most \"Nightmares\"",

  ["godlvmeng"] = "Lv Meng",
  ["shelie"] = "Look Through",
  [":shelie"] = "At your Draw Phase, you can change to show 5 cards from the top of draw pile; then, take 1 of each suit.",
  ["gongxin"] = "Strike at the Heart",
  [":gongxin"] = "Once per Action Phase: you can look at all the hand cards of another player. Among them, you can pick 1 <font color='red'>♥</font> and show it to everyone; then choose: 1. Discard it. 2. Place it on top of draw pile.",
  ["gongxin_discard"] = "Discard it",
  ["gongxin_put"] = "Place it on the top of draw pile",

  ["godzhouyu"] = "Zhou Yu",
  ["qinyin"] = "The Sound of Music",
  [":qinyin"] = "In your Discard Phase, if you discard 2 or more cards: you can force all players to heal 1 HP or lose 1 HP.",
  ["yeyan"] = "Searing Heat",
  [":yeyan"] = "(limited) In your Action Phase: you can select up to 3 players and distribute up to 3 Fire DMG among them. If you allocate more than 1 DMG to any of them, you need to discard 1 card of each suit and lose 3 HP first.",
  ["#yeyan-choose"] = "Searing Heat: choose the target to deal #%arg DMG to",

  ["godzhugeliang"] = "Zhuge Liang",
  ["qixing"] = "The Seven Stars",
  [":qixing"] = 'At the beginning of the game: you are given 11 cards. You pick 4 of them to be your starting hand and place the remaining 7 on your character, face-down ("Stars"). After each of your Draw Phases: you can interchange any # of hand cards with the same # of "Stars".',
  ["kuangfeng"] = "Strong Gale",
  [":kuangfeng"] = 'In your Finish Phase: you can discard 1 "Star" and select a player. Until your next turn, all Fire DMG that player suffers is increased by +1.',
  ["dawu"] = "Heavy Mist",
  [":dawu"] = 'In your End Phase: you can discard any # of "Stars" and select the same # of players. Until your next turn, these players will be protected from all DMG, except Thunder DMG.',
  ["star"] = "Star",
  ["@@kuangfeng"] = "Gale",
  ["#kuangfeng-card"] = "Strong Gale: You can discard 1 \"Star\" then choose a player",
  ["#kuangfeng-target"] = "Strong Gale: Please choose a player, until your next turn, he suffers stronger Fire DMG",
  ["@@dawu"] = "Mist",
  ["#dawu-card"] = "Heavy Gale: You can discard at least 1 \"Stars\" then choose same # of players",
  ["#dawu-target"] = "Heavy Gale: Choose %arg player(s), until your next turn, protect him from all DMG (except Thunder)",

  ["godlvbu"] = "Lv Bu",
  ["kuangbao"] = "Violent Rage",
  [":kuangbao"] = '(forced) At the beginning of the game: you get 2 "Rage". After you cause/suffer 1 DMG: you get 1 "Rage".',
  ["wumou"] = "Simpleton",
  [":wumou"] = '(forced) When you use a non-delay trick card, you choose: 1. Remove 1 "Rage". 2. Lose 1 HP.',
  ["wuqian"] = "Unprecedented",
  [":wuqian"] = 'In your Action Phase: you can remove 2 "Rage" and select a player. This turn, that player\'s armor becomes ineffective and you acquire "Without Equal".',
  ["shenfen"] = "Asura's Fury",
  [":shenfen"] = 'Once per Action Phase: you can remove 6 "Rage"; then, every other player:<br>\
    - Suffers 1 DMG.<br>\
    - Discards all his equipped cards.<br>\
    - Discards 4 hand cards.<br>\
    Finally, turn over your character card.',

  ["@baonu"] = "Rage",
  ["wumouBaonu"] = "Remove 1 \"Rage\"",
  ["@@wuqian-turn"] = "Unprecedented",
  ["#wuqianCleaner"] = "Unprecedented",

  ["godcaocao"] = "Cao Cao",
  ["guixin"] = "Homage",
  [":guixin"] = "After you suffer 1 DMG: you can take 1 card from every other player in any of his areas; then, turn over your character.",
  ["feiying"] = "Flying Shadow",
  [":feiying"] = "(forced) You always have a bonus +1 horse.",

  ["nos__godzhaoyun"] = "神赵云",
  ["nos__juejing"] = "绝境",
  [":nos__juejing"] = "锁定技，摸牌阶段，你令额定摸牌数+X（X为你已损失的体力值）；你的手牌上限+2。",
  ["nos__longhun"] = "龙魂",
  [":nos__longhun"] = "你可以将X张你的同花色的牌按以下规则使用或打出：红桃当【桃】，方块当火【杀】，梅花当【闪】，黑桃当【无懈可击】（X为你的体力值且至少为1）。",

  ["godzhaoyun"] = "神赵云",
  ["juejing"] = "绝境",
  [":juejing"] = "锁定技，你的手牌上限+2；当你进入濒死状态时或你的濒死结算结束后，你摸一张牌。",
  ["longhun"] = "龙魂",
  [":longhun"] = "你可以将至多两张你的同花色的牌按以下规则使用或打出：红桃当【桃】，方块当火【杀】，梅花当【闪】，黑桃当【无懈可击】。若你以此法使用或打出了两张：红桃牌，此牌回复基数+1；方块牌，此牌伤害基数+1；黑色牌，你弃置当前回合角色一张牌。",
  ["#longhun_discard"] = "龙魂",

  ["gundam"] = "高达一号",
  ["gundam__juejing"] = "绝境",
  [":gundam__juejing"] = "锁定技，你跳过摸牌阶段；当你的手牌数大于4/小于4时，你将手牌弃置至4/摸至4张。",
  ["gundam__longhun"] = "龙魂",
  [":gundam__longhun"] = "你可以将你的牌按以下规则使用或打出：红桃当【桃】，方块当火【杀】，梅花当【闪】，黑桃当【无懈可击】。准备阶段开始时，如果场上有【青釭剑】，你可以获得之。",

  ["#gundam__longhun_qinggang"] = "龙魂",
  ["#gundam__longhun_qinggang-target"] = "龙魂：你可夺走 %src 的【青釭剑】！",
  ["#gundam__longhun_qinggang-targets"] = "龙魂：你可夺走 %src 等的【青釭剑】！",

  ["godsimayi"] = "神司马懿",
  ["renjie"] = "忍戒",
  [":renjie"] = "锁定技，当你受到伤害后/于弃牌阶段弃置手牌后，你获得X枚“忍”（X为伤害值/你弃置的手牌数）。",
  ["baiyin"] = "拜印",
  [":baiyin"] = "觉醒技，准备阶段开始时，若你的“忍”数大于3，你减1点体力上限，获得〖极略〗。",
  ["lianpo"] = "连破",
  [":lianpo"] = "当你杀死一名角色后，你可于此回合结束后获得一个额外回合。",
  ["jilve"] = "极略",
  [":jilve"] = "你可以弃置1枚“忍”，发动下列一项技能：〖鬼才〗、〖放逐〗、〖集智〗、〖制衡〗、〖完杀〗。",
  ["@godsimayi_bear"] = "忍",
  ["#jilve-zhiheng"] = "极略：你可以弃置1枚“忍”标记，发动〖制衡〗",
  ["#jilve-wansha"] = "极略：你可以弃置1枚“忍”标记，获得〖完杀〗直到回合结束",
  ["#jilve_trigger"] = "极略",
  ["#lianpo-invoke"] = "连破：你可以额外执行一个回合！",

  ["godliubei"] = "神刘备",
  ["longnu"] = "龙怒",
  [":longnu"] = "转换技，锁定技，出牌阶段开始时，阳：你失去1点体力，摸一张牌，你的红色手牌于此阶段内均视为火【杀】，你于此阶段内使用火【杀】无距离限制；"..
  "阴：你减1点体力上限，摸一张牌，你的锦囊牌于此阶段内均视为雷【杀】，你于此阶段内使用雷【杀】无次数限制。",
  ["jieying"] = "结营",
  [":jieying"] = "锁定技，你始终处于横置状态；处于连环状态的角色手牌上限+2；结束阶段开始时，你横置一名其他角色。",

  ["#longnu_filter"] = "龙怒",
  ["#jieying-target"] = "结营：选择一名其他角色，令其横置",

  ["godluxun"] = "神陆逊",
  ["junlue"] = "军略",
  [":junlue"] = "锁定技，当你造成或受到1点伤害后，你获得一枚“军略”。",
  ["@junlue"] = "军略",
  ["cuike"] = "摧克",
  [":cuike"] = "出牌阶段开始时，若你的“军略”数为：奇数，你可以对一名角色造成1点伤害；偶数，你可以弃置一名角色区域里的一张牌，令其横置。然后若“军略”数大于7，你可弃全部“军略”，对所有其他角色各造成1点伤害。",
  ["#cuike-damage"] = "摧克：你可以对一名角色造成1点伤害",
  ["#cuike-discard"] = "摧克：你可以弃置一名角色区域里的一张牌并横置之",
  ["#cuike-shenfen"] = "摧克：你可以弃置所有“军略”对所有其他角色各造成1点伤害",
  ["zhanhuo"] = "绽火",
  [":zhanhuo"] = "限定技，出牌阶段，你可以弃全部“军略”，令至多等量的处于连环状态的角色弃置所有装备区里的牌，然后对其中一名角色造成1点火焰伤害。",
  ["#zhanhuo-damage"] = "绽火：对其中一名角色造成一点火焰伤害",
  ["#zhanhuo-prompt"] = "绽火：弃置全部“军略”并选择至多等量处于连环状态中的角色",

  ["godzhangliao"] = "神张辽",
  ["duorui"] = "夺锐",
  [":duorui"] = "当你于出牌阶段内对一名其他角色造成伤害后，你可以废除你的一个装备栏，然后选择该角色的武将牌上的一个技能"..
  "（限定技、觉醒技、使命技、主公技除外），令其于其下回合结束之前此技能无效，然后你于其下回合结束或其死亡之前拥有此技能且不能发动〖夺锐〗。",
  ["zhiti"] = "止啼",
  [":zhiti"] = "锁定技，你攻击范围内已受伤的角色手牌上限-1；当你和这些角色拼点或【决斗】你赢时，你恢复一个装备栏。"..
  "当你受到伤害后，若来源在你的攻击范围内且已受伤，你恢复一个装备栏。",

  ["#duorui-choice"] = "是否发动 夺锐，废除一个装备栏，夺取%dest一个技能",
  ["#duorui-skill"] = "夺锐：选择%dest的一个技能令其无效，且你获得此技能",
  ["@duorui_source"] = "夺锐",
  ["@duorui_target"] = "被夺锐",
  ["#zhiti-choice"] = "止啼：选择要恢复的装备栏",

  ["godganning"] = "神甘宁",
  ["poxi"] = "魄袭",
  [":poxi"] = "出牌阶段限一次，你可以观看一名其他角色的手牌，然后你可以弃置你与其手里共计四张不同花色的牌。若如此做，根据此次弃置你的牌数量执行以下效果：没有，体力上限减1；一张，结束出牌阶段且本回合手牌上限-1；三张，回复1点体力；四张，摸四张牌。",
  ["gn_jieying"] = "劫营",
  [":gn_jieying"] = "回合开始时，若没有角色有“营”标记，你获得一个“营”标记；结束阶段你可以将“营”标记交给一名其他角色；有“营”的角色摸牌阶段多摸一张牌、使用【杀】的次数上限+1、手牌上限+1。有“营”的其他角色的结束阶段，你获得其“营”标记及所有手牌。",

  ["#poxi-prompt"] = "魄袭：选择一名有手牌的其他角色，并可弃置你与其手牌中共计四张花色各不相同的牌",
  ["@@jieying_camp"] = "营",
  ["#poxi-choose"] = "魄袭：从双方的手牌中选出四张不同花色的牌弃置，或者点取消",
  ["#gn_jieying-choose"] = "劫营：你可将营标记交给其他角色",

  ["goddiaochan"] = "神貂蝉",
  ["meihun"] = "魅魂",
  [":meihun"] = "结束阶段或当你成为【杀】目标后，你可以令一名其他角色" ..
    "交给你一张你声明的花色的牌，若其没有则你观看其手牌然后弃置其中一张。",
  ["#meihun-choose"] = "魅魂：你可以对一名其他角色发动“魅魂”",
  ["#meihun-give"] = "魅魂：请交给 %src 一张 %arg 牌",

  ["huoxin"] = "惑心",
  [":huoxin"] = "出牌阶段限一次，你可以展示两张花色相同的手牌并分别交给两名" ..
    "其他角色，然后令这两名角色拼点，没赢的角色获得1个“魅惑”标记；若双方拼点点数" ..
    "相差5或更多，改为获得2个“魅惑”标记。拥有2个或" ..
    "更多“魅惑”的角色回合即将开始时，该角色移去其所有“魅惑”，" ..
    "此回合改为由你操控。",
  ["@huoxin-meihuo"] = "魅惑",
  ["#huoxin-choose"] = "惑心：请将一张牌交给其中一名角色，另一张牌自动交给另一名",
  ["#huoxin-pindian"] = "惑心：请选择拼点牌，拼点没赢会获得1枚魅惑标记",
  ["#huoxin_trig"] = "惑心",
}