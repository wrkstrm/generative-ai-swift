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

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
struct CountTokensRequest: GenerativeAIRequest {
  typealias Response = CountTokensResponse
  
  let model: String
  let generateContentRequest: GenerateContentRequest
  let options: HTTP.Request.Options
}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
extension CountTokensRequest: HTTP.Request.Codable {
  typealias ResponseType = CountTokensResponse
  
  var method: WrkstrmNetworking.HTTP.Method {
    .get
  }
  
  var path: String {
    "\(GenerativeAISwift.baseURL)/\(options.apiVersion)/\(model):countTokens"
  }
  
  var queryItems: [URLQueryItem] {
    []
  }

  var url: URL {
    URL(string: path)!
  }
}

/// The model's response to a count tokens request.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct CountTokensResponse: Codable, Sendable {
  /// The total number of tokens in the input given to the model as a prompt.
  public let totalTokens: Int
}

// MARK: - Codable Conformances

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
extension CountTokensRequest: Encodable {
  enum CodingKeys: CodingKey {
    case generateContentRequest
  }
}
