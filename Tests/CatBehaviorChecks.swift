import Foundation

/// Run without a simulator: swiftc BrainRush/CatBehavior.swift Tests/CatBehaviorChecks.swift -o /tmp/brainrush-cat-checks && /tmp/brainrush-cat-checks
@main
struct CatBehaviorChecks {
    private static var failures: [String] = []

    static func main() {
        let start = Date(timeIntervalSinceReferenceDate: 10_000)

        check("idle has no action") {
            CatBehaviorState().sample(at: start) == CatActionSample(action: .none, progress: 0)
        }

        check("accepted taps cycle through pet, nuzzle, roll and repeat") {
            var state = CatBehaviorState()
            let actions = [0.0, 0.6, 1.2, 1.8].compactMap {
                state.pet(at: start.addingTimeInterval($0))
            }
            return actions == [.pet, .nuzzle, .roll, .pet]
        }

        check("rapid taps do not restart an action or consume the next reaction") {
            var state = CatBehaviorState()
            _ = state.pet(at: start)
            let rejected = state.pet(at: start.addingTimeInterval(0.1))
            let action = state.sample(at: start.addingTimeInterval(0.4))
            let next = state.pet(at: start.addingTimeInterval(0.6))
            return rejected == nil && action.action == .pet && close(action.progress, 0.25)
                && next == .nuzzle
        }

        check("the cooldown accepts a tap at its boundary") {
            var state = CatBehaviorState()
            _ = state.pet(at: start)
            return state.pet(at: start.addingTimeInterval(0.55)) == .nuzzle
        }

        check("a deliberate second touch responds before the first gesture has ended") {
            var state = CatBehaviorState()
            _ = state.pet(at: start)
            return state.pet(at: start.addingTimeInterval(0.25)) == .nuzzle
        }

        check("a stroke requests nuzzling immediately") {
            var state = CatBehaviorState()
            return state.pet(stroked: true, at: start) == .nuzzle
        }

        check("a new event replaces a touch reaction") {
            var state = CatBehaviorState()
            _ = state.pet(at: start)
            state.perform(.celebrate, at: start.addingTimeInterval(0.2))
            let sample = state.sample(at: start.addingTimeInterval(0.6))
            return sample.action == .celebrate && close(sample.progress, 0.25)
        }

        check("identical consecutive events restart the motion") {
            var state = CatBehaviorState()
            state.perform(.celebrate, at: start)
            state.perform(.celebrate, at: start.addingTimeInterval(0.7))
            let sample = state.sample(at: start.addingTimeInterval(0.7))
            return sample.action == .celebrate && sample.progress == 0
        }

        check("an answer event keeps its initial response when the cat is tapped") {
            var state = CatBehaviorState()
            state.perform(.encourage, at: start)
            return state.pet(at: start.addingTimeInterval(0.3)) == nil
                && state.sample(at: start.addingTimeInterval(0.3)).action == .encourage
                && state.pet(at: start.addingTimeInterval(0.6)) == .pet
        }

        check("each action ends cleanly instead of remaining on its last frame") {
            let cases: [(CatAction, TimeInterval)] = [
                (.pet, 1.6), (.nuzzle, 1.8), (.roll, 2.6), (.greet, 1.3),
                (.celebrate, 1.6), (.encourage, 1.6), (.meow, 0.8)
            ]
            return cases.allSatisfy { action, duration in
                var state = CatBehaviorState()
                state.perform(action, at: start)
                let middle = state.sample(at: start.addingTimeInterval(duration / 2))
                let end = state.sample(at: start.addingTimeInterval(duration))
                return middle.action == action && close(middle.progress, 0.5)
                    && end == CatActionSample(action: .none, progress: 0)
            }
        }

        check("a sample before action start never has negative progress") {
            var state = CatBehaviorState()
            state.perform(.greet, at: start)
            return state.sample(at: start.addingTimeInterval(-0.1))
                == CatActionSample(action: .greet, progress: 0)
        }

        check("clearing a motion returns the cat to idle") {
            var state = CatBehaviorState()
            state.perform(.roll, at: start)
            state.perform(.none, at: start.addingTimeInterval(0.4))
            return state.sample(at: start.addingTimeInterval(0.4)).action == .none
        }

        check("reset clears motion, cooldown and touch history") {
            var state = CatBehaviorState()
            _ = state.pet(at: start)
            _ = state.pet(at: start.addingTimeInterval(0.6))
            state.reset()
            let idle = state.sample(at: start.addingTimeInterval(0.7))
            return idle.action == .none && state.pet(at: start.addingTimeInterval(0.7)) == .pet
        }

        check("interrupting a roll starts from its current joints") {
            var state = CatBehaviorState()
            state.perform(.roll, at: start)
            let at = start.addingTimeInterval(1.3)
            let before = state.sample(at: at).gesture
            state.perform(.pet, at: at)
            let after = state.sample(at: at).gesture
            return before.roll > 0.9 && after == before
        }

        check("an interrupted roll settles into the new pet within a quarter second") {
            var state = CatBehaviorState()
            state.perform(.roll, at: start)
            state.perform(.pet, at: start.addingTimeInterval(1.3))
            let pose = state.sample(at: start.addingTimeInterval(1.56)).gesture
            return pose.roll == 0 && pose.pet > 0.1
        }

        check("a second interruption preserves the already blended joints") {
            var state = CatBehaviorState()
            state.perform(.roll, at: start)
            state.perform(.pet, at: start.addingTimeInterval(1.3))
            let at = start.addingTimeInterval(1.4)
            let before = state.sample(at: at).gesture
            state.perform(.encourage, at: at)
            return before.roll > 0 && before.roll < 1 && state.sample(at: at).gesture == before
        }

        check("clearing an active pose eases its joints back to rest") {
            var state = CatBehaviorState()
            state.perform(.roll, at: start)
            state.perform(.none, at: start.addingTimeInterval(1.3))
            let beginning = state.sample(at: start.addingTimeInterval(1.3))
            let end = state.sample(at: start.addingTimeInterval(1.6))
            return beginning.action == .none && beginning.gesture.roll > 0.9
                && end.gesture == CatGesturePose()
        }

        guard failures.isEmpty else {
            for failure in failures { print("FAIL: \(failure)") }
            print("\(failures.count) cat behavior check(s) failed")
            exit(1)
        }
        print("PASS: 17 deterministic cat behavior checks")
    }

    private static func close(_ value: CGFloat, _ expected: CGFloat) -> Bool {
        abs(value - expected) < 0.000_01
    }

    private static func check(_ name: String, _ predicate: () -> Bool) {
        if !predicate() { failures.append(name) }
    }
}
