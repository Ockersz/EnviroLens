//
//  RedeemView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-15.
//


import SwiftUI
import UserNotifications

struct RedeemView: View {
    @State private var redeemItems: [RedeemCategory] = []
    @State private var userCredits = 0
    @State private var isLoading = false
    @State private var cart: [String: Int] = [:]
    @State private var showingCheckout = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Loading items...")
                        .padding()
                } else {
                    ScrollView {
                        ForEach(redeemItems) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(category.category)
                                        .font(.title3.bold())
                                }
                                .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(category.products) { product in
                                            VStack(spacing: 8) {
                                                Image(product.image)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 80, height: 80)
                                                
                                                Text(product.name)
                                                    .font(.headline)
                                                
                                                HStack(spacing: 4) {
                                                    Image(systemName: "leaf.fill")
                                                        .foregroundColor(.green)
                                                    Text("\(product.credits)")
                                                        .font(.subheadline)
                                                }
                                                .font(.caption)
                                                
                                                HStack(spacing: 16) {
                                                    Button(action: {
                                                        if (cart[product.id] ?? 0) > 0 {
                                                            cart[product.id]! -= 1
                                                        }
                                                    }) {
                                                        Image(systemName: "minus")
                                                            .font(.headline)
                                                            .frame(width: 36, height: 36)
                                                            .background(Color(.systemGray5))
                                                            .clipShape(Circle())
                                                    }
                                                    
                                                    Text("\(cart[product.id] ?? 0)")
                                                        .font(.headline)
                                                        .frame(minWidth: 28)
                                                    
                                                    Button(action: {
                                                        cart[product.id, default: 0] += 1
                                                    }) {
                                                        Image(systemName: "plus")
                                                            .font(.headline)
                                                            .frame(width: 36, height: 36)
                                                            .background(Color(.systemGray5))
                                                            .clipShape(Circle())
                                                    }
                                                }
                                                .padding(8)
                                                .background(Color(.systemGray6))
                                                .clipShape(Capsule())
                                            }
                                            .padding()
                                            .background(Color(.systemGray5))
                                            .cornerRadius(12)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    if !cart.isEmpty {
                        Divider()
                        HStack {
                            let total = totalCredits()
                            Text("Total: \(total) credits")
                                .font(.headline)
                                .foregroundColor(total <= userCredits ? .green : .red)
                            
                            Spacer()
                            Button("Checkout") {
                                showingCheckout = true
                            }
                            .disabled(total > userCredits)
                            .padding()
                            .background(total > userCredits ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                fetchUserCredits()
                fetchRedeemItems()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Redeem")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("\(userCredits)")
                                .font(.title2)
                                .fontWeight(.medium)
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
            }
            .sheet(isPresented: $showingCheckout) {
                VStack(spacing: 20) {
                    Text("Checkout Summary")
                        .font(.title.bold())
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(redeemItems.flatMap { $0.products }.filter { cart[$0.id, default: 0] > 0 }) { product in
                                HStack {
                                    Image(product.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    VStack(alignment: .leading) {
                                        Text(product.name)
                                        Text("\(cart[product.id]!) x \(product.credits) credits")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("\(cart[product.id]! * product.credits)")
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Divider()
                    
                    Text("Total: \(totalCredits()) credits")
                        .font(.headline)
                    
                    Button(action: {
                        var total = totalCredits()
                        
                        if total == 0 {
                            return
                        }
                        
                        userCredits -= total
                        cart.removeAll()
                        total = totalCredits()
                        showingCheckout = false
                        showSuccess = true
                        sendRedemptionNotification()
                    }) {
                        Text("Redeem Now")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }

                }
                .padding()
                .presentationDetents([.medium, .large])
            }
            .overlay(
                Group {
                    if showSuccess {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.green)
                                .transition(.scale)
                            
                            Text("Redemption Successful!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("You can collect the items at your nearest collection centre.")
                                .multilineTextAlignment(.center)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(.ultraThickMaterial)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showSuccess = false
                                }
                            }
                        }
                    }
                }, alignment: .center
            )
        }
    }
    
    func fetchRedeemItems() {
        guard let url = URL(string: "https://us-central1-envirolens-2ca53.cloudfunctions.net/getRedeemItems") else { return }
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { DispatchQueue.main.async { isLoading = false } }
            guard let data = data, error == nil else { return }
            do {
                let result = try JSONDecoder().decode([RedeemCategory].self, from: data)
                DispatchQueue.main.async {
                    self.redeemItems = result
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    func fetchUserCredits() {
        guard let url = URL(string: "https://getuserstats-33s7emkdia-uc.a.run.app") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let stats = try JSONDecoder().decode(UserStats.self, from: data)
                DispatchQueue.main.async {
                    self.userCredits = stats.credits
                }
            } catch {
                print("Credit fetch decode error")
            }
        }.resume()
    }
    
    func totalCredits() -> Int {
        var total = 0
        var cleanedCart: [String: Int] = [:]
        
        for category in redeemItems {
            for product in category.products {
                let quantity = cart[product.id] ?? 0
                if quantity > 0 {
                    total += product.credits * quantity
                    cleanedCart[product.id] = quantity
                }
            }
        }
        
        DispatchQueue.main.async {
            self.cart = cleanedCart
        }
        
        return total
    }

    
    func sendRedemptionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Items Redeemed"
        content.body = "Your redeemed items can now be collected at the nearest collection centre."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

struct RedeemCategory: Codable, Identifiable {
    var id: String { category }
    let category: String
    let products: [RedeemProduct]
}

struct RedeemProduct: Codable, Identifiable {
    let id: String
    let name: String
    let image: String
    let credits: Int
}

