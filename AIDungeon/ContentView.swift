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
