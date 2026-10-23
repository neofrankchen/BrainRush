import Foundation

extension StroopRound {
    /// 正解・不正解のあと、いま解いた問題の解説を出す。題は種類ごとのファイルを見る。
    var answerExplanation: String {
        switch stimulus {
        case .word(let word, let ink):
            return ColorWordBank.explanation(word: word, ink: ink)
        case .emblem(let id):
            if BrainTeaserBank.template(id: id) != nil {
                return BrainTeaserBank.explanation(id: id)
            }
            if HardChoiceBank.template(id: id) != nil {
                return HardChoiceBank.explanation(id: id)
            }
            if FunChoiceBank.template(id: id) != nil {
                return FunChoiceBank.explanation(id: id)
            }
            if FoodChoiceBank.template(id: id) != nil {
                return FoodChoiceBank.explanation(id: id)
            }
            return KidChoiceBank.explanation(id: id)
        case .flag(let id, _):
            if StudentFlagBank.template(id: id) != nil {
                return StudentFlagBank.explanation(id: id)
            }
            return GdpFlagBank.explanation(id: id)
        }
    }
}
