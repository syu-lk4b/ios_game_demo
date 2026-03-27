import Foundation

enum RoomEvent {
    case empty
    case monster(Monster)
    case npc(name: String, description: String, personality: String)
    case treasure(gold: Int, item: Item?)
    case trap(damage: Int)
    case boss(Monster)
    case entrance
}
