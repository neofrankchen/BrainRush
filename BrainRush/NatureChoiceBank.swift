import Foundation

/// 自然2択：生き物・天文・地理の自然。
enum NatureChoiceBank {
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
                task: .natureChoice,
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
            id: "nat-wombat",
            ja: "ウォンバットのうんちは何形？",
            zh: "袋熊的大便是什么形状？",
            en: "What shape is wombat poop?",
            my: "ဝုမ်းဘတ် ကျင်ကြီး ပုံစံက ဘာလဲ။",
            answerID: "square",
            choices: [
                ("square", "四角", "方形", "Square", "စတုရန်း"),
                ("round", "丸", "圆形", "Round", "လုံး"),
            ],
            explainJA: "正解は四角。ウォンバットのうんちは立方体に近い。縄張りを示すためと言われる。",
            explainZH: "正确答案是方形。袋熊的粪便接近立方体，常说是用来标记地盘。",
            explainEN: "Almost cubes. Wombats use them to mark territory.",
            explainMY: "အဖြေမှန်က စတုရန်း။ နယ်မြေပြရန်ဟု ဆိုသည်။"
        ),
        Item(
            id: "nat-octopus-heart",
            ja: "タコの心臓はいくつ？",
            zh: "章鱼有几颗心脏？",
            en: "How many hearts does an octopus have?",
            my: "ရေဘဝဲ နှလုံး ဘယ်နှစ်ခုရှိသလဲ။",
            answerID: "three",
            choices: [
                ("three", "3つ", "3颗", "Three", "၃ ခု"),
                ("one", "1つ", "1颗", "One", "၁ ခု"),
            ],
            explainJA: "正解は3つ。全身用が1つ、えら用が2つ。",
            explainZH: "正确答案是 3 颗。1 颗供全身，2 颗给鳃。",
            explainEN: "Three: one for the body and two for the gills.",
            explainMY: "အဖြေမှန်က ၃ ခု။ ကိုယ်ခန္ဓာ ၁၊ ပါးဟက် ၂။"
        ),
        Item(
            id: "nat-seahorse",
            ja: "タツノオトシゴで出産するのは？",
            zh: "海马由雄性还是雌性生产？",
            en: "Which seahorse gives birth?",
            my: "ပင်လယ်မြင်း မွေးသူက ဘယ်ဟာလဲ။",
            answerID: "male",
            choices: [
                ("female", "メス", "雌性", "The female", "အမ"),
                ("male", "オス", "雄性", "The male", "အထီး"),
            ],
            explainJA: "正解はオス。オスが育児嚢で卵を育てて産む。",
            explainZH: "正确答案是雄性。雄海马用育儿袋孵卵再生产。",
            explainEN: "The male carries eggs in a pouch and gives birth.",
            explainMY: "အဖြေမှန်က အထီး။ အိတ်ထဲတွင် ဥ ထိန်းသည်။"
        ),
        Item(
            id: "nat-butterfly",
            ja: "チョウが味を感じるのは？",
            zh: "蝴蝶主要用哪里感受味道？",
            en: "Where do butterflies taste?",
            my: "လိပ်ပြာ အရသာ ဘယ်မှာ ခံစားသလဲ။",
            answerID: "feet",
            choices: [
                ("feet", "足", "脚", "Their feet", "ခြေ"),
                ("tongue", "舌", "舌头", "Their tongue", "လျှာ"),
            ],
            explainJA: "正解は足。チョウは足のセンサーで味を見る。",
            explainZH: "正确答案是脚。蝴蝶用脚上的感觉器尝味道。",
            explainEN: "Butterflies taste with sensors on their feet.",
            explainMY: "အဖြေမှန်က ခြေ။ ခြေတွင် အရသာ အာရုံခံသည်။"
        ),
        Item(
            id: "nat-flamingo",
            ja: "生まれたばかりのフラミンゴの羽は？",
            zh: "刚出生的火烈鸟羽毛通常是什么颜色？",
            en: "What color are flamingo chicks?",
            my: "မွေးကင်းစ ဖလာမင်ဂို အမွေးက ဘာအရောင်လဲ။",
            answerID: "gray",
            choices: [
                ("gray", "灰色っぽい色", "偏灰色", "Grayish", "မီးခိုးရောင်"),
                ("pink", "ピンク", "粉色", "Pink", "ပန်းရောင်"),
            ],
            explainJA: "正解は灰色っぽい色。ピンクはあとからえさの色素でつく。",
            explainZH: "正确答案是偏灰色。粉色是后来吃的食物色素染上的。",
            explainEN: "Chicks are grayish. Pink comes later from food pigments.",
            explainMY: "အဖြေမှန်က မီးခိုးရောင်။ ပန်းရောင်က စားသောက်မှုကြောင့် နောက်မှ။"
        ),
        Item(
            id: "nat-venus",
            ja: "金星ではどちらの時間が長い？",
            zh: "金星自转一圈与公转一圈哪个时间更长？",
            en: "On Venus, which takes longer?",
            my: "ဗီးနပ်စ်တွင် ဘယ်အချိန် ပိုကြာသလဲ။",
            answerID: "spin",
            choices: [
                ("orbit", "公転1周", "公转一周", "One orbit", "ပတ်လမ်း ၁ ပတ်"),
                ("spin", "自転1回", "自转一圈", "One spin", "ကိုယ်လှည့် ၁ ကြိမ်"),
            ],
            explainJA: "正解は自転1回。金星の自転は公転より長い。",
            explainZH: "正确答案是自转一圈。金星自转比公转还慢。",
            explainEN: "One spin. A Venus day is longer than its year.",
            explainMY: "အဖြေမှန်က ကိုယ်လှည့် ၁ ကြိမ်။ နှစ်ထက် နေ့ ပိုကြာသည်။"
        ),
        Item(
            id: "nat-shark-tree",
            ja: "サメと木、地球に先に現れたのは？",
            zh: "鲨鱼和树木谁更早出现在地球？",
            en: "What appeared first, sharks or trees?",
            my: "ငါးမန်းနှင့် သစ်ပင်၊ ကမ္ဘာတွင် အရင်ရောက်သူက ဘယ်ဟာလဲ။",
            answerID: "shark",
            choices: [
                ("shark", "サメ", "鲨鱼", "Sharks", "ငါးမန်း"),
                ("tree", "木", "树木", "Trees", "သစ်ပင်"),
            ],
            explainJA: "正解はサメ。サメの祖先は木が広まるよりずっと前にいた。",
            explainZH: "正确答案是鲨鱼。鲨鱼祖先比树木在地球上普及更早。",
            explainEN: "Sharks. Their ancestors lived long before trees spread.",
            explainMY: "အဖြေမှန်က ငါးမန်း။ သစ်ပင်ထက် စောသည်။"
        ),
        Item(
            id: "nat-giraffe-neck",
            ja: "キリンと人間、首の骨の数は？",
            zh: "长颈鹿与人类的颈椎数量相比如何？",
            en: "Giraffe vs human neck bones?",
            my: "သစ်ကုလားအုတ်နှင့် လူ၊ လည်ပင်းအရိုး အရေအတွက်ကော။",
            answerID: "same",
            choices: [
                ("more", "キリンが多い", "长颈鹿更多", "The giraffe has more", "သစ်ကုလားအုတ် ပိုများ"),
                ("same", "同じ", "一样多", "The same number", "တူညီ"),
            ],
            explainJA: "正解は同じ。どちらも頸椎はだいたい7個。キリンは1本1本が長い。",
            explainZH: "正确答案是一样多。两者颈椎大约都是 7 块，长颈鹿每一块更长。",
            explainEN: "About seven cervical vertebrae each. Giraffe bones are just longer.",
            explainMY: "အဖြေမှန်က တူညီ။ နှစ်ခုလုံး လည်ပင်းအရိုး ၇ ခုခန့်။"
        ),
        Item(
            id: "nat-dolphin-sleep",
            ja: "イルカが眠るとき、脳はどう休む？",
            zh: "海豚睡觉时大脑如何休息？",
            en: "How does a dolphin's brain rest?",
            my: "လင်းပိုင် အိပ်သည့်အခါ ဦးနှောက် ဘယ်လို အနားယူသလဲ။",
            answerID: "half",
            choices: [
                ("all", "全部同時に", "全部同时", "All at once", "အားလုံး တပြိုင်နက်"),
                ("half", "半分ずつ", "一半一半", "One half at a time", "တစ်ဝက်စီ"),
            ],
            explainJA: "正解は半分ずつ。片方の脳を休めて、もう片方で泳ぎ呼吸する。",
            explainZH: "正确答案是一半一半。一边大脑休息，另一边继续游泳呼吸。",
            explainEN: "One hemisphere sleeps while the other keeps swimming and breathing.",
            explainMY: "အဖြေမှန်က တစ်ဝက်စီ။ တစ်ခြမ်း အနားယူ၊ တစ်ခြမ်း ကူးသည်။"
        ),
        Item(
            id: "nat-penguin-knee",
            ja: "ペンギンにひざはある？",
            zh: "企鹅有膝盖吗？",
            en: "Do penguins have knees?",
            my: "ပင်ဂွင်း ဒူး ရှိသလား။",
            answerID: "yes",
            choices: [
                ("yes", "ある", "有", "Yes", "ရှိသည်"),
                ("no", "ない", "没有", "No", "မရှိ"),
            ],
            explainJA: "正解はある。ひざは体の羽毛の中に隠れている。",
            explainZH: "正确答案是有。膝盖藏在身体的羽毛里面。",
            explainEN: "Yes. The knees are hidden under feathers on the body.",
            explainMY: "အဖြေမှန်က ရှိသည်။ အမွေးထဲ ပုန်းနေသည်။"
        ),
        Item(
            id: "nat-otter",
            ja: "ラッコがわきの下にしまうことがあるのは？",
            zh: "海獭有时会把什么藏在腋下？",
            en: "What do sea otters tuck under an arm?",
            my: "ပင်လယ်ဖျံ လက်မောင်းအောက် သိမ်းတတ်တာက ဘာလဲ။",
            answerID: "rock",
            choices: [
                ("rock", "石や食べ物", "石头或食物", "A rock or food", "ကျောက် သို့မဟုတ် အစား"),
                ("water", "海水", "海水", "Seawater", "ပင်လယ်ရေ"),
            ],
            explainJA: "正解は石や食べ物。貝を割る石や餌をわきにしまっておく。",
            explainZH: "正确答案是石头或食物。海獭把砸贝壳的石头或食物夹在腋下。",
            explainEN: "A rock or food. They stash shell-cracking stones and snacks.",
            explainMY: "အဖြေမှန်က ကျောက် သို့မဟုတ် အစား။ ပင်လယ်ရေ မဟုတ်။"
        ),
        Item(
            id: "nat-cucumber",
            ja: "一部のナマコが敵から身を守るために出すのは？",
            zh: "有些海参为了自卫会排出什么？",
            en: "What do some sea cucumbers eject to defend themselves?",
            my: "ပင်လယ်သခွား သူရဲဘုရားကာကွယ်ရန် ထုတ်တာက ဘာလဲ။",
            answerID: "guts",
            choices: [
                ("ink", "墨", "墨汁", "Ink", "မင်"),
                ("guts", "内臓", "内脏", "Internal organs", "အတွင်းအင်္ဂါ"),
            ],
            explainJA: "正解は内臓。危険だと内臓を出して逃げる種類がいる。墨を出すのはイカなど。",
            explainZH: "正确答案是内脏。有的海参遇敌会排出内脏逃走。喷墨的是乌贼一类。",
            explainEN: "Organs. Some eviscerate to escape. Ink is for squid.",
            explainMY: "အဖြေမှန်က အတွင်းအင်္ဂါ။ မင်က စကွစ်။"
        ),
        Item(
            id: "nat-berry",
            ja: "植物学でベリーの仲間なのは？",
            zh: "植物学上的真正浆果是哪一个？",
            en: "Which is a true berry in botany?",
            my: "အပင်ဗေဒအရ ဘယ်ရီ မျိုးက ဘယ်ဟာလဲ။",
            answerID: "banana",
            choices: [
                ("banana", "バナナ", "香蕉", "A banana", "ငှက်ပျော"),
                ("strawberry", "イチゴ", "草莓", "A strawberry", "စတော်ဘယ်ရီ"),
            ],
            explainJA: "正解はバナナ。植物学ではバナナはベリー。イチゴはそう分類されない。",
            explainZH: "正确答案是香蕉。植物学上香蕉是浆果，草莓通常不算真正浆果。",
            explainEN: "A banana is a true berry. A strawberry is not.",
            explainMY: "အဖြေမှန်က ငှက်ပျော။ စတော်ဘယ်ရီက တကယ့် ဘယ်ရီ မဟုတ်။"
        ),
        Item(
            id: "nat-peanut",
            ja: "ピーナッツは植物学上、何の仲間？",
            zh: "花生在植物学上属于哪一类？",
            en: "What is a peanut botanically?",
            my: "ပဲလင်းမြွေ အပင်ဗေဒအရ ဘာမျိုးလဲ။",
            answerID: "legume",
            choices: [
                ("legume", "豆の仲間", "豆类", "A legume", "ပဲမျိုး"),
                ("nut", "木の実（ナッツ）", "坚果", "A tree nut", "သစ်စေ့"),
            ],
            explainJA: "正解は豆の仲間。ピーナッツは地中で実る豆。木の実ではない。",
            explainZH: "正确答案是豆类。花生是长在土里的豆子，不是树上的坚果。",
            explainEN: "A legume that grows underground, not a tree nut.",
            explainMY: "အဖြေမှန်က ပဲမျိုး။ သစ်ပင်စေ့ မဟုတ်။"
        ),
        Item(
            id: "nat-antarctica",
            ja: "南極は砂漠に分類される？",
            zh: "南极属于沙漠吗？",
            en: "Is Antarctica classed as a desert?",
            my: "တောင်ဝင်ရိုးစွန်းကို သဲကန္တာရဟု သတ်မှတ်သလား။",
            answerID: "yes",
            choices: [
                ("no", "いいえ", "不是", "No", "မဟုတ်"),
                ("yes", "はい", "是", "Yes", "ဟုတ်"),
            ],
            explainJA: "正解ははい。雨や雪がとても少なく、寒冷砂漠に分類される。",
            explainZH: "正确答案是。南极降水极少，属于寒冷沙漠。",
            explainEN: "Yes. It gets so little precipitation that it counts as a cold desert.",
            explainMY: "အဖြေမှန်က ဟုတ်။ မိုးနှင်း နည်း၍ အေးသော သဲကန္တာရ။"
        ),
        Item(
            id: "nat-moon",
            ja: "月は毎年、地球からどうなる？",
            zh: "月球与地球的距离每年怎样变化？",
            en: "What happens to the Moon each year?",
            my: "လသည် နှစ်စဉ် ကမ္ဘာနှင့် ဘယ်လို ဖြစ်သလဲ။",
            answerID: "away",
            choices: [
                ("away", "離れる", "变远", "It moves farther away", "ပိုဝေး"),
                ("closer", "近づく", "变近", "It moves closer", "ပိုနီး"),
            ],
            explainJA: "正解は離れる。月は毎年数センチ地球から遠ざかっている。",
            explainZH: "正确答案是变远。月球每年大约远离地球几厘米。",
            explainEN: "It recedes a few centimeters each year.",
            explainMY: "အဖြေမှန်က ပိုဝေး။ နှစ်စဉ် စင်တီမီတာ အနည်းငယ် ဝေးသည်။"
        ),
        Item(
            id: "nat-cloud",
            ja: "約1立方キロの典型的な積雲の水滴の重さは？",
            zh: "约1立方公里典型积云中的水滴估计有多重？",
            en: "About how heavy is the water in 1 km³ of typical cumulus?",
            my: "စုပုံတိမ် ၁ ကုဗကီလိုမီတာ ရေစက် အလေးချိန်ခန့်က ဘယ်လောက်လဲ။",
            answerID: "tons",
            choices: [
                ("tons", "約500トン", "约500吨", "About 500 tons", "တန် ၅၀၀ ခန့်"),
                ("kilos", "約500キロ", "约500公斤", "About 500 kilograms", "ကီလို ၅၀၀ ခန့်"),
            ],
            explainJA: "正解は約500トン。小さく見える水滴でも、雲全体では数百トンになる。",
            explainZH: "正确答案是约 500 吨。小水滴加起来，整朵积云能有几百吨。",
            explainEN: "About 500 tons. Tiny droplets add up across the whole cloud.",
            explainMY: "အဖြေမှန်က တန် ၅၀၀ ခန့်။ ကီလို ၅၀၀ မဟုတ်။"
        ),
        Item(
            id: "nat-jellyfish",
            ja: "大人から若い段階に戻れる種類のクラゲはいる？",
            zh: "有些水母能从成年阶段恢复到幼体阶段吗？",
            en: "Can some jellyfish revert to a younger stage?",
            my: "အရွယ်ရောက်ပြီး ပြန်နုနိုင်သော ဂျယ်လီဖစ် ရှိသလား။",
            answerID: "yes",
            choices: [
                ("no", "いない", "没有", "No", "မရှိ"),
                ("yes", "いる", "有", "Yes", "ရှိသည်"),
            ],
            explainJA: "正解はいる。ベニクラゲなどは条件によって若い段階に戻れる。",
            explainZH: "正确答案是有。灯塔水母等在某些条件下能回到幼体阶段。",
            explainEN: "Yes. Turritopsis and some others can revert toward a younger stage.",
            explainMY: "အဖြေမှန်က ရှိသည်။ အချို့ ဂျယ်လီဖစ် ပြန်နုနိုင်သည်။"
        ),
        Item(
            id: "nat-koala",
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
    ]
}
