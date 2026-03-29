import Foundation
import GameplayKit

enum MonsterAction: Equatable {
    case attack
    case berserk
    case useSkill(Skill)
    case defend

    static func == (lhs: MonsterAction, rhs: MonsterAction) -> Bool {
        switch (lhs, rhs) {
        case (.attack, .attack): return true
        case (.berserk, .berserk): return true
        case (.defend, .defend): return true
        case (.useSkill(let a), .useSkill(let b)): return a.id == b.id
        default: return false
        }
    }
}

enum MonsterAI {
    static func decideAction(for monster: inout Monster) -> MonsterAction {
        switch monster.behavior {
        case .melee:
            return decideMelee(for: &monster)
        case .ranged:
            return decideRanged(for: &monster)
        case .boss:
            return decideBoss(for: &monster)
        }
    }

    private static func decideMelee(for monster: inout Monster) -> MonsterAction {
        let hpPercent = Double(monster.stats.hp) / Double(monster.stats.maxHp)
        if hpPercent <= 0.25 && !monster.berserkTriggered {
            monster.berserkTriggered = true
            monster.stats.atk *= 2
            return .berserk
        }
        return .attack
    }

    private static func decideRanged(for monster: inout Monster) -> MonsterAction {
        if let skill = monster.skills.first {
            return .useSkill(skill)
        }
        return .attack
    }

    private static func decideBoss(for monster: inout Monster) -> MonsterAction {
        let hpPercent = Double(monster.stats.hp) / Double(monster.stats.maxHp)
        if hpPercent <= 0.50 && !monster.berserkTriggered {
            monster.berserkTriggered = true
            monster.stats.atk = Int(Double(monster.stats.atk) * 1.5)
            if let rageSkill = monster.skills.first(where: { $0.id == "boss_rage" }) {
                return .useSkill(rageSkill)
            }
        }
        if let slamSkill = monster.skills.first(where: { $0.id == "boss_slam" }) {
            if GKRandomDistribution(lowestValue: 1, highestValue: 100).nextInt() <= 30 {
                return .useSkill(slamSkill)
            }
        }
        return .attack
    }
}
