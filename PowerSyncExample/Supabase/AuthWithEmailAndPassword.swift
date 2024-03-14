import SwiftUI

enum ActionState<Success, Failure: Error> {
  case idle
  case inFlight
  case result(Result<Success, Failure>)
}

struct AuthWithEmailAndPassword: View {
    enum Mode {
        case signIn, signUp
    }
    
    enum Result {
        case needsEmailConfirmation
    }
    
    @Environment(PowerSync.self) var powerSync
    
    @State var email = ""
    @State var password = ""
    @State var mode: Mode = .signIn
    @State var actionState = ActionState<Result, Error>.idle
    
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
                Button(mode == .signIn ? "Sign in" : "Sign up") {
                    Task {
                        await primaryActionButtonTapped()
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
            case .result(.success(.needsEmailConfirmation)):
                Section {
                    Text("Check you inbox.")
                    
                    Button("Resend confirmation") {
                        Task {
                            await resendConfirmationButtonTapped()
                        }
                    }
                }
            }
        }
        .onOpenURL { url in
            Task {
                await onOpenURL(url)
            }
        }
        .animation(.default, value: mode)
    }
    
    func primaryActionButtonTapped() async {
        do {
            actionState = .inFlight
            switch mode {
            case .signIn:
                try await powerSync.connector.client.auth.signIn(email: email, password: password)
            case .signUp:
                let response = try await powerSync.connector.client.auth.signUp(
                    email: email,
                    password: password,
                    redirectTo: Constants.redirectToURL
                )
                
                if case .user = response {
                    actionState = .result(.success(.needsEmailConfirmation))
                }
            }
        } catch {
            withAnimation {
                actionState = .result(.failure(error))
            }
        }
    }
    
    private func onOpenURL(_ url: URL) async {
        do {
            try await powerSync.connector.client.auth.session(from: url)
        } catch {
            debug("Fail to init session with url: \(url)")
        }
    }
    
    private func resendConfirmationButtonTapped() async {
        do {
            try await powerSync.connector.client.auth.resend(email: email, type: .signup)
        } catch {
            debug("Fail to resend email confirmation: \(error)")
        }
    }
}

#Preview {
    AuthWithEmailAndPassword()
        .environment(PowerSync())
}
