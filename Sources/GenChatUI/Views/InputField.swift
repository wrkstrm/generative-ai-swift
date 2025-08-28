#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct InputField<Label: View>: View {
  @Binding private var text: String
  private let title: String?
  private let onSubmit: () -> Void
  private let label: () -> Label

  public init(
    _ title: String? = nil,
    text: Binding<String>,
    onSubmit: @escaping () -> Void,
    @ViewBuilder label: @escaping () -> Label
  ) {
    self.title = title
    _text = text
    self.onSubmit = onSubmit
    self.label = label
  }

  public var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .bottom) {
        VStack(alignment: .leading) {
          TextField(
            title ?? "",
            text: $text,
            axis: .vertical,
          )
          .padding(.vertical, 4)
          .onSubmit { onSubmit() }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .padding(.bottom, 8)
        .overlay {
          RoundedRectangle(
            cornerRadius: 16,
            style: .continuous,
          )
          #if canImport(UIKit)
          .stroke(Color(uiColor: .systemFill), lineWidth: 1)
          #elseif canImport(AppKit)
          .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
          #else
          .stroke(Color.secondary, lineWidth: 1)
          #endif
        }

        Button(action: onSubmit, label: label)
          .padding(.bottom, 4)
      }
      .padding(8)
      .overlay(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
      )
    }
  }
}

#Preview {
  struct Wrapper: View {
    @State var userInput: String = ""

    var body: some View {
      InputField(
        "Message",
        text: $userInput,
        onSubmit: {}
      ) {
        Image(systemName: "arrow.up.circle.fill")
          .font(.title)
      }
    }
  }

  return Wrapper()
}
#endif
