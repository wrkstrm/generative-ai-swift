#if canImport(SwiftUI)
import SwiftUI

@MainActor
public final class ChatScreenViewModel: ObservableObject {
  @Published public var chats: [UUID]
  @Published public var selectedChat: UUID?
  @Published public var conversationViewModels: [UUID: ConversationViewModel]
  private let apiKey: String

  public init(apiKey: String) {
    self.apiKey = apiKey
    let initialChat = UUID()
    chats = [initialChat]
    selectedChat = initialChat
    let initialViewModel = ConversationViewModel(apiKey: apiKey)
    conversationViewModels = [initialChat: initialViewModel]
  }

  public func newChat() {
    let chat = UUID()
    let viewModel = ConversationViewModel(apiKey: apiKey)
    conversationViewModels[chat] = viewModel
    chats.append(chat)
    sortChatsByCreationDate()
    selectedChat = chat
  }

  public func deleteChats(at offsets: IndexSet) {
    for index in offsets.sorted(by: >) {
      let chat = chats.remove(at: index)
      conversationViewModels.removeValue(forKey: chat)
    }
    sortChatsByCreationDate()

    if let selected = selectedChat, !chats.contains(selected) {
      selectedChat = chats.first
    }
  }

  private func sortChatsByCreationDate() {
    chats.sort {
      let date0 = conversationViewModels[$0]?.creationDate ?? .distantPast
      let date1 = conversationViewModels[$1]?.creationDate ?? .distantPast
      return date0 < date1
    }
  }

  public var currentConversationViewModel: ConversationViewModel? {
    selectedChat.flatMap { conversationViewModels[$0] }
  }
}
#endif
