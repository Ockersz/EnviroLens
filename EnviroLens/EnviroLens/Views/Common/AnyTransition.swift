//
//  AnyTransition.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-10.
//
import SwiftUI

extension AnyTransition {
    static var slideFromRight: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
    
    static var slideFromLeft: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading),
            removal: .move(edge: .trailing)
        )
    }
}
