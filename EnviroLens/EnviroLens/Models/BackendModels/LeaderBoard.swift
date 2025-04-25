//
//  LeaderBoard.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-12.
//

import Foundation

struct LeaderBoard: Codable {
    let leaders: [Leader]
}

struct Leader: Codable, Identifiable {
    let id = UUID()
    let name: String
    let score: Int
    let rank: Int
}
