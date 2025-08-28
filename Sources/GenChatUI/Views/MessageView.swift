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
import MarkdownUI
import SwiftUI

struct MessageContentView: View {
  var message: ChatMessage

  var body: some View {
    if message.pending {
      BouncingDots()
    } else {
      Markdown(message.message)
        .markdownTextStyle {
          FontFamilyVariant(.normal)
          FontSize(.em(0.85))
          ForegroundColor(message.participant == .system ? Color.primary : .white)
        }
        .markdownBlockStyle(\.codeBlock) { configuration in
          configuration.label
            .relativeLineSpacing(.em(0.25))
            .markdownTextStyle {
              FontFamilyVariant(.monospaced)
              FontSize(.em(0.85))
              ForegroundColor(Color.primary)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .markdownMargin(top: .zero, bottom: .em(0.8))
        }
    }
  }
}

public struct MessageView: View {
  var message: ChatMessage

  public var body: some View {
    HStack {
      if message.participant == .user {
        Spacer()
      }
      MessageContentView(message: message)
        .padding(10)
        .background(
          message.participant == .system
            ? Color.gray.opacity(0.2)
            : Color.accentColor,
        )
        .roundedCorner(
          10,
          corners: [
            .topLeft,
            .topRight,
            message.participant == .system ? .bottomRight : .bottomLeft,
          ],
        )
      if message.participant == .system {
        Spacer()
      }
    }
    .listRowSeparator(.hidden)
  }
}

struct MessageView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      List {
        MessageView(message: ChatMessage.samples[0])
        MessageView(message: ChatMessage.samples[1])
        MessageView(message: ChatMessage.samples[2])
        MessageView(message: ChatMessage(message: "Hello!", participant: .system, pending: true))
      }
      .listStyle(.plain)
      .navigationTitle("Chat sample")
    }
  }
}

#endif
