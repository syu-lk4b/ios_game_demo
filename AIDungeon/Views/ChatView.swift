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
            VStack(spacing: 4) {
                Text(npcName)
                    .font(.headline)
                Text(npcDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)

            Divider()

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

            let parsed = ResponseParser.parse(fullResponse)
            messages.append((text: parsed.displayText, isPlayer: false))
            chatHistory.append(ChatMessage(role: "assistant", content: fullResponse))
            streamingText = ""
            isStreaming = false

            for action in parsed.actions {
                handleNPCAction(action)
            }
        }
    }

    private func handleNPCAction(_ action: NPCAction) {
        switch action {
        case .trade(let itemName, let cost):
            messages.append((text: "💰 交易提议：\(itemName) — \(cost) 金币", isPlayer: false))
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
