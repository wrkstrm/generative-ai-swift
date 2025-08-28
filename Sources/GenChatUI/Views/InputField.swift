#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct InputField<Label>: View where Label: View {
  @Binding
  private var text: String

  private var title: String?
  private var label: () -> Label
  @Environment(\EnvironmentValues.submit) private var submitAction

  public init(
    _ title: String? = nil,
    text: Binding<String>,
    @ViewBuilder label: @escaping () -> Label,
  ) {
    self.title = title
    _text = text
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
          .onSubmit { submitAction() }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .overlay {
          RoundedRectangle(
            cornerRadius: 8,
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

        Button(action: { submitAction() }, label: label)
          .padding(.bottom, 4)
      }
    }
    .padding(8)
  }
}

#Preview {
  struct Wrapper: View {
    @State var userInput: String = ""

    var body: some View {
      InputField("Message", text: $userInput) {
        Image(systemName: "arrow.up.circle.fill")
          .font(.title)
      }
    }
  }

  return Wrapper()
}

#endif
