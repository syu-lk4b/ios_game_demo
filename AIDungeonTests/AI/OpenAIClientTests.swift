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
