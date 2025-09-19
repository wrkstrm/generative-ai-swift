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

#if canImport(Darwin)
@preconcurrency import Foundation
@preconcurrency import XCTest

@available(iOS 15.0, macOS 12.0, macCatalyst 15.0, *)
class MockURLProtocol: URLProtocol {
  nonisolated(unsafe) static var requestHandler: ((URLRequest) -> (URLResponse, [String]))?

  override class func canInit(with _: URLRequest) -> Bool { true }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    guard let requestHandler = MockURLProtocol.requestHandler else {
      fatalError("`requestHandler` is nil.")
    }
    let req = request
    guard let client else { fatalError("`client` is nil.") }
    let (response, lines) = requestHandler(req)
    client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    for line in lines {
      guard let data = line.data(using: .utf8) else {
        fatalError("Failed to convert \"\(line)\" to UTF8 data.")
      }
      client.urlProtocol(self, didLoad: data)
      client.urlProtocol(self, didLoad: "\n".data(using: .utf8)!)
    }
    client.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}
#endif
