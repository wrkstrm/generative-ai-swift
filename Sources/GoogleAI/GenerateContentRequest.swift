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

public enum GenerateContent {
  @available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
  public struct Request: HTTP.CodableURLRequest, Sendable {
    public typealias RequestBody = GenerateContent.Request.Body
    public typealias ResponseType = GenerateContentResponse

    public var method: WrkstrmNetworking.HTTP.Method = .post

    public var path: String {
      guard isStreaming else {
        return "\(body!.model):generateContent"
      }
      return "\(body!.model):streamGenerateContent?alt=sse"
    }

    public var queryItems: [URLQueryItem] = []

    /// Model name.
    public let isStreaming: Bool
    public let options: HTTP.Request.Options
    public var body: GenerateContent.Request.Body?

    public init(
      queryItems: [URLQueryItem] = [],
      isStreaming: Bool,
      options: HTTP.Request.Options,
      body: GenerateContent.Request.Body? = nil
    ) {
      self.queryItems = queryItems
      self.isStreaming = isStreaming
      self.options = options
      self.body = body
    }
  }
}

extension GenerateContent.Request {
  public struct Body: Encodable, Sendable {
    public let model: String
    public let contents: [ModelContent]
    public let generationConfig: GenerationConfig?
    public let safetySettings: [SafetySetting]?
    public let tools: [Tool]?
    public let toolConfig: ToolConfig?
    public let systemInstruction: ModelContent?

    public init(
      model: String,
      contents: [ModelContent],
      generationConfig: GenerationConfig?,
      safetySettings: [SafetySetting]? = nil,
      tools: [Tool]? = nil,
      toolConfig: ToolConfig? = nil,
      systemInstruction: ModelContent,
    ) {
      self.model = model
      self.contents = contents
      self.generationConfig = generationConfig
      self.safetySettings = safetySettings
      self.tools = tools
      self.toolConfig = toolConfig
      self.systemInstruction = systemInstruction
    }
  }
}
