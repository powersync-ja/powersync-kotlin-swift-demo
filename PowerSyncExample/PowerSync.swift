import Foundation
import PowerSync

typealias SuspendHandle = () async throws -> Any?

@Observable
@MainActor
class PowerSync {
    var factory = DatabaseDriverFactory()
    var connector = SupabaseConnector()
    var schema = createSchema()
    var db: PowerSyncDatabase!

    func connect() async {
        db = PowerSyncDatabase(factory: factory, schema: schema)

        do {
            try await db.connect(connector: connector,crudThrottleMs: 100,retryDelayMs:100)
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
        try await self.db.execute(
            sql: "INSERT INTO todos (id, description, completed) VALUES (uuid(), ?, ?)",
            parameters: [todo.description, todo.isComplete]
        )
    }

    func updateTodo(_ todo: Todo) async throws {
        try await self.db.execute(
            sql: "UPDATE todos SET description = ?, completed = ? WHERE id = ?",
            parameters: [todo.description, todo.isComplete, todo.id]
        )
    }

    func deleteTodo(id: String) async throws {
        try await db.writeTransaction(body: SuspendTaskWrapper {
            try await self.db.execute(
                sql: "DELETE FROM todos WHERE id = ?",
                parameters: [id]
            )
            return
        })
    }

    func writeTransaction(_ queryHandle: @escaping () async throws -> Any) async throws -> Any? {
        try await db.writeTransaction(body: SuspendTaskWrapper(queryHandle))
    }

    func readTransaction(_ queryHandle: @escaping () async throws -> Any) async throws -> Any? {
        try await db.readTransaction(body: SuspendTaskWrapper(queryHandle))
    }
}

private class SuspendTaskWrapper: KotlinSuspendFunction1 {
    let handle: () async throws -> Any

    init(_ handle: @escaping () async throws -> Any) {
        self.handle = handle
    }

    @MainActor
    func invoke(p1: Any?, completionHandler: @escaping (Any?, Error?) -> Void) {
        Task {
            do {
                let result = try await self.handle()
                completionHandler(result, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
}
