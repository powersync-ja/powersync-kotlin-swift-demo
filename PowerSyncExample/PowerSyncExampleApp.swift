import SwiftUI
import PowerSyncKotlin

@main
struct PowerSyncExampleApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(PowerSync())
        }
    }
}
