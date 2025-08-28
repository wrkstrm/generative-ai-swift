// Copyright 2024 wrkstrm
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

/// Request and response types for the `models.list` endpoint.
public enum ListModels {
  @available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
  /// A request for the list of available models.
  public struct Request: HTTP.CodableURLRequest, Sendable {
    public typealias ResponseType = ListModels.Response

    public var method: HTTP.Method = .get
    public let options: HTTP.Request.Options
    public var pageSize: Int?
    public var pageToken: String?

    public init(
      options: HTTP.Request.Options,
      pageSize: Int? = nil,
      pageToken: String? = nil
    ) {
      self.options = options
      self.pageSize = pageSize
      self.pageToken = pageToken
    }

    public var path: String { "models" }

    public var queryItems: [URLQueryItem] {
      var items: [URLQueryItem] = []
      if let pageSize {
        items.append(.init(name: "page_size", value: String(pageSize)))
      }
      if let pageToken, !pageToken.isEmpty {
        items.append(.init(name: "page_token", value: pageToken))
      }
      return items
    }
  }
}

extension ListModels {
  @available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
  /// The response body containing model metadata.
  public struct Response: Decodable, Sendable {
    public let models: [Model]
    public let nextPageToken: String?
  }

  @available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
  /// Metadata describing a model returned by `ListModels`.
  public struct Model: Decodable, Sendable {
    public let name: String
    public let baseModelId: String?
    public let version: String?
    public let displayName: String?
    public let description: String?
    public let inputTokenLimit: Int?
    public let outputTokenLimit: Int?
    public let supportedGenerationMethods: [String]?
  }
}
