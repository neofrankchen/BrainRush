import Foundation

/// ストループ効果：字の色と書かれた文字が食い違う二択。
enum ColorWordBank {
    static var count: Int { allRounds().count }

    static var rule: String {
        tr(ja: "見えている色を選べ", zh: "选择你看到的颜色", en: "Choose the color you see", my: "မြင်ရသော အရောင်ကို ရွေးပါ")
    }

    static func pick() -> StroopRound {
        allRounds().randomElement() ?? make(ink: .red, word: .blue)
    }

    static func allRounds() -> [StroopRound] {
        pairs.map { make(ink: $0.ink, word: $0.word) }
    }

    static func localized(_ round: StroopRound) -> StroopRound {
        var translated = round
        translated.rule = rule
        translated.choices = round.choices.map { choice in
            let title = StroopColor(rawValue: choice.id)?.name ?? choice.title
            return AnswerChoice(id: choice.id, title: title, symbol: choice.symbol, style: choice.style, badge: choice.badge)
        }
        return translated
    }

    static func explanation(word: StroopColor, ink: StroopColor) -> String {
        tr(
            ja: "この問題は文字の色を見るよ。色は「\(ink.name)」、書かれた文字は「\(word.name)」。だから「\(ink.name)」が正解！",
            zh: "这题看的是字的颜色。颜色是「\(ink.name)」，写的字才是「\(word.name)」，所以选「\(ink.name)」。",
            en: "This asks for the ink color: \(ink.name). The word says \(word.name), but that isn't what this question asks for.",
            my: "ဒီမေးခွန်းက မင်အရောင်ကို မေးတာပါ။ မင်က \(ink.name)၊ စာသားက \(word.name) ဖြစ်လို့ \(ink.name) ကိုရွေးပါ။",
            ko: "이 문제는 글자 색을 봐요. 색은 「\(ink.name)」, 쓰인 글자는 「\(word.name)」. 그래서 「\(ink.name)」이 정답이에요!",
            fr: "Il faut la couleur : \(ink.name). Le mot dit \(word.name), mais ce n’est pas la question.",
            zhHant: "這題看的是字的顏色。顏色是「\(ink.name)」，寫的字才是「\(word.name)」，所以選「\(ink.name)」。"
        )
    }

    private static let pairs: [(ink: StroopColor, word: StroopColor)] = [
        (.red, .yellow),
        (.red, .green),
        (.red, .blue),
        (.yellow, .red),
        (.yellow, .green),
        (.yellow, .blue),
        (.green, .red),
        (.green, .yellow),
        (.blue, .red),
        (.blue, .green),
    ]

    private static func make(ink: StroopColor, word: StroopColor) -> StroopRound {
        StroopRound(
            task: .colorWord,
            rule: rule,
            answerID: ink.rawValue,
            choices: [ink, word].shuffled().map { color in
                AnswerChoice(id: color.rawValue, title: color.name, symbol: nil, style: .neutral)
            },
            stimulus: .word(word, ink: ink)
        )
    }
}
