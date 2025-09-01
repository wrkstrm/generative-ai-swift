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
import SwiftUI
import GoogleGenerativeAI

public struct ConversationScreen: View {

  @EnvironmentObject
  public var viewModel: ConversationViewModel

  @State private var userPrompt = ""

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
              ? "stop.circle.fill" : "arrow.up.circle.fill"
          )
          .font(.title)
        }
      )
      .focused($focusedField, equals: .message)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Menu {
          Button(ConversationViewModel.fallbackModelDisplayName) {
            viewModel.selectModel(ConversationViewModel.fallbackModelName)
          }
          ForEach(
            viewModel.availableModels.filter {
              $0.name != ConversationViewModel.fallbackModelName
            },
            id: \.name
          ) { model in
            Button(model.displayName ?? model.name) {
              viewModel.selectModel(model.name)
            }
          }
        } label: {
          Text(viewModel.modelDisplayName)
        }
      }
      ToolbarItem(placement: .primaryAction) {
        Button(action: newChat) {
          Image(systemName: "square.and.pencil")
        }
      }
    }
    .navigationTitle("Chat sample")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
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

  private func newChat() {
    viewModel.startNewChat()
  }
}

struct ConversationScreen_Previews: PreviewProvider {
  struct ContainerView: View {
    @StateObject var viewModel = ConversationViewModel(apiKey: "")

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
