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
