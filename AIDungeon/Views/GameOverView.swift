import SwiftUI

struct GameOverView: View {
    let engine: GameEngine
    let isVictory: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text(isVictory ? "🎉 胜利！" : "💀 游戏结束")
                .font(.largeTitle.bold())

            if let player = engine.player {
                VStack(spacing: 8) {
                    StatRow(label: "角色", value: player.characterClass.rawValue)
                    StatRow(label: "获得金币", value: "\(player.gold)")
                    StatRow(label: "收集物品", value: "\(player.inventory.count)")
                    StatRow(label: "获得线索", value: "\(player.hints.count)")
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button("重新开始") {
                engine.resetGame()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

private struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
