import CommonAI
import Testing

@Test
func CAIContentCodableRoundTrip() throws {
  let original = CAIContent.user("Hello")
  let data = try JSONEncoder().encode(original)
  let decoded = try JSONDecoder().decode(CAIContent.self, from: data)
  #expect(original == decoded)
}
