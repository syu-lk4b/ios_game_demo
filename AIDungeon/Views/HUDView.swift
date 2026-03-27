import SwiftUI

struct HUDView: View {
    let engine: GameEngine

    var body: some View {
        if let player = engine.player {
            HStack {
                Label("\(player.stats.hp)/\(player.stats.maxHp)", systemImage: "heart.fill")
                    .foregroundStyle(.red)

                Spacer()

                Label("\(player.gold)", systemImage: "bitcoinsign.circle.fill")
                    .foregroundStyle(.yellow)

                Spacer()

                Text(player.characterClass.icon + " " + player.characterClass.rawValue)
            }
            .font(.subheadline.bold())
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
