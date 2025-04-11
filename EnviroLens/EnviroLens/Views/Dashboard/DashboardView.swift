import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header Greeting and Icons
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hi, User")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Welcome to EnviroLens")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 16) {
                        Image(systemName: "bell")
                            .font(.title2)
                        Button(action: {
                            showingLogoutConfirmation = true
                        }) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.title2)
                        }
                    }
                    .foregroundColor(Color("PrBtnCol")) // Use your green color
                }
                .padding(.horizontal)
                .confirmationDialog("Account", isPresented: $showingLogoutConfirmation, titleVisibility: .visible) {
                    Button("Log Out", role: .destructive) {
                        authViewModel.signOut();
                    }
                    Button("Cancel", role: .cancel) { }
                }
                
                // Waste Credits and Area Rank
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Your Waste Credits")
                        Spacer()
                        HStack {
                            Text("500")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                        }
                    }
                    
                    HStack {
                        Text("Area Rank")
                        Spacer()
                        Text("#15")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Leaderboard Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Previous Month Winners")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("#1 - User 1 (Gold)")
                            Spacer()
                            Text("1520")
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                        }
                        HStack {
                            Text("#2 - User 2 (Silver)")
                            Spacer()
                            Text("1200")
                            Image(systemName: "crown.fill")
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("#3 - User 3 (Bronze)")
                            Spacer()
                            Text("800")
                            Image(systemName: "crown.fill")
                                .foregroundColor(.brown)
                        }
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Explore App Title
                Text("Explore App")
                    .font(.headline)
                    .padding(.horizontal)
                
                // Grid of Feature Buttons
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 20) {
                    featureButton(image: "camera.fill", label: "Scan Waste")
                    featureButton(image: "magnifyingglass", label: "Search Nearby\nLocations")
                    featureButton(image: "trash.fill", label: "Dispose Waste")
                    
                    featureButton(image: "shippingbox.fill", label: "My Bins")
                    featureButton(image: "star.circle.fill", label: "Leaderboard")
                    featureButton(image: "target", label: "Our Mission")
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding(.top)
        }
        .background(Color(.systemBackground))
    }
    
    // Feature Button Builder
    func featureButton(image: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .foregroundColor(Color("PrBtnCol"))
            
            Text(label)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DashboardView().environmentObject(AuthViewModel())
}
