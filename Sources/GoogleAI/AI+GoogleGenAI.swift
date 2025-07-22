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
import Foundation
import WrkstrmNetworking

#if !os(macOS) && !os(iOS)
  #warning("Only iOS, macOS, and Catalyst targets are currently fully supported.")
#endif

/// Constants associated with the GenerativeAISwift SDK.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
enum AI {
  enum GoogleGenAI {
    struct Environment: HTTP.Environment, Sendable {
      static func betaEnv(with apiKey: String) -> Environment {
        .init(apiKey: apiKey)
      }

      var clientVersion: String? = "0.5.6"
      var scheme: HTTP.Scheme = .https
      /// The Google AI backend endpoint URL.
      var baseURLString: String = "generativelanguage.googleapis.com"
      var apiVersion: String? = "v1beta"
      var apiKey: String?

      var headers: HTTP.Client.Headers {
        [
          "x-goog-api-key": apiKey ?? "",
          "x-goog-api-client": "genai-swift/\(String(describing: clientVersion))",
          "Content-Type": "application/json",
        ]
      }

      init(apiKey: String) {
        self.apiKey = apiKey
      }
    }
  }
}
