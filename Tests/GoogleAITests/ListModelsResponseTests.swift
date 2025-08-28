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
import XCTest

@testable import GoogleGenerativeAI

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
final class ListModelsResponseTests: XCTestCase {
  func testDecodeResponse() throws {
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

    let data = try XCTUnwrap(json.data(using: .utf8))
    let decoder = JSONDecoder()
    let response = try decoder.decode(ListModels.Response.self, from: data)

    XCTAssertEqual(response.models.count, 1)
    let model = try XCTUnwrap(response.models.first)
    XCTAssertEqual(model.name, "models/test-model")
    XCTAssertEqual(model.baseModelId, "base-model")
    XCTAssertEqual(model.version, "0.0.1")
    XCTAssertEqual(model.displayName, "Test Model")
    XCTAssertEqual(model.description, "Used for testing")
    XCTAssertEqual(model.inputTokenLimit, 1000)
    XCTAssertEqual(model.outputTokenLimit, 2000)
    XCTAssertEqual(model.supportedGenerationMethods, ["generateContent", "countTokens"])
    XCTAssertEqual(response.nextPageToken, "token123")
  }

  func testDecodeResponseWithMissingOptionalFields() throws {
    let json = """
    {
      "models": [
        {
          "name": "models/minimal"
        }
      ]
    }
    """

    let data = try XCTUnwrap(json.data(using: .utf8))
    let decoder = JSONDecoder()
    let response = try decoder.decode(ListModels.Response.self, from: data)

    XCTAssertEqual(response.models.count, 1)
    let model = try XCTUnwrap(response.models.first)
    XCTAssertEqual(model.name, "models/minimal")
    XCTAssertNil(model.baseModelId)
    XCTAssertNil(model.version)
    XCTAssertNil(model.displayName)
    XCTAssertNil(model.description)
    XCTAssertNil(model.inputTokenLimit)
    XCTAssertNil(model.outputTokenLimit)
    XCTAssertNil(model.supportedGenerationMethods)
    XCTAssertNil(response.nextPageToken)
  }
}
