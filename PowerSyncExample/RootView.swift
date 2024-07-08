import Auth
import SwiftUI

struct RootView: View {
  @Environment(PowerSync.self) var powerSync
    
  var body: some View {
    NavigationStack {
        if powerSync.connector.session == nil {
        AuthWithEmailAndPassword()
      } else {
        HomeView()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    RootView().environment(PowerSync())
  }
}
