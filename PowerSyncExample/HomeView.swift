import SwiftUI

struct HomeView: View {
  @Environment(SupabaseConnector.self) var auth

  var body: some View {
    TodoListView()
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Sign out") {
            Task {
              try! await supabase.auth.signOut()
            }
          }
        }
      }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
