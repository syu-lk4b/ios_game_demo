import XCTest
@testable import AIDungeon

final class PlayerTests: XCTestCase {
    func testPlayerInitWithWarrior() {
        let player = Player(characterClass: .warrior)
        XCTAssertEqual(player.stats.hp, 120)
        XCTAssertEqual(player.stats.atk, 18)
        XCTAssertEqual(player.stats.def, 15)
        XCTAssertEqual(player.skills.count, 2)
        XCTAssertEqual(player.gold, 0)
        XCTAssertTrue(player.inventory.isEmpty)
    }

    func testAddItem() {
        var player = Player(characterClass: .rogue)
        player.addItem(.healthPotion)
        XCTAssertEqual(player.inventory.count, 1)
        XCTAssertEqual(player.inventory[0].name, "生命药水")
    }

    func testRemoveItem() {
        var player = Player(characterClass: .rogue)
        player.addItem(.healthPotion)
        let removed = player.removeItem(id: "health_potion")
        XCTAssertNotNil(removed)
        XCTAssertTrue(player.inventory.isEmpty)
    }

    func testUseHealthPotion() {
        var player = Player(characterClass: .warrior)
        player.stats.hp = 50
        player.addItem(.healthPotion)
        let used = player.usePotion(id: "health_potion")
        XCTAssertTrue(used)
        XCTAssertEqual(player.stats.hp, 80)
        XCTAssertTrue(player.inventory.isEmpty)
    }

    func testGainGold() {
        var player = Player(characterClass: .mage)
        player.gainGold(50)
        XCTAssertEqual(player.gold, 50)
    }

    func testSpendGold() {
        var player = Player(characterClass: .mage)
        player.gainGold(100)
        let spent = player.spendGold(60)
        XCTAssertTrue(spent)
        XCTAssertEqual(player.gold, 40)
    }

    func testSpendGoldInsufficientFunds() {
        var player = Player(characterClass: .mage)
        player.gainGold(10)
        let spent = player.spendGold(60)
        XCTAssertFalse(spent)
        XCTAssertEqual(player.gold, 10)
    }
}
