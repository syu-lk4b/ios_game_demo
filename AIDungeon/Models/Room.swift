import Foundation

struct Room {
    let position: Position
    var event: RoomEvent
    var isExplored: Bool
    var description: String

    init(position: Position, event: RoomEvent = .empty, description: String = "") {
        self.position = position
        self.event = event
        self.isExplored = false
        self.description = description
    }
}
