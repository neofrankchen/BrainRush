import AVFoundation
import SwiftUI

/// 背景音乐。曲目在 `Music/`，右上角音符随时切换。播放时偶尔插入 `Meows/` 里的真猫叫。
@MainActor
@Observable
final class BackgroundMusic {
    static let shared = BackgroundMusic()

    enum Track: String, CaseIterable, Identifiable {
        case off
        case random
        case cozyAmbience = "cozy-ambience"
        case bookshop
        case autumnCozy = "autumn-cozy"
        case autumnBreeze = "autumn-breeze"
        case autumnPiano = "autumn-piano"
        case fallenLeaves = "fallen-leaves"
        case healing
        case healingLight = "healing-light"
        case loving
        case storytelling
        case romantic
        case family
        case thanksgiving
        case christmasMagic = "christmas-magic"
        case christmasSpirit = "christmas-spirit"

        var id: String { rawValue }

        var fileName: String? {
            switch self {
            case .off, .random: nil
            default: rawValue
            }
        }

        var title: String {
            switch self {
            case .off:
                tr(ja: "オフ", zh: "关闭", en: "Off", my: "ပိတ်")
            case .random:
                tr(ja: "ランダム", zh: "随机播放", en: "Shuffle", my: "ကျပန်း")
            case .cozyAmbience:
                tr(ja: "ほっこり", zh: "暖暖氛围", en: "Cozy", my: "နွေးထွေး")
            case .bookshop:
                tr(ja: "本屋の午後", zh: "书店下午", en: "Bookshop", my: "စာအုပ်ဆိုင်")
            case .autumnCozy:
                tr(ja: "秋のぬくもり", zh: "秋日暖意", en: "Autumn cozy", my: "ဆောင်းဦးနွေး")
            case .autumnBreeze:
                tr(ja: "秋のそよ風", zh: "秋风", en: "Autumn breeze", my: "ဆောင်းဦးလေ")
            case .autumnPiano:
                tr(ja: "秋のピアノ", zh: "秋日钢琴", en: "Autumn piano", my: "ဆောင်းဦးစန္ဒရား")
            case .fallenLeaves:
                tr(ja: "落ち葉のピアノ", zh: "落叶钢琴", en: "Fallen leaves", my: "ရွက်ကြွေ")
            case .healing:
                tr(ja: "いやし", zh: "疗愈", en: "Healing", my: "ကုစား")
            case .healingLight:
                tr(ja: "ひかり", zh: "柔光", en: "Soft light", my: "အလင်း")
            case .loving:
                tr(ja: "やさしい気持ち", zh: "温柔", en: "Gentle", my: "နူးညံ့")
            case .storytelling:
                tr(ja: "ものがたり", zh: "故事", en: "Story", my: "ပုံပြင်")
            case .romantic:
                tr(ja: "ときめき", zh: "心动", en: "Romance", my: "နှလုံးသား")
            case .family:
                tr(ja: "ファミリー", zh: "家人", en: "Family", my: "မိသားစု")
            case .thanksgiving:
                tr(ja: "かんしゃ", zh: "感恩", en: "Thanks", my: "ကျေးဇူးတင်")
            case .christmasMagic:
                tr(ja: "クリスマス", zh: "圣诞魔法", en: "Christmas magic", my: "ခရစ္စမတ်")
            case .christmasSpirit:
                tr(ja: "聖夜", zh: "圣诞气氛", en: "Christmas spirit", my: "ခရစ္စမတ်ည")
            }
        }
    }

    var track: Track {
        didSet {
            UserDefaults.standard.set(track.rawValue, forKey: Self.key)
            apply(forceNew: true)
        }
    }

    var isPlaying = false {
        didSet {
            guard isPlaying != oldValue else { return }
            if isPlaying {
                startMeows()
            } else {
                stopMeows()
            }
        }
    }

    private var player: AVAudioPlayer?
    private var meowPlayer: AVAudioPlayer?
    private var meowTask: Task<Void, Never>?
    private var currentFile: String?
    private let finishRelay = FinishRelay()
    private static let key = "bgmTrackMode"
    private static var songs: [Track] { Track.allCases.filter { $0.fileName != nil } }
    private static let meowFiles = (1...5).map { "meow-\($0)" }

    private init() {
        track = Track(rawValue: UserDefaults.standard.string(forKey: Self.key) ?? "") ?? .random
        finishRelay.owner = { BackgroundMusic.shared.songDidFinish() }
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { notification in
            Task { @MainActor in
                BackgroundMusic.shared.handleInterruption(notification)
            }
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                BackgroundMusic.shared.apply(forceNew: false)
            }
        }
    }

    nonisolated static func activateSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        #endif
    }

    func start() {
        apply(forceNew: false)
    }

    func handle(_ phase: ScenePhase) {
        switch phase {
        case .active:
            apply(forceNew: false)
        case .background:
            player?.pause()
            isPlaying = false
        default:
            break
        }
    }

    fileprivate func songDidFinish() {
        guard track == .random else { return }
        apply(forceNew: true)
    }

    private func handleInterruption(_ notification: Notification) {
        let info = notification.userInfo
        let typeValue = info?[AVAudioSessionInterruptionTypeKey] as? UInt
        let type = typeValue.flatMap(AVAudioSession.InterruptionType.init(rawValue:))
        switch type {
        case .began:
            isPlaying = false
        case .ended:
            let optionsValue = info?[AVAudioSessionInterruptionOptionKey] as? UInt
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue ?? 0)
            if options.contains(.shouldResume) {
                apply(forceNew: false)
            }
        default:
            break
        }
    }

    private func apply(forceNew: Bool) {
        Self.activateSession()
        if track == .off {
            player?.stop()
            player = nil
            currentFile = nil
            isPlaying = false
            return
        }
        if !forceNew, let player, currentFile != nil {
            if !player.isPlaying {
                player.play()
            }
            isPlaying = true
            return
        }
        let file: String
        if track == .random {
            let names = Self.songs.compactMap(\.fileName)
            file = names.filter { $0 != currentFile }.randomElement() ?? names.first ?? ""
        } else {
            file = track.fileName ?? ""
        }
        guard !file.isEmpty, let url = Self.url(for: file) else { return }
        player?.stop()
        guard let next = try? AVAudioPlayer(contentsOf: url) else { return }
        next.numberOfLoops = track == .random ? 0 : -1
        next.volume = 0.45
        next.delegate = finishRelay
        next.prepareToPlay()
        next.play()
        player = next
        currentFile = file
        isPlaying = true
    }

    private func startMeows() {
        meowTask?.cancel()
        meowTask = Task { @MainActor in
            while !Task.isCancelled {
                let wait = Double.random(in: 9...24)
                try? await Task.sleep(for: .seconds(wait))
                guard !Task.isCancelled, isPlaying else { return }
                playMeow()
            }
        }
    }

    private func stopMeows() {
        meowTask?.cancel()
        meowTask = nil
        meowPlayer?.stop()
        meowPlayer = nil
    }

    private func playMeow() {
        guard let name = Self.meowFiles.randomElement(),
              let url = Self.url(for: name, ext: "m4a", folder: "Meows") else { return }
        guard let next = try? AVAudioPlayer(contentsOf: url) else { return }
        next.enableRate = true
        next.rate = Float.random(in: 0.9...1.12)
        next.volume = Float.random(in: 0.42...0.7)
        next.play()
        meowPlayer = next
    }

    private static func url(for file: String, ext: String = "mp3", folder: String = "Music") -> URL? {
        if let url = Bundle.main.url(forResource: file, withExtension: ext, subdirectory: folder) {
            return url
        }
        if let url = Bundle.main.url(forResource: file, withExtension: ext) {
            return url
        }
        guard let root = Bundle.main.resourceURL else { return nil }
        let nested = root.appending(path: "\(folder)/\(file).\(ext)")
        if FileManager.default.fileExists(atPath: nested.path) {
            return nested
        }
        if let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) {
            for case let item as URL in enumerator where item.lastPathComponent == "\(file).\(ext)" {
                return item
            }
        }
        return nil
    }
}

private final class FinishRelay: NSObject, AVAudioPlayerDelegate {
    var owner: (() -> Void)?

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else { return }
        Task { @MainActor in
            owner?()
        }
    }
}

struct MusicPickerMenu: View {
    var body: some View {
        let selected = BackgroundMusic.shared.track
        Menu {
            ForEach(BackgroundMusic.Track.allCases) { track in
                Button {
                    BackgroundMusic.shared.track = track
                } label: {
                    if track == selected {
                        Label(track.title, systemImage: "checkmark")
                    } else {
                        Text(track.title)
                    }
                }
            }
        } label: {
            let playing = BackgroundMusic.shared.isPlaying
            TimelineView(.animation(minimumInterval: 1 / 30, paused: !playing)) { context in
                let turn = playing
                    ? context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.4) / 2.4
                    : 0
                WoodlandIconBadge(symbol: "music.note", rotation: turn * 360, lit: playing)
            }
        }
        .accessibilityLabel(tr(ja: "BGM", zh: "背景音乐", en: "Music", my: "နောက်ခံသီချင်း"))
        .accessibilityIdentifier("stroop-music")
    }
}
