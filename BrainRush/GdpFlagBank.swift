import Foundation

/// 世界の名目GDPが大きい国の旗。IMF 2025年推計。
enum GdpFlagBank {
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
                task: .gdpFlag,
                rule: rule,
                answerID: answerID,
                choices: picks.map {
                    AnswerChoice(id: $0.id, title: tr(ja: $0.ja, zh: $0.zh, en: $0.en, my: $0.my), symbol: nil, style: .neutral)
                },
                stimulus: .flag(id: id, emoji: flag)
            )
        }
    }

    private static let promptJA = "この旗は、世界のGDPが大きい国のどれ？"
    private static let promptZH = "这面旗是世界 GDP 靠前的哪个国家？"
    private static let promptEN = "Which top GDP country is this flag?"
    private static let promptMY = "ကမ္ဘာ့ GDP ကြီးသော နိုင်ငံ ဘယ်အလံလဲ။"

    private static let items: [Item] = [
        Item(
            id: "gdp-usa",
            flag: "🇺🇸",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "usa",
            choices: [
                ("usa", "アメリカ", "美国", "United States", "အမေရိကန်"),
                ("liberia", "リベリア", "利比里亚", "Liberia", "လိုက်ဘေးရီးယား"),
            ],
            explainJA: "アメリカ。IMFの2025年の名目GDPでは約30.9兆ドルで1位。アップル、グーグル、自由の女神、ハリウッド、NBAが有名。",
            explainZH: "美国。IMF 2025 年名义 GDP 约 30.9 万亿美元，第 1 名。出名的有苹果、谷歌、自由女神像、好莱坞、NBA。",
            explainEN: "United States. IMF 2025 nominal GDP about $30.9 trillion, 1st. Famous: Apple, Google, the Statue of Liberty, Hollywood, the NBA.",
            explainMY: "အမေရိကန်။ IMF 2025 GDP ခန့် $30.9 trillion၊ အဆင့် 1။ Apple၊ Google၊ လွတ်လပ်မှုရုပ်တု၊ ဟောလီးဝုဒ်၊ NBA ကျော်ကြားသည်။"
        ),
        Item(
            id: "gdp-china",
            flag: "🇨🇳",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "china",
            choices: [
                ("vietnam", "ベトナム", "越南", "Vietnam", "ဗီယက်နမ်"),
                ("china", "中国", "中国", "China", "တရုတ်"),
            ],
            explainJA: "中国。IMF 2025年では約19.6兆ドルで2位。万里の長城、パンダ、高速鉄道、アリババ、春節が有名。",
            explainZH: "中国。IMF 2025 年约 19.6 万亿美元，第 2 名。出名的有长城、熊猫、高铁、阿里巴巴、春节。",
            explainEN: "China. IMF 2025 about $19.6 trillion, 2nd. Famous: the Great Wall, pandas, high-speed rail, Alibaba, Spring Festival.",
            explainMY: "တရုတ်။ IMF 2025 ခန့် $19.6 trillion၊ အဆင့် 2။ မဟာတံတိုင်း၊ ပန်ဒါ၊ မြန်နှုန်းမြင့်ရထား၊ Alibaba၊ နွေဦးပွဲ ကျော်ကြားသည်။"
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
            explainJA: "ドイツ。IMF 2025年では約5.1兆ドルで3位。メルセデス・ベンツやBMW、ベートーヴェン、ブランデンブルク門、オクトーバーフェストが有名。",
            explainZH: "德国。IMF 2025 年约 5.1 万亿美元，第 3 名。出名的有奔驰、宝马、贝多芬、勃兰登堡门、啤酒节。",
            explainEN: "Germany. IMF 2025 about $5.1 trillion, 3rd. Famous: Mercedes-Benz and BMW, Beethoven, the Brandenburg Gate, Oktoberfest.",
            explainMY: "ဂျာမနီ။ IMF 2025 ခန့် $5.1 trillion၊ အဆင့် 3။ Mercedes-Benz၊ BMW၊ ဘီသိုဗင်၊ Brandenburg တံခါး၊ Oktoberfest ကျော်ကြားသည်။"
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
            explainJA: "日本。IMF 2025年では約4.5兆ドルで4位。トヨタ、任天堂、富士山、寿司、アニメが有名。",
            explainZH: "日本。IMF 2025 年约 4.5 万亿美元，第 4 名。出名的有丰田、任天堂、富士山、寿司、动画。",
            explainEN: "Japan. IMF 2025 about $4.45 trillion, 4th. Famous: Toyota, Nintendo, Mount Fuji, sushi, and anime.",
            explainMY: "ဂျပန်။ IMF 2025 ခန့် $4.45 trillion၊ အဆင့် 4။ Toyota၊ Nintendo၊ ဖူဂျီတောင်၊ ဆူရှီ၊ အန်နီမေ ကျော်ကြားသည်။"
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
            explainJA: "イギリス。IMF 2025年では約4.0兆ドルで5位。ビッグベン、ビートルズ、プレミアリーグ、シャーロック・ホームズが有名。",
            explainZH: "英国。IMF 2025 年约 4.0 万亿美元，第 5 名。出名的有大本钟、披头士、英超、福尔摩斯。",
            explainEN: "United Kingdom. IMF 2025 about $4.0 trillion, 5th. Famous: Big Ben, the Beatles, the Premier League, Sherlock Holmes.",
            explainMY: "ယူကေ။ IMF 2025 ခန့် $4.0 trillion၊ အဆင့် 5။ Big Ben၊ Beatles၊ Premier League၊ Sherlock Holmes ကျော်ကြားသည်။"
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
            explainJA: "インド。IMF 2025年では約3.9兆ドルで6位。タージマハル、ボリウッド、クリケット、ITのバンガロールが有名。",
            explainZH: "印度。IMF 2025 年约 3.9 万亿美元，第 6 名。出名的有泰姬陵、宝莱坞、板球、班加罗尔的 IT。",
            explainEN: "India. IMF 2025 about $3.91 trillion, 6th. Famous: the Taj Mahal, Bollywood, cricket, and IT in Bengaluru.",
            explainMY: "အိန္ဒိယ။ IMF 2025 ခန့် $3.91 trillion၊ အဆင့် 6။ တာ့ဂျ်မဟာလ်၊ ဘောလီးဝုဒ်၊ ခရစ်ကတ်၊ ဘန်ဂလို၏ IT ကျော်ကြားသည်။"
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
            explainJA: "フランス。IMF 2025年では約3.4兆ドルで7位。エッフェル塔、ルーブル美術館、ファッション、ワイン、サッカーが有名。",
            explainZH: "法国。IMF 2025 年约 3.4 万亿美元，第 7 名。出名的有埃菲尔铁塔、卢浮宫、时装、葡萄酒、足球。",
            explainEN: "France. IMF 2025 about $3.38 trillion, 7th. Famous: the Eiffel Tower, the Louvre, fashion, wine, and football.",
            explainMY: "ပြင်သစ်။ IMF 2025 ခန့် $3.38 trillion၊ အဆင့် 7။ အိုင်ဖယ်တာဝါ၊ လူဗာ၊ ဖက်ရှင်၊ စပျစ်ရည်၊ ဘောလုံး ကျော်ကြားသည်။"
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
            explainJA: "ロシア。IMF 2025年では約2.6兆ドルで8位。バレエ、マトリョーシカ、エルミタージュ美術館、宇宙飛行士ガガーリンが有名。",
            explainZH: "俄罗斯。IMF 2025 年约 2.6 万亿美元，第 8 名。出名的有芭蕾、套娃、艾尔米塔什博物馆、宇航员加加林。",
            explainEN: "Russia. IMF 2025 about $2.57 trillion, 8th. Famous: ballet, matryoshka dolls, the Hermitage, and cosmonaut Gagarin.",
            explainMY: "ရုရှား။ IMF 2025 ခန့် $2.57 trillion၊ အဆင့် 8။ ဘဲလေး၊ matryoshka၊ Hermitage ပြတိုက်၊ အာကာသယာဉ်မှူး Gagarin ကျော်ကြားသည်။"
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
            explainJA: "イタリア。IMF 2025年では約2.6兆ドルで9位。コロッセオ、ピザ、フェラーリ、レオナルド・ダ・ヴィンチが有名。",
            explainZH: "意大利。IMF 2025 年约 2.6 万亿美元，第 9 名。出名的有斗兽场、披萨、法拉利、达·芬奇。",
            explainEN: "Italy. IMF 2025 about $2.55 trillion, 9th. Famous: the Colosseum, pizza, Ferrari, and Leonardo da Vinci.",
            explainMY: "အီတလီ။ IMF 2025 ခန့် $2.55 trillion၊ အဆင့် 9။ ကိုလိုဆီယမ်၊ ပီဇာ၊ Ferrari၊ လီယိုနာဒို ဒါဗင်ချီ ကျော်ကြားသည်။"
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
            explainJA: "カナダ。IMF 2025年では約2.3兆ドルで10位。メイプルシロップ、ナイアガラの滝、アイスホッケー、バンフ国立公園が有名。",
            explainZH: "加拿大。IMF 2025 年约 2.3 万亿美元，第 10 名。出名的有枫糖浆、尼亚加拉瀑布、冰球、班夫国家公园。",
            explainEN: "Canada. IMF 2025 about $2.32 trillion, 10th. Famous: maple syrup, Niagara Falls, ice hockey, and Banff National Park.",
            explainMY: "ကနေဒါ။ IMF 2025 ခန့် $2.32 trillion၊ အဆင့် 10။ မေပယ်ရည်၊ နိုင်အာဂရာရေတံခွန်၊ ရေခဲဟော်ကီ၊ Banff ဥယျာဉ် ကျော်ကြားသည်။"
        ),
    ]
}
