import Foundation

struct Todo: Identifiable, Hashable, Decodable {
  let id: UUID
  var description: String
  var isComplete: Bool

  enum CodingKeys: String, CodingKey {
    case id
    case description
    case isComplete = "completed"
  }
}

struct CreateTodoRequest: Encodable {
  var description: String
  var isComplete: Bool

  enum CodingKeys: String, CodingKey {
    case description
    case isComplete = "completed"
  }
}

struct UpdateTodoRequest: Encodable {
  var description: String?
  var isComplete: Bool?

  enum CodingKeys: String, CodingKey {
    case description
    case isComplete = "completed"
  }
}
