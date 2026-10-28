import AVFoundation
import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum CatCue {
    case pet, greeting, correct, wrong, timeout, result, goodbye
}

/// One cat voice at a time, sharing the session already used by background music.
@MainActor
final class CatMeowPlayer {
    static let shared = CatMeowPlayer()

    private enum Clip: String, CaseIterable {
        case curious = "curious-1"
        case happy = "happy-1"
        case impatient = "impatient-1"
        case kitten = "kitten-1"
        case pleading = "pleading-1"
    }

    private let urls: [Clip: URL]
    private var voice: AVAudioPlayer?
    private var voiceOwner: UUID?
    private var lastClip: Clip?
    private var nextPetAllowedAt: Date?
    private var observers: [NSObjectProtocol] = []

    private init() {
        urls = Dictionary(uniqueKeysWithValues: Clip.allCases.compactMap { clip in
            Self.resourceURL(named: clip.rawValue).map { (clip, $0) }
        })
        #if os(iOS)
        observers.append(NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification, object: nil, queue: .main
        ) { [weak self] notification in
            let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
            guard type == AVAudioSession.InterruptionType.began.rawValue else { return }
            Task { @MainActor [weak self] in self?.stopVoice() }
        })
        observers.append(NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in self?.stopVoice() }
        })
        #endif
    }

    /// Returns the duration only when a clip actually starts. Gameplay cues can replace touch sounds.
    @discardableResult
    func play(_ cue: CatCue, owner: UUID, at date: Date = .now) -> TimeInterval? {
        if cue == .pet, let nextPetAllowedAt, date < nextPetAllowedAt { return nil }
        let preferred = clips(for: cue).filter { urls[$0] != nil }
        let available = preferred.isEmpty ? Array(urls.keys) : preferred
        let different = available.filter { $0 != lastClip }
        guard let clip = (different.isEmpty ? available : different).randomElement(),
              let url = urls[clip],
              let next = try? AVAudioPlayer(contentsOf: url) else { return nil }

        next.volume = 0.95
        next.numberOfLoops = 0
        next.prepareToPlay()
        voice?.stop()
        guard next.play() else {
            voice = nil
            voiceOwner = nil
            return nil
        }
        voice = next
        voiceOwner = owner
        lastClip = clip
        // A touch never immediately cuts off the start of answer or greeting feedback.
        nextPetAllowedAt = date.addingTimeInterval(0.55)
        return next.duration
    }

    func stop(owner: UUID) {
        guard voiceOwner == owner else { return }
        stopVoice()
    }

    private func stopVoice() {
        voice?.stop()
        voice = nil
        voiceOwner = nil
        nextPetAllowedAt = nil
    }

    private func clips(for cue: CatCue) -> [Clip] {
        switch cue {
        case .pet: [.kitten, .curious, .happy]
        case .greeting: [.kitten, .curious]
        case .correct: [.happy, .kitten]
        case .wrong: [.pleading, .kitten]
        case .timeout: [.impatient, .pleading]
        case .result: [.happy, .kitten]
        case .goodbye: [.kitten, .pleading]
        }
    }

    private static func resourceURL(named name: String) -> URL? {
        Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Meows")
            ?? Bundle.main.url(forResource: name, withExtension: "wav")
    }
}
