import Foundation

enum DungeonGenerator {
    static func generate(size: Int, theme: String) -> Dungeon {
        var dungeon = Dungeon(size: size, theme: theme)

        // 1. Entrance at (0,0)
        dungeon.updateRoom(at: Position(row: 0, col: 0)) { room in
            room.event = .entrance
            room.isExplored = true
            room.description = "地牢入口。身后的大门已经关闭。"
        }

        // 2. Boss room far from entrance
        let bossPos = Position(row: size - 1, col: size - 1)
        dungeon.updateRoom(at: bossPos) { room in
            room.event = .boss(Monster.dungeonBoss(name: "地牢守卫", description: "一个巨大的黑暗生物"))
            room.description = "一股强大的气息从前方传来..."
        }

        // 3. Collect remaining positions
        var available = (0..<size).flatMap { row in
            (0..<size).compactMap { col -> Position? in
                let pos = Position(row: row, col: col)
                if pos == Position(row: 0, col: 0) || pos == bossPos { return nil }
                return pos
            }
        }
        available.shuffle()

        // 4. Place 1-2 NPCs
        let npcCount = Int.random(in: 1...2)
        for i in 0..<npcCount where !available.isEmpty {
            let pos = available.removeFirst()
            dungeon.updateRoom(at: pos) { room in
                room.event = .npc(
                    name: Self.randomNPCName(index: i),
                    description: "一位神秘的旅者",
                    personality: "友善但警惕"
                )
            }
        }

        // 5. Place monsters (6-8 rooms)
        let monsterCount = min(Int.random(in: 6...8), available.count)
        for _ in 0..<monsterCount where !available.isEmpty {
            let pos = available.removeFirst()
            let monster = Bool.random() ? Monster.goblin() : Monster.skeleton()
            dungeon.updateRoom(at: pos) { room in
                room.event = .monster(monster)
            }
        }

        // 6. Place treasures (2-3 rooms)
        let treasureCount = min(Int.random(in: 2...3), available.count)
        for _ in 0..<treasureCount where !available.isEmpty {
            let pos = available.removeFirst()
            let hasItem = Bool.random()
            dungeon.updateRoom(at: pos) { room in
                room.event = .treasure(
                    gold: Int.random(in: 10...30),
                    item: hasItem ? .healthPotion : nil
                )
            }
        }

        // 7. Place traps (1-2 rooms)
        let trapCount = min(Int.random(in: 1...2), available.count)
        for _ in 0..<trapCount where !available.isEmpty {
            let pos = available.removeFirst()
            dungeon.updateRoom(at: pos) { room in
                room.event = .trap(damage: Int.random(in: 10...20))
            }
        }

        return dungeon
    }

    private static func randomNPCName(index: Int) -> String {
        let names = ["老铁匠马库斯", "流浪商人莉娜", "隐居学者艾文", "神秘吟游诗人"]
        return names[index % names.count]
    }
}
