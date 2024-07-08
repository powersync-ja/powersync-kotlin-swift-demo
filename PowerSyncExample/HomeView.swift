import SwiftUI

struct HomeView: View {
    @Environment(PowerSync.self) var powerSync
  var body: some View {
    TodoListView()
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Sign out") {
            Task {
                try await powerSync.connector.client.auth.signOut()
            }
          }
        }
      }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView().environment(PowerSync())
  }
}
