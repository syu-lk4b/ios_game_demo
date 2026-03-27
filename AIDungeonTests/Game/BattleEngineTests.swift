import XCTest
@testable import AIDungeon

final class BattleEngineTests: XCTestCase {
    func testAttackDealsDamage() {
        var player = Player(characterClass: .warrior)
        var monster = Monster.goblin()
        let result = BattleEngine.executePlayerAction(.attack, player: &player, monster: &monster)
        XCTAssertEqual(result.damageToMonster, 13)
        XCTAssertEqual(monster.stats.hp, 27)
    }

    func testDefendReducesDamage() {
        var player = Player(characterClass: .warrior)
        var monster = Monster.goblin()
        let result = BattleEngine.executePlayerAction(.defend, player: &player, monster: &monster)
        XCTAssertTrue(result.playerDefending)
        XCTAssertEqual(result.damageToPlayer, 1)
    }

    func testSkillDealsDamage() {
        var player = Player(characterClass: .mage)
        var monster = Monster.goblin()
        let result = BattleEngine.executePlayerAction(.skill(Skill.fireball), player: &player, monster: &monster)
        XCTAssertEqual(result.damageToMonster, 20)
        XCTAssertEqual(monster.stats.hp, 20)
    }

    func testHealingSkill() {
        var player = Player(characterClass: .mage)
        player.stats.hp = 50
        var monster = Monster.goblin()
        let result = BattleEngine.executePlayerAction(.skill(Skill.heal), player: &player, monster: &monster)
        XCTAssertEqual(result.healingDone, 30)
        XCTAssertEqual(player.stats.hp, 80)
    }

    func testUsePotion() {
        var player = Player(characterClass: .warrior)
        player.stats.hp = 50
        player.addItem(.healthPotion)
        var monster = Monster.goblin()
        let result = BattleEngine.executePlayerAction(.useItem(Item.healthPotion), player: &player, monster: &monster)
        XCTAssertEqual(result.healingDone, 30)
        XCTAssertEqual(player.stats.hp, 80)
        XCTAssertTrue(player.inventory.isEmpty)
    }

    func testMonsterCounterattacks() {
        var player = Player(characterClass: .warrior)
        var monster = Monster.goblin()
        let result = BattleEngine.executePlayerAction(.attack, player: &player, monster: &monster)
        XCTAssertGreaterThan(result.damageToPlayer, 0)
    }

    func testMonsterDeathNoCounterattack() {
        var player = Player(characterClass: .warrior)
        var monster = Monster.goblin()
        monster.stats.hp = 1
        let result = BattleEngine.executePlayerAction(.attack, player: &player, monster: &monster)
        XCTAssertFalse(monster.stats.isAlive)
        XCTAssertEqual(result.damageToPlayer, 0)
    }

    func testSkillCooldown() {
        var player = Player(characterClass: .mage)
        var monster = Monster.goblin()
        _ = BattleEngine.executePlayerAction(.skill(Skill.fireball), player: &player, monster: &monster)
        XCTAssertFalse(player.isSkillReady("fireball"))
        player.tickCooldowns()
        XCTAssertFalse(player.isSkillReady("fireball"))
        player.tickCooldowns()
        XCTAssertTrue(player.isSkillReady("fireball"))
    }
}
