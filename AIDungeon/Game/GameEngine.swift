import Foundation
import Observation

@Observable
final class GameEngine {
    var state: GameState = .characterSelect
    var player: Player?
    var dungeon: Dungeon?
    var currentMonster: Monster?
    var currentNPC: (name: String, description: String, personality: String)?
    var lastEventMessage: String?

    func startGame(characterClass: CharacterClass, theme: String = "黑暗地牢") {
        player = Player(characterClass: characterClass)
        dungeon = DungeonGenerator.generate(size: 5, theme: theme)
        state = .exploring
        lastEventMessage = nil
    }

    func movePlayer(to position: Position) -> Bool {
        guard state == .exploring,
              var p = player,
              var d = dungeon,
              p.position.isAdjacent(to: position),
              d.room(at: position) != nil else { return false }

        p.position = position
        d.markExplored(position)
        player = p
        dungeon = d

        handleRoomEvent(at: position)
        return true
    }

    func finishBattle() {
        currentMonster = nil
        if player?.stats.isAlive == true {
            state = .exploring
        } else {
            state = .gameOver
        }
    }

    func finishChat() {
        currentNPC = nil
        state = .exploring
    }

    func resetGame() {
        state = .characterSelect
        player = nil
        dungeon = nil
        currentMonster = nil
        currentNPC = nil
        lastEventMessage = nil
    }

    private func handleRoomEvent(at position: Position) {
        guard let room = dungeon?.room(at: position) else { return }

        switch room.event {
        case .entrance, .empty:
            lastEventMessage = room.description.isEmpty ? nil : room.description

        case .monster(let monster):
            currentMonster = monster
            state = .battle

        case .npc(let name, let description, let personality):
            currentNPC = (name, description, personality)
            state = .chat

        case .treasure(let gold, let item):
            player?.gainGold(gold)
            if let item { player?.addItem(item) }
            lastEventMessage = "发现宝箱！获得 \(gold) 金币" + (item != nil ? "和 \(item!.name)" : "")
            dungeon?.updateRoom(at: position) { $0.event = .empty }

        case .trap(let damage):
            player?.stats.takeDamage(raw: damage, defenseMultiplier: 0)
            if player?.stats.isAlive == false {
                state = .gameOver
            }
            lastEventMessage = "触发陷阱！受到 \(damage) 点伤害"
            dungeon?.updateRoom(at: position) { $0.event = .empty }

        case .boss(let monster):
            currentMonster = monster
            state = .battle
        }
    }
}
