//
//  LeaderboardView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-15.
//

import SwiftUI

struct LeaderboardView: View {
    @State private var leaders: [Leader] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if isLoading {
                        ProgressView("Loading leaderboard...")
                            .padding()
                    } else {
                        if leaders.count >= 3 {
                            TopThreeLeadersView(leaders: Array(leaders.prefix(3)))
                        }
                        
                        // Remaining Leaders
                        VStack(spacing: 16) {
                            ForEach(leaders.dropFirst(3)) { leader in
                                LeaderRowView(leader: leader)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                fetchTopLeaders()
            }
        }
    }
    
    func fetchTopLeaders() {
        guard let url = URL(string: "https://gettopleaderboard-33s7emkdia-uc.a.run.app?type=all") else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
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
                    self.leaders = response.leaders.sorted(by: { $0.rank < $1.rank })
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
}

struct TopThreeLeadersView: View {
    let leaders: [Leader]
    
    var body: some View {
        VStack{
            if let first = leaders.first {
                LeaderCircleView(leader: first, color: .orange)
                    .frame(maxWidth: .infinity)
            }
           
            ZStack{
                HStack(spacing: 140) {
                    if leaders.count > 1 {
                        LeaderCircleView(leader: leaders[1], color: .blue)
                    }
                    
                    if leaders.count > 2 {
                        LeaderCircleView(leader: leaders[2], color: .green)
                    }
                }
            }
            .offset(y: -60)
        }
        .padding(.horizontal)
    }
}

struct LeaderCircleView: View {
    let leader: Leader
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color, lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Image("Person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                if leader.rank == 1 {
                    Image(systemName: "crown.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.yellow)
                        .offset(y: -55)
                }
            }
            
            Text(leader.name)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("\(leader.score)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

struct LeaderRowView: View {
    let leader: Leader
    
    var body: some View {
        HStack {
            Text("#\(leader.rank)")
                .font(.headline)
                .frame(width: 40, alignment: .leading)
            
            Image("Person")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            Text(leader.name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(leader.score)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
