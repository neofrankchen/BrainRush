import Foundation

/// 国旗を見て、どの国または地域かを選ぶ。
/// 在日留学生の多い国（JASSO 2025年5月1日 上位10）と、よく知られる旗・間違えやすい旗。
/// 選択肢は色や形が似ている相手。解説は旗の意味。
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

    private static let promptJA = "この旗は、どの国または地域？"
    private static let promptZH = "这是哪个国家或地区的旗帜？"
    private static let promptEN = "Which country or region is this flag?"
    private static let promptMY = "ဒီအလံက ဘယ်နိုင်ငံ သို့မဟုတ် ဒေသလဲ။"

    private static let items: [Item] = [
        Item(
            id: "flag-china",
            flag: "🇨🇳",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "china",
            choices: [
                ("china", "中国", "中国", "China", "တရုတ်"),
                ("vietnam", "ベトナム", "越南", "Vietnam", "ဗီယက်နမ်"),
            ],
            explainJA: "中国。赤い旗に大きい黄色い星が1つ、小さい星が4つ。大きい星は国をまとめる力、4つの星は人々。ベトナムも赤地に黄色い星だが、星は1つだけ。",
            explainZH: "中国。红旗上有 1 颗大黄星和 4 颗小黄星。大星代表领导，小星代表人。越南也是红底黄星，但只有 1 颗。",
            explainEN: "China. A red field with one large yellow star and four small ones — the large star for leadership, the small ones for the people. Vietnam is also red with a yellow star, but only one.",
            explainMY: "တရုတ်။ အနီပေါ် ကြယ်ဝါ အကြီး ၁၊ အသေး ၄။ ဗီယက်နမ်က ကြယ် ၁ ခုသာ။"
        ),
        Item(
            id: "flag-nepal",
            flag: "🇳🇵",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "nepal",
            choices: [
                ("india", "インド", "印度", "India", "အိန္ဒိယ"),
                ("nepal", "ネパール", "尼泊尔", "Nepal", "နီပေါ"),
            ],
            explainJA: "ネパール。世界でほぼ唯一の、三角形が2つ重なった旗。深紅は勇気、青い縁は平和、太陽と月は国がいつまでも続く願い。インドの旗は長方形の横三色。",
            explainZH: "尼泊尔。世界上几乎唯一由两个三角形叠成的国旗。深红代表勇气，蓝边代表和平，太阳和月亮表示国家长久。印度旗是长方形的横三色。",
            explainEN: "Nepal. Almost the only non-rectangular national flag: two pennants. Crimson for courage, a blue border for peace, sun and moon for lasting as long as they do. India’s flag is a rectangular tricolor.",
            explainMY: "နီပေါ။ တြိဂံနှစ်ခု စပ်သော ကမ္ဘာ့နီးပါး တစ်ခုတည်းသော အလံ။ အိန္ဒိယက စတုဂံ သုံးရောင်။"
        ),
        Item(
            id: "flag-vietnam",
            flag: "🇻🇳",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "vietnam",
            choices: [
                ("vietnam", "ベトナム", "越南", "Vietnam", "ဗီယက်နမ်"),
                ("china", "中国", "中国", "China", "တရုတ်"),
            ],
            explainJA: "ベトナム。赤い旗の真ん中に黄色い星が1つ。赤は独立、星は人々がまとまる印。中国も赤地に黄色い星だが、星は5つ。",
            explainZH: "越南。红旗正中一颗黄星。红代表独立，星代表人民团结。中国也是红底黄星，但是 5 颗。",
            explainEN: "Vietnam. One yellow star on red: independence, and people standing together. China is also red with yellow stars, but five of them.",
            explainMY: "ဗီယက်နမ်။ အနီပေါ် ကြယ်ဝါ ၁ ခု။ တရုတ်က ကြယ် ၅ ခု။"
        ),
        Item(
            id: "flag-myanmar",
            flag: "🇲🇲",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "myanmar",
            choices: [
                ("lithuania", "リトアニア", "立陶宛", "Lithuania", "လစ်သူယေးနီးယား"),
                ("myanmar", "ミャンマー", "缅甸", "Myanmar", "မြန်မာ"),
            ],
            explainJA: "ミャンマー。黄・緑・赤の横三色の上に白い星。黄は団結、緑は平和、赤は勇気、星は国が一つであること。リトアニアも黄緑赤だが、星がない。",
            explainZH: "缅甸。黄、绿、红横条上有一颗白星。黄是团结，绿是和平，红是勇气，星表示国家统一。立陶宛也是黄绿红，但没有星。",
            explainEN: "Myanmar. Yellow, green, and red stripes with a white star: solidarity, peace, courage, and union. Lithuania uses the same colors, but has no star.",
            explainMY: "မြန်မာ။ အဝါ–အစိမ်း–အနီ ပေါ် ကြယ်ဖြူ။ လစ်သူယေးနီးယားတွင် ကြယ် မရှိ။"
        ),
        Item(
            id: "flag-srilanka",
            flag: "🇱🇰",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "srilanka",
            choices: [
                ("india", "インド", "印度", "India", "အိန္ဒိယ"),
                ("srilanka", "スリランカ", "斯里兰卡", "Sri Lanka", "သီရိလင်္ကာ"),
            ],
            explainJA: "スリランカ。黄色い獅子と剣は勇気。緑とオレンジの帯は国内のさまざまな人々。ボの葉は仏教。インドの旗は横三色で、中央に輪がある。",
            explainZH: "斯里兰卡。黄狮和剑代表勇气。绿、橙条代表国内不同族群。菩提叶代表佛教。印度旗是横三色，中间有轮。",
            explainEN: "Sri Lanka. A gold lion and sword for courage; green and orange for communities; bo leaves for Buddhism. India is a tricolor with a wheel in the center.",
            explainMY: "သီရိလင်္ကာ။ ခြင်္သေ့နှင့် ဓားက ရဲစွမ်း။ အိန္ဒိယက သုံးရောင်နှင့် စက်ဝိုင်း။"
        ),
        Item(
            id: "flag-korea",
            flag: "🇰🇷",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "korea",
            choices: [
                ("korea", "韓国", "韩国", "South Korea", "တောင်ကိုရီးယား"),
                ("japan", "日本", "日本", "Japan", "ဂျပန်"),
            ],
            explainJA: "韓国。白い旗に赤と青の太極、四すみに卦。白は平和、太極は調和。日本の旗は白い地に赤い丸だけで、模様が違う。",
            explainZH: "韩国。白旗上有红蓝太极和四角的卦。白代表和平，太极代表和谐。日本旗只是白底红日，图案不同。",
            explainEN: "South Korea. White for peace, a red-and-blue taegeuk for balance, and four trigrams. Japan’s flag is a red disc on white, with no taegeuk.",
            explainMY: "တောင်ကိုရီးယား။ အဖြူပေါ် တိုင်ဂုတ်နှင့် ဂွာ။ ဂျပန်က အနီလုံးသာ။"
        ),
        Item(
            id: "flag-bangladesh",
            flag: "🇧🇩",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "bangladesh",
            choices: [
                ("japan", "日本", "日本", "Japan", "ဂျပန်"),
                ("bangladesh", "バングラデシュ", "孟加拉国", "Bangladesh", "ဘင်္ဂလားဒေ့ရှ်"),
            ],
            explainJA: "バングラデシュ。緑の地に赤い丸。緑は豊かな土地、赤は独立の朝日。日本も赤い丸だが、地の色は白。",
            explainZH: "孟加拉国。绿底红圆。绿是富饶的土地，红是独立的朝阳。日本也有红圆，但底色是白的。",
            explainEN: "Bangladesh. A red disc on green: fertile land and the sun of independence. Japan also has a red disc, but on white.",
            explainMY: "ဘင်္ဂလားဒေ့ရှ်။ အစိမ်းပေါ် အနီလုံး။ ဂျပန်က အဖြူပေါ် အနီလုံး။"
        ),
        Item(
            id: "flag-taiwan",
            flag: "🇹🇼",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "taiwan",
            choices: [
                ("taiwan", "台湾", "台湾", "Taiwan", "ထိုင်ဝမ်"),
                ("china", "中国", "中国", "China", "တရုတ်"),
            ],
            explainJA: "台湾。赤い地の左上に青い四角、白い太陽。12本の光は1年の12か月。中国の旗は黄色い星で、太陽ではない。",
            explainZH: "台湾。红底左上是蓝方块和白日。12 道光代表一年 12 个月。中国旗是黄星，不是太阳。",
            explainEN: "Taiwan. Red field, blue canton, white sun with 12 rays for the 12 months. China’s flag uses yellow stars, not a sun.",
            explainMY: "ထိုင်ဝမ်။ အနီပေါ် အပြာစတုရန်းနှင့် နေဖြူ။ တရုတ်က ကြယ်ဝါ။"
        ),
        Item(
            id: "flag-indonesia",
            flag: "🇮🇩",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "indonesia",
            choices: [
                ("indonesia", "インドネシア", "印度尼西亚", "Indonesia", "အင်ဒိုနီးရှား"),
                ("monaco", "モナコ", "摩纳哥", "Monaco", "မိုနာကို"),
            ],
            explainJA: "インドネシア。上赤・下白。赤は勇気、白は純潔。モナコも同じ赤白だが、縦に近く四角い。インドネシアの旗は横に長い。",
            explainZH: "印度尼西亚。上红下白。红是勇气，白是纯洁。摩纳哥也是红白，但更接近正方形。印尼旗更扁更长。",
            explainEN: "Indonesia. Red over white: courage and purity. Monaco uses the same colors, but is closer to square. Indonesia’s flag is much wider.",
            explainMY: "အင်ဒိုနီးရှား။ အပေါ်အနီ အောက်အဖြူ။ မိုနာကိုက ပိုစတုရန်း။"
        ),
        Item(
            id: "flag-usa",
            flag: "🇺🇸",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "usa",
            choices: [
                ("usa", "アメリカ", "美国", "United States", "အမေရိကန်"),
                ("liberia", "リベリア", "利比里亚", "Liberia", "လိုက်ဘေးရီးယား"),
            ],
            explainJA: "アメリカ。13本の縞は最初の州、青い四角の星は今の州の数。赤は勇気、白は純潔、青は正義。リベリアも似ているが、星は1つだけ。",
            explainZH: "美国。13 道条纹是最初的州，蓝角上的星是现在的州。红是勇气，白是纯洁，蓝是正义。利比里亚很像，但只有 1 颗星。",
            explainEN: "United States. 13 stripes for the first states, stars for today’s states. Red valor, white purity, blue justice. Liberia looks similar, but has only one star.",
            explainMY: "အမေရိကန်။ ကြယ်များစွာ။ လိုက်ဘေးရီးယားက ကြယ် ၁ ခုသာ။"
        ),
        Item(
            id: "flag-japan",
            flag: "🇯🇵",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "japan",
            choices: [
                ("bangladesh", "バングラデシュ", "孟加拉国", "Bangladesh", "ဘင်္ဂလားဒေ့ရှ်"),
                ("japan", "日本", "日本", "Japan", "ဂျပန်"),
            ],
            explainJA: "日本。白い地に赤い日の丸。白は清らかさ、赤は太陽。バングラデシュも赤い丸だが、地は緑。",
            explainZH: "日本。白底红日。白是纯洁，红是太阳。孟加拉国也有红圆，但底色是绿的。",
            explainEN: "Japan. A red sun on white: purity and the sun. Bangladesh also has a red disc, but on green.",
            explainMY: "ဂျပန်။ အဖြူပေါ် နေနီ။ ဘင်္ဂလားဒေ့ရှ်က အစိမ်းပေါ်။"
        ),
        Item(
            id: "flag-uk",
            flag: "🇬🇧",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "uk",
            choices: [
                ("uk", "イギリス", "英国", "United Kingdom", "ယူကေ"),
                ("australia", "オーストラリア", "澳大利亚", "Australia", "ဩစတြေးလျ"),
            ],
            explainJA: "イギリス。イングランド・スコットランド・アイルランドの十字を重ねたユニオンジャック。オーストラリアの旗は端にユニオンジャックがあり、ほかに南十字星がある。",
            explainZH: "英国。英格兰、苏格兰、爱尔兰的十字叠在一起，叫联合杰克。澳大利亚旗角上有联合杰克，另外还有南十字星。",
            explainEN: "United Kingdom. The Union Jack layers three crosses. Australia puts a Union Jack in the corner and adds the Southern Cross.",
            explainMY: "ယူကေ။ ယူနီယံဂျက်။ ဩစတြေးလျတွင် ထောင့်၌ ရှိပြီး ကြယ်များ ထပ်ပါသည်။"
        ),
        Item(
            id: "flag-france",
            flag: "🇫🇷",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "france",
            choices: [
                ("france", "フランス", "法国", "France", "ပြင်သစ်"),
                ("netherlands", "オランダ", "荷兰", "Netherlands", "နယ်သာလန်"),
            ],
            explainJA: "フランス。青・白・赤の縦三色。自由・平等・博愛を表すことが多い。オランダは赤・白・青の横三色で、向きが違う。",
            explainZH: "法国。蓝白红竖三色，常表示自由、平等、博爱。荷兰是红白蓝横三色，排列方向不同。",
            explainEN: "France. Vertical blue, white, red — often liberty, equality, fraternity. The Netherlands is horizontal red, white, blue.",
            explainMY: "ပြင်သစ်။ ဒေါင်လိုက် အပြာ–အဖြူ–အနီ။ နယ်သာလန်က အလျားလိုက် အနီ–အဖြူ–အပြာ။"
        ),
        Item(
            id: "flag-germany",
            flag: "🇩🇪",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "germany",
            choices: [
                ("germany", "ドイツ", "德国", "Germany", "ဂျာမနီ"),
                ("belgium", "ベルギー", "比利时", "Belgium", "ဘယ်လ်ဂျီယမ်"),
            ],
            explainJA: "ドイツ。黒・赤・金の横三色。ベルギーも似た色だが、黒・黄・赤の縦三色。横か縦かで見分ける。",
            explainZH: "德国。黑、红、金横三色。比利时颜色接近，但是黑、黄、红竖三色。看是横条还是竖条。",
            explainEN: "Germany. Horizontal black, red, gold. Belgium is similar in color, but vertical black, yellow, red.",
            explainMY: "ဂျာမနီ။ အလျားလိုက် အနက်–အနီ–ရွှေ။ ဘယ်လ်ဂျီယမ်က ဒေါင်လိုက်။"
        ),
        Item(
            id: "flag-italy",
            flag: "🇮🇹",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "italy",
            choices: [
                ("italy", "イタリア", "意大利", "Italy", "အီတလီ"),
                ("mexico", "メキシコ", "墨西哥", "Mexico", "မက္ကဆီကို"),
            ],
            explainJA: "イタリア。緑・白・赤の縦三色。緑は平野や希望、白は雪や信仰、赤は勇気とされることが多い。メキシコも緑白赤だが、中央に紋章がある。",
            explainZH: "意大利。绿白红竖三色。绿常表示平原或希望，白表示雪或信仰，红表示勇气。墨西哥也是绿白红，但中间有国徽。",
            explainEN: "Italy. Vertical green, white, red. Mexico uses the same stripes, but has a coat of arms in the center.",
            explainMY: "အီတလီ။ ဒေါင်လိုက် အစိမ်း–အဖြူ–အနီ။ မက္ကဆီကိုတွင် အလယ် အမှတ်အသား ရှိသည်။"
        ),
        Item(
            id: "flag-ireland",
            flag: "🇮🇪",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "ireland",
            choices: [
                ("ivorycoast", "コートジボワール", "科特迪瓦", "Côte d’Ivoire", "ကို့တ်ဒီဗွာ"),
                ("ireland", "アイルランド", "爱尔兰", "Ireland", "အိုင်ယာလန်"),
            ],
            explainJA: "アイルランド。緑・白・オレンジの縦三色。緑とオレンジは人々の調和、白は平和。コートジボワールは同じ色を逆に並べている。",
            explainZH: "爱尔兰。绿、白、橙竖三色。绿和橙表示不同群体和谐，白是和平。科特迪瓦是同样的颜色反过来排。",
            explainEN: "Ireland. Vertical green, white, orange. Côte d’Ivoire uses the same colors in reverse order.",
            explainMY: "အိုင်ယာလန်။ ဒေါင်လိုက် အစိမ်း–အဖြူ–လိမ္မော်။ ကို့တ်ဒီဗွာက ပြောင်းပြန်။"
        ),
        Item(
            id: "flag-australia",
            flag: "🇦🇺",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "australia",
            choices: [
                ("australia", "オーストラリア", "澳大利亚", "Australia", "ဩစတြေးလျ"),
                ("newzealand", "ニュージーランド", "新西兰", "New Zealand", "နယူးဇီလန်"),
            ],
            explainJA: "オーストラリア。青い地にユニオンジャック、大きな七角の星、白い南十字星。ニュージーランドも似ているが、星は赤くて4つ。大きい白い星があるのがオーストラリア。",
            explainZH: "澳大利亚。蓝底、联合杰克、一颗大七角星和白色南十字。新西兰很像，但星是红色的、只有 4 颗。有那颗大白星的是澳大利亚。",
            explainEN: "Australia. Blue field, Union Jack, a large seven-pointed star, and a white Southern Cross. New Zealand is similar, but its stars are red and there are four.",
            explainMY: "ဩစတြေးလျ။ ကြယ်ဖြူကြီးနှင့် တောင်ကြယ်။ နယူးဇီလန်က ကြယ်နီ ၄ ခု။"
        ),
        Item(
            id: "flag-chad",
            flag: "🇹🇩",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "chad",
            choices: [
                ("romania", "ルーマニア", "罗马尼亚", "Romania", "ရိုမေးနီးယား"),
                ("chad", "チャド", "乍得", "Chad", "ချဒ်"),
            ],
            explainJA: "チャド。青・黄・赤の縦三色。青は空や希望、黄は太陽、赤は勇気。ルーマニアもほとんど同じ配色で、ネットでよく比べられる。チャドの青は少し暗い。",
            explainZH: "乍得。蓝、黄、红竖三色。蓝是天空或希望，黄是太阳，红是勇气。罗马尼亚配色几乎一样，网上常拿来比。乍得的蓝更深一点。",
            explainEN: "Chad. Vertical blue, yellow, red. Romania is almost the same — a famous look-alike. Chad’s blue is a bit darker.",
            explainMY: "ချဒ်။ ဒေါင်လိုက် အပြာ–အဝါ–အနီ။ ရိုမေးနီးယားနှင့် နီးပါးတူသည်။"
        ),
        Item(
            id: "flag-canada",
            flag: "🇨🇦",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "canada",
            choices: [
                ("peru", "ペルー", "秘鲁", "Peru", "ပီရူး"),
                ("canada", "カナダ", "加拿大", "Canada", "ကနေဒါ"),
            ],
            explainJA: "カナダ。赤・白・赤に赤いカエデの葉。カエデはカナダの印。ペルーも赤白赤だが、中央は紋章で、葉ではない。",
            explainZH: "加拿大。红白红，中间是红枫叶。枫叶代表加拿大。秘鲁也是红白红，但中间是国徽，不是叶子。",
            explainEN: "Canada. Red-white-red with a maple leaf, the country’s emblem. Peru is also red-white-red, but the center is a coat of arms, not a leaf.",
            explainMY: "ကနေဒါ။ မေပယ်ရွက်။ ပီရူးက အလယ် အမှတ်အသား။"
        ),
        Item(
            id: "flag-india",
            flag: "🇮🇳",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "india",
            choices: [
                ("india", "インド", "印度", "India", "အိန္ဒိယ"),
                ("niger", "ニジェール", "尼日尔", "Niger", "နိုင်ဂျာ"),
            ],
            explainJA: "インド。橙・白・緑の横三色。中央の24本の輪はアショーカ・チャクラ。橙は勇気、白は平和、緑は豊かさ。ニジェールも橙白緑だが、中央はオレンジの丸。",
            explainZH: "印度。橙、白、绿横三色。中间 24 辐的轮是阿育王轮。橙是勇气，白是和平，绿是富饶。尼日尔也是橙白绿，但中间是橙圆。",
            explainEN: "India. Saffron, white, green, with the 24-spoke Ashoka Chakra. Niger is a similar tricolor, but has an orange disc instead of a wheel.",
            explainMY: "အိန္ဒိယ။ လိမ္မော်–အဖြူ–အစိမ်းနှင့် စက်ဝိုင်း။ နိုင်ဂျာက အလယ် လုံး။"
        ),
        Item(
            id: "flag-russia",
            flag: "🇷🇺",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "russia",
            choices: [
                ("slovakia", "スロバキア", "斯洛伐克", "Slovakia", "ဆလိုဗက်ကီးယား"),
                ("russia", "ロシア", "俄罗斯", "Russia", "ရုရှား"),
            ],
            explainJA: "ロシア。白・青・赤の横三色。白は率直、青は誠実、赤は勇気とされることが多い。スロバキアも白青赤だが、紋章が付いている。",
            explainZH: "俄罗斯。白、蓝、红横三色。白常表示率直，蓝表示诚实，红表示勇气。斯洛伐克也是白蓝红，但带有国徽。",
            explainEN: "Russia. Horizontal white, blue, red. Slovakia uses the same stripes plus a coat of arms.",
            explainMY: "ရုရှား။ အလျားလိုက် အဖြူ–အပြာ–အနီ။ ဆလိုဗက်ကီးယားတွင် အမှတ်အသား ပါသည်။"
        ),
        Item(
            id: "flag-mongolia",
            flag: "🇲🇳",
            ja: promptJA, zh: promptZH, en: promptEN, my: promptMY,
            answerID: "mongolia",
            choices: [
                ("kazakhstan", "カザフスタン", "哈萨克斯坦", "Kazakhstan", "ကာဇက်စတန်"),
                ("mongolia", "モンゴル", "蒙古", "Mongolia", "မွန်ဂိုလီးယား"),
            ],
            explainJA: "モンゴル。赤・青・赤。青い帯は永遠の空。赤い帯のソヨンボは火・太陽・月などの印。カザフスタンは空色に金色の模様で、配色が違う。",
            explainZH: "蒙古。红、蓝、红。蓝带是长生天。红带上的索永布是火、太阳、月亮等符号。哈萨克斯坦是天蓝底金色图案，配色不同。",
            explainEN: "Mongolia. Red-blue-red. Blue is the eternal sky; the soyombo on red stands for fire, sun, and moon. Kazakhstan is sky-blue with gold, a different palette.",
            explainMY: "မွန်ဂိုလီးယား။ အနီ–အပြာ–အနီနှင့် ဆိုယွန်ဘို။ ကာဇက်စတန်က မိုးပြာနှင့် ရွှေ။"
        ),
    ]
}
