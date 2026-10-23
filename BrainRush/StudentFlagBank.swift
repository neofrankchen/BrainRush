import Foundation

/// 日本の留学生が多い国・地域の旗。JASSO 2024年5月1日時点。
enum StudentFlagBank {
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
                task: .studentFlag,
                rule: rule,
                answerID: answerID,
                choices: picks.map {
                    AnswerChoice(id: $0.id, title: tr(ja: $0.ja, zh: $0.zh, en: $0.en, my: $0.my), symbol: nil, style: .neutral)
                },
                stimulus: .flag(id: id, emoji: flag)
            )
        }
    }

    private static let promptJA = "この旗は、日本に留学している人が多い国・地域のどれ？"
    private static let promptZH = "这面旗是日本留学生人数靠前的哪个国家或地区？"
    private static let promptEN = "Which top origin of students in Japan is this flag?"
    private static let promptMY = "ဂျပန်တွင် ကျောင်းသားများများသော နိုင်ငံ/ဒေသ ဘယ်အလံလဲ။"

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
            explainJA: "中国。JASSO（2024年5月1日）では日本の留学生12万3485人で1位、全体の約37%。有名なものは万里の長城、パンダ、春節、北京ダック。会社ではファーウェイやテンセントがある。",
            explainZH: "中国。JASSO（2024年5月1日）统计，在日留学生 123,485 人，第 1 名，约占全体 37%。出名的有长城、熊猫、春节、北京烤鸭，公司有华为、腾讯。",
            explainEN: "China. JASSO (1 May 2024): 123,485 students in Japan, 1st, about 37%. Famous: the Great Wall, pandas, Spring Festival, Peking duck; companies like Huawei and Tencent.",
            explainMY: "တရုတ်။ JASSO (2024 မေ 1) တွင် ဂျပန်၌ 123,485 ဦး၊ အဆင့် 1၊ 37% ခန့်။ ကျော်ကြားသည် - မဟာတံတိုင်း၊ ပန်ဒါ၊ နွေဦးပွဲ၊ ပီကင်းဘဲ၊ Huawei၊ Tencent။"
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
            explainJA: "ネパール。JASSOでは6万4816人で2位。前年より大きく増えた。世界でいちばん高いエベレストがあり、首都はカトマンズ。ダールバートというご飯と豆の料理が有名。",
            explainZH: "尼泊尔。JASSO 统计 64,816 人，第 2 名，比前一年大增。有世界最高峰珠穆朗玛峰，首都加德满都。名菜是豆汤配饭（达尔巴特）。",
            explainEN: "Nepal. JASSO: 64,816 students, 2nd, a big jump from the year before. Home of Everest; capital Kathmandu. Famous food: dal bhat.",
            explainMY: "နီပေါ။ JASSO တွင် 64,816၊ အဆင့် 2။ အမြင့်ဆုံး ဧဝရတ်တောင်၊ မြို့တော် ကတ်မန္ဒူ။ ထမင်းနှင့် ပဲဟင်း dal bhat ကျော်ကြားသည်။"
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
            explainJA: "ベトナム。JASSOでは4万323人で3位。フォーという麺、ハロン湾の景色、アオザイという服が有名。コーヒーもよく知られている。",
            explainZH: "越南。JASSO 统计 40,323 人，第 3 名。出名的有河粉、下龙湾、奥黛，咖啡也很有名。",
            explainEN: "Vietnam. JASSO: 40,323 students, 3rd. Famous: pho, Ha Long Bay, the ao dai dress, and coffee.",
            explainMY: "ဗီယက်နမ်။ JASSO တွင် 40,323၊ အဆင့် 3။ ဖိုခေါက်ဆွဲ၊ ဟာလောင်ပင်လယ်အော်၊ အောဇိုင်းဝတ်စုံ၊ ကော်ဖီ ကျော်ကြားသည်။"
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
            explainJA: "ミャンマー。JASSOでは1万6596人で4位。前年の約2倍に増えた。ヤンゴンのシュエダゴン・パゴダ、インレー湖、ロンジーという巻きスカートが有名。",
            explainZH: "缅甸。JASSO 统计 16,596 人，第 4 名，大约是前一年的两倍。出名的有仰光大金塔、茵莱湖、笼基。",
            explainEN: "Myanmar. JASSO: 16,596 students, 4th, about twice the year before. Famous: Shwedagon Pagoda in Yangon, Inle Lake, and the longyi.",
            explainMY: "မြန်မာ။ JASSO တွင် 16,596၊ အဆင့် 4၊ ယခင်နှစ်၏ နှစ်ဆခန့်။ ရွှေတိဂုံစေတီ၊ အင်းလေးကန်၊ လုံချည် ကျော်ကြားသည်။"
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
            explainJA: "韓国。JASSOでは1万4579人で5位。K-POP、サムスン、キムチ、ソウルの景福宮が有名。ドラマや化粧品もよく知られている。",
            explainZH: "韩国。JASSO 统计 14,579 人，第 5 名。出名的有 K-POP、三星、泡菜、首尔景福宫，还有影视和化妆品。",
            explainEN: "South Korea. JASSO: 14,579 students, 5th. Famous: K-pop, Samsung, kimchi, Gyeongbokgung in Seoul, dramas and cosmetics.",
            explainMY: "တောင်ကိုရီးယား။ JASSO တွင် 14,579၊ အဆင့် 5။ K-POP၊ Samsung၊ ကင်မ်ချီ၊ ဆိုးလ်ရှိ Gyeongbokgung နန်းတော် ကျော်ကြားသည်။"
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
            explainJA: "スリランカ。JASSOでは1万2269人で6位。セイロンティー、コロンボ、ゾウ、シーギリヤロックが有名。",
            explainZH: "斯里兰卡。JASSO 统计 12,269 人，第 6 名。出名的有锡兰红茶、科伦坡、大象、狮子岩。",
            explainEN: "Sri Lanka. JASSO: 12,269 students, 6th. Famous: Ceylon tea, Colombo, elephants, and Sigiriya Rock.",
            explainMY: "သီရိလင်္ကာ။ JASSO တွင် 12,269၊ အဆင့် 6။ စီလုံလက်ဖက်၊ ကိုလံဘို၊ ဆင်၊ Sigiriya ကျောက်တောင် ကျော်ကြားသည်။"
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
            explainJA: "台湾。JASSOでは7655人で7位。夜市の食べもの、タピオカティー、台北101、阿里山が有名。半導体のTSMCもある。",
            explainZH: "台湾。JASSO 统计 7,655 人，第 7 名。出名的有夜市小吃、珍珠奶茶、台北101、阿里山，还有台积电。",
            explainEN: "Taiwan. JASSO: 7,655 students, 7th. Famous: night-market food, bubble tea, Taipei 101, Alishan, and TSMC chips.",
            explainMY: "ထိုင်ဝမ်။ JASSO တွင် 7,655၊ အဆင့် 7။ ညဈေးအစားအစာ၊ ပုလဲနို့လက်ဖက်၊ ထိုင်ပေ 101၊ အလီရှန်၊ TSMC ကျော်ကြားသည်။"
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
            explainJA: "バングラデシュ。JASSOでは7597人で8位。首都ダッカ、ジャムダニ織、ベンガルトラ、リックスホーという三輪車が有名。",
            explainZH: "孟加拉国。JASSO 统计 7,597 人，第 8 名。出名的有首都达卡、贾姆达尼织品、孟加拉虎、三轮车。",
            explainEN: "Bangladesh. JASSO: 7,597 students, 8th. Famous: Dhaka, jamdani weaving, the Bengal tiger, and rickshaws.",
            explainMY: "ဘင်္ဂလားဒေ့ရှ်။ JASSO တွင် 7,597၊ အဆင့် 8။ ဒါကာ၊ jamdani ရက်ကန်း၊ ဘင်္ဂလားကျား၊ ရစ်ရှော ကျော်ကြားသည်။"
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
            explainJA: "インドネシア。JASSOでは6778人で9位。赤と白の旗はモナコと似ている。バリ島、ボロブドゥール遺跡、バティック、ガルーダが有名。",
            explainZH: "印度尼西亚。JASSO 统计 6,778 人，第 9 名。红白旗很像摩纳哥。出名的有巴厘岛、婆罗浮屠、蜡染、嘉鲁达。",
            explainEN: "Indonesia. JASSO: 6,778 students, 9th. The red-and-white flag looks like Monaco’s. Famous: Bali, Borobudur, batik, Garuda.",
            explainMY: "အင်ဒိုနီးရှား။ JASSO တွင် 6,778၊ အဆင့် 9။ အနီ-အဖြူအလံသည် မိုနာကိုနှင့် ဆင်တူသည်။ ဘာလီ၊ ဗိုရိုဘူဒူ၊ ဘာတစ်၊ ဂါရုဒ ကျော်ကြားသည်။"
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
            explainJA: "モンゴル。JASSOでは4085人で10位。チンギス・ハン、草原、ナーダムという祭り、フートグ（羊肉）が有名。",
            explainZH: "蒙古。JASSO 统计 4,085 人，第 10 名。出名的有成吉思汗、草原、那达慕大会、手把羊肉。",
            explainEN: "Mongolia. JASSO: 4,085 students, 10th. Famous: Genghis Khan, the steppe, the Naadam festival, and khorkhog (mutton).",
            explainMY: "မွန်ဂိုလီးယား။ JASSO တွင် 4,085၊ အဆင့် 10။ ချင်ဂစ္စခန်၊ လွင်ပြင်၊ နာဒမ်ပွဲ၊ သိုးသားဟင်း ကျော်ကြားသည်။"
        ),
    ]
}
