import Foundation
import powersyncswift

class PowerSync {
    var factory = DatabaseDriverFactory()
//    var connector = SupabaseConnector()
    var schema = Schema(tables: [
        Table(name: "customers", columns: [
            Column(name: "name", type: ColumnType.text),
            Column(name: "email", type: ColumnType.text)
        ], indexes: [], localOnly: false, insertOnly: false, _viewNameOverride: "customers")
    ]
    )
    var db: PowerSyncDatabase!
    
    func connect() async {
        db = PowerSyncBuilderCompanion().from(factory: factory, schema: schema).build()
        
//        do {
//            try await db.connect(connector: connector)
//        } catch {
//            print("Unexpected error: \(error.localizedDescription)") // Catches any other error
//        }
    }
    
    func version() async -> String  {
        do {
            return try await db.getPowerSyncVersion()
        } catch {
            return error.localizedDescription
        }
    }
    
    func firstUser()async -> String {
        do {
            let result = try await self.db.getOptional(sql: "SELECT name FROM customers LIMIT 1", parameters: []) { cursor in
                cursor.getString(index: 0)!
            } as! String?
            return result != nil ? result! : "No Users"
        }catch {
            print("Error on querying firstUser: \(error)")
        }
        return "Error"
    }
    
    func createUser()async -> Void {
        
        await self.writeTransaction {
            try await self.db.execute(sql: "INSERT OR REPLACE INTO customers (id, name, email) VALUES (?, ?, ?)", parameters:["1", "Test User", "test@example.com"])
        }
    }
    
    func writeTransaction(_ handle: @escaping SuspendHandle) async {
        do {
            let _ = try await self.db.writeTransaction(body: SuspendWrapper {
                try await handle()
            })
        } catch {
            print("Error on writeTransaction: \(error)")
        }
    }
    
    func readTransaction(_ handle: @escaping SuspendHandle) async -> Any? {
        do {
            return try await self.db.readTransaction(body: SuspendWrapper {
                return try await handle()
            })
        } catch {
            print("Error on writeTransaction: \(error)")
            return nil
        }
    }
}

typealias SuspendHandle = () async throws -> Any?

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
