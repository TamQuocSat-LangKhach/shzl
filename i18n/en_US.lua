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
  [":liegong"] = "After you target with a Slash in you action phase, if the target's hand cards is not less than you HP or not more than you ATK range, you can make him can't use Jink to respond this Slash.",

  ["weiyan"] = "Wei Yan",
  ["kuanggu"] = "Haughty Streak",
  [":kuanggu"] = "<b>Compulsory skill</b>, after you cause 1 DMG to a player at distance 1, you heal 1 HP.",

  ["xiaoqiao"] = "Xiao Qiao",
  ["tianxiang"] = "Heavenly Scent",
  [":tianxiang"] = "When you are about to take DMG, you can discard 1 heart hand card, transfer this DMG to another player, then he draws X cards (X=his lost HP).",
  ["#tianxaing-choose" ] = "Heavenly Scent: you may discard 1 heart hand card to transfer the DMG",
  ["hongyan"] = "Youthful Beauty",
  [":hongyan"] = "<b>Compulsory skill</b>, your spade cards are regarded as heart cards.",

  ["zhoutai"] = "Zhou Tai",
  ["buqu"] = "Refusing Death",
  [":buqu"] = 'When you are dying, you can place a card at the top of draw pile to your character card, face-up ("Wound"). If its number is not same as all your other "Wounds", you quit dying so you won\'t die; otherwise, put it into discard pile. After you recover 1 HP, if you have "Wounds", you need to put 1 of them into discard pile.',
  ["#buqu-invoke"] = 'Refusing Death: you can place %arg card(s) at the top of draw pile to "Wound"',
  ["#buqu_duplicate"] = '"%arg2" of %from fails: %arg duplicate pairs in the "Wound"',
  ["#buqu_duplicate_group"] = "Duplicated numbers #%arg: %arg2",
  ["#buqu_duplicate_item"] = 'Duplicated "Wound" cards: %arg',
  ["#buqu_remove"] = '%from removes "Wound" cards：%arg',
  ["zhoutai_chuang"] = "Wound",

  ["zhangjiao"] = "Zhang Jiao",
  ["leiji"] = "Lighting Strike",
  [":leiji"] = "When you use/play Jink, you can let a player to perform a judgement, if the result is spade, you deal 2 Thunder DMG to him.",
  ["guidao"] = "Dark Sorcery",
  [":guidao"] = "Before a player's judge card takes effect, you can play a black card to replace it.",
  ["huangtian"] = "Yellow Sky",
  [":huangtian"] = "<b>Lord skill</b>, once per action phase of other Neutral characters, they can give you a Jink or a Lightning.",

  ["#leiji-choose"] = "Lighting Strike: you can let a player to perform judgement now",
  ["#guidao-ask"] = 'Dark Sorcery: you can play a black card to replace %dest\'s judge card (reason is "%arg")',

  ["huangtian_other&"] = "Yellow Sky",
  [":huangtian_other&"] = "Once per action phase, you can give a Jink or a Lightning to Zhang Jiao.",

  ["yuji"] = "Yu Ji",
  ["guhuo"] = "Demagogue",
  [":guhuo"] = "You can use/play a card face-down and declare it as any basic card or normal trick card; then all other players whose HP is above 0 are asked whether they believe you. This card takes effect unless someone doubts you, in this case flip the card immediately: if is was fake, all the disbelievers draw 1 card; if it was real, all the disbelievers lose 1 HP.<br>This card is useless and discarded as long as it has been flipped over, regardless whether is real or fake, UNLESS the card is both real and has a suit of heart, in which case the card is still effective.",
  ["question"] = "Question",
  ["noquestion"] = "No Question",
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
  [":bazhen"] = "<b>Compulsory skill</b>, If you don't have any armor equipped, you are regarded as having Eight Diagram equipped.",
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
  [":niepan"] = "<b>Limited skill</b>, when you are dying, you can discard all of your cards, reset your character card, then draw 3 cards and heal to 3 HP.",
  ["#lianhuan"] = "Chaining: use club hand card as Iron Chain or recast",

  ["taishici"] = "Taishi Ci",
  ["tianyi"] = "Justice of Heaven",
  [":tianyi"] = "Once per action phase, you can point fight with another player, if you win, until the end of the turn, your Slash have no distance limit, you can use +1 extra Slash, and your Slash can target to +1 extra player; if you lose, you can't use Slash for the rest of this turn.",

  ["pangde"] = "Pang De",
  ["mengjin"] = "Fearsome Advance",
  [":mengjin"] = "After you Slash is offseted by target's Jink, you can discard him 1 card.",

  ["yanliangwenchou"] = "Yan L. & Wen C.",
  ["shuangxiong"] = "Dual Heroes",
  [":shuangxiong"] = "During you draw phase, you can change to perform a judgement; you get the judge result card, and in this turn you can use any card with a different color from the judge result as Duel.",
  ["@shuangxiong-turn"] = "Dual H.",
  ["#shuangxiongJude"] = "Dual Heroes",

  ["yuanshao"] = "Yuan Shao",
  ["luanji"] = "Chaos Archery",
  [":luanji"] = "You can use 2 hand cards with the same suit as Archery Attack.",
  ["xueyi"] = "Bloodline",
  [":xueyi"] = "<b>Lord skill, compulsory skill</b>, you max card is increased by +2*X (X=the amount of other Neutral characters in the game)",

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
  [":songwei"] = "<b>Lord skill</b>, after another Wei character's black judge card takes effect, he can let you draw 1 card.",

  ["#fangzhu-choose"] = "Banish into Exile: you can make another turn over and draw cards",
  ["#songwei-invoke"] = "Exalt the Powerful: you can let %src draw 1 card",

  ["menghuo"] = "Meng Huo",
  ["huoshou"] = "The Smoking Gun",
  [":huoshou"] = "<b>Compulsory skill</b>, Savage Assault has no effect on you; when Savage Assault deals DMG, you become the DMG source.",
  ["zaiqi"] = "Great Again",
  [":zaiqi"] = "During you draw phase, if you are wounded, you can change to show X cards at the top of draw pile (X=your lost HP), you discard all heart cards of them and recover same amount of HP, then you get the rest of cards.",

  ["zhurong"] = "Zhu Rong",
  ["juxiang"] = "Giant Elephant",
  [":juxiang"] = "<b>Compulsory skill</b>, Savage Assault has no effect on you; after Savage Assault used by another player have finished all effects, you get that card.",
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
  [":roulin"] = "<b>Compulsory skill</b>, when you use Slash target to a female character of when a famale character uses Slash target to you, the target needs to use 2 Jink to evade it.",
  ["benghuai"] = "Disintegration",
  [":benghuai"] = "<b>Compulsory skill</b>, at the start of your finish phase, if you aren't the player with the lowest HP, you choose: 1. Lose 1 HP; 2. Lose 1 max HP.",
  ["baonve"] = "The Tyrant",
  [":baonve"] = "<b>Lord skill</b>, after other Neutral character deals 1 DMG, he can perform a judgement, if the result is spade, you heal 1 HP.",
  ["loseMaxHp"] = "Lose 1 max HP",
  ["loseHp"] = "Lose 1 HP",
  ["#baonve-invoke"] = "The Tyrant: you can perform judgement, if result is spade, %src heals 1 HP",

  ["jiaxu"] = "Jia Xu",
  ["wansha"] = "Unmitigated Murder",
  [":wansha"] = "<b>Compulsory skill</b>, during your turn, only you and the dying player can use Peach.",
  ["luanwu"] = "Descend into Chaos",
  [":luanwu"] = "<b>Limited skill</b>, during you action phase, you can make all other players choose: 1. Use a Slash to the player in their least distance; 2. Lose 1 HP.",
  ["weimu"] = "Behind the Curtain",
  [":weimu"] = "<b>Compulsory skill</b>, you can't be the target of black trick cards.",

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
  [":zaoxian"] = '<b>Awaken skill</b>, at the start of prepare phase, if you have 3 or 3+ "Fields", you lose 1 max HP and acquire the skill Blitz.',
  ["jixi"] = "Blitz",
  [":jixi"] = 'You can use a "Field" as Snatch.',
  ["dengai_field"] = "Field",

  ["jiangwei"] = "Jiang Wei",
  ["tiaoxin"] = "Provoke",
  [":tiaoxin"] = "Once per action phase, you can select a player who has you within his attack range, then ask him to use a Slash to you. If he didn't use Slash, you discard him 1 card.",
  ["zhiji"] = "Carry out Behest",
  [":zhiji"] = "<b>Awaken skill</b>, at the start of you prepare phase, if you don't have hand cards, you choose: 1. Draw 2 cards; 2. Heal 1 HP. Then you lose 1 max HP and acquire the skill Stargaze.",
  ["#tiaoxin-use"] = "Provoke: please use a Slash to him, otherwise he discard you 1 card",
  ["draw1"] = "Draw 1 card",
  ["draw2"] = "Draw 2 cards",
  ["recover"] = "Heal 1 HP",

  ["liushan"] = "Liu Shan",
  ["xiangle"] = "Indulged",
  [":xiangle"] = "<b>Compulsory skill</b>, after a player uses Slash to target you, the user choose: 1. Discard 1 basic card; 2. This Slash has no effect on you.",
  ["#xiangle-discard"] = "Indulged: you must discard 1 basic card, otherwise this Slash has no effect on %src",
  ["fangquan"] = "Devolution",
  [":fangquan"] = "You can skip your action phase, and when this turn over, you discard 1 hand card and choose another player, he will play an extra turn.",
  ["#fangquan-give"] = "Devolution: you can discard 1 hand card to let another play an extra turn",
  ["ruoyu"] = "Like Fool",
  [":ruoyu"] = "<b>Lord skill, awaken skill</b>, at the start of you prepare phase, if you have the fewest HP, you heal 1 max HP and heal 1 HP, then acquire the skills Rouse.",

  ["sunce"] = "Sun Ce",
  ["jiang"] = "Heated",
  [":jiang"] = "After you target with/you are targeted by Duel or red Slash, you can draw 1 card.",
  ["hunzi"] = "Divine Aura",
  [":hunzi"] = "<b>Awaken skill</b>, at the start of prepare phase, if you HP is 1, you lose 1 max HP and acquire the skills Soul of Hero and Handsome.",
  ["zhiba"] = "Hegemony",
  [":zhiba"] = "<b>Lord skill</b>, once per action phase of another Wu character, he can point fight you (if you have activated Divine Aura you can refuse him), if he doesn't win, you can take both cards.",

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
  ["@&huanshen"] = "Incarnation",
  ["#huashen"] = "Incarnation: choose the skill you want to acquire",
  ["@huanshen_skill"] = "Inca.",

  ["caiwenji"] = "Cai Wenji",
  ["beige"] = "Dirge",
  [":beige"] = "After a player takes DMG from Slash, you can discard 1 card and let him perform a judgement, if the result is: heart, he heals 1 HP; diamond, he draws 2 cards; club, the DMG source discard 2 cards; spade, the DMG source turns over.",
  ["duanchang"] = "Sorrow",
  [":duanchang"] = "<b>Compulsory skill</b>, when you died, the killer loses all of his skills.",
  ["#beige-invoke"] = "Dirge: %dest takes DMG, you can discard 1 card and let him perform judgement",
}