import Foundation

/// ひっかけ問題：日本語のダジャレ・脑筋急转弯。
enum BrainTeaserBank {
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

    static func hint(id: String) -> String {
        let text = hints[id] ?? (
            ja: "字面と、いちばん普通の意味、両方見てみて。",
            zh: "字面意思和最平常的理解，两边都想想。",
            en: "Check the literal wording and the everyday meaning.",
            my: "စာသားအတိုင်းနှင့် ပုံမှန်အဓိပ္ပာယ် နှစ်ခုလုံး စဉ်းစားပါ။"
        )
        return tr(ja: text.ja, zh: text.zh, en: text.en, my: text.my)
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
                task: .brainTeaser,
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
            id: "factory-hi",
            ja: "工場に「ひ」をつけるとどうなる？",
            zh: "给「工場」加上「ひ」会怎样？",
            en: "What happens if you add 「ひ」 to 「工場」?",
            my: "「工場」 ကို 「ひ」 ထည့်လိုက်ရင် ဘာဖြစ်မလဲ။",
            answerID: "fire",
            choices: [
                ("fire", "火事になる", "发生火灾", "It catches fire", "မီးလောင်သည်"),
                ("airport", "飛行場になる", "变成机场", "It becomes an airport", "လေဆိပ် ဖြစ်သည်"),
            ],
            explainJA: "正解は「火事になる」。ひらがなの「ひ」は「火」と同じ読み。工場に火をつければ火事。一方「ひ＋工場」を続けて読むと「飛行場（ひこうじょう）」にもなる、というのが日本語のひっかけ。",
            explainZH: "正确答案是「发生火灾」。日语平假名「ひ」读 hi，和汉字「火」同音。给工厂点火就会着火。若把「ひ」接在「工場」前面连读，又变成「飛行場（ひこうじょう，机场）」，所以容易选错。",
            explainEN: "The answer is that it catches fire. Hiragana ひ is the same sound as 火 (fire). Putting fire on a factory starts a fire. Read as one word, ひ＋工場 can also be 飛行場 (airport). That Japanese pun is the trap.",
            explainMY: "အဖြေမှန်က မီးလောင်သည်။ ဟိရဂန 「ひ」 က 「火」 နှင့် အသံတူ။ စက်ရုံကို မီးတင်ရင် မီးလောင်သည်။ ဆက်ဖတ်ရင် 「飛行場」 (လေဆိပ်) လည်း ဖြစ်နိုင်သည်။ ဂျပန်စာလုံးဆော့ကစားခြင်းပါ။"
        ),
        Item(
            id: "road-u",
            ja: "道路の真ん中にあるものはなに？",
            zh: "马路正中间有什么？",
            en: "What is in the middle of 道路?",
            my: "「道路」 ရဲ့ အလယ်မှာ ဘာရှိသလဲ။",
            answerID: "u",
            choices: [
                ("crossing", "横断歩道", "人行横道", "A crosswalk", "လမ်းကူးမျဉ်း"),
                ("u", "う", "う", "う", "う"),
            ],
            explainJA: "正解は「う」。「道路」の読みは「どうろ」。ひらがなにすると「ど・う・ろ」の3文字で、真ん中が「う」。漢字の意味（道の真ん中）ではなく、仮名の並びに注目するひっかけ。",
            explainZH: "正确答案是「う」。日语「道路」读作「どうろ」，写成平假名是「ど・う・ろ」三个字，正中间是「う」。问的不是马路上有什么，而是假名怎么排。",
            explainEN: "The answer is う. 道路 is read どうろ. In hiragana that is three characters, ど・う・ろ, so the middle one is う. It is not asking about a real road.",
            explainMY: "အဖြေမှန်က 「う」။ 「道路」 ကို どうろ ဟုဖတ်သည်။ ဟိရဂန ど・う・ろ သုံးလုံး၏ အလယ်က う။ လမ်းပေါ်က အရာကို မမေးပါ။"
        ),
        Item(
            id: "frog-baby",
            ja: "ネコの赤ちゃんは「ニャー」。カエルのお母さんは「ゲコゲコ」。カエルの赤ちゃんはなんと鳴く？",
            zh: "小猫叫「喵」。青蛙妈妈叫「呱呱」。小青蛙怎么叫？",
            en: "A kitten goes meow. A mother frog goes croak. What sound does a baby frog make?",
            my: "ကြောင်ကလေးက ညောင်သည်။ ဖားအမေက ဖားသံကျသည်။ ဖားကလေး ဘယ်လိုအော်သလဲ။",
            answerID: "silent",
            choices: [
                ("croak", "ゲコゲコ", "呱呱", "Croak", "ဖားသံ"),
                ("silent", "鳴かない", "不叫", "It doesn't make a sound", "မအော်ပါ"),
            ],
            explainJA: "正解は「鳴かない」。カエルの赤ちゃんはオタマジャクシで、鳴かない。",
            explainZH: "正确答案是「不叫」。青蛙宝宝是蝌蚪，蝌蚪不会叫。",
            explainEN: "The answer is that it doesn't make a sound. A baby frog is a tadpole, and tadpoles don't croak.",
            explainMY: "အဖြေမှန်က “မအော်ပါ”။ ဖားကလေးက ဖားသားလောင်းဖြစ်လို့ အော်သံ မထွက်ပါ။"
        ),
        Item(
            id: "gummies",
            ja: "グミが6個ある。欲張って5つ口に入れた。グミは何個？",
            zh: "有 6 颗软糖。你贪心把 5 颗放进嘴里。现在有几颗？",
            en: "There are 6 gummies. You greedily put 5 in your mouth. How many gummies are there?",
            my: "ဂမ်မီ ၆ လုံးရှိသည်။ ၅ လုံး ပါးစပ်ထဲ ထည့်လိုက်သည်။ ဘယ်နှစ်လုံးရှိသလဲ။",
            answerID: "six",
            choices: [
                ("one", "1個", "1颗", "1", "၁ လုံး"),
                ("six", "6個", "6颗", "6", "၆ လုံး"),
            ],
            explainJA: "正解は6個。口に入れただけで食べてはいないので、口の中の5個もまだある。",
            explainZH: "正确答案是 6 颗。题目只说放进嘴里，没有说吃掉，嘴里那 5 颗也还在。",
            explainEN: "The answer is 6. Putting them in your mouth is not eating them, so all six still exist.",
            explainMY: "အဖြေမှန်က ၆ လုံး။ ပါးစပ်ထဲထည့်ရုံသာဖြစ်ပြီး မစားရသေးလို့ ၆ လုံးလုံး ရှိနေသေးသည်။"
        ),
        Item(
            id: "chutoro-ikura",
            ja: "大トロは1000円。では中トロはいくら？",
            zh: "大腹金枪鱼 1000 日元。那中腹是「いくら」？",
            en: "Otoro is 1000 yen. Then, is chutoro いくら?",
            my: "အိုတိုရိုက ၁၀၀၀ ယန်း။ ချူတိုရိုက いくら လား။",
            answerID: "different",
            choices: [
                ("five-hundred", "500円", "500日元", "500 yen", "၅၀၀ ယန်း"),
                ("different", "ちがう", "不是", "No, that's something else", "မဟုတ်ပါ"),
            ],
            explainJA: "正解は「ちがう」。日本語の「いくら」は同音異義語。値段を聞く「いくら」と、寿司ネタの「イクラ」（鮭の卵）がある。中トロはマグロで、イクラではない。",
            explainZH: "正确答案是「不是」。日语「いくら」是同音词：一是问价钱「多少钱」，二是寿司里的鲑鱼籽「イクラ」。读音一样，意思不同。中腹是金枪鱼，不是鲑鱼籽。",
            explainEN: "The answer is “that's something else.” In Japanese, いくら is a homophone: “how much?” and ikura (salmon roe on sushi). Chutoro is tuna, not ikura.",
            explainMY: "အဖြေမှန်က မဟုတ်ပါ။ ဂျပန် 「いくら」 က အသံတူ နှစ်မျိုး။ စျေးမေးခြင်းနှင့် ဆူရှီ ဆော်လမွန်ဥ။ ချူတိုရိုက တူနာ၊ အဲဒါ မဟုတ်။"
        ),
        Item(
            id: "cat-kuwaete",
            ja: "バケツに魚が5匹。野良猫が1匹くわえて行った。今、何匹？",
            zh: "桶里有 5 条鱼。野猫「くわえて」走了 1 条。现在几条？",
            en: "A bucket has 5 fish. A stray cat くわえて 1 more. How many now?",
            my: "ပုံးထဲ ငါး ၅ ကောင်။ ကြောင်က ၁ ကောင် くわえて သွားသည်။ ယခု ဘယ်နှစ်ကောင်လဲ။",
            answerID: "six",
            choices: [
                ("six", "6匹", "6条", "6", "၆ ကောင်"),
                ("four", "4匹", "4条", "4", "၄ ကောင်"),
            ],
            explainJA: "正解は6匹。日本語の「くわえて」は漢字で意味が分かれる。「咥えて」なら口にくわえて持ち去る（4匹）。「加えて」なら数を足す（6匹）。この問題は後者。",
            explainZH: "正确答案是 6 条。日语「くわえて」同音能写成「咥えて」（叼走）或「加えて」（加上）。叼走剩 4 条，加上是 6 条。这题按「加上」来算。",
            explainEN: "The answer is 6. Japanese くわえて is a homophone: 咥えて (carry in the mouth → 4 fish) or 加えて (add → 6). This riddle uses “add.”",
            explainMY: "အဖြေမှန်က ၆ ကောင်။ ဂျပန် くわえて အသံတူ။ ခဲယူသွားရင် ၄၊ ပေါင်းထည့်ရင် ၆။ ဒီပဟေဠိက ပေါင်းထည့်ခြင်း။"
        ),
        Item(
            id: "train-seat",
            ja: "杖をついたおじいさんが電車に乗ってきた。誰も席を譲らない。なぜ？",
            zh: "拄拐的老爷爷上了电车，却没人让座。为什么？",
            en: "An old man with a cane boards the train. Nobody gives up a seat. Why?",
            my: "တုတ်နှင့် လူအို ရထားစီးလာသည်။ ဘယ်သူမှ ခုံမပေး။ ဘာကြောင့်လဲ။",
            answerID: "empty",
            choices: [
                ("all-old", "乗客もみんな高齢者だった", "乘客也都是老人", "All the passengers were elderly too", "ခရီးသည်အားလုံး လူအိုချည်း"),
                ("empty", "席が空いていた", "本来就有空座", "There were empty seats", "ခုံလွတ်များ ရှိနေသည်"),
            ],
            explainJA: "正解は「席が空いていた」。空席があれば、座っている人が立つ必要はない。",
            explainZH: "正确答案是「本来就有空座」。有空位子时，坐着的人不必站起来让座。",
            explainEN: "The answer is that seats were empty. If a seat is free, nobody sitting needs to stand up.",
            explainMY: "အဖြေမှန်က “ခုံလွတ်များ ရှိနေသည်”။ ခုံလွတ်ရှိရင် ထိုင်နေသူ ထပေးစရာ မလိုပါ။"
        ),
        Item(
            id: "eigo-japan",
            ja: "英語はどこの国の言葉？",
            zh: "「英語」是哪个国家的词？",
            en: "Which country does the word 英語 belong to?",
            my: "「英語」 က ဘယ်နိုင်ငံက စကားလုံးလဲ။",
            answerID: "japan",
            choices: [
                ("japan", "日本", "日本", "Japan", "ဂျပန်"),
                ("america", "アメリカ", "美国", "America", "အမေရိကန်"),
            ],
            explainJA: "正解は日本。英語という言語は米英などで使う。でも「英語」は漢字二字の日本語（音読みで「えいご」）。単語そのものがどの国の言葉かを聞いている。",
            explainZH: "正确答案是日本。英语这种语言用在英美等国。但「英語」是两个汉字组成的日语词，读作「えいご」。问的是这个词本身是日语，不是英语从哪来。",
            explainEN: "The answer is Japan. English is spoken in the US and UK, but the two-kanji word 英語 (eigo) is Japanese. The riddle asks about the word, not the language.",
            explainMY: "အဖြေမှန်က ဂျပန်။ အင်္ဂလိပ်ဘာသာကို အမေရိကန်/ယူကေမှာ သုံးသည်။ သို့သော် 「英語」 (えいご) က ဂျပန် ခန်ဂျိ စကားလုံး။ စကားလုံးကို မေးတာပါ။"
        ),
        Item(
            id: "taro-siblings",
            ja: "タロウさんの両親には4人の子がいる。ジロウ、サブロウ、シロウ、最後の1人は？",
            zh: "太郎的父母有 4 个孩子：次郎、三郎、四郎，最后一个人是？",
            en: "Taro's parents have 4 children: Jiro, Saburo, Shiro, and who is the last one?",
            my: "တရိုးရဲ့ မိဘမှာ ကလေး ၄ ယောက်ရှိသည်။ ဂျိရိုး၊ ဆဘုရိုး၊ ရှိရိုး၊ နောက်ဆုံးတစ်ယောက်က ဘယ်သူလဲ။",
            answerID: "taro",
            choices: [
                ("goro", "ゴロウさん", "五郎", "Goro", "ဂိုရိုး"),
                ("taro", "タロウさん", "太郎", "Taro", "တရိုး"),
            ],
            explainJA: "正解はタロウさん。昔の日本では長男を太郎、次男を次郎、三男を三郎、四男を四郎と付けることが多かった。タロウ本人が長男で、4人に含まれる。",
            explainZH: "正确答案是太郎。日本旧时常用太郎、次郎、三郎、四郎按男孩出生顺序起名。题目里已经有太郎，他就是四个孩子里的老大。",
            explainEN: "The answer is Taro. Traditional Japanese boy names often go Tarō, Jirō, Saburō, Shirō by birth order. Taro himself is the eldest of the four.",
            explainMY: "အဖြေမှန်က တရိုး။ ဂျပန် အစဉ်အလာ အမည် တရိုး၊ ဂျိရိုး၊ ဆဘုရိုး၊ ရှိရိုး။ တရိုးကိုယ်တိုင် အကြီးဆုံး၊ ကလေး ၄ ယောက်ထဲ ပါသည်။"
        ),
        Item(
            id: "hut-entrance",
            ja: "入口しかない小屋にいる。出口も窓もないのに脱出できた。どうやって？",
            zh: "你在只有入口的小屋里，没有出口也没有窗，却出来了。怎么出来的？",
            en: "You're in a hut with only an entrance, no exit or windows, but you got out. How?",
            my: "ဝင်ပေါက်ပဲရှိသော တဲထဲမှာ။ ထွက်ပေါက်နှင့် ပြတင်းပေါက် မရှိသော်လည်း ထွက်နိုင်သည်။ ဘယ်လိုလဲ။",
            answerID: "entrance",
            choices: [
                ("entrance", "入口から出た", "从入口出去", "Went out the entrance", "ဝင်ပေါက်ကနေ ထွက်သည်"),
                ("still-in", "実は出られていない", "其实没出去", "You actually didn't get out", "တကယ် မထွက်ရသေး"),
            ],
            explainJA: "正解は入口から出た。入口のドアは出ることもできる。鍵がかかっているとは書いていない。",
            explainZH: "正确答案是从入口出去。入口的门同样可以当出口用，题目没说门锁上了。",
            explainEN: "The answer is going out the entrance. An entrance door can also be used to leave, and it never said it was locked.",
            explainMY: "အဖြေမှန်က ဝင်ပေါက်ကနေ ထွက်သည်။ ဝင်ပေါက်တံခါးက ထွက်လို့ရသည်။ သော့ခတ်ထားသည်ဟု မရေးထားပါ။"
        ),
        Item(
            id: "dice-six",
            ja: "1〜6のサイコロなのに、6以上の目が出ることがある。その数字は？",
            zh: "骰子只有 1 到 6，却能掷出 6 以上。那个数字是？",
            en: "A 1–6 die can still roll a number that is 6 or more. Which number?",
            my: "၁ မှ ၆ အထိ ဝါးလုံး၊ ၆ နှင့်အထက် ထွက်နိုင်သည်။ ဘယ်ဂဏန်းလဲ။",
            answerID: "six",
            choices: [
                ("six", "6", "6", "6", "၆"),
                ("none", "そんな数字はない", "没有这种数字", "There is no such number", "အဲဒီဂဏန်း မရှိ"),
            ],
            explainJA: "正解は6。日本語の「以上」はその数字を含む。6以上は6・7・8…。「6より大きい」とは違う。",
            explainZH: "正确答案是 6。日语「以上」包含这个数字本身，「6以上」就是 6 和比 6 大的。和「超过 6」不一样。",
            explainEN: "The answer is 6. In Japanese, 以上 includes the number itself, so 6以上 means 6 or more, not “more than 6.”",
            explainMY: "အဖြေမှန်က ၆။ ဂျပန် 「以上」 က ထိုဂဏန်းကိုယ်တိုင် ပါသည်။ ၆ နှင့်အထက် = ၆၊ ၇၊ ၈…။ ၆ ထက်ကြီးတာ မဟုတ်။"
        ),
        Item(
            id: "months-28",
            ja: "1年間で31日まである月は7つ。では、28日がある月はいくつ？",
            zh: "一年里有 31 天的月份有 7 个。那么，有 28 天的月份有几个？",
            en: "7 months have 31 days. How many months have 28 days?",
            my: "၃၁ ရက်ရှိသော လ ၇ လရှိသည်။ ၂၈ ရက်ရှိသော လ ဘယ်နှစ်လလဲ။",
            answerID: "twelve",
            choices: [
                ("one", "1", "1个月", "1", "၁ လ"),
                ("twelve", "12", "12个月", "12", "၁၂ လ"),
            ],
            explainJA: "正解は12。聞いているのは「28日しかない月」ではなく「28日がある月」。どの月にも28日目がある。",
            explainZH: "正确答案是 12 个月。问的是「有 28 天」，不是「只有 28 天」。每个月都有第 28 天。",
            explainEN: "The answer is 12. Every month has a 28th day. It does not ask which month has only 28 days.",
            explainMY: "အဖြေမှန်က ၁၂ လ။ ၂၈ ရက်တိတိသာရှိတာကို မမေးပါ။ လတိုင်းမှာ ၂၈ ရက်နေ့ ရှိသည်။"
        ),
        Item(
            id: "konbanwa",
            ja: "Aさんは「こんばんは」とあいさつした。誰も「こんばんは」と返さない。なぜ？",
            zh: "A 说了「晚上好」，却没人回「晚上好」。为什么？",
            en: "A says “good evening,” but nobody replies “good evening.” Why?",
            my: "A က ညနေခင်းမင်္ဂလာပါဟု နှုတ်ဆက်သည်။ ဘယ်သူမှ ညနေခင်းမင်္ဂလာပါဟု ပြန်မပြော။ ဘာကြောင့်လဲ။",
            answerID: "daytime",
            choices: [
                ("unheard", "聞こえていなかった", "没听见", "Nobody heard it", "မကြားလိုက်ကြ"),
                ("daytime", "夜ではないから", "现在不是晚上", "It isn't night", "ညမဟုတ်လို့"),
            ],
            explainJA: "正解は夜ではないから。日本語のあいさつは時間で変わる。朝はおはよう、昼はこんにちは、夜はこんばんは。こんばんはと返さないのは、今が夜ではないから。",
            explainZH: "正确答案是现在不是晚上。日语打招呼按时间分：早上「おはよう」，白天「こんにちは」，晚上「こんばんは」。没人回「晚上好」，可能是白天，回了别的招呼。",
            explainEN: "The answer is that it isn’t night. Japanese greetings change with the time: おはよう in the morning, こんにちは in the day, こんばんは at night.",
            explainMY: "အဖြေမှန်က ညမဟုတ်လို့။ ဂျပန် နှုတ်ဆက်စကား အချိန်လိုက် ပြောင်းသည်။ မနက် おはよう၊ နေ့ こんにちは၊ ည こんばんは။"
        ),
        Item(
            id: "strap-hand",
            ja: "電車に乗っている。何でつり革につかまっている？",
            zh: "你在电车上。用什么抓着吊环？",
            en: "You're on a train. What are you holding the strap with?",
            my: "ရထားပေါ်မှာ။ ကြိုးကို ဘာနှင့် ကိုင်ထားသလဲ။",
            answerID: "hand",
            choices: [
                ("danger", "危ないから", "因为危险", "Because it's dangerous", "အန္တရာယ်ရှိလို့"),
                ("hand", "手", "手", "Your hand", "လက်"),
            ],
            explainJA: "正解は手。日本語の「何で」は二通り。「なんで」＝なぜ、「なにで」＝何を使って。ここでは「なにでつかまっているか」なので手。",
            explainZH: "正确答案是手。日语「何で」有两种读法：「なんで」是为什么，「なにで」是用什么。这题问用什么抓吊环，所以是手。",
            explainEN: "The answer is your hand. Japanese 何で can be なんで (why) or なにで (with what). Here it means “with what,” so the hand.",
            explainMY: "အဖြေမှန်က လက်။ ဂျပန် 「何で」 နှစ်မျိုး။ なんで = ဘာကြောင့်၊ なにで = ဘာနှင့်။ ဒီမှာ ဘာနှင့်ကိုင်သလဲ = လက်။"
        ),
        Item(
            id: "one-to-twenty",
            ja: "「1から20」に7がつく数はいくつある？",
            zh: "「1から20」里有几个带 7 的数？",
            en: "In the text “1から20”, how many numbers contain a 7?",
            my: "「1から20」 ထဲမှာ ၇ ပါသော ကိန်း ဘယ်နှစ်ခုရှိသလဲ။",
            answerID: "zero",
            choices: [
                ("zero", "0個", "0个", "0", "၀ ခု"),
                ("two", "2個", "2个", "2", "၂ ခု"),
            ],
            explainJA: "正解は0個。かぎかっこ「1から20」は日本語の文。「から」は助詞で、書いてあるのは1・から・20。数字の7は出てこない。1〜20を数える問題ではない。",
            explainZH: "正确答案是 0 个。日语「から」是助词，表示「从…到」。括号里写的是「1から20」这几个字，里面没有数字 7。不是让你数 1 到 20。",
            explainEN: "The answer is 0. Japanese から is a particle meaning “from.” The quoted text “1から20” has no digit 7. It is not asking you to count from 1 to 20.",
            explainMY: "အဖြေမှန်က ၀ ခု။ ဂျပန် 「から」 က ကြိယာဝိသေသန/ပစ္စည်း။ 「1から20」 စာထဲမှာ ဂဏန်း ၇ မပါ။ ၁ မှ ၂၀ ရေတွက်ခိုင်းတာ မဟုတ်။"
        ),
        Item(
            id: "ten-years-later",
            ja: "イタズラばかりの問題児A君は今10歳。10年後は何になっている？",
            zh: "爱捣蛋的问题儿童 A 现在 10 岁。10 年后他会变成什么？",
            en: "A, a mischievous 10-year-old, in 10 years will be what?",
            my: "ဒုက္ခပေးတတ်သော A က ယခု ၁၀ နှစ်။ ၁၀ နှစ်ကြာရင် ဘာဖြစ်မလဲ။",
            answerID: "twenty",
            choices: [
                ("youtuber", "迷惑系YouTuber", "整人网红", "A nuisance YouTuber", "အနှောင့်အယှက် YouTuber"),
                ("twenty", "20歳", "20岁", "20 years old", "၂၀ နှစ်"),
            ],
            explainJA: "正解は20歳。将来の職業はわからないが、10年後に20歳になることだけは確か。",
            explainZH: "正确答案是 20 岁。以后做什么工作不知道，但十年后一定满 20 岁。",
            explainEN: "The answer is 20 years old. His future job is unknown, but in 10 years he will be 20.",
            explainMY: "အဖြေမှန်က ၂၀ နှစ်။ အနာဂတ်အလုပ် မသိသော်လည်း ၁၀ နှစ်ကြာရင် ၂၀ နှစ် ဖြစ်မည်။"
        ),
        Item(
            id: "north-ken",
            ja: "日本で一番北にある県はなに？",
            zh: "日本最北的「县」是哪一个？",
            en: "What is the northernmost 県 in Japan?",
            my: "ဂျပန်မှာ အမြောက်ဆုံး 県 က ဘာလဲ။",
            answerID: "aomori",
            choices: [
                ("aomori", "青森県", "青森县", "Aomori", "အအိုမိုရိ"),
                ("hokkaido", "北海道", "北海道", "Hokkaido", "ဟော့ကိုင်းဒိုး"),
            ],
            explainJA: "正解は青森県。日本の地方は「都道府県」の4種。東京は都、北海道は道、大阪と京都は府、残りが県。一番北の県は青森。北海道はより北だが「道」。",
            explainZH: "正确答案是青森县。日本行政区分成都、道、府、县：东京是「都」，北海道是「道」，大阪和京都是「府」，其余是「县」。最北的「县」是青森；北海道更北，但不是县。",
            explainEN: "The answer is Aomori. Japan uses four labels: 都 (Tokyo), 道 (Hokkaido), 府 (Osaka, Kyoto), and 県 for the rest. The northernmost 県 is Aomori; Hokkaido is farther north but is a 道.",
            explainMY: "အဖြေမှန်က အအိုမိုရိ။ ဂျပန်ကို 都၊ 道၊ 府၊ 県 ခွဲသည်။ အမြောက်ဆုံး 県 က အအိုမိုရိ။ ဟော့ကိုင်းဒိုး ပိုမြောက်သော်လည်း 道။"
        ),
        Item(
            id: "fire-elsewhere",
            ja: "火事が起こった。しかし誰もその場から逃げない。なぜ？",
            zh: "发生了火灾，却没人从「现场」逃走。为什么？",
            en: "A fire broke out, but nobody runs from that place. Why?",
            my: "မီးလောင်သည်။ သို့သော် အဲဒီနေရာက ဘယ်သူမှ မပြေး။ ဘာကြောင့်လဲ။",
            answerID: "not-there",
            choices: [
                ("already-left", "すでに逃げた後", "已经逃完了", "Everyone already fled", "ပြေးပြီးကြပြီ"),
                ("not-there", "火災現場ではない", "那里不是火灾现场", "That place is not the fire scene", "မီးလောင်ရာ မဟုတ်"),
            ],
            explainJA: "正解は火災現場ではない。「火事が起こった」と「その場」が同じ場所だとは書いていない。",
            explainZH: "正确答案是那里不是火灾现场。题目没说「那个地方」就是起火的地方。",
            explainEN: "The answer is that this place is not the fire scene. A fire happened, but not necessarily here.",
            explainMY: "အဖြေမှန်က မီးလောင်ရာ မဟုတ်။ မီးလောင်သည်ဟု ရေးသော်လည်း ဒီနေရာမှာဟု မဆိုပါ။"
        ),
        Item(
            id: "ramen-two",
            ja: "ラーメン1杯税込500円。1000円札を出したらおつりがない。なぜ？",
            zh: "拉面一杯含税 500 日元。付了 1000 日元却没有找零。为什么？",
            en: "Ramen is 500 yen a bowl tax-in. You pay with 1000 yen and get no change. Why?",
            my: "ရာမင် တစ်ပွဲ အခွန်ပါ ၅၀၀ ယန်း။ ၁၀၀၀ ပေးသော်လည်း အကြွေမရ။ ဘာကြောင့်လဲ။",
            answerID: "two-bowls",
            choices: [
                ("two-bowls", "2杯食べた", "吃了两碗", "You ate two bowls", "နှစ်ပွဲ စားသည်"),
                ("extra", "ラーメン以外も頼んだ", "还点了别的", "You ordered something else too", "တခြားဟာလည်း မှာသည်"),
            ],
            explainJA: "正解は2杯食べた。1杯500円でも、2杯なら1000円でおつりは出ない。何杯食べたかは書いていない。",
            explainZH: "正确答案是吃了两碗。一杯 500，两杯正好 1000，所以没有找零。题目没说只吃了一杯。",
            explainEN: "The answer is two bowls. Two bowls at 500 yen each are 1000 yen, so there is no change.",
            explainMY: "အဖြေမှန်က နှစ်ပွဲ စားသည်။ တစ်ပွဲ ၅၀၀၊ နှစ်ပွဲဆို ၁၀၀၀ မို့ အကြွေမထွက်။ တစ်ပွဲသာစားသည်ဟု မရေးထားပါ။"
        ),
        Item(
            id: "kakigori",
            ja: "かき氷を逆さまにするとどうなる？",
            zh: "刨冰倒过来会怎样？",
            en: "What happens if you turn shaved ice upside down?",
            my: "ရေခဲမုန့်ကို ပြောင်းပြန်လှန်လိုက်ရင် ဘာဖြစ်မလဲ။",
            answerID: "spill",
            choices: [
                ("backwards", "りおごきか", "变成倒着读的词", "The letters reverse", "စာလုံးပြောင်းပြန်"),
                ("spill", "こぼれる", "会洒出来", "It spills", "ဖိတ်ကျသည်"),
            ],
            explainJA: "正解はこぼれる。「かき氷」を逆から読むと「こおりかき」になる言葉遊びもあるが、問題は器を逆さまにする話。中身がこぼれる。",
            explainZH: "正确答案是会洒出来。日语有时会把词倒过来读着玩，「かき氷」倒读有点像「こおりかき」。但这题是把刨冰这盘东西翻过来，会洒出来。",
            explainEN: "The answer is that it spills. Japanese wordplay might read かき氷 backwards as こおりかき, but here you turn the bowl over, so the ice falls out.",
            explainMY: "အဖြေမှန်က ဖိတ်ကျသည်။ ဂျပန်စာလုံးပြန်ဖတ်ကစား 「かき氷」 → 「こおりかき」 လည်းရှိသည်။ သို့သော် ပန်းကန်လှန်တာမို့ ဖိတ်သည်။"
        ),
        Item(
            id: "bouquets",
            ja: "3人の友達から花束を1束ずつもらった。全部合わせたらいくつ？",
            zh: "三个朋友每人送了一束花。全部合在一起是几束？",
            en: "Three friends each give you one bouquet. How many if you put them all together?",
            my: "သူငယ်ချင်း ၃ ယောက်က ပန်းစည်း တစ်စည်းစီ ပေးသည်။ ပေါင်းလိုက်ရင် ဘယ်နှစ်စည်းလဲ။",
            answerID: "one",
            choices: [
                ("one", "1つ", "1束", "1", "၁ စည်း"),
                ("three", "3つ", "3束", "3", "၃ စည်း"),
            ],
            explainJA: "正解は1つ。3束を合わせると、1つの花束になる。",
            explainZH: "正确答案是 1 束。三束合在一起，就变成一束。",
            explainEN: "The answer is 1. Putting three bouquets together makes one bouquet.",
            explainMY: "အဖြေမှန်က ၁ စည်း။ သုံးစည်းကို ပေါင်းလိုက်ရင် တစ်စည်း ဖြစ်သွားသည်။"
        ),
        Item(
            id: "othello",
            ja: "オセロのコマは何種類ある？",
            zh: "黑白棋的棋子有几种？",
            en: "How many kinds of Othello pieces are there?",
            my: "အိုသယ်လို အကွက် ဘယ်နှစ်မျိုးရှိသလဲ။",
            answerID: "one",
            choices: [
                ("one", "1種類", "1种", "1 kind", "၁ မျိုး"),
                ("three", "3種類", "3种", "3 kinds", "၃ မျိုး"),
            ],
            explainJA: "正解は1種類。片面が黒、片面が白の同じコマが1種類だけ。",
            explainZH: "正确答案是 1 种。棋子一面黑一面白，是同一种。",
            explainEN: "The answer is one kind. Each piece is black on one side and white on the other.",
            explainMY: "အဖြေမှန်က ၁ မျိုး။ တစ်ဖက်အမည်း တစ်ဖက်အဖြူ၊ အကွက်အမျိုးအစား တစ်ခုတည်း။"
        ),
        Item(
            id: "black-clothes",
            ja: "汚れた真っ黒な服を洗っても白くならない。なぜ？",
            zh: "脏兮兮的全黑衣服洗完也不会变白。为什么？",
            en: "You wash filthy pitch-black clothes, but they don't turn white. Why?",
            my: "ညစ်ပတ်သော အမည်းရောင်အဝတ် လျှော်သော်လည်း မဖြူ။ ဘာကြောင့်လဲ။",
            answerID: "already-black",
            choices: [
                ("no-soap", "洗剤を入れ忘れた", "忘了放洗衣粉", "You forgot detergent", "ဆပ်ပြာ မထည့်မိ"),
                ("already-black", "元々黒い服だった", "衣服本来就是黑的", "The clothes were black to begin with", "မူလက အမည်းရောင်"),
            ],
            explainJA: "正解は元々黒い服だった。汚れて黒くなった服ではなく、黒い服が汚れていただけ。",
            explainZH: "正确答案是衣服本来就是黑的。不是脏成黑色，而是黑色衣服弄脏了，洗完还是黑的。",
            explainEN: "The answer is that the clothes were already black. Dirt didn't dye them black.",
            explainMY: "အဖြေမှန်က မူလက အမည်းရောင်။ ညစ်လို့ မည်းသွားတာမဟုတ်၊ အမည်းအဝတ် ညစ်နေတာပါ။"
        ),
        Item(
            id: "marathon-fifth",
            ja: "10人のマラソンで、5位の人を抜いた。今は何位？",
            zh: "十人马拉松里，你超过了第五名。现在第几名？",
            en: "In a 10-person marathon you pass the runner in 5th. What place are you in now?",
            my: "လူ ၁၀ ယောက် မာရသွန်မှာ ပဉ္စမကို ကျော်လိုက်သည်။ ယခု ဘယ်အဆင့်လဲ။",
            answerID: "fifth",
            choices: [
                ("fourth", "4位", "第四名", "4th", "စတုတ္ထ"),
                ("fifth", "5位", "第五名", "5th", "ပဉ္စမ"),
            ],
            explainJA: "正解は5位。5位の人を抜く前は6位。抜いたあと、その人の位置に入るので5位。",
            explainZH: "正确答案是第五名。超过第五名之前你是第六，超过之后你占了他的位置，变成第五。",
            explainEN: "The answer is 5th. You were 6th, then you take the place of the person you passed.",
            explainMY: "အဖြေမှန်က ပဉ္စမ။ မကျော်ခင်က ဆဋ္ဌမ၊ ကျော်ပြီးရင် သူ့နေရာကိုယူလို့ ပဉ္စမ။"
        ),
        Item(
            id: "crawl-feet",
            ja: "ハイハイしている赤ちゃん1人、ネコ2匹、ウサギ1羽。足は合計何本？",
            zh: "1 个正在爬的宝宝、2 只猫、1 只兔子。脚一共几只？",
            en: "1 crawling baby, 2 cats, and 1 rabbit. How many feet in total?",
            my: "တွားနေသော ကလေး ၁၊ ကြောင် ၂၊ ယုန် ၁။ ခြေထောက် စုစုပေါင်း ဘယ်နှစ်ချောင်းလဲ။",
            answerID: "fourteen",
            choices: [
                ("fourteen", "14本", "14只", "14", "၁၄ ချောင်း"),
                ("sixteen", "16本", "16只", "16", "၁၆ ချောင်း"),
            ],
            explainJA: "正解は14本。赤ちゃんの足は2本。ネコ2匹とウサギ1羽は4本×3で12本。手は足に数えない。",
            explainZH: "正确答案是 14。宝宝的脚是 2 只；猫和兔子各 4 只，三只要 12。爬行用的手不算脚。",
            explainEN: "The answer is 14. The baby has 2 feet; three four-legged animals add 12. Hands used to crawl are not feet.",
            explainMY: "အဖြေမှန်က ၁၄။ ကလေးခြေ ၂၊ ကြောင်နှင့် ယုန် ၄×၃ = ၁၂။ တွားရာတွင် သုံးသော လက်ကို ခြေဟု မရေတွက်။"
        ),
        Item(
            id: "osaka-fu",
            ja: "大阪府の県庁所在地はどこ？",
            zh: "大阪府的县厅所在地是哪里？",
            en: "Where is the prefectural-office seat of Osaka-fu?",
            my: "အိုဆာကာဖု ရဲ့ 県庁所在地 က ဘယ်မှာလဲ။",
            answerID: "none",
            choices: [
                ("osaka-city", "大阪市", "大阪市", "Osaka City", "အိုဆာကာမြို့"),
                ("none", "県庁所在地はない", "没有县厅所在地", "There isn't one", "県庁 မရှိ"),
            ],
            explainJA: "正解は県庁所在地はない。日本は都道府県。大阪と京都だけが「府」で、県庁ではなく府庁がある。大阪市は府庁所在地ではあるが、県庁所在地という言い方はしない。",
            explainZH: "正确答案是没有县厅所在地。日本分成都、道、府、县，只有大阪和京都叫「府」，衙门叫府厅，不叫县厅。",
            explainEN: "The answer is that there isn’t a 県庁. Only Osaka and Kyoto are 府, so they have a fu office, not a ken (prefecture) office.",
            explainMY: "အဖြေမှန်က 県庁 မရှိ။ ဂျပန်တွင် အိုဆာကာနှင့် ကျိုတိုသာ 府။ 府 ရုံးရှိသည်၊ 県 ရုံး မခေါ်ပါ။"
        ),
        Item(
            id: "five-necks",
            ja: "私たちの体には首がいくつある？",
            zh: "我们身上有几个「首」？",
            en: "How many 首 does the human body have?",
            my: "ခန္ဓာကိုယ်မှာ 首 ဘယ်နှစ်ခုရှိသလဲ။",
            answerID: "five",
            choices: [
                ("one", "1つ", "1个", "1", "၁ ခု"),
                ("five", "5つ", "5个", "5", "၅ ခု"),
            ],
            explainJA: "正解は5つ。日本語では首のほか、手のくびを「手首」、足のくびを「足首」とも書く。首1＋手首2＋足首2＝5。",
            explainZH: "正确答案是 5 个。日语「首」不只是脖子：手腕叫「手首」，脚踝叫「足首」，都带这个字。脖子 1 + 手腕 2 + 脚踝 2 = 5。",
            explainEN: "The answer is 5. In Japanese, 首 is the neck, but wrists are 手首 and ankles 足首 — all use 首. Neck 1 + wrists 2 + ankles 2.",
            explainMY: "အဖြေမှန်က ၅ ခု။ ဂျပန် 首 သည် လည်ပင်းသာမက လက်ကောက်ဝတ် 手首၊ ခြေချင်းဝတ် 足首။ ၁+၂+၂=၅။"
        ),
        Item(
            id: "hide-seek",
            ja: "5人でかくれんぼ。3人見つかった。隠れているのはあと何人？",
            zh: "5 人在玩捉迷藏。找到了 3 人。还剩几人在藏？",
            en: "5 people play hide-and-seek. 3 are found. How many are still hiding?",
            my: "လူ ၅ ယောက် ပုန်းကစားသည်။ ၃ ယောက် တွေ့ပြီ။ ပုန်းနေသေးတာ ဘယ်နှစ်ယောက်လဲ။",
            answerID: "one",
            choices: [
                ("one", "1人", "1人", "1", "၁ ယောက်"),
                ("two", "2人", "2人", "2", "၂ ယောက်"),
            ],
            explainJA: "正解は1人。5人のうち1人は鬼なので、隠れているのは4人。3人見つかると残り1人。",
            explainZH: "正确答案是 1 人。5 人里有 1 个找人，藏起来的是 4 人。找到 3 人后还剩 1 人。",
            explainEN: "The answer is 1. One of the five is “it,” so 4 hid. After 3 are found, 1 is still hiding.",
            explainMY: "အဖြေမှန်က ၁ ယောက်။ ၅ ယောက်ထဲက ၁ ယောက်က ရှာသူ၊ ပုန်းသူ ၄။ ၃ ယောက်တွေ့ရင် ၁ ယောက်ကျန်သည်။"
        ),
        Item(
            id: "momotaro",
            ja: "桃太郎が初めて出会った生物はなに？",
            zh: "桃太郎第一次遇见的生物是什么？",
            en: "What living being did Momotaro meet first?",
            my: "မိုမိုတရိုး ပထမဆုံး တွေ့သော သတ္တဝါက ဘာလဲ။",
            answerID: "human",
            choices: [
                ("human", "人間", "人", "A human", "လူ"),
                ("dog", "犬", "狗", "A dog", "ခွေး"),
            ],
            explainJA: "正解は人間。日本の昔話『桃太郎』では、桃から生まれたあとおじいさん・おばあさんに会う。犬・猿・キジはあとからお供になる。ひっかけは「犬」を選ばせること。",
            explainZH: "正确答案是人。这是日本民间故事《桃太郎》：从桃子里出来后先见到爷爷奶奶。狗、猴、野鸡是后来的随从。陷阱是让你选「狗」。",
            explainEN: "A human. In the Japanese folk tale Momotaro, he first meets the old couple after being born from a peach. The dog, monkey, and pheasant join later. The trap is choosing the dog.",
            explainMY: "အဖြေမှန်က လူ။ ဂျပန် ဒဏ္ဍာရီ 『မိုမိုတရိုး』။ မက်မွန်ထဲက ထွက်ပြီး အဘိုးအဘွားကို အရင်တွေ့သည်။"
        ),
        Item(
            id: "diamond-ace",
            ja: "トランプのダイヤのエースに描かれているダイヤはいくつ？",
            zh: "扑克牌方片 A 上画了几个方片？",
            en: "How many diamonds are drawn on the ace of diamonds?",
            my: "ဖဲချပ် စိန်အေပေါ် စိန်ပုံ ဘယ်နှစ်ခုဆွဲထားသလဲ။",
            answerID: "three",
            choices: [
                ("one", "1つ", "1个", "1", "၁ ခု"),
                ("three", "3つ", "3个", "3", "၃ ခု"),
            ],
            explainJA: "正解は3つ。中央に1つ、カードの上下の隅に1つずつで合計3つ。",
            explainZH: "正确答案是 3 个。中间 1 个，牌面上下角各 1 个。",
            explainEN: "The answer is 3: one in the center and one in each of the top and bottom corners.",
            explainMY: "အဖြေမှန်က ၃ ခု။ အလယ် ၁ ခု၊ အပေါ်အောက် ထောင့်မှာ တစ်ခုစီ။"
        ),
    ]

    private static let hints: [String: (ja: String, zh: String, en: String, my: String)] = [
        "factory-hi": (
            ja: "字を足す話？ それとも火をつける話？",
            zh: "是往字上加「ひ」，还是往工厂点火？",
            en: "Are you adding a letter, or putting fire on it?",
            my: "စာလုံးထည့်တာလား၊ မီးတင်တာလား။"
        ),
        "road-u": (
            ja: "本物の道じゃなくて、書いた文字を見てみて。",
            zh: "别想马路上有什么，看看「道路」这几个字。",
            en: "Don't picture a street. Look at the written characters.",
            my: "လမ်းကို မတွေးပါနှင့်။ ရေးထားသော စာလုံးကို ကြည့်ပါ။"
        ),
        "frog-baby": (
            ja: "カエルの赤ちゃんって、どんな姿？",
            zh: "青蛙宝宝刚出生时，长什么样？",
            en: "What does a baby frog look like at first?",
            my: "ဖားကလေး အစမှာ ဘယ်လိုပုံလဲ။"
        ),
        "gummies": (
            ja: "口に入れただけで、食べたことになる？",
            zh: "放进嘴里，就等于吃掉了吗？",
            en: "Does putting them in your mouth mean you ate them?",
            my: "ပါးစပ်ထဲထည့်ရုံနှင့် စားပြီးပြီလား။"
        ),
        "chutoro-ikura": (
            ja: "「いくら」って、値段だけ？",
            zh: "「いくら」在这里只是在问多少钱吗？",
            en: "Does いくら only mean “how much”?",
            my: "「いくら」 က စျေးနှုန်းပဲလား။"
        ),
        "cat-kuwaete": (
            ja: "「くわえて」の読み方、ふたつあるよ。",
            zh: "「くわえて」有两种理解：叼走，或者加上。",
            en: "くわえて can mean carrying in the mouth, or adding.",
            my: "「くわえて」 ကို ခဲယူသည် သို့မဟုတ် ပေါင်းသည်ဟု ဖတ်နိုင်သည်။"
        ),
        "train-seat": (
            ja: "席を譲る必要がなかった理由は？",
            zh: "为什么根本不用让座？",
            en: "Why might nobody need to give up a seat?",
            my: "ဘာကြောင့် ခုံပေးစရာ မလိုတာလဲ။"
        ),
        "eigo-japan": (
            ja: "言語の話？ それとも「英語」という単語の話？",
            zh: "问的是英语这种语言，还是「英語」这个词本身？",
            en: "Is this about the English language, or the word 英語?",
            my: "အင်္ဂလိပ်ဘာသာကို မေးတာလား၊ 「英語」 စကားလုံးကို မေးတာလား။"
        ),
        "taro-siblings": (
            ja: "問題文の最初の名前、忘れないで。",
            zh: "题目开头那个人，也算孩子吗？",
            en: "Don't forget the name at the start of the question.",
            my: "မေးခွန်းအစက နာမည်ကို မမေ့ပါနှင့်။"
        ),
        "hut-entrance": (
            ja: "入口は、出るときにも使える？",
            zh: "入口的门，出去的时候也能用吗？",
            en: "Can an entrance also be used to leave?",
            my: "ဝင်ပေါက်ကို ထွက်ဖို့လည်း သုံးလို့ရသလား။"
        ),
        "dice-six": (
            ja: "「6以上」に、6自身は入る？",
            zh: "「6 以上」包不包括 6 自己？",
            en: "Does “6 or more” include 6 itself?",
            my: "“၆ နှင့်အထက်” ထဲမှာ ၆ ကိုယ်တိုင် ပါသလား။"
        ),
        "months-28": (
            ja: "「28日がある」と「28日しかない」は違うよ。",
            zh: "「有第 28 天」和「只有 28 天」，不是一回事。",
            en: "“Has a 28th day” is not “has only 28 days.”",
            my: "၂၈ ရက်ရှိသည် နှင့် ၂၈ ရက်သာရှိသည် မတူပါ။"
        ),
        "konbanwa": (
            ja: "返さなかったのは「こんばんは」だけ。夜だった？",
            zh: "没人回的只是「晚上好」。当时一定是晚上吗？",
            en: "Nobody returned “good evening.” Was it even night?",
            my: "ပြန်မပြောတာ “ညနေခင်းမင်္ဂလာပါ” ပဲ။ ညဟုတ်ရဲ့လား။"
        ),
        "strap-hand": (
            ja: "「何で」は理由？ それとも道具？",
            zh: "「何で」是问为什么，还是问用什么？",
            en: "Does 何で ask why, or what you use?",
            my: "「何で」 က ဘာကြောင့်လဲ၊ သို့မဟုတ် ဘာနှင့်လဲ။"
        ),
        "one-to-twenty": (
            ja: "1から20までの数じゃなくて、書いてある文字を見て。",
            zh: "别数 1 到 20，看看「1から20」这几个字里有没有 7。",
            en: "Don't count 1 to 20. Look at the written phrase.",
            my: "၁ မှ ၂၀ မရေပါနှင့်။ ရေးထားသော စာကို ကြည့်ပါ။"
        ),
        "ten-years-later": (
            ja: "職業より、年齢の方が確実だよ。",
            zh: "以后做什么不确定，年纪却可以算出来。",
            en: "His job is a guess. His age is certain.",
            my: "အလုပ်က ခန့်မှန်းချက်။ အသက်က သေချာသည်။"
        ),
        "north-ken": (
            ja: "「県」と書いてある。道・府・県は別物だよ。",
            zh: "题目写的是「县」。北海道是「道」，不是县。",
            en: "It says 県. Hokkaido is a 道, not a prefecture of that kind.",
            my: "「県」 လို့ရေးထားသည်။ ဟော့ကိုင်းဒိုးက 道၊ 県 မဟုတ်။"
        ),
        "fire-elsewhere": (
            ja: "「その場」は、火事の場所と同じ？",
            zh: "「那个地方」一定就是火灾现场吗？",
            en: "Is “that place” necessarily where the fire is?",
            my: "“အဲဒီနေရာ” က မီးလောင်ရာနှင့် တူသလား။"
        ),
        "ramen-two": (
            ja: "何杯食べたか、書いてある？",
            zh: "题目有说只吃了一碗吗？",
            en: "Does it actually say you ate only one bowl?",
            my: "တစ်ပွဲသာ စားသည်ဟု ရေးထားသလား။"
        ),
        "kakigori": (
            ja: "文字を逆さにする話？ 本物を逆さにする話？",
            zh: "倒过来的是这两个字，还是碗里的刨冰？",
            en: "Are you flipping the letters, or the actual shaved ice?",
            my: "စာလုံးပြောင်းပြန်လား၊ ရေခဲမုန့်ကိုယ်တိုင်လား။"
        ),
        "bouquets": (
            ja: "合わせたら、束は増える？ 一つになる？",
            zh: "三束合在一起，还是三束，还是变成一束？",
            en: "If you put them together, is that still three, or one?",
            my: "ပေါင်းလိုက်ရင် သုံးစည်းကျန်သလား၊ တစ်စည်းဖြစ်သလား။"
        ),
        "othello": (
            ja: "片面黒・片面白のコマは、何種類？",
            zh: "一面黑、一面白的棋子，算几种？",
            en: "A piece that is black on one side and white on the other: how many kinds is that?",
            my: "တစ်ဖက်အမည်း တစ်ဖက်အဖြူ အကွက်ကို ဘယ်နှစ်မျိုးရေမလဲ။"
        ),
        "black-clothes": (
            ja: "汚れで黒くなった？ もともと黒い服？",
            zh: "是脏成黑色的，还是衣服本来就是黑的？",
            en: "Did dirt turn them black, or were they already black?",
            my: "ညစ်လို့ မည်းတာလား၊ မူလက အမည်းရောင်လား။"
        ),
        "marathon-fifth": (
            ja: "抜く前、自分は何位にいた？",
            zh: "超过第五名之前，你自己是第几名？",
            en: "Before you passed 5th place, what place were you in?",
            my: "မကျော်ခင် သင် ဘယ်အဆင့်မှာလဲ။"
        ),
        "crawl-feet": (
            ja: "足だけ数えて。手は足じゃないよ。",
            zh: "只数脚。爬的时候用手，手不算脚。",
            en: "Count feet only. Hands used to crawl are not feet.",
            my: "ခြေထောက်သာ ရေတွက်ပါ။ လက်က ခြေမဟုတ်။"
        ),
        "osaka-fu": (
            ja: "大阪は「県」？ それとも「府」？",
            zh: "大阪是「县」，还是「府」？",
            en: "Is Osaka a 県, or a 府?",
            my: "အိုဆာကာက 県 လား၊ 府 လား။"
        ),
        "five-necks": (
            ja: "「首」がつく場所、体にいくつある？",
            zh: "日语里带「首」的部位，身上有几处？",
            en: "How many body parts include the character 首?",
            my: "「首」 ပါသော ခန္ဓာကိုယ်နေရာ ဘယ်နှစ်ခုရှိသလဲ။"
        ),
        "hide-seek": (
            ja: "かくれんぼの人数、全員隠れる？",
            zh: "捉迷藏的五个人，全都在藏吗？",
            en: "In hide-and-seek, is everyone hiding?",
            my: "ပုန်းကစားသူ ၅ ယောက် အားလုံး ပုန်းနေသလား။"
        ),
        "momotaro": (
            ja: "犬より前に会った相手は？",
            zh: "遇到狗之前，桃太郎先见到了谁？",
            en: "Who did he meet before the dog?",
            my: "ခွေးမတွေ့ခင် ဘယ်သူ့ကို အရင်တွေ့သလဲ။"
        ),
        "diamond-ace": (
            ja: "真ん中以外にも、絵が描いてあるよ。",
            zh: "除了中间，牌角上也有图案。",
            en: "Look at the corners too, not just the center.",
            my: "အလယ်တင်မက ထောင့်တွေမှာလည်း ပုံရှိသည်။"
        ),
    ]
}

extension StroopRound {
    var catHint: String? {
        guard let id = Self.teaserID(from: stimulus), BrainTeaserBank.template(id: id) != nil else { return nil }
        return BrainTeaserBank.hint(id: id)
    }
}
