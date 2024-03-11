import Auth
import SwiftUI
import Supabase
import powersyncswift


@Observable
@MainActor
class SupabaseConnector: PowerSyncBackendConnector {
    let powerSyncEndpoint: String = Secrets.powerSyncEndpoint
    
    var session: Session?
    
    @ObservationIgnored
    private var observeAuthStateChangesTask: Task<Void, Never>?
    
    override init() {
        super.init()
        observeAuthStateChangesTask = Task {
            for await (event, session) in await supabase.auth.authStateChanges {
                guard [.initialSession, .signedIn, .signedOut].contains(event) else { return }
                
                self.session = session
            }
        }
    }
    
    var currentUserID: String {
        guard let id = session?.user.id else {
            preconditionFailure("Required session.")
        }
        
        return id.uuidString
    }
    
    var sessionExpiresAt: Kotlinx_datetimeInstant {
        guard let expireAt = session?.expiresAt else {
            preconditionFailure("Required session.")
        }
        
        return Kotlinx_datetimeInstant.companion.fromEpochMilliseconds(epochMilliseconds: Int64(expireAt))
    }
    
    override func __fetchCredentials() async throws -> PowerSyncCredentials? {
        if((self.session == nil)){
            throw AuthError.sessionNotFound
        }
        return PowerSyncCredentials(endpoint: self.powerSyncEndpoint, token: session!.accessToken, userId: currentUserID,
                                    expiresAt: sessionExpiresAt)
    }
    
    override func __uploadData(database: any PowerSyncDatabase) async throws {
        
        guard let transaction = try await database.getNextCrudTransaction() else { return }
        var lastEntry: CrudEntry? = nil
        do {
            for entry in transaction.crud {
                lastEntry = entry
                
                let table = await supabase.database.from(entry.table)
                
                
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
    
    
    deinit {
        observeAuthStateChangesTask?.cancel()
    }
}
