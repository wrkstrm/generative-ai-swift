import Testing
import GenChatUI
import CommonAI

// Dummy CommonAI chat/model/service to avoid network
actor DummyChat: CommonAIChat {
  private(set) var _history: [CAIContent]
  
  init(history: [CAIContent]) { _history = history }
  
  nonisolated var history: [CAIContent] { _history }
  
  func send(_ content: [CAIContent]) async throws -> CAIMessage {
    _history.append(contentsOf: content)
    return CAIMessage(role: .model, text: "Echo: \(content.compactMap { part in
    if case .text(let t) = part.parts.first {
    return t
    } else {
    return nil
    }
    }.joined())")
  }

  #if canImport(Darwin)
  @available(macOS 12.0, *)
  func sendStream(_ content: [CAIContent]) -> AsyncThrowingStream<CAIMessage, Error> {
    AsyncThrowingStream { continuation in
      continuation.yield(CAIMessage(role: .model, text: "Echo: "))
      continuation.yield(CAIMessage(role: .model, text: content.first.map { part in
        if case let .text(t) = part.parts.first { return t } else { return "" }
      } ?? ""))
      continuation.finish()
    }
  }
  #endif
}

struct DummyModel: CommonAIModel {
  let name: String
  func generateText(_ text: String) async throws -> CAIMessage { .init(role: .model, text: text) }
  func generate(_ content: [CAIContent]) async throws -> CAIMessage { .init(role: .model, text: "ok") }
  @MainActor func startChat(history: [CAIContent]) -> any CommonAIChat { DummyChat(history: history) }
}

struct DummyService: CommonAIService {
  let providerName: String = "Dummy"
  func model(named: String) -> any CommonAIModel { DummyModel(name: named) }
  func listModels(pageSize: Int?) async throws -> [CAIModelInfo] {
    [CAIModelInfo(name: "dummy-1", displayName: "Dummy 1"), CAIModelInfo(name: "dummy-2")] }
}

@Test
func ConversationVM_SendMessage_AppendsAndReplacesPending() async {
  let vm = await MainActor.run { ConversationViewModel(service: DummyService()) }
  #expect(vm.messages.count == 0)

  await vm.sendMessage("hello", streaming: false)
  // Expect two messages: user + model
  #expect(vm.messages.count == 2)
  #expect(vm.messages.first?.message == "hello")
  #expect(vm.messages.last?.pending == false)
  #expect((vm.messages.last?.message.contains("Echo")) == true)
}
