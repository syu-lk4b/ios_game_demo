import SpriteKit

final class DungeonMapScene: SKScene {
    private let gridSize = 5
    private let tileSpacing: CGFloat = 4

    var dungeon: Dungeon?
    var playerPosition: Position?
    var onTileTapped: ((Position) -> Void)?

    private var tileSize: CGFloat {
        let available = min(size.width, size.height) - 40
        return (available - CGFloat(gridSize - 1) * tileSpacing) / CGFloat(gridSize)
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        drawGrid()
    }

    func updateMap(dungeon: Dungeon, playerPosition: Position) {
        self.dungeon = dungeon
        self.playerPosition = playerPosition
        removeAllChildren()
        drawGrid()
    }

    private func drawGrid() {
        guard let dungeon, let playerPosition else { return }

        let visiblePositions = dungeon.visiblePositions()
        let totalSize = CGFloat(gridSize) * (tileSize + tileSpacing) - tileSpacing
        let offsetX = (size.width - totalSize) / 2
        let offsetY = (size.height - totalSize) / 2

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let pos = Position(row: row, col: col)
                let x = offsetX + CGFloat(col) * (tileSize + tileSpacing) + tileSize / 2
                let y = offsetY + CGFloat(gridSize - 1 - row) * (tileSize + tileSpacing) + tileSize / 2

                if visiblePositions.contains(pos) {
                    let tile = createTile(for: dungeon.room(at: pos)!, at: CGPoint(x: x, y: y), isPlayer: pos == playerPosition)
                    tile.name = "tile_\(row)_\(col)"
                    addChild(tile)
                } else {
                    let fog = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize), cornerRadius: 4)
                    fog.position = CGPoint(x: x, y: y)
                    fog.fillColor = SKColor(white: 0.15, alpha: 1)
                    fog.strokeColor = SKColor(white: 0.25, alpha: 1)
                    fog.name = "fog_\(row)_\(col)"
                    addChild(fog)
                }
            }
        }
    }

    private func createTile(for room: Room, at point: CGPoint, isPlayer: Bool) -> SKNode {
        let tile = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize), cornerRadius: 4)
        tile.position = point
        tile.fillColor = isPlayer ? SKColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1) : tileColor(for: room)
        tile.strokeColor = isPlayer ? .cyan : SKColor(white: 0.4, alpha: 1)
        tile.lineWidth = isPlayer ? 2 : 1

        let icon = SKLabelNode(text: room.isExplored ? tileIcon(for: room, isPlayer: isPlayer) : "?")
        icon.fontSize = 24
        icon.verticalAlignmentMode = .center
        tile.addChild(icon)

        return tile
    }

    private func tileColor(for room: Room) -> SKColor {
        guard room.isExplored else { return SKColor(white: 0.25, alpha: 1) }
        switch room.event {
        case .entrance: return SKColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1)
        case .monster:  return SKColor(red: 0.6, green: 0.2, blue: 0.2, alpha: 1)
        case .npc:      return SKColor(red: 0.6, green: 0.5, blue: 0.2, alpha: 1)
        case .treasure:  return SKColor(red: 0.7, green: 0.6, blue: 0.1, alpha: 1)
        case .trap:     return SKColor(red: 0.5, green: 0.1, blue: 0.3, alpha: 1)
        case .boss:     return SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1)
        case .empty:    return SKColor(white: 0.3, alpha: 1)
        }
    }

    private func tileIcon(for room: Room, isPlayer: Bool) -> String {
        if isPlayer { return "🧙" }
        switch room.event {
        case .entrance: return "🚪"
        case .monster:  return "👾"
        case .npc:      return "🧑"
        case .treasure: return "📦"
        case .trap:     return "⚠️"
        case .boss:     return "💀"
        case .empty:    return "·"
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for node in nodes(at: location) {
            guard let name = node.name else { continue }
            let parseName = name.hasPrefix("tile_") ? name : (node.parent?.name ?? "")
            guard parseName.hasPrefix("tile_") else { continue }
            let parts = parseName.split(separator: "_")
            guard parts.count == 3, let row = Int(parts[1]), let col = Int(parts[2]) else { continue }
            onTileTapped?(Position(row: row, col: col))
            return
        }
    }
}
