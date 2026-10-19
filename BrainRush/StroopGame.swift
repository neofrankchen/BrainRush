import SwiftUI
import AVFoundation

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case japanese
    case chinese
    case english
    case burmese

    var id: String { rawValue }

    var label: String {
        switch self {
        case .japanese: "日本語"
        case .chinese: "中文"
        case .english: "English"
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

func tr(ja: String, zh: String, en: String, my: String) -> String {
    let language = MainActor.assumeIsolated { LanguageStore.shared.language }
    switch language {
    case .japanese: return ja
    case .chinese: return zh
    case .english: return en
    case .burmese: return my
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
                .foregroundStyle(selected == language ? .black : .white)
                .padding(.horizontal, compact ? 8 : 12)
                .padding(.vertical, compact ? 4 : 6)
                .background {
                    Capsule().fill(
                        selected == language
                            ? Color(red: 0.98, green: 0.74, blue: 0.32)
                            : Color.white.opacity(0.08)
                    )
                }
                .accessibilityAddTraits(selected == language ? .isSelected : [])
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
    case arrowPlace
    case wordPlace
    case numberCount
    case valueSize

    var title: String {
        switch self {
        case .colorWord: tr(ja: "色と字", zh: "色和字", en: "Color and word", my: "အရောင်နှင့် စာသား")
        case .arrowPlace: tr(ja: "向きと位置", zh: "方向和位置", en: "Direction and place", my: "ဦးတည်ချက်နှင့် နေရာ")
        case .wordPlace: tr(ja: "文字と位置", zh: "字和位置", en: "Word and place", my: "စာလုံးနှင့် နေရာ")
        case .numberCount: tr(ja: "数字と個数", zh: "数字和数量", en: "Number and count", my: "ဂဏန်းနှင့် အရေအတွက်")
        case .valueSize: tr(ja: "数値と大きさ", zh: "数值和字号", en: "Value and size", my: "တန်ဖိုးနှင့် အရွယ်")
        }
    }

    var chipTitle: String {
        switch self {
        case .colorWord: tr(ja: "色", zh: "颜色", en: "Color", my: "အရောင်")
        case .arrowPlace: tr(ja: "矢印", zh: "箭头", en: "Arrow", my: "မြား")
        case .wordPlace: tr(ja: "位置", zh: "方位", en: "Place", my: "နေရာ")
        case .numberCount: tr(ja: "個数", zh: "数量", en: "Count", my: "အရေအတွက်")
        case .valueSize: tr(ja: "大きさ", zh: "大小", en: "Size", my: "အရွယ်")
        }
    }
}

enum StroopColor: String, CaseIterable {
    case red, orange, yellow, green, blue, purple

    var name: String {
        switch self {
        case .red: tr(ja: "赤", zh: "红", en: "Red", my: "အနီ")
        case .orange: tr(ja: "橙", zh: "橙", en: "Orange", my: "လိမ္မော်")
        case .yellow: tr(ja: "黄", zh: "黄", en: "Yellow", my: "အဝါ")
        case .green: tr(ja: "緑", zh: "绿", en: "Green", my: "အစိမ်း")
        case .blue: tr(ja: "青", zh: "蓝", en: "Blue", my: "အပြာ")
        case .purple: tr(ja: "紫", zh: "紫", en: "Purple", my: "ခရမ်း")
        }
    }

    var color: Color {
        switch self {
        case .red: Color(red: 0.95, green: 0.28, blue: 0.32)
        case .orange: Color(red: 0.98, green: 0.52, blue: 0.16)
        case .yellow: Color(red: 0.98, green: 0.82, blue: 0.28)
        case .green: Color(red: 0.30, green: 0.82, blue: 0.48)
        case .blue: Color(red: 0.32, green: 0.56, blue: 0.98)
        case .purple: Color(red: 0.64, green: 0.38, blue: 0.96)
        }
    }
}

enum Compass: String, CaseIterable {
    case up, down, left, right

    var name: String {
        switch self {
        case .up: tr(ja: "上", zh: "上", en: "Up", my: "အပေါ်")
        case .down: tr(ja: "下", zh: "下", en: "Down", my: "အောက်")
        case .left: tr(ja: "左", zh: "左", en: "Left", my: "ဘယ်")
        case .right: tr(ja: "右", zh: "右", en: "Right", my: "ညာ")
        }
    }

    var symbol: String {
        switch self {
        case .up: "arrow.up"
        case .down: "arrow.down"
        case .left: "arrow.left"
        case .right: "arrow.right"
        }
    }

    var offset: CGSize {
        switch self {
        case .up: CGSize(width: 0, height: -88)
        case .down: CGSize(width: 0, height: 88)
        case .left: CGSize(width: -88, height: 0)
        case .right: CGSize(width: 88, height: 0)
        }
    }

    var quizOffset: CGSize {
        switch self {
        case .up: CGSize(width: 0, height: -48)
        case .down: CGSize(width: 0, height: 48)
        case .left: CGSize(width: -52, height: 0)
        case .right: CGSize(width: 52, height: 0)
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
    var slot: Compass? = nil
    var badge: String? = nil
}

enum Stimulus: Equatable {
    case word(StroopColor, ink: StroopColor)
    case placedArrow(direction: Compass, place: Compass)
    case placedWord(word: Compass, place: Compass)
    case digits(value: Int, count: Int)
    case pair(left: Int, right: Int, leftUsesLargerFont: Bool)
}

struct StroopRound: Equatable {
    var task: InterferenceTask
    var rule: String
    var answerID: String
    var choices: [AnswerChoice]
    var stimulus: Stimulus

    static func make(_ task: InterferenceTask, trap: Bool = false) -> StroopRound {
        switch task {
        case .colorWord: colorWord(trap: trap)
        case .arrowPlace: arrowPlace(trap: trap)
        case .wordPlace: wordPlace(trap: trap)
        case .numberCount: numberCount(trap: trap)
        case .valueSize: valueSize(trap: trap)
        }
    }

    private static func colorWord(trap: Bool) -> StroopRound {
        let ink = StroopColor.allCases.randomElement() ?? .red
        let word = other(ink, in: StroopColor.allCases)
        let answer = trap ? word : ink
        return StroopRound(
            task: .colorWord,
            rule: trap
                ? tr(ja: "見えている文字を選べ", zh: "选择你看到的文字", en: "Choose the text you see", my: "မြင်ရသော စာသားကို ရွေးပါ")
                : tr(ja: "見えている色を選べ", zh: "选择你看到的颜色", en: "Choose the color you see", my: "မြင်ရသော အရောင်ကို ရွေးပါ"),
            answerID: answer.rawValue,
            choices: colorPair(ink: ink, word: word),
            stimulus: .word(word, ink: ink)
        )
    }

    private static func arrowPlace(trap: Bool) -> StroopRound {
        let direction = Compass.allCases.randomElement() ?? .right
        let place = other(direction, in: Compass.allCases)
        return StroopRound(
            task: .arrowPlace,
            rule: trap
                ? tr(ja: "矢印がある場所を選べ", zh: "选出箭头在哪一边", en: "Pick the side where the arrow sits", my: "မြားရှိသောဘက်ကို ရွေးပါ")
                : tr(ja: "矢印が指している方を選べ", zh: "选出箭头指向哪一边", en: "Pick the side the arrow points to", my: "မြားညွှန်သောဘက်ကို ရွေးပါ"),
            answerID: (trap ? place : direction).rawValue,
            choices: compassPair(direction, place, showArrow: true),
            stimulus: .placedArrow(direction: direction, place: place)
        )
    }

    private static func wordPlace(trap: Bool) -> StroopRound {
        let word = Compass.allCases.randomElement() ?? .down
        let place = other(word, in: Compass.allCases)
        return StroopRound(
            task: .wordPlace,
            rule: trap
                ? tr(ja: "字がある場所を選べ", zh: "选出字在哪一边", en: "Pick the side where the word sits", my: "စာလုံးရှိသောဘက်ကို ရွေးပါ")
                : tr(ja: "書いてある字を選べ", zh: "选出字写的是什么", en: "Pick what the word says", my: "ရေးထားသော စာလုံးကို ရွေးပါ"),
            answerID: (trap ? place : word).rawValue,
            choices: compassPair(word, place, showArrow: false),
            stimulus: .placedWord(word: word, place: place)
        )
    }

    private static func numberCount(trap: Bool) -> StroopRound {
        // Interference: the written number as shown (数字, e.g. 111) vs the count (数量, e.g. 3).
        let count = Int.random(in: 2...4)
        let value = other(count, in: Array(1...9))
        let shown = String(repeating: "\(value)", count: count)
        return StroopRound(
            task: .numberCount,
            rule: trap
                ? tr(ja: "数字は何個ある？", zh: "有几个数字？", en: "How many digits are there?", my: "ဂဏန်း ဘယ်နှစ်လုံး ရှိသလဲ။")
                : tr(ja: "数字は？", zh: "数字是几？", en: "What is the number?", my: "ဂဏန်းက ဘယ်လဲ။"),
            answerID: trap ? "\(count)" : shown,
            choices: numberChoices(shown: shown, count: count),
            stimulus: .digits(value: value, count: count)
        )
    }

    private static func numberChoices(shown: String, count: Int) -> [AnswerChoice] {
        [shown, "\(count)"].shuffled().map {
            AnswerChoice(id: $0, title: $0, symbol: nil, style: .neutral)
        }
    }

    private static func valueSize(trap: Bool) -> StroopRound {
        let smaller = Int.random(in: 1...8)
        let larger = smaller + (smaller == 8 ? 1 : Int.random(in: 1...2))
        let largerOnLeft = Bool.random()
        let left = largerOnLeft ? larger : smaller
        let right = largerOnLeft ? smaller : larger
        let leftUsesLargerFont = left < right
        let numericSide = largerOnLeft ? "left" : "right"
        let visualSide = leftUsesLargerFont ? "left" : "right"
        return StroopRound(
            task: .valueSize,
            rule: trap
                ? tr(ja: "字が大きい方を選べ", zh: "选出字体更大的一边", en: "Pick the side with bigger text", my: "စာလုံးပိုကြီးသောဘက်ကို ရွေးပါ")
                : tr(ja: "数の大きい方を選べ", zh: "选出数值更大的一边", en: "Pick the side with the larger number", my: "ကိန်းပိုကြီးသောဘက်ကို ရွေးပါ"),
            answerID: trap ? visualSide : numericSide,
            choices: [
                AnswerChoice(id: "left", title: tr(ja: "左", zh: "左边", en: "Left", my: "ဘယ်ဘက်"), symbol: nil, style: .neutral),
                AnswerChoice(id: "right", title: tr(ja: "右", zh: "右边", en: "Right", my: "ညာဘက်"), symbol: nil, style: .neutral),
            ],
            stimulus: .pair(left: left, right: right, leftUsesLargerFont: leftUsesLargerFont)
        )
    }

    private static func colorPair(ink: StroopColor, word: StroopColor) -> [AnswerChoice] {
        [ink, word].shuffled().map { color in
            AnswerChoice(id: color.rawValue, title: color.name, symbol: nil, style: .ink(color))
        }
    }

    private static func compassPair(_ first: Compass, _ second: Compass, showArrow: Bool) -> [AnswerChoice] {
        [first, second].shuffled().map { direction in
            AnswerChoice(
                id: direction.rawValue,
                title: direction.name,
                symbol: showArrow ? direction.symbol : nil,
                style: .neutral
            )
        }
    }

    private static func other<T: Equatable>(_ value: T, in pool: [T]) -> T {
        pool.filter { $0 != value }.randomElement() ?? value
    }

}

private enum StroopCue {
    case correct
    case wrong
    case timeout
    case heart
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
                .heart: Self.notes([(523, 0, 0.32), (659, 0.08, 0.36), (880, 0.16, 0.4)], seconds: 0.36, noise: 0, format: format),
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
        case playing
        case finished
    }

    private let audio = StroopAudio()

    private(set) var phase: Phase = .ready
    private(set) var round = StroopRound.make(.colorWord)
    private(set) var score = 0
    private(set) var streak = 0
    private(set) var hearts = 3
    private(set) var heartGain = 0
    private(set) var correctCount = 0
    private(set) var answerCount = 0
    private(set) var questionRemaining: TimeInterval = 10
    private(set) var questionLimit: TimeInterval = 10
    private(set) var lastAnswerWasCorrect: Bool?
    private(set) var lastMissWasTimeout = false
    private(set) var isResolving = false
    private(set) var selectedChoiceID: String?
    private(set) var roundID = UUID()
    private(set) var testing = false
    private(set) var testUsesTimer = false
    private(set) var testTask: InterferenceTask = .colorWord
    private var testTrap = false
    private var questionEndsAt: Date?
    private var previousTrial: ScriptedTrial?

    private struct ScriptedTrial {
        var task: InterferenceTask
        var trap: Bool
    }

    var showsTimer: Bool {
        !testing || testUsesTimer
    }

    var accuracyText: String {
        guard answerCount > 0 else { return tr(ja: "まだ回答がない", zh: "还没有作答", en: "No answers yet", my: "အဖြေမရှိသေးပါ") }
        let percent = Int((Double(correctCount) / Double(answerCount) * 100).rounded())
        return tr(
            ja: "正解 \(correctCount) / \(answerCount)、正解率 \(percent)%",
            zh: "答对 \(correctCount) / \(answerCount)，正确率 \(percent)%",
            en: "Correct \(correctCount) / \(answerCount), \(percent)%",
            my: "မှန် \(correctCount) / \(answerCount)၊ မှန်ကန်နှုန်း \(percent)%"
        )
    }

    func start() {
        previousTrial = nil
        score = 0
        streak = 0
        hearts = 3
        heartGain = 0
        correctCount = 0
        answerCount = 0
        questionLimit = 10
        questionRemaining = 10
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
        isResolving = true
        selectedChoiceID = timeout ? nil : id
        questionEndsAt = nil
        answerCount += 1
        if !timeout && id == round.answerID {
            streak += 1
            correctCount += 1
            score += 10 + min(streak - 1, 5) * 2
            if !testing, streak.isMultiple(of: 3) {
                hearts += 1
                heartGain += 1
                audio.play(.heart)
            } else {
                audio.play(.correct)
            }
            if !testing {
                questionLimit = max(5, questionLimit - 1)
            }
            lastAnswerWasCorrect = true
            lastMissWasTimeout = false
        } else {
            streak = 0
            if !testing {
                hearts -= 1
                questionLimit = 10
            }
            lastAnswerWasCorrect = false
            lastMissWasTimeout = timeout
            audio.play(timeout ? .timeout : .wrong)
        }
        let answeredRound = roundID
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(650))
            guard phase == .playing, roundID == answeredRound else { return }
            if !testing, hearts <= 0 {
                hearts = 0
                ScoreBoard.submit(game: "stroop", score: score, rank: .high)
                phase = .finished
                isResolving = false
            } else {
                deal()
            }
        }
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
            testUsesTimer = false
            questionLimit = 10
        }
        guard phase == .playing else { return }
        deal()
    }

    func setTestTimer(_ on: Bool) {
        testUsesTimer = on
        guard phase == .playing, testing else { return }
        if on {
            questionLimit = 10
            questionEndsAt = Date().addingTimeInterval(questionLimit)
            questionRemaining = questionLimit
        } else {
            questionEndsAt = nil
            questionRemaining = questionLimit
        }
    }

    func selectTestTask(_ task: InterferenceTask) {
        testTask = task
        guard phase == .playing, testing else { return }
        deal()
    }

    func flipTestQuestion() {
        testTrap.toggle()
        guard phase == .playing, testing else { return }
        deal()
    }

    func applyTestLanguage() {
        guard phase == .playing, testing else { return }
        deal()
    }

    private func deal() {
        roundID = UUID()
        isResolving = false
        selectedChoiceID = nil
        lastAnswerWasCorrect = nil
        lastMissWasTimeout = false
        let trial = nextTrial()
        var next = StroopRound.make(trial.task, trap: trial.trap)
        var tries = 0
        while next.stimulus == round.stimulus && tries < 6 {
            next = StroopRound.make(trial.task, trap: trial.trap)
            tries += 1
        }
        round = next
        questionRemaining = questionLimit
        if showsTimer {
            questionEndsAt = Date().addingTimeInterval(questionLimit)
        } else {
            questionEndsAt = nil
        }
    }

    private func nextTrial() -> ScriptedTrial {
        if testing {
            let trial = ScriptedTrial(task: testTask, trap: testTrap)
            previousTrial = trial
            return trial
        }
        let task = InterferenceTask.allCases.randomElement() ?? .colorWord
        let trap: Bool
        if previousTrial?.task == task {
            trap = !(previousTrial?.trap ?? false)
        } else {
            trap = Bool.random()
        }
        let trial = ScriptedTrial(task: task, trap: trap)
        previousTrial = trial
        return trial
    }
}

struct StroopGameView: View {
    @State private var session = StroopSession()
    @State private var showsGuide = false
    @State private var showsPractice = false
    @State private var showsRanking = false

    var body: some View {
        Group {
            switch session.phase {
            case .ready:
                menu
            case .playing:
                playfield
            case .finished:
                result
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StroopBackdrop(light: session.phase == .playing))
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
            session.applyTestLanguage()
        }
        .sensoryFeedback(.success, trigger: session.correctCount)
        .sensoryFeedback(.increase, trigger: session.heartGain)
        .sensoryFeedback(.error, trigger: session.answerCount - session.correctCount)
        .overlay {
            HeartGainPop(token: session.heartGain)
        }
    }

    private var menu: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color(red: 0.07, green: 0.10, blue: 0.30).ignoresSafeArea()
                Image("StartScreenArt")
                    .resizable()
                    .ignoresSafeArea(.container, edges: .all)
                    .accessibilityLabel("Brain Rush — ブレインラッシュ")
                ScrollView {
                    VStack(spacing: 18) {
                        HStack {
                            Spacer()
                            Button { showsPractice = true } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .padding(12)
                                    .background(.white.opacity(0.2), in: Circle())
                                    .overlay { Circle().strokeBorder(.white.opacity(0.35), lineWidth: 2) }
                            }
                            .accessibilityLabel(tr(ja: "設定", zh: "设置", en: "Settings", my: "ဆက်တင်"))
                        }
                        Spacer(minLength: max(220, geometry.size.height * 0.52))
                        Button { session.start() } label: {
                            HStack(spacing: 16) {
                                Text("START").font(.system(size: 38, weight: .black, design: .rounded))
                                Image(systemName: "play.fill").font(.system(size: 28, weight: .black))
                            }
                            .foregroundStyle(Color(red: 0.04, green: 0.07, blue: 0.22))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background {
                                Capsule().fill(LinearGradient(colors: [Color(red: 1, green: 0.94, blue: 0.37), .yellow, .orange], startPoint: .top, endPoint: .bottom))
                            }
                            .overlay { Capsule().strokeBorder(.white.opacity(0.75), lineWidth: 3).padding(4) }
                            .padding(6)
                            .background(Capsule().fill(Color(red: 0.03, green: 0.05, blue: 0.18)))
                            .overlay { Capsule().strokeBorder(Color(red: 0.36, green: 0.50, blue: 1), lineWidth: 3) }
                            .shadow(color: .black.opacity(0.4), radius: 0, y: 7)
                        }
                        .buttonStyle(ArcadePressStyle())
                        .accessibilityIdentifier("stroop-start")
                        .accessibilityLabel(tr(ja: "開始", zh: "开始", en: "Start", my: "စတင်မည်"))
                        HStack(spacing: 10) {
                            arcadeShortcut("crown.fill", tr(ja: "ランキング", zh: "排行榜", en: "Ranking", my: "အဆင့်"), .yellow) { showsRanking = true }
                            arcadeShortcut("chart.bar.fill", tr(ja: "遊び方", zh: "怎么玩", en: "How to play", my: "ကစားနည်း"), .cyan) { showsGuide = true }
                            arcadeShortcut("gearshape.fill", tr(ja: "設定", zh: "设置", en: "Settings", my: "ဆက်တင်"), .white) { showsPractice = true }
                        }
                        .padding(.top, 10)
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 8)
                    .frame(maxWidth: 520)
                    .frame(minHeight: geometry.size.height)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .foregroundStyle(.white)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showsGuide) {
            menuSheet(tr(ja: "遊び方", zh: "怎么玩", en: "How to play", my: "ကစားနည်း")) {
                VStack(alignment: .leading, spacing: 24) {
                    guide(
                        tr(ja: "遊び方", zh: "怎么玩", en: "How to play", my: "ကစားနည်း"),
                        tr(
                            ja: "画面には、くい違う手がかりが2つ同時に出ます。問題文を読んで、そのとおりに選んでください。見た瞬間の感覚で押すと間違えやすくなります。",
                            zh: "画面上会同时出现两个互相矛盾的线索。请读完题目，按题目的要求点选。跟着第一眼的感觉去按，很容易按错。",
                            en: "Two conflicting cues appear at once. Read the question and answer exactly what it asks. Going with your first glance is an easy way to miss.",
                            my: "မျက်နှာပြင်မှာ ဆန့်ကျင်နေတဲ့ လမ်းညွှန်နှစ်ခု တစ်ပြိုင်နက် ပေါ်သည်။ မေးခွန်းကို ဖတ်ပြီး မေးထားသည့်အတိုင်း ရွေးပါ။ ပထမတစ်ချက်မြင်တာနဲ့ နှိပ်ရင် မှားလွယ်သည်။"
                        )
                    )
                    guide(
                        tr(ja: "5種類の問題", zh: "五种题目", en: "Five kinds of questions", my: "မေးခွန်း ၅ မျိုး"),
                        tr(
                            ja: "どの問題も二択です。\n色：見えている色か、見えている文字か。文字の意味とインクの色は違います。\n矢印：指している方か、矢印がある場所か。向きと場所は違います。\n文字の位置：書いてある字か、字がある場所か。意味と場所は違います。\n数字と個数：例えば画面が111なら、選択肢は111と3。「数字は？」なら111、「数字は何個ある？」なら3。並びと個数は違います。\n大きさ：数の大きい方か、字の大きい方か。差は1か2で、字が大きいのは数の小さい方です。",
                            zh: "每道题都是二选一。\n颜色：看到的颜色，还是看到的文字。字义和墨水颜色不会相同。\n箭头：箭头指向哪一边，还是箭头在哪一边。指向和位置不会相同。\n方位字：字写的是什么，还是字在哪一边。字义和位置不会相同。\n数字和数量：例如画面是 111，选项是 111 和 3。问「数字是几？」选 111，问「有几个数字？」选 3。数字串和数量不会相同。\n大小：数值更大的一边，还是字体更大的一边。两数只差 1 或 2，字更大的是数值更小的那个。",
                            en: "Every question is a two-choice pick.\nColor: the color you see, or the text you see. The word and the ink never match.\nArrow: the side it points to, or the side where it sits. Direction and place never match.\nPlace word: what the word says, or the side where it sits. Meaning and place never match.\nNumber and count: if the screen shows 111, the choices are 111 and 3. \"What is the number?\" means 111. \"How many digits are there?\" means 3. The written number and the count never match.\nSize: the larger number, or the bigger text. The numbers differ by 1 or 2, and the bigger text is the smaller number.",
                            my: "မေးခွန်းတိုင်းကို ရွေးစရာ ၂ ခုသာ ပေးသည်။\nအရောင်။ မြင်ရသော အရောင်၊ သို့မဟုတ် မြင်ရသော စာသား။ စာသားအဓိပ္ပာယ်နှင့် မင်အရောင် မတူပါ။\nမြား။ ညွှန်သောဘက်၊ သို့မဟုတ် မြားရှိသောဘက်။ ဦးတည်ချက်နှင့် နေရာ မတူပါ။\nနေရာစာလုံး။ ရေးထားသောစာလုံး၊ သို့မဟုတ် စာလုံးရှိသောဘက်။ အဓိပ္ပာယ်နှင့် နေရာ မတူပါ။\nဂဏန်းနှင့် အရေအတွက်။ ဥပမာ မျက်နှာပြင်မှာ ၁၁၁ ဖြစ်လျှင် ရွေးစရာက ၁၁၁ နှင့် ၃။ \"ဂဏန်းက ဘယ်လဲ\" ဆိုရင် ၁၁၁၊ \"ဂဏန်း ဘယ်နှစ်လုံး ရှိသလဲ\" ဆိုရင် ၃။ ရေးထားသောကိန်းနှင့် အရေအတွက် မတူပါ။\nအရွယ်။ ကိန်းပိုကြီးသောဘက်၊ သို့မဟုတ် စာလုံးပိုကြီးသောဘက်။ ကိန်းနှစ်ခုက ၁ သို့မဟုတ် ၂ ပဲ ကွာပြီး စာလုံးပိုကြီးတာက ကိန်းပိုငယ်သောဘက် ဖြစ်သည်။"
                        )
                    )
                    guide(
                        tr(ja: "出る順番", zh: "出题顺序", en: "Order", my: "ထွက်ပုံ"),
                        tr(
                            ja: "5種類の問題は毎回ランダムに出ます。同じ種類が続くと、問い方が変わります。",
                            zh: "五种题目每次都会随机出现。同一类题如果接着出现，问法会换成另一种。",
                            en: "All five kinds of questions appear at random. If the same kind appears again, the question flips.",
                            my: "မေးခွန်း ၅ မျိုးကို တစ်ကြိမ်ချင်း အလျှောက်ကျကျ ထုတ်သည်။ တစ်မျိုးတည်း ဆက်ထွက်လျှင် မေးပုံ ပြောင်းသည်။"
                        )
                    )
                    guide(
                        tr(ja: "ハートと時間", zh: "爱心和时间", en: "Hearts and time", my: "နှလုံးနှင့် အချိန်"),
                        tr(
                            ja: "ハートは3つから始まります。不正解か時間切れで1つ減り、0になると終了です。3問連続で正解すると1つ増えます。\n最初の制限時間は10秒です。連続で正解するたびに、次の問題が1秒短くなり、最短は5秒です。不正解か時間切れのあと、次の問題は10秒に戻ります。残りわずかになると、バーが赤くなって点滅します。正解は高い音、不正解は低い音、時間切れは下がる音です。ハートが増えるときは明るい音が鳴ります。",
                            zh: "开局有 3 颗爱心。答错或超时扣 1 颗，减到 0 就结束。连续答对 3 题加 1 颗。\n第一题 10 秒。每连续答对一题，下一题少 1 秒，最短 5 秒。答错或超时之后，下一题回到 10 秒。时间所剩不多时，进度条会变红并闪动。答对是高音，答错是低音，超时是向下的音。加上爱心时会响一声更亮的音。",
                            en: "You start with 3 hearts. A miss or a timeout removes 1, and the game ends at 0. Three correct answers in a row add 1.\nThe first question lasts 10 seconds. Each correct answer in a row makes the next question 1 second shorter, down to 5. After a miss or a timeout, the next question returns to 10 seconds. When little time is left, the bar turns red and pulses. A correct answer plays a high note, a miss plays a low note, and a timeout plays a falling note. Gaining a heart plays a brighter chime.",
                            my: "နှလုံး ၃ ခုဖြင့် စသည်။ မှားလျှင် သို့မဟုတ် အချိန်ကုန်လျှင် ၁ ခုလျော့ပြီး ၀ ဖြစ်လျှင် ပြီးသည်။ ဆက်တိုက် ၃ ခုမှန်လျှင် ၁ ခုတိုးသည်။\nပထမမေးခွန်းက ၁၀ စက္ကန့်။ ဆက်တိုက်မှန်တိုင်း နောက်တစ်ခုက ၁ စက္ကန့်လျော့ပြီး အနည်းဆုံး ၅ စက္ကန့်။ မှားလျှင် သို့မဟုတ် အချိန်ကုန်လျှင် နောက်တစ်ခုက ၁၀ စက္ကန့် ပြန်ဖြစ်သည်။ အချိန်နည်းလာလျှင် ဘားတန်း နီလာပြီး တဖျတ်ဖျတ်ဖြစ်သည်။ မှန်လျှင် အသံမြင့်၊ မှားလျှင် အသံနိမ့်၊ အချိန်ကုန်လျှင် အသံကျသည်။ နှလုံးတိုးလျှင် ပိုလင်းသော အသံ ထွက်သည်။"
                        )
                    )
                    guide(
                        tr(ja: "得点", zh: "得分", en: "Score", my: "ရမှတ်"),
                        tr(
                            ja: "正解は10点です。連続で正解すると、連勝が1つ増えるごとに2点追加され、追加は最大10点です。",
                            zh: "答对得 10 分。连续答对时，每多连对一题再加 2 分，额外加分最多 10 分。",
                            en: "A correct answer scores 10. Each extra correct answer in a row adds 2 points, up to 10 extra.",
                            my: "မှန်လျှင် ၁၀ မှတ်။ ဆက်တိုက်မှန်လျှင် တစ်ခါလျှင် ၂ မှတ် ထပ်ပေါင်းပြီး အများဆုံး ၁၀ မှတ် ထပ်ရသည်။"
                        )
                    )
                }
            }
        }
        .sheet(isPresented: $showsRanking) {
            menuSheet(tr(ja: "ランキング", zh: "排行榜", en: "Leaderboard", my: "အဆင့်စာရင်း")) {
                ScoreBoardList(game: "stroop")
            }
        }
        .sheet(isPresented: $showsPractice) {
            menuSheet(tr(ja: "設定", zh: "设置", en: "Settings", my: "ဆက်တင်")) {
                VStack(alignment: .leading, spacing: 24) {
                    LanguagePicker()
                    testControls(showNote: true)
                }
            }
        }
    }

    private func arcadeShortcut(_ symbol: String, _ title: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: symbol).font(.system(size: 30, weight: .bold)).foregroundStyle(color)
                    .shadow(color: color.opacity(0.4), radius: 8)
                Text(title).font(.system(.caption, design: .rounded, weight: .heavy))
                    .lineLimit(1).minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 92)
            .background(Color(red: 0.08, green: 0.12, blue: 0.34).opacity(0.95), in: RoundedRectangle(cornerRadius: 22))
            .overlay { RoundedRectangle(cornerRadius: 22).strokeBorder(Color(red: 0.35, green: 0.43, blue: 0.85), lineWidth: 2) }
        }
        .buttonStyle(ArcadePressStyle())
    }

    private func menuSheet<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        let sheetContent = content()
        return NavigationStack {
            ScrollView {
                sheetContent.padding(24).frame(maxWidth: 560).frame(maxWidth: .infinity)
            }
            .background(StroopBackdrop())
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
        .preferredColorScheme(.dark)
    }

    private func testControls(showNote: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                session.setTesting(!session.testing)
            } label: {
                Text(session.testing
                    ? tr(ja: "テストモード：オン", zh: "测试模式：开", en: "Test mode: on", my: "စမ်းသပ်မုဒ်၊ ဖွင့်")
                    : tr(ja: "テストモード：オフ", zh: "测试模式：关", en: "Test mode: off", my: "စမ်းသပ်မုဒ်၊ ပိတ်"))
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .tint(session.testing ? Color(red: 0.98, green: 0.74, blue: 0.32) : .white)
            .accessibilityIdentifier("stroop-test-mode")
            if session.testing {
                if showNote {
                    Text(tr(
                        ja: "種類、問い方、言語を自分で切り替えられます。制限時間は最初オフです。不正解でもハートは減りません。",
                        zh: "可以自己切换题目、问法和语言。倒计时默认关闭。答错不扣爱心。",
                        en: "Switch the kind, the question, and the language yourself. The countdown starts off. A miss does not cost a heart.",
                        my: "အမျိုးအစား၊ မေးပုံ၊ ဘာသာစကားကို ကိုယ်တိုင် ပြောင်းနိုင်သည်။ အချိန်ရေတွက်မှု ပိတ်ထားသည်။ မှားလျှင် နှလုံးမလျော့ပါ။"
                    ))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
                }
                if showNote {
                    Text(tr(ja: "すべての問題", zh: "全部题型", en: "All question types", my: "မေးခွန်းအမျိုးအစားအားလုံး"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.72))
                }
                LanguageWrap(spacing: showNote ? 8 : 6) {
                    ForEach(InterferenceTask.allCases, id: \.rawValue) { task in
                        let selected = task == session.testTask
                        Button {
                            session.selectTestTask(task)
                        } label: {
                            Text(task.chipTitle)
                                .font(showNote ? .caption.weight(.semibold) : .caption2.weight(.semibold))
                                .lineLimit(1)
                                .foregroundStyle(selected ? .black : .white)
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
                        .accessibilityIdentifier("stroop-test-task-\(task.rawValue)")
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
                .tint(session.testUsesTimer ? Color(red: 0.98, green: 0.74, blue: 0.32) : .white)
                .accessibilityIdentifier("stroop-test-timer")
                Button(tr(ja: "問い方を変える", zh: "换问法", en: "Switch question", my: "မေးပုံပြောင်း")) {
                    session.flipTestQuestion()
                }
                .font(.caption.weight(.semibold))
                .buttonStyle(.bordered)
                .tint(.white)
                .accessibilityIdentifier("stroop-test-flip")
            }
        }
    }

    private func guide(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Text(body)
                .font(.body)
                .foregroundStyle(.white.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var playfield: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 12) {
                    quizHeader
                    if session.testing {
                        VStack(alignment: .leading, spacing: 8) {
                            LanguagePicker(compact: true)
                            testControls(showNote: false)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 18).fill(CatQuizPalette.ink))
                    }
                    CatQuizHost(isMistake: session.lastAnswerWasCorrect == false)
                        .padding(.bottom, -18)
                        .zIndex(1)
                    VStack(spacing: 4) {
                        questionBanner
                        stimulusPanel
                    }
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: [Color(red: 1, green: 0.98, blue: 0.93), CatQuizPalette.cream], startPoint: .top, endPoint: .bottom))
                            .shadow(color: CatQuizPalette.wood.opacity(0.3), radius: 0, y: 4)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(CatQuizPalette.wood, lineWidth: 2.5)
                    }
                    answers
                        .frame(minHeight: max(220, min(320, geometry.size.height * 0.32)))
                    Spacer(minLength: 0)
                    quizFooter
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
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(urgencyColor.opacity(session.questionRemaining <= urgentRemaining && session.showsTimer ? 0.9 : 0), lineWidth: 5)
                .padding(4)
                .scaleEffect(pulse)
                .allowsHitTesting(false)
        }
    }

    private var quizHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Q\(session.answerCount + 1)")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Capsule().fill(CatQuizPalette.ink))
                .accessibilityIdentifier("stroop-score")
                .accessibilityLabel(tr(ja: "得点 \(session.score)", zh: "得分 \(session.score)", en: "Score \(session.score)", my: "ရမှတ် \(session.score)"))

            VStack(spacing: 4) {
                hearts
                Text(tr(ja: "得点 \(session.score)", zh: "得分 \(session.score)", en: "Score \(session.score)", my: "ရမှတ် \(session.score)"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CatQuizPalette.ink)
            }
            .frame(maxWidth: .infinity)

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
                .fill(CatQuizPalette.ink)
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
                .animation(.linear(duration: 0.05), value: session.questionRemaining)
            Text("\(secondsLeft)")
                .font(.system(size: session.questionRemaining <= urgentRemaining ? 26 : 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .scaleEffect(pulse)
                .contentTransition(.numericText())
        }
        .frame(width: 68, height: 68)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(tr(ja: "残り \(secondsLeft) 秒", zh: "还剩 \(secondsLeft) 秒", en: "\(secondsLeft) seconds left", my: "\(secondsLeft) စက္ကန့်ကျန်သည်"))
    }

    private var questionBanner: some View {
        VStack(spacing: 4) {
            Text(session.round.rule)
                .font(.system(size: 25, weight: .heavy, design: .rounded))
                .foregroundStyle(CatQuizPalette.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if session.lastAnswerWasCorrect == false {
                Text(session.lastMissWasTimeout
                    ? tr(ja: "時間切れ", zh: "超时", en: "Time's up", my: "အချိန်ကုန်ပြီ")
                    : tr(ja: "不正解", zh: "点错了", en: "Wrong", my: "မှားသည်"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.92, green: 0.28, blue: 0.34))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
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
                        .fill(CatQuizPalette.ink)
                    Capsule()
                        .fill(LinearGradient(colors: [Color(red: 0.58, green: 0.95, blue: 0.2), Color(red: 0.25, green: 0.85, blue: 0.48)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(18, (geo.size.width - 8) * heartProgress))
                        .overlay(Capsule().strokeBorder(.white, lineWidth: 2))
                        .padding(4)
                }
            }
            .frame(height: 25)
            .overlay(Capsule().strokeBorder(.white.opacity(0.85), lineWidth: 1.5))
            .accessibilityLabel(tr(ja: "ハート \(session.hearts)", zh: "\(session.hearts) 颗爱心", en: "\(session.hearts) hearts", my: "နှလုံး \(session.hearts)"))

            HStack {
                Text(tr(ja: "連続 \(session.streak)", zh: "连对 \(session.streak)", en: "Streak \(session.streak)", my: "ဆက်တိုက် \(session.streak)"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CatQuizPalette.ink)
                Spacer()
                Button(tr(ja: "終了", zh: "结束", en: "End", my: "ထွက်ရန်")) { session.returnToMenu() }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CatQuizPalette.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(CatQuizPalette.cream))
            }
            .padding(.horizontal, 6)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 22).fill(CatQuizPalette.cream.opacity(0.92)))
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

    private var heartProgress: CGFloat {
        CGFloat(min(1, max(0, Double(session.hearts) / 5)))
    }

    private var secondsLeft: Int {
        max(0, Int(ceil(session.questionRemaining - 0.001)))
    }

    private var pulse: CGFloat {
        guard session.questionRemaining <= urgentRemaining, session.questionRemaining > 0 else { return 1 }
        let beat = (session.questionRemaining * 3).truncatingRemainder(dividingBy: 1)
        return beat < 0.45 ? 1.08 : 0.96
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

    private var hearts: some View {
        HStack(spacing: 3) {
            if session.hearts <= 6 {
                ForEach(0..<session.hearts, id: \.self) { index in
                    Image(systemName: "heart.fill")
                        .symbolEffect(.bounce, value: index == session.hearts - 1 ? session.heartGain : 0)
                }
            } else {
                Image(systemName: "heart.fill")
                    .symbolEffect(.bounce, value: session.heartGain)
                Text("\(session.hearts)")
                    .font(.caption.bold())
            }
        }
        .font(.system(size: 16, weight: .bold))
        .foregroundStyle(Color(red: 0.95, green: 0.28, blue: 0.32))
        .animation(.spring(response: 0.32, dampingFraction: 0.55), value: session.hearts)
        .accessibilityLabel(tr(ja: "ハート \(session.hearts)", zh: "\(session.hearts) 颗爱心", en: "\(session.hearts) hearts", my: "နှလုံး \(session.hearts)"))
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
        case .placedArrow(let direction, let place):
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.55))
                Image(systemName: direction.symbol)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(Color(red: 0.16, green: 0.16, blue: 0.18))
                    .offset(place.quizOffset)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
        case .placedWord(let word, let place):
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.55))
                Text(word.name)
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(Color(red: 0.16, green: 0.16, blue: 0.18))
                    .offset(place.quizOffset)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
        case .digits(let value, let count):
            Text(String(repeating: "\(value)", count: count))
                .font(.system(size: 56, weight: .black, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundStyle(Color(red: 0.16, green: 0.16, blue: 0.18))
                .frame(maxWidth: .infinity)
                .frame(height: 100)
        case .pair(let left, let right, let leftUsesLargerFont):
            HStack(alignment: .center, spacing: 28) {
                Text("\(left)")
                    .font(.system(size: leftUsesLargerFont ? 88 : 28, weight: .black, design: .rounded))
                Text("\(right)")
                    .font(.system(size: leftUsesLargerFont ? 28 : 88, weight: .black, design: .rounded))
            }
            .foregroundStyle(Color(red: 0.16, green: 0.16, blue: 0.18))
            .frame(maxWidth: .infinity)
            .frame(height: 120)
        }
    }

    private var answers: some View {
        HStack(spacing: 14) {
            ForEach(Array(session.round.choices.enumerated()), id: \.element.id) { index, choice in
                choiceCard(choice, mark: index == 0 ? "A" : "B", accent: index == 0
                    ? Color(red: 0.95, green: 0.32, blue: 0.38)
                    : Color(red: 0.28, green: 0.52, blue: 0.98))
            }
        }
    }

    private func choiceCard(_ choice: AnswerChoice, mark: String, accent: Color) -> some View {
        Button {
            session.choose(choice.id)
        } label: {
            VStack(spacing: 0) {
                HStack {
                    Text(mark)
                        .font(.system(size: 27, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(Circle().fill(LinearGradient(colors: [accent, accent.opacity(0.8)], startPoint: .top, endPoint: .bottom)))
                        .overlay(Circle().strokeBorder(.white.opacity(0.9), lineWidth: 2))
                        .shadow(color: accent.opacity(0.3), radius: 0, y: 3)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)

                Spacer(minLength: 4)

                choiceVisual(choice)
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)

                Spacer(minLength: 12)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 220, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(colors: [.white, Color(red: 0.96, green: 0.95, blue: 0.97)], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(CatQuizPalette.ink.opacity(0.55), lineWidth: 2)
            }
            .shadow(color: CatQuizPalette.wood.opacity(0.25), radius: 0, y: 5)
        }
        .buttonStyle(ArcadePressStyle())
        .disabled(session.isResolving)
        .overlay {
            if session.selectedChoiceID == choice.id {
                RoundedRectangle(cornerRadius: 26)
                    .strokeBorder(session.lastAnswerWasCorrect == true ? Color.green : Color.red, lineWidth: 4)
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
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.16, green: 0.16, blue: 0.18))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .padding(.horizontal, 8)
        }
    }

    private var result: some View {
        VStack(spacing: 16) {
            Text(tr(ja: "ハートがなくなった", zh: "爱心用完了", en: "No hearts left", my: "နှလုံးကုန်ပြီ"))
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("\(session.score)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(session.accuracyText)
                .font(.body)
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)
            ScoreBoardList(game: "stroop")
            Button(tr(ja: "もう一度", zh: "再来一局", en: "Play again", my: "နောက်တစ်ပွဲ")) { session.start() }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.98, green: 0.74, blue: 0.32))
            Button(tr(ja: "戻る", zh: "返回", en: "Back", my: "ပြန်ရန်")) { session.returnToMenu() }
                .buttonStyle(.bordered)
                .tint(.white)
        }
        .padding(24)
    }
}

private struct ArcadePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .brightness(configuration.isPressed ? -0.06 : 0)
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
            .toolbar(isPlaying ? .hidden : .visible, for: .navigationBar)
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

private struct HeartGainPop: View {
    let token: Int

    @State private var scale: CGFloat = 0.2
    @State private var opacity: Double = 0
    @State private var shownToken = 0

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .font(.system(size: 68))
            Text("+1")
                .font(.title.bold())
        }
        .foregroundStyle(Color(red: 0.95, green: 0.28, blue: 0.32))
        .scaleEffect(scale)
        .opacity(opacity)
        .allowsHitTesting(false)
        .onChange(of: token) { _, newValue in
            guard newValue > 0 else { return }
            shownToken = newValue
            scale = 0.2
            opacity = 0
            withAnimation(.spring(response: 0.28, dampingFraction: 0.52)) {
                scale = 1
                opacity = 1
            }
            Task {
                try? await Task.sleep(for: .milliseconds(560))
                guard shownToken == newValue else { return }
                withAnimation(.easeOut(duration: 0.28)) {
                    scale = 1.45
                    opacity = 0
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StroopGameView()
    }
}
