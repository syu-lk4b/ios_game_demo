import XCTest
@testable import AIDungeon

final class DungeonTests: XCTestCase {
    func testDungeonInitialization() {
        let dungeon = Dungeon(size: 5, theme: "废弃矿洞")
        XCTAssertEqual(dungeon.size, 5)
        XCTAssertEqual(dungeon.theme, "废弃矿洞")
        XCTAssertEqual(dungeon.rooms.count, 25)
    }

    func testRoomAccessByPosition() {
        let dungeon = Dungeon(size: 5, theme: "测试地牢")
        let room = dungeon.room(at: Position(row: 2, col: 3))
        XCTAssertNotNil(room)
        XCTAssertEqual(room?.position, Position(row: 2, col: 3))
    }

    func testOutOfBoundsReturnsNil() {
        let dungeon = Dungeon(size: 5, theme: "测试地牢")
        XCTAssertNil(dungeon.room(at: Position(row: 5, col: 0)))
        XCTAssertNil(dungeon.room(at: Position(row: -1, col: 0)))
    }

    func testVisibleRoomsIncludesAdjacentToExplored() {
        var dungeon = Dungeon(size: 5, theme: "测试地牢")
        dungeon.markExplored(Position(row: 0, col: 0))
        let visible = dungeon.visiblePositions()
        XCTAssertTrue(visible.contains(Position(row: 0, col: 0)))
        XCTAssertTrue(visible.contains(Position(row: 0, col: 1)))
        XCTAssertTrue(visible.contains(Position(row: 1, col: 0)))
        XCTAssertFalse(visible.contains(Position(row: 2, col: 2)))
    }

    func testValidMoves() {
        var dungeon = Dungeon(size: 5, theme: "测试地牢")
        dungeon.markExplored(Position(row: 0, col: 0))
        let moves = dungeon.validMoves(from: Position(row: 0, col: 0))
        XCTAssertEqual(Set(moves), Set([Position(row: 0, col: 1), Position(row: 1, col: 0)]))
    }
}
