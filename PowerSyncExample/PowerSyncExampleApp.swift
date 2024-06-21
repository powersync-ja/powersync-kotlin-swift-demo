import SwiftUI
import PowerSync
import Supabase

@main
struct PowerSyncExampleApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
              .environment(PowerSync())
        }
    }
}
