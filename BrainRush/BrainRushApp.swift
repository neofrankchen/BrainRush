import SwiftUI

@main
struct BrainRushApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StroopGameView()
            }
            .preferredColorScheme(.dark)
        }
    }
}
