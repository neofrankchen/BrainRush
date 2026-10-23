import Foundation

/// 食べ物2択：子供向け食べ物雑学。他の2択とは別ファイル。
enum FoodChoiceBank {
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
                task: .foodChoice,
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
            id: "food-ice-headache",
            ja: "アイスクリームやかき氷など、冷たいものを食べたときにキーンとくる「アイスクリーム頭痛」の予防法は次のうちどちらでしょうか？",
            zh: "吃冰淇淋或刨冰时突然「嗡」一下的「冰淇淋头痛」，预防方法是哪一种？",
            en: "Which way helps prevent “ice cream headache” from cold food?",
            my: "ရေခဲမုန့်စားစဉ် ခေါင်းကိုက်ခြင်းကို ဘယ်လို ကာကွယ်မလဲ။",
            answerID: "slow",
            choices: [
                ("slow", "ゆっくり食べる", "慢慢吃", "Eat slowly", "ဖြည်းဖြည်းစားပါ"),
                ("fast", "噛んですぐ飲み込む", "嚼完马上咽下去", "Chew and swallow right away", "ဝါးပြီး ချက်ချင်း မျိုပါ"),
            ],
            explainJA: "アイスクリームやかき氷は、ゆっくり時間をかけて食べることで血管の膨張を緩やかにし喉の冷えもおさえられることから、アイスクリーム頭痛の予防になります。",
            explainZH: "冰淇淋和刨冰慢慢吃，血管膨胀会比较缓和，喉咙也不那么凉，可以预防冰淇淋头痛。",
            explainEN: "Eating ice cream or shaved ice slowly eases blood-vessel swelling and throat chill, which helps prevent ice cream headache.",
            explainMY: "ရေခဲမုန့်ကို ဖြည်းဖြည်းစားရင် သွေးကြောကြီးထွားမှု ညင်သာပြီး လည်ချောင်းအေးမှု လျော့သည်။"
        ),
        Item(
            id: "food-grape-sweet",
            ja: "一房のブドウの中で、どの部分が一番甘いでしょうか？",
            zh: "一串葡萄里，哪一部分最甜？",
            en: "On one bunch of grapes, which part is the sweetest?",
            my: "စပျစ်သီးတစ်ခိုင်တွင် ဘယ်အစိတ်အပိုင်း အချိုဆုံးလဲ။",
            answerID: "top",
            choices: [
                ("top", "上の部分", "上面的部分", "The top part", "အပေါ်ပိုင်း"),
                ("bottom", "下の部分", "下面的部分", "The bottom part", "အောက်ပိုင်း"),
            ],
            explainJA: "ブドウは枝に近い上の部分から先に栄養が届き下の部分より早く熟すため、上のブドウの方が甘くなります。",
            explainZH: "营养先到靠近枝的上部，上面比下面熟得早，所以上面更甜。",
            explainEN: "Nutrients reach the grapes nearer the stem first, so the top ripens sooner and tastes sweeter.",
            explainMY: "အကိုင်းနီးသော အပေါ်ပိုင်းသို့ အာဟာရ အရင်ရောက်သည်။ အပေါ်ပိုင်း ပိုရင့်ပြီး ပိုချိုသည်။"
        ),
        Item(
            id: "food-donut-hole",
            ja: "ドーナツの真ん中に穴が空いている理由はなんでしょうか？",
            zh: "甜甜圈中间有洞，是为什么？",
            en: "Why does a doughnut have a hole in the middle?",
            my: "ဒိုးနတ်အလယ် အပေါက်ဘာကြောင့်ရှိသလဲ။",
            answerID: "even",
            choices: [
                ("save", "材料の節約のため", "为了节省材料", "To save ingredients", "ပါဝင်ပစ္စည်း ချွေတာရန်"),
                ("even", "ムラなく均等に火が通るようにするため", "为了均匀熟透", "So it cooks evenly all the way through", "မီးညီညီကျော်ရန်"),
            ],
            explainJA: "ドーナツは、穴が開いていないと中心部に熱が伝わりにくいためムラができてしまいます。そのため、真ん中をあえて空洞にして作られています。",
            explainZH: "没有洞的话，中间不容易传热，会熟得不均匀。所以故意把中间做成空洞。",
            explainEN: "Without a hole, heat does not reach the center well and cooking is uneven. The hole is made on purpose.",
            explainMY: "အပေါက်မရှိရင် အလယ်သို့ အပူမရောက်၊ မညီညာကျော်သည်။ ထို့ကြောင့် အလယ်ကို ဗလာလုပ်ထားသည်။"
        ),
        Item(
            id: "food-salad-flavor",
            ja: "おせんべいなどによくある「サラダ味」とはそもそも何味でしょうか？",
            zh: "仙贝等食品常见的「沙拉味」到底是什么味？",
            en: "What is “salad flavor” on rice crackers actually?",
            my: "မုန့်ခြောက် «ဆလာဒ်အရသာ» ဆိုသည်မှာ ဘာအရသာလဲ။",
            answerID: "oil",
            choices: [
                ("veg", "野菜サラダ", "蔬菜沙拉", "Vegetable salad", "ဟင်းသီးဟင်းရွက်ဆလာဒ်"),
                ("oil", "サラダ油", "色拉油", "Salad oil", "ဆလာဒ်ဆီ"),
            ],
            explainJA: "おせんべいのサラダ味とは、サラダ油をからめて塩をまぶしたものです。「塩味」より「サラダ味」のほうがおしゃれということで、サラダ味と名付けられました。",
            explainZH: "仙贝的沙拉味是裹上色拉油再撒盐。觉得比「咸味」更时髦，所以叫沙拉味。",
            explainEN: "Salad-flavor senbei is coated in salad oil and salt. The name sounded more stylish than just “salt.”",
            explainMY: "ဆလာဒ်အရသာ ဆိုသည်မှာ ဆလာဒ်ဆီနှင့် ဆား။ «ဆားအရသာ» ထက် ခေတ်မီသည်ဟု ခေါ်ထားသည်။"
        ),
        Item(
            id: "food-shumai-pea",
            ja: "シュウマイの上にはグリーンピースが乗っていることがあります。グリーンピースが乗るようになった理由はなんでしょうか？",
            zh: "烧卖上面有时会放一颗青豆。为什么会放上去？",
            en: "Why is there sometimes a green pea on shumai?",
            my: "ရှုမိုင်ပေါ် ပဲစိမ်းဘာကြောင့် တင်လာသလဲ။",
            answerID: "cake",
            choices: [
                ("cake", "イチゴのショートケーキの真似をした", "模仿草莓蛋糕上的草莓", "It copied the strawberry on shortcake", "စတော်ဘယ်ရီကိတ်ကို တုထားသည်"),
                ("nutrition", "栄養バランス調整のため", "为了营养均衡", "To balance nutrition", "အာဟာရ ချိန်ညှိရန်"),
            ],
            explainJA: "昔の給食はあまり美味しいものではなく、給食を残す子ども少なくありませんでした。そこで、子供たちを喜ばせるためにイチゴのショートケーキのイチゴを真似して、シュウマイの上にグリーンピースが乗せられるようになりました。",
            explainZH: "以前的给食不太好吃，剩饭的孩子不少。为了让孩子们开心，就模仿草莓蛋糕上的草莓，在烧卖上放了青豆。",
            explainEN: "Old school lunches were not very tasty and kids left food. To cheer them up, the pea copied the strawberry on shortcake.",
            explainMY: "ရှေးကျောင်းထမင်း မစားကောင်း၊ ကလေးများ ကျန်ခဲ့သည်။ ပျော်စေရန် စတော်ဘယ်ရီကိတ်ကို တုပြီး ပဲစိမ်းတင်လာသည်။"
        ),
        Item(
            id: "food-musk-melon",
            ja: "マスクメロンの「マスク」の由来はなんでしょうか？",
            zh: "「マスクメロン」里的「マスク」从哪来？",
            en: "Where does the “musk” in muskmelon come from?",
            my: "မတ်စ်ခ်မယ်လွန်ရှိ «မတ်စ်ခ်» ဘယ်ကလာသလဲ။",
            answerID: "scent",
            choices: [
                ("net", "メロンの網目がマスクをかぶっているように見えるから", "因为网纹看起来像戴了口罩", "Because the net looks like a face mask", "ကွန်ရက်က နှာခေါင်းစည်း တပ်ထားသယောင်"),
                ("scent", "いい香りがするから", "因为很好闻", "Because it smells good", "ရနံ့ကောင်းသောကြောင့်"),
            ],
            explainJA: "香水の原料になる香りとされる「ムスク(じゃ香)」の香りがするため、マスクメロンと名付けられました。",
            explainZH: "因为它有「麝香（ムスク）」那种可用作香水原料的香味，所以叫マスクメロン。",
            explainEN: "It was named for a musk (jako) scent used in perfume, not for a face mask.",
            explainMY: "ရေမွှေးကုန်ကြမ်း မတ်စ်ခ်ရနံ့ ရှိသောကြောင့် မတ်စ်ခ်မယ်လွန်ဟု ခေါ်သည်။"
        ),
        Item(
            id: "food-ebichiri",
            ja: "中華でおなじみエビチリの発祥地はどこでしょうか？",
            zh: "中餐里常见的干烧虾仁，发源地是哪里？",
            en: "Where did ebi chili (chili shrimp) originate?",
            my: "အီဘိချီရီ စတင်ရာက ဘယ်နိုင်ငံလဲ။",
            answerID: "japan",
            choices: [
                ("japan", "日本", "日本", "Japan", "ဂျပန်"),
                ("china", "中国", "中国", "China", "တရုတ်"),
            ],
            explainJA: "エビチリは日本で四川料理の父として活躍した陳建民さんが考案しました。陳建民さんは中華料理を日本向けの味にアレンジするのが得意で、エビチリもその一つとされています。",
            explainZH: "干烧虾仁是在日本被称作四川料理之父的陈建民想出来的。他擅长把中餐改成日本口味，这也是其中之一。",
            explainEN: "Ebi chili was created in Japan by Chen Kenmin, called the father of Sichuan cooking there. He adapted Chinese dishes for Japanese tastes.",
            explainMY: "အီဘိချီရီကို ဂျပန်တွင် စီချွမ်ဟင်းဖခင် ချန်ကန်မင် ဖန်တီးသည်။ တရုတ်ဟင်းကို ဂျပန်အရသာသို့ ပြင်သည်။"
        ),
        Item(
            id: "food-healthy-veg",
            ja: "世界一ヘルシーと言われている野菜は次のうちどちらでしょうか？",
            zh: "被称为世界上最健康的蔬菜是哪一种？",
            en: "Which vegetable is said to be the world’s healthiest?",
            my: "ကမ္ဘာ့အကျန်းမာဆုံးဟု ဆိုသော ဟင်းသီးဟင်းရွက်က ဘယ်ဟာလဲ။",
            answerID: "cucumber",
            choices: [
                ("hakusai", "白菜", "白菜", "Napa cabbage", "ဂေါ်ဖီထုပ်ဖြူ"),
                ("cucumber", "キュウリ", "黄瓜", "Cucumber", "သခွားသီး"),
            ],
            explainJA: "キュウリは実のほとんどが水分でできており、とてもヘルシーな野菜です。そのことでギネス記録にも載っています。インターネットで検索すると「世界一栄養がない野菜としてギネスに載った」と出てくることがありますが、それは間違いです。",
            explainZH: "黄瓜几乎全是水分，非常健康，还上过吉尼斯纪录。网上有时写「作为世界上最没有营养的蔬菜上了吉尼斯」，那是错的。",
            explainEN: "Cucumber is mostly water and very healthy; it is in Guinness. Claims that it is the world’s least nutritious vegetable are wrong.",
            explainMY: "သခွားသီးသည် ရေများပြီး ကျန်းမာသည်။ ဂင်းနစ်တွင် ပါသည်။ «အာဟာရအနည်းဆုံး» ဟု ဆိုသည်မှာ မှားသည်။"
        ),
        Item(
            id: "food-shortcake",
            ja: "ショートケーキの「ショート」の意味はなんでしょうか？",
            zh: "「ショートケーキ」里的「ショート」是什么意思？",
            en: "What does “short” mean in shortcake?",
            my: "ရှော့ကိတ်ရှိ «ရှော့» ဘာအဓိပ္ပာယ်လဲ။",
            answerID: "fat",
            choices: [
                ("fat", "ショートニング（油脂）", "起酥油（油脂）", "Shortening (fat)", "ရှော့တနင်း (အဆီ)"),
                ("short", "短い", "短的", "Short (not long)", "တိုသည်"),
            ],
            explainJA: "ショートニングとは、サクサクした食感を出すためにお菓子作りに使われる油脂です。アメリカで生まれたショートケーキは、サクサクに焼いた生地にいちごを挟んだもので「ショートネス」と呼ばれていました。",
            explainZH: "起酥油是做点心时用来做出酥脆口感的油脂。美国的短蛋糕是酥脆饼皮夹草莓，曾叫「ショートネス」。",
            explainEN: "Shortening is a baking fat that makes dough crumbly. American shortcake was crisp pastry with strawberries, once called “shortness.”",
            explainMY: "ရှော့တနင်းသည် မုန့်ကြွပ်စေသော အဆီ။ အမေရိကန် ရှော့ကိတ်သည် စတော်ဘယ်ရီညှပ်သော ကြွပ်မုန့်။"
        ),
        Item(
            id: "food-apple-sweet",
            ja: "リンゴはどのようなことをすると甘みがアップするでしょうか？",
            zh: "苹果怎样处理会更甜？",
            en: "What makes an apple taste sweeter?",
            my: "ပန်းသီးကို ဘာလုပ်ရင် ပိုချိုလာသလဲ။",
            answerID: "cold",
            choices: [
                ("warm", "温める", "加热", "Warm it", "အပူပေးပါ"),
                ("cold", "冷やす", "冰镇", "Chill it", "အေးအောင်ထားပါ"),
            ],
            explainJA: "リンゴに含まれる果糖には、ａ型とＢ型があります。冷蔵庫などで冷やすと甘みの強いＢ型が増えてリンゴが甘くなります。",
            explainZH: "苹果里的果糖有 a 型和 B 型。放冰箱后，更甜的 B 型会增加，苹果就更甜。",
            explainEN: "Apple fructose has type A and type B. Chilling increases the sweeter type B.",
            explainMY: "ပန်းသီးဖရပ်တိုစ်တွင် A နှင့် B ရှိသည်။ အအေးခန်းထဲ ထားရင် ပိုချိုသော B ပိုများလာသည်။"
        ),
        Item(
            id: "food-gyoza-shape",
            ja: "日本でも大人気の餃子ですが、本場中国では縁起のいい食べ物とされており、餃子の形は昔の中国のあるものがモチーフにされています。それは何でしょうか？",
            zh: "饺子在日本也很受欢迎。在中国它被视为吉利食物，形状模仿了古时中国的某样东西。是什么？",
            en: "In China, gyoza is lucky food. What old Chinese thing is its shape based on?",
            my: "တရုတ်တွင် ကြက်ကြော်ပေါက်သည် ကံကောင်းသော အစာ။ ပုံစံက ဘာကို တုထားသလဲ။",
            answerID: "money",
            choices: [
                ("daruma", "だるま", "达摩不倒翁", "A daruma doll", "ဒရုမ"),
                ("money", "お金", "钱", "Money", "ငွေ"),
            ],
            explainJA: "餃子をお金の形にすることで、金運を呼ぶ意味が込められています。",
            explainZH: "把饺子做成钱的形状，寓意招来财运。",
            explainEN: "Shaping dumplings like old money is meant to bring good fortune with wealth.",
            explainMY: "ကြက်ကြော်ပေါက်ကို ငွေပုံလုပ်ခြင်းသည် ငွေကံခေါ်ရန် ဖြစ်သည်။"
        ),
        Item(
            id: "food-squid-ink",
            ja: "タコ墨よりイカ墨を使った料理が多いのはなぜでしょうか？",
            zh: "用鱿鱼墨的料理比用章鱼墨多，为什么？",
            en: "Why is squid ink used in cooking more than octopus ink?",
            my: "ရေဘဝဲမင်ထက် ရွှေငါးမင် ဟင်းတွင် ပိုသုံးသည်။ ဘာကြောင့်လဲ။",
            answerID: "cling",
            choices: [
                ("poison", "タコ墨は毒が含まれているから", "因为章鱼墨有毒", "Because octopus ink is poisonous", "ရေဘဝဲမင်တွင် အဆိပ်ရှိသောကြောင့်"),
                ("cling", "イカ墨のほうが料理によく絡むから", "因为鱿鱼墨更容易裹在菜上", "Because squid ink clings to food better", "ရွှေငါးမင်က ဟင်းနှင့် ပိုကပ်သောကြောင့်"),
            ],
            explainJA: "イカ墨はタコ墨よりも粘り気が強く料理に絡みやすいため、イカ墨を使った料理のほうが多くなっています。",
            explainZH: "鱿鱼墨比章鱼墨更有黏性，更容易裹在菜上，所以用鱿鱼墨的料理更多。",
            explainEN: "Squid ink is stickier than octopus ink, so it coats dishes better and is used more.",
            explainMY: "ရွှေငါးမင်သည် ပိုစေးကပ်ပြီး ဟင်းနှင့် ပိုကပ်သည်။ ထို့ကြောင့် ပိုသုံးသည်။"
        ),
        Item(
            id: "food-sweet-potato-fart",
            ja: "サツマイモを食べるとオナラが出やすくなりますが、どのようにして食べたらオナラが出にくくなるでしょうか？",
            zh: "吃红薯容易放屁。怎样吃会比较不容易放？",
            en: "Sweet potatoes can make you gassy. How should you eat them to reduce that?",
            my: "ကန်စွန်းဥစားရင် လေလည်လွယ်သည်။ ဘယ်လိုစားရင် လျော့မလဲ။",
            answerID: "skin",
            choices: [
                ("skin", "皮ごと食べる", "连皮一起吃", "Eat them with the skin", "ခွံနှင့်တကွ စားပါ"),
                ("peel", "皮を剥いて食べる", "削皮再吃", "Peel them first", "ခွံခွာပြီး စားပါ"),
            ],
            explainJA: "サツマイモは皮ごと食べることで、オナラが出にくくなります。これはサツマイモの皮の内側にある「ヤラピン」という酵素が消化を助けてくれるからです。",
            explainZH: "红薯连皮吃就不容易放屁。因为皮内侧有一种叫「ヤラピン」的酶，能帮助消化。",
            explainEN: "Eating the skin helps. An enzyme called yarapin just under the skin aids digestion.",
            explainMY: "ခွံနှင့်စားရင် လေလည်နည်းသည်။ ခွံအတွင်း ယာရာပင် အင်ဇိုင်းက အစာကြေစေသည်။"
        ),
        Item(
            id: "food-sea-fish-salt",
            ja: "海水はとてもしょっぱいです。では、なぜ海に生息している魚が塩辛くならないのでしょうか？",
            zh: "海水很咸。海里的鱼为什么不会变得很咸？",
            en: "Seawater is very salty. Why aren’t sea fish salty through and through?",
            my: "ပင်လယ်ရေ အလွန်ငန်သည်။ ပင်လယ်ငါး ဘာကြောင့် မငန်သလဲ။",
            answerID: "gills",
            choices: [
                ("cook", "調理すると塩が体内から抜ける仕組みになっている", "一烹饪盐就会从体内排出", "Cooking makes the salt leave the body", "ချက်လျှင် ဆား ထွက်သွားသော ယန္တရား"),
                ("gills", "エラと腎臓で塩分を体外へ排出している", "用鳃和肾脏把盐排出体外", "Gills and kidneys send salt back out", "ပါးဟက်နှင့် ကျောက်ကပ်က ဆား ထုတ်သည်"),
            ],
            explainJA: "魚も塩分をとりすぎると死んでしまうので、このような体の仕組みで自らを守っています。",
            explainZH: "鱼盐分过多也会死，所以用这套身体机制保护自己。",
            explainEN: "Too much salt would kill fish too, so this body system protects them.",
            explainMY: "ငါးလည်း ဆားများလွန်းရင် သေသည်။ ဤခန္ဓာကိုယ်ယန္တရားဖြင့် ကာကွယ်သည်။"
        ),
        Item(
            id: "food-mont-blanc",
            ja: "ケーキの中でも人気のあるモンブランですが、モンブランという名前の由来は何でしょうか？",
            zh: "很受欢迎的蒙布朗，这个名字从哪来？",
            en: "Where does the cake name Mont Blanc come from?",
            my: "မွန်ဘလွန်ကိတ် အမည် ဘယ်ကလာသလဲ။",
            answerID: "mountain",
            choices: [
                ("mountain", "山の名前", "山的名字", "A mountain’s name", "တောင်အမည်"),
                ("person", "人の名前", "人的名字", "A person’s name", "လူအမည်"),
            ],
            explainJA: "モンブランという名前は、ヨーロッパ最高峰の山の名前である「モンブラン（白い山）」が由来になっています。見た目が山とそっくりなため、この名前がついたそうです。",
            explainZH: "名字来自欧洲最高峰「勃朗峰（白色的山）」。因为样子很像那座山。",
            explainEN: "The name comes from Mont Blanc (“white mountain”), Europe’s highest peak. The cake looks like the mountain.",
            explainMY: "အမည်မှာ ဥရောပအမြင့်ဆုံးတောင် မွန်ဘလွန် (တောင်ဖြူ) မှ။ ပုံတူသောကြောင့်။"
        ),
        Item(
            id: "food-edible-chrysanthemum",
            ja: "お刺身の上に乗っている黄色の「食用菊」は彩りを良くする飾りでもありますが、他にはどのような効果があるでしょうか？",
            zh: "生鱼片上黄色的食用菊既是装饰，还有什么作用？",
            en: "The yellow edible chrysanthemum on sashimi is garnish. What else does it do?",
            my: "ဆာရှိမိပေါ် ပန်းဝါသည် အလှသာမက ဘာအကျိုးရှိသလဲ။",
            answerID: "poison",
            choices: [
                ("scent", "香りをつける", "增加香味", "Adds aroma", "ရနံ့ထည့်သည်"),
                ("poison", "食中毒を防ぐ", "防止食物中毒", "Helps prevent food poisoning", "အစားအသောက်အဆိပ်သင့်မှု ကာကွယ်သည်"),
            ],
            explainJA: "菊には毒を分解する作用があり、刺身と一緒に食べることで食中毒を防いでくれます。",
            explainZH: "菊花有分解毒素的作用，和生鱼片一起吃可以帮助防止食物中毒。",
            explainEN: "Chrysanthemum can break down toxins, so eating it with sashimi helps prevent food poisoning.",
            explainMY: "ပန်းတွင် အဆိပ်ဖြိုနိုင်သည်။ ဆာရှိမိနှင့်အတူ စားရင် အဆိပ်သင့်မှု ကာကွယ်သည်။"
        ),
        Item(
            id: "food-basque-cheesecake",
            ja: "バスクチーズケーキ発祥の美食の街「サンセバスチャン」はどこの国にあるでしょうか？",
            zh: "巴斯克芝士蛋糕发源的美食之城「圣塞巴斯蒂安」在哪个国家？",
            en: "San Sebastián, birthplace of Basque burnt cheesecake, is in which country?",
            my: "ဘတ်စ်ခ်ချိစ်ကိတ် မွေးရပ်မြို့ ဆန်ဆဲဘတ်စ်တီယန် ဘယ်နိုင်ငံလဲ။",
            answerID: "spain",
            choices: [
                ("spain", "スペイン", "西班牙", "Spain", "စပိန်"),
                ("holland", "オランダ", "荷兰", "the Netherlands", "နယ်သာလန်"),
            ],
            explainJA: "日本で流通しているバスクチーズケーキは、スペインの都市・サンセバスチャンにある「ラ・ビーニャ」というバルのレシピが参考になっています。",
            explainZH: "日本流通的巴斯克芝士蛋糕，参考的是西班牙圣塞巴斯蒂安酒吧「La Viña」的配方。",
            explainEN: "The Basque cheesecake sold in Japan follows a recipe from La Viña, a bar in San Sebastián, Spain.",
            explainMY: "ဂျပန်ရှိ ဘတ်စ်ခ်ချိစ်ကိတ်သည် စပိန် ဆန်ဆဲဘတ်စ်တီယန်ရှိ လာဗီညာ ဘား၏ ချက်နည်းကို ကိုးကားသည်။"
        ),
        Item(
            id: "food-champuru",
            ja: "沖縄の郷土料理ゴーヤチャンプルーの「チャンプルー」はどのような意味でしょうか？",
            zh: "冲绳家乡菜苦瓜炒什锦里的「チャンプルー」是什么意思？",
            en: "In Okinawan gōyā champuru, what does “champuru” mean?",
            my: "အိုကီနာဝါ ဂိုယာချန်ပူရုရှိ «ချန်ပူရု» ဘာအဓိပ္ပာယ်လဲ။",
            answerID: "mix",
            choices: [
                ("full", "いっぱい", "很多、满满的", "Full / a lot", "ပြည့်/များ"),
                ("mix", "ごちゃまぜ", "混在一起", "All mixed together", "ရောနှော"),
            ],
            explainJA: "ゴーヤチャンプルーの「チャンプルー」は、沖縄の方言で「ごちゃまぜ」という意味になります。",
            explainZH: "「チャンプルー」在冲绳方言里是「混在一起」的意思。",
            explainEN: "In the Okinawan dialect, champuru means mixed together.",
            explainMY: "ချန်ပူရုသည် အိုကီနာဝါစကားတွင် ရောနှောဟု အဓိပ္ပာယ်ရသည်။"
        ),
        Item(
            id: "food-natto-sauce",
            ja: "朝食の定番納豆ですが、タレを入れるタイミングでもっと美味しくなります。いつ入れるといいでしょうか？",
            zh: "早餐常吃的纳豆，酱汁什么时候放会更好吃？",
            en: "When should you add the sauce to make nattō tastier?",
            my: "နတ်တို ဆော့စ်ကို ဘယ်အချိန် ထည့်ရင် ပိုစားကောင်းသလဲ။",
            answerID: "before",
            choices: [
                ("before", "納豆を混ぜる前", "搅纳豆之前", "Before mixing the nattō", "မမွှေခင်"),
                ("after", "納豆を混ぜた後", "搅纳豆之后", "After mixing the nattō", "မွှေပြီးမှ"),
            ],
            explainJA: "納豆の表面には旨味成分のアミノ酸が多く含まれているため、タレを入れる前にかき混ぜることでアミノ酸が全体に広がり美味しくなります。",
            explainZH: "纳豆表面有很多鲜味氨基酸。先搅匀再放酱，氨基酸会铺开，更好吃。",
            explainEN: "The surface has lots of savory amino acids. Mix first, then add sauce, so the flavor spreads.",
            explainMY: "နတ်တိုမျက်နှာပြင်တွင် အမိုင်နိုအက်ဆစ် များသည်။ ဆော့စ်မထည့်ခင် မွှေရင် အရသာ ပျံ့သည်။"
        ),
        Item(
            id: "food-tempura-beer",
            ja: "天ぷらを作る時に天ぷら粉に混ぜる水の代わりにあるものを入れるとサクサクした天ぷらになります。その「あるもの」とは次のうちどちらでしょうか？",
            zh: "做天妇罗时，用某样东西代替水来拌粉会更酥脆。是哪一样？",
            en: "Instead of water in tempura batter, which ingredient makes it crispier?",
            my: "တန်ပူရာမှုန့်တွင် ရေအစား ဘာထည့်ရင် ပိုကြွပ်သလဲ။",
            answerID: "beer",
            choices: [
                ("milk", "牛乳", "牛奶", "Milk", "နို့"),
                ("beer", "ビール", "啤酒", "Beer", "ဘီယာ"),
            ],
            explainJA: "天ぷら粉にビールを混ぜると、ビールの炭酸に含まれた二酸化炭素が衣に空洞を作り、ビールの旨味成分も加わることでサクサク美味しい天ぷらになります。",
            explainZH: "天妇罗粉里加啤酒，碳酸里的二氧化碳会在面衣里形成空洞，再加上啤酒的鲜味，就会又酥又好吃。",
            explainEN: "Beer’s carbon dioxide makes little holes in the batter, and its flavor helps make crisp, tasty tempura.",
            explainMY: "ဘီယာ၏ ကာဗွန်ဒိုင်အောက်ဆိုဒ်က အပေါ်လွှာတွင် အပေါက်ငယ်များဖြစ်စေပြီး ကြွပ်ပြီး အရသာရှိသည်။"
        ),
        Item(
            id: "food-momiji-meat",
            ja: "「もみじ」とは何の肉でしょうか？",
            zh: "「もみじ」指的是哪种肉？",
            en: "What animal’s meat is called “momiji”?",
            my: "«မိုမိဂျိ» ဆိုသည်မှာ ဘယ်အသားလဲ။",
            answerID: "deer",
            choices: [
                ("deer", "シカ", "鹿", "Deer", "သမင်"),
                ("boar", "イノシシ", "野猪", "Boar", "တောဝက်"),
            ],
            explainJA: "シカの肉は「もみじ」とも呼ばれています。江戸時代、「生類憐みの令」によって鳥獣の殺傷が禁止された時に動物の肉を表す隠語が作られました。名前の由来は、花札の10月札「鹿に紅葉」の絵柄だと言われています。ちなみに…イノシシの肉の隠語は「ぼたん」です。",
            explainZH: "鹿肉也叫「もみじ」。江户时代《生类怜悯令》禁止杀伤鸟兽时，出现了这类隐语。名字据说来自花札十月「鹿与红叶」。野猪肉的隐语是「ぼたん」。",
            explainEN: "Deer meat is also called momiji. Edo-period bans on killing animals led to code names. The name is said to come from the October hanafuda card of a deer and maple. Boar meat is botan.",
            explainMY: "သမင်သားကို မိုမိဂျိဟုလည်း ခေါ်သည်။ အဲဒိုခေတ် တိရစ္ဆာန်မသတ်ရ အမိန့်ကြောင့် လျှို့ဝှက်အမည် ပေါ်သည်။ တောဝက်သားက ဘိုတန်။"
        ),
        Item(
            id: "food-shusse-uo",
            ja: "魚の中には成長段階によって呼び名が変わるものがいます。そのような魚を何と呼ぶでしょうか？",
            zh: "有些鱼会随生长阶段改名字。这种鱼叫什么？",
            en: "Some fish change names as they grow. What are they called?",
            my: "ကြီးလာသည်နှင့် အမည်ပြောင်းသော ငါးကို ဘာခေါ်သလဲ။",
            answerID: "shusse",
            choices: [
                ("shusse", "出世魚", "出仕鱼 / 升迁鱼", "Shusse-uo (promotion fish)", "ရှုဆဲငါး"),
                ("shinka", "進化魚", "进化鱼", "Evolution fish", "ဆင့်ကဲငါး"),
            ],
            explainJA: "成長段階によって呼び名が変わる魚は「出世魚」と呼ばれます。例えば、関東ではブリのことを…【ワカナゴ→イナダ→ワラサ→ブリ】といった感じに成長段階で呼び方を変えています。また、地域によって呼び方には微妙に違いがあるため同じブリでも関西の場合は…【ワカナ→ツバス→ハマチ→メジロ→ブリ】といった呼び名になっています。",
            explainZH: "随生长阶段改名的鱼叫「出世魚」。例如关东的鰤鱼：ワカナゴ→イナダ→ワラサ→ブリ。关西同一条鱼则是：ワカナ→ツバス→ハマチ→メジロ→ブリ。",
            explainEN: "They are called shusse-uo. In Kanto, yellowtail goes wakago → inada → warasa → buri. Kansai uses different stage names for the same fish.",
            explainMY: "ကြီးလာသည်နှင့် အမည်ပြောင်းသော ငါးကို ရှုဆဲငါးဟု ခေါ်သည်။ ဒေသအလိုက် အမည်ကွဲသည်။"
        ),
        Item(
            id: "food-truffle",
            ja: "世界三大珍味の1つ「トリュフ」とはなんでしょうか？",
            zh: "世界三大珍味之一的「松露」是什么？",
            en: "What is a truffle, one of the world’s three great delicacies?",
            my: "ကမ္ဘာ့ထိပ်တန်းအရသာသုံးမျိုးထဲက ထရပ်ဖယ်က ဘာလဲ။",
            answerID: "mushroom",
            choices: [
                ("roe", "魚の卵", "鱼卵", "Fish eggs", "ငါးဥ"),
                ("mushroom", "キノコ", "蘑菇", "A mushroom", "မှို"),
            ],
            explainJA: "トリュフはキノコの1種ですが人工的に栽培するのが難しく、地面の下に埋まっているため探すのも難しくなっています。そのような理由から希少価値が高い高級品となっています。",
            explainZH: "松露是一种蘑菇，很难人工栽培，又埋在地下不好找，所以非常珍贵昂贵。",
            explainEN: "A truffle is a kind of mushroom that is hard to farm and hard to find underground, so it is rare and expensive.",
            explainMY: "ထရပ်ဖယ်သည် မှိုအမျိုး။ စိုက်ပျိုးရခက်၊ မြေအောက်တွင် ရှာရခက်သောကြောင့် ရှားပြီး ဈေးကြီးသည်။"
        ),
        Item(
            id: "food-konowata",
            ja: "「日本三大珍味」の1つ、「このわた」の材料はなんでしょうか？",
            zh: "「日本三大珍味」之一「このわた」的原料是什么？",
            en: "What is konowata, one of Japan’s three great delicacies, made from?",
            my: "ဂျပန်ထိပ်တန်းအရသာသုံးမျိုးထဲက ကိုနိုဝါတာ ဘာနဲ့လုပ်သလဲ။",
            answerID: "namako",
            choices: [
                ("namako", "ナマコ", "海参", "Sea cucumber", "ပင်လယ်သခွား"),
                ("uni", "ウニ", "海胆", "Sea urchin", "ပင်လယ်ပြူ"),
            ],
            explainJA: "「このわた」は、ナマコの腸を塩漬けして熟成させたものです。ウニを加工した「塩ウニ」も日本三大珍味の1つです。",
            explainZH: "「このわた」是把海参的肠盐渍熟成做成的。用海胆加工的「盐海胆」也是日本三大珍味之一。",
            explainEN: "Konowata is salted, aged sea-cucumber intestine. Salted uni is another of Japan’s three great delicacies.",
            explainMY: "ကိုနိုဝါတာသည် ပင်လယ်သခွားအူကို ဆားစိမ်ပြီး ရင့်စေသည်။ ဆားစိမ်ပင်လယ်ပြူလည်း ဂျပန်ထိပ်တန်းအရသာထဲ ပါသည်။"
        ),
        Item(
            id: "food-sandai-chinmi",
            ja: "「日本三大珍味」はいつ頃から存在しているでしょうか？",
            zh: "「日本三大珍味」大约从什么时候开始有？",
            en: "From about when have Japan’s three great delicacies existed as a set?",
            my: "ဂျပန်ထိပ်တန်းအရသာသုံးမျိုး ဘယ်အချိန်က စရှိသလဲ။",
            answerID: "edo",
            choices: [
                ("kofun", "古墳時代", "古坟时代", "The Kofun period", "ကိုဖုန်ခေတ်"),
                ("edo", "江戸時代", "江户时代", "The Edo period", "အဲဒိုခေတ်"),
            ],
            explainJA: "第24問で述べた「塩ウニ」「このわた」に「からすみ」を加えた3つは「日本三大珍味」と呼ばれており、江戸時代には献上品として重宝されていたと言われています。ちなみに…「からすみ」は、ボラの卵を塩蔵して乾燥させたものです。",
            explainZH: "盐海胆、このわた，再加上「からすみ」，合称日本三大珍味。据说江户时代已是珍贵贡品。からすみ是鲻鱼卵盐渍后再干燥做成的。",
            explainEN: "Salted uni, konowata, and karasumi are Japan’s three great delicacies, valued as gifts in the Edo period. Karasumi is salted, dried mullet roe.",
            explainMY: "ဆားစိမ်ပင်လယ်ပြူ၊ ကိုနိုဝါတာနှင့် ကရာဆုမိကို ဂျပန်ထိပ်တန်းအရသာသုံးမျိုးဟု ခေါ်သည်။ အဲဒိုခေတ် လက်ဆောင်ဖြစ်သည်။"
        ),
        Item(
            id: "food-disher",
            ja: "アイスクリーム屋さんがアイスを丸い形で盛り付ける時に使っている道具の名前はなんでしょうか？",
            zh: "冰淇淋店把冰淇淋舀成圆形时用的工具叫什么？",
            en: "What is the tool ice-cream shops use to scoop round scoops?",
            my: "ရေခဲမုန့်ဆိုင်က လုံးပုံ ခပ်ရာသုံးကိရိယာ ဘာခေါ်သလဲ။",
            answerID: "disher",
            choices: [
                ("slusher", "スラッシャー", "Slusher", "Slusher", "စလပ်ရှာ"),
                ("disher", "ディッシャー", "Disher", "Disher", "ဒစ်ရှာ"),
            ],
            explainJA: "アイスクリームなどを丸っこい形に盛り付ける時に使われる道具の名前は、「ディッシャー」です。一定の量を一定の形で盛り付けることができる便利な道具です。",
            explainZH: "把冰淇淋舀成圆球的工具叫「ディッシャー」，能按固定分量和形状盛装。",
            explainEN: "The tool is a disher. It scoops a set amount into a set round shape.",
            explainMY: "အမည်မှာ ဒစ်ရှာ။ ပမာဏနှင့် ပုံစံ တည်ငြိမ်အောင် ခပ်နိုင်သည်။"
        ),
        Item(
            id: "food-zabuton",
            ja: "実際にある牛肉の部位はどちらでしょうか？",
            zh: "下面哪种是真实存在的牛肉部位？",
            en: "Which of these is a real cut of beef?",
            my: "ဘယ်ဟာ အမှန်တကယ်ရှိသော အမဲသားအစိတ်အပိုင်းလဲ။",
            answerID: "zabuton",
            choices: [
                ("zabuton", "ザブトン", "座布団", "Zabuton", "ဇဘုတန်"),
                ("ofuton", "オフトン", "お布団", "Ofuton", "အိုဖုတန်"),
            ],
            explainJA: "「ザブトン」は、牛肉の肩ロースのあばら骨側に位置する部位のことです。1頭から数kgしかとれない希少部位です。肩ロースから切り分けると、座布団のような四角い形にできることが名前の由来です。",
            explainZH: "「ザブトン」是肩里脊靠肋骨一侧的部位，一头牛只能取几公斤。切开后像坐垫一样方正，因此得名。",
            explainEN: "Zabuton is a rare cut on the rib side of chuck roll, only a few kilos per animal. Cut out, it looks like a square zabuton cushion.",
            explainMY: "ဇဘုတန်သည် ပခုံးသားနံရိုးဘက် ရှားပါးအစိတ်။ ဖြတ်လိုက်ရင် ထိုင်အုံးပုံ လေးထောင့်ဖြစ်သည်။"
        ),
        Item(
            id: "food-kanikama",
            ja: "カニカマにはカニの身は使われていません。では、材料となっているのはなんでしょうか？",
            zh: "蟹肉棒里没有螃蟹肉。那原料是什么？",
            en: "Imitation crab isn’t made of crab meat. What is it made from?",
            my: "ကနိခါမတွင် ကဏန်းသား မပါ။ ဘာနဲ့လုပ်သလဲ။",
            answerID: "whitefish",
            choices: [
                ("shrimp", "エビ", "虾", "Shrimp", "ပုဇွန်"),
                ("whitefish", "白身魚", "白身鱼", "White fish", "အသားဖြူငါး"),
            ],
            explainJA: "カニカマにはカニエキスが使われていますが、カニの身は使われていません。白身魚（主にスケトウダラ）のすり身が使われている「カニ風味のかまぼこ」です。",
            explainZH: "蟹肉棒用了螃蟹提取物，但没有蟹肉。是白身鱼（主要是明太鱼）鱼糜做成的蟹味鱼糕。",
            explainEN: "It uses crab extract, not crab meat. It is kamaboko made from white-fish paste, mainly Alaska pollock.",
            explainMY: "ကဏန်းအနှစ် သုံးသော်လည်း ကဏန်းသား မပါ။ အသားဖြူငါး (ပေါ်လော့ခ်) ကြိတ်သား ကာမဘိုကို ဖြစ်သည်။"
        ),
        Item(
            id: "food-unagi-ume",
            ja: "昔から「ウナギと梅干し」は食べ合わせが悪いと言われてきました。この話は本当か嘘かどちらでしょうか？",
            zh: "从前一直说「鳗鱼和梅干」相克。这话是真是假？",
            en: "People long said eel and pickled plum are a bad pair. True or false?",
            my: "ငါးရှဉ့်နှင့် ဥမဲဘိုရှိ မတွဲစားရဟု ဆိုသည်။ အမှန်လား အမှားလား။",
            answerID: "false",
            choices: [
                ("true", "本当", "真的", "True", "အမှန်"),
                ("false", "嘘", "假的", "False", "အမှား"),
            ],
            explainJA: "昔は「ウナギの脂っこさと梅干しの酸味が刺激し合って消化不良を起こす」と考えられていたようです。しかし実際には、ウナギも梅干しも疲労回復に効果がある上に、梅干しが胃酸の分泌を促してウナギの脂分の消化を助けてくれるため寧ろ相性が良い食べ物だと言えます。",
            explainZH: "从前以为鳗鱼的油腻和梅干的酸会互相刺激导致消化不良。其实两者都有助于恢复疲劳，梅干还能促进胃酸、帮助消化鳗鱼的脂肪，反而很搭。",
            explainEN: "People thought eel fat and plum sourness caused indigestion. In fact both help recovery, and the plum’s acid helps digest the eel fat, so they pair well.",
            explainMY: "ရှေးက အဆီနှင့် အချဉ်က အစာမကြေဟု ထင်သည်။ အမှန်မှာ နှစ်ခုလုံး ပင်ပန်းပြန်နာကျင်စေပြီး ဥမဲက အစာအိမ်အက်ဆစ် ထုတ်ကာ အဆီကြေစေသည်။"
        ),
        Item(
            id: "food-so-cheese",
            ja: "奈良時代や平安時代の日本で作られていた「蘇（そ）」とは、現在で言えば何に近い食べ物でしょうか？",
            zh: "奈良、平安时代日本做的「蘇（そ）」，接近现在的哪种食物？",
            en: "What modern food is closest to “so,” made in Nara and Heian Japan?",
            my: "နာရာ/ဟဲအန်းခေတ် «ဆို» သည် ယခု ဘယ်အစာနှင့် နီးသလဲ။",
            answerID: "cheese",
            choices: [
                ("cheese", "チーズ", "奶酪", "Cheese", "ချိစ်"),
                ("miso", "味噌", "味噌", "Miso", "မီဆို"),
            ],
            explainJA: "「蘇（そ）」とは、現在で言うチーズに似た乳製品です。2020年頃、新型コロナウイルス流行によって休校になったせいで大量に余った学校給食用の牛乳を大量に消費できるレシピとしてSNS上で話題となりました。",
            explainZH: "「蘇」是类似现在奶酪的乳制品。2020 年前后因新冠停课，给食用牛奶大量剩余，能消耗很多牛奶的蘇的做法在网上很火。",
            explainEN: "So is a dairy food like cheese. Around 2020, school-milk leftovers from COVID closures made so recipes a social-media hit.",
            explainMY: "ဆိုသည် ချိစ်နှင့် ဆင်သော နို့ထွက်။ ၂၀၂၀ ဝန်းကျင် ကျောင်းနို့ပို၍ SNS တွင် ဟင်းချက်နည်း ကျော်ကြားသည်။"
        ),
    ]
}
