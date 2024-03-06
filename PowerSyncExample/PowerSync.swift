
import powersyncswift

class DummyConnector: PowerSyncBackendConnector {
    func fetchCredentials() -> PowerSyncCredentials {
        return PowerSyncCredentials(endpoint: "", token: "", userId: "", expiresAt: nil)
    }
    
    func uploadData(database:PowerSyncDatabase) {}
}

typealias SuspendHandle = () async throws -> Any?

class PowerSync {
    var factory = DatabaseDriverFactory()
    var connector = DummyConnector()
    var schema = Schema(tables: [
        Table(name: "test", columns: [
            Column(name: "name", type: ColumnType.text)
        ], indexes: [], localOnly: false, insertOnly: false, _viewNameOverride: "test")
    ]
    )
    var db: PowerSyncDatabase!
    
    func connect() async {
        db = PowerSyncBuilderCompanion().from(factory: factory, schema: schema).build()
        
        // TODO: Implement connector.
        //                do {
        //                    try await db.connect(connector: connector)
        //                } catch {
        //                    print("Unexpected error: \(error)") // Catches any other error
        //                }
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
            let result = try await self.db.getOptional(sql: "SELECT name FROM test LIMIT 1", parameters: []) { cursor in
                cursor.getString(index: 0)!
            } as! String?
            return result != nil ? result! : "No Users"
        }catch {
            print("Error on querying firstUser: \(error)")
        }
        return "Error"
    }
    
    func createUser()async -> Void {
        do {
            let _ = try await self.db.writeTransaction(body: SuspendWrapper{
                try await self.db.execute(sql: "INSERT OR REPLACE INTO test (id, name) VALUES (?, ?)", parameters:["1", "Test User"])
            })
        }catch {
            print("Error on createUser: \(error)")
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
