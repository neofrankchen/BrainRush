import Foundation

/// 美食2択：世界の料理。日本の食べ物は JapanChoiceBank。
enum GourmetChoiceBank {
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
                task: .gourmetChoice,
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
            id: "gm-paella",
            ja: "パエリアはどこの国の料理として有名？",
            zh: "西班牙海鲜饭是哪个国家的著名料理？",
            en: "Paella is a famous dish from which country?",
            my: "ပယ်အဲလျာက ဘယ်နိုင်ငံ အစားအစာလဲ။",
            answerID: "spain",
            choices: [
                ("spain", "スペイン", "西班牙", "Spain", "စပိန်"),
                ("portugal", "ポルトガル", "葡萄牙", "Portugal", "ပေါ်တူဂါ"),
            ],
            explainJA: "正解はスペイン。バレンシア地方の米料理。ポルトガルではない。",
            explainZH: "正确答案是西班牙。源自巴伦西亚的米饭菜。不是葡萄牙。",
            explainEN: "Spain, from Valencia. Not Portugal.",
            explainMY: "အဖြေမှန်က စပိန်။"
        ),
        Item(
            id: "gm-pho",
            ja: "フォーはどこの国の料理？",
            zh: "河粉是哪个国家的料理？",
            en: "Which country is pho from?",
            my: "ဖိုခေါက်ဆွဲက ဘယ်နိုင်ငံ အစားလဲ။",
            answerID: "vietnam",
            choices: [
                ("thai", "タイ", "泰国", "Thailand", "ထိုင်း"),
                ("vietnam", "ベトナム", "越南", "Vietnam", "ဗီယက်နမ်"),
            ],
            explainJA: "正解はベトナム。スープに平たい米粉麺。タイの代表はパッタイなど。",
            explainZH: "正确答案是越南。扁米粉配汤。泰国更有名的是炒河粉。",
            explainEN: "Vietnam. Thailand is better known for pad thai.",
            explainMY: "အဖြေမှန်က ဗီယက်နမ်။"
        ),
        Item(
            id: "gm-taco",
            ja: "タコスはどこの国の伝統料理？",
            zh: "塔可饼是哪个国家的传统料理？",
            en: "Tacos are a traditional dish of which country?",
            my: "တာကိုက ဘယ်နိုင်ငံ ရိုးရာအစားလဲ။",
            answerID: "mexico",
            choices: [
                ("argentina", "アルゼンチン", "阿根廷", "Argentina", "အာဂျင်တီးနား"),
                ("mexico", "メキシコ", "墨西哥", "Mexico", "မက္ကဆီကို"),
            ],
            explainJA: "正解はメキシコ。とうもろこしのトルティーヤに具を包む。",
            explainZH: "正确答案是墨西哥。用玉米饼包馅。",
            explainEN: "Mexico. A tortilla with fillings.",
            explainMY: "အဖြေမှန်က မက္ကဆီကို။"
        ),
        Item(
            id: "gm-bibimbap",
            ja: "ビビンバはどこの国の料理？",
            zh: "石锅拌饭是哪个国家的料理？",
            en: "Which country is bibimbap from?",
            my: "ဘီဘင်ဘပ်က ဘယ်နိုင်ငံ အစားလဲ။",
            answerID: "korea",
            choices: [
                ("korea", "韓国", "韩国", "Korea", "ကိုရီးယား"),
                ("china", "中国", "中国", "China", "တရုတ်"),
            ],
            explainJA: "正解は韓国。ご飯の上に野菜や肉をのせて混ぜて食べる。",
            explainZH: "正确答案是韩国。米饭上放蔬菜和肉，拌着吃。",
            explainEN: "Korea. Rice mixed with vegetables and meat.",
            explainMY: "အဖြေမှန်က ကိုရီးယား။"
        ),
        Item(
            id: "gm-ceviche-country",
            ja: "セビーチェが代表料理として有名な国は？",
            zh: "哪个国家以酸橘汁腌鱼闻名？",
            en: "Which country is famous for ceviche?",
            my: "စီဗီချေ ကျော်ကြားသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "peru",
            choices: [
                ("chile", "チリ", "智利", "Chile", "ချီလီ"),
                ("peru", "ペルー", "秘鲁", "Peru", "ပီရူး"),
            ],
            explainJA: "正解はペルー。生の魚を柑橘の汁で締める料理。チリも近いが代表はペルー。",
            explainZH: "正确答案是秘鲁。用柑橘汁腌生鱼。智利也有类似菜，但代表是秘鲁。",
            explainEN: "Peru. Raw fish cured in citrus juice.",
            explainMY: "အဖြေမှန်က ပီရူး။"
        ),
        Item(
            id: "gm-goulash",
            ja: "グヤーシュで有名なのはどこの国？",
            zh: "哪个国家以古拉什汤闻名？",
            en: "Which country is famous for goulash?",
            my: "ဂူလက်ရှ် ကျော်ကြားသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "hungary",
            choices: [
                ("hungary", "ハンガリー", "匈牙利", "Hungary", "ဟန်ဂေရီ"),
                ("sweden", "スウェーデン", "瑞典", "Sweden", "ဆွီဒင်"),
            ],
            explainJA: "正解はハンガリー。パプリカで味つけした肉の煮込み。",
            explainZH: "正确答案是匈牙利。用红椒粉炖的肉汤。",
            explainEN: "Hungary. A paprika meat stew.",
            explainMY: "အဖြေမှန်က ဟန်ဂေရီ။"
        ),
        Item(
            id: "gm-risotto",
            ja: "イタリア料理のリゾットの主な材料は？",
            zh: "意大利烩饭的主要食材是什么？",
            en: "What is the main ingredient in risotto?",
            my: "ရီဇိုတို အဓိက ပစ္စည်းက ဘာလဲ။",
            answerID: "rice",
            choices: [
                ("pasta", "パスタ", "意面", "Pasta", "ခေါက်ဆွဲ"),
                ("rice", "米", "米", "Rice", "ဆန်"),
            ],
            explainJA: "正解は米。短いイタリア米を出汁でゆっくり煮る。パスタ料理ではない。",
            explainZH: "正确答案是米。用短粒米慢慢烩，不是意面。",
            explainEN: "Rice, slowly cooked in stock. Not pasta.",
            explainMY: "အဖြေမှန်က ဆန်။"
        ),
        Item(
            id: "gm-gazpacho",
            ja: "スペイン料理のガスパチョは普通どう食べる？",
            zh: "西班牙冷汤通常怎么吃？",
            en: "How is Spanish gazpacho usually eaten?",
            my: "ဂက်စ်ပတ်ချိုကို ဘယ်လိုစားလဲ။",
            answerID: "cold",
            choices: [
                ("cold", "冷たくして", "冷着吃", "Cold", "အေးအေး"),
                ("hot", "熱々にして", "热着吃", "Hot", "ပူပူ"),
            ],
            explainJA: "正解は冷たくして。トマトなどの野菜をすりつぶした冷製スープ。",
            explainZH: "正确答案是冷着吃。番茄等蔬菜打成的冷汤。",
            explainEN: "Served cold. A blended vegetable soup.",
            explainMY: "အဖြေမှန်က အေးအေး စားသည်။"
        ),
        Item(
            id: "gm-carbonara",
            ja: "伝統的なローマ風カルボナーラに使うのは？",
            zh: "传统罗马风味培根蛋面使用什么？",
            en: "Traditional Roman carbonara uses which of these?",
            my: "ရိုးရာ ကာဘိုနာရာတွင် ဘာသုံးသလဲ။",
            answerID: "egg",
            choices: [
                ("cream", "生クリーム", "鲜奶油", "Cream", "ခရင်မ်"),
                ("egg", "卵", "鸡蛋", "Egg", "ကြက်ဥ"),
            ],
            explainJA: "正解は卵。チーズと卵で絡める。生クリームは後から広まった入れ方。",
            explainZH: "正确答案是鸡蛋。用蛋和奶酪拌面。鲜奶油是后来才常见的做法。",
            explainEN: "Egg and cheese. Cream is a later variation.",
            explainMY: "အဖြေမှန်က ကြက်ဥ။"
        ),
        Item(
            id: "gm-tzatziki",
            ja: "ギリシャ料理のツァツィキによく使うのは？",
            zh: "希腊酸奶黄瓜酱通常使用什么？",
            en: "Greek tzatziki is usually made with which of these?",
            my: "ဂရိ ဆတ်ဇီကီတွင် ဘာသုံးသလဲ။",
            answerID: "yogurt",
            choices: [
                ("yogurt", "ヨーグルト", "酸奶", "Yogurt", "ဒိန်ချဉ်"),
                ("mayo", "マヨネーズ", "蛋黄酱", "Mayonnaise", "မေယို"),
            ],
            explainJA: "正解はヨーグルト。きゅうりとニンニクを合わせたソース。",
            explainZH: "正确答案是酸奶。配黄瓜和大蒜。",
            explainEN: "Yogurt with cucumber and garlic.",
            explainMY: "အဖြေမှန်က ဒိန်ချဉ်။"
        ),
        Item(
            id: "gm-hummus",
            ja: "中東料理のフムスの主な材料は？",
            zh: "中东鹰嘴豆泥的主要食材是什么？",
            en: "What is the main ingredient in hummus?",
            my: "ဟမ်းမတ်စ် အဓိက ပစ္စည်းက ဘာလဲ။",
            answerID: "chickpea",
            choices: [
                ("chickpea", "ひよこ豆", "鹰嘴豆", "Chickpeas", "ပဲချောင်း"),
                ("potato", "じゃがいも", "土豆", "Potato", "အာလူး"),
            ],
            explainJA: "正解はひよこ豆。すりつぶしてごまペーストなどと合わせる。",
            explainZH: "正确答案是鹰嘴豆。磨成泥后常配芝麻酱。",
            explainEN: "Chickpeas, often with tahini.",
            explainMY: "အဖြေမှန်က ပဲချောင်း။"
        ),
        Item(
            id: "gm-fish-chips",
            ja: "イギリスのフィッシュ＆チップスの「チップス」は？",
            zh: "英国炸鱼薯条中的 Chips 是什么？",
            en: "In British fish and chips, what are the chips?",
            my: "ဗြိတိန် ငါးနှင့် ချစ်ပ်စ်တွင် ချစ်ပ်စ်က ဘာလဲ။",
            answerID: "fries",
            choices: [
                ("crisps", "薄いポテトチップス", "薄薯片", "Thin crisps", "ပါးပါး အာလူးချပ်"),
                ("fries", "フライドポテト", "炸薯条", "Thick fries", "အာလူးကြော်"),
            ],
            explainJA: "正解はフライドポテト。イギリスでは太い揚げ芋をチップスと呼ぶ。薄い袋菓子はクリスプ。",
            explainZH: "正确答案是炸薯条。英式 chips 是粗薯条，薄薯片叫 crisps。",
            explainEN: "Thick fried potatoes. Thin bagged chips are called crisps.",
            explainMY: "အဖြေမှန်က အာလူးကြော်။"
        ),
        Item(
            id: "gm-padthai",
            ja: "タイ料理のパッタイの麺は普通何から作られる？",
            zh: "泰式炒河粉的面条通常由什么制成？",
            en: "Pad thai noodles are usually made from what?",
            my: "ပတ်ထိုင်း ခေါက်ဆွဲကို ဘာနှင့် လုပ်သလဲ။",
            answerID: "rice",
            choices: [
                ("wheat", "小麦粉", "小麦粉", "Wheat flour", "ဂျုံမှုန့်"),
                ("rice", "米", "米", "Rice", "ဆန်"),
            ],
            explainJA: "正解は米。米粉の麺を炒める。小麦粉の麺ではない。",
            explainZH: "正确答案是米。用米粉炒，不是小麦粉。",
            explainEN: "Rice noodles, not wheat noodles.",
            explainMY: "အဖြေမှန်က ဆန်။"
        ),
        Item(
            id: "gm-tomyum",
            ja: "トムヤムクンの「クン」は何を意味する？",
            zh: "冬阴功汤里的“功”是什么意思？",
            en: "In tom yum kung, what does kung mean?",
            my: "တွမ်ယမ်ကွန်း တွင် ကွန်းက ဘာလဲ။",
            answerID: "shrimp",
            choices: [
                ("shrimp", "エビ", "虾", "Shrimp", "ပုဇွန်"),
                ("crab", "カニ", "螃蟹", "Crab", "ကဏန်း"),
            ],
            explainJA: "正解はエビ。タイ語でクンはエビ。カニはプー。",
            explainZH: "正确答案是虾。泰语“功”是虾。螃蟹叫“普”。",
            explainEN: "Shrimp. Crab is puu in Thai.",
            explainMY: "အဖြေမှန်က ပုဇွန်။"
        ),
        Item(
            id: "gm-somtam",
            ja: "タイのサラダ「ソムタム」によく使うのは？",
            zh: "泰国青木瓜沙拉通常使用什么？",
            en: "Thai som tam is usually made with which of these?",
            my: "ထိုင်း ဆုမ်တမ်တွင် ဘာသုံးသလဲ။",
            answerID: "papaya",
            choices: [
                ("papaya", "青パパイヤ", "青木瓜", "Green papaya", "ပင်စိမ်း ပပယာ"),
                ("mango", "熟したマンゴー", "熟芒果", "Ripe mango", "မှည့်သော သရက်"),
            ],
            explainJA: "正解は青パパイヤ。細切りにして辛い味で和える。",
            explainZH: "正确答案是青木瓜。切丝后拌成辣沙拉。",
            explainEN: "Shredded green papaya, not ripe mango.",
            explainMY: "အဖြေမှန်က ပင်စိမ်း ပပယာ။"
        ),
        Item(
            id: "gm-banhmi",
            ja: "ベトナムのバインミーによく使うパンは？",
            zh: "越南法棍三明治通常使用哪种面包？",
            en: "What bread is usually used for Vietnamese banh mi?",
            my: "ဗီယက်နမ် ဘန်းမီ ပေါင်မုန့်က ဘာလဲ။",
            answerID: "baguette",
            choices: [
                ("loaf", "食パン", "切片吐司", "Sliced loaf", "ပေါင်မုန့်ချပ်"),
                ("baguette", "バゲット", "法棍", "Baguette", "ဘဂက်"),
            ],
            explainJA: "正解はバゲット。フランスの影響で細長いパンに具を挟む。",
            explainZH: "正确答案是法棍。受法国影响，用长棍面包夹馅。",
            explainEN: "A baguette, from French influence.",
            explainMY: "အဖြေမှန်က ဘဂက်။"
        ),
        Item(
            id: "gm-tteokbokki",
            ja: "韓国料理のトッポッキの主な材料は？",
            zh: "韩式炒年糕的主要食材是什么？",
            en: "What is the main ingredient in tteokbokki?",
            my: "ထော့ဘော့ကီ အဓိက ပစ္စည်းက ဘာလဲ။",
            answerID: "ricecake",
            choices: [
                ("udon", "うどん", "乌冬面", "Udon", "အူဒွန်"),
                ("ricecake", "餅", "年糕", "Rice cakes", "မုန့်ကောက်"),
            ],
            explainJA: "正解は餅。米粉の棒状の餅を辛いソースで煮る。うどんではない。",
            explainZH: "正确答案是年糕。米粉条煮在辣酱里，不是乌冬。",
            explainEN: "Rice cakes in spicy sauce, not udon.",
            explainMY: "အဖြေမှန်က မုန့်ကောက်။"
        ),
        Item(
            id: "gm-xiaolongbao",
            ja: "中国料理の小籠包の中によく入っているのは？",
            zh: "中国小笼包里通常有什么？",
            en: "What is usually inside xiaolongbao?",
            my: "ရှောင်လုံပေါင် အထဲတွင် ဘာရှိသလဲ။",
            answerID: "soup",
            choices: [
                ("soup", "スープ状の肉汁", "汤汁", "Soupy broth", "အရည်ကြည်"),
                ("cheese", "チーズソース", "奶酪酱", "Cheese sauce", "ဒိန်ဆော့စ်"),
            ],
            explainJA: "正解はスープ状の肉汁。凍らせた煮汁を餡に入れて蒸して溶かす。",
            explainZH: "正确答案是汤汁。把冻好的肉汁包进馅里，蒸化成汤。",
            explainEN: "A soupy meat jelly that melts when steamed.",
            explainMY: "အဖြေမှန်က အရည်ကြည်။"
        ),
        Item(
            id: "gm-guacamole",
            ja: "メキシコ料理のワカモレの主な材料は？",
            zh: "墨西哥牛油果酱的主要食材是什么？",
            en: "What is the main ingredient in guacamole?",
            my: "ဂွာကာမိုလီ အဓိက ပစ္စည်းက ဘာလဲ။",
            answerID: "avocado",
            choices: [
                ("avocado", "アボカド", "牛油果", "Avocado", "ထောပတ်သီး"),
                ("cucumber", "きゅうり", "黄瓜", "Cucumber", "သခွား"),
            ],
            explainJA: "正解はアボカド。つぶしてライムや塩で味をつける。",
            explainZH: "正确答案是牛油果。捣碎后常加青柠和盐。",
            explainEN: "Mashed avocado, often with lime and salt.",
            explainMY: "အဖြေမှန်က ထောပတ်သီး။"
        ),
        Item(
            id: "gm-feijoada",
            ja: "ブラジル料理のフェジョアーダによく使う豆は？",
            zh: "巴西黑豆炖肉通常使用什么豆？",
            en: "Which beans are usually used in Brazilian feijoada?",
            my: "ဘရာဇီး ဖေဂျိုအားဒါ ပဲက ဘာလဲ။",
            answerID: "blackbean",
            choices: [
                ("soy", "大豆", "大豆", "Soybeans", "ပဲပိစပ်"),
                ("blackbean", "黒いんげん豆", "黑芸豆", "Black beans", "ပဲနက်"),
            ],
            explainJA: "正解は黒いんげん豆。豚肉などと煮込むブラジルの国民食。",
            explainZH: "正确答案是黑芸豆。常和猪肉一起炖，是巴西国民菜。",
            explainEN: "Black beans stewed with pork. Not soybeans.",
            explainMY: "အဖြေမှန်က ပဲနက်။"
        ),
        Item(
            id: "gm-ceviche-lime",
            ja: "ペルー料理のセビーチェで魚の味付けによく使うのは？",
            zh: "秘鲁酸橘汁腌鱼通常使用什么调味？",
            en: "What is usually used to season fish in Peruvian ceviche?",
            my: "ပီရူး စီဗီချေတွင် ငါးကို ဘာနှင့် နယ်သလဲ။",
            answerID: "lime",
            choices: [
                ("lime", "ライム果汁", "青柠汁", "Lime juice", "ရှောက်ရည်"),
                ("milk", "牛乳", "牛奶", "Milk", "နွားနို့"),
            ],
            explainJA: "正解はライム果汁。酸味で魚を締める。牛乳は使わない。",
            explainZH: "正确答案是青柠汁。用酸味“熟”鱼，不用牛奶。",
            explainEN: "Lime juice cures the fish. Not milk.",
            explainMY: "အဖြေမှန်က ရှောက်ရည်။"
        ),
        Item(
            id: "gm-injera",
            ja: "エチオピア料理のインジェラは主に何の粉で作る？",
            zh: "埃塞俄比亚薄饼主要由什么粉制作？",
            en: "Ethiopian injera is mainly made from which flour?",
            my: "အီသီယိုးပီးယား အင်ဂျီရာ မှုန့်က ဘာလဲ။",
            answerID: "teff",
            choices: [
                ("buckwheat", "そば粉", "荞麦粉", "Buckwheat flour", "ပေါက်ဆံမှုန့်"),
                ("teff", "テフ粉", "苔麸粉", "Teff flour", "တက်ဖ်မှုန့်"),
            ],
            explainJA: "正解はテフ粉。酸味のあるクレープ状のパンの土台になる。",
            explainZH: "正确答案是苔麸粉。做成带酸味的薄饼当餐盘。",
            explainEN: "Teff flour, a sour spongy flatbread.",
            explainMY: "အဖြေမှန်က တက်ဖ်မှုန့်။"
        ),
        Item(
            id: "gm-nachos",
            ja: "メキシコ料理のナチョスによく使うのは？",
            zh: "墨西哥玉米片料理通常使用什么？",
            en: "Nachos are usually made with which of these?",
            my: "နာချိုစ်တွင် ဘာသုံးသလဲ။",
            answerID: "tortilla",
            choices: [
                ("tortilla", "トルティーヤチップス", "玉米片", "Tortilla chips", "တောတီယာချပ်"),
                ("potato", "ポテトチップス", "薯片", "Potato chips", "အာလူးချပ်"),
            ],
            explainJA: "正解はトルティーヤチップス。チーズなどをのせる。ポテトチップスではない。",
            explainZH: "正确答案是玉米片。上面常加奶酪，不是薯片。",
            explainEN: "Tortilla chips, not potato chips.",
            explainMY: "အဖြေမှန်က တောတီယာချပ်။"
        ),
        Item(
            id: "gm-empanada",
            ja: "エンパナーダはどんな料理？",
            zh: "恩潘纳达是什么类型的料理？",
            en: "What kind of dish is an empanada?",
            my: "အင်ပန်နာဒါက ဘယ်လို အစားလဲ။",
            answerID: "pastry",
            choices: [
                ("soup", "麺入りスープ", "带面的汤", "Noodle soup", "ခေါက်ဆွဲပြုတ်ရည်"),
                ("pastry", "具を包んだパイ", "包馅馅饼", "A stuffed pastry", "အထုပ်ပိုင်"),
            ],
            explainJA: "正解は具を包んだパイ。中南米などで焼くか揚げる。スープではない。",
            explainZH: "正确答案是包馅馅饼。中南美洲常烤或炸，不是汤。",
            explainEN: "A stuffed pastry, baked or fried. Not soup.",
            explainMY: "အဖြေမှန်က အထုပ်ပိုင်။"
        ),
        Item(
            id: "gm-tiramisu",
            ja: "イタリアのティラミスによく使う飲み物は？",
            zh: "意大利提拉米苏通常用什么饮品调味？",
            en: "Which drink is usually used in tiramisu?",
            my: "တီရာမီစုတွင် ဘယ်သောက်စရာ သုံးသလဲ။",
            answerID: "coffee",
            choices: [
                ("coffee", "コーヒー", "咖啡", "Coffee", "ကော်ဖီ"),
                ("tea", "紅茶", "红茶", "Tea", "လက်ဖက်ရည်"),
            ],
            explainJA: "正解はコーヒー。フィンガービスケットをエスプレッソに浸す。",
            explainZH: "正确答案是咖啡。饼干浸过浓缩咖啡。",
            explainEN: "Coffee. Ladyfingers are dipped in espresso.",
            explainMY: "အဖြေမှန်က ကော်ဖီ။"
        ),
        Item(
            id: "gm-creme-brulee",
            ja: "クレームブリュレの表面で焦がすのは？",
            zh: "法式焦糖布丁表面焦化的是什么？",
            en: "What is browned on top of crème brûlée?",
            my: "ခရမ်ဘရူလေး အပေါ်တွင် ဘာကို မီးကင်သလဲ။",
            answerID: "sugar",
            choices: [
                ("salt", "塩", "盐", "Salt", "ဆား"),
                ("sugar", "砂糖", "糖", "Sugar", "သကြား"),
            ],
            explainJA: "正解は砂糖。表面の砂糖をバーナーで焦がしてカリッとさせる。",
            explainZH: "正确答案是糖。把表面的糖烤脆。",
            explainEN: "Sugar, torched until crisp. Not salt.",
            explainMY: "အဖြေမှန်က သကြား။"
        ),
        Item(
            id: "gm-cannoli",
            ja: "イタリアのお菓子カンノーリの中によく入れるのは？",
            zh: "意大利卡诺里甜点常用什么作为馅料？",
            en: "What filling is usually inside cannoli?",
            my: "ကန်နိုလီ အထဲတွင် ဘာထည့်သလဲ။",
            answerID: "ricotta",
            choices: [
                ("mozzarella", "モッツァレラチーズ", "马苏里拉奶酪", "Mozzarella", "မောဇာရယ်လာ"),
                ("ricotta", "リコッタチーズ", "里科塔奶酪", "Ricotta", "ရီကော့တာ"),
            ],
            explainJA: "正解はリコッタチーズ。揚げた筒状の生地に甘いリコッタを詰める。",
            explainZH: "正确答案是里科塔。甜奶酪填进炸面筒。",
            explainEN: "Sweet ricotta in a fried pastry tube.",
            explainMY: "အဖြေမှန်က ရီကော့တာ။"
        ),
        Item(
            id: "gm-baklava",
            ja: "バクラヴァに何をよく挟む？",
            zh: "巴克拉瓦千层酥通常夹什么？",
            en: "What is usually layered in baklava?",
            my: "ဘက်ကလာဗာတွင် ဘာညှပ်သလဲ။",
            answerID: "nuts",
            choices: [
                ("nuts", "ナッツ", "坚果", "Nuts", "အခွံမာသီး"),
                ("potato", "じゃがいも", "土豆", "Potato", "အာလူး"),
            ],
            explainJA: "正解はナッツ。薄い生地にナッツを重ね、蜜をかけた菓子。",
            explainZH: "正确答案是坚果。薄饼层层夹坚果再淋糖浆。",
            explainEN: "Layered nuts and pastry with syrup. Not potato.",
            explainMY: "အဖြေမှန်က အခွံမာသီး။"
        ),
        Item(
            id: "gm-churros",
            ja: "チュロスは普通どうやって作る？",
            zh: "吉拿棒通常用什么方式制作？",
            en: "How are churros usually cooked?",
            my: "ချူရိုစ်ကို ဘယ်လိုလုပ်သလဲ။",
            answerID: "fry",
            choices: [
                ("bake", "焼く", "烤", "Baked", "ဖုတ်"),
                ("fry", "揚げる", "炸", "Fried", "ကြော်"),
            ],
            explainJA: "正解は揚げる。生地を油で揚げ、砂糖をまぶすことが多い。",
            explainZH: "正确答案是炸。面糊下油锅，常裹糖。",
            explainEN: "Fried dough, often rolled in sugar.",
            explainMY: "အဖြေမှန်က ကြော်။"
        ),
        Item(
            id: "gm-panna-cotta",
            ja: "パンナコッタを固めるためによく使うのは？",
            zh: "意式奶冻通常使用什么来凝固？",
            en: "What is usually used to set panna cotta?",
            my: "ပန်နာကော့တာ ခဲအောင် ဘာသုံးသလဲ။",
            answerID: "gelatin",
            choices: [
                ("gelatin", "ゼラチン", "明胶", "Gelatin", "ဂျယ်လတင်"),
                ("yeast", "イースト", "酵母", "Yeast", "တဆေး"),
            ],
            explainJA: "正解はゼラチン。生クリームを冷やして固める。イーストは発酵用。",
            explainZH: "正确答案是明胶。奶油冷却凝固。酵母是用来发酵的。",
            explainEN: "Gelatin sets the cream. Yeast is for rising dough.",
            explainMY: "အဖြေမှန်က ဂျယ်လတင်။"
        ),
    ]
}
