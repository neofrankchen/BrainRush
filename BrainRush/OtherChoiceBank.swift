import Foundation

/// 世界の常識2択：地理・名所・食べ物・科学の常識。置きにくい題もここ。
enum OtherChoiceBank {
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
                task: .otherChoice,
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
            id: "ot-paris",
            ja: "フランスの首都は？",
            zh: "法国的首都是什么？",
            en: "What is the capital of France?",
            my: "ပြင်သစ် မြို့တော်က ဘာလဲ။",
            answerID: "paris",
            choices: [
                ("paris", "パリ", "巴黎", "Paris", "ပဲရစ်"),
                ("rome", "ローマ", "罗马", "Rome", "ရောမ"),
            ],
            explainJA: "正解はパリ。ローマはイタリアの首都。",
            explainZH: "正确答案是巴黎。罗马是意大利的首都。",
            explainEN: "Paris. Rome is the capital of Italy.",
            explainMY: "အဖြေမှန်က ပဲရစ်။ ရောမက အီတလီ။"
        ),
        Item(
            id: "ot-moon-sat",
            ja: "地球の自然の衛星は？",
            zh: "地球的天然卫星是什么？",
            en: "What is Earth's natural satellite?",
            my: "ကမ္ဘာရဲ့ သဘာဝ ဂြိုဟ်ရံက ဘာလဲ။",
            answerID: "moon",
            choices: [
                ("sun", "太陽", "太阳", "The Sun", "နေ"),
                ("moon", "月", "月亮", "The Moon", "လ"),
            ],
            explainJA: "正解は月。太陽は恒星で、地球の衛星ではない。",
            explainZH: "正确答案是月亮。太阳是恒星，不是地球的卫星。",
            explainEN: "The Moon. The Sun is a star, not a satellite.",
            explainMY: "အဖြေမှန်က လ။ နေက ကြယ်၊ ဂြိုဟ်ရံ မဟုတ်။"
        ),
        Item(
            id: "ot-pacific",
            ja: "世界で一番広い海洋は？",
            zh: "世界面积最大的海洋是什么？",
            en: "What is the world's largest ocean?",
            my: "ကမ္ဘာ့ အကျယ်ဆုံး သမုဒ္ဒရာက ဘယ်ဟာလဲ။",
            answerID: "pacific",
            choices: [
                ("atlantic", "大西洋", "大西洋", "the Atlantic", "အတ္တလန္တိတ်"),
                ("pacific", "太平洋", "太平洋", "the Pacific", "ပစိဖိတ်"),
            ],
            explainJA: "正解は太平洋。大西洋よりずっと広い。",
            explainZH: "正确答案是太平洋。比大西洋大得多。",
            explainEN: "The Pacific is much larger than the Atlantic.",
            explainMY: "အဖြေမှန်က ပစိဖိတ်။ အတ္တလန္တိတ်ထက် ကျယ်သည်။"
        ),
        Item(
            id: "ot-pyramid",
            ja: "ギザの大ピラミッドがある国は？",
            zh: "吉萨大金字塔位于哪个国家？",
            en: "Where is the Great Pyramid of Giza?",
            my: "ဂီဇာ ပိရမစ်ကြီး ရှိသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "egypt",
            choices: [
                ("egypt", "エジプト", "埃及", "Egypt", "အီဂျစ်"),
                ("greece", "ギリシャ", "希腊", "Greece", "ဂရိ"),
            ],
            explainJA: "正解はエジプト。ギリシャにある有名なのはパルテノン神殿など。",
            explainZH: "正确答案是埃及。希腊更有名的是帕特农神庙一类。",
            explainEN: "Egypt. Greece is known for sites like the Parthenon.",
            explainMY: "အဖြေမှန်က အီဂျစ်။ ဂရိက ပါသီနွန်။"
        ),
        Item(
            id: "ot-eiffel",
            ja: "エッフェル塔がある国は？",
            zh: "埃菲尔铁塔位于哪个国家？",
            en: "Where is the Eiffel Tower?",
            my: "အိုင်ဖယ်တာဝါ ရှိသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "france",
            choices: [
                ("france", "フランス", "法国", "France", "ပြင်သစ်"),
                ("germany", "ドイツ", "德国", "Germany", "ဂျာမနီ"),
            ],
            explainJA: "正解はフランス。パリにある。ドイツではない。",
            explainZH: "正确答案是法国。在巴黎，不在德国。",
            explainEN: "France. It stands in Paris, not Germany.",
            explainMY: "အဖြေမှန်က ပြင်သစ်။ ပဲရစ်တွင် ရှိသည်။"
        ),
        Item(
            id: "ot-koala",
            ja: "コアラが野生で暮らす国は？",
            zh: "考拉在野外生活于哪个国家？",
            en: "Where do wild koalas live?",
            my: "ကိုအာလာ တောရိုင်းနေသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "australia",
            choices: [
                ("canada", "カナダ", "加拿大", "Canada", "ကနေဒါ"),
                ("australia", "オーストラリア", "澳大利亚", "Australia", "ဩစတြေးလျ"),
            ],
            explainJA: "正解はオーストラリア。野生のコアラはオーストラリアにしかいない。カナダはいない。",
            explainZH: "正确答案是澳大利亚。野生考拉只生活在澳大利亚，加拿大没有。",
            explainEN: "Australia. Wild koalas live only there, not in Canada.",
            explainMY: "အဖြေမှန်က ဩစတြေးလျ။ ကနေဒါတွင် မရှိ။"
        ),
        Item(
            id: "ot-escalator",
            ja: "ギネス記録の最も短いエスカレーターがある国は？",
            zh: "吉尼斯纪录中最短的自动扶梯在哪个国家？",
            en: "Which country has the Guinness shortest escalator?",
            my: "ဂင်းနစ် အတိုဆုံး စက်လှေကား ရှိသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "japan",
            choices: [
                ("usa", "アメリカ", "美国", "the United States", "အမေရိကန်"),
                ("japan", "日本", "日本", "Japan", "ဂျပန်"),
            ],
            explainJA: "正解は日本。川崎市の地下街にある短いエスカレーターがギネス記録。",
            explainZH: "正确答案是日本。川崎市地下街的短扶梯入了吉尼斯纪录。",
            explainEN: "Japan. A short underground escalator in Kawasaki holds the Guinness record.",
            explainMY: "အဖြေမှန်က ဂျပန်။ ခါဝါဆကိ မြေအောက် စက်လှေကား တိုသည်။"
        ),
        Item(
            id: "ot-hotel",
            ja: "ギネス認定の世界最古のホテルがある国は？",
            zh: "吉尼斯认证的世界最古老酒店位于哪里？",
            en: "Which country has the Guinness oldest hotel?",
            my: "ဂင်းနစ် ကမ္ဘာ့အဟောင်းဆုံး ဟိုတယ် ရှိသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "japan",
            choices: [
                ("italy", "イタリア", "意大利", "Italy", "အီတလီ"),
                ("japan", "日本", "日本", "Japan", "ဂျပန်"),
            ],
            explainJA: "正解は日本。山梨の西山温泉慶雲館がギネスの最古のホテル。",
            explainZH: "正确答案是日本。山梨县西山温泉庆云馆是吉尼斯认证的最古老酒店。",
            explainEN: "Japan. Nishiyama Onsen Keiunkan in Yamanashi is the Guinness oldest hotel.",
            explainMY: "အဖြေမှန်က ဂျပန်။ ယာမနရှိ ရှိ နိရှိယာမ အွန်ဆန် ခဲအွန်ခန်။"
        ),
        Item(
            id: "ot-russia-area",
            ja: "世界で一番面積が大きい国は？",
            zh: "世界上面积最大的国家是？",
            en: "Which country has the largest area?",
            my: "ကမ္ဘာ့ အကျယ်ဆုံးနိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "russia",
            choices: [
                ("canada", "カナダ", "加拿大", "Canada", "ကနေဒါ"),
                ("russia", "ロシア", "俄罗斯", "Russia", "ရုရှား"),
            ],
            explainJA: "正解はロシア。面積は世界一。カナダは2番目に広い。",
            explainZH: "正确答案是俄罗斯。面积世界第一。加拿大是第二大。",
            explainEN: "Russia is largest by area. Canada is second.",
            explainMY: "အဖြေမှန်က ရုရှား။ ကနေဒါက ဒုတိယ။"
        ),
        Item(
            id: "ot-vatican",
            ja: "世界で一番小さい独立国は？",
            zh: "世界上面积最小的独立国家是？",
            en: "What is the smallest independent country?",
            my: "ကမ္ဘာ့ အသေးဆုံး လွတ်လပ်သောနိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "vatican",
            choices: [
                ("vatican", "バチカン市国", "梵蒂冈", "Vatican City", "ဗာတီကန်"),
                ("monaco", "モナコ", "摩纳哥", "Monaco", "မိုနာကို"),
            ],
            explainJA: "正解はバチカン市国。ローマの中にある世界最小の独立国。モナコはとても小さいが、バチカンより広い。",
            explainZH: "正确答案是梵蒂冈。在罗马城里，是最小的独立国家。摩纳哥也很小，但比梵蒂冈大。",
            explainEN: "Vatican City is the smallest. Monaco is tiny but larger.",
            explainMY: "အဖြေမှန်က ဗာတီကန်။ မိုနာကိုက ပိုကျယ်သည်။"
        ),
        Item(
            id: "ot-canberra",
            ja: "オーストラリアの首都は？",
            zh: "澳大利亚的首都是？",
            en: "What is Australia’s capital?",
            my: "ဩစတြေးလျ မြို့တော်က ဘာလဲ။",
            answerID: "canberra",
            choices: [
                ("canberra", "キャンベラ", "堪培拉", "Canberra", "ကင်ဘာရာ"),
                ("sydney", "シドニー", "悉尼", "Sydney", "ဆစ်ဒနီ"),
            ],
            explainJA: "正解はキャンベラ。シドニーはいちばん有名な都市だけど、首都ではない。",
            explainZH: "正确答案是堪培拉。悉尼最有名，但不是首都。",
            explainEN: "Canberra is the capital. Sydney is famous, but not the capital.",
            explainMY: "အဖြေမှန်က ကင်ဘာရာ။ ဆစ်ဒနီက မြို့တော် မဟုတ်။"
        ),
        Item(
            id: "ot-ankara",
            ja: "トルコの首都は？",
            zh: "土耳其的首都是？",
            en: "What is Turkey’s capital?",
            my: "တူရကီ မြို့တော်က ဘာလဲ။",
            answerID: "ankara",
            choices: [
                ("istanbul", "イスタンブール", "伊斯坦布尔", "Istanbul", "အစ္စတန်ဘူလ်"),
                ("ankara", "アンカラ", "安卡拉", "Ankara", "အန်ကာရာ"),
            ],
            explainJA: "正解はアンカラ。イスタンブールは最大の都市だけど、首都はアンカラ。",
            explainZH: "正确答案是安卡拉。伊斯坦布尔是最大城市，首都是安卡拉。",
            explainEN: "Ankara is the capital. Istanbul is the largest city.",
            explainMY: "အဖြေမှန်က အန်ကာရာ။ အစ္စတန်ဘူလ်က မြို့ကြီး။"
        ),
        Item(
            id: "ot-giza-continent",
            ja: "ギザのピラミッドがある大陸は？",
            zh: "吉萨金字塔位于哪个大洲？",
            en: "On which continent are the Giza pyramids?",
            my: "ဂီဇာ ပိရမစ်က ဘယ်တိုက်ကြီးလဲ။",
            answerID: "africa",
            choices: [
                ("africa", "アフリカ", "非洲", "Africa", "အာဖရိက"),
                ("asia", "アジア", "亚洲", "Asia", "အာရှ"),
            ],
            explainJA: "正解はアフリカ。エジプトはアフリカ大陸。アジアではない。",
            explainZH: "正确答案是非洲。埃及在非洲，不在亚洲。",
            explainEN: "Africa. Egypt is in Africa, not Asia.",
            explainMY: "အဖြေမှန်က အာဖရိက။ အာရှ မဟုတ်။"
        ),
        Item(
            id: "ot-brazil-lang",
            ja: "ブラジルの公用語は？",
            zh: "巴西的官方语言是？",
            en: "What is Brazil’s official language?",
            my: "ဘရာဇီး ရုံးသုံးဘာသာက ဘာလဲ။",
            answerID: "portuguese",
            choices: [
                ("portuguese", "ポルトガル語", "葡萄牙语", "Portuguese", "ပေါ်တူဂီ"),
                ("spanish", "スペイン語", "西班牙语", "Spanish", "စပိန်"),
            ],
            explainJA: "正解はポルトガル語。南米の多くはスペイン語だが、ブラジルはポルトガル語。",
            explainZH: "正确答案是葡萄牙语。南美多数说西班牙语，巴西说葡萄牙语。",
            explainEN: "Portuguese. Most of South America speaks Spanish; Brazil does not.",
            explainMY: "အဖြေမှန်က ပေါ်တူဂီ။ စပိန် မဟုတ်။"
        ),
        Item(
            id: "ot-sahara",
            ja: "サハラ砂漠がある大陸は？",
            zh: "撒哈拉沙漠位于哪个大洲？",
            en: "On which continent is the Sahara?",
            my: "ဆာဟာရ သဲကန္တာရက ဘယ်တိုက်ကြီးလဲ။",
            answerID: "africa",
            choices: [
                ("asia", "アジア", "亚洲", "Asia", "အာရှ"),
                ("africa", "アフリカ", "非洲", "Africa", "အာဖရိက"),
            ],
            explainJA: "正解はアフリカ。サハラはアフリカ北部の巨大な砂漠。",
            explainZH: "正确答案是非洲。撒哈拉在非洲北部。",
            explainEN: "The Sahara is in northern Africa.",
            explainMY: "အဖြေမှန်က အာဖရိက။"
        ),
        Item(
            id: "ot-tajmahal",
            ja: "タージ・マハルがある国は？",
            zh: "泰姬陵位于哪个国家？",
            en: "Where is the Taj Mahal?",
            my: "တာ့ဂျ်မဟာလ် ရှိသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "india",
            choices: [
                ("india", "インド", "印度", "India", "အိန္ဒိယ"),
                ("egypt", "エジプト", "埃及", "Egypt", "အီဂျစ်"),
            ],
            explainJA: "正解はインド。アグラにある霊廟。ピラミッドはエジプト。",
            explainZH: "正确答案是印度。在阿格拉。金字塔在埃及。",
            explainEN: "India, in Agra. The pyramids are in Egypt.",
            explainMY: "အဖြေမှန်က အိန္ဒိယ။ အီဂျစ် မဟုတ်။"
        ),
        Item(
            id: "ot-pisa",
            ja: "ピサの斜塔がある国は？",
            zh: "比萨斜塔位于哪个国家？",
            en: "Where is the Leaning Tower of Pisa?",
            my: "ပီဆာ မျှော်စင် စောင်း ရှိသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "italy",
            choices: [
                ("france", "フランス", "法国", "France", "ပြင်သစ်"),
                ("italy", "イタリア", "意大利", "Italy", "အီတလီ"),
            ],
            explainJA: "正解はイタリア。ピサはイタリアの都市。フランスではない。",
            explainZH: "正确答案是意大利。比萨是意大利的城市，不在法国。",
            explainEN: "Italy. Pisa is an Italian city, not French.",
            explainMY: "အဖြေမှန်က အီတလီ။"
        ),
        Item(
            id: "ot-machu",
            ja: "マチュピチュがある国は？",
            zh: "马丘比丘位于哪个国家？",
            en: "Where is Machu Picchu?",
            my: "မာချူပီချူ ရှိသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "peru",
            choices: [
                ("peru", "ペルー", "秘鲁", "Peru", "ပီရူး"),
                ("mexico", "メキシコ", "墨西哥", "Mexico", "မက္ကဆီကို"),
            ],
            explainJA: "正解はペルー。インカの遺跡。メキシコの有名な遺跡はチチェン・イッツァなど。",
            explainZH: "正确答案是秘鲁。印加遗址。墨西哥更有名的是奇琴伊察等。",
            explainEN: "Peru. Mexico is known for sites like Chichen Itza.",
            explainMY: "အဖြေမှန်က ပီရူး။"
        ),
        Item(
            id: "ot-colosseum",
            ja: "コロッセオがある都市は？",
            zh: "罗马斗兽场位于哪个城市？",
            en: "In which city is the Colosseum?",
            my: "ကိုလိုဆီယမ် ရှိသော မြို့က ဘယ်ဟာလဲ။",
            answerID: "rome",
            choices: [
                ("rome", "ローマ", "罗马", "Rome", "ရောမ"),
                ("athens", "アテネ", "雅典", "Athens", "အေသင်"),
            ],
            explainJA: "正解はローマ。古代ローマの闘技場。アテネはギリシャの首都。",
            explainZH: "正确答案是罗马。是古罗马竞技场。雅典是希腊首都。",
            explainEN: "Rome. Athens is the capital of Greece.",
            explainMY: "အဖြေမှန်က ရောမ။ အေသင်က ဂရိ။"
        ),
        Item(
            id: "ot-liberty",
            ja: "ニューヨークの自由の女神像がある国は？",
            zh: "纽约自由女神像位于哪个国家？",
            en: "Where is the Statue of Liberty?",
            my: "လွတ်လပ်မှုရုပ်တု ရှိသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "usa",
            choices: [
                ("uk", "イギリス", "英国", "the United Kingdom", "ယူကေ"),
                ("usa", "アメリカ", "美国", "the United States", "အမေရိကန်"),
            ],
            explainJA: "正解はアメリカ。ニューヨーク港にある。フランスから贈られた像。",
            explainZH: "正确答案是美国。在纽约港，是法国赠送的。",
            explainEN: "The United States, in New York Harbor. France gave the statue.",
            explainMY: "အဖြေမှန်က အမေရိကန်။"
        ),
        Item(
            id: "ot-angkor",
            ja: "アンコール・ワットがある国は？",
            zh: "吴哥窟位于哪个国家？",
            en: "Where is Angkor Wat?",
            my: "အန်ကောဝပ် ရှိသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "cambodia",
            choices: [
                ("thai", "タイ", "泰国", "Thailand", "ထိုင်း"),
                ("cambodia", "カンボジア", "柬埔寨", "Cambodia", "ကမ္ဘောဒီးယား"),
            ],
            explainJA: "正解はカンボジア。シェムリアップ近郊。タイではない。",
            explainZH: "正确答案是柬埔寨。在暹粒附近，不在泰国。",
            explainEN: "Cambodia, near Siem Reap. Not Thailand.",
            explainMY: "အဖြေမှန်က ကမ္ဘောဒီးယား။"
        ),
        Item(
            id: "ot-paella",
            ja: "パエリアが生まれた国は？",
            zh: "西班牙海鲜饭起源于哪个国家？",
            en: "Where did paella originate?",
            my: "ပယ်အဲလျာ မွေးဖွားသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "spain",
            choices: [
                ("spain", "スペイン", "西班牙", "Spain", "စပိန်"),
                ("italy", "イタリア", "意大利", "Italy", "အီတလီ"),
            ],
            explainJA: "正解はスペイン。バレンシア地方の米料理。イタリアの料理ではない。",
            explainZH: "正确答案是西班牙。源自巴伦西亚。不是意大利菜。",
            explainEN: "Spain, from Valencia. Not Italy.",
            explainMY: "အဖြေမှန်က စပိန်။"
        ),
        Item(
            id: "ot-taco",
            ja: "タコスが生まれた国は？",
            zh: "塔可饼起源于哪个国家？",
            en: "Where did tacos originate?",
            my: "တာကို မွေးဖွားသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "mexico",
            choices: [
                ("peru", "ペルー", "秘鲁", "Peru", "ပီရူး"),
                ("mexico", "メキシコ", "墨西哥", "Mexico", "မက္ကဆီကို"),
            ],
            explainJA: "正解はメキシコ。とうもろこしのトルティーヤに具を包む。",
            explainZH: "正确答案是墨西哥。用玉米饼包馅。",
            explainEN: "Mexico. A tortilla with fillings.",
            explainMY: "အဖြေမှန်က မက္ကဆီကို။"
        ),
        Item(
            id: "ot-pho",
            ja: "フォーが代表的な料理として有名な国は？",
            zh: "河粉是哪个国家的代表性美食？",
            en: "Which country is pho famous from?",
            my: "ဖိုခေါက်ဆွဲ ကျော်ကြားသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "vietnam",
            choices: [
                ("thai", "タイ", "泰国", "Thailand", "ထိုင်း"),
                ("vietnam", "ベトナム", "越南", "Vietnam", "ဗီယက်နမ်"),
            ],
            explainJA: "正解はベトナム。牛肉や鶏のスープに平たい麺。タイの代表はパッタイなど。",
            explainZH: "正确答案是越南。扁米粉配牛汤或鸡汤。泰国更有名的是炒河粉等。",
            explainEN: "Vietnam. Thailand is better known for dishes like pad thai.",
            explainMY: "အဖြေမှန်က ဗီယက်နမ်။"
        ),
        Item(
            id: "ot-cheese",
            ja: "一般的なチーズの主な原料は？",
            zh: "常见奶酪的主要原料是？",
            en: "What is ordinary cheese mainly made from?",
            my: "ပုံမှန် ချိစ် အဓိက ပစ္စည်းက ဘာလဲ။",
            answerID: "milk",
            choices: [
                ("milk", "牛乳", "牛奶", "Cow’s milk", "နွားနို့"),
                ("flour", "小麦粉", "小麦粉", "Wheat flour", "ဂျုံမှုန့်"),
            ],
            explainJA: "正解は牛乳。牛や羊・山羊の乳を固める。小麦粉が主ではない。",
            explainZH: "正确答案是牛奶。用牛乳等凝固而成，不是面粉。",
            explainEN: "Milk, not wheat flour.",
            explainMY: "အဖြေမှန်က နွားနို့။ ဂျုံမှုန့် မဟုတ်။"
        ),
        Item(
            id: "ot-cacao",
            ja: "チョコレートの原料となるのは？",
            zh: "巧克力的原料是什么？",
            en: "What is chocolate made from?",
            my: "ချောကလက် ကုန်ကြမ်းက ဘာလဲ။",
            answerID: "cacao",
            choices: [
                ("coffee", "コーヒー豆", "咖啡豆", "Coffee beans", "ကော်ဖီစေ့"),
                ("cacao", "カカオ豆", "可可豆", "Cacao beans", "ကိုကိုးစေ့"),
            ],
            explainJA: "正解はカカオ豆。カカオを発酵・焙煎して作る。コーヒー豆ではない。",
            explainZH: "正确答案是可可豆。不是咖啡豆。",
            explainEN: "Cacao beans, not coffee beans.",
            explainMY: "အဖြေမှန်က ကိုကိုးစေ့။ ကော်ဖီ မဟုတ်။"
        ),
        Item(
            id: "ot-jupiter",
            ja: "太陽系で一番大きい惑星は？",
            zh: "太阳系最大的行星是？",
            en: "What is the largest planet in the solar system?",
            my: "နေအဖွဲ့ အကြီးဆုံး ဂြိုဟ်က ဘယ်ဟာလဲ။",
            answerID: "jupiter",
            choices: [
                ("jupiter", "木星", "木星", "Jupiter", "ဂျူပီတာ"),
                ("saturn", "土星", "土星", "Saturn", "စတန်"),
            ],
            explainJA: "正解は木星。太陽系でいちばん大きい。土星は輪が有名だが、木星より小さい。",
            explainZH: "正确答案是木星。太阳系最大。土星有环，但比木星小。",
            explainEN: "Jupiter is largest. Saturn is famous for rings, but smaller.",
            explainMY: "အဖြေမှန်က ဂျူပီတာ။ စတန်က ပိုသေး။"
        ),
        Item(
            id: "ot-mercury",
            ja: "太陽に一番近い惑星は？",
            zh: "距离太阳最近的行星是？",
            en: "Which planet is closest to the Sun?",
            my: "နေနှင့် အနီးဆုံး ဂြိုဟ်က ဘယ်ဟာလဲ။",
            answerID: "mercury",
            choices: [
                ("venus", "金星", "金星", "Venus", "ဗီးနပ်စ်"),
                ("mercury", "水星", "水星", "Mercury", "မာကျူရီ"),
            ],
            explainJA: "正解は水星。金星は明るく見えるが、太陽にいちばん近いのは水星。",
            explainZH: "正确答案是水星。金星看起来很亮，但离太阳最近的是水星。",
            explainEN: "Mercury. Venus looks bright, but Mercury is closer.",
            explainMY: "အဖြေမှန်က မာကျူရီ။ ဗီးနပ်စ်က ပိုလင်းသော်လည်း ပိုဝေး။"
        ),
        Item(
            id: "ot-aus-summer",
            ja: "オーストラリアで夏にあたるのは？",
            zh: "澳大利亚哪个月份属于夏季？",
            en: "Which month is summer in Australia?",
            my: "ဩစတြေးလျတွင် နွေရာသီ ဘယ်လလဲ။",
            answerID: "dec",
            choices: [
                ("dec", "12月", "12月", "December", "ဒီဇင်ဘာ"),
                ("june", "6月", "6月", "June", "ဇွန်"),
            ],
            explainJA: "正解は12月。南半球なので季節が逆。6月は冬。",
            explainZH: "正确答案是 12 月。南半球季节相反，6 月是冬天。",
            explainEN: "December. In the southern hemisphere, June is winter.",
            explainMY: "အဖြေမှန်က ဒီဇင်ဘာ။ ဇွန်က ဆောင်း။"
        ),
        Item(
            id: "ot-cheetah",
            ja: "陸上で最も速く走る動物は？",
            zh: "陆地上跑得最快的动物是？",
            en: "What is the fastest land animal?",
            my: "ကုန်းပေါ် အမြန်ဆုံးပြေးသော တိရစ္ဆာန်က ဘယ်ဟာလဲ။",
            answerID: "cheetah",
            choices: [
                ("lion", "ライオン", "狮子", "Lion", "ခြင်္သေ့"),
                ("cheetah", "チーター", "猎豹", "Cheetah", "ကျားသစ်ကွက်"),
            ],
            explainJA: "正解はチーター。短距離なら陸上でいちばん速い。ライオンは強いが、最速ではない。",
            explainZH: "正确答案是猎豹。短跑陆地最快。狮子强壮但不是最快。",
            explainEN: "The cheetah. Lions are strong, not the fastest.",
            explainMY: "အဖြေမှန်က ကျားသစ်ကွက်။"
        ),
        Item(
            id: "ot-whale-mammal",
            ja: "クジラは何の仲間？",
            zh: "鲸鱼属于哪类动物？",
            en: "What kind of animal is a whale?",
            my: "ဝေလငါးက ဘာအုပ်စုလဲ။",
            answerID: "mammal",
            choices: [
                ("mammal", "ほ乳類", "哺乳类", "A mammal", "နို့တိုက်သတ္တဝါ"),
                ("fish", "魚類", "鱼类", "A fish", "ငါး"),
            ],
            explainJA: "正解はほ乳類。肺で呼吸し、子どもに乳を与える。魚ではない。",
            explainZH: "正确答案是哺乳类。用肺呼吸、给幼鲸喂奶，不是鱼。",
            explainEN: "A mammal. It breathes air and nurses young, not a fish.",
            explainMY: "အဖြေမှန်က နို့တိုက်သတ္တဝါ။ ငါးမဟုတ်။"
        ),
        Item(
            id: "ot-bones",
            ja: "大人の骨の数は一般的に何本？",
            zh: "成年人通常有多少块骨头？",
            en: "How many bones does an adult usually have?",
            my: "လူကြီး အရိုး ပုံမှန် ဘယ်နှစ်ချောင်းလဲ။",
            answerID: "206",
            choices: [
                ("306", "306本", "306 块", "306", "၃၀၆"),
                ("206", "206本", "206 块", "206", "၂၀၆"),
            ],
            explainJA: "正解は206本。子どもはもっと多いが、大人ではくっついて約206本。",
            explainZH: "正确答案是 206 块。小孩更多，长大后愈合到大约 206。",
            explainEN: "About 206 in adults. Children have more that fuse later.",
            explainMY: "အဖြေမှန်က ၂၀၆။"
        ),
        Item(
            id: "ot-vacuum-sound",
            ja: "音は真空の中を伝わる？",
            zh: "声音能在真空中传播吗？",
            en: "Does sound travel in a vacuum?",
            my: "အသံ အလွတ်အတွင်း ပျံ့သလား။",
            answerID: "no",
            choices: [
                ("no", "伝わらない", "不能传播", "It does not travel", "မပျံ့"),
                ("yes", "伝わる", "能传播", "It travels", "ပျံ့သည်"),
            ],
            explainJA: "正解は伝わらない。音は空気などの振動。真空には媒介がない。",
            explainZH: "正确答案是不能。声音靠空气等介质振动，真空里没有介质。",
            explainEN: "It does not. Sound needs a medium; a vacuum has none.",
            explainMY: "အဖြေမှန်က မပျံ့။ ကြားခံ မရှိ။"
        ),
        Item(
            id: "ot-olympics-greece",
            ja: "古代オリンピックが始まったのは現在のどの国？",
            zh: "古代奥林匹克运动会发源于今天的哪个国家？",
            en: "Where did the ancient Olympics begin, in today’s countries?",
            my: "ရှေးအိုလံပစ် စတင်သော ယခုနိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "greece",
            choices: [
                ("italy", "イタリア", "意大利", "Italy", "အီတလီ"),
                ("greece", "ギリシャ", "希腊", "Greece", "ဂရိ"),
            ],
            explainJA: "正解はギリシャ。オリンピアで始まった。イタリアのローマ五輪とは別。",
            explainZH: "正确答案是希腊。起源于奥林匹亚。和意大利的罗马奥运会不是一回事。",
            explainEN: "Greece, at Olympia. Not Italy.",
            explainMY: "အဖြေမှန်က ဂရိ။"
        ),
        Item(
            id: "ot-moon-1969",
            ja: "人類が初めて月面に降り立った年は？",
            zh: "人类首次登上月球是哪一年？",
            en: "When did humans first land on the Moon?",
            my: "လူသား လပေါ် ပထမဆုံး ဆင်းသည့် နှစ်က ဘယ်နှစ်လဲ။",
            answerID: "1969",
            choices: [
                ("1969", "1969年", "1969年", "1969", "၁၉၆၉"),
                ("1979", "1979年", "1979年", "1979", "၁၉၇၉"),
            ],
            explainJA: "正解は1969年。アポロ11号。1979年ではない。",
            explainZH: "正确答案是 1969 年。阿波罗 11 号。不是 1979 年。",
            explainEN: "1969, Apollo 11. Not 1979.",
            explainMY: "အဖြေမှန်က ၁၉၆၉။"
        ),
        Item(
            id: "ot-great-wall",
            ja: "万里の長城がある国は？",
            zh: "万里长城位于哪个国家？",
            en: "Where is the Great Wall?",
            my: "မဟာတံတိုင်း ရှိသော နိုင်ငံက ဘယ်ဟာလဲ။",
            answerID: "china",
            choices: [
                ("japan", "日本", "日本", "Japan", "ဂျပန်"),
                ("china", "中国", "中国", "China", "တရုတ်"),
            ],
            explainJA: "正解は中国。日本には万里の長城はない。",
            explainZH: "正确答案是中国。日本没有长城。",
            explainEN: "China. Japan does not have the Great Wall.",
            explainMY: "အဖြေမှန်က တရုတ်။"
        ),
        Item(
            id: "ot-moai",
            ja: "巨大なモアイ像で有名な島は？",
            zh: "以巨大摩艾石像闻名的是哪个岛？",
            en: "Which island is famous for giant moai statues?",
            my: "မိုအိုင်ရုပ်တု ကျော်ကြားသော ကျွန်းက ဘယ်ဟာလဲ။",
            answerID: "easter",
            choices: [
                ("easter", "イースター島", "复活节岛", "Easter Island", "အီစတာကျွန်း"),
                ("bali", "バリ島", "巴厘岛", "Bali", "ဘာလီ"),
            ],
            explainJA: "正解はイースター島（ラパ・ヌイ）。チリ領。バリ島はインドネシアの島で、モアイではない。",
            explainZH: "正确答案是复活节岛（拉帕努伊）。属于智利。巴厘岛在印尼，没有摩艾。",
            explainEN: "Easter Island (Rapa Nui), Chile. Bali is in Indonesia and has no moai.",
            explainMY: "အဖြေမှန်က အီစတာကျွန်း။ ဘာလီ မဟုတ်။"
        ),
    ]
}
