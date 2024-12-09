import SwiftUI

private enum ActionState<Success, Failure: Error> {
    case idle
    case inFlight
    case result(Result<Success, Failure>)
}

struct SignInScreen: View {
    @Environment(PowerSync.self) private var powerSync
    @Environment(AuthModel.self) private var authModel
    @Environment(NavigationModel.self) private var navigationModel

    @State private var email = ""
    @State private var password = ""
    @State private var actionState = ActionState<Void, Error>.idle

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            Section {
                Button("Sign in") {
                    Task {
                        await signInButtonTapped()
                    }
                }
            }

            switch actionState {
                case .idle:
                    EmptyView()
                case .inFlight:
                    ProgressView()
                case let .result(.failure(error)):
                    ErrorText(error)
                case .result(.success):
                    Text("Sign in successful!")
            }

            Section {
                Button("Don't have an account? Sign up") {
                        navigationModel.path.append(Route.signUp)
                    }
            }
        }
    }

    private func signInButtonTapped() async {
        do {
            actionState = .inFlight
            try await powerSync.connector.client.auth.signIn(email: email, password: password)
            actionState = .result(.success(()))
            authModel.isAuthenticated = true
            navigationModel.path = NavigationPath()
        } catch {
            withAnimation {
                actionState = .result(.failure(error))
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignInScreen()
            .environment(PowerSync())
    }
}
