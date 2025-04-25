//
//  OurMissionView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-15.
//


import SwiftUI

struct OurMissionView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Image("EarthBanner")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .shadow(radius: 4)

                Text("Our Mission")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        Text("Born from a desire to protect the Earth, EnviroLens is a product of passion and purpose. Our planet faces immense pressure from pollution and unsustainable habits. Every year, millions of tons of waste end up in oceans and landfills. We knew we had to act.")
                    }

                    HStack(alignment: .top) {
                        Image(systemName: "arrow.3.trianglepath")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        Text("Recycling isn't just a task; it's a movement. By building technology that empowers communities to track, sort, and dispose of waste responsibly, we're making sustainability accessible to all.")
                    }

                    HStack(alignment: .top) {
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.teal)
                        Text("Our mission is clear: reduce waste, raise awareness, and inspire the next generation to protect what truly matters. Together, we can make green living second nature.")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)

                VStack(spacing: 10) {
                    Text("Join the Movement")
                        .font(.title2.bold())
                        .foregroundColor(.accentColor)

                    Text("Every scanned item. Every smart bin. Every conscious choice. They all count. Let's build a better world, together.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .padding(.top)
        }
        .navigationTitle("Our Mission")
        .navigationBarTitleDisplayMode(.large)
    }
}
