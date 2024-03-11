import Auth
import SwiftUI
import Supabase

@Observable
@MainActor
final class AuthController {
  var session: Session?

  var currentUserID: UUID {
    guard let id = session?.user.id else {
      preconditionFailure("Required session.")
    }

    return id
  }

  @ObservationIgnored
  private var observeAuthStateChangesTask: Task<Void, Never>?

  init() {
//    observeAuthStateChangesTask = Task {
//      for await (event, session) in await supabase.auth.authStateChanges {
//        guard [.initialSession, .signedIn, .signedOut].contains(event) else { return }
//
//        self.session = session
//      }
//    }
  }

  deinit {
    observeAuthStateChangesTask?.cancel()
  }
}
