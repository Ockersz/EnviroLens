import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutConfirmation = false
    @State private var userStats: UserStats? = nil
    @State private var leaderBoard: [Leader] = []
    @State private var isLoadingStats = true
    @State private var isLoadingLeaders = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Greeting Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hi, \(authViewModel.currentUserName ?? "User")")
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
                        Button {
                            showingLogoutConfirmation = true
                        } label: {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.title2)
                        }
                    }
                    .foregroundColor(Color("PrBtnCol"))
                }
                .padding(.horizontal)
                .confirmationDialog("Account", isPresented: $showingLogoutConfirmation, titleVisibility: .visible) {
                    Button("Log Out", role: .destructive) {
                        authViewModel.signOut()
                    }
                    Button("Cancel", role: .cancel) { }
                }
                
                // Waste Stats
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Your Waste Credits")
                        Spacer()
                        HStack {
                            Text("\(userStats?.credits ?? 0)")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                        }
                    }
                    
                    HStack {
                        Text("Area Rank")
                        Spacer()
                        Text("#\(userStats?.areaRank ?? 0)")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .redacted(reason: isLoadingStats ? .placeholder : [])
                
                // Leaderboard
                VStack(alignment: .leading, spacing: 8) {
                    Text("Previous Month Winners")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    if isLoadingLeaders {
                        ForEach(0..<3, id: \.self) { _ in
                            HStack {
                                Text("Loading...")
                                Spacer()
                                Text("----")
                                Image(systemName: "crown.fill")
                            }
                        }
                        .redacted(reason: .placeholder)
                    } else {
                        ForEach(leaderBoard.prefix(3)) { leader in
                            HStack {
                                Text("#\(leader.rank) - \(leader.name)")
                                Spacer()
                                Text("\(leader.score)")
                                Image(systemName: "crown.fill")
                                    .foregroundColor(crownColor(for: leader.rank))
                            }
                        }
                    }
                }
                .font(.subheadline)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Explore App Section
                Text("Explore App")
                    .font(.headline)
                    .padding(.horizontal)
                
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 20) {
                    featureButton(image: "camera.fill", label: "Scan Waste", isCustom: false)
                    featureButton(image: "magnifyingglass", label: "Nearby Locations", isCustom: false)
                    featureButton(image: "trash.fill", label: "Dispose Waste", isCustom: false)
                    featureButton(image: "MyBins", label: "My Bins", isCustom: true)
                    featureButton(image: "Leaderboard", label: "Leaderboard", isCustom: true)
                    featureButton(image: "Mission", label: "Our Mission", isCustom: true)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding(.top)
        }
        .background(Color(.systemBackground))
        .onAppear {
            fetchUserStats()
            fetchTopLeaders()
        }
    }
    
    // MARK: - Feature Button
    func featureButton(image: String, label: String, isCustom: Bool) -> some View {
        VStack(spacing: 12) {
            if isCustom {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(Color("PrBtnCol"))
            } else {
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(Color("PrBtnCol"))
            }
            
            Text(label)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 130)
    }
    
    // MARK: - Crown Color for Leaderboard
    func crownColor(for rank: Int) -> Color {
        switch rank {
            case 1: return .yellow
            case 2: return .gray
            case 3: return .brown
            default: return .primary
        }
    }
    
    // MARK: - Network Calls
    func fetchUserStats() {
        guard let url = URL(string: "https://getuserstats-33s7emkdia-uc.a.run.app") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching stats: \(error)")
                return
            }
            guard let data = data else {
                print("No data")
                return
            }
            do {
                let stats = try JSONDecoder().decode(UserStats.self, from: data)
                DispatchQueue.main.async {
                    self.userStats = stats
                    self.isLoadingStats = false
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    func fetchTopLeaders() {
        guard let url = URL(string: "https://gettopleaderboard-33s7emkdia-uc.a.run.app") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching leaderboard: \(error)")
                return
            }
            guard let data = data else {
                print("No data")
                return
            }
            do {
                let response = try JSONDecoder().decode(LeaderBoard.self, from: data)
                DispatchQueue.main.async {
                    self.leaderBoard = response.leaders
                    self.isLoadingLeaders = false
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
}
