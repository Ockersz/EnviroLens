import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            Color.clear
                .accessibilityIdentifier("RegisterView")
            
            VStack(spacing: 16) {
                Image("RecycleBadge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding(.top, 10)
                
                Text("Sign up")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 4) {
                    customTextField("Name", text: $viewModel.name)
                    if viewModel.attemptedRegister && !FormValidator.isValidName(viewModel.name) {
                        validationMessage("Name cannot be empty.")
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    customTextField("Username", text: $viewModel.username)
                    if viewModel.attemptedRegister {
                        if !FormValidator.isValidUsername(viewModel.username) {
                            validationMessage("Username must be 3–15 characters, alphanumeric or underscore.")
                        } else if !FormValidator.isUsernameAllowed(viewModel.username) {
                            validationMessage("This username is reserved. Please choose another.")
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    customTextField("Email", text: $viewModel.email, keyboardType: .emailAddress)
                    if viewModel.attemptedRegister && !FormValidator.isValidEmail(viewModel.email) {
                        validationMessage("Please enter a valid email address.")
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    secureCustomField("Password", text: $viewModel.password)
                        .accessibilityIdentifier("PwdField")
                    if viewModel.attemptedRegister && !FormValidator.isStrongPassword(viewModel.password) {
                        validationMessage("Password must be 8+ chars, include upper/lowercase, number & special char.")
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    secureCustomField("Confirm Password", text: $viewModel.confirmPassword)
                        .accessibilityIdentifier("ConfField")
                    if viewModel.attemptedRegister && !FormValidator.passwordsMatch(viewModel.password, viewModel.confirmPassword) {
                        validationMessage("Passwords do not match.")
                    }
                }
                
                Button(action: {
                    viewModel.isShowingAreaDialog = true
                }) {
                    HStack {
                        Text(viewModel.selectedArea)
                            .foregroundColor(viewModel.selectedArea == "Select Area" ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(height: 50)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .confirmationDialog("Select Your Area", isPresented: $viewModel.isShowingAreaDialog) {
                    ForEach(viewModel.areas, id: \.self) { area in
                        Button(area) {
                            viewModel.selectedArea = area
                        }
                    }
                }
                
                if viewModel.attemptedRegister && viewModel.selectedArea == "Select Area" {
                    validationMessage("Please select an area.")
                }
                
                HStack(alignment: .top) {
                    Button(action: {
                        viewModel.acceptTerms.toggle()
                    }) {
                        Image(systemName: viewModel.acceptTerms ? "checkmark.square" : "square")
                            .foregroundColor(Color("PrBtnCol"))
                    }
                    
                    Text("I accept the ") +
                    Text("Terms").underline().foregroundColor(.blue) +
                    Text(" and ") +
                    Text("Privacy Policy").underline().foregroundColor(.blue)
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                if viewModel.attemptedRegister && !viewModel.acceptTerms {
                    validationMessage("You must accept the terms and privacy policy.")
                }
                
                if viewModel.attemptedRegister && !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    viewModel.registerUser {
                        dismiss()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 50)
                    } else {
                        Text("Sign up")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color("PrBtnCol"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .disabled(viewModel.isLoading)
                .accessibilityIdentifier("RegisterButton")
                
                HStack {
                    Text("Already a member?")
                        .foregroundColor(.secondary)
                    Button("Login") {
                        withAnimation {
                            dismiss()
                        }
                    }
                    .foregroundColor(.blue)
                }
                .font(.footnote)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Custom Field Components    
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
            .accessibilityIdentifier(placeholder)
    }
    
    func validationMessage(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.red)
            .padding(.horizontal)
    }
}
