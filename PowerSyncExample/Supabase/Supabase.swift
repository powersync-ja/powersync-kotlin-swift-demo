import Foundation
import powersyncswift
import Supabase


class SupabaseConnector: PowerSyncBackendConnector {
    let powerSyncEndpoint: String
    let client: SupabaseClient
    
    var session: Session?
    
    init(supabaseURL: URL, supabaseKey: String, powerSyncEndpoint: String) {
        self.powerSyncEndpoint = powerSyncEndpoint
        
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    func login(email: String, password: String) async {
        do {
            self.session = try await self.client.auth.signIn(email: email, password: password)
        } catch {
            print("Error signing in to Supabase: \(error)")
        }
    }
    
    
    override func __fetchCredentials() async throws -> PowerSyncCredentials? {
        if((self.session == nil)){
            throw AuthError.sessionNotFound
        }
        return PowerSyncCredentials(endpoint: self.powerSyncEndpoint, token: session!.accessToken, userId: session?.user.id.uuidString,
                                    expiresAt: Kotlinx_datetimeInstant.companion.fromEpochMilliseconds(epochMilliseconds: Int64(session!.expiresAt!)
                                                                                                      ))
    }
    
    override func __uploadData(database: any PowerSyncDatabase) async throws {
        
        guard let transaction = try await database.getNextCrudTransaction() else { return }
        var lastEntry: CrudEntry? = nil
        do {
            for entry in transaction.crud {
                lastEntry = entry
                
                let table = await client.database.from(entry.table)
                
                
                switch entry.op {
                case .put:
                    var data = entry.opData ?? [String: String]()
                    data["id"] = entry.id
                    let _ = try table.upsert(data);
                case .patch:
                    guard let opData = entry.opData else { continue }
                    let _ = try table.update(opData).eq("id", value: entry.id)
                    
                case .delete:
                    let _ = try await table.delete().eq( "id", value: entry.id).execute()
                }
            }
            
            let _ = try await transaction.complete.invoke(p1: nil)
            
        } catch {
            print("Data upload error - retrying last entry: \(lastEntry!), \(error)")
            throw error
        }
    }
}
