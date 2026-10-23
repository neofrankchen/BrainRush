import Foundation

/// 難問2択：雑学の二択クイズ。ひっかけ問題とは別ファイル。
enum HardChoiceBank {
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
                task: .hardChoice,
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
            id: "hard-hyogo-bread",
            ja: "兵庫県の人の朝食は「ご飯派」と「パン派」どちらが多い？",
            zh: "兵库县的人早餐更常吃米饭，还是面包？",
            en: "In Hyogo, do more people eat rice or bread for breakfast?",
            my: "ဟယောဂိုတွင် နံနက်စာ ထမင်းများသလား၊ ပေါင်မုန့်များသလား။",
            answerID: "bread",
            choices: [
                ("rice", "ご飯", "米饭", "Rice", "ထမင်း"),
                ("bread", "パン", "面包", "Bread", "ပေါင်မုန့်"),
            ],
            explainJA: "正解はパン。日本全体ではほぼ半々だが、兵庫県では約8割がパン派。神戸は港町でパン食が早く根付いた。",
            explainZH: "正确答案是面包。日本整体几乎一半一半，但兵库县约八成吃面包。神户是港口城市，面包文化很早就扎根了。",
            explainEN: "Bread. Japan is split about evenly, but about 80% in Hyogo choose bread. Kobe’s port brought bakeries in early.",
            explainMY: "အဖြေမှန်က ပေါင်မုန့်။ ဂျပန်တစ်နိုင်ငံလုံး နီးပါးညီသော်လည်း ဟယောဂိုတွင် ၈၀% ခန့် ပေါင်မုန့်စားသည်။"
        ),
        Item(
            id: "hard-tokyo-ny",
            ja: "東京の人口はニューヨークの人口より多い？ 少ない？",
            zh: "东京的人口比纽约多，还是少？",
            en: "Is Tokyo’s population larger or smaller than New York’s?",
            my: "တိုကျိုလူဦးရေက နယူးယောက်ထက် များသလား၊ နည်းသလား။",
            answerID: "fewer",
            choices: [
                ("fewer", "少ない", "更少", "Smaller", "နည်းသည်"),
                ("more", "多い", "更多", "Larger", "များသည်"),
            ],
            explainJA: "正解は少ない。東京都は約1339万人、ニューヨーク州は約1945万人。面積はニューヨークの方がずっと広く、人口密度は東京の方が高い。",
            explainZH: "正确答案是更少。东京都约 1339 万人，纽约州约 1945 万人。纽约面积大得多，但东京人口密度更高。",
            explainEN: "Smaller. Tokyo Metropolis is about 13.4 million; New York State is about 19.5 million. Tokyo is far denser.",
            explainMY: "အဖြေမှန်က နည်းသည်။ တိုကျို မြို့တော် ၁၃.၄ သန်းခန့်၊ နယူးယောက်ပြည်နယ် ၁၉.၅ သန်းခန့်။ တိုကျိုက ပိုသိပ်သည်းသည်။"
        ),
        Item(
            id: "hard-togan",
            ja: "ウリ科の野菜「冬瓜」の旬はいつ？",
            zh: "葫芦科蔬菜「冬瓜」的当季是什么时候？",
            en: "When is winter melon (tōgan) in season?",
            my: "「冬瓜」 ရဲ့ ရာသီက ဘယ်အချိန်လဲ။",
            answerID: "summer",
            choices: [
                ("winter", "冬", "冬天", "Winter", "ဆောင်း"),
                ("summer", "夏", "夏天", "Summer", "နွေ"),
            ],
            explainJA: "正解は夏。日本語の「冬瓜」は漢字どおり冬の瓜に見えるが、涼しい場所で冬まで保存できるからこの名。旬は夏。字面の季節にだまされない。",
            explainZH: "正确答案是夏天。日语「冬瓜」两个汉字看起来像冬天的瓜，其实是因为阴凉处能存到冬天才叫这个名字。当季是夏天，别被字面骗了。",
            explainEN: "Summer. The kanji 冬瓜 look like “winter melon,” but the name is because it keeps until winter. Peak season is summer.",
            explainMY: "အဖြေမှန်က နွေ။ ဂျပန် 「冬瓜」 ခန်ဂျိက ဆောင်းဖရုံလို မြင်ရသည်။ ဆောင်းအထိ သိမ်းနိုင်လို့ နာမည်ပေးသည်။ ရာသီက နွေ။"
        ),
        Item(
            id: "hard-signal-right",
            ja: "道路の信号機の一番右の色は何色？",
            zh: "马路交通灯最右边是什么颜色？",
            en: "What color is on the far right of a Japanese traffic light?",
            my: "ဂျပန်လမ်းမီး အညာဘက်စွန်းက ဘာအရောင်လဲ။",
            answerID: "red",
            choices: [
                ("blue", "青色", "蓝色", "Blue / green", "အပြာ"),
                ("red", "赤色", "红色", "Red", "အနီ"),
            ],
            explainJA: "正解は赤。日本の信号は左から青・黄・赤。左側通行なので、いちばん外側（右）を赤にすると街路樹に隠れにくい。",
            explainZH: "正确答案是红色。日本信号灯从左到右是绿、黄、红。靠左行驶时，最外侧的红灯不容易被行道树挡住。",
            explainEN: "Red. Japanese lights run blue-yellow-red left to right, so the outer (right) lamp stays visible beside trees.",
            explainMY: "အဖြေမှန်က အနီ။ ဂျပန်မီးက ဘယ်မှ စိမ်း-ဝါ-နီ။ ညာဘက်စွန်း အနီက သစ်ပင်များနှင့် မပိတ်လွယ်။"
        ),
        Item(
            id: "hard-sunrise",
            ja: "太陽が昇ってくるのは、どちらの方角から？",
            zh: "太阳从哪个方向升起？",
            en: "From which direction does the sun rise?",
            my: "နေက ဘယ်ဘက်က ထွက်သလဲ။",
            answerID: "east",
            choices: [
                ("west", "西", "西", "West", "အနောက်"),
                ("east", "東", "东", "East", "အရှေ့"),
            ],
            explainJA: "正解は東。地球が時計と逆向きに回っているので、太陽は東から昇り西へ沈む。",
            explainZH: "正确答案是东。地球自转方向和时钟相反，所以太阳从东边升起、西边落下。",
            explainEN: "East. Earth rotates opposite a clock hand, so the sun rises in the east and sets in the west.",
            explainMY: "အဖြေမှန်က အရှေ့။ ကမ္ဘာလည်ပတ်မှုကြောင့် နေက အရှေ့မှထွက် အနောက်သို့ ဝင်သည်။"
        ),
        Item(
            id: "hard-t-rex-speed",
            ja: "ティラノサウルスの歩く速度はどのくらい？",
            zh: "霸王龙走路大概有多快？",
            en: "How fast did a T. rex walk?",
            my: "တီရက်ခ်စ် လမ်းလျှောက်နှုန်းက ဘယ်လောက်လဲ။",
            answerID: "human",
            choices: [
                ("human", "人間の歩く速度", "跟人走路差不多", "About a human walking", "လူလမ်းလျှောက်နှုန်း"),
                ("car", "車が走る速度", "跟车速差不多", "About a car", "ကားနှုန်း"),
            ],
            explainJA: "正解は人間の歩く速度（約4.8km/h）。体のわりに足が細いので、車並みに走ると骨が折れると考えられる。",
            explainZH: "正确答案是跟人走路差不多（约 4.8 公里/小时）。腿相对身体太细，跑到车速骨头会断。",
            explainEN: "About a human walk, ~4.8 km/h. Its legs were too thin for car-like speeds without breaking.",
            explainMY: "အဖြေမှန်က လူလမ်းလျှောက်နှုန်း (~၄.၈ km/h)။ ခြေထောက်ပါးလွန်းလို့ ကားနှုန်းပြေးရင် အရိုးကျိုးနိုင်သည်။"
        ),
        Item(
            id: "hard-worker-ant",
            ja: "働きアリの性別は、オスとメスどちら？",
            zh: "工蚁的性别是雄还是雌？",
            en: "Are worker ants male or female?",
            my: "အလုပ်သမားပုရွက်ဆိတ်က အထီးလား၊ အမလား။",
            answerID: "female",
            choices: [
                ("male", "オス", "雄", "Male", "အထီး"),
                ("female", "メス", "雌", "Female", "အမ"),
            ],
            explainJA: "正解はメス。卵を産むのは女王だけ。働きアリはすべてメス。オスは交尾のために生まれ、受精していない卵からできる。",
            explainZH: "正确答案是雌。只有蚁后产卵，工蚁全是雌性。雄蚁为交配而生，来自未受精的卵。",
            explainEN: "Female. Only the queen lays eggs; workers are all female. Males exist to mate and hatch from unfertilized eggs.",
            explainMY: "အဖြေမှန်က အမ။ ဥဥသည် ဘုရင်မသာ။ အလုပ်သမားအားလုံး အမ။ အထီးက မိတ်လိုက်ရန် မြေသြဇာမရသောဥမှ။"
        ),
        Item(
            id: "hard-adult-age",
            ja: "「成人」は何歳から？",
            zh: "「成年」从几岁开始？",
            en: "From what age is someone an adult in Japan?",
            my: "ဂျပန်တွင် အရွယ်ရောက်သည် ဘယ်နှစ်မှလဲ။",
            answerID: "eighteen",
            choices: [
                ("eighteen", "18歳", "18岁", "18", "၁၈"),
                ("twenty", "20歳", "20岁", "20", "၂၀"),
            ],
            explainJA: "正解は18歳。以前は20歳だったが、2022年4月から18歳成人になった。",
            explainZH: "正确答案是 18 岁。以前是 20 岁，2022 年 4 月起改为 18 岁成年。",
            explainEN: "18. It used to be 20; since April 2022 Japan’s age of adulthood is 18.",
            explainMY: "အဖြေမှန်က ၁၈။ အရင်က ၂၀၊ ၂၀၂၂ ဧပြီမှစ၍ ၁၈ ဖြစ်သည်။"
        ),
        Item(
            id: "hard-feb11",
            ja: "2月11日は何の日？",
            zh: "2 月 11 日是什么日子？",
            en: "What day is February 11 in Japan?",
            my: "ဖေဖော်ဝါရီ ၁၁ က ဘာနေ့လဲ။",
            answerID: "founding",
            choices: [
                ("constitution", "憲法記念日", "宪法纪念日", "Constitution Day", "ဖွဲ့စည်းပုံနေ့"),
                ("founding", "建国記念日", "建国纪念日", "National Foundation Day", "နိုင်ငံတည်ထောင်နေ့"),
            ],
            explainJA: "正解は建国記念日。憲法記念日は5月3日。明確な建国日がないため、日本神話をもとに2月11日になった。",
            explainZH: "正确答案是建国纪念日。宪法纪念日是 5 月 3 日。没有明确建国日，所以依日本神话定在 2 月 11 日。",
            explainEN: "National Foundation Day. Constitution Day is May 3. Japan has no exact founding date, so myth set Feb 11.",
            explainMY: "အဖြေမှန်က နိုင်ငံတည်ထောင်နေ့။ ဖွဲ့စည်းပုံနေ့က မေ ၃။ တည်ထောင်ရက် မသေချာလို့ ဒဏ္ဍာရီအရ ဖေဖော်ဝါရီ ၁၁။"
        ),
        Item(
            id: "hard-polar-bear-skin",
            ja: "シロクマの皮膚の色は何色？",
            zh: "北极熊的皮肤是什么颜色？",
            en: "What color is a polar bear’s skin?",
            my: "ဝင်ရိုးစွန်းဝက်ဝံ အရေပြား ဘာအရောင်လဲ။",
            answerID: "black",
            choices: [
                ("white", "白色", "白色", "White", "အဖြူ"),
                ("black", "黒色", "黑色", "Black", "အမည်း"),
            ],
            explainJA: "正解は黒。毛は透明で、光の反射で白く見える。黒い皮膚は熱を逃がしにくくする。",
            explainZH: "正确答案是黑色。毛其实是透明的，反射光才显白。黑皮肤有助于留住热量。",
            explainEN: "Black. The fur is clear and looks white by reflection. Dark skin helps hold heat.",
            explainMY: "အဖြေမှန်က အမည်း။ အမွေးက ဖောက်ထွင်းပြီး အလင်းပြန်လို့ ဖြူမြင်ရသည်။ အမည်းအရေက အပူမလွင့်အောင် ကူသည်။"
        ),
        Item(
            id: "hard-eve",
            ja: "クリスマスイブの「イブ」とは、どういう意味？",
            zh: "「イブ」（eve）是什么意思？",
            en: "What does “eve” in Christmas Eve mean?",
            my: "Christmas Eve ရဲ့ “eve” က ဘာအဓိပ္ပာယ်လဲ။",
            answerID: "night-before",
            choices: [
                ("day-before", "前日", "前一天", "The day before", "အရင်နေ့"),
                ("night-before", "前夜", "前夜", "The night before", "အရင်ည"),
            ],
            explainJA: "正解は前夜。イブは「前日」ではなく「前夜」。日没後からがクリスマスイブ。",
            explainZH: "正确答案是前夜。eve 不是「前一天」，而是「前一夜」，从日落之后才算圣诞夜。",
            explainEN: "The night before, not the whole previous day. Eve starts after sundown.",
            explainMY: "အဖြေမှန်က အရင်ည။ တစ်နေ့လုံး အရင်နေ့ မဟုတ်၊ နေဝင်ပြီးမှ ခရစ္စမတ်ည ဖြစ်သည်။"
        ),
        Item(
            id: "hard-leap-year",
            ja: "うるう年は何日ある？",
            zh: "闰年有多少天？",
            en: "How many days are in a leap year?",
            my: "ရက်ထပ်နှစ်တွင် ရက်ဘယ်နှစ်ရက်ရှိသလဲ။",
            answerID: "366",
            choices: [
                ("364", "364日", "364 天", "364", "၃၆၄"),
                ("366", "366日", "366 天", "366", "၃၆၆"),
            ],
            explainJA: "正解は366日。4年に1度、2月が29日になり1日増える。",
            explainZH: "正确答案是 366 天。每四年一次，二月变成 29 天，全年多一天。",
            explainEN: "366. Every fourth year February has 29 days, so the year gains one day.",
            explainMY: "အဖြေမှန်က ၃၆၆။ လေးနှစ်တစ်ကြိမ် ဖေဖော်ဝါရီ ၂၉ ရက်ဖြစ်ပြီး တစ်ရက်ပိုသည်။"
        ),
        Item(
            id: "hard-holmes-author",
            ja: "シャーロック・ホームズが登場する小説を書いた人は？",
            zh: "写出福尔摩斯的人是谁？",
            en: "Who wrote the Sherlock Holmes stories?",
            my: "ရှာလော့ခ် ဟုမ်းစ်ကို ရေးသူက ဘယ်သူလဲ။",
            answerID: "doyle",
            choices: [
                ("doyle", "コナン・ドイル", "柯南·道尔", "Arthur Conan Doyle", "ကိုနန် ဒွိုင်းလ်"),
                ("christie", "アガサ・クリスティ", "阿加莎·克里斯蒂", "Agatha Christie", "အဂသာ ခရစ္စတီ"),
            ],
            explainJA: "正解はコナン・ドイル。クリスティはポアロやミス・マープルの作者。",
            explainZH: "正确答案是柯南·道尔。阿加莎·克里斯蒂写的是波洛和马普尔小姐。",
            explainEN: "Arthur Conan Doyle. Christie created Poirot and Miss Marple.",
            explainMY: "အဖြေမှန်က ကိုနန် ဒွိုင်းလ်။ ခရစ္စတီက ပွာရိုနှင့် မာပယ်တို့ကို ရေးသည်။"
        ),
        Item(
            id: "hard-human-hibernate",
            ja: "人間は冬眠できる？",
            zh: "人类能冬眠吗？",
            en: "Can humans hibernate?",
            my: "လူက ဆောင်းခိုနိုင်သလား။",
            answerID: "no",
            choices: [
                ("yes", "できる", "能", "Yes", "နိုင်သည်"),
                ("no", "できない", "不能", "No", "မနိုင်ပါ"),
            ],
            explainJA: "正解はできない。熊は冬眠できる恒温動物だが、人間が同じ状態になると命にかかわる。",
            explainZH: "正确答案是不能。熊虽是恒温动物还能冬眠，人进入那种状态会有生命危险。",
            explainEN: "No. Bears can hibernate; a human in that state would be in danger.",
            explainMY: "အဖြေမှန်က မနိုင်ပါ။ ဝက်ဝံ ဆောင်းခိုနိုင်သော်လည်း လူအနေအထားရောက်ရင် အသက်အန္တရာယ်ရှိသည်။"
        ),
        Item(
            id: "hard-pc-name",
            ja: "「パソコン」の正式名称はどれ？",
            zh: "「パソコン」的正式名称是哪个？",
            en: "What is the full name of “pasokon” (PC)?",
            my: "「パソコン」 ရဲ့ အမည်အပြည့်အစုံက ဘာလဲ။",
            answerID: "personal",
            choices: [
                ("personal", "パーソナル・コンピューター", "个人计算机", "Personal computer", "Personal computer"),
                ("personalize", "パーソナライズ・コンピューター", "个性化计算机", "Personalized computer", "Personalized computer"),
            ],
            explainJA: "正解はパーソナル・コンピューター。個人向けのコンピューターだからこの名。",
            explainZH: "正确答案是个人计算机（personal computer）。因为是面向个人的电脑。",
            explainEN: "Personal computer — a computer meant for one person.",
            explainMY: "အဖြေမှန်က personal computer။ တစ်ဦးချင်းသုံး ကွန်ပျူတာဖြစ်လို့။"
        ),
        Item(
            id: "hard-coins",
            ja: "日本の硬貨はどこで作られている？",
            zh: "日本硬币在哪里制造？",
            en: "Where are Japanese coins made?",
            my: "ဂျပန်ဒင်္ဂါးကို ဘယ်မှာလုပ်သလဲ။",
            answerID: "mint",
            choices: [
                ("mint", "造幣局", "造币局", "The Mint", "ဒင်္ဂါးရုံ"),
                ("bank", "日本銀行", "日本银行", "The Bank of Japan", "ဂျပန်ဘဏ်"),
            ],
            explainJA: "正解は造幣局。硬貨は政府発行・造幣局で製造。紙幣は日本銀行発行・印刷局で製造。どちらもその後日銀へ。",
            explainZH: "正确答案是造币局。硬币由政府发行、造币局制造；纸币由日本银行发行、印刷局印刷，之后都交日银。",
            explainEN: "The Mint. Coins are made there; banknotes are printed for the Bank of Japan.",
            explainMY: "အဖြေမှန်က ဒင်္ဂါးရုံ။ ဒင်္ဂါးကို အစိုးရထုတ်၊ ဒင်္ဂါးရုံလုပ်သည်။ ငွေစက္ကူက ဂျပန်ဘဏ်ထုတ်သည်။"
        ),
        Item(
            id: "hard-first-olympics",
            ja: "夏季オリンピックの第一回開催地はどこ？",
            zh: "第一届夏季奥运会在哪里举办？",
            en: "Where was the first Summer Olympics held?",
            my: "ပထမဆုံး နွေရာသီအိုလံပစ် ဘယ်မှာကျင်းပသလဲ။",
            answerID: "athens",
            choices: [
                ("athens", "アテネ（ギリシャ）", "雅典（希腊）", "Athens, Greece", "အေသင်၊ ဂရိ"),
                ("chamonix", "シャモニー・モンブラン（フランス）", "霞慕尼（法国）", "Chamonix, France", "ရှာမိုနီ၊ ပြင်သစ်"),
            ],
            explainJA: "正解はアテネ（1896年）。シャモニーは第一回冬季オリンピックの開催地。",
            explainZH: "正确答案是雅典（1896 年）。霞慕尼是第一届冬奥会的举办地。",
            explainEN: "Athens in 1896. Chamonix hosted the first Winter Olympics.",
            explainMY: "အဖြေမှန်က အေသင် (၁၈၉၆)။ ရှာမိုနီက ပထမဆုံး ဆောင်းရာသီအိုလံပစ်။"
        ),
        Item(
            id: "hard-china-tz",
            ja: "中国は日本と時差はある？ ない？",
            zh: "中国和日本有时差吗？",
            en: "Is there a time difference between China and Japan?",
            my: "တရုတ်နှင့် ဂျပန် အချိန်ကွာသလား။",
            answerID: "yes",
            choices: [
                ("yes", "ある", "有", "Yes", "ရှိသည်"),
                ("no", "ない", "没有", "No", "မရှိပါ"),
            ],
            explainJA: "正解はある。日本が朝9時のとき、中国は朝8時。1時間の時差。",
            explainZH: "正确答案是有。日本早上 9 点时，中国是早上 8 点，差 1 小时。",
            explainEN: "Yes. When it is 9:00 in Japan it is 8:00 in China — one hour.",
            explainMY: "အဖြေမှန်က ရှိသည်။ ဂျပန် မနက် ၉ နာရီတွင် တရုတ်က ၈ နာရီ၊ တစ်နာရီကွာသည်။"
        ),
        Item(
            id: "hard-hair-growth",
            ja: "髪の毛が1cm伸びるのにかかる期間は？",
            zh: "头发长 1 厘米大概要多久？",
            en: "How long does hair take to grow 1 cm?",
            my: "ဆံပင် ၁ စင်တီမီတာ ကြီးရန် ဘယ်လောက်ကြာသလဲ။",
            answerID: "month",
            choices: [
                ("week", "約1週間", "大约一周", "About a week", "တစ်ပတ်ခန့်"),
                ("month", "約1ヶ月", "大约一个月", "About a month", "တစ်လခန့်"),
            ],
            explainJA: "正解は約1ヶ月。1日約0.3mmなので、1cmには約1ヶ月かかる。",
            explainZH: "正确答案是大约一个月。一天大约长 0.3 毫米，1 厘米大约要一个月。",
            explainEN: "About a month. Hair grows roughly 0.3 mm a day, so 1 cm takes about 30 days.",
            explainMY: "အဖြေမှန်က တစ်လခန့်။ တစ်နေ့ ၀.၃ မီလီမီတာခန့်၊ ၁ စင်တီမီတာ တစ်လနီးပါး။"
        ),
        Item(
            id: "hard-sea-rescue",
            ja: "海で救助を求めたい時は、どこに電話する？",
            zh: "在海上求救该打哪个电话？",
            en: "Which number do you call for rescue at sea in Japan?",
            my: "ပင်လယ်တွင် ကယ်ဆယ်ရေး ဘယ်နံပါတ်ခေါ်မလဲ။",
            answerID: "118",
            choices: [
                ("118", "118番", "118", "118", "၁၁၈"),
                ("119", "119番", "119", "119", "၁၁၉"),
            ],
            explainJA: "正解は118番。陸上の救急は119、海は海上保安庁の118。",
            explainZH: "正确答案是 118。陆上急救打 119，海上要打海上保安厅的 118。",
            explainEN: "118. 119 is land emergency; 118 reaches Japan Coast Guard at sea.",
            explainMY: "အဖြေမှန်က ၁၁၈။ ကုန်းပေါ် ၁၁၉၊ ပင်လယ်ကမ်းခြေ ကာကွယ်ရေး ၁၁၈။"
        ),
        Item(
            id: "hard-hospital-clinic",
            ja: "「病院」と「クリニック」の違いはなに？",
            zh: "「医院」和「诊所」的差别是什么？",
            en: "What is the difference between a hospital and a clinic in Japan?",
            my: "「病院」 နှင့် 「クリニック」 ဘာကွာသလဲ။",
            answerID: "beds",
            choices: [
                ("beds", "ベッドの数", "床位数", "Number of beds", "ကုတင်အရေအတွက်"),
                ("staff", "医者と看護師の数", "医生和护士人数", "Number of doctors and nurses", "ဆရာဝန်နှင့် သူနာပြုအရေအတွက်"),
            ],
            explainJA: "正解はベッドの数。病院は20床以上、クリニックは19床以下。クリニックは入院設備がないことも多い。",
            explainZH: "正确答案是床位数。医院 20 张床以上，诊所 19 张以下。诊所常常没有住院部。",
            explainEN: "Bed count. A hospital has 20+ beds; a clinic has 19 or fewer, and often no inpatient ward.",
            explainMY: "အဖြေမှန်က ကုတင်အရေအတွက်။ ဆေးရုံ ၂၀ နှင့်အထက်၊ ဆေးခန်း ၁၉ နှင့်အောက်။"
        ),
        Item(
            id: "hard-stiff-shoulder",
            ja: "「肩がこる」という言葉を初めて使ったのは誰？",
            zh: "「肩膀酸」这句日语最早是谁用的？",
            en: "Who first used the Japanese phrase “kata ga koru” (stiff shoulders)?",
            my: "「肩がこる」 ကို ပထမဆုံး သုံးသူက ဘယ်သူလဲ။",
            answerID: "soseki",
            choices: [
                ("genpaku", "杉田玄白", "杉田玄白", "Sugita Genpaku", "ဆုဂိတ ဂန်းပါကု"),
                ("soseki", "夏目漱石", "夏目漱石", "Natsume Sōseki", "နာဆုမဲ ဆိုဆဲကိ"),
            ],
            explainJA: "正解は夏目漱石。日本語で肩がだるく痛いことを「肩がこる」と言う。小説『門』で使われ、それ以前は「肩が張る」などが多かった。",
            explainZH: "正确答案是夏目漱石。日语里肩膀发僵发酸叫「肩がこる」，现在很常用。他在小说《门》里这样写，之前多说「肩が張る」。",
            explainEN: "Natsume Sōseki. Japanese 肩がこる means stiff, aching shoulders. He used it in The Gate; before that people often said 肩が張る.",
            explainMY: "အဖြေမှန်က နာဆုမဲ ဆိုဆဲကိ။ ဂျပန် 「肩がこる」 က ပခုံးတောင့်ခြင်း။ ဝတ္ထု 「門」 တွင် သုံးသည်။ အရင်က 「肩が張る」。"
        ),
        Item(
            id: "hard-otter-stone",
            ja: "ラッコがとてもこだわっているものはなに？",
            zh: "海獭特别讲究的是什么？",
            en: "What are sea otters especially picky about?",
            my: "ပင်လယ်ဖျံ အလွန်ရွေးချယ်သောအရာက ဘာလဲ။",
            answerID: "stone",
            choices: [
                ("sleep", "夜眠る場所", "晚上睡觉的地方", "Where they sleep", "အိပ်ရာနေရာ"),
                ("stone", "貝を割るための石", "砸开贝壳的石头", "The stone they use to crack shells", "ခရုခွံခွဲသော ကျောက်"),
            ],
            explainJA: "正解は貝を割る石。気に入った石をなくすと、次の石が見つかるまで食事できないこともある。",
            explainZH: "正确答案是砸贝壳的石头。丢了中意的石头，找到下一块之前可能吃不成饭。",
            explainEN: "The rock they use to crack shells. Lose a favorite stone and they may not eat until they find another.",
            explainMY: "အဖြေမှန်က ခရုခွံခွဲသော ကျောက်။ အကြိုက်ကျောက် ပျောက်ရင် နောက်တစ်လုံးမတွေ့မချင်း မစားနိုင်။"
        ),
        Item(
            id: "hard-omocha-machi",
            ja: "日本に実在する地名はどちら？",
            zh: "日本真实存在的地名是哪一个？",
            en: "Which of these is a real place name in Japan?",
            my: "ဂျပန်တွင် တကယ်ရှိသော နေရာအမည်က ဘယ်ဟာလဲ။",
            answerID: "toy-town",
            choices: [
                ("toy-town", "おもちゃのまち", "玩具之町", "Omocha no Machi (Toy Town)", "အရုပ်မြို့"),
                ("game-town", "ゲームのまち", "游戏之町", "Game no Machi", "ဂိမ်းမြို့"),
            ],
            explainJA: "正解はおもちゃのまち。栃木県壬生町の地名で、玩具工場が集まったことからついた。",
            explainZH: "正确答案是「おもちゃのまち」。在栃木县壬生町，因为玩具工厂聚集而得名。",
            explainEN: "Omocha no Machi in Mibu, Tochigi, named after a cluster of toy factories.",
            explainMY: "အဖြေမှန်က အရုပ်မြို့။ တိုချိဂိခရိုင် မိဘုမြို့တွင် အရုပ်စက်ရုံများ စုဝေးလို့ နာမည်ရသည်။"
        ),
        Item(
            id: "hard-drink-expiry",
            ja: "ペットボトルと缶の飲み物、賞味期限が長いのはどちら？",
            zh: "瓶装饮料和罐装饮料，哪个保质期更长？",
            en: "Which lasts longer: bottled drinks or canned drinks?",
            my: "ပုလင်းနှင့် သံဘူးအသောက်၊ သက်တမ်းပိုရှည်တာ ဘယ်ဟာလဲ။",
            answerID: "can",
            choices: [
                ("bottle", "ペットボトル", "塑料瓶", "Plastic bottle", "ပလတ်စတစ်ပုလင်း"),
                ("can", "缶", "易拉罐", "Can", "သံဘူး"),
            ],
            explainJA: "正解は缶。ペットボトルはごくわずかな空気が入りうるので、缶より賞味期限が短い。",
            explainZH: "正确答案是易拉罐。塑料瓶可能微微透气，所以保质期比罐装短。",
            explainEN: "Cans. Bottles can let in a tiny bit of air, so their best-before date is shorter.",
            explainMY: "အဖြေမှန်က သံဘူး။ ပုလင်းက လေအနည်းငယ်ဝင်နိုင်လို့ သက်တမ်းပိုတိုသည်။"
        ),
        Item(
            id: "hard-pluto-tag",
            ja: "ディズニーのプルートのネームタグに書いてある言葉は？",
            zh: "迪士尼布鲁托项圈铭牌上写的是什么？",
            en: "What does Pluto’s name tag say at Disney?",
            my: "ဒစ္စနီ ပလူတို နာမည်တံဆိပ်တွင် ဘာရေးထားသလဲ။",
            answerID: "if-found",
            choices: [
                ("if-found", "見つけたらミッキーマウスまで連絡を", "找到请联系米奇", "If found, return to Mickey Mouse", "တွေ့ရင် မစ်ကီထံ ပြန်ပို့ပါ"),
                ("friend", "ミッキーマウスの友達", "米奇的朋友", "Mickey Mouse’s friend", "မစ်ကီ၏ သူငယ်ချင်း"),
            ],
            explainJA: "正解は「If found, please return to MICKEY MOUSE（見つけたらミッキーまで連絡を）」。",
            explainZH: "正确答案是 “If found, please return to MICKEY MOUSE”（找到请联系米奇）。",
            explainEN: "“If found, please return to MICKEY MOUSE.”",
            explainMY: "အဖြေမှန်က “If found, please return to MICKEY MOUSE”။"
        ),
        Item(
            id: "hard-conte",
            ja: "お笑いの「コント」は何語？",
            zh: "搞笑里的「コント」（小品）是哪国语言？",
            en: "What language is the comedy word “conte” from?",
            my: "ဟာသ 「コント」 က ဘယ်ဘာသာလဲ။",
            answerID: "french",
            choices: [
                ("french", "フランス語", "法语", "French", "ပြင်သစ်"),
                ("english", "英語", "英语", "English", "အင်္ဂလိပ်"),
            ],
            explainJA: "正解はフランス語。conte は短い物語・童話・寸劇という意味。",
            explainZH: "正确答案是法语。conte 的意思是短篇故事、童话、小品。",
            explainEN: "French. Conte means a short story, fable, or sketch.",
            explainMY: "အဖြေမှန်က ပြင်သစ်။ conte က ပုံပြင်တို သို့မဟုတ် ဇာတ်ကွက်တို။"
        ),
        Item(
            id: "hard-jean-pocket",
            ja: "ジーンズの小さなポケットは、元々何を入れるため？",
            zh: "牛仔裤里那只小口袋，最初是装什么的？",
            en: "What was the tiny jeans pocket originally for?",
            my: "ဂျင်းဘောင်းဘီ အိတ်ကလေး မူလက ဘာထည့်ရန်လဲ။",
            answerID: "watch",
            choices: [
                ("coins", "小銭", "零钱", "Coins", "အကြွေစေ့"),
                ("watch", "懐中時計", "怀表", "A pocket watch", "အိတ်နာရီ"),
            ],
            explainJA: "正解は懐中時計。1890年ごろウォッチポケットとして作られ、のちにコインポケットと呼ばれるようになった。",
            explainZH: "正确答案是怀表。大约 1890 年为怀表设计，后来才被叫成零钱袋。",
            explainEN: "A pocket watch, from around 1890. It later became known as a coin pocket.",
            explainMY: "အဖြေမှန်က အိတ်နာရီ။ ၁၈၉၀ ခန့်က နာရီအိတ်၊ နောက်မှ အကြွေစေ့အိတ်ဟု ခေါ်သည်။"
        ),
        Item(
            id: "hard-cashmere",
            ja: "「カシミヤ」とは、どんな動物の毛？",
            zh: "「羊绒」来自哪种动物的毛？",
            en: "Cashmere comes from which animal?",
            my: "ကက်ရှမီးယားက ဘယ်တိရစ္ဆာန်မွေးလဲ။",
            answerID: "goat",
            choices: [
                ("sheep", "ヒツジ", "绵羊", "Sheep", "သိုး"),
                ("goat", "ヤギ", "山羊", "Goat", "ဆိတ်"),
            ],
            explainJA: "正解はヤギ。カシミヤヤギの粗い毛の下にある柔らかい産毛がカシミヤ。",
            explainZH: "正确答案是山羊。来自山羊粗毛底下那层柔软的绒毛。",
            explainEN: "Goat. The soft undercoat of the cashmere goat is cashmere.",
            explainMY: "အဖြေမှန်က ဆိတ်။ ကက်ရှမီးယားဆိတ်ရဲ့ အပျော့မွေးအောက်ခံ ဖြစ်သည်။"
        ),
        Item(
            id: "hard-last-holiday",
            ja: "1年のうちで最後にやってくる祝日はどれ？",
            zh: "一年里最后一个到来的节日是哪个？（令和）",
            en: "Which Japanese national holiday comes last in the year (Reiwa)?",
            my: "ခုနှစ်တစ်နှစ်၏ နောက်ဆုံးရုံးပိတ်ရက်က ဘယ်ဟာလဲ (ရဲဝါ)။",
            answerID: "labor",
            choices: [
                ("birthday", "天皇誕生日", "天皇诞辰", "The Emperor’s Birthday", "ဧကရာဇ်မွေးနေ့"),
                ("labor", "勤労感謝の日", "勤劳感谢日", "Labor Thanksgiving Day", "အလုပ်သမားကျေးဇူးတင်နေ့"),
            ],
            explainJA: "正解は勤労感謝の日（11月23日）。令和の天皇誕生日は2月23日。平成では天皇誕生日が12月23日で年最後だった。",
            explainZH: "正确答案是勤劳感谢日（11 月 23 日）。令和的天皇诞辰是 2 月 23 日；平成时天皇诞辰在 12 月 23 日，才是当年最后一个节日。",
            explainEN: "Labor Thanksgiving Day, Nov 23. In Reiwa the Emperor’s Birthday is Feb 23; in Heisei it was Dec 23 and came last.",
            explainMY: "အဖြေမှန်က အလုပ်သမားကျေးဇူးတင်နေ့ (နိုဝင်ဘာ ၂၃)။ ရဲဝါတွင် ဧကရာဇ်မွေးနေ့ ဖေဖော်ဝါရီ ၂၃။"
        ),
    ]
}
