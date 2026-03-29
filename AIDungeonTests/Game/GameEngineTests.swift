import XCTest
@testable import AIDungeon

final class GameEngineTests: XCTestCase {
    func testInitialStateIsCharacterSelect() {
        let engine = GameEngine()
        XCTAssertEqual(engine.state, .characterSelect)
    }

    func testStartGameTransitionsToExploring() {
        let engine = GameEngine()
        engine.startGame(characterClass: .warrior)
        XCTAssertEqual(engine.state, .exploring)
        XCTAssertNotNil(engine.player)
        XCTAssertNotNil(engine.dungeon)
        XCTAssertEqual(engine.player?.characterClass, .warrior)
    }

    func testMovePlayerToAdjacentRoom() {
        let engine = GameEngine()
        engine.startGame(characterClass: .warrior)
        let moved = engine.movePlayer(to: Position(row: 0, col: 1))
        XCTAssertTrue(moved)
        XCTAssertEqual(engine.player?.position, Position(row: 0, col: 1))
    }

    func testCannotMoveToNonAdjacentRoom() {
        let engine = GameEngine()
        engine.startGame(characterClass: .warrior)
        let moved = engine.movePlayer(to: Position(row: 2, col: 2))
        XCTAssertFalse(moved)
        XCTAssertEqual(engine.player?.position, Position(row: 0, col: 0))
    }

    func testMovingToMonsterRoomTriggersBattle() {
        let engine = GameEngine()
        engine.startGame(characterClass: .warrior)
        engine.dungeon?.updateRoom(at: Position(row: 0, col: 1)) { room in
            room.event = .monster(Monster.goblin())
        }
        _ = engine.movePlayer(to: Position(row: 0, col: 1))
        XCTAssertEqual(engine.state, .battle)
    }

    func testMovingToNPCRoomTriggersChat() {
        let engine = GameEngine()
        engine.startGame(characterClass: .mage)
        engine.dungeon?.updateRoom(at: Position(row: 0, col: 1)) { room in
            room.event = .npc(name: "测试NPC", description: "一个测试用NPC", personality: "友善")
        }
        _ = engine.movePlayer(to: Position(row: 0, col: 1))
        XCTAssertEqual(engine.state, .chat)
    }

    func testTreasureRoomAddsGold() {
        let engine = GameEngine()
        engine.startGame(characterClass: .rogue)
        engine.dungeon?.updateRoom(at: Position(row: 0, col: 1)) { room in
            room.event = .treasure(gold: 25, item: .healthPotion)
        }
        _ = engine.movePlayer(to: Position(row: 0, col: 1))
        XCTAssertEqual(engine.player?.gold, 25)
        XCTAssertEqual(engine.player?.inventory.count, 1)
        XCTAssertEqual(engine.state, .exploring)
    }

    func testTrapRoomDealsDamage() {
        let engine = GameEngine()
        engine.startGame(characterClass: .warrior)
        let hpBefore = engine.player!.stats.hp
        engine.dungeon?.updateRoom(at: Position(row: 0, col: 1)) { room in
            room.event = .trap(damage: 15)
        }
        _ = engine.movePlayer(to: Position(row: 0, col: 1))
        XCTAssertLessThan(engine.player!.stats.hp, hpBefore)
    }

    func testResetGame() {
        let engine = GameEngine()
        engine.startGame(characterClass: .warrior)
        engine.resetGame()
        XCTAssertEqual(engine.state, .characterSelect)
        XCTAssertNil(engine.player)
        XCTAssertNil(engine.dungeon)
    }
}
