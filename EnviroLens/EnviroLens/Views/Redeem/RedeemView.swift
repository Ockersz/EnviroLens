import SwiftUI

struct RedeemView: View {
    @State private var redeemItems: [RedeemCategory] = []
    @State private var userCredits = 0
    @State private var isLoading = false
    @State private var cart: [String: Int] = [:] // productId: quantity

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Redeem")
                        .font(.largeTitle.bold())
                    Spacer()
                    Text("\(userCredits) ") + Text(Image(systemName: "arrow.2.circlepath.circle.fill"))
                        .font(.title3)
                        .foregroundColor(.green)
                }
                .padding()

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
                                    Spacer()
                                    Button("See All") {}
                                        .font(.subheadline)
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
                                                    .font(.subheadline)

                                                HStack(spacing: 4) {
                                                    Image(systemName: "arrow.2.circlepath")
                                                        .foregroundColor(.green)
                                                    Text("\(product.credits)")
                                                }
                                                .font(.caption)

                                                HStack {
                                                    Button(action: {
                                                        if (cart[product.id] ?? 0) > 0 {
                                                            cart[product.id]! -= 1
                                                        }
                                                    }) {
                                                        Image(systemName: "minus")
                                                    }

                                                    Text("\(cart[product.id] ?? 0)")

                                                    Button(action: {
                                                        cart[product.id, default: 0] += 1
                                                    }) {
                                                        Image(systemName: "plus")
                                                    }
                                                }
                                                .font(.caption)
                                                .padding(6)
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
                        VStack(spacing: 8) {
                            let total = totalCredits()
                            Text("Total: \(total) credits")
                                .font(.headline)
                                .foregroundColor(total <= userCredits ? .green : .red)

                            Button("Redeem Items") {
                                // Perform redemption
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
        for category in redeemItems {
            for product in category.products {
                let quantity = cart[product.id] ?? 0
                total += product.credits * quantity
            }
        }
        return total
    }
}

// MARK: - Models

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

struct UserStats: Codable {
    let credits: Int
    let areaRank: Int
}