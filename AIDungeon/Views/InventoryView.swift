import SwiftUI

struct InventoryView: View {
    let engine: GameEngine

    var body: some View {
        NavigationStack {
            List {
                if let player = engine.player {
                    Section("状态") {
                        LabeledContent("HP", value: "\(player.stats.hp)/\(player.stats.maxHp)")
                        LabeledContent("ATK", value: "\(player.stats.atk)")
                        LabeledContent("DEF", value: "\(player.stats.def)")
                        LabeledContent("金币", value: "\(player.gold)")
                    }

                    Section("物品 (\(player.inventory.count))") {
                        if player.inventory.isEmpty {
                            Text("背包空空如也")
                                .foregroundStyle(.secondary)
                        }
                        ForEach(player.inventory) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.body)
                                    Text(item.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(item.type.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(.secondary.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    if !player.hints.isEmpty {
                        Section("线索") {
                            ForEach(player.hints, id: \.self) { hint in
                                Label(hint, systemImage: "lightbulb")
                            }
                        }
                    }
                }
            }
            .navigationTitle("背包")
        }
    }
}
