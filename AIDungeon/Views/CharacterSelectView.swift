import SwiftUI

struct CharacterSelectView: View {
    let engine: GameEngine
    let aiGenerator: AIContentGenerator

    var body: some View {
        VStack(spacing: 24) {
            Text("选择角色")
                .font(.title.bold())

            ForEach(CharacterClass.allCases, id: \.self) { cls in
                Button {
                    Task {
                        let theme = await aiGenerator.generateTheme()
                        engine.startGame(characterClass: cls, theme: theme.name)
                    }
                } label: {
                    HStack(spacing: 16) {
                        Text(cls.icon)
                            .font(.largeTitle)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(cls.rawValue)
                                .font(.headline)
                            let stats = cls.baseStats
                            Text("HP:\(stats.maxHp) ATK:\(stats.atk) DEF:\(stats.def)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(cls.skills.map(\.name).joined(separator: "、"))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}
