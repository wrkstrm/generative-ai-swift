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
import WrkstrmLog

extension Log {
  /// A non default
  static let network: Log =
  if ProcessInfo.processInfo.arguments.contains(Logging.enableArgumentKey) {
    .init(system: Logging.subsystem, category: "NetworkResponse")
  } else {
    // Return a valid logger that's using `OSLog.disabled` as the logger, hiding everything.
    .disabled
  }
}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
struct GenerativeAIService: HTTP.Client {
  private let urlSession: URLSession
  
  var environment: any WrkstrmNetworking.HTTP.Environment
  
  var json: (encoder: JSONEncoder, decoder: JSONDecoder) = (.snakecase, .snakecase)

  init(environment: AI.GoogleGenAI.Environment) {
    self.environment = environment
    let configuration: URLSessionConfiguration = .default
    configuration.httpAdditionalHeaders = environment.headers
    urlSession = URLSession(configuration: configuration)
  }

  func loadRequest<T: HTTP.CodableURLRequest>(request: T) async throws -> T.ResponseType {
    let urlRequest = try request.asURLRequest(with: environment)

    #if DEBUG
    printCURLCommand(from: urlRequest)
    #endif

    let (data, rawResponse) = try await urlSession.data(for: urlRequest)

    let response = try httpResponse(urlResponse: rawResponse)

    // Verify the status code is 200
    guard response.statusCode.isHTTPOKStatusRange else {
      Log.network.error("The server responded with an error: \(response)")
      if let responseString = String(data: data, encoding: .utf8) {
        Log.shared.error("Response payload: \(responseString)")
      }

      throw parseError(responseData: data)
    }

    return try parseResponse(T.ResponseType.self, from: data)
  }

  func loadGenAIRequest<T: HTTP.CodableURLRequest>(request: T) async throws -> T.ResponseType {
    let urlRequest = try request.asURLRequest(with: environment)

    #if DEBUG
    printCURLCommand(from: urlRequest)
    #endif

    let data: Data
    let rawResponse: URLResponse
    (data, rawResponse) = try await urlSession.data(for: urlRequest)

    let response = try httpResponse(urlResponse: rawResponse)

    // Verify the status code is 200
    guard response.statusCode.isHTTPOKStatusRange else {
      Log.network.error("[GoogleGenerativeAI] The server responded with an error: \(response)")
      if let responseString = String(data: data, encoding: .utf8) {
        Logging.default.error("[GoogleGenerativeAI] Response payload: \(responseString)")
      }

      throw parseError(responseData: data)
    }

    return try parseResponse(T.ResponseType.self, from: data)
  }

  @available(macOS 12.0, *)
  func loadRequestStream<T: HTTP.CodableURLRequest>(request: T) -> AsyncThrowingStream<
    T.ResponseType, Error
  > where T.ResponseType: Sendable {
    AsyncThrowingStream { continuation in
      Task {
        let urlRequest: URLRequest
        do {
          urlRequest = try request.asURLRequest(with: environment)
        } catch {
          continuation.finish(throwing: error)
          return
        }

        #if DEBUG
        printCURLCommand(from: urlRequest)
        #endif

        let stream: URLSession.AsyncBytes
        let rawResponse: URLResponse
        do {
          (stream, rawResponse) = try await urlSession.bytes(for: urlRequest)
        } catch {
          continuation.finish(throwing: error)
          return
        }

        // Verify the status code is 200
        let response: HTTPURLResponse
        do {
          response = try httpResponse(urlResponse: rawResponse)
        } catch {
          continuation.finish(throwing: error)
          return
        }

        // Verify the status code is 200
        guard response.statusCode.isHTTPOKStatusRange else {
          Log.network
            .error("[GoogleGenerativeAI] The server responded with an error: \(response)")
          var responseBody = ""
          for try await line in stream.lines {
            responseBody += line + "\n"
          }

          Logging.default.error("[GoogleGenerativeAI] Response payload: \(responseBody)")
          continuation.finish(throwing: parseError(responseBody: responseBody))

          return
        }

        // Received lines that are not server-sent events (SSE); these are not prefixed with "data:"
        var extraLines = ""

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        for try await line in stream.lines {
          Log.network.verbose("[GoogleGenerativeAI] Stream response: \(line)")

          if line.hasPrefix("data:") {
            // We can assume 5 characters since it's utf-8 encoded, removing `data:`.
            let jsonText = String(line.dropFirst(5))
            let data: Data
            do {
              data = try jsonData(jsonText: jsonText)
            } catch {
              continuation.finish(throwing: error)
              return
            }

            // Handle the content.
            do {
              let content = try parseResponse(T.ResponseType.self, from: data)
              continuation.yield(content)
            } catch {
              continuation.finish(throwing: error)
              return
            }
          } else {
            extraLines += line
          }
        }

        if !extraLines.isEmpty {
          continuation.finish(throwing: parseError(responseBody: extraLines))
          return
        }

        continuation.finish(throwing: nil)
      }
    }
  }

  // MARK: - Private Helpers

  private func httpResponse(urlResponse: URLResponse) throws -> HTTPURLResponse {
    // Verify the status code is 200
    guard let response = urlResponse as? HTTPURLResponse else {
      Logging.default
        .error(
          "[GoogleGenerativeAI] Response wasn't an HTTP response, internal error \(urlResponse)"
        )
      throw NSError(
        domain: "com.google.generative-ai",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Response was not an HTTP response."]
      )
    }

    return response
  }

  private func jsonData(jsonText: String) throws -> Data {
    guard let data = jsonText.data(using: .utf8) else {
      let error = NSError(
        domain: "com.google.generative-ai",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Could not parse response as UTF8."]
      )
      throw error
    }

    return data
  }

  private func parseError(responseBody: String) -> Error {
    do {
      let data = try jsonData(jsonText: responseBody)
      return parseError(responseData: data)
    } catch {
      return error
    }
  }

  private func parseError(responseData: Data) -> Error {
    do {
      return try JSONDecoder().decode(RPCError.self, from: responseData)
    } catch {
      // TODO: Return an error about an unrecognized error payload with the response body
      return error
    }
  }

  private func parseResponse<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    do {
      return try JSONDecoder().decode(type, from: data)
    } catch {
      if let json = String(data: data, encoding: .utf8) {
        Log.network.error("[GoogleGenerativeAI] JSON response: \(json)")
      }
      Log.shared.error("[GoogleGenerativeAI] Error decoding server JSON: \(error)")
      throw error
    }
  }

  #if DEBUG
  private func cURLCommand(from request: URLRequest) -> String {
    var returnValue = "curl "
    if let allHeaders = request.allHTTPHeaderFields {
      for (key, value) in allHeaders {
        returnValue += "-H '\(key): \(value)' "
      }
    }

    guard let url = request.url else { return "" }
    returnValue += "'\(url.absoluteString)' "

    guard let body = request.httpBody,
      let jsonStr = String(bytes: body, encoding: .utf8)
    else { return "" }
    let escapedJSON = jsonStr.replacingOccurrences(of: "'", with: "'\\''")
    returnValue += "-d '\(escapedJSON)'"

    return returnValue
  }

  private func printCURLCommand(from request: URLRequest) {
    let command = cURLCommand(from: request)
    Logging.verbose.debug(
      """
      [GoogleGenerativeAI] Creating request with the equivalent cURL command:
      ----- cURL command -----
      \(command, privacy: .private)
      ------------------------
      """)
  }
  #endif  // DEBUG
}
