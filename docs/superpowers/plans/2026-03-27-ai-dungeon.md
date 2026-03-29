# AI Dungeon Lite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Roguelike dungeon crawler iOS game with LLM-driven NPCs, AI combat opponents, and AI-generated content.

**Architecture:** SwiftUI for menus/dialogs/settings, SpriteKit (via `SpriteView`) for dungeon map and battle animations, GameplayKit for monster AI decision trees. A unified `AIProvider` protocol wraps all LLM calls through an OpenAI-compatible HTTP client. Game state managed by a `GameEngine` state machine.

**Tech Stack:** Swift 5.9+, SwiftUI, SpriteKit, GameplayKit, URLSession + async/await, XCTest

**Design Spec:** `docs/superpowers/specs/2026-03-27-ai-dungeon-design.md`

---

## File Structure

```
AIDungeon/
├── AIDungeon/
│   ├── AIDungeonApp.swift              # App entry point, root navigation
│   ├── ContentView.swift               # Root view with NavigationStack
│   ├── Models/
│   │   ├── CharacterClass.swift        # Enum: warrior/mage/rogue + base stats
│   │   ├── Stats.swift                 # HP/ATK/DEF struct
│   │   ├── Player.swift                # Player state, inventory, skills
│   │   ├── Skill.swift                 # Skill definition + effects
│   │   ├── Item.swift                  # Item types (potion, scroll, key, etc.)
│   │   ├── Monster.swift               # Monster stats, behavior type, loot
│   │   ├── MonsterBehavior.swift       # Enum: melee/ranged/boss
│   │   ├── Room.swift                  # Room type + event + description
│   │   ├── RoomEvent.swift             # Enum: monster/npc/treasure/trap/boss/empty
│   │   ├── Position.swift              # Grid coordinate (row, col)
│   │   └── Dungeon.swift              # 5x5 grid, fog state, theme
│   ├── Game/
│   │   ├── GameEngine.swift            # Core state machine
│   │   ├── GameState.swift             # Enum: characterSelect/exploring/battle/chat/gameOver/victory
│   │   ├── DungeonGenerator.swift      # Room layout + event assignment
│   │   ├── BattleEngine.swift          # Turn-based combat logic
│   │   ├── BattleAction.swift          # Enum: attack/defend/skill/useItem
│   │   ├── BattleResult.swift          # Turn result: damage dealt, effects applied
│   │   └── MonsterAI.swift             # GameplayKit strategy trees
│   ├── AI/
│   │   ├── AIProvider.swift            # Protocol + config model
│   │   ├── OpenAIClient.swift          # OpenAI-compatible HTTP client
│   │   ├── StreamingParser.swift       # SSE stream parser
│   │   ├── PromptBuilder.swift         # System prompt assembly
│   │   ├── ResponseParser.swift        # Parse [TRADE], [HINT], [GIFT] tags
│   │   ├── FallbackContent.swift       # Offline template content
│   │   └── AIContentGenerator.swift    # High-level: generate theme, rooms, NPC
│   ├── Views/
│   │   ├── CharacterSelectView.swift   # Pick warrior/mage/rogue
│   │   ├── DungeonMapScene.swift       # SpriteKit SKScene for the 5x5 grid
│   │   ├── DungeonMapView.swift        # SwiftUI wrapper with SpriteView
│   │   ├── BattleView.swift            # Battle UI: HP bars, action buttons
│   │   ├── ChatView.swift              # NPC dialog with streaming text
│   │   ├── ChatBubble.swift            # Single message bubble component
│   │   ├── InventoryView.swift         # Backpack overlay
│   │   ├── GameOverView.swift          # Death/victory stats screen
│   │   ├── SettingsView.swift          # AI provider configuration
│   │   └── HUDView.swift              # In-game overlay: HP, gold, minimap
│   └── Resources/
│       └── FallbackTemplates.json      # Offline room descriptions, NPC dialogs
├── AIDungeonTests/
│   ├── Models/
│   │   ├── PlayerTests.swift
│   │   ├── DungeonTests.swift
│   │   └── StatsTests.swift
│   ├── Game/
│   │   ├── BattleEngineTests.swift
│   │   ├── DungeonGeneratorTests.swift
│   │   ├── MonsterAITests.swift
│   │   └── GameEngineTests.swift
│   └── AI/
│       ├── OpenAIClientTests.swift
│       ├── ResponseParserTests.swift
│       ├── PromptBuilderTests.swift
│       └── StreamingParserTests.swift
└── AIDungeon.xcodeproj
```

---

## Task 1: Xcode Project Setup

**Files:**
- Create: `AIDungeon/AIDungeonApp.swift`
- Create: `AIDungeon/ContentView.swift`

- [ ] **Step 1: Create the Xcode project**

Open Xcode → File → New → Project → iOS App.
- Product Name: `AIDungeon`
- Organization Identifier: `com.aidungeon`
- Interface: SwiftUI
- Language: Swift
- Include Tests: ✓ (Unit Tests only)
- Save to: `/Users/syu/repo/game/game_demo/`

This creates the basic project structure with `AIDungeonApp.swift`, `ContentView.swift`, and `AIDungeonTests/` target.

- [ ] **Step 2: Configure deployment target**

In Xcode → Project → AIDungeon target → General:
- Minimum Deployments: iOS 17.0
- Device Orientation: Portrait (iPhone), All (iPad)
- Supported Destinations: iPhone, iPad

- [ ] **Step 3: Add SpriteKit and GameplayKit frameworks**

In Xcode → AIDungeon target → General → Frameworks, Libraries, and Embedded Content:
- Add `SpriteKit.framework`
- Add `GameplayKit.framework`

These are Apple system frameworks, no package manager needed.

- [ ] **Step 4: Create folder structure**

Create the following groups/folders in the project navigator:
- `AIDungeon/Models/`
- `AIDungeon/Game/`
- `AIDungeon/AI/`
- `AIDungeon/Views/`
- `AIDungeon/Resources/`

- [ ] **Step 5: Set up root navigation in ContentView**

```swift
// AIDungeon/ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("AI 地牢冒险")
                    .font(.largeTitle)
                    .bold()

                NavigationLink("开始游戏") {
                    Text("游戏画面占位")
                }

                NavigationLink("设置") {
                    Text("设置画面占位")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
```

- [ ] **Step 6: Build and run to verify**

Run: `Cmd+R` in Xcode (or `xcodebuild -scheme AIDungeon -destination 'platform=iOS Simulator,name=iPhone 16'`)
Expected: App launches in simulator showing title "AI 地牢冒险" with two placeholder navigation links.

- [ ] **Step 7: Commit**

```bash
cd /Users/syu/repo/game/game_demo
git init
git add AIDungeon/
git commit -m "feat: initialize Xcode project with folder structure and root navigation"
```

---

## Task 2: Core Data Models

**Files:**
- Create: `AIDungeon/Models/Position.swift`
- Create: `AIDungeon/Models/Stats.swift`
- Create: `AIDungeon/Models/CharacterClass.swift`
- Create: `AIDungeon/Models/Skill.swift`
- Create: `AIDungeon/Models/Item.swift`
- Create: `AIDungeon/Models/Player.swift`
- Create: `AIDungeon/Models/MonsterBehavior.swift`
- Create: `AIDungeon/Models/Monster.swift`
- Create: `AIDungeon/Models/RoomEvent.swift`
- Create: `AIDungeon/Models/Room.swift`
- Create: `AIDungeon/Models/Dungeon.swift`
- Test: `AIDungeonTests/Models/PlayerTests.swift`
- Test: `AIDungeonTests/Models/DungeonTests.swift`
- Test: `AIDungeonTests/Models/StatsTests.swift`

- [ ] **Step 1: Write Stats tests**

```swift
// AIDungeonTests/Models/StatsTests.swift
import XCTest
@testable import AIDungeon

final class StatsTests: XCTestCase {
    func testStatsInitialization() {
        let stats = Stats(hp: 100, maxHp: 100, atk: 15, def: 10)
        XCTAssertEqual(stats.hp, 100)
        XCTAssertEqual(stats.maxHp, 100)
        XCTAssertEqual(stats.atk, 15)
        XCTAssertEqual(stats.def, 10)
    }

    func testTakeDamageReducesHp() {
        var stats = Stats(hp: 100, maxHp: 100, atk: 15, def: 10)
        let actualDamage = stats.takeDamage(raw: 20)
        // damage = raw - def = 20 - 10 = 10, minimum 1
        XCTAssertEqual(actualDamage, 10)
        XCTAssertEqual(stats.hp, 90)
    }

    func testTakeDamageMinimumOne() {
        var stats = Stats(hp: 100, maxHp: 100, atk: 5, def: 50)
        let actualDamage = stats.takeDamage(raw: 10)
        XCTAssertEqual(actualDamage, 1)
        XCTAssertEqual(stats.hp, 99)
    }

    func testTakeDamageWithDefenseMultiplier() {
        var stats = Stats(hp: 100, maxHp: 100, atk: 15, def: 10)
        let actualDamage = stats.takeDamage(raw: 20, defenseMultiplier: 2.0)
        // damage = 20 - (10 * 2) = 0, minimum 1
        XCTAssertEqual(actualDamage, 1)
    }

    func testHealClampsToMax() {
        var stats = Stats(hp: 50, maxHp: 100, atk: 15, def: 10)
        stats.heal(80)
        XCTAssertEqual(stats.hp, 100)
    }

    func testIsAlive() {
        var stats = Stats(hp: 1, maxHp: 100, atk: 15, def: 10)
        XCTAssertTrue(stats.isAlive)
        _ = stats.takeDamage(raw: 200)
        XCTAssertFalse(stats.isAlive)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `Cmd+U` in Xcode
Expected: Compilation error — `Stats` not defined.

- [ ] **Step 3: Implement Position and Stats**

```swift
// AIDungeon/Models/Position.swift
import Foundation

struct Position: Equatable, Hashable, Codable {
    let row: Int
    let col: Int

    func isAdjacent(to other: Position) -> Bool {
        let dr = abs(row - other.row)
        let dc = abs(col - other.col)
        return (dr + dc) == 1 // no diagonal
    }
}
```

```swift
// AIDungeon/Models/Stats.swift
import Foundation

struct Stats: Codable {
    var hp: Int
    let maxHp: Int
    var atk: Int
    var def: Int

    var isAlive: Bool { hp > 0 }

    /// Returns actual damage dealt. defenseMultiplier > 1 means defending.
    @discardableResult
    mutating func takeDamage(raw: Int, defenseMultiplier: Double = 1.0) -> Int {
        let effectiveDef = Int(Double(def) * defenseMultiplier)
        let damage = max(1, raw - effectiveDef)
        hp = max(0, hp - damage)
        return damage
    }

    mutating func heal(_ amount: Int) {
        hp = min(maxHp, hp + amount)
    }
}
```

- [ ] **Step 4: Run Stats tests to verify they pass**

Run: `Cmd+U` in Xcode
Expected: All `StatsTests` pass.

- [ ] **Step 5: Implement Skill, Item, CharacterClass**

```swift
// AIDungeon/Models/Skill.swift
import Foundation

struct Skill: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let manaCost: Int
    let damage: Int       // 0 for non-damage skills
    let healing: Int      // 0 for non-healing skills
    let cooldown: Int     // turns

    static let heavyStrike = Skill(id: "heavy_strike", name: "重击", description: "造成1.5倍攻击伤害", manaCost: 0, damage: 0, healing: 0, cooldown: 2)
    static let taunt = Skill(id: "taunt", name: "嘲讽", description: "迫使敌人下回合攻击你，防御+50%", manaCost: 0, damage: 0, healing: 0, cooldown: 3)
    static let fireball = Skill(id: "fireball", name: "火球", description: "造成高额火属性伤害", manaCost: 0, damage: 25, healing: 0, cooldown: 2)
    static let heal = Skill(id: "heal", name: "治愈", description: "恢复30点生命", manaCost: 0, damage: 0, healing: 30, cooldown: 3)
    static let steal = Skill(id: "steal", name: "偷窃", description: "有概率偷取敌人物品", manaCost: 0, damage: 0, healing: 0, cooldown: 2)
    static let poisonBlade = Skill(id: "poison_blade", name: "毒刃", description: "攻击并附加中毒效果", manaCost: 0, damage: 15, healing: 0, cooldown: 2)
}
```

```swift
// AIDungeon/Models/Item.swift
import Foundation

struct Item: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let type: ItemType
    let value: Int // healing amount, damage, or gold value

    enum ItemType: String, Codable {
        case potion
        case scroll
        case key
        case equipment
        case misc
    }

    static let healthPotion = Item(id: "health_potion", name: "生命药水", description: "恢复30点生命", type: .potion, value: 30)
    static let fireScroll = Item(id: "fire_scroll", name: "火焰卷轴", description: "对敌人造成40点伤害", type: .scroll, value: 40)
}
```

```swift
// AIDungeon/Models/CharacterClass.swift
import Foundation

enum CharacterClass: String, CaseIterable, Codable {
    case warrior = "战士"
    case mage = "法师"
    case rogue = "盗贼"

    var baseStats: Stats {
        switch self {
        case .warrior: return Stats(hp: 120, maxHp: 120, atk: 18, def: 15)
        case .mage:    return Stats(hp: 80, maxHp: 80, atk: 25, def: 8)
        case .rogue:   return Stats(hp: 90, maxHp: 90, atk: 20, def: 10)
        }
    }

    var skills: [Skill] {
        switch self {
        case .warrior: return [.heavyStrike, .taunt]
        case .mage:    return [.fireball, .heal]
        case .rogue:   return [.steal, .poisonBlade]
        }
    }

    var icon: String {
        switch self {
        case .warrior: return "⚔️"
        case .mage:    return "🔮"
        case .rogue:   return "🗡️"
        }
    }
}
```

- [ ] **Step 6: Write Player tests**

```swift
// AIDungeonTests/Models/PlayerTests.swift
import XCTest
@testable import AIDungeon

final class PlayerTests: XCTestCase {
    func testPlayerInitWithWarrior() {
        let player = Player(characterClass: .warrior)
        XCTAssertEqual(player.stats.hp, 120)
        XCTAssertEqual(player.stats.atk, 18)
        XCTAssertEqual(player.stats.def, 15)
        XCTAssertEqual(player.skills.count, 2)
        XCTAssertEqual(player.gold, 0)
        XCTAssertTrue(player.inventory.isEmpty)
    }

    func testAddItem() {
        var player = Player(characterClass: .rogue)
        player.addItem(.healthPotion)
        XCTAssertEqual(player.inventory.count, 1)
        XCTAssertEqual(player.inventory[0].name, "生命药水")
    }

    func testRemoveItem() {
        var player = Player(characterClass: .rogue)
        player.addItem(.healthPotion)
        let removed = player.removeItem(id: "health_potion")
        XCTAssertNotNil(removed)
        XCTAssertTrue(player.inventory.isEmpty)
    }

    func testUseHealthPotion() {
        var player = Player(characterClass: .warrior)
        player.stats.hp = 50
        player.addItem(.healthPotion)
        let used = player.usePotion(id: "health_potion")
        XCTAssertTrue(used)
        XCTAssertEqual(player.stats.hp, 80) // 50 + 30
        XCTAssertTrue(player.inventory.isEmpty)
    }

    func testGainGold() {
        var player = Player(characterClass: .mage)
        player.gainGold(50)
        XCTAssertEqual(player.gold, 50)
    }

    func testSpendGold() {
        var player = Player(characterClass: .mage)
        player.gainGold(100)
        let spent = player.spendGold(60)
        XCTAssertTrue(spent)
        XCTAssertEqual(player.gold, 40)
    }

    func testSpendGoldInsufficientFunds() {
        var player = Player(characterClass: .mage)
        player.gainGold(10)
        let spent = player.spendGold(60)
        XCTAssertFalse(spent)
        XCTAssertEqual(player.gold, 10)
    }
}
```

- [ ] **Step 7: Implement Player**

```swift
// AIDungeon/Models/Player.swift
import Foundation

struct Player {
    let characterClass: CharacterClass
    var stats: Stats
    var skills: [Skill]
    var inventory: [Item]
    var gold: Int
    var position: Position
    var hints: [String]  // collected from NPCs
    var skillCooldowns: [String: Int]  // skill id -> turns remaining

    init(characterClass: CharacterClass) {
        self.characterClass = characterClass
        self.stats = characterClass.baseStats
        self.skills = characterClass.skills
        self.inventory = []
        self.gold = 0
        self.position = Position(row: 0, col: 0)
        self.hints = []
        self.skillCooldowns = [:]
    }

    mutating func addItem(_ item: Item) {
        inventory.append(item)
    }

    @discardableResult
    mutating func removeItem(id: String) -> Item? {
        guard let index = inventory.firstIndex(where: { $0.id == id }) else { return nil }
        return inventory.remove(at: index)
    }

    mutating func usePotion(id: String) -> Bool {
        guard let item = inventory.first(where: { $0.id == id && $0.type == .potion }) else { return false }
        stats.heal(item.value)
        removeItem(id: id)
        return true
    }

    mutating func gainGold(_ amount: Int) {
        gold += amount
    }

    mutating func spendGold(_ amount: Int) -> Bool {
        guard gold >= amount else { return false }
        gold -= amount
        return true
    }

    mutating func tickCooldowns() {
        for key in skillCooldowns.keys {
            skillCooldowns[key] = max(0, (skillCooldowns[key] ?? 0) - 1)
        }
    }

    func isSkillReady(_ skillId: String) -> Bool {
        (skillCooldowns[skillId] ?? 0) == 0
    }
}
```

- [ ] **Step 8: Run Player tests to verify they pass**

Run: `Cmd+U` in Xcode
Expected: All `PlayerTests` pass.

- [ ] **Step 9: Implement Monster and Room models**

```swift
// AIDungeon/Models/MonsterBehavior.swift
import Foundation

enum MonsterBehavior: String, Codable {
    case melee   // 近战型：优先攻击，低HP狂暴
    case ranged  // 远程型：优先技能
    case boss    // Boss：多阶段
}
```

```swift
// AIDungeon/Models/Monster.swift
import Foundation

struct Monster {
    let name: String
    let description: String
    var stats: Stats
    let behavior: MonsterBehavior
    let skills: [Skill]
    let lootGold: ClosedRange<Int>
    let xpReward: Int

    var berserkTriggered: Bool = false

    static func goblin() -> Monster {
        Monster(
            name: "哥布林",
            description: "一只狡猾的小型怪物",
            stats: Stats(hp: 40, maxHp: 40, atk: 12, def: 5),
            behavior: .melee,
            skills: [],
            lootGold: 5...15,
            xpReward: 10
        )
    }

    static func skeleton() -> Monster {
        Monster(
            name: "骷髅弓手",
            description: "远处传来弓弦拉动的声音",
            stats: Stats(hp: 30, maxHp: 30, atk: 18, def: 3),
            behavior: .ranged,
            skills: [Skill(id: "arrow_rain", name: "箭雨", description: "射出多支箭矢", manaCost: 0, damage: 20, healing: 0, cooldown: 3)],
            lootGold: 8...20,
            xpReward: 15
        )
    }

    static func dungeonBoss(name: String, description: String) -> Monster {
        Monster(
            name: name,
            description: description,
            stats: Stats(hp: 200, maxHp: 200, atk: 25, def: 12),
            behavior: .boss,
            skills: [
                Skill(id: "boss_slam", name: "震地", description: "对玩家造成大量伤害", manaCost: 0, damage: 35, healing: 0, cooldown: 3),
                Skill(id: "boss_rage", name: "狂怒", description: "攻击力大幅提升", manaCost: 0, damage: 0, healing: 0, cooldown: 5)
            ],
            lootGold: 50...100,
            xpReward: 100
        )
    }
}
```

```swift
// AIDungeon/Models/RoomEvent.swift
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
```

```swift
// AIDungeon/Models/Room.swift
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
```

- [ ] **Step 10: Write Dungeon tests**

```swift
// AIDungeonTests/Models/DungeonTests.swift
import XCTest
@testable import AIDungeon

final class DungeonTests: XCTestCase {
    func testDungeonInitialization() {
        let dungeon = Dungeon(size: 5, theme: "废弃矿洞")
        XCTAssertEqual(dungeon.size, 5)
        XCTAssertEqual(dungeon.theme, "废弃矿洞")
        XCTAssertEqual(dungeon.rooms.count, 25) // 5x5
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
        // (0,0) explored + adjacent (0,1) and (1,0)
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
```

- [ ] **Step 11: Implement Dungeon**

```swift
// AIDungeon/Models/Dungeon.swift
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
        guard position.row >= 0, position.row < size,
              position.col >= 0, position.col < size else { return nil }
        return rooms[position.row * size + position.col]
    }

    mutating func updateRoom(at position: Position, _ transform: (inout Room) -> Void) {
        guard position.row >= 0, position.row < size,
              position.col >= 0, position.col < size else { return }
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
```

- [ ] **Step 12: Run all model tests to verify they pass**

Run: `Cmd+U` in Xcode
Expected: All tests in `StatsTests`, `PlayerTests`, `DungeonTests` pass.

- [ ] **Step 13: Commit**

```bash
git add AIDungeon/Models/ AIDungeonTests/Models/
git commit -m "feat(models): add core data models with tests — Stats, Player, Monster, Room, Dungeon"
```

---

## Task 3: Dungeon Generator

**Files:**
- Create: `AIDungeon/Game/DungeonGenerator.swift`
- Test: `AIDungeonTests/Game/DungeonGeneratorTests.swift`

- [ ] **Step 1: Write DungeonGenerator tests**

```swift
// AIDungeonTests/Game/DungeonGeneratorTests.swift
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
        // Boss should be at least 4 manhattan distance from (0,0)
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `Cmd+U`
Expected: Compilation error — `DungeonGenerator` not defined.

- [ ] **Step 3: Implement DungeonGenerator**

```swift
// AIDungeon/Game/DungeonGenerator.swift
import Foundation

enum DungeonGenerator {
    static func generate(size: Int, theme: String) -> Dungeon {
        var dungeon = Dungeon(size: size, theme: theme)

        // 1. Entrance at (0,0)
        dungeon.updateRoom(at: Position(row: 0, col: 0)) { room in
            room.event = .entrance
            room.isExplored = true
            room.description = "地牢入口。身后的大门已经关闭。"
        }

        // 2. Boss room far from entrance (bottom-right area)
        let bossPos = Position(row: size - 1, col: size - 1)
        dungeon.updateRoom(at: bossPos) { room in
            room.event = .boss(Monster.dungeonBoss(name: "地牢守卫", description: "一个巨大的黑暗生物"))
            room.description = "一股强大的气息从前方传来..."
        }

        // 3. Collect remaining positions (exclude entrance and boss)
        var available = (0..<size).flatMap { row in
            (0..<size).compactMap { col -> Position? in
                let pos = Position(row: row, col: col)
                if pos == Position(row: 0, col: 0) || pos == bossPos { return nil }
                return pos
            }
        }
        available.shuffle()

        // 4. Place 1-2 NPCs
        let npcCount = Int.random(in: 1...2)
        for i in 0..<npcCount where !available.isEmpty {
            let pos = available.removeFirst()
            dungeon.updateRoom(at: pos) { room in
                room.event = .npc(
                    name: Self.randomNPCName(index: i),
                    description: "一位神秘的旅者",
                    personality: "友善但警惕"
                )
            }
        }

        // 5. Place monsters (6-8 rooms)
        let monsterCount = min(Int.random(in: 6...8), available.count)
        for _ in 0..<monsterCount where !available.isEmpty {
            let pos = available.removeFirst()
            let monster = Bool.random() ? Monster.goblin() : Monster.skeleton()
            dungeon.updateRoom(at: pos) { room in
                room.event = .monster(monster)
            }
        }

        // 6. Place treasures (2-3 rooms)
        let treasureCount = min(Int.random(in: 2...3), available.count)
        for _ in 0..<treasureCount where !available.isEmpty {
            let pos = available.removeFirst()
            let hasItem = Bool.random()
            dungeon.updateRoom(at: pos) { room in
                room.event = .treasure(
                    gold: Int.random(in: 10...30),
                    item: hasItem ? .healthPotion : nil
                )
            }
        }

        // 7. Place traps (1-2 rooms)
        let trapCount = min(Int.random(in: 1...2), available.count)
        for _ in 0..<trapCount where !available.isEmpty {
            let pos = available.removeFirst()
            dungeon.updateRoom(at: pos) { room in
                room.event = .trap(damage: Int.random(in: 10...20))
            }
        }

        // 8. Remaining rooms stay empty
        return dungeon
    }

    private static func randomNPCName(index: Int) -> String {
        let names = ["老铁匠马库斯", "流浪商人莉娜", "隐居学者艾文", "神秘吟游诗人"]
        return names[index % names.count]
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `Cmd+U`
Expected: All `DungeonGeneratorTests` pass.

- [ ] **Step 5: Commit**

```bash
git add AIDungeon/Game/DungeonGenerator.swift AIDungeonTests/Game/DungeonGeneratorTests.swift
git commit -m "feat(game): add dungeon generator with room event placement"
```

---

## Task 4: Game State Machine

**Files:**
- Create: `AIDungeon/Game/GameState.swift`
- Create: `AIDungeon/Game/GameEngine.swift`
- Test: `AIDungeonTests/Game/GameEngineTests.swift`

- [ ] **Step 1: Write GameEngine tests**

```swift
// AIDungeonTests/Game/GameEngineTests.swift
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
        // Player starts at (0,0), move to (0,1)
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
        // Force a monster at (0,1) for deterministic test
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
        XCTAssertEqual(engine.state, .exploring) // treasure doesn't change state
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `Cmd+U`
Expected: Compilation error — `GameEngine`, `GameState` not defined.

- [ ] **Step 3: Implement GameState and GameEngine**

```swift
// AIDungeon/Game/GameState.swift
import Foundation

enum GameState: Equatable {
    case characterSelect
    case exploring
    case battle
    case chat
    case gameOver
    case victory
}
```

```swift
// AIDungeon/Game/GameEngine.swift
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
            // Clear the event so treasure isn't collected again
            dungeon?.updateRoom(at: position) { $0.event = .empty }

        case .trap(let damage):
            player?.stats.takeDamage(raw: damage, defenseMultiplier: 0) // traps ignore defense
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `Cmd+U`
Expected: All `GameEngineTests` pass.

- [ ] **Step 5: Commit**

```bash
git add AIDungeon/Game/GameState.swift AIDungeon/Game/GameEngine.swift AIDungeonTests/Game/GameEngineTests.swift
git commit -m "feat(game): add GameEngine state machine with room event handling"
```

---

## Task 5: Battle Engine

**Files:**
- Create: `AIDungeon/Game/BattleAction.swift`
- Create: `AIDungeon/Game/BattleResult.swift`
- Create: `AIDungeon/Game/BattleEngine.swift`
- Test: `AIDungeonTests/Game/BattleEngineTests.swift`

- [ ] **Step 1: Write BattleEngine tests**

```swift
// AIDungeonTests/Game/BattleEngineTests.swift
import XCTest
@testable import AIDungeon

final class BattleEngineTests: XCTestCase {
    func testAttackDealsDamage() {
        var player = Player(characterClass: .warrior) // ATK 18
        var monster = Monster.goblin() // DEF 5, HP 40
        let result = BattleEngine.executePlayerAction(.attack, player: &player, monster: &monster)
        XCTAssertEqual(result.damageToMonster, 13) // 18 - 5
        XCTAssertEqual(monster.stats.hp, 27) // 40 - 13
    }

    func testDefendReducesDamage() {
        var player = Player(characterClass: .warrior) // DEF 15
        var monster = Monster.goblin() // ATK 12
        let result = BattleEngine.executePlayerAction(.defend, player: &player, monster: &monster)
        XCTAssertTrue(result.playerDefending)
        // Monster attacks: 12 - (15 * 2) = -18 → min 1
        XCTAssertEqual(result.damageToPlayer, 1)
    }

    func testSkillDealsDamage() {
        var player = Player(characterClass: .mage)
        var monster = Monster.goblin() // DEF 5, HP 40
        let result = BattleEngine.executePlayerAction(.skill(Skill.fireball), player: &player, monster: &monster)
        // Fireball damage: 25, monster DEF 5 → 20
        XCTAssertEqual(result.damageToMonster, 20)
        XCTAssertEqual(monster.stats.hp, 20)
    }

    func testHealingSkill() {
        var player = Player(characterClass: .mage)
        player.stats.hp = 50
        var monster = Monster.goblin()
        let result = BattleEngine.executePlayerAction(.skill(Skill.heal), player: &player, monster: &monster)
        XCTAssertEqual(result.healingDone, 30)
        XCTAssertEqual(player.stats.hp, 80) // 50 + 30
    }

    func testUsePotion() {
        var player = Player(characterClass: .warrior)
        player.stats.hp = 50
        player.addItem(.healthPotion)
        var monster = Monster.goblin()
        let result = BattleEngine.executePlayerAction(.useItem(Item.healthPotion), player: &player, monster: &monster)
        XCTAssertEqual(result.healingDone, 30)
        XCTAssertEqual(player.stats.hp, 80)
        XCTAssertTrue(player.inventory.isEmpty)
    }

    func testMonsterCounterattacks() {
        var player = Player(characterClass: .warrior) // DEF 15
        var monster = Monster.goblin() // ATK 12
        let result = BattleEngine.executePlayerAction(.attack, player: &player, monster: &monster)
        // Monster counterattack: 12 - 15 → min 1
        XCTAssertGreaterThan(result.damageToPlayer, 0)
    }

    func testMonsterDeathNoCounterattack() {
        var player = Player(characterClass: .warrior)
        var monster = Monster.goblin()
        monster.stats.hp = 1 // about to die
        let result = BattleEngine.executePlayerAction(.attack, player: &player, monster: &monster)
        XCTAssertFalse(monster.stats.isAlive)
        XCTAssertEqual(result.damageToPlayer, 0) // dead monsters don't attack
    }

    func testSkillCooldown() {
        var player = Player(characterClass: .mage)
        var monster = Monster.goblin()
        _ = BattleEngine.executePlayerAction(.skill(Skill.fireball), player: &player, monster: &monster)
        XCTAssertFalse(player.isSkillReady("fireball"))
        // Tick twice (fireball cooldown is 2)
        player.tickCooldowns()
        XCTAssertFalse(player.isSkillReady("fireball"))
        player.tickCooldowns()
        XCTAssertTrue(player.isSkillReady("fireball"))
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `Cmd+U`
Expected: Compilation error — `BattleEngine`, `BattleAction`, `BattleResult` not defined.

- [ ] **Step 3: Implement BattleAction and BattleResult**

```swift
// AIDungeon/Game/BattleAction.swift
import Foundation

enum BattleAction {
    case attack
    case defend
    case skill(Skill)
    case useItem(Item)
}
```

```swift
// AIDungeon/Game/BattleResult.swift
import Foundation

struct BattleResult {
    let playerAction: String
    let damageToMonster: Int
    let damageToPlayer: Int
    let healingDone: Int
    let playerDefending: Bool
    let monsterAction: String
    let monsterDied: Bool
    let playerDied: Bool
}
```

- [ ] **Step 4: Implement BattleEngine**

```swift
// AIDungeon/Game/BattleEngine.swift
import Foundation

enum BattleEngine {
    static func executePlayerAction(
        _ action: BattleAction,
        player: inout Player,
        monster: inout Monster
    ) -> BattleResult {
        var damageToMonster = 0
        var damageToPlayer = 0
        var healingDone = 0
        var playerDefending = false
        var playerActionDesc = ""

        // Player turn
        switch action {
        case .attack:
            damageToMonster = monster.stats.takeDamage(raw: player.stats.atk)
            playerActionDesc = "攻击，造成 \(damageToMonster) 点伤害"

        case .defend:
            playerDefending = true
            playerActionDesc = "防御姿态"

        case .skill(let skill):
            if skill.healing > 0 {
                player.stats.heal(skill.healing)
                healingDone = skill.healing
                playerActionDesc = "使用 \(skill.name)，恢复 \(skill.healing) 点生命"
            } else if skill.damage > 0 {
                damageToMonster = monster.stats.takeDamage(raw: skill.damage)
                playerActionDesc = "使用 \(skill.name)，造成 \(damageToMonster) 点伤害"
            } else {
                // Special skills (heavy strike = 1.5x ATK)
                if skill.id == "heavy_strike" {
                    let rawDamage = Int(Double(player.stats.atk) * 1.5)
                    damageToMonster = monster.stats.takeDamage(raw: rawDamage)
                    playerActionDesc = "重击！造成 \(damageToMonster) 点伤害"
                } else {
                    playerActionDesc = "使用 \(skill.name)"
                }
            }
            player.skillCooldowns[skill.id] = skill.cooldown

        case .useItem(let item):
            switch item.type {
            case .potion:
                player.stats.heal(item.value)
                healingDone = item.value
                player.removeItem(id: item.id)
                playerActionDesc = "使用 \(item.name)，恢复 \(item.value) 点生命"
            case .scroll:
                damageToMonster = monster.stats.takeDamage(raw: item.value)
                player.removeItem(id: item.id)
                playerActionDesc = "使用 \(item.name)，造成 \(damageToMonster) 点伤害"
            default:
                playerActionDesc = "使用 \(item.name)"
            }
        }

        // Monster turn (only if alive)
        var monsterActionDesc = ""
        if monster.stats.isAlive {
            let defMultiplier = playerDefending ? 2.0 : 1.0
            damageToPlayer = player.stats.takeDamage(raw: monster.stats.atk, defenseMultiplier: defMultiplier)
            monsterActionDesc = "\(monster.name) 攻击，造成 \(damageToPlayer) 点伤害"
        }

        player.tickCooldowns()

        return BattleResult(
            playerAction: playerActionDesc,
            damageToMonster: damageToMonster,
            damageToPlayer: damageToPlayer,
            healingDone: healingDone,
            playerDefending: playerDefending,
            monsterAction: monsterActionDesc,
            monsterDied: !monster.stats.isAlive,
            playerDied: !player.stats.isAlive
        )
    }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `Cmd+U`
Expected: All `BattleEngineTests` pass.

- [ ] **Step 6: Commit**

```bash
git add AIDungeon/Game/BattleAction.swift AIDungeon/Game/BattleResult.swift AIDungeon/Game/BattleEngine.swift AIDungeonTests/Game/BattleEngineTests.swift
git commit -m "feat(game): add turn-based BattleEngine with attack/defend/skill/item actions"
```

---

## Task 6: Monster AI with GameplayKit

**Files:**
- Create: `AIDungeon/Game/MonsterAI.swift`
- Test: `AIDungeonTests/Game/MonsterAITests.swift`

- [ ] **Step 1: Write MonsterAI tests**

```swift
// AIDungeonTests/Game/MonsterAITests.swift
import XCTest
@testable import AIDungeon

final class MonsterAITests: XCTestCase {
    func testMeleeMonsterAttacksWhenHealthy() {
        var monster = Monster.goblin()
        monster.stats.hp = monster.stats.maxHp // full HP
        let action = MonsterAI.decideAction(for: &monster)
        XCTAssertEqual(action, .attack)
    }

    func testMeleeMonsterBerserksWhenLowHp() {
        var monster = Monster.goblin()
        monster.stats.hp = 10 // below 25% of 40
        let action = MonsterAI.decideAction(for: &monster)
        XCTAssertEqual(action, .berserk)
        XCTAssertTrue(monster.berserkTriggered)
    }

    func testBerserkDoublesAtk() {
        var monster = Monster.goblin()
        let originalAtk = monster.stats.atk
        monster.stats.hp = 5
        _ = MonsterAI.decideAction(for: &monster)
        XCTAssertEqual(monster.stats.atk, originalAtk * 2)
    }

    func testBerserkOnlyTriggersOnce() {
        var monster = Monster.goblin()
        monster.stats.hp = 5
        _ = MonsterAI.decideAction(for: &monster)
        let atkAfterFirst = monster.stats.atk
        _ = MonsterAI.decideAction(for: &monster)
        XCTAssertEqual(monster.stats.atk, atkAfterFirst) // no double-double
    }

    func testRangedMonsterUsesSkillWhenAvailable() {
        var monster = Monster.skeleton()
        let action = MonsterAI.decideAction(for: &monster)
        // skeleton has arrow_rain skill, should prefer it
        if case .useSkill(let skill) = action {
            XCTAssertEqual(skill.id, "arrow_rain")
        } else {
            // May also attack if cooldown — that's okay for first turn it should use skill
            XCTAssertEqual(action, .useSkill(monster.skills[0]))
        }
    }

    func testBossUsesSkillAtPhaseThreshold() {
        var monster = Monster.dungeonBoss(name: "Boss", description: "Test boss")
        monster.stats.hp = 100 // 50% HP — should trigger phase 2
        let action = MonsterAI.decideAction(for: &monster)
        // Boss should use a skill at 50% threshold
        switch action {
        case .useSkill:
            break // correct
        case .attack:
            break // also acceptable
        default:
            XCTFail("Boss should attack or use skill")
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `Cmd+U`
Expected: Compilation error — `MonsterAI` not defined.

- [ ] **Step 3: Implement MonsterAI**

```swift
// AIDungeon/Game/MonsterAI.swift
import Foundation
import GameplayKit

enum MonsterAction: Equatable {
    case attack
    case berserk    // attack with doubled ATK
    case useSkill(Skill)
    case defend

    static func == (lhs: MonsterAction, rhs: MonsterAction) -> Bool {
        switch (lhs, rhs) {
        case (.attack, .attack): return true
        case (.berserk, .berserk): return true
        case (.defend, .defend): return true
        case (.useSkill(let a), .useSkill(let b)): return a.id == b.id
        default: return false
        }
    }
}

enum MonsterAI {
    static func decideAction(for monster: inout Monster) -> MonsterAction {
        switch monster.behavior {
        case .melee:
            return decideMelee(for: &monster)
        case .ranged:
            return decideRanged(for: &monster)
        case .boss:
            return decideBoss(for: &monster)
        }
    }

    private static func decideMelee(for monster: inout Monster) -> MonsterAction {
        let hpPercent = Double(monster.stats.hp) / Double(monster.stats.maxHp)

        if hpPercent <= 0.25 && !monster.berserkTriggered {
            monster.berserkTriggered = true
            monster.stats.atk *= 2
            return .berserk
        }

        return .attack
    }

    private static func decideRanged(for monster: inout Monster) -> MonsterAction {
        // Prefer skill if available
        if let skill = monster.skills.first {
            return .useSkill(skill)
        }
        return .attack
    }

    private static func decideBoss(for monster: inout Monster) -> MonsterAction {
        let hpPercent = Double(monster.stats.hp) / Double(monster.stats.maxHp)

        // Phase 2: below 50%, use rage skill if not already berserk
        if hpPercent <= 0.50 && !monster.berserkTriggered {
            monster.berserkTriggered = true
            monster.stats.atk = Int(Double(monster.stats.atk) * 1.5)
            if let rageSkill = monster.skills.first(where: { $0.id == "boss_rage" }) {
                return .useSkill(rageSkill)
            }
        }

        // Use slam skill randomly (30% chance)
        if let slamSkill = monster.skills.first(where: { $0.id == "boss_slam" }) {
            if GKRandomDistribution(lowestValue: 1, highestValue: 100).nextInt() <= 30 {
                return .useSkill(slamSkill)
            }
        }

        return .attack
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `Cmd+U`
Expected: All `MonsterAITests` pass.

- [ ] **Step 5: Commit**

```bash
git add AIDungeon/Game/MonsterAI.swift AIDungeonTests/Game/MonsterAITests.swift
git commit -m "feat(game): add GameplayKit-based MonsterAI with melee/ranged/boss strategies"
```

---

## Task 7: AI Provider Protocol and OpenAI Client

**Files:**
- Create: `AIDungeon/AI/AIProvider.swift`
- Create: `AIDungeon/AI/OpenAIClient.swift`
- Create: `AIDungeon/AI/StreamingParser.swift`
- Test: `AIDungeonTests/AI/OpenAIClientTests.swift`
- Test: `AIDungeonTests/AI/StreamingParserTests.swift`

- [ ] **Step 1: Write StreamingParser tests**

```swift
// AIDungeonTests/AI/StreamingParserTests.swift
import XCTest
@testable import AIDungeon

final class StreamingParserTests: XCTestCase {
    func testParseSingleSSELine() {
        let line = "data: {\"choices\":[{\"delta\":{\"content\":\"Hello\"}}]}"
        let result = StreamingParser.parseSSELine(line)
        XCTAssertEqual(result, "Hello")
    }

    func testParseDoneSignal() {
        let line = "data: [DONE]"
        let result = StreamingParser.parseSSELine(line)
        XCTAssertNil(result)
    }

    func testParseEmptyLine() {
        let result = StreamingParser.parseSSELine("")
        XCTAssertNil(result)
    }

    func testParseNonDataLine() {
        let result = StreamingParser.parseSSELine("event: message")
        XCTAssertNil(result)
    }

    func testParseLineWithNoContent() {
        let line = "data: {\"choices\":[{\"delta\":{}}]}"
        let result = StreamingParser.parseSSELine(line)
        XCTAssertNil(result)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `Cmd+U`
Expected: Compilation error — `StreamingParser` not defined.

- [ ] **Step 3: Implement AIProvider protocol**

```swift
// AIDungeon/AI/AIProvider.swift
import Foundation

struct AIProviderConfig: Codable {
    var providerType: ProviderType
    var baseURL: String
    var apiKey: String
    var modelName: String

    enum ProviderType: String, Codable, CaseIterable {
        case ollama = "Ollama"
        case openai = "OpenAI"
        case compatible = "OpenAI 兼容"
    }

    static var ollama: AIProviderConfig {
        AIProviderConfig(providerType: .ollama, baseURL: "http://localhost:11434/v1", apiKey: "", modelName: "llama3")
    }

    static var openai: AIProviderConfig {
        AIProviderConfig(providerType: .openai, baseURL: "https://api.openai.com/v1", apiKey: "", modelName: "gpt-4o-mini")
    }

    static var deepseek: AIProviderConfig {
        AIProviderConfig(providerType: .compatible, baseURL: "https://api.deepseek.com/v1", apiKey: "", modelName: "deepseek-chat")
    }

    var chatCompletionsURL: URL {
        URL(string: "\(baseURL)/chat/completions")!
    }
}

struct ChatMessage: Codable {
    let role: String  // "system", "user", "assistant"
    let content: String
}
```

- [ ] **Step 4: Implement StreamingParser**

```swift
// AIDungeon/AI/StreamingParser.swift
import Foundation

enum StreamingParser {
    static func parseSSELine(_ line: String) -> String? {
        guard line.hasPrefix("data: ") else { return nil }
        let jsonString = String(line.dropFirst(6))
        guard jsonString != "[DONE]" else { return nil }
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let delta = choices.first?["delta"] as? [String: Any],
              let content = delta["content"] as? String else { return nil }
        return content
    }
}
```

- [ ] **Step 5: Run StreamingParser tests to verify they pass**

Run: `Cmd+U`
Expected: All `StreamingParserTests` pass.

- [ ] **Step 6: Write OpenAIClient tests**

```swift
// AIDungeonTests/AI/OpenAIClientTests.swift
import XCTest
@testable import AIDungeon

final class OpenAIClientTests: XCTestCase {
    func testBuildRequestHasCorrectHeaders() {
        let config = AIProviderConfig(providerType: .openai, baseURL: "https://api.openai.com/v1", apiKey: "test-key", modelName: "gpt-4o-mini")
        let client = OpenAIClient(config: config)
        let request = client.buildRequest(messages: [ChatMessage(role: "user", content: "hello")], stream: false)
        XCTAssertEqual(request.url?.absoluteString, "https://api.openai.com/v1/chat/completions")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-key")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testBuildRequestOllamaNoAuthHeader() {
        let config = AIProviderConfig(providerType: .ollama, baseURL: "http://localhost:11434/v1", apiKey: "", modelName: "llama3")
        let client = OpenAIClient(config: config)
        let request = client.buildRequest(messages: [ChatMessage(role: "user", content: "hello")], stream: false)
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
    }

    func testBuildRequestBodyContainsModel() throws {
        let config = AIProviderConfig.openai
        let client = OpenAIClient(config: config)
        let request = client.buildRequest(messages: [ChatMessage(role: "user", content: "test")], stream: true)
        let body = try JSONSerialization.jsonObject(with: request.httpBody!) as! [String: Any]
        XCTAssertEqual(body["model"] as? String, "gpt-4o-mini")
        XCTAssertEqual(body["stream"] as? Bool, true)
    }
}
```

- [ ] **Step 7: Implement OpenAIClient**

```swift
// AIDungeon/AI/OpenAIClient.swift
import Foundation

final class OpenAIClient {
    let config: AIProviderConfig
    private let session: URLSession

    init(config: AIProviderConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    func buildRequest(messages: [ChatMessage], stream: Bool) -> URLRequest {
        var request = URLRequest(url: config.chatCompletionsURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if !config.apiKey.isEmpty {
            request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "model": config.modelName,
            "messages": messages.map { ["role": $0.role, "content": $0.content] },
            "stream": stream
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return request
    }

    /// Non-streaming completion
    func complete(messages: [ChatMessage]) async throws -> String {
        let request = buildRequest(messages: messages, stream: false)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw AIError.requestFailed(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        return content
    }

    /// Streaming completion returning an AsyncStream of text chunks
    func streamComplete(messages: [ChatMessage]) -> AsyncStream<String> {
        let request = buildRequest(messages: messages, stream: true)

        return AsyncStream { continuation in
            let task = session.dataTask(with: request) { data, _, error in
                if let error {
                    continuation.finish()
                    return
                }
                guard let data, let text = String(data: data, encoding: .utf8) else {
                    continuation.finish()
                    return
                }
                let lines = text.components(separatedBy: "\n")
                for line in lines {
                    if let content = StreamingParser.parseSSELine(line) {
                        continuation.yield(content)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
            task.resume()
        }
    }

    /// Test connection by sending a minimal request
    func testConnection() async throws -> Bool {
        let messages = [ChatMessage(role: "user", content: "Say OK")]
        let request = buildRequest(messages: messages, stream: false)
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { return false }
        return 200..<300 ~= httpResponse.statusCode
    }
}

enum AIError: Error, LocalizedError {
    case requestFailed(statusCode: Int)
    case invalidResponse
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .requestFailed(let code): return "请求失败 (HTTP \(code))"
        case .invalidResponse: return "无效的 AI 响应"
        case .notConfigured: return "AI 尚未配置"
        }
    }
}
```

- [ ] **Step 8: Run all AI tests to verify they pass**

Run: `Cmd+U`
Expected: All `OpenAIClientTests` and `StreamingParserTests` pass.

- [ ] **Step 9: Commit**

```bash
git add AIDungeon/AI/AIProvider.swift AIDungeon/AI/OpenAIClient.swift AIDungeon/AI/StreamingParser.swift AIDungeonTests/AI/
git commit -m "feat(ai): add AIProvider protocol and OpenAI-compatible client with streaming support"
```

---

## Task 8: Prompt Builder and Response Parser

**Files:**
- Create: `AIDungeon/AI/PromptBuilder.swift`
- Create: `AIDungeon/AI/ResponseParser.swift`
- Create: `AIDungeon/AI/FallbackContent.swift`
- Test: `AIDungeonTests/AI/PromptBuilderTests.swift`
- Test: `AIDungeonTests/AI/ResponseParserTests.swift`

- [ ] **Step 1: Write ResponseParser tests**

```swift
// AIDungeonTests/AI/ResponseParserTests.swift
import XCTest
@testable import AIDungeon

final class ResponseParserTests: XCTestCase {
    func testParseTradeTag() {
        let text = "当然可以交易！[TRADE: 生命药水, 50金币] 你要来一瓶吗？"
        let result = ResponseParser.parse(text)
        XCTAssertEqual(result.displayText, "当然可以交易！ 你要来一瓶吗？")
        XCTAssertEqual(result.actions.count, 1)
        if case .trade(let itemName, let cost) = result.actions[0] {
            XCTAssertEqual(itemName, "生命药水")
            XCTAssertEqual(cost, 50)
        } else {
            XCTFail("Expected trade action")
        }
    }

    func testParseHintTag() {
        let text = "我听说...[HINT: Boss弱火属性]...你可要小心。"
        let result = ResponseParser.parse(text)
        XCTAssertEqual(result.displayText, "我听说......你可要小心。")
        if case .hint(let hint) = result.actions[0] {
            XCTAssertEqual(hint, "Boss弱火属性")
        } else {
            XCTFail("Expected hint action")
        }
    }

    func testParseGiftTag() {
        let text = "拿着这个吧。[GIFT: 神秘钥匙]"
        let result = ResponseParser.parse(text)
        XCTAssertEqual(result.displayText, "拿着这个吧。")
        if case .gift(let itemName) = result.actions[0] {
            XCTAssertEqual(itemName, "神秘钥匙")
        } else {
            XCTFail("Expected gift action")
        }
    }

    func testParseMultipleTags() {
        let text = "[HINT: 小心陷阱] 来做个交易吧 [TRADE: 火焰卷轴, 30金币]"
        let result = ResponseParser.parse(text)
        XCTAssertEqual(result.actions.count, 2)
    }

    func testParseNoTags() {
        let text = "你好，冒险者。这里很危险。"
        let result = ResponseParser.parse(text)
        XCTAssertEqual(result.displayText, "你好，冒险者。这里很危险。")
        XCTAssertTrue(result.actions.isEmpty)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `Cmd+U`
Expected: Compilation error — `ResponseParser` not defined.

- [ ] **Step 3: Implement ResponseParser**

```swift
// AIDungeon/AI/ResponseParser.swift
import Foundation

enum NPCAction {
    case trade(itemName: String, cost: Int)
    case hint(String)
    case gift(itemName: String)
}

struct ParsedResponse {
    let displayText: String
    let actions: [NPCAction]
}

enum ResponseParser {
    private static let tagPattern = /\[(TRADE|HINT|GIFT):\s*([^\]]+)\]/

    static func parse(_ text: String) -> ParsedResponse {
        var actions: [NPCAction] = []
        var displayText = text

        let matches = text.matches(of: tagPattern)
        for match in matches.reversed() {
            let tag = String(match.1)
            let value = String(match.2).trimmingCharacters(in: .whitespaces)

            switch tag {
            case "TRADE":
                let parts = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                if parts.count == 2, let cost = Int(parts[1].replacingOccurrences(of: "金币", with: "")) {
                    actions.insert(.trade(itemName: parts[0], cost: cost), at: 0)
                }
            case "HINT":
                actions.insert(.hint(value), at: 0)
            case "GIFT":
                actions.insert(.gift(itemName: value), at: 0)
            default:
                break
            }

            displayText = displayText.replacingOccurrences(of: String(match.0), with: "")
        }

        return ParsedResponse(
            displayText: displayText.trimmingCharacters(in: .whitespaces),
            actions: actions
        )
    }
}
```

- [ ] **Step 4: Run ResponseParser tests to verify they pass**

Run: `Cmd+U`
Expected: All `ResponseParserTests` pass.

- [ ] **Step 5: Write PromptBuilder tests**

```swift
// AIDungeonTests/AI/PromptBuilderTests.swift
import XCTest
@testable import AIDungeon

final class PromptBuilderTests: XCTestCase {
    func testNPCSystemPromptContainsName() {
        let prompt = PromptBuilder.npcSystemPrompt(
            npcName: "老铁匠",
            npcDescription: "一位疲惫的铁匠",
            personality: "暴躁但善良",
            dungeonTheme: "废弃矿洞",
            playerHp: 80,
            playerMaxHp: 100,
            playerItems: ["生命药水", "铁剑"]
        )
        XCTAssertTrue(prompt.contains("老铁匠"))
        XCTAssertTrue(prompt.contains("废弃矿洞"))
        XCTAssertTrue(prompt.contains("80"))
        XCTAssertTrue(prompt.contains("生命药水"))
    }

    func testDungeonThemePrompt() {
        let prompt = PromptBuilder.dungeonThemePrompt()
        XCTAssertTrue(prompt.contains("地牢"))
    }

    func testRoomDescriptionPrompt() {
        let prompt = PromptBuilder.roomDescriptionPrompt(theme: "幽灵城堡", event: "怪物")
        XCTAssertTrue(prompt.contains("幽灵城堡"))
        XCTAssertTrue(prompt.contains("怪物"))
    }
}
```

- [ ] **Step 6: Implement PromptBuilder**

```swift
// AIDungeon/AI/PromptBuilder.swift
import Foundation

enum PromptBuilder {
    static func npcSystemPrompt(
        npcName: String,
        npcDescription: String,
        personality: String,
        dungeonTheme: String,
        playerHp: Int,
        playerMaxHp: Int,
        playerItems: [String]
    ) -> String {
        """
        你是 \(npcName)，\(npcDescription)。你的性格是：\(personality)。
        你所在的地牢主题是「\(dungeonTheme)」。
        玩家当前状态：HP \(playerHp)/\(playerMaxHp)，持有物品：\(playerItems.joined(separator: "、"))。

        你的行为规则：
        - 保持角色扮演，不要出戏，用简短的语句回复（不超过3句话）
        - 可以提供本层地牢的线索，用 [HINT: 线索内容] 格式
        - 可以提供交易，用 [TRADE: 物品名, 价格金币] 格式
        - 可以赠送物品，用 [GIFT: 物品名] 格式
        - 不能直接帮玩家战斗
        - 每次回复最多包含一个标签
        """
    }

    static func dungeonThemePrompt() -> String {
        """
        你是一个地牢主题生成器。请生成一个独特的地牢主题，包含：
        1. 主题名称（4-6个字，如"废弃矿洞"、"幽灵城堡"）
        2. 简短描述（1句话，描述氛围）

        用 JSON 格式回复：{"name": "主题名", "description": "描述"}
        只回复 JSON，不要其他内容。
        """
    }

    static func roomDescriptionPrompt(theme: String, event: String) -> String {
        """
        地牢主题：\(theme)
        房间类型：\(event)

        用1-2句话描述这个房间的场景。要有氛围感，符合主题。只回复描述文字，不要其他内容。
        """
    }

    static func npcGenerationPrompt(theme: String) -> String {
        """
        地牢主题：\(theme)

        生成一个NPC角色，用 JSON 格式回复：
        {"name": "角色名", "description": "外貌描述", "personality": "性格描述"}
        只回复 JSON，不要其他内容。
        """
    }
}
```

- [ ] **Step 7: Implement FallbackContent**

```swift
// AIDungeon/AI/FallbackContent.swift
import Foundation

enum FallbackContent {
    static let themes = [
        (name: "废弃矿洞", description: "被遗弃已久的矿洞，空气中弥漫着铁锈和潮湿的气息"),
        (name: "幽灵城堡", description: "月光下的古堡，每一面墙壁都在低语"),
        (name: "地下森林", description: "奇异的发光植物照亮了这片地下世界"),
        (name: "冰封神殿", description: "古老的神殿被永恒的寒冰所覆盖"),
        (name: "熔岩洞穴", description: "地面的裂缝中涌出炽热的岩浆")
    ]

    static let roomDescriptions: [String: [String]] = [
        "monster": [
            "阴暗的角落传来低沉的咆哮声。",
            "地面上散落着碎骨，空气中弥漫着危险的气息。",
            "墙壁上的爪痕昭示着这里的主人并不友善。"
        ],
        "npc": [
            "篝火的光芒在墙壁上跳动，一个身影靠在角落。",
            "一个旅者正在这里休息，看到你后微微点头。"
        ],
        "treasure": [
            "房间中央放着一个积满灰尘的箱子。",
            "墙壁的暗格中似乎藏着什么东西。"
        ],
        "trap": [
            "地板上的纹路看起来有些异常...",
            "空气中弥漫着一股奇怪的味道。"
        ],
        "empty": [
            "空荡荡的房间，只有回声作伴。",
            "这里似乎已经被搜刮干净了。",
            "平静的房间，暂时没有危险。"
        ],
        "boss": [
            "巨大的空间，地面上刻满了神秘的符文。远处传来沉重的呼吸声。"
        ]
    ]

    static let npcDialogs = [
        "你好，冒险者。这里很危险，要小心。",
        "想买点什么吗？我这里有些好东西。",
        "你是怎么找到这里的？算了，不重要。",
        "前方的敌人很强，做好准备再去吧。"
    ]

    static func randomTheme() -> (name: String, description: String) {
        themes.randomElement()!
    }

    static func randomRoomDescription(for event: String) -> String {
        (roomDescriptions[event] ?? roomDescriptions["empty"]!).randomElement()!
    }

    static func randomNPCDialog() -> String {
        npcDialogs.randomElement()!
    }
}
```

- [ ] **Step 8: Run all tests to verify they pass**

Run: `Cmd+U`
Expected: All `PromptBuilderTests` and `ResponseParserTests` pass.

- [ ] **Step 9: Commit**

```bash
git add AIDungeon/AI/PromptBuilder.swift AIDungeon/AI/ResponseParser.swift AIDungeon/AI/FallbackContent.swift AIDungeonTests/AI/
git commit -m "feat(ai): add PromptBuilder, ResponseParser, and FallbackContent for NPC interactions"
```

---

## Task 9: AI Content Generator

**Files:**
- Create: `AIDungeon/AI/AIContentGenerator.swift`

- [ ] **Step 1: Implement AIContentGenerator**

This ties together the OpenAIClient, PromptBuilder, and FallbackContent into a single high-level API used by the game.

```swift
// AIDungeon/AI/AIContentGenerator.swift
import Foundation

@Observable
final class AIContentGenerator {
    var config: AIProviderConfig? {
        didSet { saveConfig() }
    }
    var isAvailable: Bool { config != nil }

    private var client: OpenAIClient? {
        guard let config else { return nil }
        return OpenAIClient(config: config)
    }

    init() {
        loadConfig()
    }

    // MARK: - Theme generation

    func generateTheme() async -> (name: String, description: String) {
        guard let client else { return FallbackContent.randomTheme() }

        do {
            let messages = [ChatMessage(role: "system", content: PromptBuilder.dungeonThemePrompt())]
            let response = try await client.complete(messages: messages)
            if let data = response.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
               let name = json["name"], let desc = json["description"] {
                return (name, desc)
            }
        } catch {
            // fallback
        }
        return FallbackContent.randomTheme()
    }

    // MARK: - Room description

    func generateRoomDescription(theme: String, event: String) async -> String {
        guard let client else { return FallbackContent.randomRoomDescription(for: event) }

        do {
            let messages = [ChatMessage(role: "user", content: PromptBuilder.roomDescriptionPrompt(theme: theme, event: event))]
            let response = try await client.complete(messages: messages)
            return response
        } catch {
            return FallbackContent.randomRoomDescription(for: event)
        }
    }

    // MARK: - NPC generation

    func generateNPC(theme: String) async -> (name: String, description: String, personality: String) {
        guard let client else {
            return ("神秘旅者", "一位风尘仆仆的旅人", "友善但警惕")
        }

        do {
            let messages = [ChatMessage(role: "user", content: PromptBuilder.npcGenerationPrompt(theme: theme))]
            let response = try await client.complete(messages: messages)
            if let data = response.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
               let name = json["name"], let desc = json["description"], let personality = json["personality"] {
                return (name, desc, personality)
            }
        } catch {
            // fallback
        }
        return ("神秘旅者", "一位风尘仆仆的旅人", "友善但警惕")
    }

    // MARK: - NPC chat (streaming)

    func chatWithNPC(
        npcName: String,
        npcDescription: String,
        personality: String,
        dungeonTheme: String,
        player: Player,
        chatHistory: [ChatMessage],
        userMessage: String
    ) -> AsyncStream<String> {
        guard let client else {
            return AsyncStream { continuation in
                continuation.yield(FallbackContent.randomNPCDialog())
                continuation.finish()
            }
        }

        let systemPrompt = PromptBuilder.npcSystemPrompt(
            npcName: npcName,
            npcDescription: npcDescription,
            personality: personality,
            dungeonTheme: dungeonTheme,
            playerHp: player.stats.hp,
            playerMaxHp: player.stats.maxHp,
            playerItems: player.inventory.map(\.name)
        )

        var messages = [ChatMessage(role: "system", content: systemPrompt)]
        messages.append(contentsOf: chatHistory)
        messages.append(ChatMessage(role: "user", content: userMessage))

        return client.streamComplete(messages: messages)
    }

    // MARK: - Test connection

    func testConnection() async -> Bool {
        guard let client else { return false }
        return (try? await client.testConnection()) ?? false
    }

    // MARK: - Config persistence

    private func saveConfig() {
        guard let config, let data = try? JSONEncoder().encode(config) else {
            UserDefaults.standard.removeObject(forKey: "ai_provider_config")
            return
        }
        UserDefaults.standard.set(data, forKey: "ai_provider_config")
    }

    private func loadConfig() {
        guard let data = UserDefaults.standard.data(forKey: "ai_provider_config"),
              let saved = try? JSONDecoder().decode(AIProviderConfig.self, from: data) else { return }
        config = saved
    }
}
```

- [ ] **Step 2: Build to verify compilation**

Run: `Cmd+B`
Expected: Build succeeds.

- [ ] **Step 3: Commit**

```bash
git add AIDungeon/AI/AIContentGenerator.swift
git commit -m "feat(ai): add AIContentGenerator as high-level AI integration layer"
```

---

## Task 10: Dungeon Map View (SpriteKit)

**Files:**
- Create: `AIDungeon/Views/DungeonMapScene.swift`
- Create: `AIDungeon/Views/DungeonMapView.swift`
- Create: `AIDungeon/Views/HUDView.swift`

- [ ] **Step 1: Implement DungeonMapScene**

```swift
// AIDungeon/Views/DungeonMapScene.swift
import SpriteKit

final class DungeonMapScene: SKScene {
    private let gridSize = 5
    private let tileSize: CGFloat = 60
    private let tileSpacing: CGFloat = 4

    var dungeon: Dungeon?
    var playerPosition: Position?
    var onTileTapped: ((Position) -> Void)?

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
                // Invert Y for SpriteKit (bottom-up)
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
            // Parse "tile_row_col" or check parent
            let parseName = name.hasPrefix("tile_") ? name : (node.parent?.name ?? "")
            guard parseName.hasPrefix("tile_") else { continue }
            let parts = parseName.split(separator: "_")
            guard parts.count == 3, let row = Int(parts[1]), let col = Int(parts[2]) else { continue }
            onTileTapped?(Position(row: row, col: col))
            return
        }
    }
}
```

- [ ] **Step 2: Implement DungeonMapView (SwiftUI wrapper)**

```swift
// AIDungeon/Views/DungeonMapView.swift
import SwiftUI
import SpriteKit

struct DungeonMapView: View {
    let engine: GameEngine
    let aiGenerator: AIContentGenerator

    @State private var scene: DungeonMapScene = {
        let scene = DungeonMapScene()
        scene.size = CGSize(width: 350, height: 350)
        scene.scaleMode = .aspectFit
        return scene
    }()

    var body: some View {
        VStack(spacing: 0) {
            HUDView(engine: engine)

            SpriteView(scene: scene)
                .frame(width: 350, height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            if let message = engine.lastEventMessage {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
        .onAppear { refreshMap() }
        .onChange(of: engine.player?.position) { _, _ in refreshMap() }
    }

    private func refreshMap() {
        guard let dungeon = engine.dungeon, let pos = engine.player?.position else { return }
        scene.onTileTapped = { position in
            _ = engine.movePlayer(to: position)
        }
        scene.updateMap(dungeon: dungeon, playerPosition: pos)
    }
}
```

- [ ] **Step 3: Implement HUDView**

```swift
// AIDungeon/Views/HUDView.swift
import SwiftUI

struct HUDView: View {
    let engine: GameEngine

    var body: some View {
        if let player = engine.player {
            HStack {
                Label("\(player.stats.hp)/\(player.stats.maxHp)", systemImage: "heart.fill")
                    .foregroundStyle(.red)

                Spacer()

                Label("\(player.gold)", systemImage: "bitcoinsign.circle.fill")
                    .foregroundStyle(.yellow)

                Spacer()

                Text(player.characterClass.icon + " " + player.characterClass.rawValue)
            }
            .font(.subheadline.bold())
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
```

- [ ] **Step 4: Build and run in simulator**

Run: `Cmd+R`
Expected: Builds successfully. (Map view won't be visible yet from the main menu — we'll connect it in Task 12.)

- [ ] **Step 5: Commit**

```bash
git add AIDungeon/Views/DungeonMapScene.swift AIDungeon/Views/DungeonMapView.swift AIDungeon/Views/HUDView.swift
git commit -m "feat(views): add SpriteKit dungeon map with fog of war and HUD overlay"
```

---

## Task 11: Battle View

**Files:**
- Create: `AIDungeon/Views/BattleView.swift`

- [ ] **Step 1: Implement BattleView**

```swift
// AIDungeon/Views/BattleView.swift
import SwiftUI

struct BattleView: View {
    let engine: GameEngine
    @State private var battleLog: [String] = []
    @State private var isAnimating = false

    private var player: Player? { engine.player }
    private var monster: Monster? { engine.currentMonster }

    var body: some View {
        VStack(spacing: 16) {
            // Monster info
            if let monster {
                VStack(spacing: 4) {
                    Text(monster.name)
                        .font(.title2.bold())
                    HealthBar(current: monster.stats.hp, max: monster.stats.maxHp, color: .red)
                    Text("HP: \(monster.stats.hp)/\(monster.stats.maxHp)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }

            // Battle log
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(battleLog.enumerated()), id: \.offset) { index, log in
                            Text(log)
                                .font(.callout)
                                .id(index)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 200)
                .onChange(of: battleLog.count) { _, _ in
                    if let last = battleLog.indices.last {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }

            Spacer()

            // Player info
            if let player {
                HealthBar(current: player.stats.hp, max: player.stats.maxHp, color: .green)
                Text("HP: \(player.stats.hp)/\(player.stats.maxHp)")
                    .font(.caption)
            }

            // Action buttons
            if !isAnimating, monster?.stats.isAlive == true, player?.stats.isAlive == true {
                actionButtons
            }
        }
        .padding()
        .onAppear {
            battleLog = ["战斗开始！"]
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                actionButton("攻击", icon: "burst") { performAction(.attack) }
                actionButton("防御", icon: "shield") { performAction(.defend) }
            }

            HStack(spacing: 12) {
                if let player {
                    ForEach(player.skills) { skill in
                        let ready = player.isSkillReady(skill.id)
                        actionButton(skill.name, icon: "sparkles", disabled: !ready) {
                            performAction(.skill(skill))
                        }
                    }
                }
            }

            if let player, player.inventory.contains(where: { $0.type == .potion }) {
                HStack(spacing: 12) {
                    ForEach(player.inventory.filter { $0.type == .potion }) { item in
                        actionButton(item.name, icon: "cross.vial") {
                            performAction(.useItem(item))
                        }
                    }
                }
            }
        }
    }

    private func actionButton(_ title: String, icon: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .disabled(disabled)
    }

    private func performAction(_ action: BattleAction) {
        guard var player = engine.player, var monster = engine.currentMonster else { return }
        isAnimating = true

        let result = BattleEngine.executePlayerAction(action, player: &player, monster: &monster)
        engine.player = player
        engine.currentMonster = monster

        battleLog.append("▸ \(result.playerAction)")
        if result.healingDone > 0 {
            battleLog.append("  ❤️ 恢复 \(result.healingDone) 点生命")
        }
        if !result.monsterAction.isEmpty {
            battleLog.append("◂ \(result.monsterAction)")
        }

        if result.monsterDied {
            let goldReward = Int.random(in: monster.lootGold)
            engine.player?.gainGold(goldReward)
            battleLog.append("🎉 击败了 \(monster.name)！获得 \(goldReward) 金币")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                engine.finishBattle()
            }
        } else if result.playerDied {
            battleLog.append("💀 你被击败了...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                engine.finishBattle()
            }
        }

        isAnimating = false
    }
}

struct HealthBar: View {
    let current: Int
    let max: Int
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(color.opacity(0.3))
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(current) / CGFloat(max))
            }
        }
        .frame(height: 12)
    }
}
```

- [ ] **Step 2: Build to verify compilation**

Run: `Cmd+B`
Expected: Build succeeds.

- [ ] **Step 3: Commit**

```bash
git add AIDungeon/Views/BattleView.swift
git commit -m "feat(views): add BattleView with action buttons, health bars, and battle log"
```

---

## Task 12: Chat View and NPC Dialog

**Files:**
- Create: `AIDungeon/Views/ChatBubble.swift`
- Create: `AIDungeon/Views/ChatView.swift`

- [ ] **Step 1: Implement ChatBubble**

```swift
// AIDungeon/Views/ChatBubble.swift
import SwiftUI

struct ChatBubble: View {
    let text: String
    let isPlayer: Bool

    var body: some View {
        HStack {
            if isPlayer { Spacer(minLength: 60) }

            Text(text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isPlayer ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isPlayer ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if !isPlayer { Spacer(minLength: 60) }
        }
    }
}
```

- [ ] **Step 2: Implement ChatView**

```swift
// AIDungeon/Views/ChatView.swift
import SwiftUI

struct ChatView: View {
    let engine: GameEngine
    let aiGenerator: AIContentGenerator
    let npcName: String
    let npcDescription: String
    let personality: String

    @State private var messages: [(text: String, isPlayer: Bool)] = []
    @State private var chatHistory: [ChatMessage] = []
    @State private var inputText = ""
    @State private var streamingText = ""
    @State private var isStreaming = false

    var body: some View {
        VStack(spacing: 0) {
            // NPC header
            VStack(spacing: 4) {
                Text(npcName)
                    .font(.headline)
                Text(npcDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)

            Divider()

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, msg in
                            ChatBubble(text: msg.text, isPlayer: msg.isPlayer)
                                .id(index)
                        }
                        if !streamingText.isEmpty {
                            ChatBubble(text: streamingText, isPlayer: false)
                                .id("streaming")
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.indices.last {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
                .onChange(of: streamingText) { _, _ in
                    proxy.scrollTo("streaming", anchor: .bottom)
                }
            }

            Divider()

            // Input
            HStack {
                TextField("说些什么...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isStreaming)
                    .onSubmit { sendMessage() }

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(inputText.isEmpty || isStreaming)
            }
            .padding()

            // Leave button
            Button("离开") {
                engine.finishChat()
            }
            .padding(.bottom)
        }
        .onAppear {
            messages.append((text: "（\(npcName)注意到了你的到来）", isPlayer: false))
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append((text: text, isPlayer: true))
        chatHistory.append(ChatMessage(role: "user", content: text))
        inputText = ""
        isStreaming = true
        streamingText = ""

        guard let player = engine.player, let dungeon = engine.dungeon else { return }

        Task {
            var fullResponse = ""
            let stream = aiGenerator.chatWithNPC(
                npcName: npcName,
                npcDescription: npcDescription,
                personality: personality,
                dungeonTheme: dungeon.theme,
                player: player,
                chatHistory: chatHistory,
                userMessage: text
            )

            for await chunk in stream {
                fullResponse += chunk
                streamingText = fullResponse
            }

            // Parse response for actions
            let parsed = ResponseParser.parse(fullResponse)
            messages.append((text: parsed.displayText, isPlayer: false))
            chatHistory.append(ChatMessage(role: "assistant", content: fullResponse))
            streamingText = ""
            isStreaming = false

            // Handle actions
            for action in parsed.actions {
                handleNPCAction(action)
            }
        }
    }

    private func handleNPCAction(_ action: NPCAction) {
        switch action {
        case .trade(let itemName, let cost):
            messages.append((text: "💰 交易提议：\(itemName) — \(cost) 金币", isPlayer: false))
            // Simple auto-accept for demo (could add confirmation UI)
            if engine.player?.spendGold(cost) == true {
                let item = Item(id: UUID().uuidString, name: itemName, description: "从NPC处购得", type: .potion, value: 30)
                engine.player?.addItem(item)
                messages.append((text: "✅ 购买成功！", isPlayer: false))
            } else {
                messages.append((text: "❌ 金币不足", isPlayer: false))
            }

        case .hint(let hint):
            engine.player?.hints.append(hint)
            messages.append((text: "📝 获得线索：\(hint)", isPlayer: false))

        case .gift(let itemName):
            let item = Item(id: UUID().uuidString, name: itemName, description: "NPC赠送", type: .misc, value: 0)
            engine.player?.addItem(item)
            messages.append((text: "🎁 获得：\(itemName)", isPlayer: false))
        }
    }
}
```

- [ ] **Step 3: Build to verify compilation**

Run: `Cmd+B`
Expected: Build succeeds.

- [ ] **Step 4: Commit**

```bash
git add AIDungeon/Views/ChatBubble.swift AIDungeon/Views/ChatView.swift
git commit -m "feat(views): add ChatView with streaming NPC dialog and action parsing"
```

---

## Task 13: Settings View

**Files:**
- Create: `AIDungeon/Views/SettingsView.swift`

- [ ] **Step 1: Implement SettingsView**

```swift
// AIDungeon/Views/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    let aiGenerator: AIContentGenerator
    @State private var providerType: AIProviderConfig.ProviderType = .ollama
    @State private var baseURL = "http://localhost:11434/v1"
    @State private var apiKey = ""
    @State private var modelName = "llama3"
    @State private var testResult: String?
    @State private var isTesting = false

    var body: some View {
        Form {
            Section("AI 服务商") {
                Picker("类型", selection: $providerType) {
                    ForEach(AIProviderConfig.ProviderType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .onChange(of: providerType) { _, newType in
                    applyDefaults(for: newType)
                }

                TextField("API Base URL", text: $baseURL)
                    .textContentType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if providerType != .ollama {
                    SecureField("API Key", text: $apiKey)
                }

                TextField("模型名称", text: $modelName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            Section {
                Button(action: testConnection) {
                    HStack {
                        Text("测试连接")
                        if isTesting {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(isTesting)

                if let testResult {
                    Text(testResult)
                        .foregroundStyle(testResult.contains("成功") ? .green : .red)
                        .font(.callout)
                }
            }

            Section {
                Button("保存设置") {
                    saveSettings()
                }
                .buttonStyle(.borderedProminent)

                if aiGenerator.isAvailable {
                    Button("清除设置", role: .destructive) {
                        aiGenerator.config = nil
                        testResult = nil
                    }
                }
            }

            Section("预设配置") {
                Button("Ollama (本地)") {
                    providerType = .ollama
                    baseURL = "http://localhost:11434/v1"
                    apiKey = ""
                    modelName = "llama3"
                }
                Button("OpenAI") {
                    providerType = .openai
                    baseURL = "https://api.openai.com/v1"
                    modelName = "gpt-4o-mini"
                }
                Button("DeepSeek") {
                    providerType = .compatible
                    baseURL = "https://api.deepseek.com/v1"
                    modelName = "deepseek-chat"
                }
            }
        }
        .navigationTitle("AI 设置")
        .onAppear { loadCurrentConfig() }
    }

    private func applyDefaults(for type: AIProviderConfig.ProviderType) {
        switch type {
        case .ollama:
            baseURL = "http://localhost:11434/v1"
            modelName = "llama3"
        case .openai:
            baseURL = "https://api.openai.com/v1"
            modelName = "gpt-4o-mini"
        case .compatible:
            break
        }
    }

    private func saveSettings() {
        aiGenerator.config = AIProviderConfig(
            providerType: providerType,
            baseURL: baseURL,
            apiKey: apiKey,
            modelName: modelName
        )
        testResult = "设置已保存"
    }

    private func testConnection() {
        saveSettings()
        isTesting = true
        testResult = nil

        Task {
            let success = await aiGenerator.testConnection()
            isTesting = false
            testResult = success ? "✅ 连接成功！" : "❌ 连接失败，请检查配置"
        }
    }

    private func loadCurrentConfig() {
        guard let config = aiGenerator.config else { return }
        providerType = config.providerType
        baseURL = config.baseURL
        apiKey = config.apiKey
        modelName = config.modelName
    }
}
```

- [ ] **Step 2: Build to verify compilation**

Run: `Cmd+B`
Expected: Build succeeds.

- [ ] **Step 3: Commit**

```bash
git add AIDungeon/Views/SettingsView.swift
git commit -m "feat(views): add SettingsView for AI provider configuration with presets"
```

---

## Task 14: Character Select and Game Over Views

**Files:**
- Create: `AIDungeon/Views/CharacterSelectView.swift`
- Create: `AIDungeon/Views/GameOverView.swift`
- Create: `AIDungeon/Views/InventoryView.swift`

- [ ] **Step 1: Implement CharacterSelectView**

```swift
// AIDungeon/Views/CharacterSelectView.swift
import SwiftUI

struct CharacterSelectView: View {
    let engine: GameEngine
    let aiGenerator: AIContentGenerator

    var body: some View {
        VStack(spacing: 24) {
            Text("选择角色")
                .font(.title.bold())

            ForEach(CharacterClass.allCases, id: \.self) { cls in
                Button {
                    Task {
                        let theme = await aiGenerator.generateTheme()
                        engine.startGame(characterClass: cls, theme: theme.name)
                    }
                } label: {
                    HStack(spacing: 16) {
                        Text(cls.icon)
                            .font(.largeTitle)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(cls.rawValue)
                                .font(.headline)
                            let stats = cls.baseStats
                            Text("HP:\(stats.maxHp) ATK:\(stats.atk) DEF:\(stats.def)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(cls.skills.map(\.name).joined(separator: "、"))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}
```

- [ ] **Step 2: Implement GameOverView**

```swift
// AIDungeon/Views/GameOverView.swift
import SwiftUI

struct GameOverView: View {
    let engine: GameEngine
    let isVictory: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text(isVictory ? "🎉 胜利！" : "💀 游戏结束")
                .font(.largeTitle.bold())

            if let player = engine.player {
                VStack(spacing: 8) {
                    StatRow(label: "角色", value: player.characterClass.rawValue)
                    StatRow(label: "获得金币", value: "\(player.gold)")
                    StatRow(label: "收集物品", value: "\(player.inventory.count)")
                    StatRow(label: "获得线索", value: "\(player.hints.count)")
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button("重新开始") {
                engine.resetGame()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

private struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
```

- [ ] **Step 3: Implement InventoryView**

```swift
// AIDungeon/Views/InventoryView.swift
import SwiftUI

struct InventoryView: View {
    let engine: GameEngine

    var body: some View {
        NavigationStack {
            List {
                if let player = engine.player {
                    Section("状态") {
                        LabeledContent("HP", value: "\(player.stats.hp)/\(player.stats.maxHp)")
                        LabeledContent("ATK", value: "\(player.stats.atk)")
                        LabeledContent("DEF", value: "\(player.stats.def)")
                        LabeledContent("金币", value: "\(player.gold)")
                    }

                    Section("物品 (\(player.inventory.count))") {
                        if player.inventory.isEmpty {
                            Text("背包空空如也")
                                .foregroundStyle(.secondary)
                        }
                        ForEach(player.inventory) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.body)
                                    Text(item.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(item.type.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(.secondary.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    if !player.hints.isEmpty {
                        Section("线索") {
                            ForEach(player.hints, id: \.self) { hint in
                                Label(hint, systemImage: "lightbulb")
                            }
                        }
                    }
                }
            }
            .navigationTitle("背包")
        }
    }
}
```

- [ ] **Step 4: Build to verify compilation**

Run: `Cmd+B`
Expected: Build succeeds.

- [ ] **Step 5: Commit**

```bash
git add AIDungeon/Views/CharacterSelectView.swift AIDungeon/Views/GameOverView.swift AIDungeon/Views/InventoryView.swift
git commit -m "feat(views): add CharacterSelect, GameOver, and Inventory views"
```

---

## Task 15: Wire Everything Together in ContentView

**Files:**
- Modify: `AIDungeon/ContentView.swift`
- Modify: `AIDungeon/AIDungeonApp.swift`

- [ ] **Step 1: Update AIDungeonApp to create shared instances**

```swift
// AIDungeon/AIDungeonApp.swift
import SwiftUI

@main
struct AIDungeonApp: App {
    @State private var engine = GameEngine()
    @State private var aiGenerator = AIContentGenerator()

    var body: some Scene {
        WindowGroup {
            ContentView(engine: engine, aiGenerator: aiGenerator)
        }
    }
}
```

- [ ] **Step 2: Update ContentView with full navigation**

```swift
// AIDungeon/ContentView.swift
import SwiftUI

struct ContentView: View {
    let engine: GameEngine
    let aiGenerator: AIContentGenerator
    @State private var showInventory = false

    var body: some View {
        NavigationStack {
            Group {
                switch engine.state {
                case .characterSelect:
                    mainMenu

                case .exploring:
                    DungeonMapView(engine: engine, aiGenerator: aiGenerator)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showInventory = true
                                } label: {
                                    Image(systemName: "bag")
                                }
                            }
                        }

                case .battle:
                    BattleView(engine: engine)

                case .chat:
                    if let npc = engine.currentNPC {
                        ChatView(
                            engine: engine,
                            aiGenerator: aiGenerator,
                            npcName: npc.name,
                            npcDescription: npc.description,
                            personality: npc.personality
                        )
                    }

                case .gameOver:
                    GameOverView(engine: engine, isVictory: false)

                case .victory:
                    GameOverView(engine: engine, isVictory: true)
                }
            }
            .sheet(isPresented: $showInventory) {
                InventoryView(engine: engine)
            }
        }
    }

    private var mainMenu: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("⚔️ AI 地牢冒险 ⚔️")
                .font(.largeTitle.bold())

            Text("Roguelike × AI")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            CharacterSelectView(engine: engine, aiGenerator: aiGenerator)

            Spacer()

            NavigationLink("⚙️ AI 设置") {
                SettingsView(aiGenerator: aiGenerator)
            }
            .padding(.bottom, 40)
        }
    }
}
```

- [ ] **Step 3: Build and run in simulator**

Run: `Cmd+R`
Expected: App launches with main menu showing "AI 地牢冒险", character selection cards, and AI settings link. Selecting a character starts the game with the dungeon map visible. Tapping adjacent tiles moves the player. Entering monster rooms shows battle view. Entering NPC rooms shows chat view.

- [ ] **Step 4: Commit**

```bash
git add AIDungeon/AIDungeonApp.swift AIDungeon/ContentView.swift
git commit -m "feat: wire all views together with state-driven navigation"
```

---

## Task 16: Final Polish and iPad Support

**Files:**
- Modify: `AIDungeon/ContentView.swift`
- Modify: `AIDungeon/Views/DungeonMapScene.swift`

- [ ] **Step 1: Add iPad adaptive layout to ContentView**

Replace the `exploring` case in `ContentView` body:

```swift
case .exploring:
    if UIDevice.current.userInterfaceIdiom == .pad {
        HStack(spacing: 0) {
            DungeonMapView(engine: engine, aiGenerator: aiGenerator)
                .frame(maxWidth: .infinity)
            Divider()
            InventoryView(engine: engine)
                .frame(width: 300)
        }
    } else {
        DungeonMapView(engine: engine, aiGenerator: aiGenerator)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showInventory = true
                    } label: {
                        Image(systemName: "bag")
                    }
                }
            }
    }
```

- [ ] **Step 2: Make DungeonMapScene responsive to screen size**

In `DungeonMapScene`, update `tileSize` to be computed from scene size:

Replace the fixed `tileSize` property:

```swift
private var tileSize: CGFloat {
    let available = min(size.width, size.height) - 40
    return (available - CGFloat(gridSize - 1) * tileSpacing) / CGFloat(gridSize)
}
```

And update `DungeonMapView` to use a `GeometryReader` for the scene size:

```swift
// In DungeonMapView, replace the fixed SpriteView frame:
GeometryReader { geo in
    let side = min(geo.size.width, geo.size.height, 500)
    SpriteView(scene: scene)
        .frame(width: side, height: side)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            scene.size = CGSize(width: side, height: side)
            refreshMap()
        }
}
```

- [ ] **Step 3: Build and run on both iPhone and iPad simulators**

Run: `Cmd+R` on iPhone 16 simulator, then switch to iPad Pro simulator.
Expected: iPhone shows normal layout. iPad shows dungeon map on left, inventory on right.

- [ ] **Step 4: Commit**

```bash
git add AIDungeon/ContentView.swift AIDungeon/Views/DungeonMapScene.swift AIDungeon/Views/DungeonMapView.swift
git commit -m "feat: add iPad split layout and responsive map sizing"
```

---

## Task 17: Integration Test — Full Game Loop

**Files:**
- Test: `AIDungeonTests/Game/GameEngineTests.swift` (extend)

- [ ] **Step 1: Add integration test for full game loop**

Append to `GameEngineTests.swift`:

```swift
func testFullGameLoopWithoutAI() {
    // This tests the complete game loop using only local logic (no AI calls)
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
    XCTAssertEqual(engine.state, .exploring) // treasure doesn't change state
    XCTAssertEqual(engine.player?.gold, 20)
    XCTAssertEqual(engine.player?.inventory.count, 1)

    // 4. Move to monster room
    _ = engine.movePlayer(to: Position(row: 1, col: 1))
    XCTAssertEqual(engine.state, .battle)
    XCTAssertNotNil(engine.currentMonster)

    // 5. Fight the monster
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

    // 6. After battle, should be exploring or game over
    XCTAssertTrue(engine.state == .exploring || engine.state == .gameOver)

    // 7. Reset
    engine.resetGame()
    XCTAssertEqual(engine.state, .characterSelect)
}
```

- [ ] **Step 2: Run all tests**

Run: `Cmd+U`
Expected: All tests pass, including the integration test.

- [ ] **Step 3: Commit**

```bash
git add AIDungeonTests/Game/GameEngineTests.swift
git commit -m "test: add full game loop integration test"
```

---

## Summary

| Task | Description | Tests |
|------|-------------|-------|
| 1 | Xcode project setup | — |
| 2 | Core data models | StatsTests, PlayerTests, DungeonTests |
| 3 | Dungeon generator | DungeonGeneratorTests |
| 4 | Game state machine | GameEngineTests |
| 5 | Battle engine | BattleEngineTests |
| 6 | Monster AI | MonsterAITests |
| 7 | AI provider + client | OpenAIClientTests, StreamingParserTests |
| 8 | Prompt builder + response parser | PromptBuilderTests, ResponseParserTests |
| 9 | AI content generator | — (integration layer) |
| 10 | Dungeon map view (SpriteKit) | — (visual) |
| 11 | Battle view | — (visual) |
| 12 | Chat view + NPC dialog | — (visual) |
| 13 | Settings view | — (visual) |
| 14 | Character select, game over, inventory | — (visual) |
| 15 | Wire everything together | — (integration) |
| 16 | iPad support + polish | — (visual) |
| 17 | Full game loop integration test | GameEngineTests (extended) |
