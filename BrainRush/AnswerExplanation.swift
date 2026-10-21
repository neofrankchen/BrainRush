import Foundation

extension StroopRound {
    /// Explain the conflicting cues from the resolved round, never from the next question.
    var answerExplanation: String {
        switch stimulus {
        case .word(let word, let ink):
            if answerID == ink.rawValue {
                return tr(ja: "この問題は文字の色を見るよ。色は「\(ink.name)」、書かれた文字は「\(word.name)」。だから「\(ink.name)」が正解！", zh: "这题看的是字的颜色。颜色是「\(ink.name)」，写的字才是「\(word.name)」，所以选「\(ink.name)」。", en: "This asks for the ink color: \(ink.name). The word says \(word.name), but that isn't what this question asks for.", my: "ဒီမေးခွန်းက မင်အရောင်ကို မေးတာပါ။ မင်က \(ink.name)၊ စာသားက \(word.name) ဖြစ်လို့ \(ink.name) ကိုရွေးပါ။")
            }
            return tr(ja: "この問題は書かれた文字を読むよ。「\(word.name)」と書いてあるので正解は「\(word.name)」。\(ink.name)は文字の色だよ。", zh: "这题看的是写了什么字。写的是「\(word.name)」，所以选「\(word.name)」；「\(ink.name)」只是字的颜色。", en: "Read the word: it says \(word.name). \(ink.name) is only the ink color, so choose \(word.name).", my: "ဒီမေးခွန်းက စာသားကို မေးတာပါ။ \(word.name) လို့ရေးထားလို့ \(word.name) ကိုရွေးပါ။ \(ink.name) က မင်အရောင်သာ ဖြစ်ပါတယ်။")
        case .placedArrow(let direction, let place):
            if answerID == direction.rawValue {
                return tr(ja: "矢印の向きは「\(direction.name)」。置かれている場所は「\(place.name)」だけど、今回は向きを答えるよ。", zh: "箭头指向「\(direction.name)」，只是放在「\(place.name)」边。这题问指向，所以选「\(direction.name)」。", en: "The arrow points \(direction.name), but sits on the \(place.name) side. This question asks where it points.", my: "မြားက \(direction.name) ကိုညွှန်ပြီး \(place.name) ဘက်မှာရှိပါတယ်။ ဒီတစ်ခါ ညွှန်တဲ့ဘက်ကို မေးတာပါ။")
            }
            return tr(ja: "矢印が置かれているのは「\(place.name)」。向きは「\(direction.name)」だけど、今回は場所を答えるよ。", zh: "箭头在「\(place.name)」边，指向「\(direction.name)」。这题问所在位置，所以选「\(place.name)」。", en: "The arrow sits on the \(place.name) side. It points \(direction.name), but this question asks for its location.", my: "မြားက \(place.name) ဘက်မှာရှိပါတယ်။ \(direction.name) ကိုညွှန်သော်လည်း ဒီတစ်ခါ ရှိတဲ့နေရာကို မေးတာပါ။")
        case .placedWord(let word, let place):
            if answerID == word.rawValue {
                return tr(ja: "書いてある文字は「\(word.name)」。場所は「\(place.name)」だけど、今回は文字を読むよ。", zh: "写的是「\(word.name)」，只是放在「\(place.name)」边。这题问字的内容，所以选「\(word.name)」。", en: "The word says \(word.name), although it sits on the \(place.name) side. This asks what the word says.", my: "စာသားက \(word.name) လို့ရေးထားပြီး \(place.name) ဘက်မှာရှိပါတယ်။ ဒီတစ်ခါ စာသားကို မေးတာပါ။")
            }
            return tr(ja: "文字がある場所は「\(place.name)」。文字は「\(word.name)」だけど、今回は場所を答えるよ。", zh: "字在「\(place.name)」边，写的内容是「\(word.name)」。这题问位置，所以选「\(place.name)」。", en: "The word is on the \(place.name) side. It says \(word.name), but this asks where it is.", my: "စာသားက \(place.name) ဘက်မှာရှိပါတယ်။ \(word.name) လို့ရေးသော်လည်း ဒီတစ်ခါ နေရာကို မေးတာပါ။")
        case .digits(let value, let count):
            let shown = String(repeating: "\(value)", count: count)
            if answerID == "\(count)" {
                return tr(ja: "「\(value)」が\(count)個並んでいるね。今回は数字の個数なので「\(count)」が正解。「\(shown)」は並び全体だよ。", zh: "这里有 \(count) 个「\(value)」。这题问数量，所以选「\(count)」；「\(shown)」是整串数字。", en: "There are \(count) copies of \(value). This asks how many digits there are, so choose \(count), not the whole number \(shown).", my: "\(value) က \(count) လုံးရှိပါတယ်။ ဒီတစ်ခါ အရေအတွက်ကို မေးလို့ \(count) ကိုရွေးပါ၊ \(shown) မဟုတ်ပါ။")
            }
            return tr(ja: "今回は書かれた数全体を読むよ。「\(shown)」が正解。「\(count)」は数字の個数だよ。", zh: "这题读的是整串数字，所以选「\(shown)」；「\(count)」是数字的个数。", en: "This asks for the whole written number: \(shown). \(count) is how many digits there are, which is a different question.", my: "ဒီတစ်ခါ ရေးထားတဲ့ ကိန်းတစ်ခုလုံးကို မေးလို့ \(shown) ကိုရွေးပါ။ \(count) က ဂဏန်းအရေအတွက်ပါ။")
        case .pair(let left, let right, let leftUsesLargerFont):
            let biggerText = leftUsesLargerFont ? left : right
            let largerValue = max(left, right)
            if answerID == "\(biggerText)" {
                return tr(ja: "今回は文字の大きさを見るよ。大きく印刷されているのは「\(biggerText)」。数の値が大きい「\(largerValue)」とは別だよ。", zh: "这题比字体大小。「\(biggerText)」的字印得更大，所以选它；「\(largerValue)」才是数值更大。", en: "Compare text size: \(biggerText) is printed bigger. \(largerValue) has the larger numeric value, but that's a different comparison.", my: "ဒီတစ်ခါ စာလုံးအရွယ်ကို နှိုင်းပါ။ \(biggerText) က စာလုံးပိုကြီးပါတယ်။ \(largerValue) က ကိန်းတန်ဖိုးပိုကြီးတာပါ။")
            }
            return tr(ja: "今回は数の値を比べるよ。\(largerValue)は\(min(left, right))より大きい。文字が大きい「\(biggerText)」に惑わされないでね。", zh: "这题比数值。\(largerValue) 比 \(min(left, right)) 大，所以选「\(largerValue)」；「\(biggerText)」只是字体更大。", en: "Compare numeric values: \(largerValue) is greater than \(min(left, right)). \(biggerText) is only printed in bigger text.", my: "ဒီတစ်ခါ ကိန်းတန်ဖိုးကို နှိုင်းပါ။ \(largerValue) က \(min(left, right)) ထက်ကြီးပါတယ်။ \(biggerText) က စာလုံးအရွယ်သာ ကြီးတာပါ။")
        case .emblem(let id):
            return teaserExplanation(id)
        }
    }

    private func teaserExplanation(_ id: String) -> String {
        switch id {
        case "race":
            return tr(ja: "2位の人を抜くと、その人の位置に入るから2位。1位の人はまだ前にいるよ。", zh: "超过第二名后，你占了他的位置，变成第二名；第一名还在你前面。", en: "You take second place from the person you pass. The leader is still ahead of you.", my: "ဒုတိယလူကို ကျော်ရင် သူ့နေရာကိုယူလို့ ဒုတိယဖြစ်ပါတယ်။ ပထမလူက ရှေ့မှာရှိနေဆဲပါ။")
        case "iron-cotton":
            return tr(ja: "どちらも1キロなので同じ重さ。材料や見た目の大きさは関係ないよ。", zh: "两边都是一公斤，所以一样重；材料和体积不会改变题目给出的重量。", en: "Both weigh 1 kg. Their different materials and volumes don't change that.", my: "နှစ်ခုလုံး တစ်ကီလိုဖြစ်လို့ အလေးချိန်တူပါတယ်။ ပစ္စည်းနှင့် ထုထည် ကွာတာကို မနှိုင်းပါနဲ့။")
        case "apples":
            return tr(ja: "聞かれたのは残りではなく、自分が持っている数。2個取ったので2個だよ。", zh: "问的是你拿到了几个，不是桌上剩几个。你拿走两个，所以你有两个。", en: "It asks how many you have, not how many remain. You took 2, so you have 2.", my: "ကျန်တဲ့အရေအတွက်မဟုတ်ဘဲ မင်းဆီရှိတာကို မေးတာပါ။ ၂ လုံးယူထားလို့ ၂ လုံးရှိပါတယ်။")
        case "machines":
            return tr(ja: "同じ機械が同時に動くなら、1台が5分で1個作る。100台で100個でも5分だよ。", zh: "假设机器效率相同、同时工作，每台5分钟做一个。100台同时做100个，仍然只要5分钟。", en: "Assuming identical machines working in parallel, each makes one product in 5 minutes. So 100 machines make 100 in 5 minutes.", my: "စက်တွေ အလုပ်နှုန်းတူပြီး တစ်ပြိုင်နက်လုပ်ရင် တစ်လုံးက ၅ မိနစ်မှာ တစ်ခုလုပ်ပါတယ်။ စက် ၁၀၀ က ပစ္စည်း ၁၀၀ ကိုလည်း ၅ မိနစ်ပါ။")
        case "snail-teeth":
            return tr(ja: "ここでは歯舌にある小さな歯を数えるよ。種によって数は違うけれど、この二択では約1万本が想定された答え。", zh: "这里说的是齿舌上密集的小齿，数量会随物种变化。这道二选一题采用约一万颗的近似答案，并非所有蜗牛都固定有一万颗。", en: "This counts tiny teeth on the radula. Counts vary by species; about 10,000 is this quiz's approximate answer, not a fixed count for every snail.", my: "လျှာပေါ်က သွားငယ်များကို ရေတွက်တာပါ။ မျိုးစိတ်အလိုက် ကွာသော်လည်း ဒီမေးခွန်းက ၁၀၀၀၀ ခန့်ဟု သတ်မှတ်ထားပါတယ်။")
        case "ostrich-eye":
            return tr(ja: "ダチョウは眼球がとても大きく、脳より大きいとされるよ。この二択で小さい方は脳。", zh: "鸵鸟的眼球很大，通常被描述为比大脑还大。因此这道二选一里，更小的是大脑。", en: "An ostrich's very large eyeball is commonly described as larger than its brain, so the smaller of these two is the brain.", my: "ငှက်ကုလားအုပ်ရဲ့ မျက်လုံးက ဦးနှောက်ထက်ကြီးတယ်လို့ ဖော်ပြလေ့ရှိလို့ ဒီနှစ်ခုထဲမှာ ဦးနှောက်က ပိုသေးပါတယ်။")
        case "firework-whistle":
            return tr(ja: "この問題は笛のように鳴る花火を想定しているよ。その音は空気との摩擦ではなく、音を出すための仕掛けによるもの。", zh: "这题指的是有哨音效果的烟花：声音来自专门产生哨音的结构，而不是简单的空气摩擦；并非所有烟花都一样。", en: "This refers to a whistling firework: its whistle is produced by a deliberate sound-making design, rather than simple air friction. Not every firework works the same way.", my: "ဒီမေးခွန်းက နှုတ်သီးသံပါတဲ့ မီးပန်းကို ရည်ညွှန်းပါတယ်။ အသံက လေနှင့်ပွတ်တိုက်မှုမဟုတ်ဘဲ အသံထွက်စေသော တမင်ဖန်တီးထားတဲ့ အစိတ်အပိုင်းက လာပါတယ်။")
        case "bus-bunk":
            return tr(ja: "長距離では交代する運転手の休憩場所が必要になるため、車内に仮眠室を備えたバスがあるよ。", zh: "长途线路有时需要司机轮班，因此部分巴士设有供替班司机休息的隐蔽小卧铺。", en: "Some long-distance buses have a sleeping compartment so the off-duty driver can rest between shifts.", my: "ခရီးရှည်မှာ ယာဉ်မောင်း အလှည့်ကျအနားယူဖို့ အချို့ဘတ်စကားတွေမှာ အိပ်ခန်းငယ် ပါပါတယ်။")
        case "lion-room":
            return tr(ja: "このなぞなぞでは、3年間何も食べていないライオンはもう生きていない、と考えるよ。", zh: "这道谜题的关键是“三年没吃东西”：按谜题的设定，狮子早已饿死，因此不是活狮子带来的危险。", en: "The riddle's clue is three years without food: the lion would no longer be alive.", my: "ဒီပဟေဠိရဲ့ အဓိကအချက်က ၃ နှစ်အစာမစားတာပါ။ ခြင်္သေ့က အသက်မရှင်တော့ဘူးလို့ ယူဆတာဖြစ်ပါတယ်။")
        case "prison-visitor":
            return tr(ja: "彼が囚人とは書いていないね。面会者なら、保釈が認められなくても自分は帰れるよ。", zh: "题目没有说他是囚犯。如果他只是探监者，保释被拒并不妨碍他正常离开。", en: "It never says he is the prisoner. As a visitor, he can leave even if the prisoner's bail is denied.", my: "သူက အကျဉ်းသားလို့ မရေးထားပါ။ လာတွေ့သူဆိုရင် အာမခံငြင်းခံရသော်လည်း သူ ပြန်နိုင်ပါတယ်။")
        case "newborn":
            return tr(ja: "「別の人」が浮気相手とは限らないよ。生まれたばかりの自分の赤ちゃん、と考えると喜ぶ理由がわかるね。", zh: "“另一个人”不一定是情人，也可以是刚出生的孩子。这就解释了他为什么开心。", en: "Someone else doesn't have to mean a romantic partner. A newborn baby explains why he is happy.", my: "နောက်တစ်ယောက်က ချစ်သူဖြစ်ရမယ်လို့ မဆိုပါ။ မွေးခါစကလေးဆိုရင် သူပျော်တဲ့အကြောင်းကို ရှင်းပြနိုင်ပါတယ်။")
        case "pink-house":
            return tr(ja: "「平屋」がヒント。このなぞなぞは上の階へ行く階段がない家を想定しているよ。", zh: "关键是“单层”：这道谜题默认没有通往楼上的楼梯，因此不需要判断楼梯的颜色。", en: "The clue is one-story. This riddle assumes no stairs to an upper floor, so there is no stair color to name.", my: "အဓိကက တစ်ထပ်အိမ်ပါ။ ဒီပဟေဠိမှာ အပေါ်ထပ်တက်တဲ့ လှေကားမရှိဘူးလို့ ယူဆပါတယ်။")
        case "open-eyes":
            return tr(ja: "まだ寝ているのがヒント。ドアを開ける前に、まず目を開けて起きるよ。", zh: "关键是你还在睡觉。按谜题的意思，要先睁开眼睛醒来，再去开门。", en: "You're still asleep. The intended first step is opening your eyes before opening the door.", my: "မင်းက အိပ်နေဆဲပါ။ တံခါးမဖွင့်ခင် အရင်မျက်လုံးဖွင့်ပြီး နိုးရမယ်လို့ ရည်ရွယ်တာပါ။")
        default:
            return tr(ja: "問題の条件をもう一度読んで、チェックの付いた答えと比べてみよう。", zh: "再读一遍题目条件，对照带勾的正确选项看看。", en: "Read the conditions again and compare them with the checked answer.", my: "မေးခွန်းအခြေအနေကို ပြန်ဖတ်ပြီး အမှန်ခြစ်ထားသောအဖြေနှင့် နှိုင်းယှဉ်ပါ။")
        }
    }
}
