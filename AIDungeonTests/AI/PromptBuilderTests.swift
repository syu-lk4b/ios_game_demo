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
