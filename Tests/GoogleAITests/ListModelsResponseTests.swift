// Copyright 2025 wrkstrm
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
import Testing

@testable import GoogleGenerativeAI

@Suite("ListModels Response")
struct ListModelsResponseTests {
  @Test("decode response")
  func decodeResponse() throws {
    let json = """
      {
        "models": [
          {
            "name": "models/test-model",
            "baseModelId": "base-model",
            "version": "0.0.1",
            "displayName": "Test Model",
            "description": "Used for testing",
            "inputTokenLimit": 1000,
            "outputTokenLimit": 2000,
            "supportedGenerationMethods": ["generateContent", "countTokens"]
          }
        ],
        "nextPageToken": "token123"
      }
      """

    let data = try #require(json.data(using: .utf8))
    let decoder = JSONDecoder()
    let response = try decoder.decode(ListModels.Response.self, from: data)

    #expect(response.models.count == 1)
    let model = try #require(response.models.first)
    #expect(model.name == "models/test-model")
    #expect(model.baseModelId == "base-model")
    #expect(model.version == "0.0.1")
    #expect(model.displayName == "Test Model")
    #expect(model.description == "Used for testing")
    #expect(model.inputTokenLimit == 1000)
    #expect(model.outputTokenLimit == 2000)
    #expect(model.supportedGenerationMethods == ["generateContent", "countTokens"])
    #expect(response.nextPageToken == "token123")
  }

  @Test("decode response with missing optional fields")
  func decodeResponseWithMissingOptionalFields() throws {
    let json = """
      {
        "models": [
          {
            "name": "models/minimal"
          }
        ]
      }
      """

    let data = try #require(json.data(using: .utf8))
    let decoder = JSONDecoder()
    let response = try decoder.decode(ListModels.Response.self, from: data)

    #expect(response.models.count == 1)
    let model = try #require(response.models.first)
    #expect(model.name == "models/minimal")
    #expect(model.baseModelId == nil)
    #expect(model.version == nil)
    #expect(model.displayName == nil)
    #expect(model.description == nil)
    #expect(model.inputTokenLimit == nil)
    #expect(model.outputTokenLimit == nil)
    #expect(model.supportedGenerationMethods == nil)
    #expect(response.nextPageToken == nil)
  }
}
