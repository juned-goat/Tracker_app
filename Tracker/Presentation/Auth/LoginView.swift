import SwiftUI

struct LoginView: View {
    @State var viewModel: LoginViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Email Login") {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)

                    Button("Sign In") {
                        Task { await viewModel.signInWithEmail() }
                    }
                }

                Section("Social Login") {
                    Button("Continue with Google") {
                        Task { await viewModel.signInWithGoogle() }
                    }
                }

                if case .failed(let message) = viewModel.state {
                    Section {
                        Text(message)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Tracker")
            .disabled(viewModel.state == .loading)
            .overlay {
                if viewModel.state == .loading {
                    ProgressView()
                }
            }
        }
    }
}
