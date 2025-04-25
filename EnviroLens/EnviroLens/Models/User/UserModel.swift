//
//  UserModel.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-11.
//


import Foundation
import FirebaseFirestore

struct UserModel: Codable, Identifiable {
    @DocumentID var id: String?
    
    var name: String
    var username: String
    var email: String
    var area: String
    var createdAt: Date
}
