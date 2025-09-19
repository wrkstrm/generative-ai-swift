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
import SwiftUI

public struct ConversationScreen: View {
  @EnvironmentObject
  public var viewModel: ConversationViewModel

  @State private var userPrompt = ""
  @State private var selectedModel = ConversationViewModel.fallbackModelName
  @State private var pendingModel: String?
  @State private var showModelSwitchConfirmation = false

  public enum FocusedField: Hashable {
    case message
  }

  @FocusState
  public var focusedField: FocusedField?

  public var body: some View {
    VStack {
      ScrollViewReader { scrollViewProxy in
        List {
          ForEach(viewModel.messages) { message in
            MessageView(message: message)
          }
          if let error = viewModel.error {
            ErrorView(error: error)
              .tag("errorView")
          }
        }
        .listStyle(.plain)
        .onChange(of: viewModel.messages) {
          if viewModel.hasError {
            // wait for a short moment to make sure we can actually scroll to the bottom
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
              withAnimation {
                scrollViewProxy.scrollTo("errorView", anchor: .bottom)
              }
              focusedField = .message
            }
          } else {
            guard let lastMessage = viewModel.messages.last else { return }
            // wait for a short moment to make sure we can actually scroll to the bottom
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
              withAnimation {
                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
              }
              focusedField = .message
            }
          }
        }
      }
      InputField(
        "Message...",
        text: $userPrompt,
        onSubmit: {
          sendOrStop()
        },
        label: {
          Image(
            systemName: viewModel.busy
              ? "stop.circle.fill" : "arrow.up.circle.fill",
          )
          .font(.title)
        },
      )
      .focused($focusedField, equals: .message)
    }
    #if canImport(UIKit)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Picker("Model", selection: $selectedModel) {
          Text(ConversationViewModel.fallbackModelDisplayName)
          .tag(ConversationViewModel.fallbackModelName)
          ForEach(
            viewModel.availableModels.filter { $0.name != ConversationViewModel.fallbackModelName },
            id: \.name,
          ) { model in
            Text(model.displayName ?? model.name).tag(model.name)
          }
        }
        .pickerStyle(.menu)
        .onChange(of: selectedModel) { newValue in
          guard newValue != viewModel.selectedModelName else { return }
          pendingModel = newValue
          showModelSwitchConfirmation = true
        }
      }
    }
    #else
    .toolbar {
      ToolbarItem(placement: .automatic) {
        Picker("Model", selection: $selectedModel) {
          Text(ConversationViewModel.fallbackModelDisplayName)
          .tag(ConversationViewModel.fallbackModelName)
          ForEach(
            viewModel.availableModels.filter { $0.name != ConversationViewModel.fallbackModelName },
            id: \.name,
          ) { model in
            Text(model.displayName ?? model.name).tag(model.name)
          }
        }
        .pickerStyle(.menu)
        .onChange(of: selectedModel) { newValue in
          guard newValue != viewModel.selectedModelName else { return }
          pendingModel = newValue
          showModelSwitchConfirmation = true
        }
      }
    }
    #endif
    .alert("Switch model?", isPresented: $showModelSwitchConfirmation) {
      Button("Switch", role: .destructive) {
        if let pending = pendingModel {
          viewModel.selectModel(pending)
          selectedModel = pending
        }
      }
      Button("Cancel", role: .cancel) {
        selectedModel = viewModel.selectedModelName
      }
    } message: {
      Text("Switching models clears the current chat.")
    }
    .navigationTitle(viewModel.modelDisplayName)
    #if canImport(UIKit)
    .navigationBarTitleDisplayMode(.inline)
    #endif
    .onAppear {
      selectedModel = viewModel.selectedModelName
      focusedField = .message
    }
  }

  public init() {}

  private func sendMessage() {
    Task {
      let prompt = userPrompt
      userPrompt = ""
      await viewModel.sendMessage(prompt, streaming: true)
    }
  }

  private func sendOrStop() {
    focusedField = nil

    if viewModel.busy {
      viewModel.stop()
    } else {
      sendMessage()
    }
  }
}

struct ConversationScreen_Previews: PreviewProvider {
  struct ContainerView: View {
    @StateObject var viewModel = ConversationViewModel(service: GoogleCommonAIService(apiKey: ""))

    var body: some View {
      ConversationScreen()
        .environmentObject(viewModel)
        .onAppear {
          viewModel.messages = ChatMessage.samples
        }
    }
  }

  static var previews: some View {
    NavigationStack {
      ConversationScreen()
    }
  }
}

#endif
