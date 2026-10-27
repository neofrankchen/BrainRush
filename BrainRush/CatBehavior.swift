import Foundation

enum CatMood {
    case content, curious, thinking, delighted, concerned, surprised
}

enum CatAction {
    case none, pet, nuzzle, roll, greet, celebrate, encourage, meow

    fileprivate var duration: TimeInterval {
        switch self {
        case .none: 0
        case .pet, .celebrate, .encourage: 1.6
        case .nuzzle: 1.8
        case .roll: 2.6
        case .greet: 1.3
        case .meow: 0.8
        }
    }
}

struct CatActionSample: Equatable {
    var action: CatAction
    var progress: CGFloat
    var gesture = CatGesturePose()
}

/// Joint-level offsets are blended, so a new touch never swaps the entire pose.
struct CatGesturePose: Equatable {
    var pet: CGFloat = 0
    var nuzzle: CGFloat = 0
    var roll: CGFloat = 0
    var cheer: CGFloat = 0
    var encourage: CGFloat = 0
    var mouth: CGFloat = 0

    static func sample(_ action: CatAction, progress: CGFloat) -> Self {
        let p = min(1, max(0, progress))
        let envelope = pow(sin(p * .pi), 2)
        switch action {
        case .none: return Self()
        case .pet: return Self(pet: envelope, mouth: envelope * 0.18)
        case .nuzzle: return Self(pet: envelope, nuzzle: envelope * sin(p * .pi * 2), mouth: envelope * 0.15)
        case .roll: return Self(roll: envelope)
        case .greet: return Self(cheer: envelope * 0.45, mouth: envelope * 0.35)
        case .celebrate: return Self(cheer: envelope)
        case .encourage: return Self(encourage: envelope)
        case .meow: return Self(mouth: envelope * (0.6 + 0.4 * abs(sin(p * .pi * 3))))
        }
    }

    func blended(to target: Self, amount: CGFloat) -> Self {
        let f = min(1, max(0, amount))
        func mix(_ a: CGFloat, _ b: CGFloat) -> CGFloat { a + (b - a) * f }
        return Self(pet: mix(pet, target.pet), nuzzle: mix(nuzzle, target.nuzzle),
                    roll: mix(roll, target.roll), cheer: mix(cheer, target.cheer),
                    encourage: mix(encourage, target.encourage), mouth: mix(mouth, target.mouth))
    }
}

struct CatBehaviorState {
    private(set) var touchCount = 0
    private var action = CatAction.none
    private var actionStartedAt: Date?
    private var nextTouchAllowedAt: Date?
    private var transitionFrom = CatGesturePose()
    private static let touchCooldown: TimeInterval = 0.55
    private static let transitionDuration: TimeInterval = 0.24

    @discardableResult
    mutating func pet(stroked: Bool = false, at date: Date = .now) -> CatAction? {
        if let nextTouchAllowedAt, date < nextTouchAllowedAt { return nil }
        let reactions: [CatAction] = [.pet, .nuzzle, .roll]
        let reaction = stroked ? .nuzzle : reactions[touchCount % reactions.count]
        touchCount += 1
        perform(reaction, at: date)
        // Movement responds promptly; the separate voice limiter avoids overlapping meows.
        nextTouchAllowedAt = date.addingTimeInterval(0.22)
        return reaction
    }

    mutating func perform(_ action: CatAction, at date: Date = .now) {
        transitionFrom = sample(at: date).gesture
        self.action = action
        actionStartedAt = action == .none && transitionFrom == CatGesturePose() ? nil : date
        if action != .none {
            nextTouchAllowedAt = date.addingTimeInterval(Self.touchCooldown)
        }
    }

    func sample(at date: Date) -> CatActionSample {
        guard let actionStartedAt else {
            return CatActionSample(action: .none, progress: 0)
        }
        let duration = action == .none ? Self.transitionDuration : action.duration
        guard date < actionStartedAt.addingTimeInterval(duration) else {
            return CatActionSample(action: .none, progress: 0)
        }
        let elapsed = max(0, date.timeIntervalSince(actionStartedAt))
        let progress = action == .none ? 0 : CGFloat(elapsed / action.duration)
        let target = CatGesturePose.sample(action, progress: progress)
        let blend = min(1, CGFloat(elapsed / Self.transitionDuration))
        let eased = blend * blend * (3 - 2 * blend)
        let gesture = transitionFrom == CatGesturePose() ? target
            : transitionFrom.blended(to: target, amount: eased)
        return CatActionSample(action: action, progress: progress, gesture: gesture)
    }

    mutating func reset() {
        self = CatBehaviorState()
    }
}
