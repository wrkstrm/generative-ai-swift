#if canImport(SwiftUI)
import SwiftUI

public struct ChatScreen: View {
  @StateObject private var viewModel: ChatScreenViewModel

  public init(apiKey: String) {
    _viewModel = StateObject(wrappedValue: ChatScreenViewModel(apiKey: apiKey))
  }

  public var body: some View {
    NavigationSplitView {
      List(viewModel.chats, id: \.self, selection: $viewModel.selectedChat) { chat in
        if let index = viewModel.chats.firstIndex(of: chat) {
          Text("Chat \(index + 1)")
        }
      }
      .navigationTitle("Chats")
      .onAppear {
        if viewModel.selectedChat == nil {
          viewModel.selectedChat = viewModel.chats.first
        }
      }
    } detail: {
      if let conversationViewModel = viewModel.currentConversationViewModel {
        ConversationScreen()
          .environmentObject(conversationViewModel)
      } else {
        Text("Select a chat")
      }
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button(action: viewModel.newChat) {
          Label("New Chat", systemImage: "square.and.pencil")
        }
      }
    }
  }
}

#endif
