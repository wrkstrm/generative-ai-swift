#if os(Linux)
import Testing
@testable import GoogleGenerativeAI

@Suite("Environment Configuration")
struct EnvironmentConfigurationTests {
  @Test("default headers and configuration")
  func environmentConfiguration() {
    let env = AI.GoogleGenAI.Environment(apiKey: "test-key")
    let headers = env.headers

    #expect(env.baseURLString == "generativelanguage.googleapis.com")
    #expect(env.apiVersion == "v1beta")
    #expect(headers["x-goog-api-key"] == "test-key")
    #expect(
      headers["x-goog-api-client"] ==
        "genai-swift/\(String(describing: env.clientVersion))"
    )
    #expect(headers["Content-Type"] == "application/json")
  }
}
#endif
