import XCTest
@testable import AIDungeon

final class DungeonGeneratorTests: XCTestCase {
    func testGeneratesCorrectSize() {
        let dungeon = DungeonGenerator.generate(size: 5, theme: "测试")
        XCTAssertEqual(dungeon.rooms.count, 25)
    }

    func testEntranceAtOrigin() {
        let dungeon = DungeonGenerator.generate(size: 5, theme: "测试")
        let entrance = dungeon.room(at: Position(row: 0, col: 0))!
        if case .entrance = entrance.event {
            // correct
        } else {
            XCTFail("Expected entrance at (0,0)")
        }
    }

    func testBossRoomExists() {
        let dungeon = DungeonGenerator.generate(size: 5, theme: "测试")
        let hasBoss = dungeon.rooms.contains { room in
            if case .boss = room.event { return true }
            return false
        }
        XCTAssertTrue(hasBoss)
    }

    func testBossRoomFarFromEntrance() {
        let dungeon = DungeonGenerator.generate(size: 5, theme: "测试")
        let bossRoom = dungeon.rooms.first { room in
            if case .boss = room.event { return true }
            return false
        }!
        let dist = bossRoom.position.row + bossRoom.position.col
        XCTAssertGreaterThanOrEqual(dist, 4)
    }

    func testHasNPCRooms() {
        let dungeon = DungeonGenerator.generate(size: 5, theme: "测试")
        let npcCount = dungeon.rooms.filter { room in
            if case .npc = room.event { return true }
            return false
        }.count
        XCTAssertGreaterThanOrEqual(npcCount, 1)
        XCTAssertLessThanOrEqual(npcCount, 2)
    }

    func testHasMonsterRooms() {
        let dungeon = DungeonGenerator.generate(size: 5, theme: "测试")
        let monsterCount = dungeon.rooms.filter { room in
            if case .monster = room.event { return true }
            return false
        }.count
        XCTAssertGreaterThan(monsterCount, 0)
    }

    func testEntranceIsExplored() {
        let dungeon = DungeonGenerator.generate(size: 5, theme: "测试")
        let entrance = dungeon.room(at: Position(row: 0, col: 0))!
        XCTAssertTrue(entrance.isExplored)
    }
}
