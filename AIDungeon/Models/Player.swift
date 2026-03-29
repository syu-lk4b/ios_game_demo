import Foundation

struct Player {
    let characterClass: CharacterClass
    var stats: Stats
    var skills: [Skill]
    var inventory: [Item]
    var gold: Int
    var position: Position
    var hints: [String]
    var skillCooldowns: [String: Int]

    init(characterClass: CharacterClass) {
        self.characterClass = characterClass
        self.stats = characterClass.baseStats
        self.skills = characterClass.skills
        self.inventory = []
        self.gold = 0
        self.position = Position(row: 0, col: 0)
        self.hints = []
        self.skillCooldowns = [:]
    }

    mutating func addItem(_ item: Item) {
        inventory.append(item)
    }

    @discardableResult
    mutating func removeItem(id: String) -> Item? {
        guard let index = inventory.firstIndex(where: { $0.id == id }) else { return nil }
        return inventory.remove(at: index)
    }

    mutating func usePotion(id: String) -> Bool {
        guard let item = inventory.first(where: { $0.id == id && $0.type == .potion }) else { return false }
        stats.heal(item.value)
        removeItem(id: id)
        return true
    }

    mutating func gainGold(_ amount: Int) {
        gold += amount
    }

    mutating func spendGold(_ amount: Int) -> Bool {
        guard gold >= amount else { return false }
        gold -= amount
        return true
    }

    mutating func tickCooldowns() {
        for key in skillCooldowns.keys {
            skillCooldowns[key] = max(0, (skillCooldowns[key] ?? 0) - 1)
        }
    }

    func isSkillReady(_ skillId: String) -> Bool {
        (skillCooldowns[skillId] ?? 0) == 0
    }
}
