import Foundation
import powersyncswift

typealias SuspendHandle = () async throws -> Any?

@Observable
@MainActor
class PowerSync {
    var factory = DatabaseDriverFactory()
    var connector = SupabaseConnector()
    var schema = createSchema()
    var db: PowerSyncDatabase!
    
    func connect() async {
        db = PowerSyncBuilderCompanion().from(factory: factory, schema: schema).build()
        
        do {
            try await db.connect(connector: connector)
        } catch {
            print("Unexpected error: \(error.localizedDescription)") // Catches any other error
        }
    }
    
    func version() async -> String  {
        do {
            return try await db.getPowerSyncVersion()
        } catch {
            return error.localizedDescription
        }
    }
    
    func watchTodos(_ cb: @escaping (_ todos: [Todo]) -> Void ) async {
        for await todos in self.db.watch(sql: "SELECT * FROM todos", parameters: [], mapper: { cursor in
            Todo(id: cursor.getString(index: 0)!, description: cursor.getString(index: 1)!, isComplete: cursor.getBoolean(index: 2)! as! Bool)
        }) {
            cb(todos as! [Todo])
        }
    }
    
    func insertTodo(_ todo: NewTodo) async throws {
            let _ = try await self.db.executeWrite(sql: "INSERT INTO todos (id, description, completed) VALUES (uuid(), ?, ?)", parameters: [todo.description, todo.isComplete])
    }
    
    func updateTodo(_ todo: Todo) async throws {
        let _ = try await self.db.executeWrite(sql: "UPDATE todos SET description = ?, completed = ? WHERE id = ?", parameters: [todo.description, todo.isComplete, todo.id])
    }
    
    func deleteTodo(id: String) async throws {
        let _ = try await self.db.executeWrite(sql: "DELETE FROM todos WHERE id = ?", parameters: [id])
    }
}

private class SuspendWrapper: KotlinSuspendFunction1 {
    
    let handle: SuspendHandle
    init(_ handle: @escaping SuspendHandle){
        self.handle = handle
    }
    
    func __invoke(p1: Any?, completionHandler: @escaping (Any?, Error?) -> Void) {
        Task {
            let res = try await self.handle()
            completionHandler(res, nil)
        }
    }
}
