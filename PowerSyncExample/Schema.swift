import Foundation
import PowerSync


func createSchema() -> Schema {
    return Schema(tables: [
        Table(name: "todos", columns: [
            Column(name: "description", type: ColumnType.text),
            Column(name: "completed", type: ColumnType.integer)  // 0 or 1 to represent false or true
        ], indexes: [], localOnly: false, insertOnly: false, _viewNameOverride: "todos")
    ])
}


struct Todo: Identifiable, Hashable, Decodable {
    let id: String
    var description: String
    var isComplete: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case isComplete = "completed"
    }
}

struct NewTodo: Encodable {
    var description: String
    var isComplete: Bool
}
