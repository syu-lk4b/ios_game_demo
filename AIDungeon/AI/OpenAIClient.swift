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

    func streamComplete(messages: [ChatMessage]) -> AsyncStream<String> {
        let request = buildRequest(messages: messages, stream: true)

        return AsyncStream { continuation in
            let task = session.dataTask(with: request) { data, _, error in
                if error != nil {
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
