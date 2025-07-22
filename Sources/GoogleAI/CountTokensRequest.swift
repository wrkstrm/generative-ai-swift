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

public enum CountTokens {
  @available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
  public struct Request: HTTP.CodableURLRequest, Sendable {
    public typealias RequestBody = GenerateContent.Request.Body
    public typealias ResponseType = CountTokens.Response

    public var method: HTTP.Method = .post
    public let options: HTTP.Request.Options
    public let model: String
    public let body: RequestBody?

    public var path: String {
      "\(model):countTokens"
    }

    public init(options: HTTP.Request.Options, model: String, body: GenerateContent.Request.Body?) {
      self.options = options
      self.model = model
      if let body {
        self.body = body
      } else {
        self.body = nil
      }
    }
  }
}

extension CountTokens {
  /// The model's response to a count tokens request.
  @available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
  public struct Response: Decodable, Sendable {
    /// The total number of tokens in the input given to the model as a prompt.
    public let totalTokens: Int
  }
}
