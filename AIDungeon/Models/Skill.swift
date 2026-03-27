import Foundation

struct Skill: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let manaCost: Int
    let damage: Int
    let healing: Int
    let cooldown: Int

    static let heavyStrike = Skill(id: "heavy_strike", name: "重击", description: "造成1.5倍攻击伤害", manaCost: 0, damage: 0, healing: 0, cooldown: 2)
    static let taunt = Skill(id: "taunt", name: "嘲讽", description: "迫使敌人下回合攻击你，防御+50%", manaCost: 0, damage: 0, healing: 0, cooldown: 3)
    static let fireball = Skill(id: "fireball", name: "火球", description: "造成高额火属性伤害", manaCost: 0, damage: 25, healing: 0, cooldown: 2)
    static let heal = Skill(id: "heal", name: "治愈", description: "恢复30点生命", manaCost: 0, damage: 0, healing: 30, cooldown: 3)
    static let steal = Skill(id: "steal", name: "偷窃", description: "有概率偷取敌人物品", manaCost: 0, damage: 0, healing: 0, cooldown: 2)
    static let poisonBlade = Skill(id: "poison_blade", name: "毒刃", description: "攻击并附加中毒效果", manaCost: 0, damage: 15, healing: 0, cooldown: 2)
}
