import Foundation
import Observation

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
        } catch {}
        return FallbackContent.randomTheme()
    }

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
        } catch {}
        return ("神秘旅者", "一位风尘仆仆的旅人", "友善但警惕")
    }

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

    func testConnection() async -> Bool {
        guard let client else { return false }
        return (try? await client.testConnection()) ?? false
    }

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
