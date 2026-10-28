import AVFoundation
import SwiftUI

/// 背景音乐。曲目在 `Music/`，右上角音符随时切换。
@MainActor
final class BackgroundMusic: ObservableObject {
    static let shared = BackgroundMusic()

    enum Track: String, CaseIterable, Identifiable {
        case off
        case cozyAmbience = "cozy-ambience"
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

        var id: String { rawValue }

        var fileName: String? {
            switch self {
            case .off: nil
            default: rawValue
            }
        }

        var title: String {
            switch self {
            case .off:
                tr(ja: "オフ", zh: "关闭", en: "Off", my: "ပိတ်")
            case .cozyAmbience:
                tr(ja: "ほっこり", zh: "暖暖氛围", en: "Cozy", my: "နွေးထွေး")
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
            }
        }
    }

    @Published var track: Track {
        didSet {
            UserDefaults.standard.set(track.rawValue, forKey: Self.key)
            apply(forceNew: true)
        }
    }

    @Published var isPlaying = false

    private var player: AVAudioPlayer?
    private var currentFile: String?
    private var sessionReady = false
    private var sessionStarting = false
    private var pendingForceNew: Bool?
    private let finishRelay = FinishRelay()
    private static let key = "bgmTrackMode"
    private static var songs: [Track] { Track.allCases.filter { $0.fileName != nil } }

    private init() {
        track = Track(rawValue: UserDefaults.standard.string(forKey: Self.key) ?? "")
            ?? (Self.songs.randomElement() ?? .off)
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

    private func activateSession(then forceNew: Bool) {
        #if os(iOS)
        if sessionReady {
            playCurrent(forceNew: forceNew)
            return
        }
        if sessionStarting {
            pendingForceNew = (pendingForceNew ?? false) || forceNew
            return
        }
        sessionStarting = true
        pendingForceNew = forceNew
        // Never activate the session on the main thread — iPhone 17 freezes there.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            Task { @MainActor in
                self?.finishSessionStart()
            }
        }
        #else
        playCurrent(forceNew: forceNew)
        #endif
    }

    private func finishSessionStart() {
        guard sessionStarting || !sessionReady else { return }
        sessionReady = true
        sessionStarting = false
        let force = pendingForceNew ?? false
        pendingForceNew = nil
        playCurrent(forceNew: force)
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
        guard track != .off else { return }
        track = Self.songs.filter { $0.fileName != currentFile }.randomElement() ?? track
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
        activateSession(then: forceNew)
    }

    private func playCurrent(forceNew: Bool) {
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
        let file = track.fileName ?? ""
        guard !file.isEmpty, let url = Self.url(for: file) else { return }
        player?.volume = 0
        player?.stop()
        player = nil
        let relay = finishRelay
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let next = try? AVAudioPlayer(contentsOf: url) else { return }
            next.numberOfLoops = 0
            next.volume = 0.52
            next.prepareToPlay()
            Task { @MainActor in
                guard let self else { return }
                next.delegate = relay
                next.play()
                self.player = next
                self.currentFile = file
                self.isPlaying = true
            }
        }
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
    var action: () -> Void
    @ObservedObject private var music = BackgroundMusic.shared

    var body: some View {
        Button(action: action) {
            let playing = music.isPlaying
            TimelineView(.animation(minimumInterval: 1 / 8, paused: !playing)) { context in
                let turn = playing
                    ? context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.4) / 2.4
                    : 0
                WoodlandIconBadge(symbol: "music.note", rotation: turn * 360, lit: playing)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tr(ja: "BGM", zh: "背景音乐", en: "Music", my: "နောက်ခံသီချင်း"))
        .accessibilityIdentifier("stroop-music")
    }
}

struct MusicTrackPicker: View {
    @ObservedObject private var music = BackgroundMusic.shared

    var body: some View {
        let selected = music.track
        VStack(spacing: 8) {
            ForEach(BackgroundMusic.Track.allCases) { track in
                Button {
                    music.track = track
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: track == .off ? "speaker.slash.fill" : "music.note")
                        Text(track.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if track == selected {
                            Image(systemName: "checkmark")
                        }
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(selected == track ? CatQuizPalette.ink : CatQuizPalette.wood)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        Capsule().fill(
                            selected == track
                                ? Color(red: 0.98, green: 0.74, blue: 0.32)
                                : CatQuizPalette.cream.opacity(0.94)
                        )
                    }
                    .overlay {
                        Capsule().strokeBorder(CatQuizPalette.wood.opacity(selected == track ? 0.4 : 0.14), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected == track ? .isSelected : [])
                .accessibilityIdentifier("music-\(track.rawValue)")
            }
        }
    }
}
