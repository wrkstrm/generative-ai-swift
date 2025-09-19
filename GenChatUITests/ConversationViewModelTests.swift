import CommonAI
import GenChatUI
import Testing

// Dummy CommonAI chat/model/service to avoid network
@MainActor
final class DummyChat: CommonAIChat {
  var history: [CAIContent]

  init(history: [CAIContent]) { self.history = history }

  func send(_ content: [CAIContent]) async throws -> CAIMessage {
    history.append(contentsOf: content)
    let echoed = content.compactMap { item in
      if case .text(let t) = item.parts.first { return t }
      return nil
    }.joined()
    return CAIMessage(role: .model, text: "Echo: \(echoed)")
  }

  #if canImport(Darwin)
  @available(macOS 12.0, *)
  func sendStream(_ content: [CAIContent]) -> AsyncThrowingStream<CAIMessage, Error> {
    AsyncThrowingStream { continuation in
      continuation.yield(CAIMessage(role: .model, text: "Echo: "))
      let tail =
        content.first.map { item in
          guard case .text(let t) = item.parts.first else { return "" }
          return t
        } ?? ""
      continuation.yield(CAIMessage(role: .model, text: tail))
      continuation.finish()
    }
  }
  #endif
}

// Conformance is safe due to @MainActor confinement
extension DummyChat: @unchecked Sendable {}

struct DummyModel: CommonAIModel {
  let name: String
  func generateText(_ text: String) async throws -> CAIMessage { .init(role: .model, text: text) }
  func generate(_ content: [CAIContent]) async throws -> CAIMessage {
    .init(role: .model, text: "ok")
  }
  @MainActor func startChat(history: [CAIContent]) -> any CommonAIChat {
    DummyChat(history: history)
  }
}

struct DummyService: CommonAIService {
  let providerName: String = "Dummy"
  func model(named: String) -> any CommonAIModel { DummyModel(name: named) }
  func listModels(pageSize: Int?) async throws -> [CAIModelInfo] {
    [CAIModelInfo(name: "dummy-1", displayName: "Dummy 1"), CAIModelInfo(name: "dummy-2")]
  }
}

@Test
func ConversationVM_SendMessage_AppendsAndReplacesPending() async {
  let vm = await MainActor.run { ConversationViewModel(service: DummyService()) }
  #expect(vm.messages.isEmpty)

  await vm.sendMessage("hello", streaming: false)
  // Expect two messages: user + model
  #expect(vm.messages.count == 2)
  #expect(vm.messages.first?.message == "hello")
  #expect(vm.messages.last?.pending == false)
  #expect((vm.messages.last?.message.contains("Echo")) == true)
}
