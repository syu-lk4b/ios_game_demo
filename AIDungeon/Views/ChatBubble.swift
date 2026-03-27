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
