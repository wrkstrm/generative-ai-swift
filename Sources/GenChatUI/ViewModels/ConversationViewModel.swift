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
import CommonAI
import Foundation
import SwiftUI
import WrkstrmLog

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

  private var model: any CommonAIModel
  private var chat: any CommonAIChat
  private var stopGenerating = false

  private var chatTask: Task<Void, Never>?

  private let service: any CommonAIService
  public let id = UUID()
  public let creationDate: Date

  @Published public var availableModels: [CAIModelInfo] = []
  @Published public private(set) var selectedModelName: String = ConversationViewModel
    .fallbackModelName

  public static let fallbackModelName = "gemini-1.5-flash-latest"
  public static let fallbackModelDisplayName = "Gemini 1.5 Flash"

  public init(
    service: any CommonAIService,
    availableModels: [CAIModelInfo] = [],
    selectedModelName: String = ConversationViewModel.fallbackModelName,
    creationDate: Date = Date(),
  ) {
    self.service = service
    self.creationDate = creationDate
    self.availableModels = availableModels
    self.selectedModelName = selectedModelName
    model = service.model(named: selectedModelName)
    chat = model.startChat(history: [.system("Have a nice chat.")])
  }

  // Convenience: construct with a Google API Key without exposing CommonAI in app code
  public convenience init(
    googleAPIKey: String,
    availableModels: [CAIModelInfo] = [],
    selectedModelName: String = ConversationViewModel.fallbackModelName,
    creationDate: Date = Date(),
  ) {
    let service = GoogleCommonAIService(apiKey: googleAPIKey)
    self.init(
      service: service,
      availableModels: availableModels,
      selectedModelName: selectedModelName,
      creationDate: creationDate,
    )
  }

  public var modelDisplayName: String {
    if selectedModelName == Self.fallbackModelName {
      return Self.fallbackModelDisplayName
    }
    return availableModels.first { $0.name == selectedModelName }?.displayName
      ?? selectedModelName
  }

  public func selectModel(_ name: String) {
    guard selectedModelName != name else { return }
    let chosenName: String =
      if name == Self.fallbackModelName
        || availableModels.contains(where: { $0.name == name })
      {
        name
      } else {
        Self.fallbackModelName
      }
    selectedModelName = chosenName
    model = service.model(named: chosenName)
    chat = model.startChat(history: [.system("Have a nice chat.")])
    messages.removeAll()
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
    chat = model.startChat(history: [.system("Have a nice chat.")])
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
        #if canImport(Darwin)
        let responseStream = chat.sendStream([.user(text)])
        for try await chunk in responseStream {
          messages[messages.count - 1].pending = false
          Log.genChat.trace("Received chunk text: \(chunk.text)")
          messages[messages.count - 1].message += chunk.text
        }
        #else
        let msg = try await chat.send([.user(text)])
        messages[messages.count - 1].pending = false
        messages[messages.count - 1].message = msg.text
        #endif
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
        let response = try await chat.send([.user(text)])
        Log.genChat.trace("Received response text: \(response.text)")
        // replace pending message with backend response
        messages[messages.count - 1].message = response.text
        messages[messages.count - 1].pending = false
      } catch {
        self.error = error
        Log.genChat.error("Error: \(error.localizedDescription)")
        messages.removeLast()
      }
    }
  }
}

#endif
