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
    
    func getTodos() async throws -> [String] {
        
        let res = try await self.db.getAll(sql: "SELECT * FROM todos", parameters: []) { cursor in
            cursor.getString(index: 0)!
        }
        
        return res as! [String]
        
    }
    
    func insertTodo(_ todo: PartialTodo) async {
        do {
            let newTodo = Todo(id: UUID(), description: todo.description, isComplete: todo.isComplete)
            
            let _ = try await self.db.executeWrite(sql: "INSERT INTO todos (id, description, completed) VALUES (uuid(), ?, ?)", parameters: [newTodo.description, newTodo.isComplete])
        }catch {
            print("Error: \(error.localizedDescription)")
        }
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
