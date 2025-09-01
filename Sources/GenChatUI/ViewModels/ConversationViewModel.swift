// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if canImport(SwiftUI)
import Foundation
import SwiftUI
import GoogleGenerativeAI
import WrkstrmLog

extension Log {
  /// Logger for GenChatUI conversation flow.
  static let genChat = Log(
    system: "GenChatUI",
    category: "ConversationViewModel",
    maxExposureLevel: .trace
  )
}

@MainActor
public class ConversationViewModel: ObservableObject {
  /// This array holds both the user's and the system's chat messages
  @Published public var messages: [ChatMessage] = []

  /// Indicates we're waiting for the model to finish
  @Published public var busy = false

  @Published public var error: Error?
  public var hasError: Bool {
    error != nil
  }

  private var model: GenerativeModel
  private var chat: Chat
  private var stopGenerating = false

  private var chatTask: Task<Void, Never>?

  public init(apiKey: String) {
    model = GenerativeModel(
      name: "gemini-1.5-flash-latest",
      apiKey: apiKey,
      systemInstruction: "Have a nice chat.")
    chat = model.startChat()
  }

  public func sendMessage(_ text: String, streaming: Bool = true) async {
    error = nil
    Log.genChat.trace("sendMessage streaming=\(streaming) text=\(text)")
    if streaming {
      await internalSendMessageStreaming(text)
    } else {
      await internalSendMessage(text)
    }
  }

  public func startNewChat() {
    stop()
    error = nil
    chat = model.startChat()
    messages.removeAll()
  }

  public func stop() {
    chatTask?.cancel()
    error = nil
  }

  private func internalSendMessageStreaming(_ text: String) async {
    chatTask?.cancel()

    chatTask = Task {
      busy = true
      defer {
        busy = false
      }

      // first, add the user's message to the chat
      let userMessage = ChatMessage(message: text, participant: .user)
      messages.append(userMessage)

      // add a pending message while we're waiting for a response from the backend
      let systemMessage = ChatMessage.pending(participant: .system)
      messages.append(systemMessage)

      do {
        Log.genChat.trace("Sending streaming message: \(text)")
        let responseStream = chat.sendMessageStream(text)
        for try await chunk in responseStream {
          messages[messages.count - 1].pending = false
          if let text = chunk.text {
            Log.genChat.trace("Received chunk text: \(text)")
            messages[messages.count - 1].message += text
          }
        }
      } catch {
        self.error = error
        Log.genChat.error("Streaming error: \(error.localizedDescription)")
        messages.removeLast()
      }
    }
  }

  private func internalSendMessage(_ text: String) async {
    chatTask?.cancel()

    chatTask = Task {
      busy = true
      defer {
        busy = false
      }

      // first, add the user's message to the chat
      let userMessage = ChatMessage(message: text, participant: .user)
      messages.append(userMessage)

      // add a pending message while we're waiting for a response from the backend
      let systemMessage = ChatMessage.pending(participant: .system)
      messages.append(systemMessage)

      do {
        Log.genChat.trace("Sending message: \(text)")
        var response: GenerateContentResponse?
        response = try await chat.sendMessage(text)

        if let responseText = response?.text {
          Log.genChat.trace("Received response text: \(responseText)")
          // replace pending message with backend response
          messages[messages.count - 1].message = responseText
          messages[messages.count - 1].pending = false
        }
      } catch {
        self.error = error
        Log.genChat.error("Error: \(error.localizedDescription)")
        messages.removeLast()
      }
    }
  }
}

#endif
