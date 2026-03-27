import XCTest
@testable import AIDungeon

final class MonsterAITests: XCTestCase {
    func testMeleeMonsterAttacksWhenHealthy() {
        var monster = Monster.goblin()
        monster.stats.hp = monster.stats.maxHp
        let action = MonsterAI.decideAction(for: &monster)
        XCTAssertEqual(action, .attack)
    }

    func testMeleeMonsterBerserksWhenLowHp() {
        var monster = Monster.goblin()
        monster.stats.hp = 10
        let action = MonsterAI.decideAction(for: &monster)
        XCTAssertEqual(action, .berserk)
        XCTAssertTrue(monster.berserkTriggered)
    }

    func testBerserkDoublesAtk() {
        var monster = Monster.goblin()
        let originalAtk = monster.stats.atk
        monster.stats.hp = 5
        _ = MonsterAI.decideAction(for: &monster)
        XCTAssertEqual(monster.stats.atk, originalAtk * 2)
    }

    func testBerserkOnlyTriggersOnce() {
        var monster = Monster.goblin()
        monster.stats.hp = 5
        _ = MonsterAI.decideAction(for: &monster)
        let atkAfterFirst = monster.stats.atk
        _ = MonsterAI.decideAction(for: &monster)
        XCTAssertEqual(monster.stats.atk, atkAfterFirst)
    }

    func testRangedMonsterUsesSkillWhenAvailable() {
        var monster = Monster.skeleton()
        let action = MonsterAI.decideAction(for: &monster)
        if case .useSkill(let skill) = action {
            XCTAssertEqual(skill.id, "arrow_rain")
        } else {
            XCTFail("Expected ranged monster to use skill, got \(action)")
        }
    }

    func testBossUsesSkillOrAttacks() {
        var monster = Monster.dungeonBoss(name: "Boss", description: "Test boss")
        monster.stats.hp = 100
        let action = MonsterAI.decideAction(for: &monster)
        switch action {
        case .useSkill, .attack:
            break
        default:
            XCTFail("Boss should attack or use skill")
        }
    }
}
