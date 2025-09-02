#if canImport(SwiftUI)
import SwiftUI
import GoogleGenerativeAI
import WrkstrmLog
import WrkstrmNetworking

@MainActor
public final class ChatScreenViewModel: ObservableObject {
  @Published public var chats: [UUID]
  @Published public var selectedChat: UUID? = nil
  @Published public var conversationViewModels: [UUID: ConversationViewModel] = [:]
  @Published public var availableModels: [ListModels.Model] = []
  @Published public var defaultModelName: String = ConversationViewModel.fallbackModelName
  private let apiKey: String

  public init(apiKey: String) {
    self.apiKey = apiKey
    let initialChat = UUID()
    chats = [initialChat]
    selectedChat = initialChat
    let initialViewModel = ConversationViewModel(
      apiKey: apiKey,
      availableModels: availableModels,
      selectedModelName: defaultModelName
    )
    conversationViewModels = [initialChat: initialViewModel]

    Task {
      await loadModels()
    }
  }

  public func newChat() {
    Task { @MainActor in
      if availableModels.isEmpty {
        await loadModels()
      }
      guard !availableModels.isEmpty else {
        Log.genChat.warning("Models not loaded; new chat aborted")
        return
      }
      let chat = UUID()
      let viewModel = ConversationViewModel(
        apiKey: apiKey,
        availableModels: availableModels,
        selectedModelName: defaultModelName
      )
      conversationViewModels[chat] = viewModel
      chats.append(chat)
      sortChatsByCreationDate()
      selectedChat = chat
    }
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

  private func loadModels() async {
    do {
      let environment = AI.GoogleGenAI.Environment.betaEnv(with: apiKey)
      let client = HTTP.CodableClient(
        environment: environment,
        json: (.snakecase, .snakecase)
      )
      let response = try await client.send(
        ListModels.Request(options: HTTP.Request.Options())
      )
      availableModels = response.models
      for viewModel in conversationViewModels.values {
        viewModel.availableModels = availableModels
      }
    } catch {
      Log.genChat.error("Failed to load models: \(error.localizedDescription)")
    }
  }
}
#endif
