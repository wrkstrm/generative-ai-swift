#if canImport(SwiftUI)
import SwiftUI

@MainActor
public final class ChatScreenViewModel: ObservableObject {
  @Published public var chats: [UUID]
  @Published public var selectedChat: UUID?
  @Published public var conversationViewModels: [UUID: ConversationViewModel]
  private let apiKey: String
  private var chatCreationDates: [UUID: Date] = [:]

  public init(apiKey: String) {
    self.apiKey = apiKey
    let initialChat = UUID()
    chats = [initialChat]
    selectedChat = initialChat
    conversationViewModels = [initialChat: ConversationViewModel(apiKey: apiKey)]
    chatCreationDates[initialChat] = Date()
  }

  public func newChat() {
    let chat = UUID()
    chats.append(chat)
    chatCreationDates[chat] = Date()
    sortChatsByCreationDate()
    selectedChat = chat
    conversationViewModels[chat] = ConversationViewModel(apiKey: apiKey)
  }

  public func deleteChats(at offsets: IndexSet) {
    for index in offsets.sorted(by: >) {
      let chat = chats.remove(at: index)
      conversationViewModels.removeValue(forKey: chat)
      chatCreationDates.removeValue(forKey: chat)
    }
    sortChatsByCreationDate()

    if let selected = selectedChat, !chats.contains(selected) {
      selectedChat = chats.first
    }
  }

  private func sortChatsByCreationDate() {
    chats.sort { (chatCreationDates[$0] ?? .distantPast) < (chatCreationDates[$1] ?? .distantPast) }
  }

  public var currentConversationViewModel: ConversationViewModel? {
    selectedChat.flatMap { conversationViewModels[$0] }
  }
}
#endif
