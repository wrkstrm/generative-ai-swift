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
    conversationViewModels = [initialChat: ConversationViewModel(apiKey: apiKey)]
  }

  public func newChat() {
    let chat = UUID()
    chats.append(chat)
    selectedChat = chat
    conversationViewModels[chat] = ConversationViewModel(apiKey: apiKey)
  }

  public var currentConversationViewModel: ConversationViewModel? {
    selectedChat.flatMap { conversationViewModels[$0] }
  }
}
#endif
