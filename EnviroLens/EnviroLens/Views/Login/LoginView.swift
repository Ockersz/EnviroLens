import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var loginViewModel: LoginViewModel
    @StateObject private var biometricAuth = BiometricAuthViewModel()
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        _loginViewModel = StateObject(wrappedValue: LoginViewModel(authViewModel: authViewModel))
    }
    
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
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    customTextField("Username", text: $loginViewModel.username)
                        .accessibilityIdentifier("usernameField")
                    if loginViewModel.attemptedLogin && !FormValidator.isValidUsername(loginViewModel.username) {
                        Text("Please enter a valid username.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    secureCustomField("Password", text: $loginViewModel.password)
                        .accessibilityIdentifier("passwordField")
                    if loginViewModel.attemptedLogin && loginViewModel.password.isEmpty {
                        Text("Password cannot be empty.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                if !loginViewModel.errorMessage.isEmpty {
                    Text(loginViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: loginViewModel.handleLogin) {
                    if loginViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 50)
                    } else {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color("PrBtnCol"))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .disabled(loginViewModel.isLoading)
                .accessibilityIdentifier("loginButton")
                
                if !loginViewModel.isLoading {
                    Button(action: biometricAuth.authenticate) {
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
                            loginViewModel.navigateToRegister = true
                        }
                        .foregroundColor(.blue)
                    }
                    .font(.footnote)
                    .padding(.top, 10)
                }
            }
            .padding(.top)
            .background(Color(.systemBackground))
            .navigationDestination(isPresented: $loginViewModel.navigateToRegister) {
                RegisterView()
                    .accessibilityIdentifier("RegisterView")
            }
            .navigationDestination(isPresented: $loginViewModel.navigateToHome) {
                MainTabView()
                    .accessibilityIdentifier("MainTabView")
            }
            .onReceive(biometricAuth.$isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    if let credentials = KeychainManager.retrieve() {
                        loginViewModel.isLoading = true
                        authViewModel.signIn(email: credentials.email, password: credentials.password) { success, error in
                            DispatchQueue.main.async {
                                loginViewModel.isLoading = false
                                if let error = error {
                                    loginViewModel.errorMessage = error.localizedDescription
                                } else {
                                    loginViewModel.navigateToHome = true
                                }
                            }
                        }
                    } else {
                        loginViewModel.errorMessage = "No saved credentials found."
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
            .padding()
            .frame(height: 50)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .padding(.horizontal)
    }
}
