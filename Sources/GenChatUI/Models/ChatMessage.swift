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

public enum Participant {
  case system
  case user
}

public struct ChatMessage: Identifiable, Equatable {
  public let id = UUID().uuidString
  public var message: String
  public let participant: Participant
  public var pending = false

  public init(message: String, participant: Participant, pending: Bool = false) {
    self.message = message
    self.participant = participant
    self.pending = pending
  }

  public static func pending(participant: Participant) -> ChatMessage {
    Self(message: "", participant: participant, pending: true)
  }
}

extension ChatMessage {
  nonisolated(unsafe) public static let samples: [ChatMessage] = [
    .init(message: "Hello. What can I do for you today?", participant: .system),
    .init(message: "Show me a simple loop in Swift.", participant: .user),
    .init(
      message: """
        Sure, here is a simple loop in Swift:

        # Example 1
        ```
        for i in 1...5 {
          print("Hello, world!")
        }
        ```

        This loop will print the string "Hello, world!" five times.
        The for loop iterates over a range of numbers,
        in this case the numbers from 1 to 5. The variable i is assigned each number in the range,
        and the code inside the loop is executed.

        **Here is another example of a simple loop in Swift:**
        ```swift
        var sum = 0
        for i in 1...100 {
          sum += i
        }
        print("The sum of the numbers from 1 to 100 is \\(sum).")
        ```

        This loop calculates the sum of the numbers from 1 to 100.
        The variable sum is initialized to 0,
        and then the for loop iterates over the range of numbers from 1 to 100.
        The variable i is assigned each number in the range,
        and the value of i is added to the sum variable.
        After the loop has finished executing, the value of sum is printed to the console.
        """, participant: .system,
    ),
  ]

  nonisolated(unsafe) public static let sample = samples[0]
}

#endif
