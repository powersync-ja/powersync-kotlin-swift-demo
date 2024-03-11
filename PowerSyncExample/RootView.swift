import Auth
import SwiftUI

struct RootView: View {
  @Environment(SupabaseConnector.self) var auth

  var body: some View {
    NavigationStack {
      if auth.session == nil {
        AuthWithEmailAndPassword()
      } else {
        HomeView()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}
