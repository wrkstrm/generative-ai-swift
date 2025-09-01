#if canImport(SwiftUI)
import SwiftUI

public struct ChatScreen: View {
  @State private var chats: [UUID] = [UUID()]
  @State private var selectedChat: UUID?
  @StateObject private var viewModel = ConversationViewModel(apiKey: "")

  public init() {}

  public var body: some View {
    NavigationSplitView {
      List(chats, id: \.self, selection: $selectedChat) { chat in
        if let index = chats.firstIndex(of: chat) {
          Text("Chat \(index + 1)")
        }
      }
      .navigationTitle("Chats")
      .toolbar {
        Button(action: newChat) {
          Label("New Chat", systemImage: "square.and.pencil")
        }
      }
      .onAppear {
        if selectedChat == nil {
          selectedChat = chats.first
        }
      }
    } detail: {
      if selectedChat != nil {
        ConversationScreen()
          .environmentObject(viewModel)
      } else {
        Text("Select a chat")
      }
    }
  }

  private func newChat() {
    let chat = UUID()
    chats.append(chat)
    selectedChat = chat
    viewModel.startNewChat()
  }
}

#endif
