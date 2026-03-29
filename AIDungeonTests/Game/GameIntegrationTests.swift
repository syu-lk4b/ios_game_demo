import XCTest
@testable import AIDungeon

final class GameIntegrationTests: XCTestCase {
    func testFullGameLoopWithoutAI() {
        let engine = GameEngine()

        // 1. Start game
        engine.startGame(characterClass: .warrior, theme: "测试地牢")
        XCTAssertEqual(engine.state, .exploring)
        XCTAssertEqual(engine.player?.position, Position(row: 0, col: 0))

        // 2. Force a known layout for deterministic testing
        engine.dungeon?.updateRoom(at: Position(row: 0, col: 1)) { $0.event = .treasure(gold: 20, item: .healthPotion) }
        engine.dungeon?.updateRoom(at: Position(row: 1, col: 1)) { $0.event = .monster(Monster.goblin()) }

        // 3. Move to treasure room
        _ = engine.movePlayer(to: Position(row: 0, col: 1))
        XCTAssertEqual(engine.state, .exploring)
        XCTAssertEqual(engine.player?.gold, 20)
        XCTAssertEqual(engine.player?.inventory.count, 1)

        // 4. Move to adjacent position first (need to go through (1,0) to reach (1,1))
        engine.dungeon?.updateRoom(at: Position(row: 1, col: 0)) { $0.event = .empty }
        _ = engine.movePlayer(to: Position(row: 0, col: 0))
        _ = engine.movePlayer(to: Position(row: 1, col: 0))

        // 5. Now move to monster room
        _ = engine.movePlayer(to: Position(row: 1, col: 1))
        XCTAssertEqual(engine.state, .battle)
        XCTAssertNotNil(engine.currentMonster)

        // 6. Fight the monster
        while engine.currentMonster?.stats.isAlive == true && engine.player?.stats.isAlive == true {
            if var player = engine.player, var monster = engine.currentMonster {
                _ = BattleEngine.executePlayerAction(.attack, player: &player, monster: &monster)
                engine.player = player
                engine.currentMonster = monster
                if !monster.stats.isAlive || !player.stats.isAlive {
                    engine.finishBattle()
                }
            }
        }

        // 7. After battle, should be exploring or game over
        XCTAssertTrue(engine.state == .exploring || engine.state == .gameOver)

        // 8. Reset
        engine.resetGame()
        XCTAssertEqual(engine.state, .characterSelect)
    }
}
