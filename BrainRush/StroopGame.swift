import SwiftUI
import AVFoundation

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case japanese
    case chinese
    case traditional
    case korean
    case english
    case french
    case burmese

    var id: String { rawValue }

    var label: String {
        switch self {
        case .japanese: "日本語"
        case .chinese: "简体"
        case .traditional: "繁體"
        case .korean: "한국어"
        case .english: "English"
        case .french: "Français"
        case .burmese: "မြန်မာ"
        }
    }
}

@MainActor
@Observable
final class LanguageStore {
    static let shared = LanguageStore()

    var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "appLanguage") }
    }

    private init() {
        language = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? "") ?? .japanese
    }
}

func tr(ja: String, zh: String, en: String, my: String, ko: String = "", fr: String = "", zhHant: String = "") -> String {
    let language = MainActor.assumeIsolated { LanguageStore.shared.language }
    let extra = ExtraLang.ui[ja]
    switch language {
    case .japanese: return ja
    case .chinese: return zh
    case .english: return en
    case .burmese: return my
    case .korean: return ExtraLang.first(ko, extra?.ko, en)
    case .french: return ExtraLang.first(fr, extra?.fr, en)
    case .traditional: return ExtraLang.first(zhHant, extra?.zhHant, ExtraLang.toTraditional(zh))
    }
}

struct LanguagePicker: View {
    var compact = false

    var body: some View {
        let selected = LanguageStore.shared.language
        LanguageWrap(spacing: compact ? 6 : 8) {
            ForEach(AppLanguage.allCases) { language in
                Button(language.label) {
                    LanguageStore.shared.language = language
                }
                .buttonStyle(.plain)
                .font(compact ? .caption2.weight(.semibold) : .subheadline.weight(.semibold))
                .foregroundStyle(CatQuizPalette.wood)
                .padding(.horizontal, compact ? 8 : 12)
                .padding(.vertical, compact ? 4 : 6)
                .frame(minHeight: compact ? 32 : 44)
                .background {
                    Capsule().fill(
                        selected == language
                            ? Color(red: 0.98, green: 0.74, blue: 0.32)
                            : CatQuizPalette.cream.opacity(0.9)
                    )
                }
                .accessibilityAddTraits(selected == language ? .isSelected : [])
                .accessibilityIdentifier("language-\(language.rawValue)")
            }
        }
    }
}

private struct LanguageWrap: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        let rows = rows(maxWidth: maxWidth, subviews: subviews)
        let height = rows.reduce(CGFloat(0)) { $0 + $1.height } + spacing * CGFloat(max(rows.count - 1, 0))
        let width = proposal.width ?? rows.map(\.width).max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(maxWidth: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for item in row.items {
                item.view.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: item.size.width, height: item.size.height)
                )
                x += item.size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Item {
        var view: LayoutSubview
        var size: CGSize
    }

    private struct Row {
        var items: [Item]
        var width: CGFloat
        var height: CGFloat
    }

    private func rows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var result: [Row] = []
        var items: [Item] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            let next = items.isEmpty ? size.width : width + spacing + size.width
            if next > maxWidth, !items.isEmpty {
                result.append(Row(items: items, width: width, height: height))
                items = [Item(view: view, size: size)]
                width = size.width
                height = size.height
            } else {
                items.append(Item(view: view, size: size))
                width = next
                height = max(height, size.height)
            }
        }
        if !items.isEmpty {
            result.append(Row(items: items, width: width, height: height))
        }
        return result
    }
}

enum InterferenceTask: String, CaseIterable {
    case colorWord
    case brainTeaser
    case hardChoice
    case funChoice
    case foodChoice
    case kidChoice
    case studentFlag
    case gdpFlag

    var title: String {
        switch self {
        case .colorWord: tr(ja: "色と字", zh: "色和字", en: "Color and word", my: "အရောင်နှင့် စာသား")
        case .brainTeaser: tr(ja: "ひっかけ問題", zh: "脑筋急转弯", en: "Brain teaser", my: "ပဟေဠိ")
        case .hardChoice: tr(ja: "難問2択", zh: "难问二选一", en: "Hard two-choice", my: "ခက်သော ၂ ခုရွေး")
        case .funChoice: tr(ja: "おもしろ2択", zh: "有趣二选一", en: "Fun two-choice", my: "ပျော်စရာ ၂ ခုရွေး")
        case .foodChoice: tr(ja: "食べ物2択", zh: "食物二选一", en: "Food two-choice", my: "အစားအစာ ၂ ခုရွေး")
        case .kidChoice: tr(ja: "幼児2択", zh: "幼儿二选一", en: "Kids two-choice", my: "ကလေး ၂ ခုရွေး")
        case .studentFlag: tr(ja: "留学生の旗", zh: "留学生旗帜", en: "Student flags", my: "ကျောင်းသားအလံ")
        case .gdpFlag: tr(ja: "GDPの旗", zh: "GDP旗帜", en: "GDP flags", my: "GDP အလံ")
        }
    }

    var family: QuestionFamily {
        switch self {
        case .colorWord: .stroop
        case .brainTeaser: .brainTeaser
        case .hardChoice: .hardChoice
        case .funChoice: .funChoice
        case .foodChoice: .foodChoice
        case .kidChoice: .kidChoice
        case .studentFlag: .studentFlag
        case .gdpFlag: .gdpFlag
        }
    }
}

enum QuestionFamily: String, CaseIterable, Identifiable {
    case stroop
    case brainTeaser
    case hardChoice
    case funChoice
    case foodChoice
    case kidChoice
    case studentFlag
    case gdpFlag

    var id: String { rawValue }

    var chipTitle: String {
        switch self {
        case .stroop: tr(ja: "ストループ効果", zh: "斯特鲁普效应", en: "Stroop Effect", my: "Stroop Effect")
        case .brainTeaser: tr(ja: "ひっかけ", zh: "急转弯", en: "Teaser", my: "ပဟေဠိ")
        case .hardChoice: tr(ja: "難問2択", zh: "难问二选一", en: "Hard quiz", my: "ခက်သောမေး")
        case .funChoice: tr(ja: "おもしろ2択", zh: "有趣二选一", en: "Fun quiz", my: "ပျော်စရာမေး")
        case .foodChoice: tr(ja: "食べ物2択", zh: "食物二选一", en: "Food quiz", my: "အစားအစာမေး")
        case .kidChoice: tr(ja: "幼児2択", zh: "幼儿二选一", en: "Kids quiz", my: "ကလေးမေး")
        case .studentFlag: tr(ja: "留学生の旗", zh: "留学生旗帜", en: "Student flags", my: "ကျောင်းသားအလံ")
        case .gdpFlag: tr(ja: "GDPの旗", zh: "GDP旗帜", en: "GDP flags", my: "GDP အလံ")
        }
    }
}

enum StroopColor: String, CaseIterable {
    case red, yellow, green, blue

    var name: String {
        switch self {
        case .red: tr(ja: "赤", zh: "红", en: "Red", my: "အနီ")
        case .yellow: tr(ja: "黄", zh: "黄", en: "Yellow", my: "အဝါ")
        case .green: tr(ja: "緑", zh: "绿", en: "Green", my: "အစိမ်း")
        case .blue: tr(ja: "青", zh: "蓝", en: "Blue", my: "အပြာ")
        }
    }

    var color: Color {
        switch self {
        case .red: Color(red: 0.95, green: 0.28, blue: 0.32)
        case .yellow: Color(red: 0.98, green: 0.82, blue: 0.28)
        case .green: Color(red: 0.30, green: 0.82, blue: 0.48)
        case .blue: Color(red: 0.32, green: 0.56, blue: 0.98)
        }
    }
}

enum ChoiceStyle: Equatable {
    case neutral
    case ink(StroopColor)
}

struct AnswerChoice: Equatable, Identifiable {
    let id: String
    let title: String
    let symbol: String?
    let style: ChoiceStyle
    var badge: String? = nil
}

enum Stimulus: Equatable {
    case word(StroopColor, ink: StroopColor)
    case emblem(id: String)
    case flag(id: String, emoji: String)
}

struct StroopRound: Equatable {
    var task: InterferenceTask
    var rule: String
    var answerID: String
    var choices: [AnswerChoice]
    var stimulus: Stimulus

    static func make(
        _ task: InterferenceTask,
        excludingTeaserIDs: Set<String> = []
    ) -> StroopRound {
        switch task {
        case .colorWord: ColorWordBank.pick()
        case .brainTeaser: BrainTeaserBank.pick(excluding: excludingTeaserIDs)
        case .hardChoice: HardChoiceBank.pick(excluding: excludingTeaserIDs)
        case .funChoice: FunChoiceBank.pick(excluding: excludingTeaserIDs)
        case .foodChoice: FoodChoiceBank.pick(excluding: excludingTeaserIDs)
        case .kidChoice: KidChoiceBank.pick(excluding: excludingTeaserIDs)
        case .studentFlag: StudentFlagBank.pick(excluding: excludingTeaserIDs)
        case .gdpFlag: GdpFlagBank.pick(excluding: excludingTeaserIDs)
        }
    }

    static func teaserID(from stimulus: Stimulus) -> String? {
        switch stimulus {
        case .emblem(let id), .flag(let id, _): return id
        case .word: return nil
        }
    }

    /// Rebuild translated text from the same cues and keep option IDs and order intact.
    func localized() -> StroopRound {
        switch stimulus {
        case .word:
            return ColorWordBank.localized(self)
        case .emblem(let id):
            if let matching = BrainTeaserBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            if let matching = HardChoiceBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            if let matching = FunChoiceBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            if let matching = FoodChoiceBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            if let matching = KidChoiceBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            return self
        case .flag(let id, _):
            if let matching = StudentFlagBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            if let matching = GdpFlagBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            return self
        }
    }

    private func localizedEmblem(from titles: StroopRound, rule: String) -> StroopRound {
        var translated = self
        translated.rule = rule
        translated.choices = choices.map { choice in
            let title = titles.choices.first(where: { $0.id == choice.id })?.title ?? choice.title
            return AnswerChoice(id: choice.id, title: title, symbol: choice.symbol, style: choice.style, badge: choice.badge)
        }
        return translated
    }

    static let quizLength = 20
    static let quizGame = "quiz"

    static func randomQuiz(count: Int = quizLength) -> [StroopRound] {
        var others = BrainTeaserBank.allRounds() + HardChoiceBank.allRounds() + FunChoiceBank.allRounds() + FoodChoiceBank.allRounds() + KidChoiceBank.allRounds() + StudentFlagBank.allRounds() + GdpFlagBank.allRounds()
        others.shuffle()
        var quiz = Array(others.prefix(max(0, count - 1)))
        quiz.append(ColorWordBank.pick())
        quiz.shuffle()
        return quiz
    }

}

private enum StroopCue {
    case correct
    case wrong
    case timeout
}

private final class StroopAudio {
    private let engine = AVAudioEngine()
    private let players = (0..<2).map { _ in AVAudioPlayerNode() }
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
    private var clips: [StroopCue: AVAudioPCMBuffer] = [:]
    private var nextPlayer = 0
    private let audioQueue = DispatchQueue(label: "stroop.audio", qos: .userInitiated)
    private var wired = false

    init() {
        let format = self.format
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let built: [StroopCue: AVAudioPCMBuffer] = [
                .correct: Self.notes([(784, 0, 0.42), (1046, 0.07, 0.36)], seconds: 0.2, noise: 0, format: format),
                .wrong: Self.notes([(196, 0, 0.48), (140, 0.04, 0.32)], seconds: 0.16, noise: 0.18, format: format),
                .timeout: Self.notes([(494, 0, 0.36), (330, 0.08, 0.32), (220, 0.16, 0.26)], seconds: 0.32, noise: 0.08, format: format),
            ].compactMapValues { $0 }
            DispatchQueue.main.async {
                self?.clips = built
            }
        }
    }

    func prepare() {
        audioQueue.async { [weak self] in
            self?.activate()
        }
    }

    func stop() {
        audioQueue.async { [weak self] in
            guard let self else { return }
            for player in self.players {
                player.stop()
            }
            self.engine.stop()
        }
    }

    func play(_ cue: StroopCue) {
        guard let buffer = clips[cue] else { return }
        let player = players[nextPlayer % players.count]
        nextPlayer += 1
        let volume: Float = cue == .wrong || cue == .timeout ? 0.55 : 0.75
        audioQueue.async { [weak self] in
            guard let self else { return }
            self.activate()
            player.volume = volume
            player.scheduleBuffer(buffer, completionHandler: nil)
        }
    }

    private func activate() {
        if !wired {
            wired = true
            for node in players {
                engine.attach(node)
                engine.connect(node, to: engine.mainMixerNode, format: format)
            }
            engine.mainMixerNode.outputVolume = 0.9
            #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try? session.setActive(true)
            #endif
        }
        if !engine.isRunning {
            try? engine.start()
        }
        for player in players where !player.isPlaying {
            player.play()
        }
    }

    private static func notes(
        _ notes: [(hz: Double, at: Double, amp: Double)],
        seconds: Double,
        noise: Double,
        format: AVAudioFormat
    ) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(seconds * format.sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
              let samples = buffer.floatChannelData?[0] else { return nil }
        buffer.frameLength = frameCount
        var seed: UInt64 = 29
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / format.sampleRate
            var sample = 0.0
            for note in notes {
                let age = time - note.at
                if age >= 0 {
                    let envelope = exp(-age * 8)
                    sample += sin(2 * .pi * note.hz * age) * note.amp * envelope
                }
            }
            if noise > 0 {
                seed = seed &* 6364136223846793005 &+ 1
                let hiss = Double(seed >> 40) / Double(1 << 24) * 2 - 1
                sample += hiss * noise * exp(-time * 18)
            }
            samples[frame] = Float(max(-1, min(1, sample)))
        }
        return buffer
    }
}

@Observable
final class StroopSession {
    enum Phase {
        case ready
        case naming
        case playing
        case renaming
        case finished
    }

    private let audio = StroopAudio()

    private(set) var phase: Phase = .ready
    private(set) var round = StroopRound.make(.colorWord)
    private(set) var score = 0
    private(set) var streak = 0
    private(set) var correctCount = 0
    private(set) var answerCount = 0
    private(set) var questionRemaining: TimeInterval = 30
    private(set) var questionLimit: TimeInterval = 30
    private(set) var lastAnswerWasCorrect: Bool?
    private(set) var lastMissWasTimeout = false
    private(set) var isResolving = false
    private(set) var selectedChoiceID: String?
    private(set) var roundID = UUID()
    private(set) var testing = false
    private(set) var showsPracticeTools = false
    private(set) var testUsesTimer = false
    private(set) var testFamily: QuestionFamily = .stroop
    private var questionEndsAt: Date?
    private var questionStartedAt: Date?
    private var usedTeaserIDs = Set<String>()
    private var seenQuestionKeys = Set<String>()
    private var quiz: [StroopRound] = []
    private var quizIndex = 0
    private(set) var answeringElapsed: TimeInterval = 0
    private(set) var lastPlacement: Int?
    private(set) var playerName = ""
    private(set) var playerNameID: String?
    private(set) var playerAvatar = PlayerNames.fallbackAvatar

    private struct ScriptedTrial {
        var task: InterferenceTask
        var family: QuestionFamily { task.family }
    }

    var showsTimer: Bool {
        !testing || testUsesTimer
    }

    var isReviewing: Bool {
        isResolving
    }

    var isReviewingMistake: Bool {
        isResolving && lastAnswerWasCorrect == false
    }

    var isQuizComplete: Bool {
        !testing && answerCount >= StroopRound.quizLength
    }

    var answeringTimeText: String {
        ScoreBoard.durationLabel(milliseconds: Int((answeringElapsed * 1000).rounded()))
    }

    var resultCatSpeech: String {
        let who = playerName.isEmpty ? tr(ja: "きみ", zh: "你", en: "You", my: "သင်") : playerName
        if let place = lastPlacement {
            if place == 1 {
                return tr(
                    ja: "\(who)、やったー！\(score)点でランキング1位！時間は\(answeringTimeText)だよ！",
                    zh: "\(who)，太棒了！你得了 \(score) 分，排行榜第 1 名！总用时 \(answeringTimeText)！",
                    en: "\(who) — yes! \(score) points and 1st place! Your time was \(answeringTimeText)!",
                    my: "\(who)၊ ယေး! \(score) မှတ်၊ အဆင့် ၁။ အချိန်က \(answeringTimeText)!",
                    ko: "\(who), 대단해요! \(score)점으로 1등! 시간은 \(answeringTimeText)예요!",
                    fr: "\(who) — bravo ! \(score) points et la 1re place ! Temps : \(answeringTimeText) !",
                    zhHant: "\(who)，太棒了！你得了 \(score) 分，排行榜第 1 名！總用時 \(answeringTimeText)！"
                )
            }
            let rankEN = place == 2 ? "2nd" : place == 3 ? "3rd" : "\(place)th"
            return tr(
                ja: "\(who)、\(score)点だったよ。ランキングは\(place)位。かかった時間は\(answeringTimeText)。",
                zh: "\(who)，你得了 \(score) 分，排行榜第 \(place) 名。总用时 \(answeringTimeText)。",
                en: "\(who) scored \(score). That's \(rankEN) place. Total time \(answeringTimeText).",
                my: "\(who)၊ \(score) မှတ်ရသည်။ အဆင့် \(place)။ စုစုပေါင်း \(answeringTimeText)။",
                ko: "\(who), \(score)점이었어요. 순위는 \(place)위. 시간은 \(answeringTimeText).",
                fr: "\(who) a \(score) points. C’est la \(place)e place. Temps : \(answeringTimeText).",
                zhHant: "\(who)，你得了 \(score) 分，排行榜第 \(place) 名。總用時 \(answeringTimeText)。"
            )
        }
        return tr(
            ja: "\(who)、\(score)点だったよ。時間は\(answeringTimeText)。今回はランキング圏外だったけど、また挑戦してね！",
            zh: "\(who)，你得了 \(score) 分，总用时 \(answeringTimeText)。这次没进排行榜，再来一局吧！",
            en: "\(who) scored \(score) in \(answeringTimeText). Not on the board this time — try again!",
            my: "\(who)၊ \(score) မှတ်၊ \(answeringTimeText)။ ဒီတစ်ခါ အဆင့်စာရင်း မဝင်၊ ထပ်ကစားပါ။",
            ko: "\(who), \(score)점, 시간은 \(answeringTimeText). 이번엔 순위에 못 들었지만 다시 도전해요!",
            fr: "\(who) a \(score) points en \(answeringTimeText). Pas au classement cette fois — réessaie !",
            zhHant: "\(who)，你得了 \(score) 分，總用時 \(answeringTimeText)。這次沒進排行榜，再來一局吧！"
        )
    }

    var accuracyText: String {
        guard answerCount > 0 else { return tr(ja: "まだ回答がない", zh: "还没有作答", en: "No answers yet", my: "အဖြေမရှိသေးပါ") }
        let percent = Int((Double(correctCount) / Double(answerCount) * 100).rounded())
        return tr(
            ja: "正解 \(correctCount) / \(answerCount)、正解率 \(percent)%",
            zh: "答对 \(correctCount) / \(answerCount)，正确率 \(percent)%",
            en: "Correct \(correctCount) / \(answerCount), \(percent)%",
            my: "မှန် \(correctCount) / \(answerCount)၊ မှန်ကန်နှုန်း \(percent)%",
            ko: "정답 \(correctCount) / \(answerCount), 정답률 \(percent)%",
            fr: "Bonnes réponses \(correctCount) / \(answerCount), \(percent)%",
            zhHant: "答對 \(correctCount) / \(answerCount)，正確率 \(percent)%"
        )
    }

    func beginSetup(practice: Bool? = nil) {
        if practice == true {
            let item = PlayerNames.random()
            playerAvatar = item.emoji
            adopt(item)
            start(practice: true)
            return
        }
        phase = .naming
    }

    func confirmName(_ draft: String, cannedID: String?, avatar: String) {
        applyNameDraft(draft, cannedID: cannedID, avatar: avatar)
        start(practice: false)
    }

    func keepNameForBoard() {
        publishScore()
    }

    func confirmRename(_ draft: String, cannedID: String?, avatar: String) {
        applyNameDraft(draft, cannedID: cannedID, avatar: avatar)
        publishScore()
    }

    func cancelSetup() {
        phase = .ready
    }

    func start(practice: Bool? = nil) {
        if let practice {
            showsPracticeTools = practice
            testing = practice
        }
        usedTeaserIDs = []
        seenQuestionKeys = []
        quiz = testing ? [] : StroopRound.randomQuiz()
        quizIndex = 0
        answeringElapsed = 0
        lastPlacement = nil
        questionStartedAt = nil
        score = 0
        streak = 0
        correctCount = 0
        answerCount = 0
        questionLimit = 30
        questionRemaining = 30
        lastAnswerWasCorrect = nil
        lastMissWasTimeout = false
        audio.prepare()
        deal()
        phase = .playing
    }

    func tick(now: Date) {
        guard phase == .playing, let questionEndsAt else { return }
        let left = questionEndsAt.timeIntervalSince(now)
        if left <= 0 {
            self.questionEndsAt = nil
            questionRemaining = 0
            choose("", timeout: true)
            return
        }
        questionRemaining = left
    }

    func choose(_ id: String) {
        choose(id, timeout: false)
    }

    private func choose(_ id: String, timeout: Bool) {
        guard phase == .playing, !isResolving else { return }
        guard timeout || round.choices.contains(where: { $0.id == id }) else { return }
        isResolving = true
        selectedChoiceID = timeout ? nil : id
        questionEndsAt = nil
        if let started = questionStartedAt {
            answeringElapsed += Date().timeIntervalSince(started)
            questionStartedAt = nil
        }
        answerCount += 1
        if !timeout && id == round.answerID {
            streak += 1
            correctCount += 1
            score += 5
            audio.play(.correct)
            lastAnswerWasCorrect = true
            lastMissWasTimeout = false
        } else {
            streak = 0
            lastAnswerWasCorrect = false
            lastMissWasTimeout = timeout
            audio.play(timeout ? .timeout : .wrong)
        }
    }

    func continueAfterReview() {
        guard phase == .playing, isReviewing else { return }
        if isQuizComplete {
            finishQuiz()
        } else {
            deal()
        }
    }

    private func finishQuiz() {
        lastPlacement = nil
        isResolving = false
        if testing {
            publishScore()
            return
        }
        phase = .renaming
    }

    func quitToBoard() {
        audio.stop()
        if testing {
            returnToMenu()
            return
        }
        pauseClock()
        finishQuiz()
    }

    private func publishScore() {
        lastPlacement = nil
        if let id = ScoreBoard.submit(
            game: StroopRound.quizGame,
            score: score,
            detail: Int((answeringElapsed * 1000).rounded()),
            name: playerName,
            avatar: playerAvatar,
            rank: .timed
        ) {
            if let index = ScoreBoard.records(for: StroopRound.quizGame).firstIndex(where: { $0.id == id }) {
                lastPlacement = index + 1
            }
        }
        phase = .finished
        isResolving = false
    }

    func updateProfile(_ draft: String, cannedID: String?, avatar: String) {
        applyNameDraft(draft, cannedID: cannedID, avatar: avatar)
    }

    func pauseClock() {
        guard phase == .playing else { return }
        if let ends = questionEndsAt {
            questionRemaining = max(0, ends.timeIntervalSinceNow)
            questionEndsAt = nil
        }
        if let started = questionStartedAt {
            answeringElapsed += Date().timeIntervalSince(started)
            questionStartedAt = nil
        }
    }

    func resumeClock() {
        guard phase == .playing, !isResolving else { return }
        questionStartedAt = Date()
        if showsTimer, questionRemaining > 0 {
            questionEndsAt = Date().addingTimeInterval(questionRemaining)
        }
    }

    private func applyNameDraft(_ draft: String, cannedID: String?, avatar: String) {
        playerAvatar = avatar.isEmpty ? PlayerNames.emoji(id: cannedID) : avatar
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        if let cannedID, PlayerNames.isKnown(cannedID) {
            adopt(id: cannedID)
        } else if trimmed.isEmpty {
            let item = PlayerNames.random()
            if avatar.isEmpty { playerAvatar = item.emoji }
            adopt(item)
        } else {
            adopt(custom: String(trimmed.prefix(40)))
        }
        PlayerNames.recordAvatarUse(playerAvatar)
    }

    func returnToMenu() {
        audio.stop()
        questionEndsAt = nil
        roundID = UUID()
        isResolving = false
        selectedChoiceID = nil
        lastAnswerWasCorrect = nil
        lastMissWasTimeout = false
        phase = .ready
    }

    func setTesting(_ on: Bool) {
        testing = on
        if on {
            showsPracticeTools = true
            testUsesTimer = false
            questionLimit = 30
        }
        guard phase == .playing else { return }
        deal()
    }

    func setTestTimer(_ on: Bool) {
        testUsesTimer = on
        guard phase == .playing, testing else { return }
        guard !isResolving else { return }
        if on {
            questionLimit = 30
            questionEndsAt = Date().addingTimeInterval(questionLimit)
            questionRemaining = questionLimit
        } else {
            questionEndsAt = nil
            questionRemaining = questionLimit
        }
    }

    func selectTestFamily(_ family: QuestionFamily) {
        testFamily = family
        guard phase == .playing, testing else { return }
        deal()
    }

    func applyLanguage() {
        if let playerNameID {
            playerName = PlayerNames.display(id: playerNameID)
        }
        guard phase == .playing else { return }
        round = round.localized()
    }

    private func deal() {
        roundID = UUID()
        isResolving = false
        selectedChoiceID = nil
        lastAnswerWasCorrect = nil
        lastMissWasTimeout = false
        if testing {
            dealPracticeRound()
        } else if quizIndex < quiz.count {
            round = quiz[quizIndex].localized()
            quizIndex += 1
        } else {
            finishQuiz()
            return
        }
        questionRemaining = questionLimit
        questionStartedAt = Date()
        if showsTimer {
            questionEndsAt = Date().addingTimeInterval(questionLimit)
        } else {
            questionEndsAt = nil
        }
    }

    private func dealPracticeRound() {
        let trial = nextTrial()
        if trial.task == .brainTeaser {
            let used = usedTeaserIDs.filter { BrainTeaserBank.template(id: $0) != nil }
            if used.count >= BrainTeaserBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        } else if trial.task == .hardChoice {
            let used = usedTeaserIDs.filter { HardChoiceBank.template(id: $0) != nil }
            if used.count >= HardChoiceBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        } else if trial.task == .funChoice {
            let used = usedTeaserIDs.filter { FunChoiceBank.template(id: $0) != nil }
            if used.count >= FunChoiceBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        } else if trial.task == .foodChoice {
            let used = usedTeaserIDs.filter { FoodChoiceBank.template(id: $0) != nil }
            if used.count >= FoodChoiceBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        } else if trial.task == .kidChoice {
            let used = usedTeaserIDs.filter { KidChoiceBank.template(id: $0) != nil }
            if used.count >= KidChoiceBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        } else if trial.task == .studentFlag {
            let used = usedTeaserIDs.filter { StudentFlagBank.template(id: $0) != nil }
            if used.count >= StudentFlagBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        } else if trial.task == .gdpFlag {
            let used = usedTeaserIDs.filter { GdpFlagBank.template(id: $0) != nil }
            if used.count >= GdpFlagBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        }
        var next = makeRound(for: trial)
        var tries = 0
        while seenQuestionKeys.contains(questionKey(next)) && tries < 24 {
            next = makeRound(for: trial)
            tries += 1
        }
        if let teaserID = StroopRound.teaserID(from: next.stimulus) {
            usedTeaserIDs.insert(teaserID)
        }
        seenQuestionKeys.insert(questionKey(next))
        round = next
    }

    private func makeRound(for trial: ScriptedTrial) -> StroopRound {
        StroopRound.make(trial.task, excludingTeaserIDs: usedTeaserIDs)
    }

    private func questionKey(_ round: StroopRound) -> String {
        if let teaserID = StroopRound.teaserID(from: round.stimulus) {
            return "teaser:\(teaserID)"
        }
        return "\(round.task.rawValue)|\(round.rule)|\(round.answerID)|\(String(describing: round.stimulus))"
    }

    private func nextTrial() -> ScriptedTrial {
        let family = testing ? testFamily : (QuestionFamily.allCases.randomElement() ?? .stroop)
        return ScriptedTrial(task: task(for: family))
    }

    private func task(for family: QuestionFamily) -> InterferenceTask {
        switch family {
        case .stroop: .colorWord
        case .brainTeaser: .brainTeaser
        case .hardChoice: .hardChoice
        case .funChoice: .funChoice
        case .foodChoice: .foodChoice
        case .kidChoice: .kidChoice
        case .studentFlag: .studentFlag
        case .gdpFlag: .gdpFlag
        }
    }

    private func adopt(_ item: PlayerNames.Item) {
        adopt(id: item.id)
    }

    private func adopt(id: String) {
        playerNameID = id
        playerName = PlayerNames.display(id: id)
        PlayerNames.saveLast(id: id, name: playerName, avatar: playerAvatar)
    }

    private func adopt(custom name: String) {
        playerNameID = nil
        playerName = name
        PlayerNames.saveLast(id: nil, name: name, avatar: playerAvatar)
    }
}

struct StroopGameView: View {
    @State private var session = StroopSession()
    @State private var showsGuide = false
    @State private var showsPractice = false
    @State private var showsRanking = false
    @State private var nameDraft = ""
    @State private var cannedNameID: String?
    @State private var chosenAvatar = PlayerNames.fallbackAvatar
    @State private var showsAvatarPicker = false
    @State private var avatarGroup = PlayerNames.AvatarGroup.smileys
    @State private var isEditingRename = false
    @State private var showsProfileEditor = false
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        Group {
            switch session.phase {
            case .ready:
                menu
            case .naming:
                naming
            case .playing:
                playfield
            case .renaming:
                renaming
            case .finished:
                result
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StroopBackdrop(light: session.phase == .playing || session.phase == .finished))
        .navigationTitle(tr(ja: "ブレインラッシュ", zh: "脑乱挑战", en: "Brain Rush", my: "အနှောင့်အယှက်စိန်ခေါ်ပွဲ"))
        .modifier(StroopNavigationChrome(isPlaying: session.phase == .playing))
        .background {
            TimelineView(.periodic(from: .now, by: 0.05)) { context in
                Color.clear
                    .onChange(of: context.date) { _, date in
                        session.tick(now: date)
                    }
            }
        }
        .onChange(of: LanguageStore.shared.language) { _, _ in
            session.applyLanguage()
            if (session.phase == .naming || showsProfileEditor || (session.phase == .renaming && isEditingRename)), let cannedNameID {
                nameDraft = PlayerNames.display(id: cannedNameID)
            }
        }
        .sensoryFeedback(.success, trigger: session.correctCount)
        .sensoryFeedback(.error, trigger: session.answerCount - session.correctCount)
    }

    private var menu: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 10) {
                    Spacer(minLength: 0)
                    languageBar
                    WoodlandTitle(height: min(370, max(250, geometry.size.height * 0.49)))
                    HStack(spacing: 0) {
                        menuMetric("trophy.fill", tr(ja: "ベストタイム", zh: "最快用时", en: "Best time", my: "အမြန်ဆုံး"), bestQuizTimeText, CatQuizPalette.wood)
                        Divider().frame(height: 42).overlay(CatQuizPalette.wood.opacity(0.2))
                        menuMetric("square.stack.3d.up.fill", tr(ja: "問題数", zh: "题数", en: "Questions", my: "မေးခွန်း"), "\(StroopRound.quizLength)", CatQuizPalette.wood)
                        Divider().frame(height: 42).overlay(CatQuizPalette.wood.opacity(0.2))
                        menuMetric("square.grid.2x2.fill", tr(ja: "2択クイズ", zh: "二选一", en: "Two choices", my: "ရွေးစရာ ၂ ခု"), "A / B", CatQuizPalette.wood)
                    }
                    .padding(.vertical, 10)
                    .modifier(WoodlandPanel(cornerRadius: 18))

                    Button { session.beginSetup(practice: false) } label: {
                        WoodlandAction(title: tr(ja: "ゲームを始める", zh: "开始游戏", en: "Let’s play", my: "ကစားမည်"), symbol: "play.fill")
                    }
                    .buttonStyle(ArcadePressStyle())
                    .accessibilityIdentifier("stroop-start")
                    .accessibilityLabel(tr(ja: "開始", zh: "开始", en: "Start", my: "စတင်မည်"))

                    HStack(spacing: 9) {
                        arcadeShortcut("crown.fill", tr(ja: "ランキング", zh: "排行榜", en: "Ranking", my: "အဆင့်"), .orange) { showsRanking = true }
                        arcadeShortcut("book.fill", tr(ja: "遊び方", zh: "怎么玩", en: "How to play", my: "ကစားနည်း"), .blue) { showsGuide = true }
                        arcadeShortcut("pencil.and.outline", tr(ja: "練習", zh: "练习", en: "Practice", my: "လေ့ကျင့်"), Color(red: 0.18, green: 0.62, blue: 0.42)) { showsPractice = true }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, max(22, geometry.size.width * 0.065))
                .padding(.vertical, 16)
                .frame(maxWidth: 450)
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .background(StroopBackdrop(light: true))
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showsGuide) {
            menuSheet(tr(ja: "遊び方", zh: "怎么玩", en: "How to play", my: "ကစားနည်း")) {
                VStack(alignment: .leading, spacing: 24) {
                    guide(
                        tr(ja: "遊び方", zh: "怎么玩", en: "How to play", my: "ကစားနည်း"),
                        tr(
                            ja: "始める前に名前をつけてね。自分で書くか、ランダムでもいい。毎回2択。問題を読んでから選んで。見た瞬間で押すと間違えやすいよ。",
                            zh: "开始前先起名字，可以自己填，也可以随机生成。每次两个选项。先读题目再选，别凭第一眼。",
                            en: "Pick a name first — type one or tap random. Two choices each time. Read the question, then pick. Don't go with your first glance.",
                            my: "မစခင် နာမည်ပေးပါ။ ကိုယ်တိုင်ရေး သို့မဟုတ် ကျပန်း။ တစ်ခါလျှင် ရွေးစရာ ၂ ခု။ မေးခွန်းဖတ်ပြီးမှ ရွေးပါ။"
                        )
                    )
                    guide(
                        tr(ja: "8種類の問題", zh: "八种题目", en: "Eight kinds", my: "မေးခွန်း ၈ မျိုး"),
                        tr(
                            ja: "ストループ効果：字の色と書かれた文字が食い違う。いつも字の色を選ぶ。書いてある文字は無視する。\nひっかけ：正解と、いちばん間違えやすい答えの二択。日本語のひっかけでは、ネコがヒントをくれる。\n難問2択：雑学の二択。\nおもしろ2択：小学生向けの雑学二択。\n食べ物2択：食べ物の雑学二択。\n幼児2択：保育園・幼稚園向けの簡単二択。ほかの2択とは別の種類。\n留学生の旗：日本の留学生が多い国・地域の旗。\nGDPの旗：世界のGDPが大きい国の旗。",
                            zh: "斯特鲁普效应：字的颜色和写出的字不一致。每次都选颜色，不要选写出的字。\n脑筋急转弯：两个选项里，一个是正确答案，另一个最容易想错。跟日语有关的题，猫咪会给提示。\n难问二选一：杂学二选一。\n有趣二选一：面向小学生的杂学二选一。\n食物二选一：食物杂学。\n幼儿二选一：幼儿园简单二选一，和其他二选一分开。\n留学生旗帜：看旗选日本留学生人数靠前的国家或地区。\nGDP旗帜：看旗选世界 GDP 靠前的国家。",
                            en: "Stroop Effect: always pick the ink color, not the word.\nBrain teasers: Japanese wordplay; the cat may hint.\nHard, fun, food, and kids two-choice: each trivia set lives in its own file.\nStudent flags: countries and regions that send many students to Japan.\nGDP flags: the world's largest economies.",
                            my: "Stroop Effect။ မင်အရောင်ကို ရွေးပါ။\nပဟေဠိ။ ဂျပန်စာတွင် ကြောင်က အရိပ်အမြွက် ပေးသည်။\nခက်သော / ပျော်စရာ / အစားအစာ / ကလေး ၂ ခုရွေး။ ဖိုင်ခွဲထားသည်။\nကျောင်းသားအလံ။ GDP အလံ။"
                        )
                    )
                    guide(
                        tr(ja: "20問と時間", zh: "20 题和时间", en: "20 questions and time", my: "မေးခွန်း ၂၀ နှင့် အချိန်"),
                        tr(
                            ja: "毎回20問。そのうち色と字は1問だけ、残りの19問はひっかけ、各種2択、旗の問題から。制限時間は1問30秒。時間切れは不正解。",
                            zh: "每次 20 题。其中颜色题只随机出 1 道，其余 19 道来自脑筋急转弯、各类二选一和旗帜题。每题 30 秒，超时算错。",
                            en: "Each game has 20 questions. Exactly one is a color-and-word item; the other 19 come from teasers, trivia, and flag quizzes. 30 seconds each; a timeout is a miss.",
                            my: "တစ်ပွဲ ၂၀ ခု။ အရောင်မေးခွန်း ၁ ခုသာ၊ ကျန် ၁၉ ခုမှာ ပဟေဠိ၊ ဗဟုသုတ ၂ ခုရွေးနှင့် အလံမေးများ။ တစ်ခု ၃၀ စက္ကန့်။"
                        )
                    )
                    guide(
                        tr(ja: "得点とランキング", zh: "得分和排行榜", en: "Score and ranking", my: "ရမှတ်နှင့် အဆင့်"),
                        tr(
                            ja: "正解は1問5点、満点は100点。ランキングは回答にかかった合計時間を表示する。同じ点数なら速い方が上。",
                            zh: "答对一题 5 分，满分 100 分。排行榜显示答题总时间。分数相同则更快的排前面。",
                            en: "Each correct answer is 5 points, 100 in total. The leaderboard shows your answering time. Tied scores rank the faster run first.",
                            my: "မှန်လျှင် တစ်မေးခွန်း ၅ မှတ်၊ အပြည့် ၁၀၀။ အဆင့်စာရင်းတွင် ဖြေချိန် စုစုပေါင်းကို ပြသည်။ မှတ်တူရင် ပိုမြန်သူ အပေါ်။"
                        )
                    )
                }
            }
        }
        .sheet(isPresented: $showsRanking) {
            rankingSheet
        }
        .sheet(isPresented: $showsPractice) {
            menuSheet(tr(ja: "練習", zh: "练习", en: "Practice", my: "လေ့ကျင့်")) {
                VStack(alignment: .leading, spacing: 24) {
                    testControls(showNote: true)
                }
            }
        }
    }

    private func menuMetric(_ symbol: String, _ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 5) {
            Label(title, systemImage: symbol).font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(CatQuizPalette.wood)
            Text(value).font(.system(size: 21, weight: .heavy, design: .rounded))
                .foregroundStyle(color).minimumScaleFactor(0.5).lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func arcadeShortcut(_ symbol: String, _ title: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: symbol).symbolRenderingMode(.palette).font(.system(size: 31, weight: .bold)).foregroundStyle(color)
                    .shadow(color: CatQuizPalette.wood.opacity(0.4), radius: 0, y: 1)
                    .shadow(color: Color(red: 1, green: 0.92, blue: 0.65), radius: 1)
                Text(title).font(.system(.caption, design: .rounded, weight: .heavy))
                    .foregroundStyle(CatQuizPalette.ink)
                    .lineLimit(1).minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 80)
            .modifier(WoodlandPanel(cornerRadius: 20))
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(CatQuizPalette.wood.opacity(0.14))
                    .padding(9)
                    .accessibilityHidden(true)
            }
        }
        .buttonStyle(ArcadePressStyle())
    }

    private var rankingSheet: some View {
        let _ = LanguageStore.shared.language
        return menuSheet(tr(ja: "ランキング", zh: "排行榜", en: "Leaderboard", my: "အဆင့်စာရင်း")) {
            VStack(alignment: .leading, spacing: 16) {
                languageBar
                ScoreBoardList(game: StroopRound.quizGame, rank: .timed, textColor: CatQuizPalette.wood)
            }
        }
    }

    private func menuSheet<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        let sheetContent = content()
        return NavigationStack {
            ScrollView {
                sheetContent
                    .foregroundStyle(CatQuizPalette.wood)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .modifier(WoodlandPanel())
                    .padding(20)
                    .frame(maxWidth: 560).frame(maxWidth: .infinity)
            }
            .background(StroopBackdrop(light: true))
            .tint(CatQuizPalette.wood)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(tr(ja: "閉じる", zh: "关闭", en: "Done", my: "ပိတ်ရန်")) {
                        showsGuide = false
                        showsRanking = false
                        showsPractice = false
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private func testControls(showNote: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if showNote {
                Text(tr(
                    ja: "好きな種類だけ練習できるよ。制限時間は最初オフです。",
                    zh: "可以只练自己想练的题型。倒计时默认关闭。",
                    en: "Practice just the kinds you want. The countdown starts off.",
                    my: "ကြိုက်သော အမျိုးအစားကိုပဲ လေ့ကျင့်နိုင်သည်။ အချိန်ရေတွက်မှု ပိတ်ထားသည်။"
                ))
                .font(.caption)
                .foregroundStyle(CatQuizPalette.wood.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
                Text(tr(ja: "すべての問題", zh: "全部题型", en: "All question types", my: "မေးခွန်းအမျိုးအစားအားလုံး"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CatQuizPalette.wood.opacity(0.72))
            }
            LanguageWrap(spacing: showNote ? 8 : 6) {
                ForEach(QuestionFamily.allCases) { family in
                    let selected = family == session.testFamily
                    Button {
                        session.selectTestFamily(family)
                    } label: {
                        Text(family.chipTitle)
                            .font(showNote ? .caption.weight(.semibold) : .caption2.weight(.semibold))
                            .lineLimit(1)
                            .foregroundStyle(selected ? .black : CatQuizPalette.wood)
                            .padding(.horizontal, showNote ? 10 : 8)
                            .padding(.vertical, showNote ? 6 : 4)
                            .background {
                                Capsule().fill(
                                    selected
                                        ? Color(red: 0.98, green: 0.74, blue: 0.32)
                                        : Color.white.opacity(0.1)
                                )
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("stroop-test-task-\(family.rawValue)")
                }
            }
            Button {
                session.setTestTimer(!session.testUsesTimer)
            } label: {
                Text(session.testUsesTimer
                    ? tr(ja: "制限時間：オン", zh: "倒计时：开", en: "Countdown: on", my: "အချိန်ရေတွက်၊ ဖွင့်")
                    : tr(ja: "制限時間：オフ", zh: "倒计时：关", en: "Countdown: off", my: "အချိန်ရေတွက်၊ ပိတ်"))
            }
            .font(.caption.weight(.semibold))
            .buttonStyle(.bordered)
            .tint(session.testUsesTimer ? Color(red: 0.98, green: 0.74, blue: 0.32) : CatQuizPalette.wood)
            .accessibilityIdentifier("stroop-test-timer")
            if showNote {
                Button {
                    showsPractice = false
                    session.beginSetup(practice: true)
                } label: {
                    WoodlandAction(
                        title: tr(ja: "練習を始める", zh: "开始练习", en: "Start practice", my: "လေ့ကျင့်မည်"),
                        symbol: "play.fill"
                    )
                }
                .buttonStyle(ArcadePressStyle())
                .padding(.top, 8)
                .accessibilityIdentifier("stroop-practice-start")
                .accessibilityLabel(tr(ja: "開始", zh: "开始", en: "Start", my: "စတင်မည်"))
            }
        }
    }

    private func guide(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(CatQuizPalette.wood)
            Text(body)
                .font(.body)
                .foregroundStyle(CatQuizPalette.wood.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var naming: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    languageBar
                    CatQuizHost(
                        hint: tr(
                            ja: "名前をつけてね。自分で書くか、ランダムでもいいよ！",
                            zh: "起个名字吧。可以自己填，也可以随机生成！",
                            en: "Give yourself a name. Type one, or tap random!",
                            my: "နာမည်ပေးပါ။ ကိုယ်တိုင်ရေး သို့မဟုတ် ကျပန်းနှိပ်ပါ။"
                        )
                    )
                    .padding(.bottom, -8)

                    nameFields

                    Button {
                        session.confirmName(nameDraft, cannedID: cannedNameID, avatar: chosenAvatar)
                    } label: {
                        WoodlandAction(
                            title: tr(ja: "この名前で始める", zh: "用这个名字开始", en: "Start with this name", my: "ဒီနာမည်နှင့် စတင်မည်"),
                            symbol: "play.fill"
                        )
                    }
                    .buttonStyle(ArcadePressStyle())
                    .accessibilityIdentifier("stroop-name-go")
                    .accessibilityLabel(tr(ja: "開始", zh: "开始", en: "Start", my: "စတင်မည်"))

                    Button(tr(ja: "スタート画面へ", zh: "返回首页", en: "Back to start", my: "အစသို့ ပြန်ရန်")) {
                        session.cancelSetup()
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(CatQuizPalette.wood)
                    .accessibilityIdentifier("stroop-name-back")

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, max(22, geometry.size.width * 0.065))
                .padding(.vertical, 16)
                .frame(maxWidth: 450)
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(.keyboard)
        }
        .background(StroopBackdrop(light: true))
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { loadNameDraft() }
    }

    private var renaming: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    languageBar
                    CatQuizHost(
                        hint: isEditingRename
                            ? tr(
                                ja: "好きな名前に変えてね。この名前がランキングに載るよ！",
                                zh: "改成你想用的名字。这个名字会写进排行榜！",
                                en: "Pick the name you want. It will go on the leaderboard!",
                                my: "လိုချင်သောနာမည်ပြောင်းပါ။ အဆင့်စာရင်းတွင် ပါမည်။"
                            )
                            : tr(
                                ja: "\(session.score)点だったよ。今の名前は「\(session.playerName)」。ランキングに載るよ。名前を変える？",
                                zh: "你得了 \(session.score) 分。现在的名字是「\(session.playerName)」。这个名字会进排行榜。要改名吗？",
                                en: "You scored \(session.score). Your name is “\(session.playerName)”. It will appear on the leaderboard. Want to change it?",
                                my: "\(session.score) မှတ်ရသည်။ နာမည်က “\(session.playerName)”။ အဆင့်စာရင်းတွင် ပါမည်။ ပြောင်းမလား။",
                                ko: "\(session.score)점이었어요. 지금 이름은 「\(session.playerName)」. 순위에 올라가요. 바꿀까요?",
                                fr: "Tu as \(session.score) points. Ton nom est « \(session.playerName) ». Il ira au classement. Tu changes ?",
                                zhHant: "你得了 \(session.score) 分。現在的名字是「\(session.playerName)」。這個名字會進排行榜。要改名嗎？"
                            ),
                        celebrating: true
                    )
                    .padding(.bottom, -8)
                    .accessibilityIdentifier("stroop-rename-cat")

                    if isEditingRename {
                        nameFields
                        Button {
                            session.confirmRename(nameDraft, cannedID: cannedNameID, avatar: chosenAvatar)
                        } label: {
                            WoodlandAction(
                                title: tr(ja: "この名前でランキングへ", zh: "用这个名字上榜", en: "Post this name", my: "ဒီနာမည်နှင့် စာရင်းသွင်းမည်"),
                                symbol: "crown.fill"
                            )
                        }
                        .buttonStyle(ArcadePressStyle())
                        .accessibilityIdentifier("stroop-rename-go")
                    } else {
                        VStack(spacing: 12) {
                            Text(session.playerAvatar)
                                .font(.system(size: 52))
                            Text(session.playerName)
                                .font(.title3.weight(.heavy))
                                .foregroundStyle(CatQuizPalette.ink)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            Text(tr(
                                ja: "この名前がランキングに載ります",
                                zh: "这个名字会加入排行榜",
                                en: "This name will be added to the leaderboard",
                                my: "ဒီနာမည် အဆင့်စာရင်းတွင် ပါမည်"
                            ))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CatQuizPalette.wood.opacity(0.78))
                            .multilineTextAlignment(.center)
                        }
                        .padding(16)
                        .modifier(WoodlandPanel())

                        Button {
                            session.keepNameForBoard()
                        } label: {
                            WoodlandAction(
                                title: tr(ja: "この名前でランキングへ", zh: "就用这个名字上榜", en: "Keep this name", my: "ဒီနာမည်အတိုင်း"),
                                symbol: "crown.fill"
                            )
                        }
                        .buttonStyle(ArcadePressStyle())
                        .accessibilityIdentifier("stroop-rename-keep")

                        Button {
                            cannedNameID = session.playerNameID
                            chosenAvatar = session.playerAvatar
                            nameDraft = session.playerName
                            isEditingRename = true
                        } label: {
                            Label(
                                tr(ja: "名前を変える", zh: "改名", en: "Change name", my: "နာမည်ပြောင်း"),
                                systemImage: "pencil"
                            )
                            .font(.headline)
                            .foregroundStyle(CatQuizPalette.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(CatQuizPalette.cream.opacity(0.9), in: RoundedRectangle(cornerRadius: 20))
                        }
                        .buttonStyle(ArcadePressStyle())
                        .accessibilityIdentifier("stroop-rename-edit")
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, max(22, geometry.size.width * 0.065))
                .padding(.vertical, 16)
                .frame(maxWidth: 450)
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(.keyboard)
        }
        .background(StroopBackdrop(light: true))
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            isEditingRename = false
            nameFieldFocused = false
            showsAvatarPicker = false
            cannedNameID = session.playerNameID
            chosenAvatar = session.playerAvatar
            nameDraft = session.playerName
        }
    }

    private var nameFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(tr(ja: "プレイヤー名", zh: "玩家名字", en: "Player name", my: "ကစားသမားနာမည်"))
                .font(.caption.weight(.bold))
                .foregroundStyle(CatQuizPalette.wood)
            HStack(spacing: 12) {
                Button {
                    nameFieldFocused = false
                    if showsAvatarPicker {
                        showsAvatarPicker = false
                    } else {
                        avatarGroup = PlayerNames.frequentAvatars.isEmpty ? .smileys : .frequent
                        showsAvatarPicker = true
                    }
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        Text(chosenAvatar)
                            .font(.system(size: 40))
                            .frame(width: 56, height: 56)
                            .background(CatQuizPalette.cream, in: Circle())
                            .overlay {
                                Circle()
                                    .strokeBorder(CatQuizPalette.wood.opacity(0.35), lineWidth: 1.5)
                                    .allowsHitTesting(false)
                            }
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(CatQuizPalette.wood)
                            .background(Circle().fill(CatQuizPalette.cream))
                            .offset(x: 2, y: 2)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tr(ja: "アイコンを選ぶ", zh: "选择头像", en: "Choose avatar", my: "ပုံရွေးပါ"))
                .accessibilityIdentifier("stroop-name-avatar")
                TextField(
                    tr(ja: "名前を入力", zh: "输入名字", en: "Type a name", my: "နာမည်ရိုက်ပါ"),
                    text: $nameDraft
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .focused($nameFieldFocused)
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                .background(CatQuizPalette.cream, in: RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(CatQuizPalette.wood.opacity(0.35), lineWidth: 1.5)
                        .allowsHitTesting(false)
                }
                .contentShape(RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(CatQuizPalette.ink)
                .accessibilityIdentifier("stroop-name-field")
                .onTapGesture { nameFieldFocused = true }
            }
            .onChange(of: nameDraft) { _, newValue in
                if let cannedNameID, newValue != PlayerNames.display(id: cannedNameID) {
                    self.cannedNameID = nil
                }
            }
            .onChange(of: nameFieldFocused) { _, focused in
                if focused { showsAvatarPicker = false }
            }
            Text(tr(ja: "下の種類から選んでね", zh: "按下面的分类选", en: "Pick a category below", my: "အောက်က အမျိုးအစားမှ ရွေးပါ"))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(CatQuizPalette.wood.opacity(0.72))
            if showsAvatarPicker {
                VStack(spacing: 8) {
                    Text(avatarGroup.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CatQuizPalette.wood)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView {
                        avatarGrid(PlayerNames.avatars(in: avatarGroup))
                            .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 200)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(PlayerNames.AvatarGroup.allCases) { group in
                                let enabled = group != .frequent || !PlayerNames.frequentAvatars.isEmpty
                                Button {
                                    avatarGroup = group
                                } label: {
                                    Text(group.icon)
                                        .font(.system(size: 20))
                                        .frame(width: 36, height: 36)
                                        .background(
                                            avatarGroup == group
                                                ? Color(red: 0.98, green: 0.74, blue: 0.32)
                                                : CatQuizPalette.cream,
                                            in: Capsule()
                                        )
                                        .opacity(enabled ? 1 : 0.35)
                                }
                                .buttonStyle(.plain)
                                .disabled(!enabled)
                                .accessibilityLabel(group.title)
                                .accessibilityAddTraits(avatarGroup == group ? .isSelected : [])
                            }
                        }
                    }
                }
                .accessibilityIdentifier("stroop-avatar-picker")
            }
            Button {
                applyRandomName(PlayerNames.random())
            } label: {
                Label(
                    tr(ja: "全部ランダム", zh: "全部随机", en: "Random both", my: "နှစ်ခုလုံး ကျပန်း"),
                    systemImage: "shuffle"
                )
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(CatQuizPalette.ink)
                .background(CatQuizPalette.cream.opacity(0.9), in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(ArcadePressStyle())
            .accessibilityIdentifier("stroop-name-random")
            HStack(spacing: 8) {
                Button {
                    applyRandomAdjective()
                } label: {
                    Text(tr(ja: "形容だけ", zh: "只随机形容词", en: "Adjective only", my: "နာမဝိသေသနသာ"))
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(CatQuizPalette.ink)
                        .background(CatQuizPalette.cream.opacity(0.9), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(ArcadePressStyle())
                .accessibilityIdentifier("stroop-name-random-adj")
                Button {
                    applyRandomName(PlayerNames.randomAnimal(keeping: cannedNameID))
                } label: {
                    Text(tr(ja: "動物だけ", zh: "只随机动物", en: "Animal only", my: "တိရစ္ဆာန်သာ"))
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(CatQuizPalette.ink)
                        .background(CatQuizPalette.cream.opacity(0.9), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(ArcadePressStyle())
                .accessibilityIdentifier("stroop-name-random-animal")
            }
        }
        .padding(16)
        .modifier(WoodlandPanel())
    }

    private func avatarGrid(_ items: [String]) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
            ForEach(items, id: \.self) { emoji in
                Button {
                    chosenAvatar = emoji
                    showsAvatarPicker = false
                } label: {
                    Text(emoji)
                        .font(.system(size: 28))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(
                            chosenAvatar == emoji
                                ? Color(red: 0.98, green: 0.74, blue: 0.32)
                                : CatQuizPalette.cream,
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(emoji)
            }
        }
    }

    private func applyRandomName(_ item: PlayerNames.Item) {
        cannedNameID = item.id
        nameDraft = item.display
        chosenAvatar = item.emoji
        showsAvatarPicker = false
    }

    private func applyRandomAdjective() {
        let item = PlayerNames.randomAdjective(keeping: cannedNameID)
        cannedNameID = item.id
        nameDraft = item.display
        showsAvatarPicker = false
    }

    private func openProfileEditor() {
        cannedNameID = session.playerNameID
        chosenAvatar = session.playerAvatar
        nameDraft = session.playerName
        showsAvatarPicker = false
        nameFieldFocused = false
        session.pauseClock()
        showsProfileEditor = true
    }

    private func loadNameDraft() {
        showsAvatarPicker = false
        let last = PlayerNames.loadLast()
        if let id = last.id, PlayerNames.isKnown(id) {
            cannedNameID = id
            nameDraft = PlayerNames.display(id: id)
            chosenAvatar = last.avatar
        } else if !last.name.isEmpty {
            cannedNameID = nil
            nameDraft = last.name
            chosenAvatar = last.avatar.isEmpty ? PlayerNames.fallbackAvatar : last.avatar
        } else {
            let item = PlayerNames.random()
            cannedNameID = item.id
            nameDraft = item.display
            chosenAvatar = item.emoji
        }
    }

    private var languageBar: some View {
        LanguagePicker(compact: true)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(CatQuizPalette.cream.opacity(0.95), in: Capsule())
    }

    private var playfield: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 12) {
                    quizHeader
                    languageBar
                    if session.showsPracticeTools {
                        VStack(alignment: .leading, spacing: 8) {
                            testControls(showNote: false)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .modifier(WoodlandPanel())
                    }
                    if session.isReviewing {
                        answerExplanation
                    } else {
                        CatQuizHost(hint: session.round.catHint)
                            .padding(.bottom, -18)
                            .zIndex(1)
                    }
                    VStack(spacing: 4) {
                        questionBanner
                        if session.round.task == .colorWord || session.round.task == .studentFlag || session.round.task == .gdpFlag {
                            stimulusPanel
                        }
                    }
                    .padding(12)
                    .modifier(WoodlandPanel())
                    answers
                        .frame(minHeight: session.isReviewing ? 150 : max(220, min(320, geometry.size.height * 0.32)))
                    if !session.isReviewing {
                        Spacer(minLength: 0)
                        quizFooter
                    }
                }
                .frame(maxWidth: 560)
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if session.isReviewing {
                Button { session.continueAfterReview() } label: {
                    Label(
                        session.isQuizComplete
                            ? tr(ja: "わかった・結果を見る", zh: "知道了，查看结果", en: "Got it — see results", my: "နားလည်ပြီ၊ ရလဒ်ကြည့်မည်")
                            : tr(ja: "わかった・次の問題へ", zh: "知道了，下一题", en: "Got it — next question", my: "နားလည်ပြီ၊ နောက်မေးခွန်း"),
                        systemImage: "arrow.right.circle.fill"
                    )
                    .font(.headline)
                    .foregroundStyle(CatQuizPalette.ink)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(red: 1, green: 0.85, blue: 0.35), in: RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(ArcadePressStyle())
                .accessibilityIdentifier("stroop-review-next")
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(CatQuizPalette.cream.opacity(0.98))
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(urgencyColor.opacity(!session.isResolving && session.questionRemaining <= urgentRemaining && session.showsTimer ? 0.9 : 0), lineWidth: 5)
                .padding(4)
                .allowsHitTesting(false)
        }
        .sheet(isPresented: $showsProfileEditor, onDismiss: {
            nameFieldFocused = false
            showsAvatarPicker = false
            session.resumeClock()
        }) {
            profileEditor
        }
    }

    private var profileEditor: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(tr(ja: "名前とアイコン", zh: "名字和头像", en: "Name and avatar", my: "နာမည်နှင့် ပုံ"))
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(CatQuizPalette.wood)
                nameFields
                Button {
                    session.updateProfile(nameDraft, cannedID: cannedNameID, avatar: chosenAvatar)
                    showsProfileEditor = false
                } label: {
                    WoodlandAction(
                        title: tr(ja: "これで続ける", zh: "就用这个继续", en: "Keep playing", my: "ဒီအတိုင်း ဆက်ကစားမည်"),
                        symbol: "checkmark.circle.fill"
                    )
                }
                .buttonStyle(ArcadePressStyle())
                .accessibilityIdentifier("stroop-profile-save")
                Button(tr(ja: "やめる", zh: "取消", en: "Cancel", my: "မလုပ်တော့")) {
                    showsProfileEditor = false
                }
                .font(.subheadline.bold())
                .foregroundStyle(CatQuizPalette.wood)
                .accessibilityIdentifier("stroop-profile-cancel")
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(.keyboard)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var quizHeader: some View {
        HStack(alignment: .center, spacing: 8) {
            Button(action: openProfileEditor) {
                HStack(spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        Text(session.playerAvatar)
                            .font(.system(size: 36))
                            .frame(width: 52, height: 52)
                            .background(CatQuizPalette.cream, in: Circle())
                            .overlay {
                                Circle()
                                    .strokeBorder(CatQuizPalette.wood.opacity(0.35), lineWidth: 1.5)
                                    .allowsHitTesting(false)
                            }
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(CatQuizPalette.wood)
                            .background(Circle().fill(CatQuizPalette.cream))
                            .offset(x: 2, y: 2)
                    }
                    Text(session.playerName)
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(CatQuizPalette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .frame(maxWidth: 120, alignment: .leading)
                        .accessibilityIdentifier("stroop-player-name")
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(tr(ja: "名前とアイコンを変える", zh: "改名字和头像", en: "Change name and avatar", my: "နာမည်နှင့် ပုံ ပြောင်းရန်"))
            .accessibilityIdentifier("stroop-player")
            Spacer(minLength: 4)
            Text(session.testing
                ? "Q\(session.answerCount + (session.isResolving ? 0 : 1))"
                : "Q\(session.answerCount + (session.isResolving ? 0 : 1))/\(StroopRound.quizLength)")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(CatQuizPalette.wood))
                .accessibilityIdentifier("stroop-score")
                        .accessibilityLabel(tr(ja: "得点 \(session.score)", zh: "得分 \(session.score)", en: "Score \(session.score)", my: "ရမှတ် \(session.score)", ko: "점수 \(session.score)", fr: "Score \(session.score)", zhHant: "得分 \(session.score)"))
            Text(tr(ja: "得点 \(session.score)", zh: "得分 \(session.score)", en: "Score \(session.score)", my: "ရမှတ် \(session.score)", ko: "점수 \(session.score)", fr: "Score \(session.score)", zhHant: "得分 \(session.score)"))
                .font(.caption.weight(.bold))
                .foregroundStyle(CatQuizPalette.ink)
                .lineLimit(1)
            if session.showsTimer {
                circularTimer
            } else {
                Color.clear.frame(width: 68, height: 68)
            }
        }
    }

    private var circularTimer: some View {
        ZStack {
            Circle()
                .fill(CatQuizPalette.wood)
                .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 2))
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 7)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    urgencyColor,
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(secondsLeft)")
                .font(.system(size: session.questionRemaining <= urgentRemaining ? 26 : 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 68, height: 68)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("stroop-timer")
        .accessibilityLabel(tr(ja: "残り \(secondsLeft) 秒", zh: "还剩 \(secondsLeft) 秒", en: "\(secondsLeft) seconds left", my: "\(secondsLeft) စက္ကန့်ကျန်သည်", ko: "남은 시간 \(secondsLeft)초", fr: "\(secondsLeft) s restantes", zhHant: "還剩 \(secondsLeft) 秒"))
    }

    private var questionBanner: some View {
        VStack(spacing: 4) {
            Text(session.round.rule)
                .font(.system(size: 25, weight: .heavy, design: .rounded))
                .foregroundStyle(CatQuizPalette.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if session.lastAnswerWasCorrect == true {
                Text(tr(ja: "正解", zh: "答对了", en: "Correct", my: "မှန်သည်"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.24))
            } else if session.lastAnswerWasCorrect == false {
                Text(session.lastMissWasTimeout
                    ? tr(ja: "時間切れ", zh: "超时", en: "Time's up", my: "အချိန်ကုန်ပြီ")
                    : tr(ja: "不正解", zh: "点错了", en: "Wrong", my: "မှားသည်"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.92, green: 0.28, blue: 0.34))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
        .accessibilityIdentifier("stroop-answer-\(session.round.answerID)")
        .accessibilityLabel(session.round.rule)
    }

    private var answerExplanation: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image("QuizCatThinking")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 52)
                    .accessibilityHidden(true)
                Label(
                    explanationTitle,
                    systemImage: "lightbulb.fill"
                )
                .font(.headline)
            }
            Text(session.round.answerExplanation)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("stroop-explanation")
            Label(tr(ja: "読んでいる間は時間が止まります", zh: "讲解期间暂停计时", en: "The timer is paused while you read", my: "ဖတ်နေစဉ် အချိန်ရပ်ထားသည်"), systemImage: "pause.circle")
                .font(.caption)
        }
        .foregroundStyle(CatQuizPalette.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .modifier(WoodlandPanel())
    }

    private var explanationTitle: String {
        if session.lastAnswerWasCorrect == true {
            tr(ja: "正解！なぜそうなるか見てみよう", zh: "答对了，看看为什么", en: "That's right — here's why", my: "မှန်ပါတယ်၊ အကြောင်းရင်းကြည့်ရအောင်")
        } else if session.lastMissWasTimeout {
            tr(ja: "時間切れ・この問題を見てみよう", zh: "时间到了，看看这一题", en: "Time's up — let's review", my: "အချိန်ကုန်ပြီ၊ အတူကြည့်ရအောင်")
        } else {
            tr(ja: "どこで迷ったか見てみよう", zh: "看看刚才哪里弄混了", en: "Let's see what got mixed up", my: "ဘာရောထွေးသွားလဲ ကြည့်ရအောင်")
        }
    }

    private var stimulusPanel: some View {
        stimulus(session.round)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier("stroop-answer-\(session.round.answerID)")
            .accessibilityLabel(session.round.rule)
    }

    private var quizFooter: some View {
        VStack(spacing: 10) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CatQuizPalette.wood)
                    Capsule()
                        .fill(LinearGradient(colors: [Color(red: 0.58, green: 0.95, blue: 0.2), Color(red: 0.25, green: 0.85, blue: 0.48)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(18, (geo.size.width - 8) * quizProgress))
                        .overlay(Capsule().strokeBorder(.white, lineWidth: 2))
                        .padding(4)
                }
            }
            .frame(height: 25)
            .overlay(Capsule().strokeBorder(.white.opacity(0.85), lineWidth: 1.5))
            .accessibilityLabel(tr(
                ja: "進捗 \(min(session.answerCount + (session.isResolving ? 0 : 1), StroopRound.quizLength)) / \(StroopRound.quizLength)",
                zh: "进度 \(min(session.answerCount + (session.isResolving ? 0 : 1), StroopRound.quizLength)) / \(StroopRound.quizLength)",
                en: "Progress \(min(session.answerCount + (session.isResolving ? 0 : 1), StroopRound.quizLength)) of \(StroopRound.quizLength)",
                my: "တိုးတက်မှု \(min(session.answerCount + (session.isResolving ? 0 : 1), StroopRound.quizLength)) / \(StroopRound.quizLength)",
                ko: "진행 \(min(session.answerCount + (session.isResolving ? 0 : 1), StroopRound.quizLength)) / \(StroopRound.quizLength)",
                fr: "Progression \(min(session.answerCount + (session.isResolving ? 0 : 1), StroopRound.quizLength)) / \(StroopRound.quizLength)",
                zhHant: "進度 \(min(session.answerCount + (session.isResolving ? 0 : 1), StroopRound.quizLength)) / \(StroopRound.quizLength)"
            ))

            HStack {
                Text(tr(ja: "連続 \(session.streak)", zh: "连对 \(session.streak)", en: "Streak \(session.streak)", my: "ဆက်တိုက် \(session.streak)", ko: "연속 \(session.streak)", fr: "Série \(session.streak)", zhHant: "連對 \(session.streak)"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CatQuizPalette.ink)
                Spacer()
                Button(tr(ja: "終了", zh: "结束", en: "End", my: "ထွက်ရန်")) { session.quitToBoard() }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CatQuizPalette.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(CatQuizPalette.cream))
            }
            .padding(.horizontal, 6)
        }
        .padding(10)
        .modifier(WoodlandPanel())
    }

    private var urgentRemaining: TimeInterval {
        min(3, session.questionLimit * 0.4)
    }

    private var warningRemaining: TimeInterval {
        session.questionLimit * 0.6
    }

    private var progress: CGFloat {
        CGFloat(min(1, max(0, session.questionRemaining / session.questionLimit)))
    }

    private var quizProgress: CGFloat {
        let current = session.answerCount + (session.isResolving ? 0 : 1)
        return CGFloat(min(1, max(0, Double(current) / Double(StroopRound.quizLength))))
    }

    private var bestQuizTimeText: String {
        guard let top = ScoreBoard.records(for: StroopRound.quizGame).first else {
            return "—"
        }
        return ScoreBoard.durationLabel(milliseconds: top.detail)
    }

    private var secondsLeft: Int {
        max(0, Int(ceil(session.questionRemaining - 0.001)))
    }

    private var urgencyColor: Color {
        if session.questionRemaining <= urgentRemaining {
            Color(red: 0.95, green: 0.22, blue: 0.28)
        } else if session.questionRemaining <= warningRemaining {
            Color(red: 0.98, green: 0.72, blue: 0.2)
        } else {
            Color(red: 0.98, green: 0.82, blue: 0.22)
        }
    }

    @ViewBuilder
    private func stimulus(_ round: StroopRound) -> some View {
        switch round.stimulus {
        case .word(let word, let ink):
            Text(word.name)
                .font(.system(size: 72, weight: .black))
                .foregroundStyle(ink.color)
                .frame(maxWidth: .infinity)
                .frame(height: 120)
        case .emblem:
            EmptyView()
        case .flag(_, let emoji):
            Text(emoji)
                .font(.system(size: 88))
                .frame(maxWidth: .infinity)
                .frame(height: 120)
        }
    }

    private var answers: some View {
        let marks = ["A", "B"]
        let accents: [Color] = [.pink, .blue]
        return HStack(spacing: 12) {
            ForEach(Array(session.round.choices.enumerated()), id: \.element.id) { index, choice in
                choiceCard(choice, mark: marks[index], accent: accents[index])
            }
        }
    }

    private func choiceCard(_ choice: AnswerChoice, mark: String, accent: Color) -> some View {
        Button { session.choose(choice.id) } label: {
            VStack(spacing: 12) {
                HStack {
                    Text(mark)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(accent, in: Circle())
                        .overlay { Circle().strokeBorder(CatQuizPalette.cream, lineWidth: 2) }
                    Spacer()
                    if session.isResolving && choice.id == session.round.answerID {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.24))
                    } else if session.isReviewingMistake && session.selectedChoiceID == choice.id {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color(red: 0.75, green: 0.15, blue: 0.2))
                    } else {
                        Image(systemName: "pawprint.fill")
                            .foregroundStyle(CatQuizPalette.wood.opacity(0.18))
                    }
                }
                choiceVisual(choice)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: session.isReviewing ? 52 : 72)
                    .frame(maxHeight: session.isReviewing ? 90 : 120)
                if session.isResolving && choice.id == session.round.answerID {
                    Text(tr(ja: "正解", zh: "正确答案", en: "Correct answer", my: "အဖြေမှန်"))
                        .font(.caption.bold())
                        .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.24))
                } else if session.isReviewingMistake && session.selectedChoiceID == choice.id {
                    Text(tr(ja: "選んだ答え", zh: "你的选择", en: "Your choice", my: "သင်ရွေးသောအဖြေ"))
                        .font(.caption.bold())
                        .foregroundStyle(Color(red: 0.75, green: 0.15, blue: 0.2))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .frame(minHeight: session.isReviewing ? 150 : 180)
            .modifier(WoodlandPanel())
        }
        .buttonStyle(ArcadePressStyle())
        .disabled(session.isResolving)
        .overlay {
            if session.isResolving && (session.selectedChoiceID == choice.id || choice.id == session.round.answerID) {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(choice.id == session.round.answerID ? Color.green : Color.red, lineWidth: 4)
                    .allowsHitTesting(false)
            }
        }
        .accessibilityIdentifier("stroop-choice-\(choice.id)")
        .accessibilityLabel("\(mark). \(choice.title)")
    }

    @ViewBuilder
    private func choiceVisual(_ choice: AnswerChoice) -> some View {
        if let badge = choice.badge {
            Text(badge)
                .font(.system(size: 64))
        } else if let symbol = choice.symbol {
            Image(systemName: symbol)
                .font(.system(size: 54, weight: .bold))
                .foregroundStyle(Color(red: 0.16, green: 0.16, blue: 0.18))
        } else if case .ink(let color) = choice.style {
            Text(choice.title)
                .font(.system(size: 40, weight: .black))
                .foregroundStyle(color.color)
                .lineLimit(1)
                .minimumScaleFactor(0.35)
                .padding(18)
                .background(Circle().fill(color.color.opacity(0.16)))
        } else {
            Text(choice.title)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.16, green: 0.16, blue: 0.18))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.55)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var result: some View {
        ScrollView {
            VStack(spacing: 20) {
                languageBar
                WoodlandTitle(height: 140)
                CatQuizHost(hint: session.resultCatSpeech, celebrating: true)
                    .accessibilityIdentifier("stroop-result-cat")

                resultScoreCard

                VStack(spacing: 12) {
                    Button { session.start() } label: {
                        WoodlandAction(title: tr(ja: "もう一度あそぶ", zh: "再玩一次", en: "Play again", my: "နောက်တစ်ပွဲ"), symbol: "arrow.clockwise")
                    }
                    .buttonStyle(ArcadePressStyle())
                    .accessibilityIdentifier("stroop-play-again")
                    Button { session.returnToMenu() } label: {
                        Label(tr(ja: "スタート画面へ", zh: "返回首页", en: "Back to start", my: "အစသို့ ပြန်ရန်"), systemImage: "house.fill")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .foregroundStyle(CatQuizPalette.ink)
                            .background(CatQuizPalette.cream.opacity(0.9), in: RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(ArcadePressStyle())
                    .accessibilityIdentifier("stroop-result-back")
                }

                resultRanking
            }
            .padding(20)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var resultScoreCard: some View {
        VStack(spacing: 12) {
            Label(tr(ja: "今回のスコア", zh: "本次得分", en: "Your score", my: "သင့်ရမှတ်"), systemImage: "star.fill")
                .font(.subheadline.bold())
                .foregroundStyle(CatQuizPalette.wood)
            Text("\(session.score)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(CatQuizPalette.ink)
                .accessibilityIdentifier("stroop-result-score")
            Text(session.accuracyText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CatQuizPalette.ink.opacity(0.8))
                .multilineTextAlignment(.center)
            HStack {
                Label(tr(ja: "合計時間", zh: "答题总时间", en: "Total time", my: "စုစုပေါင်းအချိန်"), systemImage: "stopwatch")
                Spacer()
                Text(session.answeringTimeText)
                    .monospacedDigit()
            }
            .font(.subheadline.bold())
            .foregroundStyle(CatQuizPalette.wood)
            Divider().overlay(CatQuizPalette.wood.opacity(0.2))
            HStack {
                Label(tr(ja: "自己ベスト", zh: "个人最佳", en: "Personal best", my: "အကောင်းဆုံး"), systemImage: "trophy.fill")
                Spacer()
                Text(bestQuizTimeText)
                    .monospacedDigit()
            }
            .font(.subheadline.bold())
            .foregroundStyle(CatQuizPalette.wood)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .modifier(WoodlandPanel())
    }

    private var resultRanking: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(tr(ja: "ランキング", zh: "排行榜", en: "Leaderboard", my: "အဆင့်စာရင်း"), systemImage: "crown.fill")
                .font(.system(.headline, design: .rounded, weight: .bold))
            ForEach(Array(ScoreBoard.records(for: StroopRound.quizGame).enumerated()), id: \.element.id) { index, record in
                HStack {
                    Text("\(index + 1)")
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .frame(width: 28, height: 28)
                        .background(index == 0 ? Color.yellow.opacity(0.6) : CatQuizPalette.cream, in: Circle())
                    if !record.avatar.isEmpty {
                        Text(record.avatar)
                            .font(.title3)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        if !record.name.isEmpty {
                            Text(record.name)
                                .font(.system(.subheadline, design: .rounded, weight: index == 0 ? .heavy : .semibold))
                                .lineLimit(2)
                        }
                        Text(ScoreBoard.durationLabel(milliseconds: record.detail))
                            .font(.system(.body, design: .rounded, weight: index == 0 ? .heavy : .medium))
                            .monospacedDigit()
                    }
                    Spacer()
                    Text(tr(ja: "\(record.score)点", zh: "\(record.score)分", en: "\(record.score) pts", my: "\(record.score)", ko: "\(record.score)점", fr: "\(record.score) pts", zhHant: "\(record.score)分"))
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()
                    if index == 0 { Image(systemName: "trophy.fill").foregroundStyle(CatQuizPalette.wood) }
                }
                .accessibilityElement(children: .combine)
            }
        }
        .foregroundStyle(CatQuizPalette.ink)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(WoodlandPanel())
    }

}

private struct WoodlandTitle: View {
    let height: CGFloat
    var body: some View {
        Image("WoodlandTitle")
            .resizable().scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(alignment: .bottom) {
                Text(tr(ja: "よく見て、どっちかを選ぼう！", zh: "仔细看，选择正确答案！", en: "Look closely. Choose A or B!", my: "သေချာကြည့်ပြီး A သို့မဟုတ် B ကို ရွေးပါ။"))
                    .font(.system(size: max(9, height * 0.039), weight: .heavy, design: .rounded))
                    .foregroundStyle(CatQuizPalette.wood)
                    .lineLimit(1).minimumScaleFactor(0.6)
                    .frame(width: height * 0.64)
                    .padding(.bottom, height * 0.095)
            }
            .shadow(color: CatQuizPalette.wood.opacity(0.25), radius: 8, y: 5)
            .accessibilityLabel("Brain Rush")
    }
}

private struct WoodlandPanel: ViewModifier {
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(LinearGradient(colors: [Color(red: 1, green: 0.96, blue: 0.84), Color(red: 0.98, green: 0.87, blue: 0.69)], startPoint: .top, endPoint: .bottom))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color(red: 0.67, green: 0.40, blue: 0.20), lineWidth: 1.5)
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: max(4, cornerRadius - 3))
                    .strokeBorder(Color(red: 1, green: 0.98, blue: 0.87), lineWidth: 1.5)
                    .padding(4)
                    .allowsHitTesting(false)
            }
            .shadow(color: CatQuizPalette.wood.opacity(0.28), radius: 0, y: 4)
    }
}

private struct WoodlandAction: View {
    let title: String
    let symbol: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "pawprint.fill").font(.caption).opacity(0.45)
            Spacer(minLength: 0)
            Label(title, systemImage: symbol)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.65).lineLimit(1)
                .shadow(color: Color(red: 1, green: 0.97, blue: 0.75), radius: 0, x: 1, y: 1)
            Spacer(minLength: 0)
            Image(systemName: "pawprint.fill").font(.caption).opacity(0.45)
        }
        .foregroundStyle(CatQuizPalette.wood)
        .padding(.horizontal, 18).padding(.vertical, 15)
        .background(LinearGradient(colors: [Color(red: 1, green: 0.92, blue: 0.39), Color(red: 1, green: 0.70, blue: 0.22)], startPoint: .top, endPoint: .bottom), in: Capsule())
        .overlay { Capsule().strokeBorder(CatQuizPalette.wood.opacity(0.8), lineWidth: 2) }
        .overlay(alignment: .topLeading) {
            Capsule().fill(Color(red: 1, green: 0.98, blue: 0.75).opacity(0.75))
                .frame(width: 24, height: 5).rotationEffect(.degrees(-25))
                .padding(.leading, 19).padding(.top, 12)
        }
        .overlay { Capsule().strokeBorder(Color(red: 1, green: 0.98, blue: 0.76), lineWidth: 2).padding(4) }
        .shadow(color: CatQuizPalette.wood.opacity(0.35), radius: 0, y: 4)
    }
}

private struct ArcadePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? -0.06 : 0)
    }
}

private struct StroopNavigationChrome: ViewModifier {
    let isPlaying: Bool

    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarBackButtonHidden(isPlaying)
            .toolbar(.hidden, for: .navigationBar)
        #else
        content
        #endif
    }
}

private struct StroopBackdrop: View {
    var light = false

    var body: some View {
        Group {
            if light {
                GeometryReader { geometry in
                    Image("CatRoomBackground")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .overlay(Color(red: 1, green: 0.95, blue: 0.85).opacity(0.08))
                }
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.09, green: 0.11, blue: 0.18),
                        Color(red: 0.05, green: 0.06, blue: 0.09),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        StroopGameView()
    }
}
