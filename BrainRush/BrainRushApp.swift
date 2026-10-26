import SwiftUI

@main
struct BrainRushApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StroopGameView()
            }
            .preferredColorScheme(.dark)
            .onAppear { BackgroundMusic.shared.start() }
            .onChange(of: scenePhase) { _, phase in
                BackgroundMusic.shared.handle(phase)
            }
        }
    }
}
