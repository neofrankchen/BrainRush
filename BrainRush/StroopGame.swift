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
final class LanguageStore: ObservableObject {
    static let shared = LanguageStore()

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "appLanguage") }
    }

    private init() {
        language = Self.loadLaunchLanguage()
    }

    private static func loadLaunchLanguage() -> AppLanguage {
        let args = ProcessInfo.processInfo.arguments
        if let flag = args.firstIndex(of: "-appLanguage"), args.indices.contains(flag + 1),
           let forced = AppLanguage(rawValue: args[flag + 1]) {
            return forced
        }
        if !UserDefaults.standard.bool(forKey: "appLanguageDefaultIsJapanese") {
            UserDefaults.standard.set(true, forKey: "appLanguageDefaultIsJapanese")
            UserDefaults.standard.set(AppLanguage.japanese.rawValue, forKey: "appLanguage")
            return .japanese
        }
        return AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? "") ?? .japanese
    }
}

func tr(ja: String, zh: String, en: String, my: String, ko: String = "", fr: String = "", zhHant: String = "") -> String {
    let language = MainActor.assumeIsolated { LanguageStore.shared.language }
    switch language {
    case .japanese: return ja
    case .chinese: return zh
    case .english: return en
    case .burmese: return my
    case .korean: return ExtraLang.first(ko, ExtraLang.ui[ja]?.ko, ja)
    case .french: return ExtraLang.first(fr, ExtraLang.ui[ja]?.fr, ja)
    case .traditional: return ExtraLang.first(zhHant, ExtraLang.ui[ja]?.zhHant, ExtraLang.toTraditional(zh))
    }
}

struct LanguagePicker: View {
    var compact = false
    var stacked = false
    var onSelect: (() -> Void)? = nil
    @ObservedObject private var languages = LanguageStore.shared

    var body: some View {
        if stacked {
            VStack(spacing: 8) {
                ForEach(AppLanguage.allCases, content: languageButton)
            }
        } else {
            LanguageWrap(spacing: compact ? 6 : 8) {
                ForEach(AppLanguage.allCases, content: languageButton)
            }
        }
    }

    private func languageButton(_ language: AppLanguage) -> some View {
        let selected = languages.language
        return Button {
            languages.language = language
            onSelect?()
        } label: {
            HStack(spacing: 10) {
                Text(language.label)
                    .frame(maxWidth: stacked ? .infinity : nil, alignment: .leading)
                if stacked, language == selected {
                    Image(systemName: "checkmark")
                }
            }
            .font(compact ? .caption2.weight(.semibold) : .system(.subheadline, design: .rounded, weight: .bold))
            .foregroundStyle(selected == language ? CatQuizPalette.ink : CatQuizPalette.wood)
            .padding(.horizontal, compact ? 8 : 16)
            .padding(.vertical, compact ? 5 : (stacked ? 12 : 7))
            .frame(minHeight: compact ? 32 : 44)
            .background {
                Capsule().fill(
                    selected == language
                        ? Color(red: 0.98, green: 0.74, blue: 0.32)
                        : CatQuizPalette.cream.opacity(0.94)
                )
            }
            .overlay {
                Capsule().strokeBorder(CatQuizPalette.wood.opacity(selected == language ? 0.4 : 0.14), lineWidth: 1)
            }
        }
        .buttonStyle(ArcadePressStyle())
        .accessibilityAddTraits(selected == language ? .isSelected : [])
        .accessibilityIdentifier("language-\(language.rawValue)")
    }
}

private struct LanguageWrap: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth: CGFloat = {
            if let width = proposal.width, width.isFinite, width > 0 { return width }
            return .greatestFiniteMagnitude
        }()
        let rows = rows(maxWidth: maxWidth, subviews: subviews)
        let height = rows.reduce(CGFloat(0)) { $0 + $1.height } + spacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        let maxWidth = bounds.width.isFinite && bounds.width > 0 ? bounds.width : .greatestFiniteMagnitude
        for row in rows(maxWidth: maxWidth, subviews: subviews) {
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
    case japanChoice
    case animeChoice
    case natureChoice
    case gourmetChoice
    case otherChoice
    case flag

    var title: String {
        switch self {
        case .colorWord: tr(ja: "色と字", zh: "色和字", en: "Color and word", my: "အရောင်နှင့် စာသား")
        case .brainTeaser: tr(ja: "ひっかけ問題", zh: "脑筋急转弯", en: "Brain teaser", my: "ပဟေဠိ")
        case .hardChoice: tr(ja: "難問2択", zh: "难问二选一", en: "Hard two-choice", my: "ခက်သော ၂ ခုရွေး")
        case .funChoice: tr(ja: "おもしろ2択", zh: "有趣二选一", en: "Fun two-choice", my: "ပျော်စရာ ၂ ခုရွေး")
        case .foodChoice: tr(ja: "食べ物2択", zh: "食物二选一", en: "Food two-choice", my: "အစားအစာ ၂ ခုရွေး")
        case .kidChoice: tr(ja: "幼児2択", zh: "幼儿二选一", en: "Kids two-choice", my: "ကလေး ၂ ခုရွေး")
        case .japanChoice: tr(ja: "日本の常識", zh: "日本常识", en: "Japan facts", my: "ဂျပန် ဗဟုသုတ")
        case .animeChoice: tr(ja: "アニメ", zh: "日本动漫", en: "Anime", my: "အန်နီမေ")
        case .natureChoice: tr(ja: "自然", zh: "自然", en: "Nature", my: "သဘာဝ")
        case .gourmetChoice: tr(ja: "美食", zh: "美食", en: "Food", my: "အစားအသောက်")
        case .otherChoice: tr(ja: "世界の常識", zh: "世界常识", en: "World facts", my: "ကမ္ဘာ့ဗဟုသုတ")
        case .flag: tr(ja: "国旗", zh: "旗帜", en: "Flags", my: "အလံ")
        }
    }

    var family: QuestionFamily {
        switch self {
        case .colorWord: .stroop
        case .brainTeaser: .brainTeaser
        case .japanChoice: .japan
        case .animeChoice: .anime
        case .natureChoice: .nature
        case .gourmetChoice: .gourmet
        case .otherChoice, .hardChoice, .funChoice, .foodChoice, .kidChoice: .other
        case .flag: .flag
        }
    }
}

enum QuestionFamily: String, CaseIterable, Identifiable {
    case all
    case stroop
    case brainTeaser
    case japan
    case anime
    case nature
    case gourmet
    case other
    case flag

    var id: String { rawValue }

    static var playable: [QuestionFamily] { allCases.filter { $0 != .all } }

    var questionCount: Int {
        switch self {
        case .all: QuestionFamily.playable.reduce(0) { $0 + $1.questionCount }
        case .stroop: ColorWordBank.count
        case .brainTeaser: BrainTeaserBank.count
        case .japan: JapanChoiceBank.count
        case .anime: AnimeChoiceBank.count
        case .nature: NatureChoiceBank.count
        case .gourmet: GourmetChoiceBank.count
        case .other: OtherChoiceBank.count
        case .flag: FlagBank.count
        }
    }

    var chipTitle: String {
        switch self {
        case .all: tr(ja: "全部", zh: "全部", en: "All", my: "အားလုံး")
        case .stroop: tr(ja: "ストループ効果", zh: "斯特鲁普效应", en: "Stroop Effect", my: "Stroop Effect")
        case .brainTeaser: tr(ja: "ひっかけ", zh: "急转弯", en: "Teaser", my: "ပဟေဠိ")
        case .japan: tr(ja: "日本の常識", zh: "日本常识", en: "Japan facts", my: "ဂျပန် ဗဟုသုတ")
        case .anime: tr(ja: "アニメ", zh: "日本动漫", en: "Anime", my: "အန်နီမေ")
        case .nature: tr(ja: "自然", zh: "自然", en: "Nature", my: "သဘာဝ")
        case .gourmet: tr(ja: "美食", zh: "美食", en: "Food", my: "အစားအသောက်")
        case .other: tr(ja: "世界の常識", zh: "世界常识", en: "World facts", my: "ကမ္ဘာ့ဗဟုသုတ")
        case .flag: tr(ja: "国旗", zh: "旗帜", en: "Flags", my: "အလံ")
        }
    }

    var chipLabel: String { "\(chipTitle) \(questionCount)" }
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
        case .japanChoice: JapanChoiceBank.pick(excluding: excludingTeaserIDs)
        case .animeChoice: AnimeChoiceBank.pick(excluding: excludingTeaserIDs)
        case .natureChoice: NatureChoiceBank.pick(excluding: excludingTeaserIDs)
        case .gourmetChoice: GourmetChoiceBank.pick(excluding: excludingTeaserIDs)
        case .otherChoice: OtherChoiceBank.pick(excluding: excludingTeaserIDs)
        case .flag: FlagBank.pick(excluding: excludingTeaserIDs)
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
            if let matching = JapanChoiceBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            if let matching = AnimeChoiceBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            if let matching = NatureChoiceBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            if let matching = GourmetChoiceBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            if let matching = OtherChoiceBank.template(id: id) {
                return localizedEmblem(from: matching.make(shuffle: false), rule: matching.rule)
            }
            return self
        case .flag(let id, _):
            if let matching = FlagBank.template(id: id) {
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

    static let quizLength = 10
    static let pointsPerCorrect = 10
    static let quizGame = "quiz"

    static func randomQuiz(count: Int = quizLength) -> [StroopRound] {
        var others = BrainTeaserBank.allRounds() + HardChoiceBank.allRounds() + FunChoiceBank.allRounds() + FoodChoiceBank.allRounds() + KidChoiceBank.allRounds() + JapanChoiceBank.allRounds() + AnimeChoiceBank.allRounds() + NatureChoiceBank.allRounds() + GourmetChoiceBank.allRounds() + OtherChoiceBank.allRounds()
        others.shuffle()
        var quiz: [StroopRound] = []
        if let flag = FlagBank.allRounds().randomElement() {
            quiz.append(flag)
        }
        quiz.append(contentsOf: others.prefix(max(0, count - 1 - quiz.count)))
        quiz.append(ColorWordBank.pick())
        if quiz.count < count {
            quiz.append(contentsOf: others.dropFirst(quiz.count - 1).prefix(count - quiz.count))
        }
        quiz.shuffle()
        return Array(quiz.prefix(count))
    }

}

private enum StroopCue {
    case correct
    case wrong
    case timeout
}

private final class StroopAudio {
    private var clips: [StroopCue: Data] = [:]
    private var player: AVAudioPlayer?
    private let audioQueue = DispatchQueue(label: "stroop.audio", qos: .userInitiated)

    init() {
        audioQueue.async { [weak self] in
            self?.clips = [
                .correct: Self.wav([(784, 0, 0.42), (1046, 0.07, 0.36)], seconds: 0.2),
                .wrong: Self.wav([(196, 0, 0.48), (140, 0.04, 0.32)], seconds: 0.16),
                .timeout: Self.wav([(494, 0, 0.36), (330, 0.08, 0.32), (220, 0.16, 0.26)], seconds: 0.32),
            ]
        }
    }

    func stop() {
        audioQueue.async { [weak self] in
            self?.player?.stop()
            self?.player = nil
        }
    }

    func play(_ cue: StroopCue) {
        audioQueue.async { [weak self] in
            guard let self, let data = self.clips[cue] else { return }
            self.player?.stop()
            guard let next = try? AVAudioPlayer(data: data) else { return }
            next.volume = cue == .correct ? 0.18 : 0.14
            next.prepareToPlay()
            next.play()
            self.player = next
        }
    }

    private static func wav(_ notes: [(hz: Double, at: Double, amp: Double)], seconds: Double) -> Data {
        let rate = 44_100.0
        let count = Int(seconds * rate)
        var samples = [Int16](repeating: 0, count: count)
        for frame in 0..<count {
            let time = Double(frame) / rate
            var sample = 0.0
            let attack = min(1, time / 0.012)
            for note in notes {
                let age = time - note.at
                if age >= 0 {
                    sample += sin(2 * .pi * note.hz * age) * note.amp * exp(-age * 8)
                }
            }
            sample *= attack
            samples[frame] = Int16(max(-1, min(1, sample)) * Double(Int16.max))
        }
        let dataSize = UInt32(count * 2)
        var data = Data()
        data.append(contentsOf: Array("RIFF".utf8))
        let chunk = UInt32(36 + dataSize).littleEndian
        data.append(contentsOf: withUnsafeBytes(of: chunk, Array.init))
        data.append(contentsOf: Array("WAVEfmt ".utf8))
        let meta: [UInt32] = [16, 0x0001_0001, UInt32(rate), UInt32(rate) * 2]
        for value in meta {
            let little = value.littleEndian
            data.append(contentsOf: withUnsafeBytes(of: little, Array.init))
        }
        let block: UInt16 = 2
        let bits: UInt16 = 16
        data.append(contentsOf: withUnsafeBytes(of: block.littleEndian, Array.init))
        data.append(contentsOf: withUnsafeBytes(of: bits.littleEndian, Array.init))
        data.append(contentsOf: Array("data".utf8))
        let size = dataSize.littleEndian
        data.append(contentsOf: withUnsafeBytes(of: size, Array.init))
        samples.withUnsafeBytes { data.append(contentsOf: $0) }
        return data
    }
}

@MainActor
final class StroopSession: ObservableObject {
    enum Phase {
        case ready
        case naming
        case playing
        case renaming
        case finished
    }

    private let audio = StroopAudio()

    @Published private(set) var phase: Phase = .ready
    @Published private(set) var round = StroopRound.make(.colorWord)
    @Published private(set) var score = 0
    @Published private(set) var streak = 0
    @Published private(set) var correctCount = 0
    @Published private(set) var answerCount = 0
    @Published private(set) var questionRemaining: TimeInterval = 30
    @Published private(set) var questionLimit: TimeInterval = 30
    @Published private(set) var lastAnswerWasCorrect: Bool?
    @Published private(set) var lastMissWasTimeout = false
    @Published private(set) var isResolving = false
    @Published private(set) var answersLocked = false
    private var answerLockTask: Task<Void, Never>?
    @Published private(set) var selectedChoiceID: String?
    @Published private(set) var roundID = UUID()
    @Published private(set) var testing = false
    @Published private(set) var justPlayed = false
    @Published private(set) var showsPracticeTools = false
    @Published private(set) var testUsesTimer = false
    @Published private(set) var testFamily: QuestionFamily = .all
    private var questionEndsAt: Date?
    private var questionStartedAt: Date?
    private var usedTeaserIDs = Set<String>()
    private var seenQuestionKeys = Set<String>()
    private var quiz: [StroopRound] = []
    private var quizIndex = 0
    @Published private(set) var answeringElapsed: TimeInterval = 0
    @Published private(set) var lastPlacement: Int?
    @Published private(set) var lastRunID: UUID?
    @Published private(set) var playerName = ""
    @Published private(set) var playerNameID: String?
    @Published private(set) var playerAvatar = PlayerNames.fallbackAvatar

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

    var boastRivalNames: [String] {
        Array(boastRivals.prefix(1)).map(leaderboardName)
    }

    var boastHeadline: String {
        if !boastRivals.isEmpty {
            return tr(
                ja: "きみは超えたよ",
                zh: "你超越了",
                en: "You surpassed",
                my: "သင်ကျော်သွားသူ",
                ko: "네가 넘어선 사람",
                fr: "Tu as dépassé",
                zhHant: "你超越了"
            )
        }
        let language = LanguageStore.shared.language
        let board = boastBoard(language: language)
        let beaten = board.filter { beatsLeaderboard($0) && !isCurrentRun($0) }
        if beaten.contains(where: { isSamePlayer($0) }) {
            return tr(
                ja: "きみの知性は、自分の記録を超えたよ！",
                zh: "你的智力超越了自己的纪录！",
                en: "Your brain just beat your own record!",
                my: "သင့်ဉာဏ်က ကိုယ့်စံချိန်ကို ကျော်သွားပြီ!",
                ko: "너의 지능이 자기 기록을 넘어섰어!",
                fr: "Ton intelligence a battu ton propre record !",
                zhHant: "你的智力超越了自己的紀錄！"
            )
        }
        let others = board.filter { !isCurrentRun($0) && !isSamePlayer($0) }
        if others.isEmpty {
            return tr(
                ja: "ランキングはまだきみだけだよ！",
                zh: "排行榜上还只有你！",
                en: "You’re the only one on the board!",
                my: "အဆင့်စာရင်းတွင် သင်တစ်ယောက်တည်း!",
                ko: "순위판에는 아직 너뿐이야!",
                fr: "Tu es seul au classement !",
                zhHant: "排行榜上還只有你！"
            )
        }
        return tr(
            ja: "今度はランキングの人を超えてみよう！",
            zh: "这次还没超越排行榜上的人，再来一局吧！",
            en: "You haven’t passed anyone on the board yet. Try again!",
            my: "အဆင့်စာရင်းက လူတွေကို မကျော်ရသေး။ ထပ်ကစားပါ။",
            ko: "이번엔 순위판의 사람을 넘지 못했어. 다시 도전하자!",
            fr: "Tu n’as encore dépassé personne au classement. Réessaie !",
            zhHant: "這次還沒超越排行榜上的人，再來一局吧！"
        )
    }

    var intelligenceBoast: String {
        let names = boastRivalNames
        if names.isEmpty { return boastHeadline }
        return "\(boastHeadline)\n\(names.joined(separator: "\n"))"
    }

    private var boastRivals: [ScoreRecord] {
        let language = LanguageStore.shared.language
        let board = boastBoard(language: language)
        let beaten = board.filter { beatsLeaderboard($0) && !isCurrentRun($0) }
        let sameLanguage = beaten.filter { $0.language == language.rawValue && !isSamePlayer($0) }
        return sameLanguage.isEmpty ? beaten.filter { !isSamePlayer($0) } : sameLanguage
    }

    private func boastBoard(language: AppLanguage) -> [ScoreRecord] {
        var rows = ScoreBoard.records(for: StroopRound.quizGame, filter: .language(language))
        var seen = Set(rows.map(\.id))
        for row in ScoreBoard.records(for: StroopRound.quizGame) {
            let sameLanguage = row.language == language.rawValue || row.language.isEmpty
            if sameLanguage, seen.insert(row.id).inserted {
                rows.append(row)
            }
        }
        return rows
    }

    private func beatsLeaderboard(_ row: ScoreRecord) -> Bool {
        if score != row.score { return score > row.score }
        let milliseconds = Int((answeringElapsed * 1000).rounded())
        if milliseconds != row.detail { return milliseconds < row.detail }
        return false
    }

    private func isCurrentRun(_ row: ScoreRecord) -> Bool {
        if let lastRunID { return row.id == lastRunID }
        return false
    }

    private func isSamePlayer(_ row: ScoreRecord) -> Bool {
        if !playerName.isEmpty, row.name == playerName, row.avatar == playerAvatar { return true }
        if playerName.isEmpty, !playerAvatar.isEmpty, row.name.isEmpty, row.avatar == playerAvatar { return true }
        return false
    }

    private func leaderboardName(_ row: ScoreRecord) -> String {
        let trimmed = row.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        if !row.avatar.isEmpty { return row.avatar }
        return tr(ja: "名無し", zh: "无名玩家", en: "Mystery player", my: "အမည်မဲ့", ko: "이름 없음", fr: "Sans nom", zhHant: "無名玩家")
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
        justPlayed = false
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
        guard phase == .naming else { return }
        applyNameDraft(draft, cannedID: cannedID, avatar: avatar)
        start(practice: false)
    }

    func keepNameForBoard() {
        guard phase == .renaming else { return }
        publishScore()
    }

    func confirmRename(_ draft: String, cannedID: String?, avatar: String) {
        guard phase == .renaming else { return }
        applyNameDraft(draft, cannedID: cannedID, avatar: avatar)
        publishScore()
    }

    func cancelSetup() {
        phase = .ready
    }

    func backToNaming() {
        audio.stop()
        answerLockTask?.cancel()
        answersLocked = false
        questionEndsAt = nil
        questionStartedAt = nil
        isResolving = false
        selectedChoiceID = nil
        lastAnswerWasCorrect = nil
        lastMissWasTimeout = false
        phase = .naming
    }

    func start(practice: Bool? = nil) {
        if let practice {
            showsPracticeTools = practice
            testing = practice
        }
        answerLockTask?.cancel()
        answersLocked = false
        isResolving = false
        selectedChoiceID = nil
        usedTeaserIDs = []
        seenQuestionKeys = []
        quiz = testing ? [] : StroopRound.randomQuiz()
        quizIndex = 0
        answeringElapsed = 0
        lastPlacement = nil
        lastRunID = nil
        questionStartedAt = nil
        score = 0
        streak = 0
        correctCount = 0
        answerCount = 0
        questionLimit = 30
        questionRemaining = 30
        lastAnswerWasCorrect = nil
        lastMissWasTimeout = false
        phase = .playing
        deal()
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
        let oldSecond = Int(ceil(questionRemaining - 0.001))
        let newSecond = Int(ceil(left - 0.001))
        if newSecond == oldSecond, abs(questionRemaining - left) < 0.25 { return }
        questionRemaining = left
    }

    func choose(_ id: String) {
        choose(id, timeout: false)
    }

    private func choose(_ id: String, timeout: Bool) {
        guard phase == .playing, !isResolving else { return }
        if !timeout, answersLocked { return }
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
            score += StroopRound.pointsPerCorrect
            lastAnswerWasCorrect = true
            lastMissWasTimeout = false
            audio.play(.correct)
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
        lastRunID = nil
        let id = ScoreBoard.submit(
            game: StroopRound.quizGame,
            score: score,
            detail: Int((answeringElapsed * 1000).rounded()),
            name: playerName,
            avatar: playerAvatar,
            language: LanguageStore.shared.language,
            rank: .timed
        )
        lastRunID = id
        if let id, let index = ScoreBoard.records(for: StroopRound.quizGame).firstIndex(where: { $0.id == id }) {
            lastPlacement = index + 1
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
        answerLockTask?.cancel()
        answersLocked = false
        questionEndsAt = nil
        roundID = UUID()
        isResolving = false
        selectedChoiceID = nil
        lastAnswerWasCorrect = nil
        lastMissWasTimeout = false
        testing = false
        showsPracticeTools = false
        justPlayed = true
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
            PlayerNames.saveLast(id: playerNameID, name: playerName, avatar: playerAvatar)
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
        lockAnswersBriefly()
    }

    private func lockAnswersBriefly() {
        answersLocked = true
        answerLockTask?.cancel()
        answerLockTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            answersLocked = false
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
        } else if trial.task == .japanChoice {
            let used = usedTeaserIDs.filter { JapanChoiceBank.template(id: $0) != nil }
            if used.count >= JapanChoiceBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        } else if trial.task == .animeChoice {
            let used = usedTeaserIDs.filter { AnimeChoiceBank.template(id: $0) != nil }
            if used.count >= AnimeChoiceBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        } else if trial.task == .natureChoice {
            let used = usedTeaserIDs.filter { NatureChoiceBank.template(id: $0) != nil }
            if used.count >= NatureChoiceBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        } else if trial.task == .gourmetChoice {
            let used = usedTeaserIDs.filter { GourmetChoiceBank.template(id: $0) != nil }
            if used.count >= GourmetChoiceBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        } else if trial.task == .otherChoice {
            let used = usedTeaserIDs.filter { OtherChoiceBank.template(id: $0) != nil }
            if used.count >= OtherChoiceBank.count {
                usedTeaserIDs.subtract(used)
                seenQuestionKeys.subtract(used.map { "teaser:\($0)" })
            }
        } else if trial.task == .flag {
            let used = usedTeaserIDs.filter { FlagBank.template(id: $0) != nil }
            if used.count >= FlagBank.count {
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
        let family: QuestionFamily
        if testing {
            family = testFamily == .all
                ? (QuestionFamily.playable.randomElement() ?? .stroop)
                : testFamily
        } else {
            family = QuestionFamily.playable.randomElement() ?? .stroop
        }
        return ScriptedTrial(task: task(for: family))
    }

    private func task(for family: QuestionFamily) -> InterferenceTask {
        switch family {
        case .all: task(for: QuestionFamily.playable.randomElement() ?? .stroop)
        case .stroop: .colorWord
        case .brainTeaser: .brainTeaser
        case .japan: .japanChoice
        case .anime: .animeChoice
        case .nature: .natureChoice
        case .gourmet: .gourmetChoice
        case .other: .otherChoice
        case .flag: .flag
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
    @StateObject private var session = StroopSession()
    @State private var companion = CatCompanion()
    @ObservedObject private var languages = LanguageStore.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var showsGuide = false
    @State private var showsRanking = false
    @State private var isHomeMenuVisible = false
    @State private var homeIdleNudge = 0
    @State private var nameDraft = ""
    @State private var cannedNameID: String?
    @State private var chosenAvatar = PlayerNames.fallbackAvatar
    @State private var showsAvatarPicker = false
    @State private var avatarGroup = PlayerNames.AvatarGroup.smileys
    @State private var isEditingRename = false
    @State private var showsProfileEditor = false
    @State private var showsLeaveAlert = false
    @State private var showsLanguage = false
    @State private var showsMusic = false
    @State private var rankingFilter: ScoreBoardFilter = .all
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        let language = languages.language
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
        .id(session.phase)
        .transition(.opacity.combined(with: .offset(y: 12)))
        .animation(.easeInOut(duration: 0.28), value: session.phase)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StroopBackdrop(light: session.phase == .playing || session.phase == .finished))
        .navigationTitle(tr(ja: "ブレインラッシュ", zh: "脑乱挑战", en: "Brain Rush", my: "အနှောင့်အယှက်စိန်ခေါ်ပွဲ"))
        .modifier(StroopNavigationChrome(isPlaying: session.phase == .playing))
        .background {
            if session.phase == .playing, session.showsTimer {
                TimelineView(.periodic(from: .now, by: 0.25)) { context in
                    Color.clear
                        .onChange(of: context.date) { date in
                            session.tick(now: date)
                        }
                }
            }
        }
        .onChange(of: language) { _ in
            session.applyLanguage()
            if let cannedNameID {
                nameDraft = PlayerNames.display(id: cannedNameID)
            }
        }
        .modifier(AnswerSensoryFeedback(correct: session.correctCount, answers: session.answerCount))
        .onChange(of: session.answerCount) { count in
            guard session.phase == .playing, count > 0 else { return }
            if session.lastAnswerWasCorrect == true {
                companion.perform(.celebrate)
            } else {
                companion.perform(.encourage)
            }
        }
        .onChange(of: session.roundID) { _ in
            if session.phase == .playing { companion.stop() }
        }
        .onChange(of: session.phase) { phase in
            switch phase {
            case .ready: companion.stop()
            case .naming, .playing: companion.perform(.greet, cue: .greeting)
            case .renaming:
                companion.perform(session.score >= 40 ? .celebrate : .encourage,
                                  cue: session.score >= 40 ? .result : .wrong)
            case .finished: companion.perform(session.score >= 40 ? .celebrate : .encourage)
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase != .active {
                companion.stop()
                if session.phase == .playing { session.pauseClock() }
            } else if session.phase == .playing, !overlaysPausePlay {
                session.resumeClock()
            }
        }
        .onDisappear { companion.stop() }
        .safeAreaInset(edge: .top, spacing: 0) {
            if session.phase != .ready {
                HStack {
                    if session.phase != .ready {
                        backBarButton
                    }
                    Spacer(minLength: 0)
                    HStack(spacing: 8) {
                        settingsBarButton
                        MusicPickerMenu { showsMusic = true }
                    }
                    .fixedSize()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
        .overlay(alignment: .topTrailing) {
            if session.phase == .ready && isHomeMenuVisible {
                HStack(spacing: 8) {
                    settingsBarButton
                    MusicPickerMenu { showsMusic = true }
                }
                .fixedSize()
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .simultaneousGesture(TapGesture().onEnded { homeIdleNudge += 1 })
            }
        }
        .modifier(EdgeBackSwipe(enabled: session.phase != .ready, action: goBack))
        .alert(
            tr(ja: "ゲームをやめる？", zh: "要退出这局吗？", en: "Leave this game?", my: "ဒီပွဲ ရပ်မလား။"),
            isPresented: $showsLeaveAlert
        ) {
            Button(tr(ja: "スタート画面へ", zh: "返回首页", en: "Back to start", my: "အစသို့ ပြန်ရန်"), role: .destructive) {
                session.returnToMenu()
            }
            Button(tr(ja: "つづける", zh: "继续", en: "Keep playing", my: "ဆက်ကစားမည်"), role: .cancel) {}
        } message: {
            Text(tr(
                ja: "いまの得点は保存されないよ。",
                zh: "当前得分不会保存。",
                en: "Your current score will not be saved.",
                my: "ယခုရမှတ် သိမ်းမည်မဟုတ်။"
            ))
        }
        .onChange(of: showsLeaveAlert) { showing in
            pauseOrResumePlay(showing)
        }
        .onChange(of: showsLanguage) { showing in
            pauseOrResumePlay(showing)
        }
        .onChange(of: showsMusic) { showing in
            pauseOrResumePlay(showing)
        }
        .sheet(isPresented: $showsLanguage) {
            menuSheet(tr(ja: "言語", zh: "语言", en: "Language", my: "ဘာသာစကား"), isPresented: $showsLanguage) {
                LanguagePicker(stacked: true) { showsLanguage = false }
            }
        }
        .sheet(isPresented: $showsMusic) {
            menuSheet(tr(ja: "BGM", zh: "背景音乐", en: "Music", my: "နောက်ခံသီချင်း"), isPresented: $showsMusic) {
                MusicTrackPicker()
            }
        }
    }

    private var backBarButton: some View {
        Button(action: goBack) {
            WoodlandIconBadge(symbol: "chevron.left")
        }
        .buttonStyle(ArcadePressStyle())
        .accessibilityLabel(tr(ja: "戻る", zh: "返回", en: "Back", my: "ပြန်ရန်"))
        .accessibilityIdentifier("stroop-back")
    }

    private var settingsBarButton: some View {
        Button { showsLanguage = true } label: {
            WoodlandIconBadge(symbol: "globe")
        }
        .buttonStyle(ArcadePressStyle())
        .accessibilityLabel(tr(ja: "言語", zh: "语言", en: "Language", my: "ဘာသာစကား"))
        .accessibilityIdentifier("stroop-settings")
    }

    private var overlaysPausePlay: Bool {
        showsProfileEditor || showsLeaveAlert || showsLanguage || showsMusic
    }

    private func pauseOrResumePlay(_ showing: Bool) {
        guard session.phase == .playing else { return }
        if showing {
            session.pauseClock()
        } else if !overlaysPausePlay {
            session.resumeClock()
        }
    }

    private func goBack() {
        switch session.phase {
        case .ready:
            break
        case .naming:
            session.cancelSetup()
        case .playing:
            if session.testing {
                session.returnToMenu()
            } else if session.answerCount > 0 || session.isResolving {
                session.pauseClock()
                showsLeaveAlert = true
            } else {
                session.backToNaming()
            }
        case .renaming:
            if isEditingRename {
                isEditingRename = false
            } else {
                session.keepNameForBoard()
            }
        case .finished:
            session.returnToMenu()
        }
    }

    private var menu: some View {
        CatWelcomeView(
            isMenuVisible: $isHomeMenuVisible,
            companion: companion,
            justPlayed: session.justPlayed,
            pauseIdle: showsRanking || showsGuide || showsLanguage || showsMusic,
            idleNudge: homeIdleNudge
        ) {
            VStack(spacing: 8) {
                Button { session.beginSetup(practice: false) } label: {
                    WoodlandAction(title: tr(ja: "ゲームを始める", zh: "开始游戏", en: "Let’s play", my: "ကစားမည်"), symbol: "play.fill")
                }
                .buttonStyle(ArcadePressStyle())
                .accessibilityIdentifier("stroop-start")
                .accessibilityLabel(tr(ja: "開始", zh: "开始", en: "Start", my: "စတင်မည်"))

                HStack(spacing: 12) {
                    arcadeShortcut("pencil.and.outline", tr(ja: "練習", zh: "练习", en: "Practice", my: "လေ့ကျင့်"), Color(red: 0.28, green: 0.48, blue: 0.36)) { session.beginSetup(practice: true) }
                        .accessibilityIdentifier("stroop-practice")
                    arcadeShortcut("crown", tr(ja: "ランキング", zh: "排行榜", en: "Ranking", my: "အဆင့်"), Color(red: 0.65, green: 0.43, blue: 0.18)) { showsRanking = true }
                        .accessibilityIdentifier("stroop-ranking")
                    arcadeShortcut("book.closed", tr(ja: "遊び方", zh: "怎么玩", en: "How to play", my: "ကစားနည်း"), Color(red: 0.36, green: 0.44, blue: 0.53)) { showsGuide = true }
                        .accessibilityIdentifier("stroop-guide")
                }
            }
        }
        .background(StroopBackdrop(light: true))
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showsGuide) {
            menuSheet(tr(ja: "遊び方", zh: "怎么玩", en: "How to play", my: "ကစားနည်း"), isPresented: $showsGuide) {
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
                            ja: "ストループ効果：字の色と書かれた文字が食い違う。いつも字の色を選ぶ。書いてある文字は無視する。\nひっかけ：正解と、いちばん間違えやすい答えの二択。日本語のひっかけでは、ネコがヒントをくれる。\n日本の常識：日本の地理・文化・行事・食べ物・昔話の二択。\nアニメ：日本の漫画・アニメの二択。\n自然：生き物・天文・自然の二択。\n美食：世界の料理の二択。\n世界の常識：世界の地理・名所・科学などの二択。\n国旗：旗を見て、どの国または地域か選ぶ。",
                            zh: "斯特鲁普效应：字的颜色和写出的字不一致。每次都选颜色，不要选写出的字。\n脑筋急转弯：两个选项里，一个是正确答案，另一个最容易想错。跟日语有关的题，猫咪会给提示。\n日本常识：日本地理、文化、节日、食物、传说的二选一。\n日本动漫：漫画和动画的二选一。\n自然：动植物、天文、自然现象的二选一。\n美食：世界料理的二选一。\n世界常识：世界地理、名胜、科学等二选一。\n旗帜：看旗帜，选出是哪个国家或地区。",
                            en: "Stroop Effect: always pick the ink color, not the word.\nBrain teasers: Japanese wordplay; the cat may hint.\nJapan facts: geography, culture, festivals, food, and folk tales.\nAnime: manga and anime two-choice.\nNature: animals, plants, space, and natural facts.\nFood: world dishes two-choice.\nWorld facts: geography, landmarks, science, and leftover trivia.\nFlags: look at the flag and pick the country or region.",
                            my: "Stroop Effect။ မင်အရောင်ကို ရွေးပါ။\nပဟေဠိ။ ဂျပန်စာတွင် ကြောင်က အရိပ်အမြွက် ပေးသည်။\nဂျပန် ဗဟုသုတ။ ပထဝီ၊ ယဉ်ကျေးမှု၊ ပွဲတော်၊ အစား၊ ဒဏ္ဍာရီ။\nအန်နီမေ။ မန်ဂါနှင့် ကာတြန်း။\nသဘာဝ။ တိရစ္ဆာန်၊ အပင်၊ နက္ခတ်။\nအစားအသောက်။ ကမ္ဘာ့ဟင်းလျာ။\nကမ္ဘာ့ဗဟုသုတ။ ပထဝီ၊ နေရာကျော်၊ သိပ္ပံ။\nအလံ။ အလံကြည့်ပြီး နိုင်ငံ သို့မဟုတ် ဒေသ ရွေးပါ။"
                        )
                    )
                    guide(
                        tr(ja: "10問と時間", zh: "10 题和时间", en: "10 questions and time", my: "မေးခွန်း ၁၀ နှင့် အချိန်"),
                        tr(
                            ja: "毎回10問。そのうち色と字は1問だけ、残りの9問はひっかけ、各種2択、旗の問題から。制限時間は1問30秒。時間切れは不正解。",
                            zh: "每次 10 题。其中颜色题只随机出 1 道，其余 9 道来自脑筋急转弯、各类二选一和旗帜题。每题 30 秒，超时算错。",
                            en: "Each game has 10 questions. Exactly one is a color-and-word item; the other 9 come from teasers, trivia, and flag quizzes. 30 seconds each; a timeout is a miss.",
                            my: "တစ်ပွဲ ၁၀ ခု။ အရောင်မေးခွန်း ၁ ခုသာ၊ ကျန် ၉ ခုမှာ ပဟေဠိ၊ ဗဟုသုတ ၂ ခုရွေးနှင့် အလံမေးများ။ တစ်ခု ၃၀ စက္ကန့်။"
                        )
                    )
                    guide(
                        tr(ja: "得点とランキング", zh: "得分和排行榜", en: "Score and ranking", my: "ရမှတ်နှင့် အဆင့်"),
                        tr(
                            ja: "正解は1問10点、満点は100点。ランキングは回答にかかった合計時間を表示する。同じ点数なら速い方が上。",
                            zh: "答对一题 10 分，满分 100 分。排行榜显示答题总时间。分数相同则更快的排前面。",
                            en: "Each correct answer is 10 points, 100 in total. The leaderboard shows your answering time. Tied scores rank the faster run first.",
                            my: "မှန်လျှင် တစ်မေးခွန်း ၁၀ မှတ်၊ အပြည့် ၁၀၀။ အဆင့်စာရင်းတွင် ဖြေချိန် စုစုပေါင်းကို ပြသည်။ မှတ်တူရင် ပိုမြန်သူ အပေါ်။"
                        )
                    )
                }
            }
        }
        .sheet(isPresented: $showsRanking) {
            rankingSheet
        }
    }

    private func arcadeShortcut(_ symbol: String, _ title: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 38, height: 38)
                    .background(color.opacity(0.10), in: Circle())
                Text(title)
                    .font(.system(.caption, design: .rounded, weight: .heavy))
                    .foregroundStyle(CatQuizPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(ArcadePressStyle())
    }

    private var rankingSheet: some View {
        let _ = languages.language
        return menuSheet(tr(ja: "ランキング", zh: "排行榜", en: "Leaderboard", my: "အဆင့်စာရင်း"), isPresented: $showsRanking) {
            VStack(alignment: .leading, spacing: 14) {
                ScoreBoardFilterBar(filter: $rankingFilter)
                ScoreBoardList(game: StroopRound.quizGame, rank: .timed, filter: rankingFilter, textColor: CatQuizPalette.wood)
            }
        }
    }

    private func menuSheet<Content: View>(_ title: String, isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) -> some View {
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
                ToolbarItem(placement: .topBarTrailing) {
            Button {
                        isPresented.wrappedValue = false
            } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(CatQuizPalette.wood)
                    }
                    .accessibilityLabel(tr(ja: "閉じる", zh: "关闭", en: "Close", my: "ပိတ်မည်"))
                }
            }
        }
        .preferredColorScheme(.light)
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(28)
        .presentationDragIndicator(.visible)
        .modifier(EdgeBackSwipe(enabled: true) {
            isPresented.wrappedValue = false
        })
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
                        Text(family.chipLabel)
                                .font(showNote ? .caption.weight(.semibold) : .caption2.weight(.semibold))
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                            .foregroundStyle(selected ? CatQuizPalette.ink : CatQuizPalette.wood)
                                .padding(.horizontal, showNote ? 10 : 8)
                                .padding(.vertical, showNote ? 6 : 5)
                                .background {
                                    Capsule().fill(
                                        selected
                                            ? Color(red: 0.98, green: 0.74, blue: 0.32)
                                            : CatQuizPalette.cream
                                    )
                                }
                                .overlay {
                                    Capsule().strokeBorder(CatQuizPalette.wood.opacity(selected ? 0.45 : 0.16), lineWidth: 1)
                        }
                        }
                        .buttonStyle(ArcadePressStyle())
                    .accessibilityIdentifier("stroop-test-task-\(family.rawValue)")
                    }
                }
                Button {
                    session.setTestTimer(!session.testUsesTimer)
                } label: {
                    Label(
                        session.testUsesTimer
                        ? tr(ja: "制限時間：オン", zh: "倒计时：开", en: "Countdown: on", my: "အချိန်ရေတွက်၊ ဖွင့်")
                            : tr(ja: "制限時間：オフ", zh: "倒计时：关", en: "Countdown: off", my: "အချိန်ရေတွက်၊ ပိတ်"),
                        systemImage: session.testUsesTimer ? "timer" : "timer.slash"
                    )
                    .font(.caption.weight(.bold))
                    .foregroundStyle(session.testUsesTimer ? CatQuizPalette.ink : CatQuizPalette.wood)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background {
                        Capsule().fill(
                            session.testUsesTimer
                                ? Color(red: 0.98, green: 0.74, blue: 0.32)
                                : CatQuizPalette.cream
                        )
                    }
                    .overlay {
                        Capsule().strokeBorder(CatQuizPalette.wood.opacity(session.testUsesTimer ? 0.45 : 0.16), lineWidth: 1)
                    }
                }
                .buttonStyle(ArcadePressStyle())
                .accessibilityIdentifier("stroop-test-timer")
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
                    CatQuizHost(
                        hint: tr(
                            ja: "名前をつけてね。自分で書くか、ランダムでもいいよ！",
                            zh: "起个名字吧。可以自己填，也可以随机生成！",
                            en: "Give yourself a name. Type one, or tap random!",
                            my: "နာမည်ပေးပါ။ ကိုယ်တိုင်ရေး သို့မဟုတ် ကျပန်းနှိပ်ပါ။"
                        ),
                        companion: companion
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
                    CatQuizHost(
                        hint: isEditingRename
                            ? tr(
                                ja: "好きな名前に変えてね。この名前がランキングに載るよ！",
                                zh: "改成你想用的名字。这个名字会写进排行榜！",
                                en: "Pick the name you want. It will go on the leaderboard!",
                                my: "လိုချင်သောနာမည်ပြောင်းပါ။ အဆင့်စာရင်းတွင် ပါမည်။"
                            )
                            : tr(
                                ja: "\(session.intelligenceBoast)\n\(session.score)点だったよ。今の名前は「\(session.playerName)」。ランキングに載るよ。名前を変える？",
                                zh: "\(session.intelligenceBoast)\n你得了 \(session.score) 分。现在的名字是「\(session.playerName)」。这个名字会进排行榜。要改名吗？",
                                en: "\(session.intelligenceBoast)\nYou scored \(session.score). Your name is “\(session.playerName)”. It will appear on the leaderboard. Want to change it?",
                                my: "\(session.intelligenceBoast)\n\(session.score) မှတ်ရသည်။ နာမည်က “\(session.playerName)”။ အဆင့်စာရင်းတွင် ပါမည်။ ပြောင်းမလား။",
                                ko: "\(session.intelligenceBoast)\n\(session.score)점이었어요. 지금 이름은 「\(session.playerName)」. 순위에 올라가요. 바꿀까요?",
                                fr: "\(session.intelligenceBoast)\nTu as \(session.score) points. Ton nom est « \(session.playerName) ». Il ira au classement. Tu changes ?",
                                zhHant: "\(session.intelligenceBoast)\n你得了 \(session.score) 分。現在的名字是「\(session.playerName)」。這個名字會進排行榜。要改名嗎？"
                            ),
                        celebrating: session.score >= 40,
                        companion: companion
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
                .fixedSize(horizontal: false, vertical: true)
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
                            WoodlandGhost(
                                title: tr(ja: "名前を変える", zh: "改名", en: "Change name", my: "နာမည်ပြောင်း"),
                                symbol: "pencil"
                            )
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
            Text(tr(ja: "言語", zh: "语言", en: "Language", my: "ဘာသာစကား"))
                .font(.caption.weight(.bold))
                .foregroundStyle(CatQuizPalette.wood)
            LanguagePicker(compact: true)
                .frame(maxWidth: .infinity)
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
                    text: $nameDraft,
                    axis: .vertical
                )
                .lineLimit(1...5)
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
            .onChange(of: nameDraft) { newValue in
                if let cannedNameID, newValue != PlayerNames.display(id: cannedNameID) {
                    self.cannedNameID = nil
                }
            }
            .onChange(of: nameFieldFocused) { focused in
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
                            .id(avatarGroup)
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
            ForEach(Array(items.enumerated()), id: \.offset) { _, emoji in
                Button {
                    chosenAvatar = emoji
                    showsAvatarPicker = false
                } label: {
                    Text(verbatim: emoji)
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
        .frame(maxWidth: .infinity)
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

    private var playfield: some View {
        GeometryReader { geometry in
            Group {
                if session.showsPracticeTools {
                    ScrollView {
                        playfieldStack
                            .padding(.horizontal, 18)
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                            .frame(maxWidth: 560)
                            .frame(width: geometry.size.width, alignment: .top)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                } else {
                    playfieldStack
                        .padding(.horizontal, 18)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .frame(maxWidth: 560)
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                }
            }
            .animation(.easeInOut(duration: 0.22), value: session.roundID)
            .animation(.easeInOut(duration: 0.22), value: session.isReviewing)
            .animation(.easeInOut(duration: 0.22), value: playfieldCatFace)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if session.isReviewing {
                Button { session.continueAfterReview() } label: {
                    WoodlandAction(
                        title: session.isQuizComplete
                            ? tr(ja: "わかった・結果を見る", zh: "知道了，查看结果", en: "Got it — see results", my: "နားလည်ပြီ၊ ရလဒ်ကြည့်မည်")
                            : tr(ja: "わかった・次の問題へ", zh: "知道了，下一题", en: "Got it — next question", my: "နားလည်ပြီ၊ နောက်မေးခွန်း"),
                        symbol: "arrow.right.circle.fill"
                    )
                }
                .buttonStyle(ArcadePressStyle())
                .accessibilityIdentifier("stroop-review-next")
                .padding(.horizontal, 18)
                .padding(.top, 6)
                .padding(.bottom, 10)
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

    private var playfieldStack: some View {
        VStack(spacing: 14) {
            quizHeader
            if session.showsPracticeTools {
                VStack(alignment: .leading, spacing: 8) {
                    testControls(showNote: false)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(WoodlandPanel(cornerRadius: 22))
            }
            questionCard
                .id(session.roundID)
            answers
                .frame(maxHeight: session.showsPracticeTools ? nil : .infinity)
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
                Button {
                    showsProfileEditor = false
                } label: {
                    WoodlandGhost(
                        title: tr(ja: "やめる", zh: "取消", en: "Cancel", my: "မလုပ်တော့"),
                        symbol: "xmark"
                    )
                }
                .buttonStyle(ArcadePressStyle())
                .accessibilityIdentifier("stroop-profile-cancel")
        }
        .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(.keyboard)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .modifier(EdgeBackSwipe(enabled: true) { showsProfileEditor = false })
    }

    private var quizHeader: some View {
        HStack(spacing: 10) {
            Button(action: openProfileEditor) {
                HStack(spacing: 8) {
                    Text(session.playerAvatar)
                        .font(.system(size: 28))
                        .frame(width: 40, height: 40)
                        .background(CatQuizPalette.cream, in: Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(CatQuizPalette.wood.opacity(0.35), lineWidth: 1.2)
                                .allowsHitTesting(false)
                        }
                    Text(session.playerName)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(CatQuizPalette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .accessibilityIdentifier("stroop-player-name")
                }
            }
            .buttonStyle(ArcadePressStyle())
            .accessibilityLabel(tr(ja: "名前とアイコンを変える", zh: "改名字和头像", en: "Change name and avatar", my: "နာမည်နှင့် ပုံ ပြောင်းရန်"))
            .accessibilityIdentifier("stroop-player")
            Spacer(minLength: 8)
            Text(tr(ja: "得点 \(session.score)", zh: "得分 \(session.score)", en: "Score \(session.score)", my: "ရမှတ် \(session.score)", ko: "점수 \(session.score)", fr: "Score \(session.score)", zhHant: "得分 \(session.score)"))
                .font(.subheadline.weight(.black))
                .foregroundStyle(CatQuizPalette.wood)
                .monospacedDigit()
                .modifier(NumericScoreTransition())
                .lineLimit(1)
                .animation(.easeInOut(duration: 0.2), value: session.score)
                .accessibilityIdentifier("stroop-score")
            if session.showsTimer {
                circularTimer
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .modifier(WoodlandPanel(cornerRadius: 20))
    }

    private var circularTimer: some View {
        ZStack {
            Circle().fill(
                LinearGradient(
                    colors: [Color(red: 1, green: 0.97, blue: 0.88), Color(red: 0.98, green: 0.89, blue: 0.72)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            Circle()
                .stroke(CatQuizPalette.wood.opacity(0.16), lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(urgencyColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(secondsLeft)")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(CatQuizPalette.ink)
                .monospacedDigit()
        }
        .frame(width: 44, height: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("stroop-timer")
        .accessibilityLabel(tr(ja: "残り \(secondsLeft) 秒", zh: "还剩 \(secondsLeft) 秒", en: "\(secondsLeft) seconds left", my: "\(secondsLeft) စက္ကန့်ကျန်သည်", ko: "남은 시간 \(secondsLeft)초", fr: "\(secondsLeft) s restantes", zhHant: "還剩 \(secondsLeft) 秒"))
    }

    private var questionIndexText: String {
        let number = session.answerCount + (session.isResolving ? 0 : 1)
        return session.testing ? "Q\(number)" : "Q\(number)/\(StroopRound.quizLength)"
    }

    private var playfieldCatFace: QuizCatFace {
        if session.lastAnswerWasCorrect == true { return .cheer }
        if session.lastMissWasTimeout { return .surprised }
        if session.isReviewingMistake { return .sad }
        if session.isReviewing { return .thinking }
        if session.showsTimer, session.questionRemaining <= urgentRemaining { return .surprised }
        return .happy
    }

    private var resultCatFace: QuizCatFace {
        if session.score >= 80 { return .cheer }
        if session.score >= 40 { return .happy }
        if session.score == 0 { return .sad }
        return .curious
    }

    private var questionCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                QuizCatPortrait(face: playfieldCatFace, width: 68, height: 54,
                                companion: companion, accessibilityID: "stroop-play-cat")
                VStack(alignment: .leading, spacing: 6) {
                    Text(questionIndexText)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(CatQuizPalette.wood)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(CatQuizPalette.cream, in: Capsule())
                        .overlay { Capsule().strokeBorder(CatQuizPalette.wood.opacity(0.2), lineWidth: 1) }
                    questionBanner
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            if session.round.task == .colorWord || session.round.task == .flag {
                stimulusPanel
            }
            if session.isReviewing {
                answerExplanation
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(WoodlandPanel(cornerRadius: 24))
    }

    private var questionBanner: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.round.rule)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(CatQuizPalette.ink)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("stroop-answer-\(session.round.answerID)")
        .accessibilityLabel("\(questionIndexText) \(session.round.rule)")
    }

    private var answerExplanation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            Label(
                explanationTitle,
                systemImage: "lightbulb.fill"
            )
            .font(.headline)
            Text(session.round.answerExplanation)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("stroop-explanation")
            Label(tr(ja: "読んでいる間は時間が止まります", zh: "讲解期间暂停计时", en: "The timer is paused while you read", my: "ဖတ်နေစဉ် အချိန်ရပ်ထားသည်"), systemImage: "pause.circle")
                .font(.caption)
        }
        .foregroundStyle(CatQuizPalette.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
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

    private var urgentRemaining: TimeInterval {
        min(3, session.questionLimit * 0.4)
    }

    private var warningRemaining: TimeInterval {
        session.questionLimit * 0.6
    }

    private var progress: CGFloat {
        CGFloat(min(1, max(0, session.questionRemaining / session.questionLimit)))
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
        return HStack(spacing: 12) {
            ForEach(Array(session.round.choices.enumerated()), id: \.element.id) { index, choice in
                choiceCard(choice, mark: marks[index])
            }
        }
    }

    private func choiceCard(_ choice: AnswerChoice, mark: String) -> some View {
        let isAnswer = session.isResolving && choice.id == session.round.answerID
        let isMiss = session.isReviewingMistake && session.selectedChoiceID == choice.id
        return Button { session.choose(choice.id) } label: {
            VStack(spacing: 10) {
                HStack {
                    Text(mark)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(CatQuizPalette.wood)
                        .frame(width: 28, height: 28)
                        .background(CatQuizPalette.cream, in: Circle())
                        .overlay { Circle().strokeBorder(CatQuizPalette.wood.opacity(0.28), lineWidth: 1) }
                    Spacer()
                    if isAnswer {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.24))
                    } else if isMiss {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color(red: 0.75, green: 0.15, blue: 0.2))
                    }
                }
                choiceVisual(choice)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: session.isReviewing ? 48 : 64)
                    .frame(maxHeight: session.isReviewing ? 84 : 110)
                if isAnswer {
                    Text(tr(ja: "正解", zh: "正确答案", en: "Correct answer", my: "အဖြေမှန်"))
                        .font(.caption.bold())
                        .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.24))
                } else if isMiss {
                    Text(tr(ja: "選んだ答え", zh: "你的选择", en: "Your choice", my: "သင်ရွေးသောအဖြေ"))
                        .font(.caption.bold())
                        .foregroundStyle(Color(red: 0.75, green: 0.15, blue: 0.2))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .frame(minHeight: session.isReviewing ? 132 : 168)
            .modifier(WoodlandPanel(cornerRadius: 22))
        }
        .buttonStyle(ArcadePressStyle())
        .disabled(session.isResolving || session.answersLocked)
        .scaleEffect(isAnswer ? 1.02 : 1)
        .animation(.spring(response: 0.32, dampingFraction: 0.72), value: session.isResolving)
        .overlay {
            if isAnswer || isMiss {
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(isAnswer ? Color(red: 0.18, green: 0.62, blue: 0.38) : Color(red: 0.86, green: 0.22, blue: 0.28), lineWidth: 3)
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
                resultScoreCard

                VStack(spacing: 12) {
                    Button { session.start() } label: {
                        WoodlandAction(title: tr(ja: "もう一度あそぶ", zh: "再玩一次", en: "Play again", my: "နောက်တစ်ပွဲ"), symbol: "arrow.clockwise")
                    }
                    .buttonStyle(ArcadePressStyle())
                    .accessibilityIdentifier("stroop-play-again")
                    Button { session.returnToMenu() } label: {
                        WoodlandGhost(
                            title: tr(ja: "スタート画面へ", zh: "返回首页", en: "Back to start", my: "အစသို့ ပြန်ရန်"),
                            symbol: "house.fill"
                        )
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
            QuizCatPortrait(face: resultCatFace, height: 84,
                            companion: companion, accessibilityID: "stroop-result-pet")
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
            Divider().overlay(CatQuizPalette.wood.opacity(0.2))
            Text(session.boastHeadline)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(CatQuizPalette.ink)
                .multilineTextAlignment(.center)
            ForEach(Array(session.boastRivalNames.enumerated()), id: \.offset) { _, name in
                Text(name)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(CatQuizPalette.wood)
                    .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .modifier(WoodlandPanel())
        .accessibilityIdentifier("stroop-result-cat")
    }

    private var resultRanking: some View {
        let rows = ScoreBoard.records(for: StroopRound.quizGame, filter: rankingFilter)
        return VStack(alignment: .leading, spacing: 12) {
            Label(tr(ja: "ランキング", zh: "排行榜", en: "Leaderboard", my: "အဆင့်စာရင်း"), systemImage: "crown.fill")
                .font(.system(.headline, design: .rounded, weight: .bold))
            ScoreBoardFilterBar(filter: $rankingFilter)
            if rows.isEmpty {
                Text(tr(ja: "まだ記録がない", zh: "还没有记录", en: "No scores yet", my: "မှတ်တမ်းမရှိသေးပါ"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CatQuizPalette.wood.opacity(0.72))
            }
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, record in
                HStack(spacing: 10) {
                    Text("\(index + 1)")
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .frame(width: 28, height: 28)
                        .background(rankBadge(index), in: Circle())
                    if !record.avatar.isEmpty {
                        Text(record.avatar)
                            .font(.title3)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        if !record.name.isEmpty {
                            Text(record.name)
                                .font(.system(.subheadline, design: .rounded, weight: index == 0 ? .heavy : .semibold))
                                .fixedSize(horizontal: false, vertical: true)
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

    private func rankBadge(_ index: Int) -> Color {
        switch index {
        case 0: Color(red: 0.98, green: 0.78, blue: 0.22)
        case 1: Color(red: 0.78, green: 0.82, blue: 0.86)
        case 2: Color(red: 0.90, green: 0.68, blue: 0.42)
        default: CatQuizPalette.cream
        }
    }

}

private struct WoodlandPanel: ViewModifier {
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 1, green: 0.97, blue: 0.88), Color(red: 0.98, green: 0.89, blue: 0.72)], startPoint: .top, endPoint: .bottom))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color(red: 0.67, green: 0.40, blue: 0.20).opacity(0.85), lineWidth: 1.5)
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: max(4, cornerRadius - 3), style: .continuous)
                    .strokeBorder(Color(red: 1, green: 0.99, blue: 0.92).opacity(0.85), lineWidth: 1.2)
                    .padding(4)
                    .allowsHitTesting(false)
            }
            .shadow(color: CatQuizPalette.wood.opacity(0.18), radius: 10, y: 5)
    }
}

private struct WoodlandAction: View {
    let title: String
    let symbol: String
    var body: some View {
        HStack(spacing: 10) {
            Spacer(minLength: 0)
            Label(title, systemImage: symbol)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.65).lineLimit(1)
            Spacer(minLength: 0)
        }
        .foregroundStyle(CatQuizPalette.wood)
        .padding(.horizontal, 20).padding(.vertical, 16)
        .background(LinearGradient(colors: [Color(red: 1, green: 0.93, blue: 0.46), Color(red: 1, green: 0.72, blue: 0.24)], startPoint: .top, endPoint: .bottom), in: Capsule())
        .overlay { Capsule().strokeBorder(CatQuizPalette.wood.opacity(0.55), lineWidth: 1.5) }
        .overlay(alignment: .top) {
            Capsule().fill(Color.white.opacity(0.38))
                .frame(height: 7)
                .padding(.horizontal, 22)
                .padding(.top, 5)
        }
        .shadow(color: CatQuizPalette.wood.opacity(0.28), radius: 8, y: 4)
    }
}

private struct WoodlandGhost: View {
    let title: String
    let symbol: String
    var body: some View {
        Label(title, systemImage: symbol)
            .font(.system(.headline, design: .rounded, weight: .bold))
            .foregroundStyle(CatQuizPalette.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(CatQuizPalette.cream.opacity(0.94), in: Capsule())
            .overlay { Capsule().strokeBorder(CatQuizPalette.wood.opacity(0.2), lineWidth: 1.5) }
    }
}

private struct EdgeBackSwipe: ViewModifier {
    var enabled: Bool
    var action: () -> Void

    func body(content: Content) -> some View {
        content.overlay(alignment: .leading) {
            if enabled {
                Color.clear
                    .frame(width: 28)
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 12)
                            .onEnded { value in
                                if value.translation.width > 70, abs(value.translation.height) < 120 {
                                    action()
                                }
                            }
                    )
                    .accessibilityHidden(true)
            }
        }
    }
}

private struct AnswerSensoryFeedback: ViewModifier {
    var correct: Int
    var answers: Int

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .sensoryFeedback(.success, trigger: correct)
                .sensoryFeedback(.error, trigger: answers - correct)
        } else {
            content
        }
    }
}

private struct NumericScoreTransition: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.contentTransition(.numericText())
        } else {
            content
        }
    }
}

private struct ArcadePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .offset(y: configuration.isPressed ? 2 : 0)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
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
                CatRoomBackdrop()
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
