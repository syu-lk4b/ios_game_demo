import XCTest
@testable import AIDungeon

final class StatsTests: XCTestCase {
    func testStatsInitialization() {
        let stats = Stats(hp: 100, maxHp: 100, atk: 15, def: 10)
        XCTAssertEqual(stats.hp, 100)
        XCTAssertEqual(stats.maxHp, 100)
        XCTAssertEqual(stats.atk, 15)
        XCTAssertEqual(stats.def, 10)
    }

    func testTakeDamageReducesHp() {
        var stats = Stats(hp: 100, maxHp: 100, atk: 15, def: 10)
        let actualDamage = stats.takeDamage(raw: 20)
        XCTAssertEqual(actualDamage, 10)
        XCTAssertEqual(stats.hp, 90)
    }

    func testTakeDamageMinimumOne() {
        var stats = Stats(hp: 100, maxHp: 100, atk: 5, def: 50)
        let actualDamage = stats.takeDamage(raw: 10)
        XCTAssertEqual(actualDamage, 1)
        XCTAssertEqual(stats.hp, 99)
    }

    func testTakeDamageWithDefenseMultiplier() {
        var stats = Stats(hp: 100, maxHp: 100, atk: 15, def: 10)
        let actualDamage = stats.takeDamage(raw: 20, defenseMultiplier: 2.0)
        XCTAssertEqual(actualDamage, 1)
    }

    func testHealClampsToMax() {
        var stats = Stats(hp: 50, maxHp: 100, atk: 15, def: 10)
        stats.heal(80)
        XCTAssertEqual(stats.hp, 100)
    }

    func testIsAlive() {
        var stats = Stats(hp: 1, maxHp: 100, atk: 15, def: 10)
        XCTAssertTrue(stats.isAlive)
        _ = stats.takeDamage(raw: 200)
        XCTAssertFalse(stats.isAlive)
    }
}
