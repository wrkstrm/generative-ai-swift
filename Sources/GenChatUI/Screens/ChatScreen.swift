#if canImport(SwiftUI)
import SwiftUI
import CommonAI

public struct ChatScreen: View {
  @StateObject private var viewModel: ChatScreenViewModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  public init(service: any CommonAIService) {
    _viewModel = StateObject(wrappedValue: ChatScreenViewModel(service: service))
  }

  public init(googleAPIKey: String) {
    self.init(service: GoogleCommonAIService(apiKey: googleAPIKey))
  }

  public var body: some View {
    NavigationSplitView {
      List(selection: $viewModel.selectedChat) {
        ForEach(viewModel.chats, id: \.self) { chat in
          if let index = viewModel.chats.firstIndex(of: chat) {
            Text("Chat \(index + 1)")
              .tag(chat)
          }
        }
        .onDelete(perform: viewModel.deleteChats)
      }
      .navigationTitle("Chats")
      .toolbar {
        if horizontalSizeClass != .compact {
          ToolbarItem(placement: .primaryAction) {
            Button(action: viewModel.newChat) {
              Label("New Chat", systemImage: "square.and.pencil")
            }
          }
        }
      }
      .onAppear {
        if viewModel.selectedChat == nil {
          viewModel.selectedChat = viewModel.chats.first
        }
      }
    } detail: {
      if let conversationViewModel = viewModel.currentConversationViewModel {
        ConversationScreen()
          .environmentObject(conversationViewModel)
          .id(conversationViewModel.id)
      } else {
        Text("Select a chat")
      }
    }
    .toolbar {
      if horizontalSizeClass == .compact {
        ToolbarItem(placement: .primaryAction) {
          Button(action: viewModel.newChat) {
            Label("New Chat", systemImage: "square.and.pencil")
          }
        }
      }
    }
  }
}

#endif
