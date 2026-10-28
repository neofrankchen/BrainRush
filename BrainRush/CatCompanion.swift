import Foundation

/// The cat's interaction state survives moves between the room and quiz pages.
@MainActor
final class CatCompanion {
    private var state = CatBehaviorState()
    private let audio = CatMeowPlayer.shared
    private let audioOwner = UUID()

    func pet(stroked: Bool = false, at date: Date = .now) {
        guard state.pet(stroked: stroked, at: date) != nil else { return }
        audio.play(.pet, owner: audioOwner, at: date)
    }

    func perform(_ action: CatAction, cue: CatCue? = nil, at date: Date = .now) {
        state.perform(action, at: date)
        if let cue { audio.play(cue, owner: audioOwner, at: date) }
    }

    func sample(at date: Date) -> CatActionSample {
        state.sample(at: date)
    }

    func stop() {
        state.reset()
        audio.stop(owner: audioOwner)
    }
}
