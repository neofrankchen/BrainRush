import Foundation

/// 日本の常識2択：地理・文化・行事・食べ物・昔話。
enum JapanChoiceBank {
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
                task: .japanChoice,
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
            id: "jp-capital",
            ja: "日本の首都は？",
            zh: "日本的首都是哪里？",
            en: "What is Japan's capital?",
            my: "ဂျပန် မြို့တော်က ဘယ်မှာလဲ။",
            answerID: "tokyo",
            choices: [
                ("osaka", "大阪", "大阪", "Osaka", "အိုဆာကာ"),
                ("tokyo", "東京", "东京", "Tokyo", "တိုကျို"),
            ],
            explainJA: "正解は東京。日本の首都は東京。大阪は大都市だけど首都ではない。",
            explainZH: "正确答案是东京。日本的首都是东京。大阪很大，但不是首都。",
            explainEN: "Tokyo is the capital. Osaka is a big city, but not the capital.",
            explainMY: "အဖြေမှန်က တိုကျို။ အိုဆာကာက မြို့ကြီး၊ မြို့တော် မဟုတ်။"
        ),
        Item(
            id: "jp-fuji",
            ja: "日本で一番高い山は？",
            zh: "日本最高的山是哪座？",
            en: "What is Japan's highest mountain?",
            my: "ဂျပန်မှာ အမြင့်ဆုံးတောင်က ဘာလဲ။",
            answerID: "fuji",
            choices: [
                ("fuji", "富士山", "富士山", "Mount Fuji", "ဖူဂျီတောင်"),
                ("takao", "高尾山", "高尾山", "Mount Takao", "တာကအိုတောင်"),
            ],
            explainJA: "正解は富士山。標高3776メートルで日本一高い。高尾山は東京近郊の低い山。",
            explainZH: "正确答案是富士山。海拔 3776 米，是日本最高峰。高尾山在东京附近，没那么高。",
            explainEN: "Mount Fuji is 3776 m, Japan's highest. Takao is a smaller mountain near Tokyo.",
            explainMY: "အဖြေမှန်က ဖူဂျီတောင်။ ၃၇၇၆ မီတာ။ တာကအိုက ပိုနိမ့်သည်။"
        ),
        Item(
            id: "jp-hokkaido",
            ja: "北海道は日本のどちら側？",
            zh: "北海道位于日本的哪一侧？",
            en: "Which side of Japan is Hokkaido on?",
            my: "ဟော့ကိုင်းဒိုးက ဂျပန်ရဲ့ ဘယ်ဘက်လဲ။",
            answerID: "north",
            choices: [
                ("north", "北", "北", "North", "မြောက်"),
                ("south", "南", "南", "South", "တောင်"),
            ],
            explainJA: "正解は北。北海道は日本列島のいちばん北。南の端は沖縄。",
            explainZH: "正确答案是北。北海道在日本最北。最南是冲绳。",
            explainEN: "Hokkaido is the north end of Japan. Okinawa is in the south.",
            explainMY: "အဖြေမှန်က မြောက်။ ဟော့ကိုင်းဒိုးက အမြောက်ဆုံး။"
        ),
        Item(
            id: "jp-okinawa",
            ja: "沖縄に近いのはどっち？",
            zh: "哪个地方离冲绳更近？",
            en: "Which is closer to Okinawa?",
            my: "အိုကီနာဝါနှင့် ပိုနီးတာက ဘယ်ဟာလဲ။",
            answerID: "taiwan",
            choices: [
                ("hokkaido", "北海道", "北海道", "Hokkaido", "ဟော့ကိုင်းဒိုး"),
                ("taiwan", "台湾", "台湾", "Taiwan", "ထိုင်ဝမ်"),
            ],
            explainJA: "正解は台湾。沖縄は日本の南西で、台湾の方が北海道よりずっと近い。",
            explainZH: "正确答案是台湾。冲绳在日本西南，离台湾比离北海道近得多。",
            explainEN: "Taiwan. Okinawa is in Japan's southwest, much closer to Taiwan than to Hokkaido.",
            explainMY: "အဖြေမှန်က ထိုင်ဝမ်။ အိုကီနာဝါက အနောက်တောင်၊ ထိုင်ဝမ် ပိုနီးသည်။"
        ),
        Item(
            id: "jp-prefectures",
            ja: "日本の都道府県はいくつ？",
            zh: "日本共有多少个都道府县？",
            en: "How many prefectures does Japan have?",
            my: "ဂျပန်မှာ 都道府県 ဘယ်နှစ်ခုရှိသလဲ။",
            answerID: "47",
            choices: [
                ("48", "48", "48", "48", "၄၈"),
                ("47", "47", "47", "47", "၄၇"),
            ],
            explainJA: "正解は47。都1、道1、府2、県43で合計47。",
            explainZH: "正确答案是 47。1 都、1 道、2 府、43 县，一共 47 个。",
            explainEN: "47: 1 to, 1 do, 2 fu, and 43 ken.",
            explainMY: "အဖြေမှန်က ၄၇။ 都 ၁၊ 道 ၁၊ 府 ၂၊ 県 ၄၃။"
        ),
        Item(
            id: "jp-kinkaku",
            ja: "金閣寺があるのは？",
            zh: "金阁寺位于哪里？",
            en: "Where is Kinkaku-ji?",
            my: "ကင်ခကုဂျိ ဘယ်မှာလဲ။",
            answerID: "kyoto",
            choices: [
                ("kyoto", "京都", "京都", "Kyoto", "ကျိုတို"),
                ("tokyo", "東京", "东京", "Tokyo", "တိုကျို"),
            ],
            explainJA: "正解は京都。金閣寺は京都市の鹿苑寺。金箔の建物で知られる。",
            explainZH: "正确答案是京都。金阁寺在京都市，因贴金箔出名。",
            explainEN: "Kyoto. Kinkaku-ji is the Golden Pavilion.",
            explainMY: "အဖြေမှန်က ကျိုတို။ ရွှေရောင်ဘုရားကျောင်း။"
        ),
        Item(
            id: "jp-hinamatsuri",
            ja: "ひな祭りは何月？",
            zh: "女儿节在几月？",
            en: "In which month is Hinamatsuri?",
            my: "ဟိနမဆွရိက ဘယ်လလဲ။",
            answerID: "march",
            choices: [
                ("may", "5月", "5月", "May", "မေ"),
                ("march", "3月", "3月", "March", "မတ်"),
            ],
            explainJA: "正解は3月。3月3日がひな祭り。5月5日はこどもの日。",
            explainZH: "正确答案是 3 月。女儿节是 3 月 3 日。5 月 5 日是儿童节。",
            explainEN: "March 3 is Hinamatsuri. May 5 is Children's Day.",
            explainMY: "အဖြေမှန်က မတ်။ မတ် ၃ က ဟိနမဆွရိ။"
        ),
        Item(
            id: "jp-kodomo",
            ja: "こどもの日はいつ？",
            zh: "日本儿童节是哪一天？",
            en: "When is Children's Day in Japan?",
            my: "ကလေးနေ့က ဘယ်နေ့လဲ။",
            answerID: "may5",
            choices: [
                ("july7", "7月7日", "7月7日", "July 7", "ဇူလိုင် ၇"),
                ("may5", "5月5日", "5月5日", "May 5", "မေ ၅"),
            ],
            explainJA: "正解は5月5日。端午の節句でもある。7月7日は七夕。",
            explainZH: "正确答案是 5 月 5 日。也是端午节。7 月 7 日是七夕。",
            explainEN: "May 5, also Tango no Sekku. July 7 is Tanabata.",
            explainMY: "အဖြေမှန်က မေ ၅။ ဇူလိုင် ၇ က တနဘတ။"
        ),
        Item(
            id: "jp-tanabata",
            ja: "一般的な七夕の日は？",
            zh: "日本通常所说的七夕是哪一天？",
            en: "When is Tanabata usually?",
            my: "တနဘတ နေ့က ဘယ်နေ့လဲ။",
            answerID: "july7",
            choices: [
                ("july7", "7月7日", "7月7日", "July 7", "ဇူလိုင် ၇"),
                ("dec25", "12月25日", "12月25日", "December 25", "ဒီဇင်ဘာ ၂၅"),
            ],
            explainJA: "正解は7月7日。日本の七夕は、織姫と彦星が年に一度会うという伝説と結びついた行事。12月25日のクリスマスとは別。",
            explainZH: "正确答案是 7 月 7 日。日本七夕是民间传说里织女和彦星一年见一次的节日。和 12 月 25 日的圣诞节不是一回事。",
            explainEN: "July 7. Japanese Tanabata is tied to the folk legend of Orihime and Hikoboshi meeting once a year. December 25 is Christmas.",
            explainMY: "အဖြေမှန်က ဇူလိုင် ၇။ ဂျပန် တနဘတ ဒဏ္ဍာရီ။ ဒီဇင်ဘာ ၂၅ က ခရစ္စမတ်။"
        ),
        Item(
            id: "jp-setsubun",
            ja: "節分にまくのは？",
            zh: "日本节分时撒什么？",
            en: "What do people throw at Setsubun?",
            my: "ဆက်ဆွဘွန်မှာ ဘာပစ်သလဲ။",
            answerID: "beans",
            choices: [
                ("beans", "豆", "豆子", "Beans", "ပဲ"),
                ("rice", "お米", "米", "Rice", "ဆန်"),
            ],
            explainJA: "正解は豆。鬼は外、福は内と言って大豆をまく。",
            explainZH: "正确答案是豆子。节分喊「鬼出去，福进来」，撒的是大豆。",
            explainEN: "Soybeans. People shout “Oni wa soto, fuku wa uchi.”",
            explainMY: "အဖြေမှန်က ပဲ။ နတ်ဆိုးထွက်၊ ကံဝင် ဟုဆိုပြီး ပဲပစ်သည်။"
        ),
        Item(
            id: "jp-torii",
            ja: "神社の入り口によくあるのは？",
            zh: "神社入口经常有什么？",
            en: "What often stands at a shrine entrance?",
            my: "ဂျင်းဂျအဝင်မှာ ဘာရှိတတ်သလဲ။",
            answerID: "torii",
            choices: [
                ("signal", "信号機", "信号灯", "A traffic light", "မီးပွိုင့်"),
                ("torii", "鳥居", "鸟居", "A torii gate", "တိုရီ"),
            ],
            explainJA: "正解は鳥居。神社の入口の門。神域との境を示す。",
            explainZH: "正确答案是鸟居。神社入口的门，表示进入神的领域。",
            explainEN: "A torii gate marks the shrine's sacred area.",
            explainMY: "အဖြေမှန်က တိုရီ။ ဘုရားကျောင်းဝင်ပေါက် တံခါး။"
        ),
        Item(
            id: "jp-dohyo",
            ja: "相撲の試合をする場所は？",
            zh: "相扑比赛在哪里进行？",
            en: "Where is a sumo bout held?",
            my: "ဆူမို ပြိုင်ပွဲ ဘယ်မှာလုပ်သလဲ။",
            answerID: "dohyo",
            choices: [
                ("dohyo", "土俵", "土俵", "The dohyo ring", "ဒိုဟယို"),
                ("pool", "プール", "游泳池", "A pool", "ရေကူးကန်"),
            ],
            explainJA: "正解は土俵。円い土の土俵の上で取る。",
            explainZH: "正确答案是土俵。相扑在圆形的土台上比。",
            explainEN: "Sumo is fought on the round clay dohyo.",
            explainMY: "အဖြေမှန်က ဒိုဟယို။ စက်ဝိုင်းမြေကွင်း။"
        ),
        Item(
            id: "jp-momotaro",
            ja: "桃太郎が生まれたのは？",
            zh: "桃太郎从什么里面出生？",
            en: "What was Momotaro born from?",
            my: "မိုမိုတရိုး ဘာထဲက မွေးသလဲ။",
            answerID: "peach",
            choices: [
                ("peach", "桃", "桃子", "A peach", "မက်မွန်"),
                ("watermelon", "スイカ", "西瓜", "A watermelon", "ဖရဲ"),
            ],
            explainJA: "正解は桃。日本の昔話『桃太郎』。おばあさんが川で拾った桃を割ると男の子が生まれ、のちに犬・猿・キジと鬼ヶ島へ行く。スイカから生まれる話ではない。",
            explainZH: "正确答案是桃子。这是日本民间故事《桃太郎》：奶奶从河里捡到桃子，剖开后跳出男孩，后来带着狗、猴、野鸡去鬼岛。不是从西瓜里出生。",
            explainEN: "A peach. This is the Japanese folk tale Momotaro: a boy is born from a peach found in the river, then goes to Onigashima with a dog, a monkey, and a pheasant. Not a watermelon.",
            explainMY: "အဖြေမှန်က မက်မွန်။ ဂျပန် ဒဏ္ဍာရီ 『မိုမိုတရိုး』။ မြစ်က မက်မွန်ထဲက မွေးသည်။"
        ),
        Item(
            id: "jp-urashima",
            ja: "浦島太郎が助けた動物は？",
            zh: "浦岛太郎救了哪种动物？",
            en: "What animal did Urashima Taro save?",
            my: "ဥရရှိမ တရိုး ကယ်သော တိရစ္ဆာန်က ဘာလဲ။",
            answerID: "turtle",
            choices: [
                ("rabbit", "ウサギ", "兔子", "A rabbit", "ယုန်"),
                ("turtle", "カメ", "乌龟", "A turtle", "လိပ်"),
            ],
            explainJA: "正解はカメ。日本の昔話『浦島太郎』。いじめられていた亀を助け、お礼に竜宮城へ連れていってもらう。ウサギを助ける話ではない。",
            explainZH: "正确答案是乌龟。这是日本民间故事《浦岛太郎》：他救了被欺负的乌龟，被带到龙宫作为答谢。不是救兔子。",
            explainEN: "A turtle. This is the Japanese folk tale Urashima Taro: he saves a turtle and is taken to the Dragon Palace. He does not save a rabbit.",
            explainMY: "အဖြေမှန်က လိပ်။ ဂျပန် ဒဏ္ဍာရီ 『ဥရရှိမ တရိုး』။ လိပ်ကယ်ပြီး နဂါးနန်းတော်သို့ သွားသည်။"
        ),
        Item(
            id: "jp-kintaro",
            ja: "金太郎が持っている武器は？",
            zh: "金太郎拿着什么武器？",
            en: "What weapon does Kintaro carry?",
            my: "ကင်တရိုး ကိုင်သော လက်နက်က ဘာလဲ။",
            answerID: "axe",
            choices: [
                ("axe", "まさかり", "大斧", "A masakari axe", "ပုဆိန်ကြီး"),
                ("sword", "日本刀", "日本刀", "A katana", "ခတန"),
            ],
            explainJA: "正解はまさかり。日本の昔話に出てくる金太郎は、足柄山で熊などと遊んだ力持ちの少年で、大きな斧を担いだ姿で知られる。日本刀を持った武士の話ではない。",
            explainZH: "正确答案是大斧。这是日本民间故事里的金太郎：足柄山长大的大力少年，出名形象是扛着大斧。不是拿日本刀的武士。",
            explainEN: "A masakari axe. Kintaro is a Japanese folk-tale strong boy from Mount Ashigara, famous for carrying a broad axe, not a katana.",
            explainMY: "အဖြေမှန်က ပုဆိန်ကြီး။ ဂျပန် ဒဏ္ဍာရီ ကင်တရိုး။ အာရှိဂါရ တောင်က သူရဲကောင်းကလေး။"
        ),
        Item(
            id: "jp-saru-kani",
            ja: "さるかに合戦で、カニの味方になる虫は？",
            zh: "「猴子和螃蟹打仗」里，帮螃蟹的虫子是什么？",
            en: "In The Crab and the Monkey, which insect helps the crabs?",
            my: "မျောက်-ကဏန်း ပုံပြင်တွင် ကဏန်းကို ကူသော ပိုးက ဘာလဲ။",
            answerID: "bee",
            choices: [
                ("bee", "ハチ", "蜜蜂", "A bee", "ပျား"),
                ("centipede", "ムカデ", "蜈蚣", "A centipede", "ကျော့ကွေး"),
            ],
            explainJA: "正解はハチ。日本の昔話『さるかに合戦』。サルがカニの柿をだまして取り、親ガニを傷つける。子どもカニはハチ・クリ・臼などの仲間と仕返しする。ムカデは出てこない。",
            explainZH: "正确答案是蜜蜂。这是日本民间故事《猴子和螃蟹打仗》：猴子骗走螃蟹的柿子并伤害蟹妈妈，小螃蟹靠蜜蜂、栗子、石臼等伙伴报仇。蜈蚣没有出场。",
            explainEN: "A bee. This is the Japanese folk tale Saru Kani Gassen: a monkey cheats a crab out of a persimmon and hurts the parent crab. The children get help from a bee, a chestnut, and a mortar. No centipede.",
            explainMY: "အဖြေမှန်က ပျား။ ဂျပန် ဒဏ္ဍာရီ 『ဆရု ကနိ ဂတ်ဆင်』။ ပျား၊ သစ်အယ်၊ ကျည်ပွေ့က ကူသည်။"
        ),
        Item(
            id: "jp-edo",
            ja: "江戸は今のどこ？",
            zh: "江户相当于现在的哪里？",
            en: "What is Edo now?",
            my: "အဲဒိုက ယခု ဘယ်မှာလဲ။",
            answerID: "tokyo",
            choices: [
                ("tokyo", "東京", "东京", "Tokyo", "တိုကျို"),
                ("kyoto", "京都", "京都", "Kyoto", "ကျိုတို"),
            ],
            explainJA: "正解は東京。1868年に江戸が東京と改められ、首都になった。",
            explainZH: "正确答案是东京。1868 年江户改称东京，成为首都。",
            explainEN: "Edo was renamed Tokyo in 1868.",
            explainMY: "အဖြေမှန်က တိုကျို။ ၁၈၆၈ တွင် အမည်ပြောင်းသည်။"
        ),
        Item(
            id: "jp-castle",
            ja: "日本のお城はどっち？",
            zh: "哪一个是日本的城堡？",
            en: "Which one is a Japanese castle?",
            my: "ဂျပန်ရဲတိုက်က ဘယ်ဟာလဲ။",
            answerID: "himeji",
            choices: [
                ("tower", "東京タワー", "东京塔", "Tokyo Tower", "တိုကျိုတာဝါ"),
                ("himeji", "姫路城", "姬路城", "Himeji Castle", "ဟိမဲဂျိရဲတိုက်"),
            ],
            explainJA: "正解は姫路城。白鷺城とも呼ばれる国宝。東京タワーは1958年の電波塔。",
            explainZH: "正确答案是姬路城，也叫白鹭城。东京塔是 1958 年的电波塔，不是城。",
            explainEN: "Himeji Castle. Tokyo Tower is a 1958 TV tower.",
            explainMY: "အဖြေမှန်က ဟိမဲဂျိရဲတိုက်။ တိုကျိုတာဝါက ရဲတိုက် မဟုတ်။"
        ),
        Item(
            id: "jp-katana",
            ja: "昔の武士の代表的な武器は？",
            zh: "古代武士的代表性武器是什么？",
            en: "What was a samurai's typical weapon?",
            my: "ရှေးရဲဘူရှီရဲ့ လက်နက်က ဘာလဲ။",
            answerID: "sword",
            choices: [
                ("broom", "ほうき", "扫帚", "A broom", "တံမြက်စည်း"),
                ("sword", "刀", "刀", "A sword", "ဓား"),
            ],
            explainJA: "正解は刀。武士の刀は日本刀。ほうきは掃除用具。",
            explainZH: "正确答案是刀。武士用日本刀。扫帚是扫地的。",
            explainEN: "A sword (katana). A broom is for cleaning.",
            explainMY: "အဖြေမှန်က ဓား။ တံမြက်စည်းက သန့်ရှင်းရေး။"
        ),
        Item(
            id: "jp-takoyaki-fill",
            ja: "たこ焼きによく入っているのは？",
            zh: "章鱼烧里面通常放什么？",
            en: "What is usually inside takoyaki?",
            my: "တာကိုယာကိထဲ ဘာထည့်တတ်သလဲ။",
            answerID: "octopus",
            choices: [
                ("octopus", "タコ", "章鱼", "Octopus", "ရေဘဝဲ"),
                ("squid", "イカ", "鱿鱼", "Squid", "စကွစ်"),
            ],
            explainJA: "正解はタコ。たこ焼きの中はたこ。いかではない。",
            explainZH: "正确答案是章鱼。章鱼烧里面是章鱼，不是鱿鱼。",
            explainEN: "Octopus. The name tako means octopus.",
            explainMY: "အဖြေမှန်က ရေဘဝဲ။ နာမည် တကို = ရေဘဝဲ။"
        ),
        Item(
            id: "jp-osaka-food",
            ja: "大阪名物として有名なのは？",
            zh: "哪个是大阪的著名美食？",
            en: "Which food is Osaka famous for?",
            my: "အိုဆာကာ အထင်ကရ စားစရာက ဘယ်ဟာလဲ။",
            answerID: "takoyaki",
            choices: [
                ("monja", "もんじゃ焼き", "文字烧", "Monjayaki", "မွန်ဂျာယာကိ"),
                ("takoyaki", "たこ焼き", "章鱼烧", "Takoyaki", "တာကိုယာကိ"),
            ],
            explainJA: "正解はたこ焼き。大阪の名物。もんじゃ焼きは東京・月島が有名。",
            explainZH: "正确答案是章鱼烧，大阪名物。文字烧更有名的是东京月岛。",
            explainEN: "Takoyaki is an Osaka specialty. Monjayaki is famous in Tsukishima, Tokyo.",
            explainMY: "အဖြေမှန်က တာကိုယာကိ။ မွန်ဂျာယာကိက တိုကျို။"
        ),
        Item(
            id: "jp-sapporo-ramen",
            ja: "札幌ラーメンの代表的な味は？",
            zh: "札幌拉面的代表性口味是什么？",
            en: "What is the typical Sapporo ramen flavor?",
            my: "ဆပ်ပိုရို ရာမင် အရသာက ဘာလဲ။",
            answerID: "miso",
            choices: [
                ("tonkotsu", "とんこつ", "豚骨", "Tonkotsu", "တုန်ကိုဆု"),
                ("miso", "味噌", "味噌", "Miso", "မိဆို"),
            ],
            explainJA: "正解は味噌。札幌ラーメンは味噌味が代表。とんこつは博多などが有名。",
            explainZH: "正确答案是味噌。札幌拉面以味噌味为代表。豚骨更有名的是博多。",
            explainEN: "Miso. Sapporo ramen is known for miso; tonkotsu is famous in Hakata.",
            explainMY: "အဖြေမှန်က မိဆို။ တုန်ကိုဆုက ဟခတ။"
        ),
        Item(
            id: "jp-onigiri",
            ja: "おにぎりによく巻くのは？",
            zh: "饭团外面通常包什么？",
            en: "What is an onigiri usually wrapped in?",
            my: "အိုနိဂိရိ ဘာနဲ့ ပတ်တတ်သလဲ။",
            answerID: "nori",
            choices: [
                ("nori", "のり", "海苔", "Nori seaweed", "နိုရိ"),
                ("lettuce", "レタス", "生菜", "Lettuce", "ဆလတ်"),
            ],
            explainJA: "正解はのり。海苔で巻くのが一般的。レタス巻きは普通ではない。",
            explainZH: "正确答案是海苔。饭团一般包海苔，不包生菜。",
            explainEN: "Nori seaweed. Lettuce is not the usual wrap.",
            explainMY: "အဖြေမှန်က နိုရိ။ ဆလတ်နှင့် မပတ်။"
        ),
        Item(
            id: "jp-natto",
            ja: "納豆の材料は？",
            zh: "纳豆主要由什么制成？",
            en: "What is natto made from?",
            my: "နတ္တိုရဲ့ ပစ္စည်းက ဘာလဲ။",
            answerID: "soy",
            choices: [
                ("soy", "大豆", "大豆", "Soybeans", "ပဲပုပ်"),
                ("wheat", "小麦", "小麦", "Wheat", "ဂျုံ"),
            ],
            explainJA: "正解は大豆。納豆は大豆を発酵させた食べ物。小麦ではない。",
            explainZH: "正确答案是大豆。纳豆是发酵大豆，不是小麦。",
            explainEN: "Fermented soybeans, not wheat.",
            explainMY: "အဖြေမှန်က ပဲပုပ်။ ဂျုံမဟုတ်။"
        ),
        Item(
            id: "jp-osechi",
            ja: "おせち料理を食べるのは？",
            zh: "日本人在什么节日吃御节料理？",
            en: "When do people eat osechi?",
            my: "အိုဆဲချိ ဘယ်အချိန် စားသလဲ။",
            answerID: "newyear",
            choices: [
                ("halloween", "ハロウィン", "万圣节", "Halloween", "ဟယ်လိုဝင်း"),
                ("newyear", "お正月", "新年", "New Year", "နှစ်သစ်"),
            ],
            explainJA: "正解はお正月。おせちは正月に食べる伝統料理。ハロウィンの料理ではない。",
            explainZH: "正确答案是新年。御节是过年吃的传统菜，不是万圣节的。",
            explainEN: "New Year. Osechi is not a Halloween food.",
            explainMY: "အဖြေမှန်က နှစ်သစ်။ ဟယ်လိုဝင်း မဟုတ်။"
        ),
        Item(
            id: "jp-escalator",
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
            id: "jp-hotel",
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
            id: "jp-biwa",
            ja: "日本で一番大きい湖は？",
            zh: "日本最大的湖泊是什么？",
            en: "What is Japan's largest lake?",
            my: "ဂျပန်မှာ အကြီးဆုံးကန်က ဘာလဲ။",
            answerID: "biwa",
            choices: [
                ("biwa", "琵琶湖", "琵琶湖", "Lake Biwa", "ဘိဝကန်"),
                ("kasumigaura", "霞ヶ浦", "霞浦", "Lake Kasumigaura", "ခဆုမိဂအုရကန်"),
            ],
            explainJA: "正解は琵琶湖。滋賀県にあり、面積は日本の湖でいちばん大きい。霞ヶ浦は茨城県の広い湖だけど、琵琶湖より小さい。",
            explainZH: "正确答案是琵琶湖。在滋贺县，是日本面积最大的湖。霞浦在茨城县，也很大，但比琵琶湖小。",
            explainEN: "Lake Biwa in Shiga is Japan's largest by area. Kasumigaura in Ibaraki is wide, but smaller.",
            explainMY: "အဖြေမှန်က ဘိဝကန်။ ရှိဂတွင်ရှိပြီး ဧရိယာ အကြီးဆုံး။ ခဆုမိဂအုရက ပိုသေးသည်။"
        ),
        Item(
            id: "jp-shinano",
            ja: "日本で一番長い川は？",
            zh: "日本最长的河流是什么？",
            en: "What is Japan's longest river?",
            my: "ဂျပန်မှာ အရှည်ဆုံးမြစ်က ဘာလဲ။",
            answerID: "shinano",
            choices: [
                ("tone", "利根川", "利根川", "the Tone River", "တိုနမြစ်"),
                ("shinano", "信濃川", "信浓川", "the Shinano River", "ရှိနနိုမြစ်"),
            ],
            explainJA: "正解は信濃川。長さは約367キロで日本一。利根川は流域面積がいちばん広い川。",
            explainZH: "正确答案是信浓川。全长约 367 公里，是日本最长的河。利根川是流域面积最大的河。",
            explainEN: "The Shinano is about 367 km, Japan's longest. The Tone has the largest drainage basin.",
            explainMY: "အဖြေမှန်က ရှိနနိုမြစ်။ ၃၆၇ ကီလိုခန့်၊ အရှည်ဆုံး။ တိုနက စီးဆင်းဧရိယာ အကျယ်ဆုံး။"
        ),
        Item(
            id: "jp-usagi-jima",
            ja: "「うさぎ島」と呼ばれる大久野島があるのは？",
            zh: "被称为兔子岛的大久野岛位于哪里？",
            en: "Where is Okunoshima, the “rabbit island”?",
            my: "ယုန်ကျွန်းဟု ခေါ်သော အိုခုနိုရှိမ ဘယ်မှာလဲ။",
            answerID: "hiroshima",
            choices: [
                ("fukuoka", "福岡県", "福冈县", "Fukuoka Prefecture", "ဖုခုအိုကခရိုင်"),
                ("hiroshima", "広島県", "广岛县", "Hiroshima Prefecture", "ဟီရိုရှီးမားခရိုင်"),
            ],
            explainJA: "正解は広島県。瀬戸内海の大久野島は野うさぎが多いのでうさぎ島と呼ばれる。",
            explainZH: "正确答案是广岛县。濑户内海的大久野岛野兔很多，所以叫兔子岛。",
            explainEN: "Hiroshima. Okunoshima in the Seto Inland Sea is full of wild rabbits.",
            explainMY: "အဖြေမှန်က ဟီရိုရှီးမား။ ဆဲတို ကုန်းတွင်းပင်လယ်က ယုန်များသော ကျွန်း။"
        ),
        Item(
            id: "jp-fuji-prefectures",
            ja: "富士山がまたがる2つの県は？",
            zh: "富士山横跨哪两个县？",
            en: "Which two prefectures does Mount Fuji straddle?",
            my: "ဖူဂျီတောင် ကူးသော ခရိုင် နှစ်ခုက ဘယ်ဟာလဲ။",
            answerID: "shizuoka-yamanashi",
            choices: [
                ("shizuoka-yamanashi", "静岡県と山梨県", "静冈县和山梨县", "Shizuoka and Yamanashi", "ရှိဇုအိုကနှင့် ယာမနရှိ"),
                ("shizuoka-nagano", "静岡県と長野県", "静冈县和长野县", "Shizuoka and Nagano", "ရှိဇုအိုကနှင့် နာဂနို"),
            ],
            explainJA: "正解は静岡県と山梨県。山頂は県境付近。長野県にはまたがらない。",
            explainZH: "正确答案是静冈县和山梨县。山顶在两县交界附近，不跨长野县。",
            explainEN: "Shizuoka and Yamanashi. The summit sits near that border, not in Nagano.",
            explainMY: "အဖြေမှန်က ရှိဇုအိုကနှင့် ယာမနရှိ။ နာဂနို မဟုတ်။"
        ),
        Item(
            id: "jp-osechi-food",
            ja: "お正月に食べる伝統料理は？",
            zh: "日本新年吃的传统料理是什么？",
            en: "What traditional food is eaten at New Year in Japan?",
            my: "နှစ်သစ်တွင် စားသော ရိုးရာဟင်းက ဘာလဲ။",
            answerID: "osechi",
            choices: [
                ("osechi", "おせち料理", "御节料理", "Osechi", "အိုဆဲချိ"),
                ("hiyashi", "冷やし中華", "冷面", "Hiyashi chuka", "အေးခေါက်ဆွဲ"),
            ],
            explainJA: "正解はおせち料理。重箱にめでたい食材を詰めて正月に食べる。冷やし中華は夏の麺。",
            explainZH: "正确答案是御节料理。装在多层食盒里，过年吃。冷面是夏天的面。",
            explainEN: "Osechi, packed in lacquer boxes for New Year. Hiyashi chuka is a summer noodle dish.",
            explainMY: "အဖြေမှန်က အိုဆဲချိ။ နှစ်သစ်ဟင်း။ အေးခေါက်ဆွဲက နွေရာသီ။"
        ),
        Item(
            id: "jp-toshikoshi",
            ja: "年越しそばを食べるのは？",
            zh: "日本人通常哪天吃跨年荞麦面？",
            en: "When do people eat toshikoshi soba?",
            my: "တိုရှိကိုရှိ ဆိုဘါ ဘယ်နေ့ စားသလဲ။",
            answerID: "dec31",
            choices: [
                ("jan1", "1月1日", "1月1日", "January 1", "ဇန်နဝါရီ ၁"),
                ("dec31", "12月31日", "12月31日", "December 31", "ဒီဇင်ဘာ ၃၁"),
            ],
            explainJA: "正解は12月31日。大晦日に細く長いそばを食べて、年を越す。1月1日はおせちの日。",
            explainZH: "正确答案是 12 月 31 日。除夕吃细长的荞麦面迎接新年。1 月 1 日吃御节。",
            explainEN: "December 31. People eat long, thin soba on New Year's Eve. January 1 is for osechi.",
            explainMY: "အဖြေမှန်က ဒီဇင်ဘာ ၃၁။ နှစ်ကုန်ည ဆိုဘါစားသည်။ ဇန်နဝါရီ ၁ က အိုဆဲချိ။"
        ),
        Item(
            id: "jp-joya-no-kane",
            ja: "除夜の鐘は伝統的に何回つく？",
            zh: "日本除夕夜的钟传统上敲多少次？",
            en: "How many times is the New Year's Eve temple bell traditionally struck?",
            my: "နှစ်ကုန်ည ခေါင်းလောင်း ရိုးရာအရ ဘယ်နှစ်ခါ ခေါက်သလဲ။",
            answerID: "108",
            choices: [
                ("108", "108回", "108 次", "108 times", "၁၀၈ ကြိမ်"),
                ("100", "100回", "100 次", "100 times", "၁၀၀ ကြိမ်"),
            ],
            explainJA: "正解は108回。人の108の煩悩を打ち消すためと言われる。",
            explainZH: "正确答案是 108 次。传说是为了敲去人的 108 种烦恼。",
            explainEN: "108 times. It is said to drive away 108 earthly desires.",
            explainMY: "အဖြေမှန်က ၁၀၈ ကြိမ်။ လူ့စိတ်ညစ် ၁၀၈ ခု ပယ်ရန်ဟု ဆိုသည်။"
        ),
        Item(
            id: "jp-obon",
            ja: "お盆の行事が多い季節は？",
            zh: "日本盂兰盆节的活动主要在哪个季节？",
            en: "In which season is Obon mostly observed?",
            my: "အိုဘွန်ပွဲ များသော ရာသီက ဘယ်ဟာလဲ။",
            answerID: "summer",
            choices: [
                ("spring", "春", "春天", "Spring", "နွေဦး"),
                ("summer", "夏", "夏天", "Summer", "နွေ"),
            ],
            explainJA: "正解は夏。多くの地域では8月（一部は7月）にお盆で先祖を迎える。春の行事ではない。",
            explainZH: "正确答案是夏天。很多地方在 8 月（有的在 7 月）过盂兰盆，迎接祖先。不是春天的节日。",
            explainEN: "Summer. Many areas mark Obon in August (some in July) to welcome ancestors.",
            explainMY: "အဖြေမှန်က နွေ။ များသောအားဖြင့် သြဂုတ် (အချို့ ဇူလိုင်) တွင် ဘိုးဘွားကြိုသည်။"
        ),
        Item(
            id: "jp-himeji-alias",
            ja: "姫路城の別名は？",
            zh: "姬路城的别名是什么？",
            en: "What is Himeji Castle's nickname?",
            my: "ဟိမဲဂျိရဲတိုက် ရဲ့ အခြားအမည်က ဘာလဲ။",
            answerID: "egret",
            choices: [
                ("egret", "白鷺城", "白鹭城", "White Heron Castle", "စွန်ဖြူရဲတိုက်"),
                ("crow", "烏城", "乌城", "Crow Castle", "ကျီးရဲတိုက်"),
            ],
            explainJA: "正解は白鷺城。白い壁が白鷺のように見えるから。烏城は岡山城の別名。",
            explainZH: "正确答案是白鹭城。白墙看起来像白鹭。乌城是冈山城的别名。",
            explainEN: "White Heron Castle, from its white walls. Crow Castle is Okayama Castle's nickname.",
            explainMY: "အဖြေမှန်က စွန်ဖြူရဲတိုက်။ နံရံဖြူကြောင့်။ ကျီးရဲတိုက်က အိုကာယာမ။"
        ),
        Item(
            id: "jp-shinkansen",
            ja: "日本で最初に開業した新幹線は？",
            zh: "日本最早开通的新干线是什么？",
            en: "Which was Japan's first shinkansen line?",
            my: "ဂျပန်မှာ ပထမဆုံး ရှင်ခန်ဆန်းက ဘယ်ဟာလဲ။",
            answerID: "tokaido",
            choices: [
                ("tohoku", "東北新幹線", "东北新干线", "the Tohoku Shinkansen", "တိုဟိုခု ရှင်ခန်ဆန်း"),
                ("tokaido", "東海道新幹線", "东海道新干线", "the Tokaido Shinkansen", "တိုခိုင်ဒို ရှင်ခန်ဆန်း"),
            ],
            explainJA: "正解は東海道新幹線。1964年、東京と新大阪の間で開業した。東北新幹線は1982年。",
            explainZH: "正确答案是东海道新干线。1964 年在东京和新大阪之间开通。东北新干线是 1982 年。",
            explainEN: "The Tokaido Shinkansen opened in 1964 between Tokyo and Shin-Osaka. Tohoku opened in 1982.",
            explainMY: "အဖြေမှန်က တိုခိုင်ဒို။ ၁၉၆၄ တိုကျို–ရှင်အိုဆာကာ။ တိုဟိုခုက ၁၉၈၂။"
        ),
        Item(
            id: "jp-miso-ramen-place",
            ja: "味噌ラーメンで有名なのは？",
            zh: "哪个地方以味噌拉面闻名？",
            en: "Which place is famous for miso ramen?",
            my: "မိဆိုရာမင်ကျော်ကြားသော နေရာက ဘယ်ဟာလဲ။",
            answerID: "sapporo",
            choices: [
                ("sapporo", "札幌", "札幌", "Sapporo", "ဆပ်ပိုရို"),
                ("hakata", "博多", "博多", "Hakata", "ဟခတ"),
            ],
            explainJA: "正解は札幌。北海道の味噌ラーメンが代表。博多はとんこつラーメンが有名。",
            explainZH: "正确答案是札幌。北海道味噌拉面很有名。博多更有名的是豚骨拉面。",
            explainEN: "Sapporo, for Hokkaido miso ramen. Hakata is known for tonkotsu ramen.",
            explainMY: "အဖြေမှန်က ဆပ်ပိုရို။ ဟခတက တုန်ကိုဆုရာမင်။"
        ),
        Item(
            id: "jp-oyakodon",
            ja: "親子丼によく使うのは？",
            zh: "亲子丼通常使用哪两种食材？",
            en: "What is usually used in oyakodon?",
            my: "အိုယာကိုဒွန်တွင် ဘာသုံးတတ်သလဲ။",
            answerID: "chicken-egg",
            choices: [
                ("chicken-egg", "鶏肉と卵", "鸡肉和鸡蛋", "Chicken and egg", "ကြက်သားနှင့် ကြက်ဥ"),
                ("pork-egg", "豚肉と卵", "猪肉和鸡蛋", "Pork and egg", "ဝက်သားနှင့် ကြက်ဥ"),
            ],
            explainJA: "正解は鶏肉と卵。親の鶏と子の卵を一緒に煮るから親子丼。豚肉だと他人丼など別の名前になる。",
            explainZH: "正确答案是鸡肉和鸡蛋。鸡是“亲”，蛋是“子”，所以叫亲子丼。用猪肉就成了别的丼。",
            explainEN: "Chicken and egg: the “parent” and “child.” Pork makes a different donburi.",
            explainMY: "အဖြေမှန်က ကြက်သားနှင့် ကြက်ဥ။ မိဘနှင့် သားဟု အမည်ရသည်။ ဝက်သားက အခြားဒွန်။"
        ),
        Item(
            id: "jp-taiyaki",
            ja: "たい焼きの形はどんな魚？",
            zh: "鲷鱼烧的形状模仿什么鱼？",
            en: "What fish is taiyaki shaped like?",
            my: "တိုင်ယာကိ ပုံစံက ဘယ်ငါးလဲ။",
            answerID: "tai",
            choices: [
                ("sake", "サケ", "鲑鱼", "Salmon", "ဆော်မွန်"),
                ("tai", "タイ", "鲷鱼", "Sea bream (tai)", "တိုင်ငါး"),
            ],
            explainJA: "正解はタイ。めでたい魚の鯛の形に焼いた和菓子。サケの形ではない。",
            explainZH: "正确答案是鲷鱼。做成吉祥的真鲷形状。不是鲑鱼。",
            explainEN: "Sea bream (tai), an auspicious fish. It is not shaped like salmon.",
            explainMY: "အဖြေမှန်က တိုင်ငါး။ ကံကောင်းငါးပုံ။ ဆော်မွန် မဟုတ်။"
        ),
        Item(
            id: "jp-udon-kagawa",
            ja: "「うどん県」として有名なのは？",
            zh: "哪个县以乌冬面闻名，被称为乌冬县？",
            en: "Which prefecture is famous as the “udon prefecture”?",
            my: "ဥဒွန်ခရိုင်ဟု ကျော်ကြားသော နေရာက ဘယ်ဟာလဲ။",
            answerID: "kagawa",
            choices: [
                ("kagawa", "香川県", "香川县", "Kagawa Prefecture", "ခဂဝခရိုင်"),
                ("fukuoka", "福岡県", "福冈县", "Fukuoka Prefecture", "ဖုခုအိုကခရိုင်"),
            ],
            explainJA: "正解は香川県。讃岐うどんの産地で、うどん県と呼ばれる。福岡はとんこつラーメンが有名。",
            explainZH: "正确答案是香川县。赞岐乌冬的产地，所以叫乌冬县。福冈更有名的是豚骨拉面。",
            explainEN: "Kagawa, home of Sanuki udon. Fukuoka is better known for tonkotsu ramen.",
            explainMY: "အဖြေမှန်က ခဂဝ။ စနုကိဥဒွန်။ ဖုခုအိုကက တုန်ကိုဆုရာမင်။"
        ),
    ]
}
