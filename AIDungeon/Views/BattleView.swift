import SwiftUI

struct BattleView: View {
    let engine: GameEngine
    @State private var battleLog: [String] = []
    @State private var isAnimating = false

    private var player: Player? { engine.player }
    private var monster: Monster? { engine.currentMonster }

    var body: some View {
        VStack(spacing: 16) {
            if let monster {
                VStack(spacing: 4) {
                    Text(monster.name)
                        .font(.title2.bold())
                    HealthBar(current: monster.stats.hp, max: monster.stats.maxHp, color: .red)
                    Text("HP: \(monster.stats.hp)/\(monster.stats.maxHp)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(battleLog.enumerated()), id: \.offset) { index, log in
                            Text(log)
                                .font(.callout)
                                .id(index)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 200)
                .onChange(of: battleLog.count) { _, _ in
                    if let last = battleLog.indices.last {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }

            Spacer()

            if let player {
                HealthBar(current: player.stats.hp, max: player.stats.maxHp, color: .green)
                Text("HP: \(player.stats.hp)/\(player.stats.maxHp)")
                    .font(.caption)
            }

            if !isAnimating, monster?.stats.isAlive == true, player?.stats.isAlive == true {
                actionButtons
            }
        }
        .padding()
        .onAppear {
            battleLog = ["战斗开始！"]
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                actionButton("攻击", icon: "burst") { performAction(.attack) }
                actionButton("防御", icon: "shield") { performAction(.defend) }
            }

            HStack(spacing: 12) {
                if let player {
                    ForEach(player.skills) { skill in
                        let ready = player.isSkillReady(skill.id)
                        actionButton(skill.name, icon: "sparkles", disabled: !ready) {
                            performAction(.skill(skill))
                        }
                    }
                }
            }

            if let player, player.inventory.contains(where: { $0.type == .potion }) {
                HStack(spacing: 12) {
                    ForEach(player.inventory.filter { $0.type == .potion }) { item in
                        actionButton(item.name, icon: "cross.vial") {
                            performAction(.useItem(item))
                        }
                    }
                }
            }
        }
    }

    private func actionButton(_ title: String, icon: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .disabled(disabled)
    }

    private func performAction(_ action: BattleAction) {
        guard var player = engine.player, var monster = engine.currentMonster else { return }
        isAnimating = true

        let result = BattleEngine.executePlayerAction(action, player: &player, monster: &monster)
        engine.player = player
        engine.currentMonster = monster

        battleLog.append("▸ \(result.playerAction)")
        if result.healingDone > 0 {
            battleLog.append("  ❤️ 恢复 \(result.healingDone) 点生命")
        }
        if !result.monsterAction.isEmpty {
            battleLog.append("◂ \(result.monsterAction)")
        }

        if result.monsterDied {
            let goldReward = Int.random(in: monster.lootGold)
            engine.player?.gainGold(goldReward)
            battleLog.append("🎉 击败了 \(monster.name)！获得 \(goldReward) 金币")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                engine.finishBattle()
            }
        } else if result.playerDied {
            battleLog.append("💀 你被击败了...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                engine.finishBattle()
            }
        }

        isAnimating = false
    }
}

struct HealthBar: View {
    let current: Int
    let max: Int
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(color.opacity(0.3))
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(current) / CGFloat(max))
            }
        }
        .frame(height: 12)
    }
}
