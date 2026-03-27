import Foundation

struct Dungeon {
    let size: Int
    let theme: String
    var rooms: [Room]

    init(size: Int, theme: String) {
        self.size = size
        self.theme = theme
        self.rooms = (0..<size).flatMap { row in
            (0..<size).map { col in
                Room(position: Position(row: row, col: col))
            }
        }
    }

    func room(at position: Position) -> Room? {
        guard position.row >= 0, position.row < size, position.col >= 0, position.col < size else { return nil }
        return rooms[position.row * size + position.col]
    }

    mutating func updateRoom(at position: Position, _ transform: (inout Room) -> Void) {
        guard position.row >= 0, position.row < size, position.col >= 0, position.col < size else { return }
        let index = position.row * size + position.col
        transform(&rooms[index])
    }

    mutating func markExplored(_ position: Position) {
        updateRoom(at: position) { $0.isExplored = true }
    }

    func visiblePositions() -> Set<Position> {
        var visible = Set<Position>()
        for room in rooms where room.isExplored {
            visible.insert(room.position)
            for neighbor in adjacentPositions(room.position) {
                visible.insert(neighbor)
            }
        }
        return visible
    }

    func validMoves(from position: Position) -> [Position] {
        adjacentPositions(position)
    }

    private func adjacentPositions(_ pos: Position) -> [Position] {
        let offsets = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        return offsets.compactMap { dr, dc in
            let p = Position(row: pos.row + dr, col: pos.col + dc)
            guard p.row >= 0, p.row < size, p.col >= 0, p.col < size else { return nil }
            return p
        }
    }
}
