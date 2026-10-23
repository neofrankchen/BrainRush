import Foundation

/// 日本アニメ2択：漫画・アニメのキャラと物語。
enum AnimeChoiceBank {
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
                task: .animeChoice,
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
            id: "an-dora",
            ja: "『ドラえもん』で、ドラえもんが好きなお菓子は？",
            zh: "《哆啦A梦》中，哆啦A梦最喜欢的点心是什么？",
            en: "In Doraemon, what sweet does Doraemon like?",
            my: "ဒိုရာအဲမွန် ကြိုက်သော အချိုက ဘာလဲ။",
            answerID: "dorayaki",
            choices: [
                ("dorayaki", "どら焼き", "铜锣烧", "Dorayaki", "ဒိုရာယာကိ"),
                ("taiyaki", "たい焼き", "鲷鱼烧", "Taiyaki", "တိုင်ယာကိ"),
            ],
            explainJA: "正解はどら焼き。ドラえもんはどら焼きが大好き。たい焼きは別の魚の形の和菓子。",
            explainZH: "正确答案是铜锣烧。哆啦A梦最爱铜锣烧。鲷鱼烧是另一种鱼形点心。",
            explainEN: "Dorayaki. Taiyaki is a different fish-shaped cake.",
            explainMY: "အဖြေမှန်က ဒိုရာယာကိ။ တိုင်ယာကိက အခြားချို။"
        ),
        Item(
            id: "an-shinchan",
            ja: "『クレヨンしんちゃん』で、野原しんのすけは何歳？",
            zh: "《蜡笔小新》中，野原新之助几岁？",
            en: "How old is Shinnosuke in Crayon Shin-chan?",
            my: "ခရေးယွန်ရှင်ချန်တွင် ရှင်နိုဆုကဲ ဘယ်နှစ်နှစ်လဲ။",
            answerID: "five",
            choices: [
                ("seven", "7歳", "7岁", "7 years old", "၇ နှစ်"),
                ("five", "5歳", "5岁", "5 years old", "၅ နှစ်"),
            ],
            explainJA: "正解は5歳。しんのすけは幼稚園に通う5歳。7歳は小学生の年ごろ。",
            explainZH: "正确答案是 5 岁。小新上幼儿园，5 岁。7 岁已经是小学生了。",
            explainEN: "He is 5 and in kindergarten, not 7.",
            explainMY: "အဖြေမှန်က ၅ နှစ်။ အရုဏ်ကျောင်းသား။"
        ),
        Item(
            id: "an-conan",
            ja: "『名探偵コナン』で、江戸川コナンの本当の名前は？",
            zh: "《名侦探柯南》中，江户川柯南的真实姓名是什么？",
            en: "What is Edogawa Conan’s real name?",
            my: "အဲဒိုဂါဝါ ကိုနန်ရဲ့ အစစ်အမည်က ဘာလဲ။",
            answerID: "shinichi",
            choices: [
                ("shinichi", "工藤新一", "工藤新一", "Shinichi Kudo", "ခုဒို ရှင်အိချိ"),
                ("heiji", "服部平次", "服部平次", "Heiji Hattori", "ဟတ္တိုရိ ဟဲအိဂျိ"),
            ],
            explainJA: "正解は工藤新一。高校生探偵が小さくなってコナンになった。服部平次は大阪の探偵の友達。",
            explainZH: "正确答案是工藤新一。高中生侦探缩小后变成柯南。服部平次是大阪的侦探朋友。",
            explainEN: "Shinichi Kudo shrank into Conan. Heiji is his Osaka rival-friend.",
            explainMY: "အဖြေမှန်က ခုဒို ရှင်အိချိ။ ဟဲအိဂျိက အိုဆာကာ မိတ်ဆွေ။"
        ),
        Item(
            id: "an-pika",
            ja: "『ポケットモンスター』で、ピカチュウは何タイプ？",
            zh: "《宝可梦》中，皮卡丘是什么属性？",
            en: "What type is Pikachu?",
            my: "ပီကာချူးက ဘာအမျိုးအစားလဲ။",
            answerID: "electric",
            choices: [
                ("water", "みずタイプ", "水属性", "Water type", "ရေအမျိုး"),
                ("electric", "でんきタイプ", "电属性", "Electric type", "လျှပ်စစ်အမျိုး"),
            ],
            explainJA: "正解はでんきタイプ。ピカチュウは電気ネズミ。みずタイプではない。",
            explainZH: "正确答案是电属性。皮卡丘是电老鼠，不是水属性。",
            explainEN: "Electric type, not water.",
            explainMY: "အဖြေမှန်က လျှပ်စစ်။ ရေမဟုတ်။"
        ),
        Item(
            id: "an-db-count",
            ja: "『ドラゴンボール』で、ドラゴンボールは全部で何個？",
            zh: "《龙珠》中，龙珠一共有几颗？",
            en: "How many Dragon Balls are there in all?",
            my: "Dragon Ball ဘယ်နှစ်လုံးရှိသလဲ။",
            answerID: "seven",
            choices: [
                ("seven", "7個", "7颗", "7", "၇ လုံး"),
                ("eight", "8個", "8颗", "8", "၈ လုံး"),
            ],
            explainJA: "正解は7個。1つ星から7つ星まで7個集めると神龍が願いを叶える。",
            explainZH: "正确答案是 7 颗。从一星到七星集齐，神龙会实现愿望。",
            explainEN: "Seven balls, one-star through seven-star, summon Shenron.",
            explainMY: "အဖြေမှန်က ၇ လုံး။"
        ),
        Item(
            id: "an-luna",
            ja: "『美少女戦士セーラームーン』で、うさぎと一緒にいる黒猫の名前は？",
            zh: "《美少女战士》中，月野兔身边的黑猫叫什么？",
            en: "What is the black cat with Usagi named?",
            my: "ဆေလာမွန်းတွင် ဥဆဂိနှင့် နေသော ကြောင်မည်း အမည်က ဘာလဲ။",
            answerID: "luna",
            choices: [
                ("jiji", "ジジ", "吉吉", "Jiji", "ဂျိဂျိ"),
                ("luna", "ルナ", "露娜", "Luna", "လူနာ"),
            ],
            explainJA: "正解はルナ。額に月の印がある黒猫。ジジは魔女の宅急便の黒猫。",
            explainZH: "正确答案是露娜。额头有月印的黑猫。吉吉是《魔女宅急便》里的黑猫。",
            explainEN: "Luna, with a moon on her forehead. Jiji is from Kiki’s Delivery Service.",
            explainMY: "အဖြေမှန်က လူနာ။ ဂျိဂျိက အခြားဇာတ်။"
        ),
        Item(
            id: "an-maruko",
            ja: "『ちびまる子ちゃん』で、まる子は小学何年生？",
            zh: "《樱桃小丸子》中，小丸子读小学几年级？",
            en: "What grade is Maruko in?",
            my: "မာရုကို မူလတန်း ဘယ်နှစ်တန်းလဲ။",
            answerID: "third",
            choices: [
                ("third", "3年生", "三年级", "3rd grade", "၃ တန်း"),
                ("sixth", "6年生", "六年级", "6th grade", "၆ တန်း"),
            ],
            explainJA: "正解は3年生。まる子は清水市の小学校3年生。6年生ではない。",
            explainZH: "正确答案是三年级。小丸子是清水市小学三年级，不是六年级。",
            explainEN: "She is a third grader, not sixth.",
            explainMY: "အဖြေမှန်က ၃ တန်း။"
        ),
        Item(
            id: "an-sakuragi",
            ja: "『SLAM DUNK』で、桜木花道が入った部活は？",
            zh: "《灌篮高手》中，樱木花道加入了什么社团？",
            en: "Which club did Hanamichi Sakuragi join?",
            my: "ဆခုရဂိ ဝင်သော ကလပ်က ဘာလဲ။",
            answerID: "basketball",
            choices: [
                ("soccer", "サッカー部", "足球社", "Soccer club", "ဘောလုံးအသင်း"),
                ("basketball", "バスケットボール部", "篮球社", "Basketball club", "ဘတ်စကက်ဘောအသင်း"),
            ],
            explainJA: "正解はバスケットボール部。湘北高校のバスケ部。サッカー部ではない。",
            explainZH: "正确答案是篮球社。他进了湘北高中篮球部，不是足球社。",
            explainEN: "The basketball club at Shohoku, not soccer.",
            explainMY: "အဖြေမှန်က ဘတ်စကက်ဘော။"
        ),
        Item(
            id: "an-mei",
            ja: "『となりのトトロ』で、サツキの妹の名前は？",
            zh: "《龙猫》中，小月的妹妹叫什么？",
            en: "What is Satsuki’s little sister named in My Neighbor Totoro?",
            my: "ဆတ်စကိရဲ့ ညီမ အမည်က ဘာလဲ။",
            answerID: "mei",
            choices: [
                ("mei", "メイ", "小梅", "Mei", "မေ"),
                ("kanta", "カンタ", "康太", "Kanta", "ခန်တ"),
            ],
            explainJA: "正解はメイ。4歳の妹。カンタは近所の男の子。",
            explainZH: "正确答案是小梅（メイ）。4 岁的妹妹。康太是邻居家的男孩。",
            explainEN: "Mei, age 4. Kanta is a neighbor boy.",
            explainMY: "အဖြေမှန်က မေ။ ခန်တက အိမ်နီးချင်းယောက်ျားလေး။"
        ),
        Item(
            id: "an-kamehame",
            ja: "『ドラゴンボール』で、孫悟空が使う有名な技は？",
            zh: "《龙珠》中，孙悟空使用的著名招式是什么？",
            en: "What famous attack does Goku use?",
            my: "ဂိုကူ သုံးသော ကျော်ကြားသည့် နည်းက ဘာလဲ။",
            answerID: "kamehame",
            choices: [
                ("rasengan", "螺旋丸", "螺旋丸", "Rasengan", "ရာဆဲန်ဂန်"),
                ("kamehame", "かめはめ波", "龟派气功", "Kamehameha", "ခမဲဟမဲဟ"),
            ],
            explainJA: "正解はかめはめ波。亀仙人から習った技。螺旋丸はNARUTOの技。",
            explainZH: "正确答案是龟派气功。从龟仙人学来的。螺旋丸是《火影忍者》的招。",
            explainEN: "Kamehameha, from Master Roshi. Rasengan is from Naruto.",
            explainMY: "အဖြေမှန်က ခမဲဟမဲဟ။ ရာဆဲန်ဂန်က နရုတို။"
        ),
        Item(
            id: "an-luffy",
            ja: "『ONE PIECE』で、ルフィの夢は？",
            zh: "《海贼王》中，路飞的梦想是什么？",
            en: "What is Luffy’s dream in One Piece?",
            my: "လူဖီရဲ့ အိပ်မက်က ဘာလဲ။",
            answerID: "pirate",
            choices: [
                ("pirate", "海賊王になる", "成为海贼王", "To become Pirate King", "ပင်လယ်ဓားပြဘုရင် ဖြစ်ရန်"),
                ("hokage", "火影になる", "成为火影", "To become Hokage", "ဟိုခဂဲ ဖြစ်ရန်"),
            ],
            explainJA: "正解は海賊王になる。ルフィは海賊王を目指す。火影はNARUTOの目標。",
            explainZH: "正确答案是成为海贼王。成为火影是鸣人的目标。",
            explainEN: "Pirate King. Becoming Hokage is Naruto’s goal.",
            explainMY: "အဖြေမှန်က ပင်လယ်ဓားပြဘုရင်။ ဟိုခဂဲက နရုတို။"
        ),
        Item(
            id: "an-zoro",
            ja: "『ONE PIECE』で、ゾロが使う刀は普通何本？",
            zh: "《海贼王》中，索隆通常使用几把刀？",
            en: "How many swords does Zoro usually use?",
            my: "ဇိုရို သုံးသော ဓား အရေအတွက်က ဘယ်နှစ်လက်လဲ။",
            answerID: "three",
            choices: [
                ("two", "2本", "2把", "2", "၂ လက်"),
                ("three", "3本", "3把", "3", "၃ လက်"),
            ],
            explainJA: "正解は3本。口に1本くわえる三刀流。2本刀ではない。",
            explainZH: "正确答案是 3 把。三刀流，嘴里还咬一把。不是两把。",
            explainEN: "Three-sword style, one in his mouth. Not two.",
            explainMY: "အဖြေမှန်က ၃ လက်။"
        ),
        Item(
            id: "an-naruto-dream",
            ja: "『NARUTO -ナルト-』で、ナルトが目指しているのは？",
            zh: "《火影忍者》中，鸣人的目标是什么？",
            en: "What is Naruto aiming to become?",
            my: "နရုတို ရည်မှန်းသည်မှာ ဘာလဲ။",
            answerID: "hokage",
            choices: [
                ("hokage", "火影", "火影", "Hokage", "ဟိုခဂဲ"),
                ("pirate", "海賊王", "海贼王", "Pirate King", "ပင်လယ်ဓားပြဘုရင်"),
            ],
            explainJA: "正解は火影。木ノ葉隠れの里のトップ。海賊王はルフィの夢。",
            explainZH: "正确答案是火影。木叶村的首领。海贼王是路飞的梦想。",
            explainEN: "Hokage of the Hidden Leaf. Pirate King is Luffy’s dream.",
            explainMY: "အဖြေမှန်က ဟိုခဂဲ။"
        ),
        Item(
            id: "an-kakashi",
            ja: "『NARUTO -ナルト-』で、ナルトが所属する第七班の担当上忍は？",
            zh: "《火影忍者》中，鸣人所在第七班的指导上忍是谁？",
            en: "Who is Team 7’s jōnin instructor?",
            my: "အသင်း ၇ ရဲ့ ဂျိုနင်ဆရာက ဘယ်သူလဲ။",
            answerID: "kakashi",
            choices: [
                ("iruka", "イルカ", "伊鲁卡", "Iruka", "အိရုက"),
                ("kakashi", "カカシ", "卡卡西", "Kakashi", "ခခရှိ"),
            ],
            explainJA: "正解はカカシ。第七班の担当ははたけカカシ。イルカはナルトの先生でアカデミーの教官。",
            explainZH: "正确答案是卡卡西。第七班的指导上忍是旗木卡卡西。伊鲁卡是忍者学校的老师。",
            explainEN: "Kakashi Hatake leads Team 7. Iruka teaches at the Academy.",
            explainMY: "အဖြေမှန်က ခခရှိ။ အိရုကက ကျောင်းဆရာ။"
        ),
        Item(
            id: "an-nezuko",
            ja: "『鬼滅の刃』で、禰豆子は炭治郎の何？",
            zh: "《鬼灭之刃》中，祢豆子是炭治郎的什么人？",
            en: "What is Nezuko to Tanjiro?",
            my: "နဲဇုကိုက တန်ဂျီရိုနှင့် ဘာလဲ။",
            answerID: "sister",
            choices: [
                ("sister", "妹", "妹妹", "Younger sister", "ညီမ"),
                ("sister-older", "姉", "姐姐", "Older sister", "အစ်မ"),
            ],
            explainJA: "正解は妹。禰豆子は炭治郎の妹。姉ではない。",
            explainZH: "正确答案是妹妹。祢豆子是炭治郎的妹妹，不是姐姐。",
            explainEN: "Younger sister, not older sister.",
            explainMY: "အဖြေမှန်က ညီမ။ အစ်မ မဟုတ်။"
        ),
        Item(
            id: "an-zenitsu",
            ja: "『鬼滅の刃』で、我妻善逸が使う呼吸は？",
            zh: "《鬼灭之刃》中，我妻善逸使用什么呼吸？",
            en: "Which Breathing Style does Zenitsu use?",
            my: "ဇဲနစ်ဆု သုံးသော အသက်ရှူနည်းက ဘာလဲ။",
            answerID: "thunder",
            choices: [
                ("water", "水の呼吸", "水之呼吸", "Water Breathing", "ရေအသက်ရှူ"),
                ("thunder", "雷の呼吸", "雷之呼吸", "Thunder Breathing", "မိုးကြိုးအသက်ရှူ"),
            ],
            explainJA: "正解は雷の呼吸。善逸は雷の呼吸の壱の型。水の呼吸は炭治郎が使う。",
            explainZH: "正确答案是雷之呼吸。善逸用雷之呼吸。水之呼吸是炭治郎用的。",
            explainEN: "Thunder Breathing. Water Breathing is Tanjiro’s.",
            explainMY: "အဖြေမှန်က မိုးကြိုး။ ရေက တန်ဂျီရို။"
        ),
        Item(
            id: "an-titan",
            ja: "『進撃の巨人』で、人類が壁の外で恐れているのは？",
            zh: "《进击的巨人》中，人类害怕墙外的什么？",
            en: "What do people fear beyond the walls?",
            my: "နံရံအပြင် လူသားများ ကြောက်သည်မှာ ဘာလဲ။",
            answerID: "titan",
            choices: [
                ("titan", "巨人", "巨人", "Titans", "လူကြီး"),
                ("vampire", "吸血鬼", "吸血鬼", "Vampires", "သွေးစုပ်ဖုတ်ကောင်"),
            ],
            explainJA: "正解は巨人。壁の外には巨人がいる。吸血鬼の話ではない。",
            explainZH: "正确答案是巨人。墙外有巨人，不是吸血鬼。",
            explainEN: "Titans, not vampires.",
            explainMY: "အဖြေမှန်က လူကြီး။ သွေးစုပ် မဟုတ်။"
        ),
        Item(
            id: "an-mikasa",
            ja: "『進撃の巨人』で、エレンの幼なじみは誰？",
            zh: "《进击的巨人》中，艾伦的青梅竹马是谁？",
            en: "Who is Eren’s childhood friend?",
            my: "အဲရဲန်ရဲ့ ကလေးဘဝ မိတ်ဆွေက ဘယ်သူလဲ။",
            answerID: "mikasa",
            choices: [
                ("levi", "リヴァイ", "利威尔", "Levi", "လီဗိုင်း"),
                ("mikasa", "ミカサ", "三笠", "Mikasa", "မီကဆ"),
            ],
            explainJA: "正解はミカサ。エレンとアルミンの幼なじみ。リヴァイは調査兵団の兵士。",
            explainZH: "正确答案是三笠。艾伦和阿尔敏的青梅竹马。利威尔是调查兵团的士兵。",
            explainEN: "Mikasa. Levi is a Scout Regiment soldier.",
            explainMY: "အဖြေမှန်က မီကဆ။ လီဗိုင်းက စစ်သား။"
        ),
        Item(
            id: "an-curse",
            ja: "『呪術廻戦』で、虎杖悠仁たちが主に戦う相手は？",
            zh: "《咒术回战》中，虎杖悠仁等人主要对抗什么？",
            en: "What do Yuji Itadori and the others mainly fight?",
            my: "အိတဒိုရိတို့ အဓိက တိုက်သည်မှာ ဘာလဲ။",
            answerID: "curse",
            choices: [
                ("curse", "呪霊", "咒灵", "Cursed spirits", "ကျိန်စာဝိညာဉ်"),
                ("alien", "宇宙人", "外星人", "Aliens", "ဂြိုဟ်သား"),
            ],
            explainJA: "正解は呪霊。負の感情から生まれる呪い。宇宙人とは戦わない。",
            explainZH: "正确答案是咒灵。由负面情绪产生，不是外星人。",
            explainEN: "Cursed spirits, not aliens.",
            explainMY: "အဖြေမှန်က ကျိန်စာဝိညာဉ်။ ဂြိုဟ်သား မဟုတ်။"
        ),
        Item(
            id: "an-inumaki",
            ja: "『呪術廻戦』で、狗巻棘が普段よく使う言葉は？",
            zh: "《咒术回战》中，狗卷棘平时经常用什么词语交流？",
            en: "What words does Toge Inumaki usually use?",
            my: "အိနုမခိ ပြောတတ်သော စကားက ဘာလဲ။",
            answerID: "onigiri",
            choices: [
                ("number", "数字", "数字", "Numbers", "ဂဏန်း"),
                ("onigiri", "おにぎりの具", "饭团馅", "Onigiri fillings", "အိုနိဂိရိ ဖြည့်စွက်"),
            ],
            explainJA: "正解はおにぎりの具。呪言を漏らさないよう、しゃけ・ツナマヨなどで話す。数字ではない。",
            explainZH: "正确答案是饭团馅。为了不误发咒言，他用鲑鱼、tuna mayo 等词说话，不用数字。",
            explainEN: "Onigiri fillings like salmon, so his cursed speech doesn’t slip. Not numbers.",
            explainMY: "အဖြေမှန်က အိုနိဂိရိ ဖြည့်။ ဂဏန်း မဟုတ်။"
        ),
        Item(
            id: "an-deku",
            ja: "『僕のヒーローアカデミア』で、デクの本名は？",
            zh: "《我的英雄学院》中，绿谷（笨久）的真实姓名是什么？",
            en: "What is Deku’s real name?",
            my: "ဒဲကူရဲ့ အစစ်အမည်က ဘာလဲ။",
            answerID: "midoriya",
            choices: [
                ("midoriya", "緑谷出久", "绿谷出久", "Izuku Midoriya", "မိဒိုရိယ အိဇုခု"),
                ("bakugo", "爆豪勝己", "爆豪胜己", "Katsuki Bakugo", "ဘခုဂို ခဆုခိ"),
            ],
            explainJA: "正解は緑谷出久。通称デク。爆豪勝己は幼なじみでライバル。",
            explainZH: "正确答案是绿谷出久，外号笨久。爆豪胜己是青梅竹马兼对手。",
            explainEN: "Izuku Midoriya. Bakugo is his childhood rival.",
            explainMY: "အဖြေမှန်က မိဒိုရိယ အိဇုခု။"
        ),
        Item(
            id: "an-anya",
            ja: "『SPY×FAMILY』で、アーニャの特殊能力は？",
            zh: "《间谍过家家》中，阿尼亚的特殊能力是什么？",
            en: "What is Anya’s special ability?",
            my: "အန်ညာရဲ့ စွမ်းရည်က ဘာလဲ။",
            answerID: "mind",
            choices: [
                ("teleport", "瞬間移動", "瞬间移动", "Teleportation", "ချက်ချင်းရွေ့"),
                ("mind", "心を読む", "读心", "Reading minds", "စိတ်ဖတ်"),
            ],
            explainJA: "正解は心を読む。アーニャは他人の心が読める。瞬間移動はヨルの戦闘向きの動きに近いが、能力の名前ではない。",
            explainZH: "正确答案是读心。阿尼亚能读别人的心，不是瞬间移动。",
            explainEN: "She reads minds, not teleportation.",
            explainMY: "အဖြေမှန်က စိတ်ဖတ်။ ချက်ချင်းရွေ့ မဟုတ်။"
        ),
        Item(
            id: "an-loid",
            ja: "『SPY×FAMILY』で、ロイドの本当の仕事は？",
            zh: "《间谍过家家》中，劳埃德的真实工作是什么？",
            en: "What is Loid’s real job?",
            my: "လွိုက်ရဲ့ အစစ်အလုပ်က ဘာလဲ။",
            answerID: "spy",
            choices: [
                ("spy", "スパイ", "间谍", "A spy", "ထောက်လှမ်းရေး"),
                ("police", "警察官", "警察", "A police officer", "ရဲ"),
            ],
            explainJA: "正解はスパイ。黄昏（たそがれ）という暗号名の諜報員。表向きは精神科医。警察官ではない。",
            explainZH: "正确答案是间谍。代号黄昏，表面是精神科医生，不是警察。",
            explainEN: "A spy, Twilight. He poses as a psychiatrist, not a cop.",
            explainMY: "အဖြေမှန်က ထောက်လှမ်းရေး။ ရဲမဟုတ်။"
        ),
        Item(
            id: "an-hinata",
            ja: "『ハイキュー!!』で、日向翔陽がしているスポーツは？",
            zh: "《排球少年》中，日向翔阳从事什么运动？",
            en: "What sport does Shoyo Hinata play?",
            my: "ဟိနတ ကစားသော အားကစားက ဘာလဲ။",
            answerID: "volley",
            choices: [
                ("basket", "バスケットボール", "篮球", "Basketball", "ဘတ်စကက်ဘော"),
                ("volley", "バレーボール", "排球", "Volleyball", "ဗော်လီဘော"),
            ],
            explainJA: "正解はバレーボール。烏野高校のバレー部。バスケはスラムダンクのほう。",
            explainZH: "正确答案是排球。乌野高中排球部。篮球是《灌篮高手》那边。",
            explainEN: "Volleyball at Karasuno. Basketball is Slam Dunk.",
            explainMY: "အဖြေမှန်က ဗော်လီဘော။"
        ),
        Item(
            id: "an-ichigo",
            ja: "『BLEACH』で、黒崎一護が得た力は？",
            zh: "《死神》中，黑崎一护获得了什么力量？",
            en: "What power did Ichigo Kurosaki gain?",
            my: "အိချိဂို ရသော စွမ်းအားက ဘာလဲ။",
            answerID: "shinigami",
            choices: [
                ("shinigami", "死神の力", "死神之力", "Shinigami power", "ရှီနိဂမိစွမ်းအား"),
                ("ninja", "忍者の力", "忍者之力", "Ninja power", "နင်ဂျစွမ်းအား"),
            ],
            explainJA: "正解は死神の力。斬魄刀を使う死神。忍者の力はNARUTO。",
            explainZH: "正确答案是死神之力。他用斩魄刀。忍者是《火影忍者》。",
            explainEN: "Shinigami (Soul Reaper) power, not ninja.",
            explainMY: "အဖြေမှန်က ရှီနိဂမိ။ နင်ဂျ မဟုတ်။"
        ),
        Item(
            id: "an-deathnote",
            ja: "『DEATH NOTE』で、デスノートに名前を書かれた人はどうなる？",
            zh: "《死亡笔记》中，名字被写进死亡笔记的人会怎样？",
            en: "What happens to someone whose name is written in the Death Note?",
            my: "ဒက်သ်နုတ်တွင် အမည်ရေးခံရသူ ဘာဖြစ်သလဲ။",
            answerID: "die",
            choices: [
                ("sleep", "眠る", "睡觉", "They fall asleep", "အိပ်သည်"),
                ("die", "死ぬ", "死去", "They die", "သေသည်"),
            ],
            explainJA: "正解は死ぬ。名前を書くと、その人は死ぬ。眠るだけではない。",
            explainZH: "正确答案是死去。名字被写上就会死，不是只是睡着。",
            explainEN: "They die. It is not just falling asleep.",
            explainMY: "အဖြေမှန်က သေသည်။ အိပ်ရုံ မဟုတ်။"
        ),
        Item(
            id: "an-pochita",
            ja: "『チェンソーマン』で、ポチタは何の悪魔？",
            zh: "《电锯人》中，波奇塔是什么恶魔？",
            en: "What kind of devil is Pochita?",
            my: "ပိုချိတက ဘာနတ်ဆိုးလဲ။",
            answerID: "chainsaw",
            choices: [
                ("chainsaw", "チェンソーの悪魔", "电锯恶魔", "The Chainsaw Devil", "လွှနတ်ဆိုး"),
                ("gun", "銃の悪魔", "枪之恶魔", "The Gun Devil", "သေနတ်နတ်ဆိုး"),
            ],
            explainJA: "正解はチェンソーの悪魔。ポチタはデンジと一緒にいるチェンソーの悪魔。銃の悪魔は別の存在。",
            explainZH: "正确答案是电锯恶魔。枪之恶魔是另一个存在。",
            explainEN: "The Chainsaw Devil. The Gun Devil is someone else.",
            explainMY: "အဖြေမှန်က လွှနတ်ဆိုး။ သေနတ်က အခြား။"
        ),
        Item(
            id: "an-frieren",
            ja: "『葬送のフリーレン』で、フリーレンはどんな種族？",
            zh: "《葬送的芙莉莲》中，芙莉莲属于什么种族？",
            en: "What race is Frieren?",
            my: "ဖရီးရဲန်က ဘာလူမျိုးလဲ။",
            answerID: "elf",
            choices: [
                ("human", "人間", "人类", "Human", "လူ"),
                ("elf", "エルフ", "精灵", "Elf", "အဲလ်ဖ်"),
            ],
            explainJA: "正解はエルフ。千年を生きる魔法使いのエルフ。人間ではない。",
            explainZH: "正确答案是精灵。活了千年的魔法使精灵，不是人类。",
            explainEN: "An elf mage, not a human.",
            explainMY: "အဖြေမှန်က အဲလ်ဖ်။ လူမဟုတ်။"
        ),
        Item(
            id: "an-bocchi",
            ja: "『ぼっち・ざ・ろっく！』で、後藤ひとりが弾く楽器は？",
            zh: "《孤独摇滚》中，后藤一里演奏什么乐器？",
            en: "What instrument does Hitori Goto play?",
            my: "ဂိုတို ဟိတိုရိ တီးသော တူရိယာက ဘာလဲ။",
            answerID: "guitar",
            choices: [
                ("guitar", "ギター", "吉他", "Guitar", "ဂစ်တာ"),
                ("drum", "ドラム", "鼓", "Drums", "ဒရမ်"),
            ],
            explainJA: "正解はギター。結束バンドのギター。ドラムは伊地知虹夏。",
            explainZH: "正确答案是吉他。结束乐队的吉他手。鼓手是伊地知虹夏。",
            explainEN: "Guitar. Nijika plays drums.",
            explainMY: "အဖြေမှန်က ဂစ်တာ။ ဒရမ်က နိဂျိက။"
        ),
        Item(
            id: "an-oshi",
            ja: "『【推しの子】』で、アクアとルビーの関係は？",
            zh: "《我推的孩子》中，阿库亚和露比是什么关系？",
            en: "How are Aqua and Ruby related in Oshi no Ko?",
            my: "အာခွါနှင့် ရူဘီ ဘာဆက်စပ်သလဲ။",
            answerID: "twins",
            choices: [
                ("cousin", "いとこ", "表亲", "Cousins", "ဝမ်းကွဲ"),
                ("twins", "双子の兄妹", "双胞胎兄妹", "Twin brother and sister", "အမြွှာ မောင်နှမ"),
            ],
            explainJA: "正解は双子の兄妹。星野愛の子ども。いとこではない。",
            explainZH: "正确答案是双胞胎兄妹。星野爱的孩子，不是表亲。",
            explainEN: "Twin siblings, children of Ai. Not cousins.",
            explainMY: "အဖြေမှန်က အမြွှာ မောင်နှမ။ ဝမ်းကွဲ မဟုတ်။"
        ),
        Item(
            id: "an-dora-ear",
            ja: "『ドラえもん』で、ドラえもんに耳がない理由は？",
            zh: "《哆啦A梦》中，哆啦A梦为什么没有耳朵？",
            en: "Why does Doraemon have no ears?",
            my: "ဒိုရာအဲမွန် နားမရှိရခြင်း အကြောင်းက ဘာလဲ။",
            answerID: "mouse",
            choices: [
                ("born", "最初からなかった", "一开始就没有", "He never had any", "မူလက မရှိ"),
                ("mouse", "ネズミにかじられた", "被老鼠咬掉了", "A mouse chewed them off", "ကြွက် ကိုက်စား"),
            ],
            explainJA: "正解はネズミにかじられた。未来世界でネズミに耳をかじられた。最初からなかったわけではない。",
            explainZH: "正确答案是被老鼠咬掉了。在未来世界被老鼠咬了耳朵。不是一开始就没有。",
            explainEN: "A mouse chewed them off in the future. He was not born without ears.",
            explainMY: "အဖြေမှန်က ကြွက် ကိုက်စား။ မူလက မရှိသည် မဟုတ်။"
        ),
        Item(
            id: "an-maruko-name",
            ja: "『ちびまる子ちゃん』で、まる子の本当の名前は？",
            zh: "《樱桃小丸子》中，小丸子的真实姓名是什么？",
            en: "What is Maruko’s real name?",
            my: "မာရုကို ရဲ့ အစစ်အမည်က ဘာလဲ။",
            answerID: "momoko",
            choices: [
                ("momoko", "さくらももこ", "樱桃子", "Momoko Sakura", "ဆာကူရ မိုမိုကို"),
                ("maruko", "さくらまるこ", "樱丸子", "Maruko Sakura", "ဆာကူရ မာရုကို"),
            ],
            explainJA: "正解はさくらももこ。「まる子」はあだ名で、本名はさくらももこ。",
            explainZH: "正确答案是樱桃子。「小丸子」是外号，本名是さくらももこ。",
            explainEN: "Momoko Sakura. Maruko is a nickname.",
            explainMY: "အဖြေမှန်က ဆာကူရ မိုမိုကို။ မာရုကိုက အမည်ပြောင်။"
        ),
        Item(
            id: "an-psyduck",
            ja: "『ポケットモンスター』で、ゲームのポケモン図鑑で、コダックのタイプは？",
            zh: "《宝可梦》中，在宝可梦图鉴中，可达鸭是什么属性？",
            en: "In the Pokédex, what type is Psyduck?",
            my: "ပိုကေးမွန် စာရင်းတွင် ကိုဒက်ခ် အမျိုးအစားက ဘာလဲ။",
            answerID: "water",
            choices: [
                ("waterpsychic", "みず・エスパー", "水・超能", "Water / Psychic", "ရေ နှင့် စိတ်"),
                ("water", "みず", "水", "Water", "ရေ"),
            ],
            explainJA: "正解はみず。不思議な力を使えるが、タイプはみずだけ。",
            explainZH: "正确答案是水。虽然会用奇妙的力量，图鉴属性只有水。",
            explainEN: "Water only. It uses odd powers, but it is not Water/Psychic.",
            explainMY: "အဖြေမှန်က ရေ။ စိတ်အမျိုးအစား မဟုတ်။"
        ),
        Item(
            id: "an-charizard",
            ja: "『ポケットモンスター』で、普通のリザードンのタイプは？",
            zh: "《宝可梦》中，普通喷火龙是什么属性？",
            en: "What type is a regular Charizard?",
            my: "ပုံမှန် ရီဇာဒွန် အမျိုးအစားက ဘာလဲ။",
            answerID: "fireflying",
            choices: [
                ("fireflying", "ほのお・ひこう", "火・飞行", "Fire / Flying", "မီး နှင့် ပျံ"),
                ("firedragon", "ほのお・ドラゴン", "火・龙", "Fire / Dragon", "မီး နှင့် နဂါး"),
            ],
            explainJA: "正解はほのお・ひこう。ドラゴンのような姿でも、通常はほのお・ひこうタイプ。",
            explainZH: "正确答案是火・飞行。样子像龙，但普通形态不是龙属性。",
            explainEN: "Fire/Flying. It looks like a dragon, but the regular form is not Dragon-type.",
            explainMY: "အဖြေမှန်က မီး နှင့် ပျံ။ ပုံမှန်က နဂါးအမျိုး မဟုတ်။"
        ),
        Item(
            id: "an-krillin-nose",
            ja: "『ドラゴンボール』で、クリリンに鼻はある？",
            zh: "《龙珠》中，克林有鼻子吗？",
            en: "Does Krillin have a nose in Dragon Ball?",
            my: "Dragon Ball တွင် ခရီလင် နှာခေါင်းရှိသလား။",
            answerID: "no",
            choices: [
                ("yes", "ある", "有", "Yes", "ရှိသည်"),
                ("no", "ない", "没有", "No", "မရှိ"),
            ],
            explainJA: "正解はない。クリリンには鼻がなく、作中でも話題になる。",
            explainZH: "正确答案是没有。克林没有鼻子，作品里也会提到这件事。",
            explainEN: "No. Krillin has no nose, and the story jokes about it.",
            explainMY: "အဖြေမှန်က မရှိ။ ခရီလင် နှာခေါင်းမရှိ။"
        ),
        Item(
            id: "an-krillin-hair",
            ja: "『ドラゴンボール』で、クリリンの頭に髪がない理由は？",
            zh: "《龙珠》中，克林为什么是光头？",
            en: "Why is Krillin bald?",
            my: "ခရီလင် ခေါင်းတုံးဖြစ်ရခြင်း အကြောင်းက ဘာလဲ။",
            answerID: "shave",
            choices: [
                ("born", "生まれつきハゲている", "天生秃头", "He was born bald", "မွေးကတည်းက တုံး"),
                ("shave", "自分で剃っている", "自己剃的", "He shaves it himself", "ကိုယ်တိုင် ရိတ်သည်"),
            ],
            explainJA: "正解は自分で剃っている。髪は生えるが、自分で頭を剃っている。",
            explainZH: "正确答案是自己剃的。其实能长头发，是他自己剃光的。",
            explainEN: "He shaves it. His hair can grow; he is not born bald.",
            explainMY: "အဖြေမှန်က ကိုယ်တိုင် ရိတ်သည်။ မွေးကတည်းက တုံးသည် မဟုတ်။"
        ),
        Item(
            id: "an-chopper",
            ja: "『ONE PIECE』で、チョッパーが食べた悪魔の実は？",
            zh: "《海贼王》中，乔巴吃了什么恶魔果实？",
            en: "Which Devil Fruit did Chopper eat?",
            my: "ချော့ပါ စားသော အကောင်သီးက ဘာလဲ။",
            answerID: "hito",
            choices: [
                ("hito", "ヒトヒトの実", "人人果实", "Hito Hito no Mi", "လူလူသီး"),
                ("tonakai", "トナカイトナカイの実", "驯鹿驯鹿果实", "Tonakai Tonakai no Mi", "ဆတ်ဆတ်သီး"),
            ],
            explainJA: "正解はヒトヒトの実。チョッパーは元々トナカイで、ヒトヒトの実を食べた。",
            explainZH: "正确答案是人人果实。乔巴本来是驯鹿，吃了人人果实。",
            explainEN: "Hito Hito no Mi. Chopper was a reindeer first.",
            explainMY: "အဖြေမှန်က လူလူသီး။ ချော့ပါ မူလက ဆတ်။"
        ),
        Item(
            id: "an-shanks-hat",
            ja: "『ONE PIECE』で、シャンクスの麦わら帽子は、元々誰から受け継いだもの？",
            zh: "《海贼王》中，香克斯的草帽最初从谁那里继承？",
            en: "Who did Shanks originally inherit the straw hat from?",
            my: "ရှန့်ခ်စ် ကောက်ရိုးဦးထုပ်ကို မူလက ဘယ်သူထံက ရသလဲ။",
            answerID: "roger",
            choices: [
                ("rayleigh", "シルバーズ・レイリー", "西尔巴兹·雷利", "Silvers Rayleigh", "ရေးလေး"),
                ("roger", "ゴール・D・ロジャー", "哥尔·D·罗杰", "Gol D. Roger", "ရိုဂျာ"),
            ],
            explainJA: "正解はゴール・D・ロジャー。シャンクスの帽子はロジャーから受け継がれた。",
            explainZH: "正确答案是哥尔·D·罗杰。香克斯的帽子是从罗杰那里继承的。",
            explainEN: "Gol D. Roger. Rayleigh did not pass down the hat.",
            explainMY: "အဖြေမှန်က ရိုဂျာ။ ရေးလေး မဟုတ်။"
        ),
        Item(
            id: "an-sanji",
            ja: "『ONE PIECE』で、サンジが戦闘で主に使うのは？",
            zh: "《海贼王》中，山治战斗时主要用什么？",
            en: "What does Sanji mainly use in fights?",
            my: "ဆန်ဂျိ တိုက်ပွဲတွင် အဓိက ဘာသုံးသလဲ။",
            answerID: "legs",
            choices: [
                ("legs", "脚", "腿", "His legs", "ခြေထောက်"),
                ("hands", "手", "手", "His hands", "လက်"),
            ],
            explainJA: "正解は脚。料理人の大切な手を守るため、主に足技を使う。",
            explainZH: "正确答案是腿。为了保护厨师最重要的手，他主要用腿技。",
            explainEN: "His legs. He protects a cook’s hands and fights with kicks.",
            explainMY: "အဖြေမှန်က ခြေထောက်။ စားဖိုမှူး လက်ကို ကာကွယ်သည်။"
        ),
        Item(
            id: "an-rasengan",
            ja: "『NARUTO -ナルト-』で、螺旋丸を最初に開発したのは？",
            zh: "《火影忍者》中，螺旋丸最初是谁开发的？",
            en: "Who first created the Rasengan?",
            my: "ရာဆဲန်ဂန်ကို ပထမဆုံး ဖန်တီးသူက ဘယ်သူလဲ။",
            answerID: "minato",
            choices: [
                ("jiraiya", "自来也", "自来也", "Jiraiya", "ဂျီရိုင်ယာ"),
                ("minato", "波風ミナト", "波风水门", "Minato Namikaze", "မီနာတို"),
            ],
            explainJA: "正解は波風ミナト。ナルトの父が考案した忍術。自来也が最初に作った技ではない。",
            explainZH: "正确答案是波风水门。鸣人的父亲发明的忍术。不是自来也先做出来的。",
            explainEN: "Minato Namikaze, Naruto’s father. Jiraiya did not invent it.",
            explainMY: "အဖြေမှန်က မီနာတို။ နာရုတို ဖခင်။"
        ),
        Item(
            id: "an-rocklee",
            ja: "『NARUTO -ナルト-』で、ロック・リーが主に使う戦闘方法は？",
            zh: "《火影忍者》中，李洛克主要使用哪种战斗方式？",
            en: "What fighting style does Rock Lee mainly use?",
            my: "ရော့ခ် လီ အဓိက တိုက်ကွက်က ဘာလဲ။",
            answerID: "taijutsu",
            choices: [
                ("ninjutsu", "忍術", "忍术", "Ninjutsu", "နင်ဂျုဆု"),
                ("taijutsu", "体術", "体术", "Taijutsu", "တိုင်ဂျုဆု"),
            ],
            explainJA: "正解は体術。忍術が苦手なリーは体術を徹底的に鍛えている。",
            explainZH: "正确答案是体术。李洛克不擅长忍术，所以拼命练体术。",
            explainEN: "Taijutsu. Lee is weak at ninjutsu, so he trains his body.",
            explainMY: "အဖြေမှန်က တိုင်ဂျုဆု။ နင်ဂျုဆု မကျွမ်း။"
        ),
        Item(
            id: "an-shinobu",
            ja: "『鬼滅の刃』で、胡蝶しのぶは主にどうやって鬼を倒す？",
            zh: "《鬼灭之刃》中，蝴蝶忍主要怎样消灭鬼？",
            en: "How does Shinobu Kochou mainly defeat demons?",
            my: "ရှိနိုဘု အဓိက ဘယ်လို နတ်ဆိုးကို လဲသလဲ။",
            answerID: "poison",
            choices: [
                ("poison", "毒を使う", "用毒", "She uses poison", "အဆိပ်သုံး"),
                ("neck", "鬼の頸を斬る", "砍断鬼的脖子", "She cuts off their heads", "လည်ပင်းဖြတ်"),
            ],
            explainJA: "正解は毒を使う。鬼の頸を斬る腕力が足りないため、藤の花の毒で戦う。",
            explainZH: "正确答案是用毒。她砍不断鬼的脖子，所以用紫藤花的毒战斗。",
            explainEN: "Poison. She lacks the strength to cut a demon’s head, so she uses wisteria toxin.",
            explainMY: "အဖြေမှန်က အဆိပ်သုံး။ လည်ပင်းဖြတ်အား မရှိ။"
        ),
        Item(
            id: "an-rengoku",
            ja: "『鬼滅の刃』で、煉獄杏寿郎の好物は？",
            zh: "《鬼灭之刃》中，炼狱杏寿郎喜欢的食物是什么？",
            en: "What is Kyojuro Rengoku’s favorite food?",
            my: "ရဲန်ဂိုခု ကြိုက်သော အစားက ဘာလဲ။",
            answerID: "miso",
            choices: [
                ("curry", "カレーライス", "咖喱饭", "Curry rice", "ကာရီထမင်း"),
                ("miso", "さつまいもの味噌汁", "红薯味噌汤", "Sweet-potato miso soup", "ကန်စွန်း မိဆို"),
            ],
            explainJA: "正解はさつまいもの味噌汁。煉獄の大好物。カレーライスではない。",
            explainZH: "正确答案是红薯味噌汤。那是炼狱最爱，不是咖喱饭。",
            explainEN: "Sweet-potato miso soup, not curry rice.",
            explainMY: "အဖြေမှန်က ကန်စွန်း မိဆို။ ကာရီမဟုတ်။"
        ),
        Item(
            id: "an-nichirin",
            ja: "『鬼滅の刃』で、炭治郎が最初に手にした日輪刀の刃の色は？",
            zh: "《鬼灭之刃》中，炭治郎最初拿到的日轮刀刀刃是什么颜色？",
            en: "What color was Tanjiro’s first Nichirin blade?",
            my: "တန်ဂျီရို ပထမ နိချိရင် ဓားအရောင်က ဘာလဲ။",
            answerID: "black",
            choices: [
                ("black", "黒", "黑色", "Black", "အနက်"),
                ("red", "赤", "红色", "Red", "အနီ"),
            ],
            explainJA: "正解は黒。炭治郎の日輪刀は珍しい黒色に変わった。最初から赤ではない。",
            explainZH: "正确答案是黑色。炭治郎的日轮刀变成少见的黑色。不是一开始就是红的。",
            explainEN: "Black. His first blade turned a rare black, not red.",
            explainMY: "အဖြေမှန်က အနက်။ အနီ မဟုတ်။"
        ),
        Item(
            id: "an-kasugai",
            ja: "『鬼滅の刃』で、鬼殺隊が任務の連絡に使う鳥は？",
            zh: "《鬼灭之刃》中，鬼杀队使用什么鸟传递任务？",
            en: "Which bird does the Demon Slayer Corps use for messages?",
            my: "နတ်ဆိုးသတ်တပ် စာပို့ ငှက်က ဘာလဲ။",
            answerID: "crow",
            choices: [
                ("pigeon", "ハト", "鸽子", "Pigeons", "ချိုးငှက်"),
                ("crow", "カラス", "乌鸦", "Crows", "ကျီးကန်း"),
            ],
            explainJA: "正解はカラス。「鎹鴉」というカラスが伝令を担当する。ハトではない。",
            explainZH: "正确答案是乌鸦。名叫「鎹鸦」的乌鸦负责传令。不是鸽子。",
            explainEN: "Crows called kasugai-garasu, not pigeons.",
            explainMY: "အဖြေမှန်က ကျီးကန်း။ ချိုးငှက် မဟုတ်။"
        ),
        Item(
            id: "an-kid-shinichi",
            ja: "『名探偵コナン』で、怪盗キッドと工藤新一は同じ人物？",
            zh: "《名侦探柯南》中，怪盗基德和工藤新一是同一个人吗？",
            en: "Are Kaito Kid and Shinichi Kudo the same person?",
            my: "ခိုက်တို ကစ် နှင့် ရှင်အိချိ တစ်ယောက်တည်းလား။",
            answerID: "different",
            choices: [
                ("same", "同一人物", "同一个人", "The same person", "တစ်ယောက်တည်း"),
                ("different", "別人", "不是同一个人", "Different people", "သူတစ်ပါး"),
            ],
            explainJA: "正解は別人。顔がそっくりだが、別々の人物。",
            explainZH: "正确答案是不是同一个人。脸很像，但是两个人。",
            explainEN: "Different people. They look alike, but they are not the same.",
            explainMY: "အဖြေမှန်က သူတစ်ပါး။ မျက်နှာတူသော်လည်း တစ်ယောက်တည်း မဟုတ်။"
        ),
        Item(
            id: "an-ran",
            ja: "『名探偵コナン』で、毛利蘭が得意な武道は？",
            zh: "《名侦探柯南》中，毛利兰擅长哪种武术？",
            en: "What martial art is Ran Mouri best at?",
            my: "မိုရိ ရန် ကျွမ်းသော ကိုယ်ခံပညာက ဘာလဲ။",
            answerID: "karate",
            choices: [
                ("karate", "空手", "空手", "Karate", "ကရာတေး"),
                ("judo", "柔道", "柔道", "Judo", "ဂျူဒို"),
            ],
            explainJA: "正解は空手。蘭は空手部の主将。柔道が得意なのは毛利小五郎。",
            explainZH: "正确答案是空手。小兰是空手道部主将。擅长柔道的是毛利小五郎。",
            explainEN: "Karate. Ran is karate club captain. Kogoro is the judo one.",
            explainMY: "အဖြေမှန်က ကရာတေး။ ဂျူဒိုက ကိုဂိုရို။"
        ),
        Item(
            id: "an-haibara",
            ja: "『名探偵コナン』で、灰原哀は元々どこに所属していた？",
            zh: "《名侦探柯南》中，灰原哀过去属于哪个组织？",
            en: "Where did Ai Haibara originally belong?",
            my: "ဟိုင်ဘာရာ အိုင် မူလက ဘယ်အဖွဲ့လဲ။",
            answerID: "black",
            choices: [
                ("black", "黒ずくめの組織", "黑衣组织", "The Black Organization", "အနက်အဖွဲ့"),
                ("fbi", "FBI", "FBI", "The FBI", "FBI"),
            ],
            explainJA: "正解は黒ずくめの組織。元々そこの研究者だった。FBIの所属ではない。",
            explainZH: "正确答案是黑衣组织。她原来是那里的研究员，不是 FBI。",
            explainEN: "The Black Organization. She was a researcher there, not FBI.",
            explainMY: "အဖြေမှန်က အနက်အဖွဲ့။ FBI မဟုတ်။"
        ),
        Item(
            id: "an-bond",
            ja: "『SPY×FAMILY』で、犬のボンドが持つ特殊能力は？",
            zh: "《间谍过家家》中，狗狗邦德拥有什么特殊能力？",
            en: "What special ability does the dog Bond have?",
            my: "ခွေး ဘွန်း ၏ အထူးစွမ်းရည်က ဘာလဲ။",
            answerID: "future",
            choices: [
                ("mind", "人の心を読む", "读心", "Reading minds", "စိတ်ဖတ်"),
                ("future", "未来を予知する", "预知未来", "Seeing the future", "အနာဂတ်မြင်"),
            ],
            explainJA: "正解は未来を予知する。心を読めるのはアーニャ。ボンドは未来を予知できる。",
            explainZH: "正确答案是预知未来。能读心的是阿尼亚，邦德能看见未来。",
            explainEN: "He sees the future. Anya reads minds, not Bond.",
            explainMY: "အဖြေမှန်က အနာဂတ်မြင်။ စိတ်ဖတ်က အန်ညာ။"
        ),
        Item(
            id: "an-yor",
            ja: "『SPY×FAMILY』で、ヨルの表向きの仕事は？",
            zh: "《间谍过家家》中，约尔表面上的工作是什么？",
            en: "What is Yor’s public job?",
            my: "ယော အပြင်ပန်း အလုပ်က ဘာလဲ။",
            answerID: "cityhall",
            choices: [
                ("nurse", "病院の看護師", "医院护士", "A hospital nurse", "သူနာပြု"),
                ("cityhall", "市役所の職員", "市政府职员", "A city-hall clerk", "မြို့တော်ခန်းမ"),
            ],
            explainJA: "正解は市役所の職員。殺し屋の正体を隠し、市役所で働いている。",
            explainZH: "正确答案是市政府职员。她隐瞒杀手身份，在市政府上班。",
            explainEN: "A city-hall clerk. Her assassin identity is hidden. She is not a nurse.",
            explainMY: "အဖြေမှန်က မြို့တော်ခန်းမ။ သူနာပြု မဟုတ်။"
        ),
        Item(
            id: "an-panda",
            ja: "『呪術廻戦』で、パンダ先輩の正体は？",
            zh: "《咒术回战》中，熊猫前辈的真实身份是什么？",
            en: "What is Panda senpai really in Jujutsu Kaisen?",
            my: "ဂျူဂျုဆုတွင် ပန်ဒါ အစစ်အမှန်က ဘာလဲ။",
            answerID: "cursed",
            choices: [
                ("cursed", "呪骸", "咒骸", "A cursed corpse", "ကျိန်စာအလောင်း"),
                ("real", "本物のパンダ", "真正的熊猫", "A real panda", "ပန်ဒါအစစ်"),
            ],
            explainJA: "正解は呪骸。見た目はパンダだが、夜蛾学長が作った呪骸。",
            explainZH: "正确答案是咒骸。外表是熊猫，其实是夜蛾校长做的咒骸。",
            explainEN: "A cursed corpse made by Principal Yaga, not a real panda.",
            explainMY: "အဖြေမှန်က ကျိန်စာအလောင်း။ ပန်ဒါအစစ် မဟုတ်။"
        ),
        Item(
            id: "an-sukuna",
            ja: "『呪術廻戦』で、両面宿儺の指は全部で何本？",
            zh: "《咒术回战》中，两面宿傩总共有多少根手指？",
            en: "How many of Sukuna’s fingers are there in total?",
            my: "စုခုန လက်ချောင်း စုစုပေါင်း ဘယ်နှစ်ချောင်းလဲ။",
            answerID: "twenty",
            choices: [
                ("ten", "10本", "10 根", "10", "၁၀ ချောင်း"),
                ("twenty", "20本", "20 根", "20", "၂၀ ချောင်း"),
            ],
            explainJA: "正解は20本。作中で集める対象となる宿儺の指は20本。",
            explainZH: "正确答案是 20 根。作品里要收集的宿傩手指一共 20 根。",
            explainEN: "20. The story’s collection target is twenty fingers, not ten.",
            explainMY: "အဖြေမှန်က ၂၀ ချောင်း။ ၁၀ မဟုတ်။"
        ),
        Item(
            id: "an-deku-quirk",
            ja: "『僕のヒーローアカデミア』で、緑谷出久は生まれつき「個性」があった？",
            zh: "《我的英雄学院》中，绿谷出久天生就有个性（超能力）吗？",
            en: "Was Izuku Midoriya born with a Quirk?",
            my: "မိဒိုရိယ မွေးကတည်းက စွမ်းရည်ရှိသလား။",
            answerID: "no",
            choices: [
                ("no", "なかった", "没有", "No", "မရှိ"),
                ("yes", "あった", "有", "Yes", "ရှိသည်"),
            ],
            explainJA: "正解はなかった。デクは生まれつき無個性で、後から力を受け継ぐ。",
            explainZH: "正确答案是没有。出久天生无个性，力量是后来继承的。",
            explainEN: "No. Deku was Quirkless at birth and inherited power later.",
            explainMY: "အဖြေမှန်က မရှိ။ နောက်မှ အမွေရသည်။"
        ),
        Item(
            id: "an-bakugo-sweat",
            ja: "『僕のヒーローアカデミア』で、爆豪勝己の「爆破」の力は何から生まれる？",
            zh: "《我的英雄学院》中，爆豪胜己的爆破能力来源于什么？",
            en: "What creates Bakugo’s Explosion Quirk?",
            my: "ဘခုဂို ပေါက်ကွဲအား ဘယ်ကလာသလဲ။",
            answerID: "sweat",
            choices: [
                ("sweat", "手のひらの汗", "手心里的汗", "Sweat from his palms", "လက်ဖဝါး ချွေး"),
                ("breath", "口から吐く息", "嘴里呼出的气", "Breath from his mouth", "ပါးစပ် အသက်ရှူ"),
            ],
            explainJA: "正解は手のひらの汗。ニトロのような汗を出して爆発させる。口の息ではない。",
            explainZH: "正确答案是手心里的汗。他把手掌上像硝化甘油一样的汗引爆。不是呼出的气。",
            explainEN: "Nitro-like sweat from his palms, not his breath.",
            explainMY: "အဖြေမှန်က လက်ဖဝါး ချွေး။ ပါးစပ် အသက်ရှူ မဟုတ်။"
        ),
        Item(
            id: "an-tiny-giant",
            ja: "『ハイキュー!!』で、日向が憧れた初代「小さな巨人」は誰？",
            zh: "《排球少年》中，日向憧憬的最初那位“小巨人”是谁？",
            en: "Who was the first “Little Giant” Hinata looked up to?",
            my: "ဟိနတ လေးစားသော ပထမ 「လူပုကြီး」 က ဘယ်သူလဲ။",
            answerID: "karasuno",
            choices: [
                ("karasuno", "烏野高校の元選手", "乌野高中的前任选手", "A former Karasuno player", "ကရာစုနို အရင်ကစားသမား"),
                ("self", "日向翔陽本人", "日向翔阳本人", "Shoyo Hinata himself", "ဟိနတ ကိုယ်တိုင်"),
            ],
            explainJA: "正解は烏野高校の元選手。日向は、かつて烏野で活躍した選手に憧れていた。本人が初代ではない。",
            explainZH: "正确答案是乌野高中的前任选手。日向憧憬的是曾经在乌野活跃的那位选手，不是他自己。",
            explainEN: "A former Karasuno player. Hinata himself is not the original Little Giant.",
            explainMY: "အဖြေမှန်က ကရာစုနို အရင်ကစားသမား။ ဟိနတ ကိုယ်တိုင် မဟုတ်။"
        ),
        Item(
            id: "an-frieren-years",
            ja: "『葬送のフリーレン』で、フリーレンたちが魔王を倒すまでの冒険は何年間？",
            zh: "《葬送的芙莉莲》中，芙莉莲等人讨伐魔王的冒险持续了几年？",
            en: "How many years did Frieren’s party spend defeating the Demon King?",
            my: "ဖရီရန်တို့ မာရ်နတ်ဘုရင် ချေမှုန်းခရီး ဘယ်နှစ်နှစ်လဲ။",
            answerID: "ten",
            choices: [
                ("hundred", "100年間", "100 年", "100 years", "၁၀၀ နှစ်"),
                ("ten", "10年間", "10 年", "10 years", "၁၀ နှစ်"),
            ],
            explainJA: "正解は10年間。勇者ヒンメルたちとの旅は10年。100年ではない。",
            explainZH: "正确答案是 10 年。和勇者辛美尔一行的旅途是 10 年，不是 100 年。",
            explainEN: "10 years with Himmel’s party, not 100.",
            explainMY: "အဖြေမှန်က ၁၀ နှစ်။ ၁၀၀ မဟုတ်။"
        ),
        Item(
            id: "an-frieren-grape",
            ja: "『葬送のフリーレン』で、作中に本当に登場する魔法はどっち？",
            zh: "《葬送的芙莉莲》中，作品中真正出现过的是哪种魔法？",
            en: "Which spell actually appears in Frieren?",
            my: "ဖရီရန်တွင် တကယ်ပေါ်သော မှော်က ဘယ်ဟာလဲ။",
            answerID: "grape",
            choices: [
                ("grape", "甘いブドウを酸っぱくする魔法", "把甜葡萄变酸的魔法", "A spell that makes sweet grapes sour", "စပျစ်ချိုကို ချဉ်အောင်"),
                ("height", "寝るだけで背が伸びる魔法", "睡觉就能长高的魔法", "A spell that makes you taller by sleeping", "အိပ်ရုံနှင့် အရပ်တက်"),
            ],
            explainJA: "正解は甘いブドウを酸っぱくする魔法。作中に本当に登場する。寝るだけで背が伸びる魔法ではない。",
            explainZH: "正确答案是把甜葡萄变酸的魔法。作品里真的出现过。睡觉就能长高的魔法没有出现。",
            explainEN: "The sour-grape spell appears. The sleep-to-grow-taller spell does not.",
            explainMY: "အဖြေမှန်က စပျစ်ချိုကို ချဉ်အောင်။ အရပ်တက်မှော် မဟုတ်။"
        ),
        Item(
            id: "an-ryuk",
            ja: "『DEATH NOTE』で、死神リュークの大好物は？",
            zh: "《死亡笔记》中，死神琉克最喜欢吃什么？",
            en: "What is Ryuk the shinigami’s favorite food?",
            my: "ရယုခ် အကြိုက်ဆုံး အစားက ဘာလဲ။",
            answerID: "apple",
            choices: [
                ("strawberry", "イチゴ", "草莓", "Strawberries", "စတော်ဘယ်ရီ"),
                ("apple", "リンゴ", "苹果", "Apples", "ပန်းသီး"),
            ],
            explainJA: "正解はリンゴ。リュークは人間界のリンゴが大好き。イチゴではない。",
            explainZH: "正确答案是苹果。琉克最爱人间的苹果，不是草莓。",
            explainEN: "Apples from the human world, not strawberries.",
            explainMY: "အဖြေမှန်က ပန်းသီး။ စတော်ဘယ်ရီ မဟုတ်။"
        ),
        Item(
            id: "an-yubaba",
            ja: "『千と千尋の神隠し』で、湯婆婆と銭婆はどんな関係？",
            zh: "《千与千寻》中，汤婆婆和钱婆婆是什么关系？",
            en: "How are Yubaba and Zeniba related in Spirited Away?",
            my: "ယုဘာဘာ နှင့် ဇဲနိဘာ ဘာဆက်စပ်သလဲ။",
            answerID: "twins",
            choices: [
                ("twins", "双子の姉妹", "双胞胎姐妹", "Twin sisters", "အမြွှာ အစ်မ"),
                ("mother", "母と娘", "母女", "Mother and daughter", "အမေနှင့် သမီး"),
            ],
            explainJA: "正解は双子の姉妹。そっくりな二人は双子。母と娘ではない。",
            explainZH: "正确答案是双胞胎姐妹。长得很像的两人是双胞胎，不是母女。",
            explainEN: "Twin sisters, not mother and daughter.",
            explainMY: "အဖြေမှန်က အမြွှာ အစ်မ။ အမေသမီး မဟုတ်။"
        ),
        Item(
            id: "an-sasha-potato",
            ja: "『進撃の巨人』で、サシャが訓練兵時代、教官の前で食べていたものは？",
            zh: "《进击的巨人》中，莎夏在训练兵时期，当着教官的面吃什么？",
            en: "What was Sasha eating in front of the instructor as a trainee?",
            my: "ဆာရှာ လေ့ကျင့်စစ်သည်ဘဝတွင် နည်းပြရှေ့ ဘာစားနေသလဲ။",
            answerID: "potato",
            choices: [
                ("fish", "焼き魚", "烤鱼", "Grilled fish", "ငါးကင်"),
                ("potato", "蒸かした芋", "蒸土豆", "A steamed potato", "ပေါင်းအာလူး"),
            ],
            explainJA: "正解は蒸かした芋。サシャは蒸かした芋を食べていて、教官に見つかった。焼き魚ではない。",
            explainZH: "正确答案是蒸土豆。莎夏当着教官吃蒸土豆被发现了，不是烤鱼。",
            explainEN: "A steamed potato. The instructor caught her; it was not grilled fish.",
            explainMY: "အဖြေမှန်က ပေါင်းအာလူး။ ငါးကင် မဟုတ်။"
        ),
    ]
}
