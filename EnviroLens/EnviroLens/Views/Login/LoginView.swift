import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var biometricAuth = BiometricAuthViewModel()
    
    @State private var username = ""
    @State private var password = ""
    @State private var navigateToRegister = false
    @State private var navigateToHome = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var attemptedLogin = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Text("EnviroLens")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("PrBtnCol"))
                    Spacer()
                }
                .padding(.horizontal)
                
                Image("RecycleBadge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 10)
                
                Text("Log in")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    customTextField("Username", text: $username)
                        .accessibilityIdentifier("usernameField")
                    if attemptedLogin && !FormValidator.isValidUsername(username) {
                        Text("Please enter a valid username.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    secureCustomField("Password", text: $password)
                        .accessibilityIdentifier("passwordField")
                    if attemptedLogin && password.isEmpty {
                        Text("Password cannot be empty.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: handleLogin) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 50)
                    } else {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                 Color("PrBtnCol")
                                
                            )
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .disabled(isLoading)
                .accessibilityIdentifier("loginButton")
                
                if !isLoading {
                    Button(action: handleBiometricLogin) {
                        HStack {
                            Image(systemName: "faceid")
                            Text("Login with Face ID")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color("PrBtnCol"))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .accessibilityIdentifier("biometricLoginButton")
                    
                    
                    HStack {
                        Text("New member?")
                            .foregroundColor(.secondary)
                        Button("Sign Up") {
                            navigateToRegister = true
                        }
                        .foregroundColor(.blue)
                    }
                    .font(.footnote)
                    .padding(.top, 10)
                }
            }
            .padding(.top)
            .background(Color(.systemBackground))
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterView()
                    .accessibilityIdentifier("RegisterView")
            }
            .navigationDestination(isPresented: $navigateToHome) {
                MainTabView()
                    .accessibilityIdentifier("MainTabView")
            }
            .onReceive(biometricAuth.$isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    if let credentials = KeychainManager.retrieve() {
                        isLoading = true
                        authViewModel.signIn(email: credentials.email, password: credentials.password) { success, error in
                            isLoading = false
                            if let error = error {
                                self.errorMessage = error.localizedDescription
                            } else {
                                navigateToHome = true
                            }
                        }
                    } else {
                        self.errorMessage = "No saved credentials found."
                    }
                }
            }
            .alert(item: $biometricAuth.authError) { error in
                Alert(title: Text("Authentication Error"), message: Text(error), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func customTextField(_ placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .accessibilityIdentifier("usernameField")
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .frame(height: 50)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .padding(.horizontal)
    }
    
    func secureCustomField(_ placeholder: String, text: Binding<String>) -> some View {
        SecureField(placeholder, text: text)
            .accessibilityIdentifier("passwordField")
            .padding()
            .frame(height: 50)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .padding(.horizontal)
    }
    
    func formIsValid() -> Bool {
        FormValidator.isValidUsername(username) && !password.isEmpty
    }
    
    func handleLogin() {
        attemptedLogin = true
        guard formIsValid() else { return }
        
        isLoading = true
        errorMessage = ""
        
        authViewModel.signInWithUsername(username: username, password: password) { success, error in
            isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                _ = KeychainManager.save(email: authViewModel.lastSignedInEmail ?? "", password: password)
                navigateToHome = true
            }
        }
    }
    
    func handleBiometricLogin() {
        biometricAuth.authenticate()
    }
}
