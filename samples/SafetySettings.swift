// Copyright 2024 Google LLC
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

import GoogleGenerativeAI
import XCTest

// Set up your API Key
// ====================
// To use the Gemini API, you'll need an API key. To learn more, see the "Set up your API Key"
// section in the Gemini API quickstart:
// https://ai.google.dev/gemini-api/docs/quickstart?lang=swift#set-up-api-key

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
final class SafetySettingsSnippets: XCTestCase {
  override func setUpWithError() throws {
    try XCTSkipIf(
      APIKey.default.isEmpty,
      "`\(APIKey.apiKeyEnvVar)` environment variable not set."
    )
  }

  func testSafetySettings() {
    // [START safety_settings]
    let generativeModel =
      GenerativeModel(
        // Specify a Gemini model appropriate for your use case
        name: "gemini-1.5-flash",
        // Access your API key from your on-demand resource .plist file (see "Set up your API key"
        // above)
        apiKey: APIKey.default,
        safetySettings: [SafetySetting(harmCategory: .harassment, threshold: .blockLowAndAbove)]
      )
    // [END safety_settings]

    // Added to silence the compiler warning about unused variable.
    _ = String(describing: generativeModel)
  }

  func testSafetySettingsMulti() {
    // [START safety_settings_multi]
    let safetySettings = [
      SafetySetting(harmCategory: .dangerousContent, threshold: .blockLowAndAbove),
      SafetySetting(harmCategory: .harassment, threshold: .blockMediumAndAbove),
      SafetySetting(harmCategory: .hateSpeech, threshold: .blockOnlyHigh),
    ]

    let generativeModel =
      GenerativeModel(
        // Specify a Gemini model appropriate for your use case
        name: "gemini-1.5-flash",
        // Access your API key from your on-demand resource .plist file (see "Set up your API key"
        // above)
        apiKey: APIKey.default,
        safetySettings: safetySettings
      )
    // [END safety_settings_multi]

    // Added to silence the compiler warning about unused variable.
    _ = String(describing: generativeModel)
  }
}
