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
            .onAppear {
                DispatchQueue.main.async {
                    BackgroundMusic.shared.start()
                }
            }
            .onChange(of: scenePhase) { phase in
                BackgroundMusic.shared.handle(phase)
            }
        }
    }
}
