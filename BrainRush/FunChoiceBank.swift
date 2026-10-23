import Foundation

/// おもしろ2択：小学生向け雑学。難問2択とは別ファイル。
enum FunChoiceBank {
    static var count: Int { items.count }

    static func pick(excluding usedIDs: Set<String>) -> StroopRound {
        let available = items.filter { !usedIDs.contains($0.id) }
        return (available.randomElement() ?? items.randomElement())?.make() ?? items[0].make()
    }

    static func template(id: String) -> Item? {
        items.first { $0.id == id }
    }

    static func allRounds() -> [StroopRound] {
        items.map { $0.make() }
    }

    static func explanation(id: String) -> String {
        template(id: id)?.explanation ?? tr(
            ja: "もう一度問題を読んで、チェックの付いた正解と比べてみよう。",
            zh: "再读一遍题目，对照带勾的正确答案。",
            en: "Read the question again and compare it with the checked answer.",
            my: "မေးခွန်းကို ပြန်ဖတ်ပြီး အမှန်ခြစ်ထားသောအဖြေနှင့် နှိုင်းယှဉ်ပါ။"
        )
    }

    struct Item {
        let id: String
        let ja: String
        let zh: String
        let en: String
        let my: String
        let answerID: String
        let choices: [(id: String, ja: String, zh: String, en: String, my: String)]
        let explainJA: String
        let explainZH: String
        let explainEN: String
        let explainMY: String

        var rule: String { tr(ja: ja, zh: zh, en: en, my: my) }
        var explanation: String { tr(ja: explainJA, zh: explainZH, en: explainEN, my: explainMY) }

        func make(shuffle: Bool = true) -> StroopRound {
            let picks = shuffle ? choices.shuffled() : choices
            return StroopRound(
                task: .funChoice,
                rule: rule,
                answerID: answerID,
                choices: picks.map {
                    AnswerChoice(id: $0.id, title: tr(ja: $0.ja, zh: $0.zh, en: $0.en, my: $0.my), symbol: nil, style: .neutral)
                },
                stimulus: .emblem(id: id)
            )
        }
    }

    private static let items: [Item] = [
        Item(
            id: "fun-kangaroo-bday",
            ja: "カンガルーの赤ちゃんの誕生日は、次のうちどちらになるでしょうか？",
            zh: "袋鼠宝宝的生日算哪一天？",
            en: "When is a baby kangaroo’s birthday?",
            my: "ကန်ဂါရုကလေးရဲ့ မွေးနေ့က ဘယ်အချိန်လဲ။",
            answerID: "pouch",
            choices: [
                ("birth", "出産の時", "出生的时候", "When it is born", "မွေးချိန်"),
                ("pouch", "お母さんのお腹の袋から出てきた時", "从妈妈肚子上的袋子里出来的时候", "When it comes out of the mother’s pouch", "အမ၏ အိတ်ထဲမှ ထွက်လာချိန်"),
            ],
            explainJA: "カンガルーの赤ちゃんは生まれるとすぐにお母さんのお腹の袋に這い上がります。そして約半年後にお腹の袋から顔を出します。この時がカンガルーの赤ちゃんの誕生日になります。",
            explainZH: "袋鼠宝宝出生后马上爬进妈妈肚子上的袋子。大约半年后才从袋子里探出头来。这一天才算袋鼠宝宝的生日。",
            explainEN: "A joey crawls into the mother’s pouch right after birth, then shows its face about six months later. That is counted as its birthday.",
            explainMY: "ကန်ဂါရုကလေး မွေးပြီး အမ၏ အိတ်ထဲ တက်သွားသည်။ ခြောက်လခန့်ကြာမှ အိတ်ထဲမှ မျက်နှာထုတ်သည်။ ထိုအချိန်ကို မွေးနေ့ဟု သတ်မှတ်သည်။"
        ),
        Item(
            id: "fun-sos",
            ja: "S.O.Sは助けを求めるサインです。S.O.Sはどんな言葉の略でしょうか？",
            zh: "S.O.S 是求救信号。它是什么词的缩写？",
            en: "S.O.S is a distress signal. What does it stand for?",
            my: "S.O.S သည် အကူအညီတောင်းသင်္ကေတ။ ဘာစာလုံးအတိုလဲ။",
            answerID: "none",
            choices: [
                ("ship", "Save Our Ship（私たちの船を助けてくれ）", "Save Our Ship（救救我们的船）", "Save Our Ship", "Save Our Ship (ကျွန်ုပ်တို့သင်္ဘောကို ကယ်ပါ)"),
                ("none", "略語ではなく特に意味はない", "不是缩写，没有特别含义", "It isn’t an abbreviation and has no special meaning", "အတိုကောက်မဟုတ်၊ အထူးအဓိပ္ပာယ် မရှိ"),
            ],
            explainJA: "いろんな説がありますが、S.O.Sには特に意味がなく、モールス信号などで伝えやすいシンプルな文字を並べただけという説が最も有力だと考えられています。",
            explainZH: "虽然有很多说法，最有力的是：S.O.S 本身没有特别含义，只是摩尔斯电码里好发、好认的简单字母排列。",
            explainEN: "There are many stories, but the strongest view is that S.O.S has no special meaning: the letters were chosen because they are simple to send in Morse code.",
            explainMY: "အယူအဆများရှိသော်လည်း S.O.S တွင် အထူးအဓိပ္ပာယ်မရှိ၊ မော့စ်ကုဒ်တွင် ပို့ရလွယ်သော စာလုံးများသာ ဟူသော အဆို အခိုင်မာဆုံးဖြစ်သည်။"
        ),
        Item(
            id: "fun-highway-bus",
            ja: "高速バスなど長距離を走るバスは、運転手が2人いて交代で運転しています。このような高速バスに隠されている秘密は次のうちどちらでしょうか？",
            zh: "跑长途的高速巴士有两名司机轮流开车。这种巴士里藏着的秘密是哪一个？",
            en: "Long-distance highway buses have two drivers who take turns. Which secret do they hide?",
            my: "ခရီးရှည်ဘတ်စ်တွင် ယာဉ်မောင်း ၂ ဦး အလှည့်ကျ မောင်းသည်။ ဘာလျှို့ဝှက်ချက်ရှိသလဲ။",
            answerID: "nap",
            choices: [
                ("nap", "運転手が仮眠するための休憩室がある", "有给司机打盹的休息室", "There is a rest room for the driver to nap", "ယာဉ်မောင်း အိပ်စက်ရန် အနားယူခန်း ရှိသည်"),
                ("amphibious", "万が一の水害に備えて水陸両用車になる", "为了防水灾会变成水陆两用车", "They turn amphibious in case of flooding", "ရေဘေးအတွက် ကုန်းရေနှစ်သွယ်ကား ဖြစ်သည်"),
            ],
            explainJA: "高速バスなどには、バスのタイヤの近くに運転手の仮眠室が作られているものがあります。コンセント、エアコン、ベッドなどがあり、ゆっくり休めるようになっています。",
            explainZH: "有的高速巴士在轮胎附近做了司机的小休息室，有插座、空调和床，可以好好休息。",
            explainEN: "Some highway buses have a driver nap room near the tires, with an outlet, air conditioning, and a bed.",
            explainMY: "အချို့ခရီးရှည်ဘတ်စ်တွင် တာယာအနီး ယာဉ်မောင်းအိပ်ခန်းရှိသည်။ ပလပ်ပေါက်၊ လေအေးပေးစက်၊ ကုတင် ပါသည်။"
        ),
        Item(
            id: "fun-konpeito",
            ja: "お菓子の「金平糖(こんぺいとう)」は、日本語か外国語どちらでしょうか？",
            zh: "点心「金平糖（こんぺいとう）」是日语还是外来语？",
            en: "Is the candy name 「金平糖 / konpeito」 Japanese or a foreign word?",
            my: "「金平糖 / konpeito」က ဂျပန်စကားလား၊ နိုင်ငံခြားစကားလား။",
            answerID: "foreign",
            choices: [
                ("japanese", "日本語", "日语", "Japanese", "ဂျပန်စကား"),
                ("foreign", "外国語", "外来语", "A foreign word", "နိုင်ငံခြားစကား"),
            ],
            explainJA: "金平糖はポルトガル語の「confeito（コンフェイト）」から付けられた外国語です。戦国時代に伝わったと言われている昔懐かしい素朴なお菓子です。",
            explainZH: "金平糖来自葡萄牙语 confeito，是外来语。据说战国时代传入，是一种怀旧的朴素点心。",
            explainEN: "Konpeito comes from Portuguese confeito, so it is a foreign word. It is said to have arrived in the Sengoku period.",
            explainMY: "ကွန်ပေးတိုးသည် ပေါ်တူဂီ confeito မှ ဆင်းသက်သော နိုင်ငံခြားစကား။ စင်ဂိုကုခေတ် ရောက်လာသည်ဟု ဆိုသည်။"
        ),
        Item(
            id: "fun-pupa",
            ja: "蝶などの幼虫はサナギになって成虫へと変化を遂げます。これを「変態（へんたい）」と言いますが、この時のサナギの中身はどのような状態でしょうか？",
            zh: "蝴蝶等幼虫会变成蛹再变成成虫，这叫「变态」。这时蛹里面是什么状态？",
            en: "A caterpillar becomes a pupa, then an adult — metamorphosis. What is inside the pupa?",
            my: "လိပ်ပြာကလေး ပိုးအိမ်ဖြစ်ပြီး အရွယ်ရောက်သည်။ ပိုးအိမ်အတွင်း ဘယ်လိုအခြေအနေလဲ။",
            answerID: "liquid",
            choices: [
                ("formed", "中は最初から成虫の形になっている", "里面一开始就是成虫的形状", "The adult shape is already formed inside", "အတွင်းမှာ အရွယ်ရောက်ပုံ ရှိပြီးသား"),
                ("liquid", "ドロドロの液体になっている", "变成黏糊糊的液体", "It turns into a gooey liquid", "ပျစ်ပျစ်အရည် ဖြစ်နေသည်"),
            ],
            explainJA: "サナギの中身は必要な神経以外の組織はドロドロに溶けています。このドロドロの液体が無数の変化を重ねて、成虫の体はゆっくり作られていきます。幼虫が成虫へと形を変えるために、サナギの中では大変なことが行われているんですね。",
            explainZH: "蛹里面除了必要的神经，其他组织都会化成黏糊糊的液体。这些液体经过无数变化，慢慢做成成虫的身体。",
            explainEN: "Inside the pupa, tissues except essential nerves melt into goo. That liquid is rebuilt, little by little, into the adult body.",
            explainMY: "ပိုးအိမ်အတွင်း လိုအပ်သော အာရုံကြောမှလွဲ၍ တစ်သျှူးများ အရည်ပျော်သည်။ ထိုအရည်မှ အရွယ်ရောက်ကိုယ်ခန္ဓာ ဖြည်းဖြည်း ဖြစ်လာသည်။"
        ),
        Item(
            id: "fun-panda-food",
            ja: "パンダ1頭あたりの1日のエサ代はおよそいくらでしょうか？",
            zh: "一头熊猫一天的饲料费大约是多少？",
            en: "About how much does one panda’s food cost per day?",
            my: "ပန်ဒါတစ်ကောင် တစ်ရက်စာ အစာဖိုး ဘယ်လောက်လဲ။",
            answerID: "eleven",
            choices: [
                ("thousand", "約1000円", "大约 1000 日元", "About 1,000 yen", "၁၀၀၀ ယန်းခန့်"),
                ("eleven", "約11000円", "大约 11000 日元", "About 11,000 yen", "၁၁၀၀၀ ယန်းခန့်"),
            ],
            explainJA: "上野動物園で食費が高い動物と言えばパンダだと言われています。上野動物園のパンダは1頭あたり1日でエサ代に約11000円かかります。単純に計算しても月に約33万円、1年間で約396万円もかかることになります。",
            explainZH: "上野动物园里饲料费最贵的动物据说是熊猫。一头一天大约 11000 日元，一个月大约 33 万，一年大约 396 万日元。",
            explainEN: "Pandas are said to have the highest food bill at Ueno Zoo: about 11,000 yen a day per animal, or about 3.96 million yen a year.",
            explainMY: "အုအဲနို တိရစ္ဆာန်ရုံတွင် ပန်ဒါ အစာဖိုး အကြီးဆုံး။ တစ်ကောင် တစ်ရက် ၁၁၀၀၀ ယန်းခန့်၊ တစ်နှစ် ၃၉၆ သိန်းခန့်။"
        ),
        Item(
            id: "fun-bath-sleepy",
            ja: "お風呂で眠くなるのは体の危険信号だと言われています。それはいったいどうしてでしょうか？",
            zh: "据说在浴缸里发困是身体的危险信号。为什么？",
            en: "Feeling sleepy in the bath is said to be a warning. Why?",
            my: "ရေချိုးကန်ထဲ ငိုက်ခြင်းသည် အန္တရာယ်သတိပေးချက်ဟု ဆိုသည်။ ဘာကြောင့်လဲ။",
            answerID: "faint",
            choices: [
                ("faint", "お風呂で眠くなるのは失神する寸前だから", "因为那是快要昏过去的前兆", "Because you are close to fainting", "မေ့မြောတော့မည့် အခြေအနေ ဖြစ်သောကြောင့်"),
                ("nutrition", "お風呂で眠くなるのは栄養失調のサインだから", "因为那是营养不良的信号", "Because it is a sign of malnutrition", "အာဟာရချို့တဲ့သင်္ကေတ ဖြစ်သောကြောင့်"),
            ],
            explainJA: "お風呂で眠くなるのは血圧が下がって脳に酸素が届かなくなるためです。溺れてしまう危険もありますので、眠くなったらすぐに浴槽から出るようにしましょう。",
            explainZH: "在浴缸里发困是因为血压下降、大脑供氧不足。还有溺水的危险，困了就马上出浴缸。",
            explainEN: "Sleepiness in the bath comes from falling blood pressure and less oxygen to the brain. Get out right away; there is a drowning risk.",
            explainMY: "ရေချိုးကန်ထဲ ငိုက်ခြင်းသည် သွေးပေါင်ကျပြီး ဦးနှောက် အောက်ဆီဂျင် မရသောကြောင့်။ နစ်မြုပ်နိုင်သဖြင့် ချက်ချင်း ထွက်ပါ။"
        ),
        Item(
            id: "fun-shiba-monument",
            ja: "柴犬は日本でどのように扱われているでしょうか？",
            zh: "柴犬在日本被怎样对待？",
            en: "How is the shiba inu treated in Japan?",
            my: "ရှိဘခွေးကို ဂျပန်တွင် ဘယ်လို သတ်မှတ်သလဲ။",
            answerID: "monument",
            choices: [
                ("mascot", "日本のマスコットキャラクター", "日本的吉祥物角色", "Japan’s mascot character", "ဂျပန်၏ မျက်နှာစာ ဇာတ်ကောင်"),
                ("monument", "日本の天然記念物", "日本的天然纪念物", "A natural monument of Japan", "ဂျပန် သဘာဝအထိမ်းအမှတ်"),
            ],
            explainJA: "柴犬は国の天然記念物に指定されています。他にも北海道犬、秋田犬、甲斐犬、四国犬、紀州犬の和犬が天然記念物に指定されています。柴犬は日本を代表する犬として世界中でも愛されています。",
            explainZH: "柴犬被指定为国家天然纪念物。北海道犬、秋田犬、甲斐犬、四国犬、纪州犬等和犬也是。柴犬作为日本代表犬种，在全世界都很受欢迎。",
            explainEN: "The shiba is a designated national natural monument, along with other Japanese dogs such as Hokkaido, Akita, Kai, Shikoku, and Kishu.",
            explainMY: "ရှိဘသည် နိုင်ငံ၏ သဘာဝအထိမ်းအမှတ်။ ဟော့ကိုင်းဒို၊ အခိတ၊ ခိုင်၊ ရှိကိုးကု၊ ခိရှု ခွေးများလည်း ပါသည်။"
        ),
        Item(
            id: "fun-bike-signal",
            ja: "自転車で信号無視をするとどうなるでしょうか？",
            zh: "骑自行车闯红灯会怎样？",
            en: "What happens if you run a red light on a bicycle?",
            my: "စက်ဘီးဖြင့် မီးပွိုင့်ချိုးဖောက်ရင် ဘာဖြစ်မလဲ။",
            answerID: "penalty",
            choices: [
                ("warning", "口で注意されるだけで終わる", "只会被口头提醒就结束", "You only get a spoken warning", "ပါးစပ်ဖြင့် သတိပေးရုံသာ"),
                ("penalty", "懲役刑または罰金刑がある", "可能有徒刑或罚金", "There can be jail time or a fine", "ထောင်ဒဏ် သို့မဟုတ် ဒဏ်ကြေး ရှိနိုင်သည်"),
            ],
            explainJA: "自転車で信号無視をすると、「3ヶ月以下の懲役または5万円以下の罰金」になる場合があります。信号は必ず守るようにしましょう！",
            explainZH: "骑自行车闯红灯，有可能被处「3 个月以下徒刑或 5 万日元以下罚金」。一定要遵守信号灯。",
            explainEN: "Running a red light on a bike can mean up to 3 months in jail or a fine of up to 50,000 yen. Always obey the lights.",
            explainMY: "စက်ဘီးဖြင့် မီးပွိုင့်ချိုးဖောက်ရင် လများ ၃ လအောက် ထောင်ဒဏ် သို့မဟုတ် ယန်း ၅ သောင်းအောက် ဒဏ်ကြေး ဖြစ်နိုင်သည်။"
        ),
        Item(
            id: "fun-winter-toilet",
            ja: "冬は夏よりもたくさんトイレに行きたくなるのはどうしてでしょうか？",
            zh: "冬天比夏天更想上厕所，是为什么？",
            en: "Why do people need the toilet more in winter than in summer?",
            my: "ဆောင်းရာသီတွင် နွေထက် အိမ်သာပိုသွားချင်သည်။ ဘာကြောင့်လဲ။",
            answerID: "sweat",
            choices: [
                ("sweat", "汗をかく量が減るから", "因为出汗变少了", "Because you sweat less", "ချွေးထွက်နည်းသောကြောင့်"),
                ("need", "体に必要な水分の量が減るから", "因为身体需要的水分变少了", "Because the body needs less water", "ခန္ဓာကိုယ်လိုအပ်သော ရေပမာဏ လျော့သောကြောင့်"),
            ],
            explainJA: "人間の体に必要な水分の量は季節によってそれほど変わりません。冬はあまり汗をかかなくなるため、その代わりにたくさんトイレでおしっこをするようになります。",
            explainZH: "人体需要的水分量并不会随季节差很多。冬天不怎么出汗，水分就更多从厕所排出。",
            explainEN: "The body still needs about the same amount of water. In winter you sweat less, so more of it leaves as urine.",
            explainMY: "ခန္ဓာကိုယ်လိုအပ်သော ရေပမာဏ ရာသီအလိုက် သိပ်မပြောင်း။ ဆောင်းတွင် ချွေးနည်းသဖြင့် အိမ်သာပိုသွားရသည်။"
        ),
        Item(
            id: "fun-shumai-pea",
            ja: "シュウマイの上に1粒だけグリーンピースが付いているのはいったいどうしてでしょうか？",
            zh: "烧卖上面只放一颗青豆，到底是为什么？",
            en: "Why is there just one green pea on a shumai dumpling?",
            my: "ရှုမိုင်ပေါ် ပဲစိမ်းတစ်လုံးသာ ဘာကြောင့် တင်ထားသလဲ။",
            answerID: "cake",
            choices: [
                ("cake", "ショートケーキのイチゴのデザインを取り入れた", "借鉴了水果蛋糕上那颗草莓的设计", "It copies the strawberry on a shortcake", "ရှော့ကိတ်ပေါ် စတော်ဘယ်ရီ ဒီဇိုင်းကို ယူထားသည်"),
                ("nutrition", "グリーンピースの栄養をプラスするため", "为了加上青豆的营养", "To add the nutrition of green peas", "ပဲစိမ်းအာဟာရ ထည့်ရန်"),
            ],
            explainJA: "シュウマイのグリーンピースは、ショートケーキに乗っているイチゴを参考にしています。確かに1粒のグリーンピースがあるだけで見た目の印象が変わりますね。",
            explainZH: "烧卖上的青豆是参考水果蛋糕上的草莓。只要一颗，观感就不一样。",
            explainEN: "The pea on shumai was inspired by the strawberry on shortcake. One pea really changes how it looks.",
            explainMY: "ရှုမိုင်ပေါ် ပဲစိမ်းသည် ရှော့ကိတ်ပေါ် စတော်ဘယ်ရီကို နမူနာယူသည်။ တစ်လုံးတည်းဖြင့် အသွင်ပြောင်းသည်။"
        ),
        Item(
            id: "fun-firework-whistle",
            ja: "夏の風物詩である打ち上げ花火は、打ちあがる時に「ヒュー」と高い音が鳴ります。この音の正体は次のうちどちらでしょうか？",
            zh: "夏天的焰火升空时会发出「咻」的高音。这个声音的真面目是？",
            en: "Summer fireworks make a high “wheee” as they go up. What is that sound?",
            my: "နွေရာသီ မီးရှူးပစ်တင်စဉ် 「ဝီး」 အသံမြင့်ထွက်သည်။ ဘာအသံလဲ။",
            answerID: "whistle",
            choices: [
                ("friction", "花火玉が上がる時に空気中で摩擦が起きた時の音", "焰火球上升时和空气摩擦的声音", "Friction with the air as the shell rises", "မီးလုံးတက်စဉ် လေနှင့် ပွတ်တိုက်သံ"),
                ("whistle", "花火玉の中に仕掛けられている笛が鳴る音", "焰火球里装的哨子发出的声音", "A whistle built into the firework shell", "မီးလုံးထဲ ထည့်ထားသော ပလွေသံ"),
            ],
            explainJA: "打ち上げ花火の玉の中には、観客の期待を高めるために「ヒュー」という音を出すための笛が仕掛けられています。つまりあの音は自然に鳴っているのではなく、あえて鳴るように設計されているということです。",
            explainZH: "升空焰火的弹体里装着哨子，故意发出「咻」来吊观众的胃口。那不是自然摩擦声，是设计出来的。",
            explainEN: "A whistle is built into the shell so it goes “wheee” and builds excitement. The sound is designed, not natural friction.",
            explainMY: "မီးလုံးထဲ ပလွေထည့်ထားသည်။ ပရိသတ် မျှော်လင့်ချက်မြှင့်ရန် တမင် ဒီဇိုင်းလုပ်ထားခြင်း ဖြစ်သည်။"
        ),
        Item(
            id: "fun-snail-teeth",
            ja: "カタツムリには歯は何本ぐらいあるでしょうか？",
            zh: "蜗牛大概有多少颗牙？",
            en: "About how many teeth does a snail have?",
            my: "ခရုတွင် သွားဘယ်နှစ်ချောင်းခန့် ရှိသလဲ။",
            answerID: "ten-thousand",
            choices: [
                ("hundred", "100本", "100 颗", "100", "၁၀၀ ချောင်း"),
                ("ten-thousand", "10000本", "10000 颗", "10,000", "၁၀၀၀၀ ချောင်း"),
            ],
            explainJA: "のんびりした動きがかわいいカタツムリには、たくさんの歯があるのを知っていますか？カタツムリには歯舌（しぜつ）という歯が10000本以上生えています。人間の歯のようなものではなく、舌のようにザラザラした細かな歯の形をしています。",
            explainZH: "慢悠悠的蜗牛其实有很多牙。齿舌上长着 10000 颗以上的小牙，不像人牙，更像舌头上密密的粗糙小齿。",
            explainEN: "A snail has a radula with more than 10,000 tiny teeth — not like human teeth, more like a rough tongue.",
            explainMY: "ခရုတွင် သွားလျှာပေါ် သွား ၁၀၀၀၀ ကျော်ရှိသည်။ လူသွားနှင့် မတူ၊ လျှာကဲ့သို့ ကြမ်းသော သွားငယ်များ။"
        ),
        Item(
            id: "fun-turtle-eggs",
            ja: "砂浜に上陸して産卵するウミガメは、一度にどれくらいの数の卵を産卵するでしょうか？",
            zh: "爬上沙滩产卵的海龟，一次大约产多少卵？",
            en: "How many eggs does a sea turtle lay at once on the beach?",
            my: "သဲသောင်ပေါ် တက်ဥဥသော ပင်လယ်လိပ် တစ်ကြိမ် ဘယ်နှစ်လုံးဥသလဲ။",
            answerID: "hundred",
            choices: [
                ("ten", "10個ぐらい", "大约 10 个", "About 10", "၁၀ လုံးခန့်"),
                ("hundred", "100個以上", "100 个以上", "More than 100", "၁၀၀ လုံးကျော်"),
            ],
            explainJA: "海の生物は一度にたくさんの卵を産むものが多いです。ウミガメは一度の産卵で100個以上の卵を産みますが、そのうち無事に大人になれるのは0.02％ほどだと言われています。",
            explainZH: "海里很多生物一次会产很多卵。海龟一次产 100 个以上，但能长大的大约只有 0.02%。",
            explainEN: "Sea turtles lay more than 100 eggs at a time, but only about 0.02% are said to reach adulthood.",
            explainMY: "ပင်လယ်လိပ် တစ်ကြိမ် ဥ ၁၀၀ ကျော်ဥသည်။ အရွယ်ရောက်နိုင်သည်မှာ ၀.၀၂% ခန့်သာ။"
        ),
        Item(
            id: "fun-horse-sweet",
            ja: "馬の大好物は次のうちどちらでしょうか？",
            zh: "马最爱吃的是哪一类？",
            en: "Which do horses love most?",
            my: "မြင်းအကြိုက်ဆုံးက ဘယ်ဟာလဲ။",
            answerID: "sweet",
            choices: [
                ("sweet", "甘い野菜や果物", "甜的蔬菜和水果", "Sweet vegetables and fruit", "ချိုသော ဟင်းသီးဟင်းရွက်နှင့် သစ်သီး"),
                ("sour", "酸っぱい野菜や果物", "酸的蔬菜和水果", "Sour vegetables and fruit", "ချဉ်သော ဟင်းသီးဟင်းရွက်နှင့် သစ်သီး"),
            ],
            explainJA: "馬は甘いものが大好きです。馬はニンジンが好きだと言われていますが、他にもリンゴ、はちみつ、角砂糖なども喜んで食べます。",
            explainZH: "马很爱吃甜的。据说喜欢胡萝卜，也爱吃苹果、蜂蜜和方糖。",
            explainEN: "Horses love sweet things: carrots, and also apples, honey, and sugar cubes.",
            explainMY: "မြင်းသည် အချိုကြိုက်သည်။ မုန်လာဥနီ၊ ပန်းသီး၊ ပျားရည်၊ သကြားတုံးလည်း စားသည်။"
        ),
        Item(
            id: "fun-hedgehog-spikes",
            ja: "体にたくさんの針を持つハリネズミ。ハリネズミのハリはいつ出てくるでしょうか？",
            zh: "身上长满刺的刺猬。刺是什么时候长出来的？",
            en: "When do a hedgehog’s spines appear?",
            my: "ပြောင်၏ ဆူးများ ဘယ်အချိန် ပေါ်လာသလဲ။",
            answerID: "five-min",
            choices: [
                ("born", "最初から針だらけで生まれてくる", "生下来就全身是刺", "They are born already covered in spines", "မွေးကတည်းက ဆူးအပြည့်"),
                ("five-min", "生まれて5分後ぐらいに出てくる", "出生大约 5 分钟后才出来", "They come out about 5 minutes after birth", "မွေးပြီး ၅ မိနစ်ခန့်တွင် ပေါ်သည်"),
            ],
            explainJA: "ハリネズミは生まれた瞬間は針が皮膚の下に隠れているため針は見えません。生まれて5分ほどすると隠れていた針が出て体はトゲトゲになります。",
            explainZH: "刺猬刚出生时刺藏在皮肤下面，看不见。大约 5 分钟后刺才会露出来，身体变得扎扎的。",
            explainEN: "At birth the spines are hidden under the skin. About five minutes later they come out.",
            explainMY: "မွေးချိန်တွင် ဆူးများ အရေပြားအောက် ပုန်းနေသည်။ ၅ မိနစ်ခန့်တွင် ထွက်လာသည်။"
        ),
        Item(
            id: "fun-cucumber-water",
            ja: "次のうち水分が多いのはどちらの野菜でしょうか？",
            zh: "下面哪种蔬菜水分更多？",
            en: "Which vegetable has more water?",
            my: "ဘယ်ဟင်းသီးဟင်းရွက် ရေပိုများသလဲ။",
            answerID: "cucumber",
            choices: [
                ("cucumber", "キュウリ", "黄瓜", "Cucumber", "သခွားသီး"),
                ("daikon", "大根", "萝卜", "Daikon radish", "ကြက်သွန်မြိတ်ဖြူ"),
            ],
            explainJA: "キュウリの水分量はおよそ97％、大根の水分量はおよそ93％ほどです。わずかにキュウリの方が多いですが、どちらも非常にみずみずしい野菜と言えますね。",
            explainZH: "黄瓜水分大约 97%，萝卜大约 93%。黄瓜略多，两种都很水灵。",
            explainEN: "Cucumber is about 97% water, daikon about 93%. Cucumber wins by a little; both are very juicy.",
            explainMY: "သခွားသီး ရေ ၉၇% ခန့်၊ ဒိုင်ကွန် ၉၃% ခန့်။ သခွားနည်းနည်း ပိုများသည်။"
        ),
        Item(
            id: "fun-edo-proxy",
            ja: "江戸時代には今では考えられないお仕事がありました。それは次のうちどちらでしょうか？",
            zh: "江户时代有一种现在很难想象的工作。是哪一种？",
            en: "Edo Japan had a job that is hard to imagine today. Which one?",
            my: "အဲဒိုခေတ်တွင် ယခု စဉ်းစားရခက်သော အလုပ်ရှိသည်။ ဘယ်ဟာလဲ။",
            answerID: "fart",
            choices: [
                ("fart", "おならをした人の身代わりになる仕事", "替放屁的人顶罪的工作", "A job standing in for someone who passed gas", "လေလည်သူအစား ဝန်ခံသော အလုပ်"),
                ("steal", "盗み食いをした人の身代わりになる仕事", "替偷吃的人顶罪的工作", "A job standing in for someone who snuck food", "ခိုးစားသူအစား ဝန်ခံသော အလုပ်"),
            ],
            explainJA: "江戸時代では、おならは現代以上に恥ずかしいことだと考えられていました。そのため、高貴な身分の人物がおならをしてしまった時のために、「私がオナラをしました」などと言って、身代わりになって自分がオナラをしたことにする仕事が存在していました。その人たちは普段は高貴な人のそばについて身の回りの世話をして、いざという時にはオナラの身代わりになるのが役割でした。",
            explainZH: "江户时代把放屁看得比现在更丢人。高贵的人万一放了，会有人出来说「是我放的」来顶替。平时他们侍奉在身边，关键时刻就当这个替身。",
            explainEN: "Passing gas was even more embarrassing then. Servants of nobles might say “It was me” and take the blame. That was part of the job.",
            explainMY: "အဲဒိုခေတ်တွင် လေလည်ခြင်း ပိုရှက်သည်။ မြင့်မြတ်သူ လေလည်လျှင် «ကျွန်ုပ်လုပ်သည်» ဟု ဝန်ခံသော အလုပ်ရှိသည်။"
        ),
        Item(
            id: "fun-squid-ink",
            ja: "イカの墨は料理にたくさん使われますが、タコの墨があまり料理に使われないのはどうしてでしょうか？",
            zh: "鱿鱼墨常用于料理，章鱼墨却很少用，为什么？",
            en: "Squid ink is used a lot in cooking, but octopus ink is not. Why?",
            my: "ရွှေငါးမင် ဟင်းချက်တွင် များစွာသုံးသည်။ ရေဘဝဲမင် နည်းသည်။ ဘာကြောင့်လဲ။",
            answerID: "match",
            choices: [
                ("devil", "タコが海外では海の悪魔だと言われているから", "因为海外把章鱼叫做海的恶魔", "Because overseas the octopus is called a sea devil", "နိုင်ငံခြားတွင် ရေဘဝဲကို ပင်လယ်နတ်ဆိုးဟု ခေါ်သောကြောင့်"),
                ("match", "イカの墨の方が食材に合わせやすいから", "因为鱿鱼墨更容易搭配食材", "Because squid ink matches other ingredients more easily", "ရွှေငါးမင်က ပါဝင်ပစ္စည်းနှင့် ပိုလိုက်သောကြောင့်"),
            ],
            explainJA: "タコは確かに海外では海の悪魔だと言われています。しかし、イカの墨の方が多くの料理に使われているのは、単純にイカの墨の方が食材に合わせやすいからだと言われています。",
            explainZH: "海外确实有把章鱼叫海的恶魔的说法。但料理里更常用鱿鱼墨，只是因为它更好搭配食材。",
            explainEN: "Octopus is sometimes called a sea devil abroad, but squid ink is used more simply because it pairs better with other foods.",
            explainMY: "ရေဘဝဲကို ပင်လယ်နတ်ဆိုးဟု ခေါ်ကြသည်။ သို့သော် ရွှေငါးမင်ကို ပိုသုံးသည်မှာ ပါဝင်ပစ္စည်းနှင့် ပိုလိုက်သောကြောင့်သာ။"
        ),
        Item(
            id: "fun-four-stomachs",
            ja: "キリンやシカ、ヤギなどの動物は胃袋が人間よりもたくさんあります。胃袋の数は何個あるでしょうか？",
            zh: "长颈鹿、鹿、山羊等动物的胃比人多。有几个胃？",
            en: "Giraffes, deer, and goats have more stomachs than humans. How many?",
            my: "သစ်ကုလားအုပ်၊ သမင်၊ ဆိတ်တို့တွင် လူထက် အစာအိမ်ပိုများသည်။ ဘယ်နှစ်လုံးလဲ။",
            answerID: "four",
            choices: [
                ("two", "2個", "2 个", "2", "၂ လုံး"),
                ("four", "4個", "4 个", "4", "၄ လုံး"),
            ],
            explainJA: "キリン、シカ、ヤギ、ウシ、ヒツジなどはなんと胃袋が4個もあります。これらの草食動物たちは植物の栄養を効率的に摂取できるように胃袋が4個になったと言われています。",
            explainZH: "长颈鹿、鹿、山羊、牛、绵羊居然有 4 个胃，据说是为了更有效吸收植物营养。",
            explainEN: "Giraffes, deer, goats, cows, and sheep have four stomachs, said to help them get nutrients from plants.",
            explainMY: "သစ်ကုလားအုပ်၊ သမင်၊ ဆိတ်၊ နွား၊ သိုးတွင် အစာအိမ် ၄ လုံးရှိသည်။ အပင်အာဟာရ ရရန်ဟု ဆိုသည်။"
        ),
        Item(
            id: "fun-soda-upside",
            ja: "開封したペットボトルの炭酸ジュースの炭酸が抜けにくくなる保存方法があります。それはどちらでしょうか？",
            zh: "打开过的瓶装碳酸饮料，有一种保存方法更不容易跑气。是哪一种？",
            en: "After you open a plastic bottle of soda, which storage trick keeps the fizz longer?",
            my: "ဖွင့်ပြီး ပလတ်စတစ်ပုလင်း ဆိုဒါပူဖောင်း မလွယ်အောင် သိမ်းနည်း ဘယ်ဟာလဲ။",
            answerID: "upside",
            choices: [
                ("upside", "上下逆さまにする", "上下颠倒放", "Store it upside down", "ပြောင်းပြန်ထားပါ"),
                ("wrap", "キャップの上からラップを巻く", "在瓶盖外再缠一层保鲜膜", "Wrap the cap in plastic wrap", "အဖုံးပေါ် ပလတ်စတစ်စ စည်းပါ"),
            ],
            explainJA: "ペットボトルの炭酸飲料は、一度開封するとキャップをしめても炭酸ガスが空気と入れ替わってしまい炭酸が抜けていってしまいます。しかし、上下逆さま（キャップが下向きになるようにする）にして保存すると中身がキャップの周りに集まって炭酸が抜けにくくなります。とは言え、一度開けたジュースは飲み過ぎない程度になるべく早く飲んでしまうのがベストです。",
            explainZH: "开封后再盖盖，碳酸仍会和空气交换而跑掉。倒过来放，液体聚在瓶盖周围，气就不容易跑。不过开过的饮料还是尽快喝完最好。",
            explainEN: "Even recapped, gas swaps with air and the drink goes flat. Stored upside down, liquid seals around the cap and fizz lasts longer. Still, finish opened soda soon.",
            explainMY: "ဖွင့်ပြီး ပြန်ပိတ်လည်း ပူဖောင်းလေနှင့် လဲသည်။ ပြောင်းပြန်ထားရင် အရည်က အဖုံးပတ်လည် ပိတ်ပေးသည်။ သို့သော် အမြန်သောက်ပါ။"
        ),
        Item(
            id: "fun-sacker",
            ja: "スーパーで商品を袋詰めするための台の名前はなんでしょうか？",
            zh: "超市里用来装袋的台子叫什么？",
            en: "What is the packing counter at a supermarket called in Japanese?",
            my: "စူပါမားကတ်တွင် အိတ်ထည့်စားပွဲကို ဘာခေါ်သလဲ။",
            answerID: "soccer",
            choices: [
                ("tennis", "テニス台", "网球台", "Tennis counter", "တင်းနစ်စားပွဲ"),
                ("soccer", "サッカー台", "足球台", "Soccer / sacker counter", "ဘောလုံးစားပွဲ"),
            ],
            explainJA: "「sacker（サッカー）」とは、イギリス英語で「袋詰め作業をする店員」という意味です。スポーツのサッカーとは関係がありません。",
            explainZH: "「sacker（サッカー）」在英式英语里指做装袋工作的店员，和足球运动无关。",
            explainEN: "“Sacker” in British English means a clerk who bags groceries. It has nothing to do with the sport soccer.",
            explainMY: "sacker သည် ဗြိတိသျှအင်္ဂလိပ်တွင် အိတ်ထည့်ဝန်ထမ်း။ အားကစား ဘောလုံးနှင့် မဆိုင်။"
        ),
        Item(
            id: "fun-licca-shoes",
            ja: "リカちゃん人形の靴をなめるとどんな味がするでしょうか？",
            zh: "舔莉卡娃娃的鞋子会是什么味道？",
            en: "What do Licca-chan doll shoes taste like if you lick them?",
            my: "လိခါရုပ်စွပ်ဖိနပ်ကို လျှာနဲ့လျှက်ရင် ဘယ်လိုအရသာလဲ။",
            answerID: "bitter",
            choices: [
                ("spicy", "とても辛い", "非常辣", "Very spicy", "အလွန်စပ်သည်"),
                ("bitter", "とても苦い", "非常苦", "Very bitter", "အလွန်ခါးသည်"),
            ],
            explainJA: "リカちゃん人形の靴は、小さい子どもが飲みこんでしまうのを防ぐためにとても苦い味が付いています。大人でもたまらず口から吐き出してしまうほど強烈な苦さですが、体に害はありません。",
            explainZH: "莉卡娃娃的鞋子带了很苦的味道，防止小孩子吞下去。苦到大人也会马上吐出来，但对身体没有害。",
            explainEN: "Licca-chan shoes are made very bitter so small children won’t swallow them. Adults spit them out too; they are not harmful.",
            explainMY: "လိခါဖိနပ်ကို ကလေး မမျိုစေရန် အလွန်ခါးအောင် လုပ်ထားသည်။ အန္တရာယ်မရှိ။"
        ),
        Item(
            id: "fun-library-book",
            ja: "図書館で借りた本が破れてしまった時、どうするのが正解でしょうか？",
            zh: "从图书馆借的书破了，怎样做才对？",
            en: "If a library book tears, what should you do?",
            my: "စာကြည့်တိုက်စာအုပ် စုတ်ပြဲရင် ဘာလုပ်ရမလဲ။",
            answerID: "report",
            choices: [
                ("report", "何もせず図書館の人に報告する", "什么都别做，告诉图书馆的人", "Don’t fix it; tell the library staff", "ဘာမှမလုပ်ဘဲ စာကြည့်တိုက်ဝန်ထမ်းကို ပြောပါ"),
                ("tape", "セロハンテープを貼って黙っておく", "贴上透明胶带并瞒着", "Put on cellophane tape and say nothing", "ကော်တိပ်ကပ်ပြီး ငြိမ်နေပါ"),
            ],
            explainJA: "もしも図書館で借りた本が破れてしまっても、セロハンテープを貼ったりせずにそのままにしておいて図書館の人に報告してください。図書館の本は、本を直すための専用のテープで直しています。セロハンテープは逆に本を傷めてしまうので、絶対に貼らないでください。",
            explainZH: "书破了不要贴透明胶带，原样拿去告诉图书馆的人。馆里用专用胶带修补。透明胶带反而会伤书，千万别贴。",
            explainEN: "Don’t tape it. Leave it and tell the staff. Libraries use special repair tape; cellophane tape damages books.",
            explainMY: "ကော်တိပ်မကပ်ပါနှင့်။ မူလအတိုင်း ဝန်ထမ်းကို ပြောပါ။ စာကြည့်တိုက်တွင် အထူးကော်သုံးသည်။"
        ),
        Item(
            id: "fun-melonpan",
            ja: "メロンパンの名前の由来はなんでしょうか？",
            zh: "蜜瓜包这个名字从哪来？",
            en: "Where does the name melonpan come from?",
            my: "မယ်လွန်ပန် အမည် ဘယ်ကလာသလဲ။",
            answerID: "looks",
            choices: [
                ("juice", "メロン果汁を入れて作っているから", "因为里面加了蜜瓜汁", "Because it is made with melon juice", "မယ်လွန်ဖျော်ရည် ထည့်သောကြောင့်"),
                ("looks", "見た目がメロンに似ているから", "因为样子像蜜瓜", "Because it looks like a melon", "မယ်လွန်နှင့် ပုံဆင်သောကြောင့်"),
            ],
            explainJA: "メロンパンは、1930年代に「金生堂（きんせいどう）」という神戸のパン屋が販売したのが始まりと言われています。その名前の由来は、表面がメロンの網目のように見えることです。実際にメロン果汁を使ったメロンパンもありますが、メロン果汁が入っていなくてもメロンパンを名乗ることはできます。",
            explainZH: "据说蜜瓜包始于 1930 年代神户面包店「金生堂」。名字来自表面像蜜瓜网纹。也有加蜜瓜汁的，但没有果汁也可以叫蜜瓜包。",
            explainEN: "Melonpan is said to have started at Kinseido in Kobe in the 1930s. The name comes from the melon-like netted crust. Juice is optional.",
            explainMY: "မယ်လွန်ပန်သည် ၁၉၃၀ ပြည့်လွန် ကိုဘဲ ကင်ဆေဒိုမှ စသည်ဟု ဆိုသည်။ အမည်မှာ အခွံကွန်ရက် မယ်လွန်နှင့် တူသောကြောင့်။"
        ),
        Item(
            id: "fun-cosmetics-floor",
            ja: "デパートの化粧品売り場は1階にあります。その理由はなんでしょうか？",
            zh: "百货公司的化妆品柜台在一楼。原因是什么？",
            en: "Department-store cosmetics are on the first floor. Why?",
            my: "ဒီပတ်စတိုး အလှကုန်ကောင်တာ ပထမထပ်တွင် ရှိသည်။ ဘာကြောင့်လဲ။",
            answerID: "smell",
            choices: [
                ("smell", "においが広がらないようにするため", "为了不让气味扩散", "So the smell does not spread", "အနံ့ မပျံ့စေရန်"),
                ("notice", "より目立ってお客さんが集まりやすくするため", "为了更显眼、更好招客", "To stand out and draw more customers", "ပိုမြင်သာပြီး ဖောက်သည် စုရန်"),
            ],
            explainJA: "空気はどんどん下へ移動していきます。もしも化粧品売り場が2階以上のフロアにあった場合、下の階までにおいが広がってしまいます。それを防ぐためにも出入口があって空気が入れ替わりやすい1階に化粧品売り場が配置されるようになりました。",
            explainZH: "空气会往下走。化妆品如果在二楼以上，气味会飘到下面各层。所以放在一楼门口附近，空气容易更换。",
            explainEN: "Air sinks. Cosmetics upstairs would send smell to lower floors. The first floor, near doors, ventilates better.",
            explainMY: "လေသည် အောက်သို့ ဆင်းသည်။ အပေါ်ထပ်ထားရင် အနံ့ အောက်ထပ်များသို့ ပျံ့သည်။ ပထမထပ် တံခါးနားတွင် လေလဲလွယ်သည်။"
        ),
        Item(
            id: "fun-banana-spots",
            ja: "バナナの皮に黒い点が出てきました。そのバナナはどんな状態でしょうか？",
            zh: "香蕉皮上冒出黑点。这根香蕉是什么状态？",
            en: "Black spots appear on a banana peel. What does that mean?",
            my: "ငှက်ပျောခွံပေါ် အစက်မည်းများ ပေါ်လာသည်။ ဘယ်လိုအခြေအနေလဲ။",
            answerID: "sweet",
            choices: [
                ("rot", "腐りかけている", "快要烂了", "It is starting to rot", "ပုပ်ခါနီး"),
                ("sweet", "甘味が増している", "甜味在增加", "It is getting sweeter", "ချိုမြင့်လာသည်"),
            ],
            explainJA: "バナナの皮に現れる黒い点は「シュガースポット」と言います。「シュガースポット」が出ているバナナは、熟して甘くなっているサインです。しかし、そのまま放っておくと傷んでしまうのでなるべく早めに食べましょう。",
            explainZH: "香蕉皮上的黑点叫「糖斑」，说明熟了、更甜了。不过再放下去会坏，尽快吃掉。",
            explainEN: "Those dots are sugar spots, a sign the banana is ripe and sweeter. Eat it soon or it will spoil.",
            explainMY: "အစက်မည်းများကို သကြားအစက်ဟု ခေါ်သည်။ ရင့်ပြီး ပိုချိုသည်။ သို့သော် မြန်မြန် စားပါ။"
        ),
        Item(
            id: "fun-medicine-water",
            ja: "薬を飲む時の水の量として正しいのはどちらでしょうか？",
            zh: "吃药时水量怎样才对？",
            en: "When you take medicine, should you use more water or less?",
            my: "ဆေးသောက်စဉ် ရေဘယ်လောက်သောက်သင့်သလဲ။",
            answerID: "more",
            choices: [
                ("more", "多め", "多一些", "A larger amount", "များများ"),
                ("less", "少なめ", "少一些", "A smaller amount", "နည်းနည်း"),
            ],
            explainJA: "薬は多めの水で飲むようにしましょう。水が少ないと途中で薬が引っかかって、胃まで届かない可能性があります。",
            explainZH: "吃药要用比较多的水。水太少，药可能卡在中途到不了胃。",
            explainEN: "Take medicine with plenty of water. Too little and it may get stuck before it reaches the stomach.",
            explainMY: "ဆေးကို ရေများများနှင့် သောက်ပါ။ ရေနည်းရင် ဆေးကြားတွင် ကပ်ပြီး အစာအိမ် မရောက်နိုင်။"
        ),
        Item(
            id: "fun-fugu-ban",
            ja: "昔、食べることが禁止されたことがある魚はなんでしょうか？",
            zh: "以前曾经被禁止食用的鱼是哪一种？",
            en: "Which fish was once banned from being eaten?",
            my: "ရှေးက စားရန် တားမြစ်ခဲ့သော ငါးက ဘယ်ဟာလဲ။",
            answerID: "fugu",
            choices: [
                ("fugu", "フグ", "河豚", "Pufferfish", "ဖူဂု"),
                ("tuna", "マグロ", "金枪鱼", "Tuna", "တူနာ"),
            ],
            explainJA: "フグは美味しい高級魚ですが、毒があることでも知られている魚です。昔は今のように毒を取り除く方法が広まっていないせいで、フグを食べて死んでしまう人がたくさんいたそうです。そのため、豊臣秀吉はフグを食べることを禁止する命令を出していたと言われています。",
            explainZH: "河豚是美味的高级鱼，也以有毒出名。从前去除毒素的方法还不普及，吃河豚致死的人很多。据说丰臣秀吉曾下令禁止吃河豚。",
            explainEN: "Fugu is a luxury fish and also poisonous. Before safe preparation spread, many people died eating it. Toyotomi Hideyoshi is said to have banned it.",
            explainMY: "ဖူဂု အရသာရှိသော်လည်း အဆိပ်ရှိသည်။ အဆိပ်ဖယ်နည်း မပျံ့မီ သေသူများသည်။ တိုယောတိုမိ ဟိဒဲယိုရှိ တားမြစ်သည်ဟု ဆိုသည်။"
        ),
        Item(
            id: "fun-arbeit",
            ja: "「アルバイト」は、元々は何語でしょうか？",
            zh: "「アルバイト」原本是哪国语言？",
            en: "What language does 「アルバイト / arubaito」 come from?",
            my: "「アルバイト」 မူလက ဘယ်ဘာသာလဲ။",
            answerID: "german",
            choices: [
                ("english", "英語", "英语", "English", "အင်္ဂလိပ်"),
                ("german", "ドイツ語", "德语", "German", "ဂျာမန်"),
            ],
            explainJA: "アルバイトの語源は、ドイツ語の「Arbeit」です。日本語に訳すと「労働」という意味です。",
            explainZH: "「アルバイト」的词源是德语 Arbeit，日语意思是「劳动」。",
            explainEN: "Arubaito comes from German Arbeit, which means labor or work.",
            explainMY: "အာရုဘိုင်တို၏ အရင်းသည် ဂျာမန် Arbeit။ အဓိပ္ပာယ်မှာ အလုပ်/အလုပ်သမား။"
        ),
    ]
}
