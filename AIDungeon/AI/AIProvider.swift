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
    let role: String
    let content: String
}
