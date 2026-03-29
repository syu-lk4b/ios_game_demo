import SwiftUI
import SpriteKit

struct DungeonMapView: View {
    let engine: GameEngine
    let aiGenerator: AIContentGenerator

    @State private var scene: DungeonMapScene = {
        let scene = DungeonMapScene()
        scene.size = CGSize(width: 350, height: 350)
        scene.scaleMode = .aspectFit
        return scene
    }()

    var body: some View {
        VStack(spacing: 0) {
            HUDView(engine: engine)

            SpriteView(scene: scene)
                .frame(width: 350, height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            if let message = engine.lastEventMessage {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
        .onAppear { refreshMap() }
        .onChange(of: engine.player?.position) { _, _ in refreshMap() }
    }

    private func refreshMap() {
        guard let dungeon = engine.dungeon, let pos = engine.player?.position else { return }
        scene.onTileTapped = { position in
            _ = engine.movePlayer(to: position)
        }
        scene.updateMap(dungeon: dungeon, playerPosition: pos)
    }
}
