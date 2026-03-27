import Foundation

struct Stats: Codable {
    var hp: Int
    let maxHp: Int
    var atk: Int
    var def: Int

    var isAlive: Bool { hp > 0 }

    @discardableResult
    mutating func takeDamage(raw: Int, defenseMultiplier: Double = 1.0) -> Int {
        let effectiveDef = Int(Double(def) * defenseMultiplier)
        let damage = max(1, raw - effectiveDef)
        hp = max(0, hp - damage)
        return damage
    }

    mutating func heal(_ amount: Int) {
        hp = min(maxHp, hp + amount)
    }
}
