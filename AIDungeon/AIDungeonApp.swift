import SwiftUI

@main
struct AIDungeonApp: App {
    @State private var engine = GameEngine()
    @State private var aiGenerator = AIContentGenerator()

    var body: some Scene {
        WindowGroup {
            ContentView(engine: engine, aiGenerator: aiGenerator)
        }
    }
}
