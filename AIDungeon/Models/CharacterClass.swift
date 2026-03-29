import Foundation

enum CharacterClass: String, CaseIterable, Codable {
    case warrior = "战士"
    case mage = "法师"
    case rogue = "盗贼"

    var baseStats: Stats {
        switch self {
        case .warrior: return Stats(hp: 120, maxHp: 120, atk: 18, def: 15)
        case .mage:    return Stats(hp: 80, maxHp: 80, atk: 25, def: 8)
        case .rogue:   return Stats(hp: 90, maxHp: 90, atk: 20, def: 10)
        }
    }

    var skills: [Skill] {
        switch self {
        case .warrior: return [.heavyStrike, .taunt]
        case .mage:    return [.fireball, .heal]
        case .rogue:   return [.steal, .poisonBlade]
        }
    }

    var icon: String {
        switch self {
        case .warrior: return "⚔️"
        case .mage:    return "🔮"
        case .rogue:   return "🗡️"
        }
    }
}
