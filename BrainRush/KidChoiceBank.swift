import Foundation

/// 幼児2択：保育園・幼稚園向けの簡単二択。ほかの2択とは別ファイル。
enum KidChoiceBank {
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
                task: .kidChoice,
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
            id: "kid-sheep",
            ja: "「メ―メ―」と鳴く、もこもこした毛の動物は何でしょうか？",
            zh: "会「咩咩」叫、毛毛茸茸的动物是什么？",
            en: "Which fluffy animal says “baa baa”?",
            my: "«မေမေ» ဟု မြည်သော အမွေးပွတိရစ္ဆာန်က ဘာလဲ။",
            answerID: "sheep",
            choices: [
                ("sheep", "ひつじ", "绵羊", "Sheep", "သိုး"),
                ("horse", "うま", "马", "Horse", "မြင်း"),
            ],
            explainJA: "「メーメー」と鳴くもこもこした毛の動物は、ひつじです。ひつじの毛はウールと呼ばれ、服やクッションなどに使われます。うまは、「ヒヒーン」と鳴きます。",
            explainZH: "会「咩咩」叫、毛毛茸茸的是绵羊。羊毛叫ウール，用来做衣服和靠垫。马是「嘶嘶」叫的。",
            explainEN: "The fluffy animal that says baa is a sheep. Its wool is used for clothes and cushions. A horse neighs.",
            explainMY: "မေမေဟု မြည်သော အမွေးပွသည် သိုး။ သိုးမွေးကို အဝတ်နှင့် ကူရှင်လုပ်သည်။ မြင်းက ဟီဟီဟု မြည်သည်။"
        ),
        Item(
            id: "kid-ear",
            ja: "音を聞くことができるのは、体のどの部分でしょうか？",
            zh: "能听见声音的是身体的哪一部分？",
            en: "Which body part can hear sounds?",
            my: "အသံကြားနိုင်သော ခန္ဓာကိုယ်အစိတ်အပိုင်းက ဘယ်ဟာလဲ။",
            answerID: "ear",
            choices: [
                ("ear", "耳", "耳朵", "Ear", "နား"),
                ("nose", "鼻", "鼻子", "Nose", "နှာခေါင်း"),
            ],
            explainJA: "耳で、いろいろな音を聞くことができます。鼻は、ニオイをかぐことができます。",
            explainZH: "用耳朵可以听见各种各样的声音。鼻子是用来闻气味的。",
            explainEN: "You hear sounds with your ears. The nose is for smelling.",
            explainMY: "နားဖြင့် အသံကြားသည်။ နှာခေါင်းဖြင့် အနံ့နမ်းသည်။"
        ),
        Item(
            id: "kid-cicada",
            ja: "夏に「ミーンミーン」と鳴く虫は何でしょうか？",
            zh: "夏天会「唧唧」叫的虫子是什么？",
            en: "Which insect goes “meen meen” in summer?",
            my: "နွေရာသီ «မင်းမင်း» ဟု မြည်သော ပိုးက ဘာလဲ။",
            answerID: "cicada",
            choices: [
                ("cicada", "セミ", "蝉", "Cicada", "ဆစ်ကေးဒါ"),
                ("dragonfly", "とんぼ", "蜻蜓", "Dragonfly", "ပိတုန်း"),
            ],
            explainJA: "セミは、木にとまって「ミーンミーン」と鳴く虫です。鳴いているのは、オスのセミだけで、メスは鳴きません。トンボは鳴きません。",
            explainZH: "蝉会停在树上「唧唧」叫。只有雄蝉会叫，雌蝉不叫。蜻蜓不会叫。",
            explainEN: "Cicadas sit on trees and sing. Only the males sing. Dragonflies do not.",
            explainMY: "ဆစ်ကေးဒါသည် သစ်ပင်ပေါ် မြည်သည်။ အထီးသာ မြည်သည်။ ပိတုန်း မမြည်။"
        ),
        Item(
            id: "kid-milk",
            ja: "牛さんがわたしたちに分けてくれる飲み物は何でしょうか？",
            zh: "牛会分给我们喝的饮料是什么？",
            en: "What drink do cows share with us?",
            my: "နွားက ကျွန်ုပ်တို့ကို ပေးသော သောက်စရာက ဘာလဲ။",
            answerID: "milk",
            choices: [
                ("milk", "牛乳", "牛奶", "Milk", "နွားနို့"),
                ("calpis", "カルピス", "可尔必思", "Calpis", "ကာရုပိစ်"),
            ],
            explainJA: "牛乳は、牛のお乳から作られた飲み物です。カルシウムという栄養がたくさん入っているので、骨が丈夫になったり、背が伸びたりします。",
            explainZH: "牛奶是用牛的奶做成的。里面钙很多，能让骨头更结实、个子长高。",
            explainEN: "Milk comes from cows. It has lots of calcium, which helps bones grow strong and tall.",
            explainMY: "နွားနို့သည် နွားရဲ့နို့မှ လုပ်သည်။ ကယ်လ်စီယမ်များ၍ အရိုးခိုင်ပြီး အရပ်တက်သည်။"
        ),
        Item(
            id: "kid-onigiri",
            ja: "三角でシャケやうめなどの具が入っている、のりがついた食べ物は何でしょうか？",
            zh: "三角形、里面有鲑鱼或梅子馅、外面有海苔的食物是什么？",
            en: "What triangular food has filling like salmon or plum and nori on it?",
            my: "တြိဂံပုံ၊ ဆယ်မွန်/ဥမဲ ပါပြီး နိုရီကပ်ထားသော အစာက ဘာလဲ။",
            answerID: "onigiri",
            choices: [
                ("onigiri", "おにぎり", "饭团", "Onigiri", "အိုနိဂိရိ"),
                ("inari", "いなりずし", "油豆腐寿司", "Inari sushi", "အိနရိဇုရှိ"),
            ],
            explainJA: "おにぎりは、中に具が入っていて、のりがついたさんかくの食べ物です。お弁当などによく入っています。いなりずしは、甘いあぶらあげの中にご飯を入れてにぎった食べ物です。",
            explainZH: "饭团是里面有馅、外面有海苔的三角形食物，便当里常有。油豆腐寿司是把米饭塞进甜甜的油豆腐里。",
            explainEN: "Onigiri is a triangle of rice with filling and nori, often in bento. Inari sushi is rice inside sweet fried tofu.",
            explainMY: "အိုနိဂိရိသည် ဟင်းပါ၊ နိုရီကပ်သော တြိဂံထမင်း။ အိနရိဇုရှိသည် ချိုသော အဘူရာအာဂဲထဲ ထမင်းထည့်သည်။"
        ),
        Item(
            id: "kid-owl",
            ja: "「ホーホー」と鳴く動物は何でしょうか？",
            zh: "会「咕咕」叫的动物是什么？",
            en: "Which animal says “hoo hoo”?",
            my: "«ဟိုဟို» ဟု မြည်သော တိရစ္ဆာန်က ဘာလဲ။",
            answerID: "owl",
            choices: [
                ("pigeon", "ハト", "鸽子", "Pigeon", "ချိုး"),
                ("owl", "ふくろう", "猫头鹰", "Owl", "ဇီးကွက်"),
            ],
            explainJA: "「ホーホー」と鳴く鳥は、ふくろうです。フクロウは昼間は体を休めて、夜は活動的に狩りをします。",
            explainZH: "会「咕咕」叫的是猫头鹰。白天休息，夜里出来打猎。",
            explainEN: "The bird that says hoo hoo is an owl. Owls rest by day and hunt at night.",
            explainMY: "ဟိုဟိုဟု မြည်သည်မှာ ဇီးကွက်။ နေ့အနားယူ၊ ညအမဲလိုက်သည်။"
        ),
        Item(
            id: "kid-watermelon",
            ja: "緑と黒のシマシマ模様の皮で、中が赤い果物は何でしょうか？",
            zh: "绿黑条纹皮、里面是红的水果是什么？",
            en: "Which fruit has green-and-black striped skin and a red inside?",
            my: "အစိမ်း-မည်း ကြားစင်းခွံ၊ အတွင်းနီသော သစ်သီးက ဘာလဲ။",
            answerID: "watermelon",
            choices: [
                ("watermelon", "すいか", "西瓜", "Watermelon", "ဖရဲသီး"),
                ("melon", "メロン", "蜜瓜", "Melon", "မယ်လွန်"),
            ],
            explainJA: "すいかは、皮が緑と黒のシマシマ模様をしていて、切ると中身が赤い果物です。つめたく冷やして食べる、夏にぴったりのたべものです。",
            explainZH: "西瓜皮是绿黑条纹，切开里面是红的。冰镇后吃，很适合夏天。",
            explainEN: "Watermelon has striped green-and-black skin and a red inside. It is a summer fruit, best eaten cold.",
            explainMY: "ဖရဲသီးခွံ အစိမ်း-မည်း ကြားစင်း၊ အတွင်းနီသည်။ အေးအောင်စားရင် နွေနှင့် ကိုက်သည်။"
        ),
        Item(
            id: "kid-dog",
            ja: "「わんわん」と鳴く動物は何でしょうか？",
            zh: "会「汪汪」叫的动物是什么？",
            en: "Which animal says “woof woof”?",
            my: "«ဝေါင်ဝေါင်» ဟု မြည်သော တိရစ္ဆာန်က ဘာလဲ။",
            answerID: "dog",
            choices: [
                ("dog", "いぬ", "狗", "Dog", "ခွေး"),
                ("cat", "ねこ", "猫", "Cat", "ကြောင်"),
            ],
            explainJA: "いぬは「わんわん」と鳴きます。ねこは「ニャー」と鳴きます。いぬはとっても鼻がよくて、遠くにあるもののにおいも嗅ぎ分けることができます。",
            explainZH: "狗会「汪汪」叫，猫会「喵」。狗的鼻子很灵，远处的气味也能分辨。",
            explainEN: "Dogs say woof. Cats say meow. Dogs have a sharp nose and can smell things far away.",
            explainMY: "ခွေးက ဝေါင်ဝေါင်၊ ကြောင်က ညောင်။ ခွေးနှာခေါင်း အလွန်ကောင်းသည်။"
        ),
        Item(
            id: "kid-fan",
            ja: "スイッチを入れるとプロペラがまわり、風を出す機械を何というでしょうか？",
            zh: "打开开关后螺旋桨转动、会吹风的机器叫什么？",
            en: "What machine spins a propeller and makes wind when you switch it on?",
            my: "ခလုတ်ဖွင့်ရင် ပန်ကာလှည့်ပြီး လေထုတ်သော စက်က ဘာလဲ။",
            answerID: "fan",
            choices: [
                ("washer", "せんたくき", "洗衣机", "Washing machine", "အဝတ်လျှော်စက်"),
                ("fan", "せんぷうき", "电风扇", "Electric fan", "ပန်ကာ"),
            ],
            explainJA: "せんぷうきは、プロペラを回して風をおこす機械です。暑い夏に活躍します。せんたくきは、汚れた服などを洗う機械です。",
            explainZH: "电风扇靠转螺旋桨吹风，夏天很有用。洗衣机是用来洗脏衣服的。",
            explainEN: "A fan spins blades to make wind, handy in hot summer. A washer cleans dirty clothes.",
            explainMY: "ပန်ကာသည် လှည့်ပြီး လေထုတ်သည်။ အဝတ်လျှော်စက်က အဝတ်လျှော်သည်။"
        ),
        Item(
            id: "kid-bath",
            ja: "体やかみの毛を洗ったり、お湯の中に入ったりする場所を何というでしょうか？",
            zh: "可以洗身体、洗头发、泡进热水里的地方叫什么？",
            en: "Where do you wash your body and hair, and sit in hot water?",
            my: "ကိုယ်နှင့် ဆံပင်လျှော်၊ ရေနွေးထဲဝင်သော နေရာက ဘာလဲ။",
            answerID: "bath",
            choices: [
                ("pool", "プール", "游泳池", "Pool", "ရေကူးကန်"),
                ("bath", "おふろ", "浴室", "Bath", "ရေချိုးခန်း"),
            ],
            explainJA: "体や頭を洗ったり、バスタブに入れたお湯の中にはいる場所は、おふろです。おふろでは、せっけんやシャンプーをつかって体や頭を洗います。プールは、水着をつけて泳ぐ場所です。",
            explainZH: "洗身体、洗头、泡进浴缸的地方是浴室，用肥皂和洗发水。游泳池是穿泳衣游泳的地方。",
            explainEN: "The bath is where you wash with soap and shampoo and sit in the tub. A pool is for swimming in a swimsuit.",
            explainMY: "ရေချိုးခန်းတွင် ကိုယ်/ခေါင်းလျှော်၊ ရေနွေးထဲဝင်သည်။ ရေကူးကန်က ရေကူးရန်။"
        ),
        Item(
            id: "kid-giraffe",
            ja: "首が長くて足がほそい、背のたかい動物は何でしょうか？",
            zh: "脖子长、腿细、个子高的动物是什么？",
            en: "Which tall animal has a long neck and thin legs?",
            my: "လည်ပင်းရှည်၊ ခြေသေး၊ အရပ်မြင့်သော တိရစ္ဆာန်က ဘာလဲ။",
            answerID: "giraffe",
            choices: [
                ("giraffe", "キリン", "长颈鹿", "Giraffe", "သစ်ကုလားအုပ်"),
                ("elephant", "ゾウ", "大象", "Elephant", "ဆင်"),
            ],
            explainJA: "キリンは、首が長くて足がほそい動物です。背が高いので、高い木の上の葉っぱも上手に食べることができます。ゾウは、大きくて鼻が長い動物です。",
            explainZH: "长颈鹿脖子长、腿细。因为个子高，高处的叶子也能吃到。大象又大、鼻子又长。",
            explainEN: "A giraffe has a long neck and thin legs, so it can eat leaves high up. An elephant is big with a long trunk.",
            explainMY: "သစ်ကုလားအုပ် လည်ပင်းရှည်၊ ခြေသေး။ အရပ်မြင့်၍ အပေါ်ရွက် စားနိုင်သည်။ ဆင်က ကြီးပြီး နှာမောင်းရှည်။"
        ),
        Item(
            id: "kid-snow",
            ja: "冬のとても寒い日に、空から降ってくる白いものは何でしょうか？",
            zh: "冬天很冷的日子，从天上落下来的白色东西是什么？",
            en: "What white thing falls from the sky on very cold winter days?",
            my: "ဆောင်းအလွန်အေးသောနေ့ ကောင်းကင်မှ ကျသော အဖြူက ဘာလဲ။",
            answerID: "snow",
            choices: [
                ("snow", "雪", "雪", "Snow", "နှင်း"),
                ("rain", "雨", "雨", "Rain", "မိုး"),
            ],
            explainJA: "冬の寒い日に空から降ってくる白いものは、雪です。雪をよーく見ると、小さな氷の結晶があつまっていて、とてもきれいな形をしています。",
            explainZH: "冬天从天上落下的白色东西是雪。仔细看，是小小的冰晶聚在一起，形状很漂亮。",
            explainEN: "That white stuff is snow. Look closely and you see tiny ice crystals in pretty shapes.",
            explainMY: "အဖြူသည် နှင်း။ ကြည့်ရင် ရေခဲပုံဆောင်ခဲငယ်များ စုပြီး လှသော ပုံရှိသည်။"
        ),
        Item(
            id: "kid-cookie",
            ja: "サクサクしていて、甘くて茶色いお菓子は何でしょうか？",
            zh: "又酥又甜、棕色的点心是什么？",
            en: "Which brown sweet is crunchy?",
            my: "ကြွပ်ကြွပ်၊ ချို၊ အညိုရောင် မုန့်က ဘာလဲ။",
            answerID: "cookie",
            choices: [
                ("chocolate", "チョコレート", "巧克力", "Chocolate", "ချောကလက်"),
                ("cookie", "クッキー", "曲奇", "Cookie", "ကွတ်ကီး"),
            ],
            explainJA: "クッキーは、甘くて茶色いサクサクしたお菓子です。オーブンで焼いてつくるので、サクサクな食感になります。",
            explainZH: "曲奇又甜又棕又酥。用烤箱烤，所以是酥的。",
            explainEN: "Cookies are sweet, brown, and crunchy because they are baked in an oven.",
            explainMY: "ကွတ်ကီးသည် ချို၊ အညို၊ ကြွပ်သည်။ မီးဖိုတွင် ဖုတ်သောကြောင့်။"
        ),
        Item(
            id: "kid-turtle",
            ja: "背中に甲羅があって、ゆっくり歩く動物は、何でしょうか？",
            zh: "背上有壳、走得很慢的动物是什么？",
            en: "Which animal has a shell on its back and walks slowly?",
            my: "ကျောပေါ် အခွံရှိ၊ ဖြည်းဖြည်းလမ်းသော တိရစ္ဆာန်က ဘာလဲ။",
            answerID: "turtle",
            choices: [
                ("turtle", "かめ", "乌龟", "Turtle", "လိပ်"),
                ("chameleon", "カメレオン", "变色龙", "Chameleon", "ပုတ်သင်ညို"),
            ],
            explainJA: "かめは、背中に甲羅があります。かめは自分を守るため、硬い甲羅をもっていて、危険なことがあるとすぐに甲羅の中にあたま・うで・あしを引っ込めることができます。カメレオンは、体の色を自由自在にかえられる爬虫類です。",
            explainZH: "乌龟背上有硬壳，遇到危险可以把头、手、脚缩进去。变色龙是能随意变色的爬行动物。",
            explainEN: "A turtle has a hard shell and can pull in its head, arms, and legs. A chameleon can change color.",
            explainMY: "လိပ်တွင် မာသောအခွံရှိပြီး ခေါင်း/လက်/ခြေ ဆွဲသွင်းနိုင်သည်။ ပုတ်သင်ညိုက အရောင်ပြောင်းနိုင်သည်။"
        ),
        Item(
            id: "kid-softcream",
            ja: "冷たくて、ぐるぐる巻きのあまい食べ物は、何でしょうか？",
            zh: "又凉、一圈圈卷起来的甜食是什么？",
            en: "What cold, sweet treat is swirled around and around?",
            my: "အေးပြီး လည်လည်ရစ်သော အချိုက ဘာလဲ။",
            answerID: "softcream",
            choices: [
                ("sherbet", "シャーベット", "冰沙", "Sherbet", "ရှာဘတ်"),
                ("softcream", "ソフトクリーム", "软冰淇淋", "Soft-serve ice cream", "ဆော့ဖ်ခရင်မ်"),
            ],
            explainJA: "冷たくて甘いぐるぐる巻きのおいしい食べ物は、ソフトクリームです。ソフトクリームは、バニラ味のほかにも、チョコ・抹茶・いちごなどいろいろな味があります。シャーベットは、果物の汁が入ったシャリシャリした冷たいデザートです。",
            explainZH: "又凉又甜、一圈圈卷起来的是软冰淇淋，有香草、巧克力、抹茶、草莓等味道。冰沙是加了果汁、口感沙沙的凉点心。",
            explainEN: "The swirled cold sweet is soft-serve, in flavors like vanilla, chocolate, matcha, and strawberry. Sherbet is an icy fruit dessert.",
            explainMY: "လည်လည်ရစ်သော အအေးချိုသည် ဆော့ဖ်ခရင်မ်။ ရှာဘတ်သည် သစ်သီးရည်ပါသော ကြွပ်အအေး။"
        ),
        Item(
            id: "kid-monkey",
            ja: "木のぼりが上手で、おしりの赤い動物は何でしょうか？",
            zh: "很会爬树、屁股是红的动物是什么？",
            en: "Which animal is good at climbing trees and has a red bottom?",
            my: "သစ်ပင်တက်တတ်၊ တင်ပါးနီသော တိရစ္ဆာန်က ဘာလဲ။",
            answerID: "monkey",
            choices: [
                ("monkey", "さる", "猴子", "Monkey", "မျောက်"),
                ("rabbit", "うさぎ", "兔子", "Rabbit", "ယုန်"),
            ],
            explainJA: "木のぼりが上手なおしりの赤い動物は、サルです。サルは、バナナなどの果物が大好物です。ウサギは、ジャンプが得意な耳の長い動物です。",
            explainZH: "很会爬树、屁股红的是猴子，最爱香蕉等水果。兔子耳朵长，很会跳。",
            explainEN: "A monkey climbs well and may have a red bottom. Monkeys love fruit like bananas. Rabbits have long ears and jump well.",
            explainMY: "မျောက်သည် သစ်ပင်တက်တတ်၊ တင်ပါးနီနိုင်သည်။ ငှက်ပျောကြိုက်သည်။ ယုန် နားရှည်၊ ခုန်တတ်သည်။"
        ),
        Item(
            id: "kid-ship",
            ja: "人やものを乗せて、水の上を移動するのりものは何でしょうか？",
            zh: "载着人或东西在水上走的交通工具是什么？",
            en: "What vehicle carries people and things on water?",
            my: "လူ/ပစ္စည်းတင်ပြီး ရေပေါ်သွားသော ယာဉ်က ဘာလဲ။",
            answerID: "ship",
            choices: [
                ("plane", "飛行機", "飞机", "Airplane", "လေယာဉ်"),
                ("ship", "船", "船", "Ship / boat", "သင်္ဘော"),
            ],
            explainJA: "海や川・湖など水の上を移動して人や物を運ぶのは船です。飛行機は、空の上を飛ぶのりものです。船は、重油（じゅうゆ）という燃料でうごきます。",
            explainZH: "在海、河、湖上运人或东西的是船。飞机在天上飞。船用重油做燃料。",
            explainEN: "A ship or boat moves people and goods on seas, rivers, and lakes. Airplanes fly. Ships use heavy oil as fuel.",
            explainMY: "သင်္ဘောသည် ပင်လယ်/မြစ်/ကန်ပေါ် သယ်သည်။ လေယာဉ်က ကောင်းကင်ပျံသည်။"
        ),
        Item(
            id: "kid-penguin",
            ja: "寒いところが好きで、ペタペタ歩く動物は何というでしょうか？",
            zh: "喜欢寒冷的地方、啪嗒啪嗒走路的动物叫什么？",
            en: "Which animal likes the cold and walks with a pat-pat waddle?",
            my: "အေးသောနေရာကြိုက်၊ ပတ်ပတ်လျှောက်သော တိရစ္ဆာန်က ဘာလဲ။",
            answerID: "penguin",
            choices: [
                ("penguin", "ペンギン", "企鹅", "Penguin", "ပင်ဂွင်း"),
                ("seal", "アザラシ", "海豹", "Seal", "ဖျံ"),
            ],
            explainJA: "寒いところが好きなペタペタ歩く動物は、ペンギンです。ペンギンは鳥の仲間で、飛ぶことはできませんが泳ぐことが得意です。アザラシも寒いところが好きですが、移動するときはお腹をはうようにして移動します。",
            explainZH: "喜欢寒冷、啪嗒啪嗒走路的是企鹅。企鹅是鸟，不会飞但很会游泳。海豹也喜欢冷，移动时是用肚子爬。",
            explainEN: "Penguins like the cold and waddle. They are birds that cannot fly but swim well. Seals also like the cold but scoot on their bellies.",
            explainMY: "ပင်ဂွင်း အေးသောနေရာကြိုက်၊ ပတ်ပတ်လျှောက်သည်။ မပျံနိုင်၊ ကူးတတ်သည်။ ဖျံက ဗိုက်ဖြင့် တက်သည်။"
        ),
        Item(
            id: "kid-sakura",
            ja: "春に咲く、ピンクのきれいなお花は何でしょうか？",
            zh: "春天开的粉色漂亮花是什么？",
            en: "Which pretty pink flower blooms in spring?",
            my: "နွေဦးပွင့်သော ပန်းရင့်ရောင် လှသောပန်းက ဘာလဲ။",
            answerID: "sakura",
            choices: [
                ("sakura", "さくら", "樱花", "Cherry blossom", "ဆကုရာ"),
                ("dandelion", "たんぽぽ", "蒲公英", "Dandelion", "ဒန်ဒလီယွန်"),
            ],
            explainJA: "春にいっせいに咲くピンク色のきれいなお花は、さくらです。日本には、1000年以上も生きつづける長生きなさくらの木もあります。たんぽぽは、黄色いお花です。",
            explainZH: "春天一起开放的粉色漂亮花是樱花。日本还有活了一千多年的樱花树。蒲公英是黄花。",
            explainEN: "Cherry blossoms bloom pink all at once in spring. Some trees in Japan live more than 1,000 years. Dandelions are yellow.",
            explainMY: "နွေဦး တပြိုင်နက် ပွင့်သော ပန်းရင့်ရောင်သည် ဆကုရာ။ ဒန်ဒလီယွန်က အဝါ။"
        ),
        Item(
            id: "kid-crayon",
            ja: "絵をかくときや色をぬるときに使う、カラフルな道具は何でしょうか？",
            zh: "画画、涂色时用的五颜六色的工具是什么？",
            en: "Which colorful tool do you use to draw and color?",
            my: "ပုံဆွဲ/အရောင်သုတ်ရာသုံး ရောင်စုံကိရိယာက ဘာလဲ။",
            answerID: "crayon",
            choices: [
                ("pencil", "えんぴつ", "铅笔", "Pencil", "ခဲတံ"),
                ("crayon", "クレヨン", "蜡笔", "Crayon", "ခရေယွန်"),
            ],
            explainJA: "クレヨンは、絵を描くときや色をぬるときに使います。あか、あお、きいろ、みどり、みずいろ・・・と、いろんな色のクレヨンがあってカラフルです。えんぴつは木と芯でできていて、黒い色で文字を書く道具です。",
            explainZH: "蜡笔用来画画涂色，有红、蓝、黄、绿、浅蓝等很多颜色。铅笔是木头加笔芯，用来写黑字。",
            explainEN: "Crayons are for drawing and coloring, in many colors. A pencil is wood and lead for writing in black.",
            explainMY: "ခရေယွန်သည် ပုံဆွဲ/အရောင်သုတ်ရန် ရောင်စုံ။ ခဲတံက အနက်စာရေးရန်။"
        ),
        Item(
            id: "kid-saru-kani",
            ja: "昔話のさるかに合戦に出てくる虫はなんでしょうか？",
            zh: "日本民间故事「猴子和螃蟹打仗」里出现的虫子是什么？",
            en: "In the folk tale The Crab and the Monkey, which insect appears?",
            my: "မျောက်-ကဏန်း ပုံပြင်တွင် ပေါ်သော ပိုးက ဘာလဲ။",
            answerID: "bee",
            choices: [
                ("bee", "ハチ", "蜜蜂", "Bee", "ပျား"),
                ("centipede", "ムカデ", "蜈蚣", "Centipede", "ကျော့ကွေး"),
            ],
            explainJA: "正解はハチ。これは日本の昔話『さるかに合戦』。サルがカニの柿をだまして取り、親ガニを傷つける。子どもカニはハチ・クリ・臼（うす）と仕返しする。ムカデは出てこない。",
            explainZH: "正确答案是蜜蜂。这是日本民间故事《猴子和螃蟹打仗》：猴子骗走螃蟹的柿子并伤害蟹妈妈，小螃蟹靠蜜蜂、栗子、石臼报仇。蜈蚣没有出场。",
            explainEN: "A bee. This is the Japanese folk tale Saru Kani Gassen: a monkey cheats a crab out of a persimmon. The children are helped by a bee, a chestnut, and a mortar. No centipede.",
            explainMY: "အဖြေမှန်က ပျား။ ဂျပန် ဒဏ္ဍာရီ 『ဆရု ကနိ ဂတ်ဆင်』။ ပျား၊ သစ်အယ်၊ ကျည်ပွေ့က ကူသည်။"
        ),
        Item(
            id: "kid-tuna",
            ja: "海で生きている魚はどちらでしょうか？",
            zh: "生活在海里的鱼是哪一种？",
            en: "Which fish lives in the sea?",
            my: "ပင်လယ်တွင် နေသော ငါးက ဘယ်ဟာလဲ။",
            answerID: "tuna",
            choices: [
                ("tuna", "マグロ", "金枪鱼", "Tuna", "တူနာ"),
                ("loach", "ドジョウ", "泥鳅", "Loach", "ဒိုဂျို"),
            ],
            explainJA: "マグロは海で生きている魚で、お寿司でも大人気ですね。ドジョウは川や田んぼで生きている魚です。",
            explainZH: "金枪鱼生活在海里，做寿司也很受欢迎。泥鳅生活在河里和田里。",
            explainEN: "Tuna live in the sea and are popular in sushi. Loaches live in rivers and rice fields.",
            explainMY: "တူနာသည် ပင်လယ်ငါး၊ ဆူရှိတွင် လူကြိုက်များသည်။ ဒိုဂျိုက မြစ်နှင့် လယ်တွင် နေသည်။"
        ),
        Item(
            id: "kid-apple",
            ja: "寒いところでも育つ果物はなんでしょうか？",
            zh: "在寒冷的地方也能种的水果是什么？",
            en: "Which fruit can grow even in cold places?",
            my: "အေးသောနေရာတွင်လည်း ပေါက်သော သစ်သီးက ဘာလဲ။",
            answerID: "apple",
            choices: [
                ("pineapple", "パイナップル", "菠萝", "Pineapple", "နာနတ်သီး"),
                ("apple", "リンゴ", "苹果", "Apple", "ပန်းသီး"),
            ],
            explainJA: "リンゴは寒いところでも育つ果物で、青森県でとてもたくさん作られています。パイナップルはあたたかいところで育つ果物で、沖縄県でたくさん作られています。",
            explainZH: "苹果在寒冷的地方也能种，青森县产量很多。菠萝在暖和的地方种，冲绳产量很多。",
            explainEN: "Apples grow in the cold and a lot are grown in Aomori. Pineapples grow in warm places like Okinawa.",
            explainMY: "ပန်းသီး အေးသောနေရာတွင် ပေါက်သည်၊ အအိုမိုရိတွင် များသည်။ နာနတ်သီး ပူသောနေရာ၊ အိုကီနာဝါတွင် များသည်။"
        ),
        Item(
            id: "kid-sandwich",
            ja: "パンを使った料理はどちらでしょうか？",
            zh: "用面包做的料理是哪一种？",
            en: "Which dish is made with bread?",
            my: "ပေါင်မုန့်သုံးသော ဟင်းက ဘယ်ဟာလဲ။",
            answerID: "sandwich",
            choices: [
                ("sandwich", "サンドイッチ", "三明治", "Sandwich", "စန်ဒဝစ်"),
                ("friedrice", "チャーハン", "炒饭", "Fried rice", "ထမင်းကြော်"),
            ],
            explainJA: "サンドイッチは、食パンでハムや野菜・チーズなどをはさんで作ります。チャーハンは、お米と具材を炒めて作る料理です。",
            explainZH: "三明治是用吐司夹火腿、蔬菜、奶酪做成的。炒饭是把米和配料炒在一起。",
            explainEN: "A sandwich is ham, vegetables, and cheese between bread. Fried rice is rice stir-fried with other ingredients.",
            explainMY: "စန်ဒဝစ်သည် ပေါင်မုန့်ကြား ဟမ်/ဟင်းသီး/ချိစ်။ ထမင်းကြော်သည် ထမင်းနှင့် ဟင်းချက်ကြော်သည်။"
        ),
        Item(
            id: "kid-aquarium",
            ja: "たくさんの海の生物に会える場所はどちらでしょうか？",
            zh: "能见到很多海洋生物的地方是哪一个？",
            en: "Where can you meet lots of sea animals?",
            my: "ပင်လယ်သတ္တဝါများစွာ တွေ့နိုင်သော နေရာက ဘယ်ဟာလဲ။",
            answerID: "aquarium",
            choices: [
                ("park", "遊園地", "游乐园", "Amusement park", "ပျော်ပွဲဥယျာဉ်"),
                ("aquarium", "水族館", "水族馆", "Aquarium", "ရေသတ္တဝါပြတိုက်"),
            ],
            explainJA: "水族館では、イルカやペンギン・魚などたくさんの海の生物に会うことができます。イルカショーなどの楽しいイベントもあります。遊園地はたくさんの楽しいのりものがある場所ですね。",
            explainZH: "水族馆能见到海豚、企鹅、鱼等很多海洋生物，还有海豚表演。游乐园是有很多好玩设施的地方。",
            explainEN: "At an aquarium you can see dolphins, penguins, and fish, and even dolphin shows. An amusement park has rides.",
            explainMY: "ရေသတ္တဝါပြတိုက်တွင် လင်းပိုင်၊ ပင်ဂွင်း၊ ငါး တွေ့နိုင်သည်။ ပျော်ပွဲဥယျာဉ်တွင် စီးစရာများရှိသည်။"
        ),
        Item(
            id: "kid-alcohol",
            ja: "大人しか飲んではいけないものはどれでしょうか？",
            zh: "只有大人才能喝的是哪一种？",
            en: "Which drink may only adults have?",
            my: "လူကြီးသာ သောက်ရသော အရာက ဘယ်ဟာလဲ။",
            answerID: "alcohol",
            choices: [
                ("alcohol", "お酒", "酒", "Alcohol", "အရက်"),
                ("tea", "紅茶", "红茶", "Black tea", "လက်ဖက်ရည်နီ"),
            ],
            explainJA: "お酒は20歳になるまで飲んではいけません。紅茶は美味しいお茶なので、子どもが飲んでも大丈夫です。",
            explainZH: "酒要到 20 岁才能喝。红茶是好喝的茶，小孩子也可以喝。",
            explainEN: "You must not drink alcohol until you are 20. Black tea is fine for children.",
            explainMY: "အရက်ကို အသက် ၂၀ မပြည့်မီ မသောက်ရ။ လက်ဖက်ရည်နီ ကလေးသောက်နိုင်သည်။"
        ),
        Item(
            id: "kid-mosquito",
            ja: "人の血を吸う虫はどちらでしょうか？",
            zh: "会吸人血的虫子是哪一种？",
            en: "Which insect sucks people’s blood?",
            my: "လူသွေးစုပ်သော ပိုးက ဘယ်ဟာလဲ။",
            answerID: "mosquito",
            choices: [
                ("butterfly", "ちょうちょ", "蝴蝶", "Butterfly", "လိပ်ပြာ"),
                ("mosquito", "蚊", "蚊子", "Mosquito", "ခြင်"),
            ],
            explainJA: "蚊は人の血を吸うことがある虫です。刺されるとかゆくなって嫌ですね。ちょうちょは花の蜜を吸っています。",
            explainZH: "蚊子会吸人血，被叮了会痒。蝴蝶吸的是花蜜。",
            explainEN: "Mosquitoes can suck blood and the bite itches. Butterflies drink flower nectar.",
            explainMY: "ခြင်က လူသွေးစုပ်တတ်သည်၊ ကိုက်ရင် ယားသည်။ လိပ်ပြာက ပန်းရည်စုပ်သည်။"
        ),
        Item(
            id: "kid-rose",
            ja: "トゲがある花はどちらでしょうか？",
            zh: "有刺的花是哪一种？",
            en: "Which flower has thorns?",
            my: "ဆူးရှိသော ပန်းက ဘယ်ဟာလဲ။",
            answerID: "rose",
            choices: [
                ("sunflower", "ヒマワリ", "向日葵", "Sunflower", "နေကြာ"),
                ("rose", "バラ", "玫瑰", "Rose", "နှင်းဆီ"),
            ],
            explainJA: "バラは茎にトゲがあります。触る時には注意しましょう。ヒマワリは夏に咲く背が高い花で、トゲはありません。",
            explainZH: "玫瑰茎上有刺，摸的时候要小心。向日葵是夏天开的高花，没有刺。",
            explainEN: "Roses have thorns on the stem, so be careful. Sunflowers bloom tall in summer and have no thorns.",
            explainMY: "နှင်းဆီပင်စည်တွင် ဆူးရှိသည်။ နေကြာ နွေပွင့်၊ ဆူးမရှိ။"
        ),
        Item(
            id: "kid-convenience",
            ja: "1日中開いているお店はどちらでしょうか？",
            zh: "一整天都开门的店是哪一种？",
            en: "Which shop stays open all day?",
            my: "တစ်နေကုန်ဖွင့်သော ဆိုင်က ဘယ်ဟာလဲ။",
            answerID: "convenience",
            choices: [
                ("convenience", "コンビニ", "便利店", "Convenience store", "ကွန်ဘီနီ"),
                ("department", "デパート", "百货公司", "Department store", "ဒီပတ်စတိုး"),
            ],
            explainJA: "コンビニは、24時間ずっと開いているお店です。朝早くや夜遅くに買い物に行きたい人にとっては便利なお店です。デパートは決まった時間のあいだしか開いていません。",
            explainZH: "便利店是 24 小时开门的店，一早一晚想买东西很方便。百货公司只在固定时间开门。",
            explainEN: "Convenience stores are open 24 hours, handy early or late. Department stores keep set hours.",
            explainMY: "ကွန်ဘီနီ ၂၄ နာရီဖွင့်သည်။ ဒီပတ်စတိုး သတ်မှတ်ချိန်သာ ဖွင့်သည်။"
        ),
        Item(
            id: "kid-popcorn",
            ja: "映画館で大人気なお菓子はどちらでしょうか？",
            zh: "电影院里很受欢迎的点心是哪一种？",
            en: "Which snack is very popular at the movie theater?",
            my: "ရုပ်ရှင်ရုံတွင် လူကြိုက်များသော မုန့်က ဘယ်ဟာလဲ။",
            answerID: "popcorn",
            choices: [
                ("senbei", "せんべい", "仙贝", "Rice crackers", "ဆင်ဘေး"),
                ("popcorn", "ポップコーン", "爆米花", "Popcorn", "ပေါ့ပ်ကွန်း"),
            ],
            explainJA: "映画館では、ポップコーンが大人気です。色んな味があるとどれにしようか迷ってしまいますね。せんべいのような音が出るお菓子は他の人の迷惑になるので、映画館では食べない方がいいお菓子です。",
            explainZH: "电影院里爆米花很受欢迎，味道很多会让人纠结。仙贝那种会响的点心会打扰别人，电影院里最好别吃。",
            explainEN: "Popcorn is a theater favorite, with many flavors. Noisy snacks like senbei bother others, so skip those in the cinema.",
            explainMY: "ရုပ်ရှင်ရုံတွင် ပေါ့ပ်ကွန်း လူကြိုက်များသည်။ ဆင်ဘေးကဲ့သို့ အသံကျယ်မုန့် မစားသင့်။"
        ),
    ]
}
