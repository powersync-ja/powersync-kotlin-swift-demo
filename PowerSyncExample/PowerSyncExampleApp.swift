import SwiftUI
import powersyncswift
import Supabase

@main
struct PowerSyncExampleApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
            RootView()
              .environment(SupabaseConnector())
        }
    }
}

let supabase = SupabaseClient(
  supabaseURL: Secrets.supabaseURL,
  supabaseKey: Secrets.supabaseAnonKey)
