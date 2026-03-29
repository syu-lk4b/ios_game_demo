import Foundation

struct Position: Equatable, Hashable, Codable {
    let row: Int
    let col: Int

    func isAdjacent(to other: Position) -> Bool {
        let dr = abs(row - other.row)
        let dc = abs(col - other.col)
        return (dr + dc) == 1
    }
}
