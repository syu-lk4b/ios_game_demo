import Foundation

struct Monster {
    let name: String
    let description: String
    var stats: Stats
    let behavior: MonsterBehavior
    let skills: [Skill]
    let lootGold: ClosedRange<Int>
    let xpReward: Int
    var berserkTriggered: Bool = false

    static func goblin() -> Monster {
        Monster(name: "哥布林", description: "一只狡猾的小型怪物", stats: Stats(hp: 40, maxHp: 40, atk: 12, def: 5), behavior: .melee, skills: [], lootGold: 5...15, xpReward: 10)
    }

    static func skeleton() -> Monster {
        Monster(name: "骷髅弓手", description: "远处传来弓弦拉动的声音", stats: Stats(hp: 30, maxHp: 30, atk: 18, def: 3), behavior: .ranged, skills: [Skill(id: "arrow_rain", name: "箭雨", description: "射出多支箭矢", manaCost: 0, damage: 20, healing: 0, cooldown: 3)], lootGold: 8...20, xpReward: 15)
    }

    static func dungeonBoss(name: String, description: String) -> Monster {
        Monster(name: name, description: description, stats: Stats(hp: 200, maxHp: 200, atk: 25, def: 12), behavior: .boss, skills: [
            Skill(id: "boss_slam", name: "震地", description: "对玩家造成大量伤害", manaCost: 0, damage: 35, healing: 0, cooldown: 3),
            Skill(id: "boss_rage", name: "狂怒", description: "攻击力大幅提升", manaCost: 0, damage: 0, healing: 0, cooldown: 5)
        ], lootGold: 50...100, xpReward: 100)
    }
}
