import Foundation

/// Compatibility wrapper matching tests that encode a generate-content request body directly.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct GenerateContentRequest: Encodable, Sendable {
  public let model: String
  public let contents: [ModelContent]
  public let generationConfig: GenerationConfig?
  public let safetySettings: [SafetySetting]?
  public let tools: [Tool]?
  public let toolConfig: ToolConfig?
  public let systemInstruction: ModelContent?

  // Additional transport options, not encoded into JSON payload.
  public let isStreaming: Bool
  public let options: RequestOptions

  public init(
    model: String,
    contents: [ModelContent],
    generationConfig: GenerationConfig?,
    safetySettings: [SafetySetting]?,
    tools: [Tool]?,
    toolConfig: ToolConfig?,
    systemInstruction: ModelContent?,
    isStreaming: Bool,
    options: RequestOptions,
  ) {
    self.model = model
    self.contents = contents
    self.generationConfig = generationConfig
    self.safetySettings = safetySettings
    self.tools = tools
    self.toolConfig = toolConfig
    self.systemInstruction = systemInstruction
    self.isStreaming = isStreaming
    self.options = options
  }

  public func encode(to encoder: Encoder) throws {
    // Encode only the body fields expected by the API (and tests).
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(model, forKey: .model)
    try container.encode(contents, forKey: .contents)
    try container.encodeIfPresent(generationConfig, forKey: .generationConfig)
    try container.encodeIfPresent(safetySettings, forKey: .safetySettings)
    try container.encodeIfPresent(tools, forKey: .tools)
    try container.encodeIfPresent(toolConfig, forKey: .toolConfig)
    try container.encodeIfPresent(systemInstruction, forKey: .systemInstruction)
  }

  enum CodingKeys: String, CodingKey {
    case model
    case contents
    case generationConfig
    case safetySettings
    case tools
    case toolConfig
    case systemInstruction
  }
}
