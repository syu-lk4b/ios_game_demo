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
