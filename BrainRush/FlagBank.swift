import Foundation

/// 国旗を見て、どの国かを選ぶ。解説は JASSO 2024年5月1日（かっこ内は前年）。
enum FlagBank {
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
            ja: "もう一度旗を見て、チェックの付いた正解と比べてみよう。",
            zh: "再看一遍旗帜，对照带勾的正确答案。",
            en: "Look at the flag again and compare it with the checked answer.",
            my: "အလံကို ပြန်ကြည့်ပြီး အမှန်ခြစ်ထားသောအဖြေနှင့် နှိုင်းယှဉ်ပါ။"
        )
    }

    struct Item {
        let id: String
        let flag: String
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
                task: .flag,
                rule: rule,
                answerID: answerID,
                choices: picks.map {
                    AnswerChoice(id: $0.id, title: tr(ja: $0.ja, zh: $0.zh, en: $0.en, my: $0.my), symbol: nil, style: .neutral)
                },
                stimulus: .flag(id: id, emoji: flag)
            )
        }
    }

    private static let promptJA = "この旗はどの国？"
    private static let promptZH = "这面国旗是哪个国家？"
    private static let promptEN = "Which country is this flag?"
    private static let promptMY = "ဒီအလံက ဘယ်နိုင်ငံလဲ။"

    private static let items: [Item] = [
        Item(
            id: "stu-china",
            flag: "🇨🇳",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "china",
            choices: [
                ("china", "中国", "中国", "China", "တရုတ်"),
                ("taiwan", "台湾", "台湾", "Taiwan", "ထိုင်ဝမ်"),
            ],
            explainJA: "中国。JASSO（2024年5月1日）では在日留学生12万3485人で1位。前の年（2023年5月1日）は11万5493人で、1年で7992人増えた。万里の長城、パンダ、春節が有名。",
            explainZH: "中国。JASSO（2024年5月1日）在日留学生 123,485 人，第 1 名。前一年（2023年5月1日）有 115,493 人，一年增加 7,992 人。出名的有长城、熊猫、春节。",
            explainEN: "China. JASSO (1 May 2024): 123,485 students in Japan, 1st. A year earlier (1 May 2023): 115,493, up 7,992. Famous: the Great Wall, pandas, Spring Festival.",
            explainMY: "တရုတ်။ JASSO (2024 မေ 1) ဂျပန်၌ 123,485၊ အဆင့် 1။ အရင်နှစ် (2023 မေ 1) 115,493၊ တစ်နှစ်တွင် 7,992 တိုး။ မဟာတံတိုင်း၊ ပန်ဒါ၊ နွေဦးပွဲ ကျော်ကြားသည်။"
        ),
        Item(
            id: "stu-nepal",
            flag: "🇳🇵",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "nepal",
            choices: [
                ("india", "インド", "印度", "India", "အိန္ဒိယ"),
                ("nepal", "ネパール", "尼泊尔", "Nepal", "နီပေါ"),
            ],
            explainJA: "ネパール。JASSO（2024年5月1日）では在日留学生6万4816人で2位。前の年（2023年5月1日）は3万7878人で、1年で2万6938人増えた。エベレスト、カトマンズ、ダールバートが有名。",
            explainZH: "尼泊尔。JASSO（2024年5月1日）在日留学生 64,816 人，第 2 名。前一年（2023年5月1日）有 37,878 人，一年增加 26,938 人。出名的有珠穆朗玛峰、加德满都、达尔巴特。",
            explainEN: "Nepal. JASSO (1 May 2024): 64,816 students in Japan, 2nd. A year earlier (1 May 2023): 37,878, up 26,938. Famous: Everest, Kathmandu, dal bhat.",
            explainMY: "နီပေါ။ JASSO (2024 မေ 1) ဂျပန်၌ 64,816၊ အဆင့် 2။ အရင်နှစ် (2023 မေ 1) 37,878၊ တစ်နှစ်တွင် 26,938 တိုး။ ဧဝရတ်တောင်၊ ကတ်မန္ဒူ၊ dal bhat ကျော်ကြားသည်။"
        ),
        Item(
            id: "stu-vietnam",
            flag: "🇻🇳",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "vietnam",
            choices: [
                ("vietnam", "ベトナム", "越南", "Vietnam", "ဗီယက်နမ်"),
                ("china", "中国", "中国", "China", "တရုတ်"),
            ],
            explainJA: "ベトナム。JASSO（2024年5月1日）では在日留学生4万323人で3位。前の年（2023年5月1日）は3万6339人で、1年で3984人増えた。フォー、ハロン湾、アオザイが有名。",
            explainZH: "越南。JASSO（2024年5月1日）在日留学生 40,323 人，第 3 名。前一年（2023年5月1日）有 36,339 人，一年增加 3,984 人。出名的有河粉、下龙湾、奥黛。",
            explainEN: "Vietnam. JASSO (1 May 2024): 40,323 students in Japan, 3rd. A year earlier (1 May 2023): 36,339, up 3,984. Famous: pho, Ha Long Bay, the ao dai.",
            explainMY: "ဗီယက်နမ်။ JASSO (2024 မေ 1) ဂျပန်၌ 40,323၊ အဆင့် 3။ အရင်နှစ် (2023 မေ 1) 36,339၊ တစ်နှစ်တွင် 3,984 တိုး။ ဖိုခေါက်ဆွဲ၊ ဟာလောင်ပင်လယ်အော်၊ အောဇိုင်း ကျော်ကြားသည်။"
        ),
        Item(
            id: "stu-myanmar",
            flag: "🇲🇲",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "myanmar",
            choices: [
                ("thailand", "タイ", "泰国", "Thailand", "ထိုင်း"),
                ("myanmar", "ミャンマー", "缅甸", "Myanmar", "မြန်မာ"),
            ],
            explainJA: "ミャンマー。JASSO（2024年5月1日）では在日留学生1万6596人で4位。前の年（2023年5月1日）は7773人で、1年で8823人増えた（約2倍）。シュエダゴン・パゴダ、インレー湖が有名。",
            explainZH: "缅甸。JASSO（2024年5月1日）在日留学生 16,596 人，第 4 名。前一年（2023年5月1日）有 7,773 人，一年增加 8,823 人（约两倍）。出名的有大金塔、茵莱湖。",
            explainEN: "Myanmar. JASSO (1 May 2024): 16,596 students in Japan, 4th. A year earlier (1 May 2023): 7,773, up 8,823 (about double). Famous: Shwedagon Pagoda, Inle Lake.",
            explainMY: "မြန်မာ။ JASSO (2024 မေ 1) ဂျပန်၌ 16,596၊ အဆင့် 4။ အရင်နှစ် (2023 မေ 1) 7,773၊ တစ်နှစ်တွင် 8,823 တိုး (နှစ်ဆခန့်)။ ရွှေတိဂုံစေတီ၊ အင်းလေးကန် ကျော်ကြားသည်။"
        ),
        Item(
            id: "stu-korea",
            flag: "🇰🇷",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "korea",
            choices: [
                ("korea", "韓国", "韩国", "South Korea", "တောင်ကိုရီးယား"),
                ("japan", "日本", "日本", "Japan", "ဂျပန်"),
            ],
            explainJA: "韓国。JASSO（2024年5月1日）では在日留学生1万4579人で5位。前の年（2023年5月1日）は1万4946人で、1年で367人減った。K-POP、サムスン、キムチが有名。",
            explainZH: "韩国。JASSO（2024年5月1日）在日留学生 14,579 人，第 5 名。前一年（2023年5月1日）有 14,946 人，一年减少 367 人。出名的有 K-POP、三星、泡菜。",
            explainEN: "South Korea. JASSO (1 May 2024): 14,579 students in Japan, 5th. A year earlier (1 May 2023): 14,946, down 367. Famous: K-pop, Samsung, kimchi.",
            explainMY: "တောင်ကိုရီးယား။ JASSO (2024 မေ 1) ဂျပန်၌ 14,579၊ အဆင့် 5။ အရင်နှစ် (2023 မေ 1) 14,946၊ တစ်နှစ်တွင် 367 လျော့။ K-POP၊ Samsung၊ ကင်မ်ချီ ကျော်ကြားသည်။"
        ),
        Item(
            id: "stu-srilanka",
            flag: "🇱🇰",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "srilanka",
            choices: [
                ("india", "インド", "印度", "India", "အိန္ဒိယ"),
                ("srilanka", "スリランカ", "斯里兰卡", "Sri Lanka", "သီရိလင်္ကာ"),
            ],
            explainJA: "スリランカ。JASSO（2024年5月1日）では在日留学生1万2269人で6位。前の年（2023年5月1日）は6819人で、1年で5450人増えた。セイロンティー、コロンボ、シーギリヤロックが有名。",
            explainZH: "斯里兰卡。JASSO（2024年5月1日）在日留学生 12,269 人，第 6 名。前一年（2023年5月1日）有 6,819 人，一年增加 5,450 人。出名的有锡兰红茶、科伦坡、狮子岩。",
            explainEN: "Sri Lanka. JASSO (1 May 2024): 12,269 students in Japan, 6th. A year earlier (1 May 2023): 6,819, up 5,450. Famous: Ceylon tea, Colombo, Sigiriya.",
            explainMY: "သီရိလင်္ကာ။ JASSO (2024 မေ 1) ဂျပန်၌ 12,269၊ အဆင့် 6။ အရင်နှစ် (2023 မေ 1) 6,819၊ တစ်နှစ်တွင် 5,450 တိုး။ စီလုံလက်ဖက်၊ ကိုလံဘို၊ Sigiriya ကျော်ကြားသည်။"
        ),
        Item(
            id: "stu-taiwan",
            flag: "🇹🇼",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "taiwan",
            choices: [
                ("taiwan", "台湾", "台湾", "Taiwan", "ထိုင်ဝမ်"),
                ("china", "中国", "中国", "China", "တရုတ်"),
            ],
            explainJA: "台湾。JASSO（2024年5月1日）では在日留学生7655人で7位。前の年（2023年5月1日）は6998人で、1年で657人増えた。夜市、タピオカティー、台北101が有名。",
            explainZH: "台湾。JASSO（2024年5月1日）在日留学生 7,655 人，第 7 名。前一年（2023年5月1日）有 6,998 人，一年增加 657 人。出名的有夜市、珍珠奶茶、台北101。",
            explainEN: "Taiwan. JASSO (1 May 2024): 7,655 students in Japan, 7th. A year earlier (1 May 2023): 6,998, up 657. Famous: night markets, bubble tea, Taipei 101.",
            explainMY: "ထိုင်ဝမ်။ JASSO (2024 မေ 1) ဂျပန်၌ 7,655၊ အဆင့် 7။ အရင်နှစ် (2023 မေ 1) 6,998၊ တစ်နှစ်တွင် 657 တိုး။ ညဈေး၊ ပုလဲနို့လက်ဖက်၊ ထိုင်ပေ 101 ကျော်ကြားသည်။"
        ),
        Item(
            id: "stu-bangladesh",
            flag: "🇧🇩",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "bangladesh",
            choices: [
                ("pakistan", "パキスタン", "巴基斯坦", "Pakistan", "ပါကစ္စတန်"),
                ("bangladesh", "バングラデシュ", "孟加拉国", "Bangladesh", "ဘင်္ဂလားဒေ့ရှ်"),
            ],
            explainJA: "バングラデシュ。JASSO（2024年5月1日）では在日留学生7597人で8位。前の年（2023年5月1日）は5326人で、1年で2271人増えた。ダッカ、ジャムダニ織が有名。",
            explainZH: "孟加拉国。JASSO（2024年5月1日）在日留学生 7,597 人，第 8 名。前一年（2023年5月1日）有 5,326 人，一年增加 2,271 人。出名的有达卡、贾姆达尼织品。",
            explainEN: "Bangladesh. JASSO (1 May 2024): 7,597 students in Japan, 8th. A year earlier (1 May 2023): 5,326, up 2,271. Famous: Dhaka, jamdani weaving.",
            explainMY: "ဘင်္ဂလားဒေ့ရှ်။ JASSO (2024 မေ 1) ဂျပန်၌ 7,597၊ အဆင့် 8။ အရင်နှစ် (2023 မေ 1) 5,326၊ တစ်နှစ်တွင် 2,271 တိုး။ ဒါကာ၊ jamdani ရက်ကန်း ကျော်ကြားသည်။"
        ),
        Item(
            id: "stu-indonesia",
            flag: "🇮🇩",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "indonesia",
            choices: [
                ("indonesia", "インドネシア", "印度尼西亚", "Indonesia", "အင်ဒိုနီးရှား"),
                ("monaco", "モナコ", "摩纳哥", "Monaco", "မိုနာကို"),
            ],
            explainJA: "インドネシア。JASSO（2024年5月1日）では在日留学生6778人で9位。前の年（2023年5月1日）は6552人で、1年で226人増えた。バリ島、ボロブドゥール、バティックが有名。",
            explainZH: "印度尼西亚。JASSO（2024年5月1日）在日留学生 6,778 人，第 9 名。前一年（2023年5月1日）有 6,552 人，一年增加 226 人。出名的有巴厘岛、婆罗浮屠、蜡染。",
            explainEN: "Indonesia. JASSO (1 May 2024): 6,778 students in Japan, 9th. A year earlier (1 May 2023): 6,552, up 226. Famous: Bali, Borobudur, batik.",
            explainMY: "အင်ဒိုနီးရှား။ JASSO (2024 မေ 1) ဂျပန်၌ 6,778၊ အဆင့် 9။ အရင်နှစ် (2023 မေ 1) 6,552၊ တစ်နှစ်တွင် 226 တိုး။ ဘာလီ၊ ဗိုရိုဘူဒူ၊ ဘာတစ် ကျော်ကြားသည်။"
        ),
        Item(
            id: "stu-mongolia",
            flag: "🇲🇳",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "mongolia",
            choices: [
                ("kazakhstan", "カザフスタン", "哈萨克斯坦", "Kazakhstan", "ကာဇက်စတန်"),
                ("mongolia", "モンゴル", "蒙古", "Mongolia", "မွန်ဂိုလီးယား"),
            ],
            explainJA: "モンゴル。JASSO（2024年5月1日）では在日留学生4085人で10位。前の年（2023年5月1日）は3677人で、1年で408人増えた。チンギス・ハン、草原、ナーダムが有名。",
            explainZH: "蒙古。JASSO（2024年5月1日）在日留学生 4,085 人，第 10 名。前一年（2023年5月1日）有 3,677 人，一年增加 408 人。出名的有成吉思汗、草原、那达慕。",
            explainEN: "Mongolia. JASSO (1 May 2024): 4,085 students in Japan, 10th. A year earlier (1 May 2023): 3,677, up 408. Famous: Genghis Khan, the steppe, Naadam.",
            explainMY: "မွန်ဂိုလီးယား။ JASSO (2024 မေ 1) ဂျပန်၌ 4,085၊ အဆင့် 10။ အရင်နှစ် (2023 မေ 1) 3,677၊ တစ်နှစ်တွင် 408 တိုး။ ချင်ဂစ္စခန်၊ လွင်ပြင်၊ နာဒမ်ပွဲ ကျော်ကြားသည်။"
        ),
        Item(
            id: "gdp-usa",
            flag: "🇺🇸",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "usa",
            choices: [
                ("usa", "アメリカ", "美国", "United States", "အမေရိကန်"),
                ("liberia", "リベリア", "利比里亚", "Liberia", "လိုက်ဘေးရီးယား"),
            ],
            explainJA: "アメリカ。JASSO（2024年5月1日）では在日留学生3918人で11位。前の年（2023年5月1日）は4076人で、1年で158人減った。自由の女神、ハリウッド、NBAが有名。",
            explainZH: "美国。JASSO（2024年5月1日）在日留学生 3,918 人，第 11 名。前一年（2023年5月1日）有 4,076 人，一年减少 158 人。出名的有自由女神像、好莱坞、NBA。",
            explainEN: "United States. JASSO (1 May 2024): 3,918 students in Japan, 11th. A year earlier (1 May 2023): 4,076, down 158. Famous: the Statue of Liberty, Hollywood, the NBA.",
            explainMY: "အမေရိကန်။ JASSO (2024 မေ 1) ဂျပန်၌ 3,918၊ အဆင့် 11။ အရင်နှစ် (2023 မေ 1) 4,076၊ တစ်နှစ်တွင် 158 လျော့။ လွတ်လပ်မှုရုပ်တု၊ ဟောလီးဝုဒ်၊ NBA ကျော်ကြားသည်။"
        ),

        Item(
            id: "gdp-germany",
            flag: "🇩🇪",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "germany",
            choices: [
                ("germany", "ドイツ", "德国", "Germany", "ဂျာမနီ"),
                ("belgium", "ベルギー", "比利时", "Belgium", "ဘယ်လ်ဂျီယမ်"),
            ],
            explainJA: "ドイツ。JASSO（2024年5月1日）では在日留学生1215人で20位。前の年（2023年5月1日）は1282人で、1年で67人減った。メルセデス・ベンツ、ベートーヴェン、オクトーバーフェストが有名。",
            explainZH: "德国。JASSO（2024年5月1日）在日留学生 1,215 人，第 20 名。前一年（2023年5月1日）有 1,282 人，一年减少 67 人。出名的有奔驰、贝多芬、啤酒节。",
            explainEN: "Germany. JASSO (1 May 2024): 1,215 students in Japan, 20th. A year earlier (1 May 2023): 1,282, down 67. Famous: Mercedes-Benz, Beethoven, Oktoberfest.",
            explainMY: "ဂျာမနီ။ JASSO (2024 မေ 1) ဂျပန်၌ 1,215၊ အဆင့် 20။ အရင်နှစ် (2023 မေ 1) 1,282၊ တစ်နှစ်တွင် 67 လျော့။ Mercedes-Benz၊ ဘီသိုဗင်၊ Oktoberfest ကျော်ကြားသည်။"
        ),
        Item(
            id: "gdp-japan",
            flag: "🇯🇵",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "japan",
            choices: [
                ("bangladesh", "バングラデシュ", "孟加拉国", "Bangladesh", "ဘင်္ဂလားဒေ့ရှ်"),
                ("japan", "日本", "日本", "Japan", "ဂျပန်"),
            ],
            explainJA: "日本。JASSOは外国から来た留学生を数えるので、日本はランキングに入らない（受け入れる側）。2024年5月1日の外国人留学生は全体で33万6708人。前の年は27万9274人で、1年で5万7434人増えた。富士山、寿司、アニメが有名。",
            explainZH: "日本。JASSO 统计的是从外国来的留学生，日本是接收方，不进这个排名。2024年5月1日在日外国留学生一共 336,708 人。前一年有 279,274 人，一年增加 57,434 人。出名的有富士山、寿司、动画。",
            explainEN: "Japan. JASSO counts students from other countries, so Japan is the host, not on the origin ranking. Total international students on 1 May 2024: 336,708. A year earlier: 279,274, up 57,434. Famous: Mount Fuji, sushi, anime.",
            explainMY: "ဂျပန်။ JASSO သည် နိုင်ငံခြားမှ ကျောင်းသားများကို ရေတွက်သည်။ ဂျပန်သည် လက်ခံသည့်နိုင်ငံဖြစ်၍ အဆင့်မပါ။ 2024 မေ 1 တွင် စုစုပေါင်း 336,708။ အရင်နှစ် 279,274၊ တစ်နှစ်တွင် 57,434 တိုး။ ဖူဂျီတောင်၊ ဆူရှီ၊ အန်နီမေ ကျော်ကြားသည်။"
        ),
        Item(
            id: "gdp-uk",
            flag: "🇬🇧",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "uk",
            choices: [
                ("uk", "イギリス", "英国", "United Kingdom", "ယူကေ"),
                ("australia", "オーストラリア", "澳大利亚", "Australia", "ဩစတြေးလျ"),
            ],
            explainJA: "イギリス。JASSO（2024年5月1日）では在日留学生953人で21位。前の年（2023年5月1日）は1117人で、1年で164人減った。ビッグベン、ビートルズ、プレミアリーグが有名。",
            explainZH: "英国。JASSO（2024年5月1日）在日留学生 953 人，第 21 名。前一年（2023年5月1日）有 1,117 人，一年减少 164 人。出名的有大本钟、披头士、英超。",
            explainEN: "United Kingdom. JASSO (1 May 2024): 953 students in Japan, 21st. A year earlier (1 May 2023): 1,117, down 164. Famous: Big Ben, the Beatles, the Premier League.",
            explainMY: "ယူကေ။ JASSO (2024 မေ 1) ဂျပန်၌ 953၊ အဆင့် 21။ အရင်နှစ် (2023 မေ 1) 1,117၊ တစ်နှစ်တွင် 164 လျော့။ Big Ben၊ Beatles၊ Premier League ကျော်ကြားသည်။"
        ),
        Item(
            id: "gdp-india",
            flag: "🇮🇳",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "india",
            choices: [
                ("ireland", "アイルランド", "爱尔兰", "Ireland", "အိုင်ယာလန်"),
                ("india", "インド", "印度", "India", "အိန္ဒိယ"),
            ],
            explainJA: "インド。JASSO（2024年5月1日）では在日留学生1685人で17位。前の年（2023年5月1日）は1612人で、1年で73人増えた。タージマハル、ボリウッド、クリケットが有名。",
            explainZH: "印度。JASSO（2024年5月1日）在日留学生 1,685 人，第 17 名。前一年（2023年5月1日）有 1,612 人，一年增加 73 人。出名的有泰姬陵、宝莱坞、板球。",
            explainEN: "India. JASSO (1 May 2024): 1,685 students in Japan, 17th. A year earlier (1 May 2023): 1,612, up 73. Famous: the Taj Mahal, Bollywood, cricket.",
            explainMY: "အိန္ဒိယ။ JASSO (2024 မေ 1) ဂျပန်၌ 1,685၊ အဆင့် 17။ အရင်နှစ် (2023 မေ 1) 1,612၊ တစ်နှစ်တွင် 73 တိုး။ တာ့ဂျ်မဟာလ်၊ ဘောလီးဝုဒ်၊ ခရစ်ကတ် ကျော်ကြားသည်။"
        ),
        Item(
            id: "gdp-france",
            flag: "🇫🇷",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "france",
            choices: [
                ("france", "フランス", "法国", "France", "ပြင်သစ်"),
                ("netherlands", "オランダ", "荷兰", "Netherlands", "နယ်သာလန်"),
            ],
            explainJA: "フランス。JASSO（2024年5月1日）では在日留学生2012人で16位。前の年（2023年5月1日）は2113人で、1年で101人減った。エッフェル塔、ルーブル、ワインが有名。",
            explainZH: "法国。JASSO（2024年5月1日）在日留学生 2,012 人，第 16 名。前一年（2023年5月1日）有 2,113 人，一年减少 101 人。出名的有埃菲尔铁塔、卢浮宫、葡萄酒。",
            explainEN: "France. JASSO (1 May 2024): 2,012 students in Japan, 16th. A year earlier (1 May 2023): 2,113, down 101. Famous: the Eiffel Tower, the Louvre, wine.",
            explainMY: "ပြင်သစ်။ JASSO (2024 မေ 1) ဂျပန်၌ 2,012၊ အဆင့် 16။ အရင်နှစ် (2023 မေ 1) 2,113၊ တစ်နှစ်တွင် 101 လျော့။ အိုင်ဖယ်တာဝါ၊ လူဗာ၊ စပျစ်ရည် ကျော်ကြားသည်။"
        ),
        Item(
            id: "gdp-russia",
            flag: "🇷🇺",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "russia",
            choices: [
                ("slovakia", "スロバキア", "斯洛伐克", "Slovakia", "ဆလိုဗက်ကီးယား"),
                ("russia", "ロシア", "俄罗斯", "Russia", "ရုရှား"),
            ],
            explainJA: "ロシア。JASSO（2024年5月1日）では在日留学生1502人で18位。前の年（2023年5月1日）は1575人で、1年で73人減った。バレエ、マトリョーシカ、ガガーリンが有名。",
            explainZH: "俄罗斯。JASSO（2024年5月1日）在日留学生 1,502 人，第 18 名。前一年（2023年5月1日）有 1,575 人，一年减少 73 人。出名的有芭蕾、套娃、加加林。",
            explainEN: "Russia. JASSO (1 May 2024): 1,502 students in Japan, 18th. A year earlier (1 May 2023): 1,575, down 73. Famous: ballet, matryoshka dolls, Gagarin.",
            explainMY: "ရုရှား။ JASSO (2024 မေ 1) ဂျပန်၌ 1,502၊ အဆင့် 18။ အရင်နှစ် (2023 မေ 1) 1,575၊ တစ်နှစ်တွင် 73 လျော့။ ဘဲလေး၊ matryoshka၊ Gagarin ကျော်ကြားသည်။"
        ),
        Item(
            id: "gdp-italy",
            flag: "🇮🇹",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "italy",
            choices: [
                ("italy", "イタリア", "意大利", "Italy", "အီတလီ"),
                ("mexico", "メキシコ", "墨西哥", "Mexico", "မက္ကဆီကို"),
            ],
            explainJA: "イタリア。JASSO（2024年5月1日）では在日留学生820人で23位。前の年（2023年5月1日）は869人で、1年で49人減った。コロッセオ、ピザ、フェラーリが有名。",
            explainZH: "意大利。JASSO（2024年5月1日）在日留学生 820 人，第 23 名。前一年（2023年5月1日）有 869 人，一年减少 49 人。出名的有斗兽场、披萨、法拉利。",
            explainEN: "Italy. JASSO (1 May 2024): 820 students in Japan, 23rd. A year earlier (1 May 2023): 869, down 49. Famous: the Colosseum, pizza, Ferrari.",
            explainMY: "အီတလီ။ JASSO (2024 မေ 1) ဂျပန်၌ 820၊ အဆင့် 23။ အရင်နှစ် (2023 မေ 1) 869၊ တစ်နှစ်တွင် 49 လျော့။ ကိုလိုဆီယမ်၊ ပီဇာ၊ Ferrari ကျော်ကြားသည်။"
        ),
        Item(
            id: "gdp-canada",
            flag: "🇨🇦",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "canada",
            choices: [
                ("peru", "ペルー", "秘鲁", "Peru", "ပီရူး"),
                ("canada", "カナダ", "加拿大", "Canada", "ကနေဒါ"),
            ],
            explainJA: "カナダ。JASSO（2024年5月1日）では在日留学生598人で25位。前の年（2023年5月1日）は591人で、1年で7人増えた。メイプルシロップ、ナイアガラの滝、アイスホッケーが有名。",
            explainZH: "加拿大。JASSO（2024年5月1日）在日留学生 598 人，第 25 名。前一年（2023年5月1日）有 591 人，一年增加 7 人。出名的有枫糖浆、尼亚加拉瀑布、冰球。",
            explainEN: "Canada. JASSO (1 May 2024): 598 students in Japan, 25th. A year earlier (1 May 2023): 591, up 7. Famous: maple syrup, Niagara Falls, ice hockey.",
            explainMY: "ကနေဒါ။ JASSO (2024 မေ 1) ဂျပန်၌ 598၊ အဆင့် 25။ အရင်နှစ် (2023 မေ 1) 591၊ တစ်နှစ်တွင် 7 တိုး။ မေပယ်ရည်၊ နိုင်အာဂရာရေတံခွန်၊ ရေခဲဟော်ကီ ကျော်ကြားသည်။"
        ),
    ]
}
